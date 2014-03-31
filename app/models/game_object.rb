class GameObject < ActiveRecord::Base
	include Identifier

	belongs_to :object_class, :class_name => "GameObjectClass"
	belongs_to :game
	has_many :properties, :as => :owner, :autosave => true

	validates :game_id, :presence => true

	before_create :instantiate_property_values

	EDITABLE_ATTRIBUTES = ["name", "description"]

	def as_list
		return {
			:list 						=> false,
			:class_path 			=> "fetto", 
			:name 						=> self.name, 
			:identifier 			=> self.identifier, 
			:properties 			=> self.properties.map{|p| {:name => p.name, :current_value => p.value, :default_value => p.default_value, :type => p.type, :identifier => p.identifier } }, 
			:description 			=> "Lorem ipsum dolor sit amet..."
		}
	end

	def update(key, value)
		if EDITABLE_ATTRIBUTES.include?(key)
			return self.update_attribute(key.to_sym, value)
		else
			return false
		end
	end

	private

	def instantiate_property_values
		object_class.property_list(:inherited => true).each do |property|
			p = property.clone
			self.properties << p 
		end
	end

end