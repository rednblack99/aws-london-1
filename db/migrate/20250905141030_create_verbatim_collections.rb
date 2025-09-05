class CreateVerbatimCollections < ActiveRecord::Migration[8.0]
  def change
    create_table :verbatim_collections do |t|
      t.text :project_title
      t.text :question_text

      t.timestamps
    end
  end
end
