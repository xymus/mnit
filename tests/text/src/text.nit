module text

import mnit

class TextContext
	var lines = new Array[String]
	var new_line = ""

	fun append( c : Char )
	do
		if c == '\n' then
			lines.add( new_line )
			new_line = ""
		else
			new_line = "{new_line}{c}"
		end
	end
end

# Where all the UI stuff is done
class Screen
	var font : Font
	var context = new TextContext

	init ( app : App )
	do
		font = app.load_font( "fonts/DroidSans.ttf" )
	end

	fun do_frame( display : Display )
	do
		display.clear( 0.0, 0.0, 1.0 )

		var x = 16
		var y = 32
		display.write( "Hello world", font, x, y )
		for line in context.lines do
			display.write( line, font, x, y )
			y += 16
		end
		display.write( context.new_line, font, x, y )
	end

	fun input( event : InputEvent ) : Bool
	do
		if event isa KeyEvent and event.is_down then
			var c = event.to_c
			if c != null then
				context.append( c )
				return true
			end
		end

		return false
	end
end

class MyApp
	super App

	var screen : nullable Screen = null

	redef fun init_window
	do
		super

		screen = new Screen( self )
	end

	redef fun frame_core( display )
	do
		var screen = self.screen
		if screen != null then
			screen.do_frame( display )
		end
	end

	redef fun input( ie )
	do
		var screen = screen
		if ie isa QuitEvent or
			( ie isa KeyEvent and ie.to_c == 'q' ) then
			quit = true
			return true
		else if screen != null then
			return screen.input( ie )
		else
			return false
		end
	end
end

var app = new MyApp
app.main_loop

