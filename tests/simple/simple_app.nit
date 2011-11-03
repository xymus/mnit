import mnit

class MyApp
	super App

	#var img : I
	init
	do
		super
	end

	#redef fun init_window
	#do
		#super
		#img = load_asset( "images/fighter.png" ).as(Image)
	#end

	var r: Float = 0.0
	var g: Float = 0.0
	var b: Float = 0.0
	redef fun frame_core( display )
	do
		#print "f"
		b = b + 0.01
		if b > 1.0 then b = 0.0

		if display isa Opengles1Display then
			display.clear( r, g, b, 1.0 )
			#display.blit( img.as(Opengles1Image), 100, 100 )
		else
			print "not a opengles"
		end
	end

	redef fun input( ie )
	do
		if ie isa QuitEvent then
			quit = true
			return true
		else if ie isa PointerEvent then
			r = ie.x/display.width.to_f
			g = ie.y/display.height.to_f
			return true
		else
			print "unknown input: {ie}"
			return false
		end
	end
end

var app = new MyApp
app.main_loop

