# frozen_string_literal: true

class InstallAudited < ActiveRecord::Migration[7.0]
  def self.up
    create_table :audits, id: :uuid, default: "gen_random_uuid()" do |t|
      t.uuid     :auditable_id
      t.string   :auditable_type
      t.uuid     :associated_id
      t.string   :associated_type
      t.uuid     :user_id
      t.string   :user_type
      t.string   :username
      t.uuid     :publisher_id
      t.uuid     :organization_id
      t.string   :organization_type
      t.uuid     :oauth_application_id
      t.string   :action
      t.jsonb    :audited_changes
      t.integer  :version, default: 0
      t.string   :comment
      t.string   :remote_address
      t.string   :request_uuid
      t.timestamps
      t.index    %i[auditable_type auditable_id version]
      t.index    %i[associated_type associated_id]
      t.index    %i[user_id user_type]
      t.index    :request_uuid
      t.index    :created_at
    end
  end

  def self.down
    drop_table :audits
  end
end
