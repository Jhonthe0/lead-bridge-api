# Architecture

## Application boundaries

- Controllers own HTTP authentication, strong parameters, status codes, and JSON rendering.
- `Captures::Create` orchestrates the atomic ingestion transaction.
- `Customers::FindOrCreate` owns customer resolution within an organization.
- `Devices::Register` and `Devices::Authenticate` isolate credential operations.
- Query objects own filtering and pagination; serializers own response shapes.
- Models enforce local invariants while PostgreSQL foreign keys enforce tenant consistency.

## Tenant isolation

The authenticated device determines the current user and organization. Android payloads cannot select an
`organization_id`. Every API lookup starts from `current_organization`, and composite foreign keys prevent a
conversation or message from referencing records in another organization.

## Idempotency

`conversations.capture_uuid` has a global unique index. Replaying a successful capture returns the existing
conversation with `messages_created: 0`. A partial unique index on
`(conversation_id, external_identifier)` prepares message-level deduplication using Android `temporary_id` values.

## Initial migrations

1. Enable `pgcrypto` for UUID generation.
2. Create organizations.
3. Create users and roles.
4. Create devices and token digests.
5. Create customers and search indexes.
6. Create conversations, capture idempotency, and tenant foreign keys.
7. Create messages, enum checks, and future deduplication index.

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/api/v1/devices/register` | Register a device and issue its token |
| GET | `/api/v1/customers` | Paginated customer list |
| GET | `/api/v1/customers/search?q=` | Search customers |
| GET | `/api/v1/customers/:id` | Fetch a customer |
| POST | `/api/v1/customers` | Create a customer |
| POST | `/api/v1/conversations` | Create a conversation |
| GET | `/api/v1/conversations/:id` | Fetch a conversation and messages |
| POST | `/api/v1/conversations/:conversation_id/messages` | Append a message |
| POST | `/api/v1/captures` | Atomically ingest a complete capture |
