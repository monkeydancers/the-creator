class GameobjectClassesController < ApplicationController
	before_filter :authenticate_user!

	before_filter :setup_active_game, :load_parent_class



	def create
		# Create a new class
		new_class = @parent_class.children.new(:name => params[:class_name], :game => @active_game)

		respond_to do |format|

			if new_class.save
				# Success
				format.json{ render :text => {:identifier => new_class.identifier, :name => new_class.name, :error => false}.to_json, :status => 200 and return }
			else 
				# Failure
				format.json{ render :nothing => true, :status => 500 and return }
			end
		end
	end

	private 

	def load_parent_class
		@parent_class = @active_game.game_object_classes.find_by_identifier(params[:parent_class_identifier])

		unless @parent_class 
			respond_to do |format|
				format.json{ render :nothing => true, :status => 500 and return }
			end
		end

	end

end
