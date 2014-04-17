class AddApiKeyToGames < ActiveRecord::Migration
  def change
  	add_column :games, :api_key, :string
  end
end
