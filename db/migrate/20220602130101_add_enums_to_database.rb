# frozen_string_literal: true

class AddEnumsToDatabase < ActiveRecord::Migration[7.0]
  def change
    create_enum :territory_type,    %w[Commune EPCI Departement Region]
    create_enum :organization_type, %w[Collectivity Publisher DDFIP]
    create_enum :epci_nature,       %w[ME CC CA CU]

    reversible do |dir|
      dir.up do
        change_column :collectivities, :territory_type, :enum,
          enum_type: "territory_type",
          using:     "territory_type::territory_type",
          null:      false

        change_column :users, :organization_type, :enum,
          enum_type: "organization_type",
          using:     "organization_type::organization_type",
          null:      false

        change_column :epcis, :nature, :enum,
          enum_type: "epci_nature",
          using:     "nature::epci_nature"
      end

      dir.down do
        change_column :collectivities, :territory_type,    :string, null: false
        change_column :users,          :organization_type, :string, null: false
        change_column :epcis,          :nature,            :string
      end
    end
  end
end
