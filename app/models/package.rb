# frozen_string_literal: true

# == Schema Information
#
# Table name: packages
#
#  id                      :uuid             not null, primary key
#  collectivity_id         :uuid             not null
#  publisher_id            :uuid
#  name                    :string           not null
#  reference               :string           not null
#  action                  :enum             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  transmitted_at          :datetime
#  approved_at             :datetime
#  rejected_at             :datetime
#  discarded_at            :datetime
#  due_on                  :date
#  completed               :boolean          default(FALSE), not null
#  reports_count           :integer          default(0), not null
#  reports_completed_count :integer          default(0), not null
#  reports_approved_count  :integer          default(0), not null
#  reports_rejected_count  :integer          default(0), not null
#  reports_debated_count   :integer          default(0), not null
#  sandbox                 :boolean          default(FALSE), not null
#
# Indexes
#
#  index_packages_on_collectivity_id  (collectivity_id)
#  index_packages_on_discarded_at     (discarded_at)
#  index_packages_on_publisher_id     (publisher_id)
#  index_packages_on_reference        (reference) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (collectivity_id => collectivities.id) ON DELETE => cascade
#  fk_rails_...  (publisher_id => publishers.id) ON DELETE => cascade
#
class Package < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :collectivity
  belongs_to :publisher, optional: true
  has_many :reports, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  ACTIONS = %w[evaluation_hab evaluation_pro].freeze

  validates :name,      presence: true
  validates :reference, presence: true, uniqueness: { unless: :skip_uniqueness_validation_of_reference? }
  validates :action,    presence: true, inclusion: { in: ACTIONS, allow_blank: true }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :sandbox,        -> { where(sandbox: true) }
  scope :out_of_sandbox, -> { where(sandbox: false) }

  scope :packing,      -> { where(transmitted_at: nil) }
  scope :transmitted,  -> { where.not(transmitted_at: nil) }
  scope :to_approve,   -> { transmitted.kept.where(approved_at: nil, rejected_at: nil) }
  scope :approved,     -> { transmitted.where.not(approved_at: nil).where(rejected_at: nil) }
  scope :rejected,     -> { transmitted.where.not(rejected_at: nil) }
  scope :unrejected,   -> { transmitted.where(rejected_at: nil) }

  scope :packed_through_publisher_api, -> { where.not(publisher_id: nil) }
  scope :packed_through_web_ui,        -> { where(publisher_id: nil) }

  scope :sent_by_collectivity, ->(collectivity) { where(collectivity: collectivity) }
  scope :sent_by_publisher,    ->(publisher)    { where(publisher: publisher) }

  scope :with_reports, ->(reports = Report.kept) { distinct.joins(:reports).merge(reports) }

  # Predicates
  # ----------------------------------------------------------------------------
  def out_of_sandbox?
    !sandbox?
  end

  def packing?
    !transmitted_at?
  end

  def transmitted?
    transmitted_at?
  end

  def to_approve?
    transmitted? && kept? && approved_at.nil? && rejected_at.nil?
  end

  def approved?
    transmitted? && approved_at? && rejected_at.nil?
  end

  def rejected?
    transmitted? && rejected_at?
  end

  def unrejected?
    transmitted? && rejected_at.nil?
  end

  def packed_through_publisher_api?
    publisher_id? || (new_record? && publisher)
  end

  def packed_through_web_ui?
    !packed_through_publisher_api?
  end

  def sent_by_collectivity?(collectivity)
    (collectivity_id == collectivity.id) || (new_record? && collectivity == self.collectivity)
  end

  def sent_by_publisher?(publisher)
    (publisher_id == publisher.id) || (new_record? && publisher == self.publisher)
  end

  # Updates
  # ----------------------------------------------------------------------------
  def transmit!
    return true if transmitted?

    touch(:transmitted_at)
  end

  def approve!
    return true if approved?

    update_columns(
      rejected_at: nil,
      approved_at: Time.current
    )
  end

  def reject!
    return true if rejected?

    update_columns(
      rejected_at: Time.current,
      approved_at: nil
    )
  end

  # Database updates
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_packages_counters()")
  end
end
