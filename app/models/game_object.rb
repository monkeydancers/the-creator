require 'digest/sha1'
class GameObject < ActiveRecord::Base

	belongs_to :object_class, :class_name => "GameObjectClass"

	has_many :properties, :as => :owner, :autosave => true

	before_create :instantiate_property_values
	before_create :generate_identifier

	def to_lua
		{
			'name' 				=> name, 
			'id' 					=> id, 
			'properties'	=> [
				{
					'id' 		=> 1,
					'name' 	=> 'monkey_minion'
				}, 
				{
					'id' 		=> 2, 
					'name'	=> 'monkey_master'
				}
			]
		}
	end

	def as_list
		return {
			:list 						=> false,
			:class_path 			=> "fetto", 
			:name 						=> self.name, 
			:identifier 			=> self.identifier, 
			:properties 			=> self.properties.map{|p| {:name => p.name, :current_value => p.value, :default_value => p.default_value, :type => p.type } }, 
			:description 			=> "Lorem ipsum dolor sit amet..."
		}
	end

	private

	def instantiate_property_values
		object_class.property_list(:inherited => true).each do |property|
			p = property.clone
			self.properties << p 
		end
	end

	def generate_identifier
		self.identifier = Digest::SHA1.hexdigest(Time.now.to_i.to_s + rand.to_s)[0..6]
		while(GameObject.exists?(["identifier = ?", self.identifier])) 
			self.identifier = Digest::SHA1.hexdigest(Time.now.to_i.to_s + rand.to_s)[0..6]
		end
	end

end