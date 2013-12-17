class CreatesController < ApplicationController

	before_filter :setup_active_game

	def show

	end

	def structure
		@structure = @active_game.class_structure
		respond_to do |format|
			format.json{ render :text => @structure.to_json, :status => 200 and return}
		end
	end

	def identifier
		@object = @active_game.resolve_identifier(params[:identifier])
		respond_to do |format|
			format.json{ render :text => @object.as_list.to_json, :status => 200 and return }
		end
	end

	private

	def setup_active_game
		@active_game = Game.first
	end

end
