class Feed < ActiveRecord::Base
	belongs_to :category
	validates_presence_of :format, :name, :url, :category_id
    attr_accessible :format, :name, :url
end
