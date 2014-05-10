class CreatesController < ApplicationController

	before_filter :authenticate_user!

	before_filter :setup_active_game


	def show

	end

	def create
		@parent = @active_game.resolve_identifier(params[:identifier])
		respond_to do |format|
			if @parent
				@object = @parent.game_objects.create(create_object_params.merge({:game_id => @active_game.id}))
				if @object && @object.errors.empty? 
					format.json{ render :template => "/creates/#{@object.class.name.downcase}", :status => 201 and return }
				else
					# Add proper error message here! .daniel	
					format.json{ render :text => {:error => true, :message => "Something went wrong"}, :status => 500 and return }
				end
			else
				format.json{ render :nothing => true, :status => 404 and return }
			end
		end
	end

	# This should be generalised to be used in  configure too
	def structure
		@structure = @active_game.class_structure
		respond_to do |format|
			format.html{ render :text => "This method does not respond to HTML-requests", :status => 406}
			format.json{ render :text => @structure.to_json, :status => 200 and return}
		end
	end

	def identifier
		@object = @active_game.resolve_identifier(params[:identifier])
		respond_to do |format|
			format.json{ render :template => "/creates/#{@object.class.name.downcase}", :status => 200 }
		end
	end

	def save_property
		property = @active_game.properties.where(["identifier = ?", params[:identifier]]).first
		respond_to do |format|	
			if property
				property.value = params[:value]
				property.save
				property.reload
				format.json{ render :text => {:value => property.value_description, :error => false}.to_json, :status => 200 and return }
			else
				format.json{ render :nothing => true, :status => 500 and return }
			end
		end
	end

	def load_property
		@property = @active_game.properties.where(["identifier = ?", params[:identifier]]).first
		respond_to do |format|
			if @property
				format.json{}
			else
				format.json{ render :text => {:error => true}.to_json, :status => 404 and return }
			end
		end
	end

	# Update this to provide a per-object payload which can be used to identify stuff
	# on client-side. 
	def remove
		@object = @active_game.resolve_identifier(params[:identifier])
		respond_to do |format|
			result = @object.handle_removal(params[:scope])
			if @object && !result[:error]
				format.json{ render :text => result[:payload].to_json, :status => 200 }
			else
				format.json{ render :text => result[:payload].to_json, :status => 500 }
			end
		end
	end

	def update
		@object = @active_game.resolve_identifier(params[:identifier][:identifier])
		respond_to do |format|
			if @object && @object.update(params[:key], params[:value])
				format.json{}
			else
				format.json{ render :text => {:error => true}.to_json, :status => 500 }
			end
		end
	end

	private

	def create_object_params
		params.require(:game_object).permit(:name)
	end
end
