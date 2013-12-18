require 'digest/sha1'
module Identifier

	def self.included(base)
		base.class_eval do 
			before_create :generate_identifier
		end
	end

	private

	def generate_identifier
		self.identifier = Digest::SHA1.hexdigest(Time.now.to_i.to_s + rand.to_s)[0..6]
		while(GameObject.exists?(["identifier = ?", self.identifier])) 
			self.identifier = Digest::SHA1.hexdigest(Time.now.to_i.to_s + rand.to_s)[0..6]
		end
	end

end