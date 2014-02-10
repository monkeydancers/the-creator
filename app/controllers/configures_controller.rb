class ConfiguresController < ApplicationController
	before_filter :setup_active_game



	def class_info
		@gameobjectclass = @active_game.game_object_classes.where(["identifier = ?", params[:identifier]]).first
		respond_to do |format|
			format.html{ render :text => "This method does not respond to HTML-requests", :status => 406}
			format.json
		end

	end



end
