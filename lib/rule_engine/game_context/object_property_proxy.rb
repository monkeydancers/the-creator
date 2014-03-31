class GameContext

	class ObjectPropertyProxy

		def initialize(property_object)
			@multi = property_object.is_multi_object? 
			@list = Array(property_object.value).map{|game_object| GameContext::GameObjectProxy.new(game_object)}			
		end

		def [](idx)
			if idx.is_a?(Fixnum)
				return @list[idx]
			else
				raise UnknownPropertyException.new("#{idx} is an unknown property in this context")
			end
		end

		def first
			@list[0]
		end

		def last
			@list[-1]
		end

		def size
			@list.length
		end

	end

end