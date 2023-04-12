# frozen_string_literal: true

# == Schema Information
#
# Table name: offices
#
#  id             :uuid             not null, primary key
#  ddfip_id       :uuid             not null
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
#  index_offices_on_ddfip_id      (ddfip_id)
#  index_offices_on_discarded_at  (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (ddfip_id => ddfips.id) ON DELETE => cascade
#
class Office < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :ddfip

  has_many :office_users,    dependent: :delete_all
  has_many :office_communes, dependent: :delete_all

  has_many :users,    through: :office_users
  has_many :communes, through: :office_communes

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
    connection.select_value("SELECT reset_all_offices_counters()")
  end
end
