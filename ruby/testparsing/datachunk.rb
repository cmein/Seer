class Datachunk < ActiveRecord::Base
	# match these with the table columns for Datachunk:
	attr_accessible :course_title, :course_instructor, :course_location 
end
