class AddNoteToReport < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :note, :text
  end
end
