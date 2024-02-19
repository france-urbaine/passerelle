# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_applications
#
#  id           :uuid             not null, primary key
#  name         :string           not null
#  uid          :string           not null
#  secret       :string           not null
#  owner_id     :uuid
#  owner_type   :string
#  redirect_uri :text
#  scopes       :string           default(""), not null
#  confidential :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#  sandbox      :boolean          default(FALSE), not null
#
# Indexes
#
#  index_oauth_applications_on_owner_id_and_owner_type  (owner_id,owner_type)
#  index_oauth_applications_on_uid                      (uid) UNIQUE
#
class OauthApplication < ApplicationRecord
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::Application
  include States::Sandbox

  audited
  has_associated_audits

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :owner, polymorphic: true, inverse_of: :oauth_applications

  has_many :transmissions, dependent: false

  # Scopes
  # ----------------------------------------------------------------------------
  # Add default scope to restrict token creation
  default_scope { kept }

  scope :owned_by, ->(organization) { where(owner: organization) }

  scope :search, lambda { |input|
    advanced_search(
      input,
      name: ->(value) { match(:name, value) }
    )
  }

  # Scopes: orders
  # ----------------------------------------------------------------------------
  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      name: ->(direction) { order_by_name(direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  scope :order_by_name, ->(direction = :asc) { unaccent_order(:name, direction) }
end
