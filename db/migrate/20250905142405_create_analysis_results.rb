class CreateAnalysisResults < ActiveRecord::Migration[8.0]
  def change
    create_table :analysis_results do |t|
      t.references :verbatim_collection, null: false, foreign_key: true
      t.integer :response_id
      t.text :text
      t.string :parent_theme
      t.text :thematic_codes
      t.string :sentiment
      t.boolean :is_garbage

      t.timestamps
    end
  end
end
