class SearchesController < ApplicationController

	before_filter :setup_active_game

	# Generic search
	def create
		@results = Search.perform(params, @active_game)
		respond_to do |format|
			format.json{}
		end
	end

end
