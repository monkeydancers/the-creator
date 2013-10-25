class GameObject
	include Mongoid::Document
	include Mongoid::Attributes::Dynamic

	field :game_object_class_id, type: Integer

	before_create :instantiate_property_values

	def object_class
		return GameObjectClass.find(self.game_object_class_id)
	end

	private

	def instantiate_property_values
		object_class.properties.each do |property|

		end
	end

end