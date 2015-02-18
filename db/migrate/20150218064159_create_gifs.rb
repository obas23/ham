class CreateGifs < ActiveRecord::Migration
  def up
    create_table :gifs, id: false do |t|
      t.string :id, null: false
      t.timestamps null: false
    end

    execute %Q{ ALTER TABLE "gifs" ADD PRIMARY KEY ("id"); }
  end

  def down
    drop_table :gifs
  end
end

