class WordsController < ApplicationController

	before_filter :get_category

	def index
		@words = @category.words
	end

	def new
		@word = @category.words.build
	end

	def create
		@word = @category.words.build(params[:word])
		respond_to do |format|
		  if @word.save
			format.html { redirect_to new_category_word_path(@category) }
		  else     
			format.html { render action: "new", :id => @category.id }
		  end
		end
	end

	def show
		@word = Word.find(params[:id])
	end

	def edit
		@word = Word.find(params[:id])
	end

	def update
		@word = Word.find(params[:id])
		if @word.update_attributes(params[:word])
			flash[:notice] = "Successfully updated word."
			redirect_to category_url(@word.category_id)
		else
			render :action => 'edit'
		end
	end

	def destroy
		@word = Word.find(params[:id])
		@word.destroy
		flash[:notice] = "Successfully destroyed word."
		redirect_to category_url(@word.category_id)
	end

	def updateword
		@word = Word.find(params[:id])
		@word.update_single_word_entries
		redirect_to category_word_path(@category, @word) 
	end

	private

	def get_category
		@category = Category.find(params[:category_id])
	end

end



