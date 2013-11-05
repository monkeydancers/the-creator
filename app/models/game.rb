class Game < ActiveRecord::Base

	has_many :game_objects
	has_many :game_object_classes	

end