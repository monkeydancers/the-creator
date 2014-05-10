class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  	def setup_active_game
			@active_game = current_user.game
		end

		def after_sign_in_path_for(resource)
		  configure_path
		end

end
