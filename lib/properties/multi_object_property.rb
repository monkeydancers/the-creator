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

	def value=(value)
		@value = Array(@value) + Array(value)
	end

	def value
		return nil if @value.blank?
		@value_object ||= GameObject.where(["identifier in (?)", @value])
	end

	def default_value
		return nil if @default_value.blank?
		@default_value_object ||= GameObject.where(["identifier in (?)", @default_value])
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

	# Refactor the id-changing bits here
	def save
		super	
		$redis.del id+'-value' if @value
		$redis.rpush id+'-value', Array(@value).map{|g| g.is_a?(GameObject) ? g.identifier : g } if Array(@value).length > 0
		$redis.del id+'-default-value' if @default_value
		$redis.rpush id+'-default-value', Array(@default_value).map{|g| g.is_a?(GameObject) ? g.identifier : g } if Array(@default_value).length > 0
	end

	def self.can_set_property_klazz?
		true
	end

	def self.definition_class
		GameObject
	end

	def handle_removal(scope)
		if scope.is_a?(Array)
			scope.map!{|o| o.is_a?(GameObject) ? o.identifier : o }			
			refetch
			@value = @value.reject{|object| scope.include?(object) }
			puts @value.inspect
		elsif scope == 'all'
			@value = []
		end
		return true
	end

	private 

	def refetch
		data 						= $redis.hgetall(self.id)
		@value 					= $redis.lrange(self.id + '-value', 0, -1)
		@default_value 	= $redis.lrange(self.id + '-default-value', 0, -1)
		@value_object, @default_value_object = nil, nil
	end

end