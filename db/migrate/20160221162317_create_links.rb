class CreateLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :links do |t|
      t.string :url, null: false
      t.timestamps null: false
    end
  end
end
