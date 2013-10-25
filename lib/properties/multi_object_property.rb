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
		@value_object ||= GameObject.find(@value)
	end

	def default_value
		@default_value_object ||= GameObject.find(@default_value)
	end

	def stem
		'mio'
	end

	def save
		super	
		$redis.del id+'-value' if @value
		$redis.rpush id+'-value', @value.map{|g| g.id } if @value
		$redis.del id+'-default-va' if @default_value
		$redis.rpush id+'-default-value', @default_value.map{|g| g.id} if @default_value
	end

	def self.can_set_property_klazz?
		false
	end

end