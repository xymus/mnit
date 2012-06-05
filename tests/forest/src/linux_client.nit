module linux_client

import client
import linux

redef class NfsApp
	redef fun input( input_event )
	do
		if input_event isa KeyEvent and not input_event.is_down then
			if input_event isa SDLKeyEvent and input_event.key_name == "q" then
				in_client_quit = true
				print "Local quit"
				return true
			else if input_event isa SDLKeyEvent and input_event.key_name == "s" then
				in_server_shutdown = true
				print "Shutdown server"
				return true
			end
		end

		return super
	end
end

super
