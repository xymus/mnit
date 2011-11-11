import mnit

class MyApp
	super App

	var img : nullable I = null
	init
	do
		super
	end

	redef fun init_window
	do
		super

		#var txt = load_asset( "hello.txt" ).as(String)
		#print txt
		#print txt.length

		img = load_asset( "fighter.png" ).as(Image)
	end

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

			var img = self.img
			if img != null then
				display.blit( img.as(Opengles1Image), 100, 100 )
			end
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

