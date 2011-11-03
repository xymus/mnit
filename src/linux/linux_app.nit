module linux_app

import mnit
import sdl
import linux_opengles1

`{
#include <EGL/egl.h>
`}

redef class App
	redef type IE : SDLInputEvent
	redef type D : Opengles1Display
	redef type I : Opengles1Image

	redef init
	do
		display = new Opengles1Display

		super

		init_window
	end

	redef fun generate_input
	do
#		var new_event : nullable SDLInputEvent = null
#		loop do
#			new_event = display.sdl_display.poll_event
#			if new_event != null then
#				input( new_event )
#			else
#				break
#			end
#		end
		for event in display.sdl_display.events do
			input( event )
		end
	end
end

