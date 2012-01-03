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
		@categories = Category.find(:all)
		@category = Category.new(params[:category])
		respond_to do |format|
		  if @category.save
			format.html { redirect_to new_category_path }
		  else     
			format.html { render action: "new" }
		  end
		end
	end

	def edit
		@category = Category.find(params[:id])
	end

	def update
		@category = Category.find(params[:id])
		if @category.update_attributes(params[:category])
			flash[:notice] = "Successfully updated category."
			redirect_to category_url(@category)
		else
			render :action => 'edit'
		end
	end

	def destroy
		@category = Category.find(params[:id])
		@category.destroy
		flash[:notice] = "Successfully destroyed category."
		redirect_to new_category_path
	end

end

