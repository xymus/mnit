module app

import display

abstract class App
	type IE : InputEvent
	type D : Display
	type I : Image

	var display : nullable D protected writable = null
	var quit : Bool protected writable = false

	init do end

	fun visible : Bool is abstract

	# invoqued at each frame
	fun full_frame
	do
		var display = self.display
		if display != null then
			display.begin
			frame_core( display )
			display.finish
		end
	end
	fun frame_core( display : D ) is abstract
	
	#fun start do end
	#fun stop do end
	#fun destroy do end
	
	fun save do end
	fun pause do end
	fun resume do end
	
	fun gained_focus do end
	fun lost_focus do end
	
	fun init_window do end
	fun term_window do end
	
	fun log_error( msg : String ) do print "#nit error: {msg}"
	fun log_warning( msg : String ) do print "#nit warn: {msg}"
	fun log_info( msg : String ) do print "#nit info: {msg}"
	
	# receive and deal with every input
	fun input( event : InputEvent ) : Bool
	do
		return false
	end

	protected fun generate_input is abstract
	
	fun main_loop
	do
		while not quit do
			generate_input
			full_frame
		end
	end
end

