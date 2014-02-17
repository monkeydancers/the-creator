# @author Daniel Sundström
# The property class represents attributes on instances of {GameObjectClass} which in turn are
# available on {GameObject} inheriting from the same {GameObjectClass}. Properties are the main 
# way through which authors add structure to their game. 
#
# Properties can be of a variety of types. Typing is enforced, unless specifically asked to not be. 
# The default setting is recommended unless you're an advanced user, due to the heightened risk of
# shooting ones own foot.
# 
# Out of the box, The Creator provides the following property types.
#
# * String
# * Integer
# * Single {GameObject}
# * List of {GameObject}s (order is preserved)
# * Single {Asset}
# * List of {Asset}s (order is preserverd)
#
# Services and extensions can provide new types of properties. See {Service}-documentation for 
# details.
#
# ## Default values
# Properties support the notion of default values, as in - values that created instances of {GameObject} 
# receive in their properties if no changes are made.
#
# ## Deletion
# TBD
#
# ## Rule Engine
# TBD
class Property < ActiveRecord::Base
	include Identifier

	belongs_to :game_object_class
	belongs_to :game

	validates :name, :presence => true
	validates :category, :presence => true
	validates :game_id, :presence => true

	around_save :flush_redis_writes
	before_save :set_property_klazz, :on => :create
	around_destroy :flush_redis_destroy

	# Assign a new default value to this property. Typing is not enforced until save.
	def value=(value)
		self.updated_at = Time.now
		if is_multi_object?
			(@value ||= []) << value
		else
			@value = value
		end
	end

	# Get the default value of this property.
	def value
		# This bizarre construct is done in order to not be reliant
		# on the inherent assignment-order when using Property.new({...})
		# since that hash can be ordered anywhich way .daniel
		if value_id
			value_object.value
		else			
			@value
		end
	end

	# Assign a new default value to this property. Typing is not enforced until save.
	def default_value=(value)
		@default_value = value
	end

	# Get the default value of this property.
	def default_value
		# This bizarre construct is done in order to not be reliant
		# on the inherent assignment-order when using Property.new({...})
		# since that hash can be ordered anywhich way .daniel
		if value_id
			value_object.default_value
		else			
			@default_value
		end
	end

	def value_description(regular = true)
		value_object.value_description(regular)
	end

	def clone
		raise ArgumentError.new("You can't clone an unsaved property") unless self.persisted? 
		return Property.new(:parent_id => self.id, :name => self.name, :property_klazz => self.property_klazz, :category => self.category, :default_value => self.value, :game_id => self.game_id)
	end

	def type
		value_object.type
	end

	def reload
		value_object.reload
	end

	# Identifier methods

	def is_multi_object? 
		return category.to_s.eql?('multi_object')
	end

	def is_single_object?
		return category.to_s.eql?('object')
	end

	def is_string?
		return category.to_s.eql?('string')
	end

	def is_numeric?
		return category.to_s.eql?('numeric')
	end

	def handle_removal(scope)
		value_object.handle_removal(scope)
		save
	end

	private

	def value_object
		@value_object ||= load_value_object
	end

	def available_subclasses
		{
			"string" 				=> StringProperty, 
			"object" 				=> SingleObjectProperty, 
			"multi_object" 			=> MultiObjectProperty, 
			"numeric"				=> NumericProperty
		}
	end

	def load_value_object
		value_instance = value_klazz.fetch(self.value_id)
		self.value_id = value_instance.id
		value_instance
	end

	def value_klazz
		available_subclasses[category.to_s]
	end

	def flush_redis_writes
		value_object.value = @value
		value_object.default_value = @default_value
		value_object.save
		yield
		value_object.commit
	end

	def set_property_klazz
		if value_klazz.can_set_property_klazz? && self.property_klazz.blank? 
			self.property_klazz = value_klazz.definition_class.to_s
		end
	end

	def flush_redis_destroy
		value_object.destroy
		yield
		if self.persisted?
			value_object.commit
		else
			value_object.discard
		end
	end

end