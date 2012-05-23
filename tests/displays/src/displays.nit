module displays

import mnit

redef class Sys
	var w = 800
	var h = 600
end

class Button
	var img : Image
	var x : Int
	var y : Int
	var hit_manager : MyApp

	fun hit( x, y : Int ) : Bool
	do
		if x > self.x and x < self.x + img.width and
			y > self.y and y < self.y + img.height then

			hit_manager.hit( self )
			return true
		else
			return false
		end
	end
end

class MyApp
	super App

	var but_640x480 : Button
	var but_800x600 : Button
	var but_1280x800 : Button
	var buttons = new Array[Button]

	init do super

	redef fun init_window
	do
		super

		but_640x480 = new Button( load_image( "640x480.png" ), 32, 0, self )
		but_800x600 = new Button( load_image( "800x600.png" ), 32, 128, self )
		but_1280x800 = new Button( load_image( "1280x800.png" ), 32, 256, self )

		buttons.clear
		buttons.add( but_640x480 )
		buttons.add( but_800x600 )
		buttons.add( but_1280x800 )
	end

	redef fun frame_core( display )
	# the arg display is not null but otherwise the same than self.display
	do
		display.clear(1.0,1.0,1.0)
		for but in buttons do
			display.blit( but.img, but.x, but.y )
		end
	end

	redef fun input( input_event )
	do
		if input_event isa QuitEvent then # close window button
			quit = true # orders system to quit
			return true # this event has been handled

		else if input_event isa PointerEvent and input_event.down then
			for but in buttons do
				if but.hit( input_event.x.to_i, input_event.y.to_i ) then
					return true
				end
			end
			return false

		else
			return false # unknown event, can be handled by something else
		end
	end

	fun hit( b : Button )
	do
		if b == but_640x480 then
			sys.w = 640
			sys.h = 480
		else if b == but_800x600 then
			sys.w = 800
			sys.h = 600
		else
			sys.w = 1280
			sys.h = 800
		end

		display.as(Opengles1Display).close
		display = new Opengles1Display
		init_window
	end
end

var app = new MyApp
app.main_loop
