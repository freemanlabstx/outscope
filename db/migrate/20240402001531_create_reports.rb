class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.string :title, null: false
      t.string :location, null: false
      t.string :term, null: false
      t.integer :status, default: 0, null: false

      t.belongs_to :account, null: false, foreign_key: true
      t.jsonb :data

      t.timestamps
    end
  end
end
