class FeedsController < ApplicationController
	def new
		@category = Category.find(params[:id])
		@feed = @category.feeds.build
	end

	def create
		@category = Category.find(params[:id])
		@feed = @category.feeds.build(params[:feed])
		respond_to do |format|
		  if @feed.save
			format.html { redirect_to new_feed_path(:id => @category.id) }
		  else     
			format.html { redirect_to new_feed_path(:id => @category.id) }
		  end
		end
	end

end


