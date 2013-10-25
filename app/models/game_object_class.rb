class GameObjectClass < ActiveRecord::Base

	belongs_to :parent, :class_name => "GameObjectClass"
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

end
