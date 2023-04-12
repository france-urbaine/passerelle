# frozen_string_literal: true

class EnableExtensions < ActiveRecord::Migration[7.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    enable_extension "unaccent" unless extension_enabled?("unaccent")
  end
end
