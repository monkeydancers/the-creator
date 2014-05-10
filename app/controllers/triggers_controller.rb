class TriggersController < ApplicationController

	before_filter :validate_game

	protect_from_forgery :only => []

	def create
		# Whatever results should / will be?
		results = @game.handle_interaction(params)
		respond_to do |format|
			format.json{ render :text => results.to_json, :status => 200 and return }
			format.html{ render :text => results.to_json, :status => 200 and return }
		end
	end

	private

	def validate_game
		key = params[:apikey] || request.env['HTTP_AUTH_TOKEN']
		@game = Game.where(["api_key = ?", key]).first
		unless @game
			respond_to do |format|
				format.json{ render :text => {:message => "The provided key doesn't match any game."}.to_json, :status => 404 and return }
				format.html{ render :text => "The provided key doesn't match any game.", :status => 404 and return } 
			end
		end
	end

end
