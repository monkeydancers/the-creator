class GameObject
	include Mongoid::Document
	include Mongoid::Attributes::Dynamic

	field :game_object_class_id, type: Integer

	def object_class
		return GameObjectClass.find(self.game_object_class_id)
	end

end