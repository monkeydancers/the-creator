require 'securerandom'
class PropertyProxy

	attr_reader :id

	def self.fetch(object_id)
		instance = self.new({:value => nil})
		instance.set_identifier
		instance
	end

	def initialize(attributes)
		@value 						= attributes[:value]
		@default_value		= attributes[:default_value]
		@id 							= attributes[:id] 
	end

	def value=(value)
		@value = value		
	end

	def value
		@value
	end

	def default_value=(value)
		@default_value = value
	end

	def default_value
		@default_value
	end

	def set_identifier
		@id = generate_identifier
	end

	def save
		$redis.multi
	end

	def destroy
		$redis.multi
		$redis.del(id)
	end

	def commit
		$redis.exec
	end

	def discard
		$redis.discard
	end

	private

	def generate_identifier(st=nil)
		return (st || stem)  + "-" + SecureRandom.urlsafe_base64(12)
	end

end