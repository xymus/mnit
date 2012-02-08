module moles

import mnit

class Hole
	var game : Game
	var x : Int
	var y : Int
	var dim : Int # Should it be removed?

	# state
	var up : Bool = false
	var hitted : Bool = false

	init ( g : Game, x, y : Int )
	do
		game = g
		self.x = x
		self.y = y
		dim = game.img_dim
	end

	fun do_turn
	do
		if up then
			if hitted then
				if (20.0*game.speed_modifier).to_i.rand == 0 then
					# dead / hide
					hitted = false
					up = false
				end
			else if (80.0*game.speed_modifier).to_i.rand == 0 then
				# hide
				up = false
			end
		else if (100.0*game.speed_modifier).to_i.rand == 0 then
			# show up
			up = true
		end
	end

	fun intercepts( event : PointerEvent ) : Bool
	do
		var ex = event.x.to_i
		var ey = event.y.to_i
		return ex > x and ex < x + dim and
			ey > y and ey < y + dim
	end

	fun hit
	do
		if hitted then return

		if up then
			hitted = true
			game.points += 1
		else
			abort # should not happen
		end
	end
end

class Game
	var holes : Sequence[Hole] = new Array[Hole].with_capacity(4)

	# rule / const
	var modifier_half_life : Float = 40.0
	var rows : Int = 5
	var columns : Int = 3

	# state
	var points : Int = 0
	var speed_modifier : Float = 1.0

	# configs
	var img_ori_dim : Int = 256
	var img_dim : Int = 210
	var global_speed_modifier : Float = 2.0

	init
	do
		var d = img_dim
		for x in [ 0 .. rows [ do
			for y in [ 0 .. columns [ do
				holes.add( new Hole( self, x*d, y*d ) )
			end
		end
	end

	fun do_turn do
		for hole in holes do hole.do_turn

		speed_modifier = modifier_half_life / (modifier_half_life+points.to_f) * global_speed_modifier

		print "p: {points} sm: {speed_modifier}"
	end
end

# Where all the UI stuff is done
class Screen
	var empty_img : Image
	var up_img : Image
	var hit_img : Image

	var game : Game = new Game

	init ( app : App )
	do
		empty_img = app.load_asset( "images/empty.png" ).as(Image)
		up_img = app.load_asset( "images/up.png" ).as(Image)
		hit_img = app.load_asset( "images/hit.png" ).as(Image)

		var scale = game.img_dim.to_f / game.img_ori_dim.to_f
		empty_img.scale = scale
		up_img.scale = scale
		hit_img.scale = scale
	end

	fun do_frame( display : Display )
	do
		if display isa Opengles1Display then
			display.clear( 0.0, 0.7, 0.0, 1.0 )
		end

		for hole in game.holes do
			var img

			if hole.hitted then
				img = hit_img
			else if hole.up then
				img = up_img
			else
				img = empty_img
			end

			display.blit( img, hole.x, hole.y-64 )
		end
	end

	fun input( event : InputEvent ) : Bool
	do
		if event isa PointerEvent then
			for hole in game.holes do
				if hole.intercepts( event ) then
					if hole.up then
						hole.hit
					end
					return true
				end
			end
		end

		return false
	end
end

class MyApp
	super App

	var screen : nullable Screen = null

	init do super

	redef fun init_window
	do
		super

		screen = new Screen( self )
	end

	redef fun frame_core( display )
	do
		var screen = self.screen
		if screen != null then
			screen.game.do_turn
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
			print "unknown input: {ie}"
			return false
		end
	end
end

var app = new MyApp
app.main_loop

