class CreateStatistics < ActiveRecord::Migration[6.0]
  def change
    create_table :statistics do |t|
      t.string :series
      t.integer :period
      t.decimal :value

      t.timestamps
    end
  end
end
