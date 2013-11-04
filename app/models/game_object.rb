class GameObject < ActiveRecord::Base

	belongs_to :object_class, :class_name => "GameObjectClass"

	has_many :properties, :as => :owner, :autosave => true

	before_create :instantiate_property_values

	def to_lua
		{
			'name' 				=> name, 
			'id' 					=> id, 
			'properties'	=> [
				{
					'id' 		=> 1,
					'name' 	=> 'monkey_master'
				}, 
				{
					'id' 		=> 2, 
					'name'	=> 'monkey_minion'
				}
			]
		}
	end

	private

	def instantiate_property_values
		object_class.property_list(:inherited => true).each do |property|
			p = property.clone
			self.properties << p 
		end
	end

end