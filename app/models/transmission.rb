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
#  fk_rails_...  (collectivity_id => collectivities.id)
#  fk_rails_...  (oauth_application_id => oauth_applications.id)
#  fk_rails_...  (publisher_id => publishers.id)
#  fk_rails_...  (user_id => users.id)
#
class Transmission < ApplicationRecord
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
  scope :sandbox,        -> { where(sandbox: true) }
  scope :out_of_sandbox, -> { where(sandbox: false) }

  scope :made_through_publisher_api, -> { where.not(publisher_id: nil) }
  scope :made_through_web_ui,        -> { where(publisher_id: nil) }

  scope :made_by_collectivity, ->(collectivity) { where(collectivity: collectivity) }
  scope :made_by_publisher,    ->(publisher)    { where(publisher: publisher) }

  # Predicates
  # ----------------------------------------------------------------------------
  def out_of_sandbox?
    !sandbox?
  end

  def made_through_publisher_api?
    publisher_id? || (new_record? && publisher)
  end

  def made_through_web_ui?
    !made_through_publisher_api?
  end

  def made_by_collectivity?(collectivity)
    (collectivity_id == collectivity.id) || (new_record? && collectivity == self.collectivity)
  end

  def made_by_publisher?(publisher)
    (publisher_id == publisher.id) || (new_record? && publisher == self.publisher)
  end
end
