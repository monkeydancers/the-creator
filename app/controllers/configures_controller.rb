class ConfiguresController < ApplicationController

	before_filter :authenticate_user!

	before_filter :setup_active_game


	def class_info
		@gameobjectclass = @active_game.game_object_classes.where(["identifier = ?", params[:identifier]]).first
	end



end
