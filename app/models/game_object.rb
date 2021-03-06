class GameObject < ActiveRecord::Base
	include Identifier

	belongs_to :object_class, :class_name => "GameObjectClass"
	belongs_to :game
	has_many :properties, :as => :owner, :autosave => true

	validates :game_id, :presence => true

	before_create :instantiate_property_values
	before_create :setup_default_description

	EDITABLE_ATTRIBUTES = ["name", "description"]

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
			p.value = property.value
			self.properties << p 
		end
	end

	def setup_default_description
		self.description = I18n.t('activerecord.models.game_object.defaults.description') if self.description.blank? 
	end

end