import text
import linux

redef class Screen
	redef fun input( event )
	do
		if not super and event isa SDLKeyEvent and
			 event.is_down then
			if event.key_name == "return" then
				context.append( '\n' )
			else if event.key_name == "spacebar" then
				context.append( ' ' )
			end
		end

		return false
	end
end

super

