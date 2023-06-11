# frozen_string_literal: true

class UpdateEnumValues < ActiveRecord::Migration[7.0]
  def up
    execute "ALTER TYPE action RENAME VALUE 'evaluation_eco' TO 'evaluation_pro'"
    execute "ALTER TYPE action RENAME VALUE 'occupation_eco' TO 'occupation_pro'"
  end
end
