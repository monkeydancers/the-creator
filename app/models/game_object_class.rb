class GameObjectClass < ActiveRecord::Base

	belongs_to :parent, :class_name => "GameObjectClass"
	has_many :properties

end
