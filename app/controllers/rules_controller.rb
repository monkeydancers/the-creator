class RulesController < ApplicationController

	before_filter :setup_active_game

	before_filter :authenticate_user!


	def index
		@rules = @active_game.rules
	end

	def show
		@rule = @active_game.rules.where(["id = ?", params[:id]]).first
		respond_to do |format|
			format.json{}
		end
	end

	def update
		@rule = @active_game.rules.where(["id = ?", params[:id]]).first
		respond_to do |format|
			if @rule.update_attributes(rule_params)
				format.json{ render :action => :show, :status => 200 and return }
			else
				format.json{ render :text => {:error => true}.to_json, :status => 500 and return }
			end
		end
	end

	def create
		@rule = @active_game.rules.create(rule_params)
		respond_to do |format|
			if @rule && @rule.errors.empty? 
				format.json{ render :action => :show, :status => 200 and return }
			else
				format.json{ render :status => 400, :text => {:error => true, :message => @rule.errors.full_messages }.to_json and return }
			end
		end
	end


	private 

	def rule_params
		params.require(:rule).permit(:rule_code, :name, :actor_list, :target_list)
	end

end
