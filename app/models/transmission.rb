# frozen_string_literal: true

# == Schema Information
#
# Table name: transmissions
#
#  id                   :uuid             not null, primary key
#  user_id              :uuid
#  publisher_id         :uuid
#  collectivity_id      :uuid             not null
#  oauth_application_id :uuid
#  completed_at         :datetime
#  sandbox              :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_transmissions_on_collectivity_id       (collectivity_id)
#  index_transmissions_on_oauth_application_id  (oauth_application_id)
#  index_transmissions_on_publisher_id          (publisher_id)
#  index_transmissions_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (collectivity_id => collectivities.id) ON DELETE => cascade
#  fk_rails_...  (oauth_application_id => oauth_applications.id) ON DELETE => nullify
#  fk_rails_...  (publisher_id => publishers.id) ON DELETE => nullify
#  fk_rails_...  (user_id => users.id) ON DELETE => nullify
#
class Transmission < ApplicationRecord
  include States::Sandbox
  include States::MadeBy

  audited associated_with: :oauth_application

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :user, optional: true
  belongs_to :publisher, optional: true
  belongs_to :collectivity
  belongs_to :oauth_application, optional: true

  has_many :reports, dependent: false
  has_many :packages, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :user_id,      presence: { unless: :publisher_id? }, absence: { if: :publisher_id? }
  validates :publisher_id, presence: { unless: :user_id? },      absence: { if: :user_id? }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :active,    -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }

  # Predicates
  # ----------------------------------------------------------------------------
  def active?
    completed_at.nil?
  end

  def completed?
    completed_at?
  end
end
