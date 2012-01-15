class Saxer < ::Ox::Sax

	attr_accessor :stack

	def initialize
		@stack = []
	end

	def start_element(name)
		@name = name.to_s
	end

	#def attr(name, value);   puts "  #{name} => #{value}"; end
	
	def text(value)
		@value = value.to_s.force_encoding("UTF-8") # UTF-8 encoding is forced to allow saving to database
		case @name
		when "title"
			@title = @value
		when "instructor"
			@instructor = @value
		when "building"
			@location = @value
		when "room"
			@location = [@location, @value].join(' ')
		end
	end

	def end_element(name)
		Datachunk.create(:course_title => @title, :course_instructor => @instructor, :course_location => @location) if name.to_s == "course" # modify according to top-level element
	end

	private

end

