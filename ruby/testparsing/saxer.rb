class Saxer < ::Ox::Sax
	def initialize
	end

  def start_element(name)
		@name = name
	end

  #def end_element(name);   puts "end: #{name}";          end
  #def attr(name, value);   puts "  #{name} => #{value}"; end
	
  def text(value)
			Datachunk.create(:course_title => @name) if @name=='title'
	end

end

