require 'digest/sha1'
class GameObjectClass < ActiveRecord::Base
	include Identifier

	belongs_to :parent, :class_name => "GameObjectClass"
	has_many :children, :class_name => "GameObjectClass", :foreign_key => :parent_id
	has_many :properties, :as => :owner
	belongs_to :game
	has_many :game_objects, :foreign_key => 'object_class_id'

	def property_list(opts = {:inherited => false})
		opts = {:list => []}.merge(opts)
		unless opts[:inherited]
			properties
		else
			list = opts[:list] + properties.to_a
			if self.parent
				return self.parent.property_list({:inherited => true, :list => list})
			else
				return list
			end
		end
	end

	def objects(recursive = true)
		list = []
		if recursive
			list = list + objects(false)
			self.children.each do |child|
				list = list + child.objects(true)
			end
		else
			list = list + self.game_objects.map{|go| {:name => go.name, :identifier => go.identifier} }
		end
		list
	end

	def generate_as_lua
		parent_name = (parent ? parent.name : 'GameObjectClass')
		a = %{
			#{name} = utils.makeClass(#{parent_name})
			#{name}.id = #{id}
		}
	end

	def descendants(data = [])		
		if self.children.count > 0
			return {:klazz => self, :children => self.children.map{|c| c.descendants }}
		else
			return {:klazz => self, :children => []}
		end
	end

	def as_tree
		return {
			:id 			=> self.id, 
			:name 		=> self.name, 
			:info 		=> {:objects => 20, :identifier => self.identifier}, 
			:children => self.children.map(&:as_tree)
		}
	end

	# Return the class-structure for the passed game as a tree. 
	def self.class_tree(game)
		data = []
		parents = game.game_object_classes.where(["parent_id is null"])
		parents.each do |parent_class|		
			data.push(parent_class.descendants)
		end
		data
	end

	def handle_removal(scope)
		if scope == "all"
			self.game.game_objects.destroy_all
		else
			self.game.game_objects.where(["identifier in (?)", scope]).destroy_all
		end
	end


end
