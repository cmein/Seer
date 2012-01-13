class Word < ActiveRecord::Base
	belongs_to :category
	validates_presence_of :name, :category_id
	attr_accessible :name, :alert, :pop_mean, :pop_sd, :history, :category_id
	before_create :init
	serialize :history, Array

	def init
		self.alert ||= 0
		self.pop_mean ||= 0.0
		self.pop_sd ||= 0.0
	end

end
