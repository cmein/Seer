class CategoriesController < ApplicationController
	def index
		@categories = Category.find(:all)
	end

	def show
		@category = Category.find(params[:id])
		@feeds = @category.feeds.find(:all)
	end

	def new
		@category = Category.new
		@categories = Category.find(:all)
	end

	def create
		@category = Category.new(params[:category])
		respond_to do |format|
		  if @category.save
			format.html { redirect_to new_category_path }
		  else     
			format.html { redirect_to new_category_path }
		  end
		end
	end

end

