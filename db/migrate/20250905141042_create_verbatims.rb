class CreateVerbatims < ActiveRecord::Migration[8.0]
  def change
    create_table :verbatims do |t|
      t.text :text
      t.references :verbatim_collection, null: false, foreign_key: true

      t.timestamps
    end
  end
end
