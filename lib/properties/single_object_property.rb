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
		@value_object ||= GameObject.where(["identifier = ?", @value]).first
	end

	def default_value
		return nil if @default_value.blank?
		@default_value_object ||= GameObject.where(["identifier = ?", @default_value]).first
	end

	def value_description(regular = true)
		if regular
			return value.nil? ? 'No object' : value.name
		else
			return default_value.nil? ? 'No object' : default_value.name
		end
	end

	def stem
		'sio'
	end

	def type
		'object'
	end

	def save
		super
		$redis.hmset id, :value, (@value ? (@value.is_a?(GameObject) ? @value.identifier.to_s : @value) : ""), :default_value, (@default_value ? (@default_value.is_a?(GameObject) ? @default_value.identifier.to_s : @default_value) : "")
	end

	def self.can_set_property_klazz?
		true
	end

	def self.definition_class
		GameObject
	end

	def handle_removal(scope)
		@value = []
		return {:error => false, :payload => {:description => value_description(true), :error => false, :object_type => "property"}}
	end

	private

	def refetch
		data 						= $redis.hgetall(self.id)
		@value 					= data['value']
		@default_value 	= data['default_value']
		@value_object, @default_value_object = nil, nil
	end

end