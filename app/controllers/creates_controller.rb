class CreatesController < ApplicationController


	def show

	end

	def structure
		@structure = Game.first.class_structure
		respond_to do |format|
			format.json{ render :text => @structure.to_json, :status => 200 and return}
		end
	end

end
