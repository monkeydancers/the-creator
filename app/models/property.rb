class Property < ActiveRecord::Base

	belongs_to :game_object_class

	validates :name, :presence => true

	around_save :flush_redis_writes
	before_save :set_property_klazz, :on => :create
	around_destroy :flush_redis_destroy

	def default_value=(value)
		@value = value
	end

	def default_value
		# This bizarre construct is done in order to not be reliant
		# on the inherent assignment-order when using Property.new({...})
		# since that hash can be ordered anywhich way .daniel
		if value_id
			value_object.value
		else			
			@value
		end
	end

	private

	def value_object
		@value_object ||= load_value_object
	end

	def available_subclasses
		{
			"StringProperty" => StringProperty
		}
	end

	def load_value_object
		value_instance = value_klazz.fetch(self.value_id)
		self.value_id = value_instance.id
		value_instance
	end

	def value_klazz
		available_subclasses[property_type_definition]
	end

	def flush_redis_writes
		value_object.value = @value
		value_object.save
		yield
		value_object.commit
	end

	def set_property_klazz
		self.property_klazz = value_klazz.definition_class if self.property_klazz.blank? 
	end

	def flush_redis_destroy
		value_object.destroy
		yield
		value_object.commit
	end

end