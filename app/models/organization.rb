class Organization < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception
  has_many :devices, dependent: :restrict_with_exception
  has_many :customers, dependent: :restrict_with_exception
  has_many :conversations, dependent: :restrict_with_exception
  has_many :messages, dependent: :restrict_with_exception

  normalizes :slug, with: ->(slug) { slug.strip.downcase }

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }
end
