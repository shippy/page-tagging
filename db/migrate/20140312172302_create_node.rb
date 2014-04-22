class CreateNode < ActiveRecord::Migration
  def change 
	  create_table :nodes do |t|
		  t.text :url, null: false
		  t.string :tag
		  t.string :tagger
		  t.integer :rank
	  end
  end
end
