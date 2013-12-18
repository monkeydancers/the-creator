class SingleObjectProperty < PropertyProxy

	def self.fetch(object_id)
		unless object_id
			super
		else
			data = $redis.hgetall(object_id)
			new({:id => object_id, :value => data['value'], :default_value => data['default_value']})
		end
	end

	def value
		return nil if @value.blank? 
		@value_object ||= GameObject.find(@value)
	end

	def default_value
		return nil if @default_value.blank?
		@default_value_object ||= GameObject.find(@default_value)
	end

	def stem
		'sio'
	end

	def type
		'objects'
	end

	def save
		super
		$redis.hmset id, :value, (@value ? @value.id.to_s : ""), :default_value, (@default_value ? @default_value.id.to_s : "")
	end

	def self.can_set_property_klazz?
		true
	end

	def self.definition_class
		GameObject
	end

	private

	def refetch
		data 						= $redis.hgetall(self.id)
		@value 					= data['value']
		@default_value 	= data['default_value']
		@value_object, @default_value_object = nil, nil
	end

end