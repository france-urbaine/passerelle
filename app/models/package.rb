# frozen_string_literal: true

# == Schema Information
#
# Table name: packages
#
#  id                     :uuid             not null, primary key
#  collectivity_id        :uuid             not null
#  publisher_id           :uuid
#  reference              :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  discarded_at           :datetime
#  sandbox                :boolean          default(FALSE), not null
#  transmission_id        :uuid
#  ddfip_id               :uuid
#  reports_count          :integer          default(0), not null
#  reports_accepted_count :integer          default(0), not null
#  reports_rejected_count :integer          default(0), not null
#  reports_approved_count :integer          default(0), not null
#  reports_canceled_count :integer          default(0), not null
#
# Indexes
#
#  index_packages_on_collectivity_id  (collectivity_id)
#  index_packages_on_ddfip_id         (ddfip_id)
#  index_packages_on_discarded_at     (discarded_at)
#  index_packages_on_publisher_id     (publisher_id)
#  index_packages_on_reference        (reference) UNIQUE
#  index_packages_on_transmission_id  (transmission_id)
#
# Foreign Keys
#
#  fk_rails_...  (collectivity_id => collectivities.id) ON DELETE => cascade
#  fk_rails_...  (ddfip_id => ddfips.id) ON DELETE => nullify
#  fk_rails_...  (publisher_id => publishers.id) ON DELETE => cascade
#  fk_rails_...  (transmission_id => transmissions.id) ON DELETE => nullify
#
class Package < ApplicationRecord
  include States::Sandbox
  include States::MadeBy

  audited

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :collectivity
  belongs_to :publisher, optional: true
  belongs_to :transmission, optional: true
  belongs_to :ddfip, optional: true

  has_many :reports, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :reference, presence: true, uniqueness: { unless: :skip_uniqueness_validation_of_reference? }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :with_reports, ->(reports = Report.kept) { distinct.joins(:reports).merge(reports) }

  scope :with_ddfip, ->(ddfip_id) { where(ddfip_id: ddfip_id) }

  # Updates methods
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_packages_counters()")
  end
end
