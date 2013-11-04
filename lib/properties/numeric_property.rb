class NumericProperty < PropertyProxy
	def self.fetch(object_id)
		unless object_id
			super
		else
			data = $redis.hgetall(object_id)
			new({:id => object_id, :value => data['value'].to_i, :default_value => data['default_value'].to_i})
		end
	end

	def value
		@value.to_i
	end

	def default_value
		@default_value.to_i
	end

	def stem
		'num'
	end

	def save
		super
		$redis.hmset id, :value, @value.to_s, :default_value, @default_value.to_s
	end

	def self.definition_class
		Integer
	end

	def self.can_set_property_klazz?
		true
	end

	private

	def refetch
		data 						= $redis.hgetall(self.id)
		@value 					= data['value']
		@default_value 	= data['default_value']
	end

end