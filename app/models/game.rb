class Game < ActiveRecord::Base

	has_many :game_objects
	has_many :game_object_classes
	has_many :properties
	has_many :root_classes, ->{ where(["parent_id is null"]) }, :class_name => "GameObjectClass"

	def class_structure
		data = []
		root_classes.each do |goc|
			data.push(goc.as_tree)
		end
		return data
	end

	def resolve_identifier(identifier)
		if self.game_objects.where(["identifier = ?", identifier]).count > 0
			return self.game_objects.where(["identifier = ?", identifier]).first
		elsif self.game_object_classes.where(["identifier = ?", identifier]).count > 0
			return self.game_object_classes.where(["identifier = ?", identifier]).first
		else
			return nil
		end
	end

end