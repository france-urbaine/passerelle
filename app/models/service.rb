# frozen_string_literal: true

# == Schema Information
#
# Table name: services
#
#  id             :uuid             not null, primary key
#  ddfip_id       :uuid
#  name           :string           not null
#  action         :enum             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  discarded_at   :datetime
#  users_count    :integer          default(0), not null
#  communes_count :integer          default(0), not null
#
# Indexes
#
#  index_services_on_ddfip_id      (ddfip_id)
#  index_services_on_discarded_at  (discarded_at)
#
class Service < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :ddfip

  has_many :user_services,    dependent: :delete_all
  has_many :service_communes, dependent: :delete_all

  has_many :users,    through: :user_services
  has_many :communes, through: :service_communes

  # Validations
  # ----------------------------------------------------------------------------
  ACTIONS = %w[evaluation_hab evaluation_eco occupation_hab occupation_eco].freeze

  validates :name,   presence: true
  validates :action, presence: true, inclusion: { in: ACTIONS }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(
      input,
      name:             ->(value) { match(:name, value) },
      ddfip_name:       ->(value) { left_joins(:ddfip).merge(DDFIP.match(:name, value)) },
      code_departement: ->(value) { left_joins(:ddfip).merge(DDFIP.where(code_departement: value)) }
    )
  }

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      name:   ->(direction) { unaccent_order(:name, direction) },
      ddfip:  ->(direction) { left_joins(:ddfip).merge(DDFIP.order(name: direction)) },
      action: ->(direction) { order(action: direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  # Counters cached
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_services_counters()")
  end

  # Communes assignement
  # ----------------------------------------------------------------------------
  def commune_ids
    @commune_ids ||= communes.pluck(:id)
  end

  def epci_ids
    @epci_ids ||= EPCI.having_communes(communes).pluck(:id)
  end

  def codes_insee
    @codes_insee ||= service_communes.pluck(:code_insee)
  end

  def epci_sirens
    @epci_sirens ||= EPCI.having_communes(communes).pluck(:id)
  end

  def codes_insee=(values)
    values = values.filter_map(&:presence).uniq

    if new_record?
      values.each do |value|
        service_communes.build(code_insee: value)
      end
    else
      actual_codes_insee = self.codes_insee

      values_to_delete = actual_codes_insee - values
      service_communes.where(code_insee: values_to_delete).delete_all if values_to_delete.any?

      values_to_insert = values - actual_codes_insee
      ServiceCommune.insert_all(values_to_insert.map { |value| { service_id: id, code_insee: value } }) if values_to_insert.any?
    end

    @codes_insee ||= values
  end
end
