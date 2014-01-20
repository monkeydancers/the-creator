class ConfiguresController < ApplicationController
	before_filter :setup_active_game

	def show

	end

	def class_info
		@gameobjectclass = @active_game.game_object_classes.where(["identifier = ?", params[:identifier]]).first
		logger.error(@gameobjectclass.inspect)
		respond_to do |format|
			format.html{ render :text => "This method does not respond to HTML-requests", :status => 406}
			format.json
		end

	end

	# Ported from creates 
	def structure
		@structure = @active_game.class_structure
		respond_to do |format|
			format.html{ render :text => "This method does not respond to HTML-requests", :status => 406}
			format.json{ render :text => @structure.to_json, :status => 200 and return}
		end
	end

end
