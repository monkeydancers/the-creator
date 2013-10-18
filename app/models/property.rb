class Property < ActiveRecord::Base

	belongs_to :game_object_class

	before_save :assign_value_id
	after_save :persist_default_value
	after_destroy :remove_value

	validates :name, :presence => true

	def default_value
		default_value_object.nil? ? nil : default_value_object[:value]
	end

	def default_value_object
		@value ||= PropertyValue.find(default_value_id.to_s)
	end

	def default_value=(v)
		if self.default_value_id.blank?
			setup_default_value_storage
		end
		default_value_object[:value] = v
	end

	private 

	def assign_value_id
		self.default_value_id = @value.id.to_s if @value
	end

	def setup_default_value_storage
		@value = PropertyValue.new
	end

	def persist_default_value		
		default_value_object.save if default_value_object
	end

	def remove_value
		default_value_object.destroy if default_value_object
	end
end
