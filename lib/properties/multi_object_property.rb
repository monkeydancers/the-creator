class MultiObjectProperty < PropertyProxy

	def self.fetch(object_id)
		unless object_id
			super
		else
			value 						= $redis.lrange(object_id+'-value', 0, -1)
			default_value 		= $redis.lrange(object_id+'-default-value', 0, -1)
			new({:id => object_id, :value => value, :default_value => default_value})
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

	# This can be optimized!
	def value_description(regular)
		if regular
			return "#{value.nil? ? 0 : value.length} objects"
		else
			return "#{default_value.nil? ? 0 : default_value.length} objects"
		end
	end

	def stem
		'mio'
	end

	def type
		'objects'
	end

	def save
		super	
		$redis.del id+'-value' if @value
		$redis.rpush id+'-value', Array(@value).map{|g| g.id } if @value
		$redis.del id+'-default-value' if @default_value
		$redis.rpush id+'-default-value', Array(@default_value).map{|g| g.id} if @default_value
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
		@value 					= $redis.lrange(self.id + '-value', 0, -1)
		@default_value 	= $redis.lrange(self.id + '-default-value', 0, -1)
		@value_object, @default_value_object = nil, nil
	end

end