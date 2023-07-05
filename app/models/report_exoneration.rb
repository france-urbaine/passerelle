# frozen_string_literal: true

# == Schema Information
#
# Table name: report_exonerations
#
#  id                :uuid             not null, primary key
#  report_id         :uuid             not null
#  code              :string           not null
#  label             :string           not null
#  status            :enum             not null
#  base              :enum             not null
#  code_collectivite :enum             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_report_exonerations_on_report_id  (report_id)
#
# Foreign Keys
#
#  fk_rails_...  (report_id => reports.id) ON DELETE => cascade
#
class ReportExoneration < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :report

  # Validations
  # ----------------------------------------------------------------------------
  STATUSES           = %w[conserver supprimer ajouter].freeze
  BASES              = %w[imposable impose].freeze
  CODES_COLLECTIVITE = %w[C GC TS OM].freeze

  validates :code,   presence: true
  validates :label,  presence: true
  validates :status, presence: true, inclusion: { in: STATUSES, allow_blank: true }
  validates :base,   presence: true, inclusion: { in: BASES, allow_blank: true }
  validates :code_collectivite, presence: true, inclusion: { in: CODES_COLLECTIVITE, allow_blank: true }
end
