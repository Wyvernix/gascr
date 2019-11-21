class CreateData < ActiveRecord::Migration[6.0]
  def change
    create_table :data do |t|
      t.string :content
      t.integer :tag, default: 0

      t.timestamps
    end
  end
end
