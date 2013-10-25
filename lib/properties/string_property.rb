class StringProperty < PropertyProxy

	# Add default value here later on...
	def initialize(attributes)
		@value 	= attributes[:value]
		@id 		= attributes[:id] 
	end

	def self.fetch(object_id)
		unless object_id
			super
		else
			@value = $redis.get(object_id)
			new({:id => object_id, :value => @value})
		end
	end

	def value=(value)
		@value = value		
	end

	def value
		@value
	end

	def stem
		'str'
	end

	def save
		super
		$redis.set id, @value.to_s
	end

end