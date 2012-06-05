module font

import display

class Rectangle
	var top : Int
	var left : Int
	var width : Int
	var height : Int

	init ( t, l, w, h : Int )
	do
		top = t
		left = l
		width = w
		height = h
	end

	fun right : Int do return left + width
	fun bottom : Int do return top + height
end

redef class Display
	fun write( text : String, font : Font, at_x : Int, at_y : Int )
	do
		var x = at_x
		for c in text do
			write_char( c, font, x, at_y )
			x += font.char_width
		end
	end
	fun write_boxed( text : String, font : Font, within : Rectangle )
	do
		var x = within.left
		var y = within.top

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
					write_char( text[i], font, x, y )
					x += font.char_width
				end

				if line_skip then
					y += font.char_height
					line_skip = false
				else
					x += font.char_width
				end

				word_start = li + 1
			else
				var word_length = li - word_start
				if word_length * font.char_width + y > within.right then
					x = within.left
					y += font.char_height
				end
			end

			li += 1
		end
	end
	fun write_char( c : Char, font : Font, at_x : Int, at_y : Int ) is abstract
end

interface Font
	fun char_width : Int is abstract
	fun char_height : Int is abstract
	fun length_of( text : String ) : Int is abstract
end
