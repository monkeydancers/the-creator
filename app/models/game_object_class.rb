require 'digest/sha1'
class GameObjectClass < ActiveRecord::Base
	include Identifier

	belongs_to :parent, :class_name => "GameObjectClass"
	has_many :children, :class_name => "GameObjectClass", :foreign_key => :parent_id, :dependent => :destroy
	has_many :properties, :as => :owner
	belongs_to :game
	has_many :game_objects, :foreign_key => 'object_class_id'

	validates :game_id, presence: true	

	before_create :set_parent_key
	after_commit :rebuild_nested_sets, :on => :create
	after_commit :rebuild_nested_sets_after_destroy, :on => :destroy

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

	def descendants(data = [])		
		if self.children.count > 0
			return {:klazz => self, :children => self.children.map{|c| c.descendants }}
		else
			return {:klazz => self, :children => []}
		end
	end

	def as_tree
		return {
			:id 				=> self.identifier, 
			:name 			=> self.name, 
			:info 			=> {:objects => full_stack_child_count, :identifier => self.identifier}, 
			:children 	=> self.children.map(&:as_tree)
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
			result = self.game.game_objects.destroy_all
		else
			result = self.game.game_objects.where(["identifier in (?)", scope]).destroy_all
		end
		logger.info result.inspect
		return {:error => !result, :payload => {:error => !result, :object_type => "object"}}
	end

	def subtree
		return self.game.game_object_classes.where(["lft > ? and rgt < ? and parent_key = ?", self.lft, self.rgt, self.parent_key])
	end

	def full_stack_child_count
		GameObject.count_by_sql(["select count(*) from game_objects where object_class_id in (select id from game_object_classes where lft >= ? and rgt <= ? and parent_key = ?);", self.lft, self.rgt, self.parent_key])
	end

	private

	# Add comments here for nested set architecture here...

	def rebuild_nested_sets_after_destroy
		if parent_id
			root.send(:rebuild_nested_sets)
		end
	end

	# Rebuild the nested sets used for tree-traversal
	def rebuild_nested_sets
		root.send(:perform_tree_rebuild, root.id, 0)
	end

	def perform_tree_rebuild(parent_id, left)
		object = self.game.game_object_classes.where(["id = ?", parent_id]).first
		right = left + 1
		object.children.each do |child|
			right = perform_tree_rebuild(child.id, right)
		end
		err = object.update_attributes({:lft => left, :rgt => right})
		return right + 1
	end

	def root
		current = self
		while GameObjectClass.exists?(["id = ? and game_id = ?", current.parent_id, current.game_id]) && !current.parent_id.nil? 
			current = GameObjectClass.where(["id = ? and game_id = ?", current.parent_id, current.game_id]).first
		end
		current
	end

	def set_parent_key
		self.parent_key = root.identifier
	end

end
