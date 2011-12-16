class FeedEntriesController < ApplicationController

	before_filter :get_feed

	def index
		@feed_entries = @feed.feed_entries
	end

	def new
		@feed_entry = @feed.feed_entries.build
	end

	def create
		@feed_entry = @feed.feed_entries.build(params[:feed_entry])
		respond_to do |format|
		  if @feed_entry.save
			format.html { redirect_to new_feed_entry_path(:id => @feed.id) }
		  else     
			format.html { render action: "new", :id => @feed.id }
		  end
		end
	end

	def show
		@feed_entry = FeedEntry.find(params[:id])
	end

	def edit
		@feed_entry = FeedEntry.find(params[:id])
	end

	def update
		@feed_entry = FeedEntry.find(params[:id])
		if @feed_entry.update_attributes(params[:feed_entry])
			flash[:notice] = "Successfully updated feed entry."
			redirect_to category_feed_url(@feed_entry.feed_id)
		else
			render :action => 'edit'
		end
	end

	def destroy
		@feed_entry = FeedEntry.find(params[:id])
		@feed_entry.destroy
		flash[:notice] = "Successfully destroyed feed."
		redirect_to category_feed_url(@feed_entry.feed_id)
	end

	private

	def get_feed
		@feed = Feed.find(params[:feed_id])
	end

end
