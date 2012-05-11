import mnit

class MyApp
	super App

	var img : nullable I = null

	init do super

	redef fun init_window
	do
		super

		var txt = load_asset( "hello.txt" )
		if txt isa String then
			print txt.length
			print txt
		end

		img = load_image( "fighter.png" )
	end

	var r: Float = 0.0
	var g: Float = 0.0
	var b: Float = 0.0
	redef fun frame_core( display )
	do
		b = b + 0.01
		if b > 1.0 then b = 0.0

		display.clear( r, g, b )

		var img = self.img
		if img != null then
			display.blit( img, 100, 100 )
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

