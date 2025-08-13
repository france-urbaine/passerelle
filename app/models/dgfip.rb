# frozen_string_literal: true

# == Schema Information
#
# Table name: dgfips
#
#  id                        :uuid             not null, primary key
#  name                      :string           not null
#  contact_first_name        :string
#  contact_last_name         :string
#  contact_email             :string
#  contact_phone             :string
#  domain_restriction        :string
#  allow_2fa_via_email       :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  discarded_at              :datetime
#  users_count               :integer          default(0), not null
#  reports_transmitted_count :integer          default(0), not null
#  reports_accepted_count    :integer          default(0), not null
#  reports_rejected_count    :integer          default(0), not null
#  reports_approved_count    :integer          default(0), not null
#  reports_canceled_count    :integer          default(0), not null
#  ip_ranges                 :text             default([]), not null, is an Array
#
# Indexes
#
#  index_dgfips_on_discarded_at  (discarded_at)
#  index_dgfips_on_name          (name) UNIQUE WHERE (discarded_at IS NULL)
#  singleton_dgfip_constraint    ((1)) UNIQUE
#
class DGFIP < ApplicationRecord
  audited

  # Associations
  # ----------------------------------------------------------------------------
  has_many :users, as: :organization, dependent: :delete_all

  # Validations
  # ----------------------------------------------------------------------------
  validates :name, presence: true

  validates :contact_email,      format: { allow_blank: true, with: EMAIL_REGEXP }
  validates :contact_phone,      format: { allow_blank: true, with: PHONE_REGEXP }
  validates :domain_restriction, format: { allow_blank: true, with: DOMAIN_REGEXP }

  validate :validate_one_singleton_record, on: :create

  normalizes :ip_ranges, with: ->(ip_ranges) { ip_ranges.reject(&:empty?).uniq }
  validate :ip_ranges_format

  def validate_one_singleton_record
    errors.add :base, :exist if DGFIP.with_discarded.exists?
  end

  def ip_ranges_format
    ip_ranges&.each do |ip_range|
      IPAddr.new(ip_range)
    rescue IPAddr::InvalidAddressError
      errors.add(:ip_ranges, :invalid_ip, ip: ip_range)
      return false
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(input, scopes: {
      name: ->(value) { match(:name, value) }
    })
  }

  scope :autocomplete, ->(input) { search(input) }

  # Updates methods
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_dgfips_counters()")
  end

  # Singleton record
  # ----------------------------------------------------------------------------
  # Overwrite to_param so DGFIP is a singular resource when calling url_for
  #
  def to_param
    nil
  end

  def self.find_or_create_singleton_record
    record = with_discarded.first
    record.undiscard if record&.discarded?
    record || create(name: I18n.t("activerecord.default_values.dgfip.name"))
  end
end
