require 'securerandom'
class PropertyProxy

	attr_reader :id

	def self.fetch(object_id)
		instance = self.new({:value => nil})
		instance.set_identifier
		instance
	end

	def value=(value)
		raise NotImplementedError.new("#{self.class.name} does not properly implement value=")
	end

	def value
		raise NotImplementedError.new("#{self.class.name} does not properly implement value")
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