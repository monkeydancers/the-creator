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

	def resolve_identifier(identifier)
		if self.game_objects.count(["identifier = ?", identifier]) > 0
			return self.game_objects.where(["identifier = ?", identifier])
		elsif self.game_object_classes.count(["identifier = ?", identifier]) > 0
			return self.game_object_classes.where(["identifier = ?", identifier])
		else
			return nil
		end
	end

end