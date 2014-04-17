class Rule < ActiveRecord::Base

	belongs_to :game

	acts_as_taggable_on :actor, :target

	validates :actor_list, length: { maximum: 1 }
	validates :target_list, length: { maximum: 1 }

	def actor
		game.resolve_identifier(self.actor_list.first)
	end

	def target
		game.resolve_identifier(self.target_list.first)
	end

end
