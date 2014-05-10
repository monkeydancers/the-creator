class Api::V1::GameObjectsController < ApplicationController

	before_filter :set_active_game

	def index
		@objects = @game.game_objects
		if params[:scope]	
			@objects = @objects.where(["object_class_id in (select id from game_object_classes where identifier in (?))", params[:scope]])
		end
		respond_to do |format|
			format.json{}
		end
	end

	def show
		@object = @game.game_objects.where(["identifier = ?", params[:id]]).first
		respond_to do |format|
			format.json{}
		end
	end


	private

	def set_active_game
		@game = Game.where(["api_key = ?", params[:key]]).first
		unless @game
			respond_to do |format|
				format.json{ render :text => {:error => true, :message => "Invalid Game API-key"}.to_json, :status => 401 and return }
			end
		end
	end


end
