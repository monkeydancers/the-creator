class GameObjectProxy

	def initialize(game_object_class)
		@object_class = game_object_class
	end

	def each(&block)
		GameObject.where(game_object_class_id: @object_class.id).each(&block)
	end

	def destroy_all
		GameObject.where(game_object_class_id: @object_class.id).destroy_all
	end

	def length
		GameObject.where(game_object_class_id: @object_class.id).count
	end

	def create(attributes)
		GameObject.create(attributes.merge({:game_object_class_id => @object_class.id}))
	end

	def new(attributes)
		GameObject.new(attributes.merge!({:game_object_class_id => @object_class.id}))
	end

	alias_method :count, :length

end