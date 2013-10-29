class GameObject < ActiveRecord::Base

	belongs_to :object_class, :class_name => "GameObjectClass"

	has_many :properties, :as => :owner, :autosave => true

	before_create :instantiate_property_values

	private

	def instantiate_property_values
		object_class.property_list(:inherited => true).each do |property|
			p = property.clone
			self.properties << p 
			puts p.inspect
		end
		puts self.properties.inspect
	end

end
