class FeedsController < ApplicationController

	before_filter :get_category

	def index
		@feeds = @category.feeds
	end

	def new
		@feed = @category.feeds.build
	end

	def create
		@feed = @category.feeds.build(params[:feed])
		respond_to do |format|
		  if @feed.save
			format.html { redirect_to new_category_feed_path(@category) }
		  else     
			format.html { render action: "new", :id => @category.id }
		  end
		end
	end

	def show
		@feed = Feed.find(params[:id])
	end

	def edit
		@feed = Feed.find(params[:id])
	end

	def update
		@feed = Feed.find(params[:id])
		if @feed.update_attributes(params[:feed])
			flash[:notice] = "Successfully updated feed."
			redirect_to category_url(@feed.category_id)
		else
			render :action => 'edit'
		end
	end

	def destroy
		@feed = Feed.find(params[:id])
		@feed.destroy
		flash[:notice] = "Successfully destroyed feed."
		redirect_to category_url(@feed.category_id)
	end

	def updatefeed
		@feed = Feed.find(params[:id])
		@feed.update_single_feed_entries
		redirect_to category_feed_path(@category, @feed) 
	end

	private

	def get_category
		@category = Category.find(params[:category_id])
	end

end


