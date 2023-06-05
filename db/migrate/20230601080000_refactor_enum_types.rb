# frozen_string_literal: true

class RefactorEnumTypes < ActiveRecord::Migration[7.0]
  def up
    execute "ALTER TYPE user_organization_type RENAME TO organization_type"
    execute "ALTER TYPE collectivity_territory_type RENAME TO territory_type"

    create_enum :action, %w[evaluation_hab evaluation_eco occupation_hab occupation_eco]
    create_enum :priority, %w[low medium high]

    change_column :offices, :action, :enum,
      enum_type: "action",
      null:      false,
      using:     "action::text::action"

    execute "DROP TYPE office_action"
  end

  def down
    create_enum :office_action, %w[evaluation_hab evaluation_eco occupation_hab occupation_eco]

    change_column :offices, :action, :enum,
      enum_type: "office_action",
      null:      false,
      using:     "action::text::office_action"

    execute "DROP TYPE action"
    execute "DROP TYPE priority"
    execute "ALTER TYPE organization_type RENAME TO user_organization_type"
    execute "ALTER TYPE territory_type RENAME TO collectivity_territory_type"
  end
end
