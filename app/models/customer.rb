class Customer < ApplicationRecord
  belongs_to :organization

  has_many :conversations, dependent: :restrict_with_exception

  normalizes :phone, with: ->(phone) { phone.gsub(/\D/, "") }

  validates :name, presence: true, length: { maximum: 200 }
  validates :phone, length: { maximum: 30 }, allow_blank: true
  validates :company_name, :external_crm_id, length: { maximum: 200 }, allow_blank: true
end
