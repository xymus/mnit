
import bucket

import grid

class Forest
special Game
	redef type G : Forest

	var trees : List[ Tree ] = new List[ Tree ]
	var grid : Grid[ Tree ] = new Grid[ Tree ]

	var total_tree_count : Int = 0

	init
	do
		prepare
	end

	fun prepare
	do
		var o_node = grid.get_node_at( new Point( 0, 0 ) )
		var first_tree : Tree = new Tree( o_node )
		o_node.e = first_tree
		#var e = new TreeBirthEvent( first_tree )
		trees.add( first_tree )

		buckets.add_at( first_tree, 0 )
	end

	redef fun do_post_turn( turn )
	do
#	   #print "doing post turn"
		for e in turn.events
		do
			react_to_event( e )
		end
	end

	fun react_to_event( e : GameEvent )
	do
		if e isa TreeBirthEvent
		then
			trees.add( e.tree )
			e.tree.ground.e = e.tree
			buckets.add_at( e.tree, tick+1 )
			#print "birth at {turn.tick} on {e.tree.ground.position}"
			total_tree_count += 1
		else if e isa TreeFallEvent
		then
			trees.remove( e.tree )
			e.tree.ground.e = null
			#print "death at {turn.tick}"
		end
	end

	redef fun to_s
	do
		var text = new Buffer
		for y in [ -20 .. 20 [
		do
			for x in [ -40 .. 40 [
			do
				var n = grid.get_node_at( new Point( x, y ) )
				var tree = n.e

				if tree != null
				then
					text.append( "0" )
				#   #print "found tree"
				else
					text.append( "_" )
				end
			end
			text.append( "#\n" )
		end

		return text.to_s
	end
end

class Tree
special Bucketable[ Forest ]

	var stage : Int = 0 # 0=unborn, 1=growing, 2=adulthood, 3=useless/dead
	var grow_until : nullable Int
	var birth : Int = 0

	var ground : Node[ Tree ]

	var growth_rate : Float = 0.0
	var growing_time : Int
	var grown_size : Int
	fun size_at( t : Int ) : Float
	do
		if stage < 2
		then
			var elapsed = t - birth
			return elapsed.to_f*growth_rate
		else
			return grown_size.to_f
		end
	end

	init ( g : Node[ Tree ] )
	do
		ground = g

		growing_time = (50 + 100 .rand)
		grown_size = 2+8 .rand
		growth_rate = grown_size.to_f / growing_time.to_f
	end

	redef fun do_turn( turn )
	do
		if stage == 0
		then # birth
			birth = turn.tick
			grow_until = turn.tick + growing_time
			turn.game.buckets.add_at( self, grow_until.as(not null) )
			stage = 1 # is now growing

			#print "forest gr: {growth_rate}"

			#print "birth {self} grow until {grow_until.as(not null)}"
		else if stage == 1
		then # growing
			#print "growing"
			if turn.tick == grow_until
			then # grown to adulthood
				#print "grown to adulthood"
				turn.events.add( new TreeGrowthStopEvent( self ) )
				stage = 2
				do_adult_turn( turn )
			else # continue growing
				#print "continue {turn.tick} {grow_until.as(not null)}"
				turn.game.buckets.add_at(self, grow_until.as(not null) )
			end
		else if stage == 2
		then # adulthood
			#print "adulthood"
			do_adult_turn( turn )
		else # dead useless
			#print "useless"
			# falling or actually killed by anything
		   #print "is falling at {ground.position}"
			turn.events.add( new TreeFallEvent( self ) )
		end
	end

	fun is_dead : Bool do return stage == 3

	fun do_adult_turn( turn : GameTurn[Forest] )
	do
		var r = 8.rand
		if r == 0
		then # die
			die( turn )

		else # try to pollenise and live on

			var next_pos = ground.random_next.random_next.random_next
			if next_pos.e == null
			then # pollenise!
				var new_tree = new Tree( next_pos )
				turn.events.add( new TreeBirthEvent( new_tree ) )
				next_pos.e = new_tree # reserve space right away
			end

			var next_action = turn.tick + (50 + 20 .rand)
			turn.game.buckets.add_at( self, next_action )
		end
	end

	fun die( turn : GameTurn[ Forest ] ) : nullable TreeDeathEvent
	do
		if not is_dead then
			var fall_at = turn.tick + (50 + 40 .rand)
			turn.game.buckets.add_at( self, fall_at )
			var e = new TreeDeathEvent( self )
			turn.events.add( e )
			stage = 3 # is now dead but yet to fall
			return e
		else return null
	end
end

class PositionEvent
special GameEvent
	fun pos : Point is abstract
end

class MoveEvent
special GameEvent
	fun from : Point is abstract
	fun to : Point is abstract
end

class TreeEvent
special PositionEvent
	# position
	var tree : Tree writable
	redef fun pos do return tree.ground.position
end

class TreeDeathEvent
special TreeEvent
	init ( t : Tree ) do tree = t
end

class TreeFallEvent
special TreeEvent
	init ( t : Tree ) do tree = t
end

class TreeBirthEvent
special TreeEvent
	init ( t : Tree ) do tree = t
end

class TreeGrowthStopEvent
special TreeEvent
	init ( t : Tree ) do tree = t
end

