# frozen_string_literal: true

# == Schema Information
#
# Table name: office_communes
#
#  id         :uuid             not null, primary key
#  office_id  :uuid             not null
#  code_insee :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_office_communes_on_code_insee                (code_insee)
#  index_office_communes_on_office_id                 (office_id)
#  index_office_communes_on_office_id_and_code_insee  (office_id,code_insee) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id) ON DELETE => cascade
#
class OfficeCommune < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :office
  belongs_to :commune, primary_key: :code_insee, foreign_key: :code_insee, inverse_of: :office_communes, optional: true
end
