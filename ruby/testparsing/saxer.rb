class Saxer < ::Ox::Sax

	attr_accessor :stack

	def initialize
		@stack = []
	end

	def start_element(name)
		@name = name.to_s
	end

	#def end_element(name);   puts "end: #{name}";          end
	#def attr(name, value);   puts "  #{name} => #{value}"; end
	
	def text(value)
		@value = value.to_s.force_encoding("UTF-8")	# UTF-8 encoding is forced to allow saving to database
		Datachunk.create(:course_title => @value) if @name=='title'
		puts @value if @name=='title'
	end

end

