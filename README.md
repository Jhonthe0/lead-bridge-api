# Lead Bridge API

Rails API for securely ingesting WhatsApp Business conversations captured by an authorized Android device.

## Requirements

- Ruby 3.3.1
- Rails 8.1
- PostgreSQL 14 or newer
- Docker and Docker Compose (recommended)

## Setup with Docker

```bash
cp .env.example .env
docker compose build
./goo setup
./goo start
```

The API is available at `http://localhost:3000`; PostgreSQL is exposed on port `5432`.

## Setup without Docker

Create PostgreSQL databases named `lead_bridge_api_development` and `lead_bridge_api_test`, then run:

```bash
bundle install
cp .env.example .env
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Database settings can be supplied with `DATABASE_HOST`, `DATABASE_USER`, `DATABASE_PASSWORD`, `DATABASE_NAME`,
and `DATABASE_TEST_NAME`. Production uses `DATABASE_URL`. Rails stores and emits timestamps in UTC.

Set `DEVICE_REGISTRATION_SECRET` to a long random value. It authorizes provisioning only; registered devices
receive their own bearer tokens, whose SHA-256 digests are the only token values stored in PostgreSQL.

## Tests and formatting

```bash
./goo test
./goo cop
```

Without Docker, use `bundle exec rspec` and `bundle exec rubocop -A`.

## Register a device

The `user_id` must already exist. The organization is derived from that user and cannot be supplied by Android.

```bash
curl -X POST http://localhost:3000/api/v1/devices/register \
  -H 'Content-Type: application/json' \
  -H 'X-Registration-Token: replace-with-a-long-random-secret' \
  -d '{
    "device": {
      "user_id": "USER_UUID",
      "device_uuid": "5f47d1b5-4ad4-48e3-9f94-cec42c69e739",
      "name": "Galaxy S25",
      "platform": "android",
      "app_version": "0.1.0"
    }
  }'
```

Store the returned token securely on Android. It is shown only in the registration response.

## Create a capture

```bash
curl -X POST http://localhost:3000/api/v1/captures \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer DEVICE_TOKEN' \
  -d '{
    "capture_uuid": "a48495b5-290b-43c7-97d1-25912a052426",
    "captured_at": "2026-10-01T12:30:00Z",
    "source": "whatsapp_business",
    "contact": {
      "display_name": "João da Silva",
      "phone": null
    },
    "messages": [
      {
        "temporary_id": "local-001",
        "sender_type": "customer",
        "body": "Preciso de 200 unidades.",
        "occurred_at": "2026-10-01T12:25:00Z"
      },
      {
        "temporary_id": "local-002",
        "sender_type": "seller",
        "body": "Consigo entregar sexta.",
        "occurred_at": "2026-10-01T12:26:00Z"
      }
    ]
  }'
```

Successful creation returns HTTP `201`. Replaying the same `capture_uuid` returns HTTP `200`, the original IDs,
and `messages_created: 0` without duplicating data.

See [docs/architecture.md](docs/architecture.md) for module boundaries, tenant guarantees, migrations, and routes.
