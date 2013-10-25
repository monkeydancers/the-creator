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

	belongs_to :game_object_class

	validates :name, :presence => true

	around_save :flush_redis_writes
	before_save :set_property_klazz, :on => :create
	around_destroy :flush_redis_destroy

	# Assign a new default value to this property. Typing is not enforced until save.
	def value=(value)
		@value = value
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

	def clone
		raise ArgumentError.new("You can't clone an unsaved property") unless self.persisted? 
		return Property.new(:parent_id => self.id, :name => self.name, :property_klazz => self.property_klazz, :property_type_definition => self.property_type_definition, :default_value => self.value)
	end

	private

	def value_object
		@value_object ||= load_value_object
	end

	def available_subclasses
		{
			"StringProperty" => StringProperty, 
			"ObjectProperty" => SingleObjectProperty
		}
	end

	def load_value_object
		value_instance = value_klazz.fetch(self.value_id)
		self.value_id = value_instance.id
		value_instance
	end

	def value_klazz
		available_subclasses[property_type_definition]
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
			self.property_klazz = value_klazz.definition_class
		end
	end

	def flush_redis_destroy
		value_object.destroy
		yield
		value_object.commit
	end

end