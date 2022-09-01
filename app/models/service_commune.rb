# frozen_string_literal: true

# == Schema Information
#
# Table name: service_communes
#
#  id         :uuid             not null, primary key
#  service_id :uuid             not null
#  code_insee :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_service_communes_on_code_insee                 (code_insee)
#  index_service_communes_on_service_id                 (service_id)
#  index_service_communes_on_service_id_and_code_insee  (service_id,code_insee) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (service_id => services.id) ON DELETE => cascade
#
class ServiceCommune < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :service, counter_cache: :users_count
  belongs_to :commune, primary_key: :code_insee, foreign_key: :code_insee, inverse_of: :service_communes, optional: true
end
