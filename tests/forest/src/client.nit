import mnit

import sockets
import serialize

import thin_termites_jack

import client_comm

import config

redef class ThinForest
	init do prepare

	fun sync( s : DeserializationStream )
	do
		# trees
		for x in [ 0 .. w [ do for y in [ 0 .. h [ do
			var case = grid[ x ][ y ]
			case.termite_count = 0
			case.lumberjack_count = 0
			case.worked_on_count = 0

			#print "{x} {y} {s.peak( 4 )}"
			var has_tree = s.read_bool

			if has_tree then
				var size = s.read_float
				var grown = s.read_bool
				var growth_rate = s.read_float
				var dead = s.read_bool
				case.tree = new ThinTree( size, grown, growth_rate, dead )
			else
				case.tree = null
			end
		end

		# termites
		var t_count = s.read_int
		for t in [ 0 .. t_count [ do
			var p = new Point( s.read_int, s.read_int )

			local_case_for( p ).termite_count += 1
		end

		# lumberjack
		var l_count = s.read_int
		for l in [ 0 .. l_count [ do
			var p = new Point( s.read_int, s.read_int )

			local_case_for( p ).lumberjack_count += 1
		end

		# worked on by lumberjacks
		var w_count = s.read_int
		for wo in [ 0 .. w_count [ do
			var p = new Point( s.read_int, s.read_int )

			local_case_for( p ).worked_on_count += 1
		end
	end
end

class NfsApp
	super App

	var imgs = new HashMap[String,Image]

	var s = new CommunicationSocket.connect_to( address, port )
	var stream : SocketDeserializationStream

	var tf = new ThinForest

	var in_server_shutdown protected writable = false
	var in_client_quit protected writable = false
	var in_moving protected writable = false
	var in_dx = 0
	var in_dy = 0

	init do super

	redef fun init_window
	do
		super

		imgs[ "trunk" ] = load_image( "trunk.png" )
		imgs[ "grown" ] = load_image( "grown-tree.png" )
		imgs[ "teen" ] = load_image( "teen-tree.png" )
		imgs[ "dead" ] = load_image( "dead-tree.png" )
		imgs[ "young" ] = load_image( "small-tree.png" )
		imgs[ "lumberjack" ] = load_image( "lumberjack.png" )

		for i in [ 1 .. 8 ] do
			imgs[ "termites{i}" ] = load_image( "termites{i}.png" )
		end

		var handshake = new Buffer
		(tf.w/-2).dump_to( handshake )
		(tf.w).dump_to( handshake )
		(tf.h/-2).dump_to( handshake )
		(tf.h).dump_to( handshake )

		print "sending handshake {handshake.to_s}"
		s.write( handshake.to_s )
		print "sent handshake {handshake.to_s}"

		# receiving sync
		stream = new SocketDeserializationStream( s )
		print "syncing"
		tf.sync( stream )
		print "synced"

	end

	redef fun frame_core( display )
	# the arg display is not null but otherwise the same than self.display
	do
		# receive updates
		var turn = new ThinGameTurn[Forest].deserialize( stream )

		# integrate
		tf.integrate_turn( turn )
		tf.do_local_turn

		# apply inputs
		tf.x += in_dx
		tf.y += in_dy

		# send inputs to server
		var b = new Buffer
		if in_client_quit then
			"quit".dump_to( b )
		else if in_server_shutdown then
			"shutdown".dump_to( b )
		else if in_moving then
			"move".dump_to( b )
		else
			"ok".dump_to( b )
		end
		s.write( b.to_s )

		# act on inputs locally
		if in_client_quit or in_server_shutdown then
		#	break label end_game
		else if in_moving then
			b = new Buffer

			(tf.x - tf.w/2).dump_to( b )
			(tf.w).dump_to( b )
			(tf.y - tf.h/2).dump_to( b )
			(tf.h).dump_to( b )

			s.write( b.to_s )

			tf.sync( stream )
		end

		# ui
		tf.draw( display, imgs )

		if not in_client_quit then
			in_client_quit = stream.read_bool
			if in_client_quit then print "Remote server shutdown"
		end

		if in_client_quit then finish_up

		in_server_shutdown = false
		in_client_quit = false
		in_moving = false
		in_dx = 0
		in_dy = 0
	end

	redef fun input( input_event )
	do
		if input_event isa QuitEvent then # close window button
			print "Local quit"
			in_client_quit = true
			return true # this event has been handled
		else if input_event isa KeyEvent and input_event.is_down then
			if input_event.is_arrow_up then
				in_moving = true
				in_dy -= 4
				return true
			else if input_event.is_arrow_down then
				in_moving = true
				in_dy += 4
				return true
			else if input_event.is_arrow_left then
				in_moving = true
				in_dx -= 4
				return true
			else if input_event.is_arrow_right then
				in_moving = true
				in_dx += 4
				return true
			end
		end
		return false
	end

	fun finish_up
	do
		s.close
		quit = true
	end
end

var app = new NfsApp
app.main_loop
