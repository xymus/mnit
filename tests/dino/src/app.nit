# App for the Dino game, manages App lifecyle and inputs
module app

import mnit

import graphism
import fancy_dino
import splash

class DinoApp
	super App

	var cavemen_at_first_level = 6
	var cavemen_incr = 4

	var game : nullable Game = null
	var imgs : nullable ImageSet = null
	var splash : nullable SplashScreen = null

	init do super

	redef fun init_window
	do
		super

		var display = display
		assert display != null

		# load only splash images
		splash = new SplashScreen( self )
		splash.draw( display, false )

		# load other images
		imgs = new ImageSet( self )

		splash.draw( display, true )
	end

	redef fun frame_core( display )
	do
		var game = game
		if game != null then
			var turn = game.do_turn()
			game.draw( display, imgs.as(not null), turn )
		else
			splash.draw( display, true )
		end
	end

	redef fun input( input_event )
	do
		if input_event isa QuitEvent then # close window button
			quit = true # orders system to quit
			return true # this event has been handled

		else if input_event isa PointerEvent then
			if game == null then
				# start from splash
				game = new Game( cavemen_at_first_level )
			else if game.over and game.ready_to_start_over then
				# play next game
				var next_nbr_caveman = game.nbr_wanted_cavemen
				if game.won then next_nbr_caveman += cavemen_incr
				game = new Game( next_nbr_caveman )
			else
				# normal play
				game.dino.going_to = (new ScreenPos( input_event.x, input_event.y )).to_game( display.as(not null) )
			end
			return true

		else if input_event isa KeyEvent then
			return false
		end

		return false # unknown event, can be handled by something else
	end
end

var app = new DinoApp
app.main_loop

