class StringProperty < PropertyProxy

	def self.fetch(object_id)
		unless object_id
			super
		else
			@value = $redis.get(object_id)
			new({:id => object_id, :value => data['value'], :default_value => data['default_value']})
		end
	end

	def stem
		'str'
	end

	def save
		super
		$redis.hmset id, :value, @value.to_s, :default_value, @default_value.to_s
	end

	def self.definition_class
		String
	end

	def self.can_set_property_klazz?
		true
	end

end