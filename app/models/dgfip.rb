# frozen_string_literal: true

# == Schema Information
#
# Table name: dgfips
#
#  id                  :uuid             not null, primary key
#  name                :string           not null
#  contact_first_name  :string
#  contact_last_name   :string
#  contact_email       :string
#  contact_phone       :string
#  domain_restriction  :string
#  allow_2fa_via_email :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  discarded_at        :datetime
#  users_count         :integer          default(0), not null
#
# Indexes
#
#  index_dgfips_on_discarded_at  (discarded_at)
#  index_dgfips_on_name          (name) UNIQUE WHERE (discarded_at IS NULL)
#
class DGFIP < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  has_many :users, as: :organization, dependent: :delete_all

  # Validations
  # ----------------------------------------------------------------------------
  validates :name, presence: true

  validates :contact_email,      format: { allow_blank: true, with: EMAIL_REGEXP }
  validates :contact_phone,      format: { allow_blank: true, with: PHONE_REGEXP }
  validates :domain_restriction, format: { allow_blank: true, with: DOMAIN_REGEXP }

  validates :name, uniqueness: {
    case_sensitive: false,
    conditions: -> { kept },
    unless: :skip_uniqueness_validation_of_name?
  }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(
      input,
      name: ->(value) { match(:name, value) }
    )
  }

  scope :autocomplete, ->(input) { search(input) }

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      name: ->(direction) { unaccent_order(:name, direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }
end
