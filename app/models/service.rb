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
  validates :name,   presence: true
  validates :action, presence: true, inclusion: { in: %w[evaluation_hab evaluation_eco occupation_hab occupation_eco] }
end
