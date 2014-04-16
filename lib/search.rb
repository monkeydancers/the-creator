class Search

	SEARCHABLE_CLASSES = {
		'GameObject' => GameObject, 
		'GameObjectClass' => GameObjectClass
	}

	def self.perform(params, game_scope)
		klazz_scope = determine_klazz_scope(params[:scope])
		query 			= transform_query(params[:query])
		return ThinkingSphinx.search(query, :classes => klazz_scope, :with => {:game_id => game_scope.id})
	end

	private

	def self.determine_klazz_scope(scope_definition)
		if scope_definition
			return Array(scope_definition).map{|name| Search::SEARCHABLE_CLASSES[name] }.reject{|t| t.nil? }
		else
			return Search::SEARCHABLE_CLASSES.values
		end
	end

	def self.transform_query(query)
		if query[:strict]
			return query[:query]
		else
			return "*#{query[:query]}*"
		end
	end

end