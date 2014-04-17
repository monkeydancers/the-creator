class Game < ActiveRecord::Base

	has_many :game_objects, :dependent => :destroy
	has_many :game_object_classes, :dependent => :destroy
	has_many :properties, :dependent => :destroy
	has_many :rules, :dependent => :destroy
	has_many :root_classes, ->{ where(["parent_id is null"]) }, :class_name => "GameObjectClass"

	before_validation :generate_api_key, :on => :create

	def class_structure
		data = []
		root_classes.each do |goc|
			data.push(goc.as_tree)
		end
		return data
	end

	# Extend resolve_identifier to support scoping to a specific set of 
	# classes.
	def resolve_identifier(identifier)
		if self.game_objects.where(["identifier = ?", identifier]).count > 0
			return self.game_objects.where(["identifier = ?", identifier]).first
		elsif self.game_object_classes.where(["identifier = ?", identifier]).count > 0
			return self.game_object_classes.where(["identifier = ?", identifier]).first
		elsif self.properties.where(["identifier = ?", identifier]).count > 0 
			return self.properties.where(["identifier = ?", identifier]).first
		else
			return nil
		end
	end

	def handle_interaction(parameters)
		actor_object 		= resolve_identifier(parameters[:actor])
		return {:error => true, :message => "Unknown actor"} if actor_object.nil?

		target_object 	= resolve_identifier(parameters[:target])
		return {:error => true, :message => "Unknown target"} if target_object.nil?

		# Extend this later on with support for multiple tags, which will then qualify rules
		# for being based on n-n relationships.
		rule_selection 	= rules.tagged_with(actor_object.object_class.identifier, :on => :actor)
														.tagged_with(target_object.object_class.identifier, :on => :target)

		rule_context = Engine.new(self)

		rule_selection.to_a.each do |rule|
			rule_context.run(rule.rule_code)
		end

		# Some kind of 

		# profit!!
	end

	private

	def generate_api_key
		self.api_key = Digest::SHA1.hexdigest(self.object_id.to_s + Time.now.to_i.to_s)
	end

end