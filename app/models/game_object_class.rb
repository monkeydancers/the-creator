class GameObjectClass < ActiveRecord::Base

	belongs_to :parent, :class_name => "GameObjectClass"
	has_many :properties

	def game_objects
		return GameObjectProxy.new(self)
	end

end
