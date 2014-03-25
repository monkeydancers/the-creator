class GameobjectClassPropertiesController < ApplicationController
	before_filter :setup_active_game

	def create
		gameobjectclass = @active_game.game_object_classes.where(["identifier = ?", params[:class_identifier]]).first

		prop = gameobjectclass.properties.new( 
			:name 		=> params[:property_name], 
			:category 	=> params[:data_type], 
			:value 		=> params[:property_default],  
			:game 		=> @active_game)


		respond_to do |format|

			if prop.save 
				format.json{ render :text => {
					:identifier => prop.identifier, 
					:name => prop.name, 
					:error => false,
					:datatype => prop.type,
					:inherited_from => "",
					:default_value => prop.value_description(true)}.to_json, 
						:status => 200 and return }
			else 	
				# Failure
				format.json{ render :nothing => true, :status => 500 and return }
			end
		end

	end

	def destroy 
		prop = @active_game.properties.where("identifier = ?", params[:id]).first

		respond_to do |format|

			if prop && prop.destroy
				format.json{ render :text => {
					:identifier => prop.identifier, 
					:error => false}.to_json, 
						:status => 200 and return }
			else 
				format.json{ render :nothing => true, :status => 500 and return }
			end 
		end
	end


	def update
		prop = @active_game.properties.where("identifier = ?", params[:id]).first

		respond_to do |format|

			if prop && prop.update(:name => params[:property_name], :value => params[:property_default])
				format.json{ render :text => {
					:identifier => prop.identifier, 
					:name => prop.name, 
					:error => false,
					:datatype => prop.type,
					:inherited_from => "",
					:default_value => prop.value_description(true)}.to_json, 
						:status => 200 and return }
			else 
				format.json{ render :nothing => true, :status => 500 and return }
			end 
		end
	end

end
