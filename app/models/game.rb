class Game < ActiveRecord::Base

	has_many :game_objects
	has_many :game_object_classes
	has_many :root_classes, ->{ where(["parent_id is null"]) }, :class_name => "GameObjectClass"

	def class_structure
		data = []
		root_classes.each do |goc|
			data.push(goc.as_tree)
		end
		return data
	end


end