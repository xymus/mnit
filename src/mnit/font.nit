import display

abstract class Point
	fun x : Int is abstract
	fun y : Int is abstract
end

class PointI
super Point
	redef var x : Int
	redef var y : Int

	init ( x, y : Int )
	do
		self.x = x
		self.y = y
	end

	init from ( other : Point)
	do
		self.x = other.x
		self.y = other.y
	end
end

class PointF
super Point
	var xf : Float
	var yf : Float

	init ( x, y : Float )
	do
		xf = x
		yf = y
	end

	init from ( other : Point)
	do
		if other isa PointF then
			self.xf = other.xf
			self.yf = other.yf
		else
			self.xf = other.x.to_f
			self.yf = other.y.to_f
		end
	end

	redef fun x do return xf.to_i
	redef fun y do return yf.to_i
end

class Rectangle
	var top_left : Point
	var dimension : Point

	init ( t, l, w, h : Int )
	do
		top_left = new PointI( t, l )
		dimension = new PointI( w, h )
	end

	fun left : Int do return top_left.x
	fun top : Int do return top_left.y
	fun width : Int do return dimension.x
	fun height : Int do return dimension.y
	fun right : Int do return top_left.x + dimension.x
	fun bottom : Int do return top_left.y + dimension.y
end

redef class Display
	fun write( text : String, font : Font, at : Point )
	do
		var p = new PointI.from( at )
		for c in text do
			write_char( c, font, p )
			p.x += font.char_width
		end
	end
	fun write_boxed( text : String, font : Font, within : Rectangle )
	do
		var p = new PointI.from( within.top_left )
		var word_start = 0
		var word_end = 0
		var li = 0
		var line_skip = false

		for l in text do
			if l == ' ' then
				word_end = li
			else if l == '\n' then
				word_end = li
				line_skip = true
			end


			if word_end > word_start then # word complete
				for i in [ word_start .. word_end [ do
					write_char( text[i], font, p )
					p.x += font.char_width
				end

				if line_skip then
					p.y += font.char_height
					line_skip = false
				else
					p.x += font.char_width
				end

				word_start = li + 1
			else
				var word_length = li - word_start
				if word_length * font.char_width + p.y > within.right then
					p.x = within.left
					p.y += font.char_height
				end
			end

			li += 1
		end
	end
	fun write_char( c : Char, font : Font, at : Point ) is abstract
end

interface Font
	fun char_width : Int is abstract
	fun char_height : Int is abstract
	fun length_of( text : String ) : Int is abstract
end
