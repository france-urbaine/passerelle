# frozen_string_literal: true

json.collectivites @collectivities do |collectivity|
  json.extract! collectivity, :id, :name, :siren, :territory_type
end
