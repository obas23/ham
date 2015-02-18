class CreateGifsTags < ActiveRecord::Migration
  def change
    create_table :gifs_tags do |t|
      t.string  :gif_id
      t.integer :tag_id
      t.index [:gif_id, :tag_id]
    end
  end
end

