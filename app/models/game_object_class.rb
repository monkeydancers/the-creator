class GameObjectClass < ActiveRecord::Base

	belongs_to :parent, :class_name => "GameObjectClass"
	has_many :children, :class_name => "GameObjectClass", :foreign_key => :parent_id
	has_many :properties, :as => :owner
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

	# Return the class-structure for the passed game as a tree. 
	def self.class_tree(game)
		data = []
		parents = game.game_object_classes.where(["parent_id is null"])
		parents.each do |parent_class|		
			data.push(parent_class.descendants)
		end
		data
	end

end
