require 'digest/sha1'
class GameObjectClass < ActiveRecord::Base

	belongs_to :parent, :class_name => "GameObjectClass"
	has_many :children, :class_name => "GameObjectClass", :foreign_key => :parent_id
	has_many :properties, :as => :owner
	has_many :game_objects, :foreign_key => 'object_class_id'

	before_create :generate_identifier

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

	def as_list
		object_list = objects(true)
		return {
			:list 							=> true,
			:identifier 				=> self.identifier, 
			:num_game_objects		=> object_list.length, 
			:objects_per_page 	=> 10, 
			:game_objects_list 	=> object_list
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

	private


	def generate_identifier
		self.identifier = Digest::SHA1.hexdigest(Time.now.to_i.to_s + rand.to_s)[0..6]
		while(GameObject.exists?(["identifier = ?", self.identifier])) 
			self.identifier = Digest::SHA1.hexdigest(Time.now.to_i.to_s + rand.to_s)[0..6]
		end
	end

end
