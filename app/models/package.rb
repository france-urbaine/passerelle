# frozen_string_literal: true

# == Schema Information
#
# Table name: packages
#
#  id              :uuid             not null, primary key
#  collectivity_id :uuid             not null
#  publisher_id    :uuid
#  name            :string           not null
#  reference       :string           not null
#  action          :enum             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  transmitted_at  :datetime
#  approved_at     :datetime
#  rejected_at     :datetime
#  discarded_at    :datetime
#  due_on          :date
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
  ACTIONS = %w[evaluation_hab evaluation_eco].freeze

  validates :name, presence: true
  validates :action, presence: true, inclusion: { in: ACTIONS, allow_blank: true }

  # Callbacks
  # ----------------------------------------------------------------------------
  before_create :generate_reference

  def generate_reference
    return if reference?

    last_reference = Package.maximum(:reference)

    month = (created_at || Time.zone.today).strftime("%Y-%m")
    index = last_reference&.slice(/^#{month}-(\d{5})$/, 1).to_i + 1
    index = index.to_s.rjust(5, "0")

    self.reference ||= "#{month}-#{index}"
  end

  # Scopes
  # ----------------------------------------------------------------------------
  # In some scopes we use `model_name.name` to identify the model of either
  # an instance or a relation:
  # Example:
  #    sent_by(Publisher.last)
  #    sent_by(Publisher.all)

  scope :packing,      -> { where(transmitted_at: nil) }
  scope :transmitted,  -> { where.not(transmitted_at: nil) }
  scope :to_approve,   -> { transmitted.kept.where(approved_at: nil, rejected_at: nil) }
  scope :approved,     -> { transmitted.where.not(approved_at: nil).where(rejected_at: nil) }
  scope :rejected,     -> { transmitted.where.not(rejected_at: nil) }
  scope :unrejected,   -> { transmitted.where(rejected_at: nil) }

  scope :packed_through_publisher_api,   -> { where.not(publisher_id: nil) }
  scope :packed_through_collectivity_ui, -> { where(publisher_id: nil) }

  scope :sent_by_publisher,    ->(publisher)    { where(publisher: publisher) }
  scope :sent_by_collectivity, ->(collectivity) { where(collectivity: collectivity) }
  scope :sent_by, lambda { |entity|
    case entity.model_name.name
    when "Publisher"    then sent_by_publisher(entity)
    when "Collectivity" then sent_by_collectivity(entity)
    else raise TypeError, "unexpected argument: #{entity}"
    end
  }

  scope :with_reports, ->(reports = Report.all) { distinct.joins(:reports).merge(reports.kept) }

  scope :available_to_collectivity, lambda { |collectivity|
    kept.sent_by_collectivity(collectivity).merge(
      Package.unscoped.transmitted.or(
        Package.unscoped.packed_through_collectivity_ui
      )
    )
  }

  scope :available_to_publisher, ->(publisher) { kept.sent_by_publisher(publisher) }
  scope :available_to_ddfip,     ->(ddfip)     { kept.unrejected.with_reports(Report.covered_by_ddfip(ddfip)) }
  scope :available_to_office,    ->(office)    { kept.approved.with_reports(Report.covered_by_office(office)) }

  scope :available_to, lambda { |entity|
    case entity.model_name.name
    when "Publisher"    then available_to_publisher(entity)
    when "Collectivity" then available_to_collectivity(entity)
    when "DDFIP"        then available_to_ddfip(entity)
    when "Office"       then available_to_office(entity)
    else raise TypeError, "unexpected argument: #{entity}"
    end
  }

  # Predicates
  # ----------------------------------------------------------------------------
  def packing?
    !transmitted?
  end

  def transmitted?
    transmitted_at?
  end

  def packed_through_publisher_api?
    publisher_id? || (new_record? && publisher)
  end

  def to_approve?
    transmitted? && kept? && !approved_at? && !rejected_at?
  end

  def approved?
    transmitted? && approved_at? && !rejected_at?
  end

  def rejected?
    transmitted? && rejected_at?
  end
end
