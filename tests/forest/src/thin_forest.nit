import mnit

import forest # just for MoveEvent, etc
import bucket

class Case
	var tree : nullable ThinTree writable = null
	
	redef fun to_s
	do  
		if tree != null
		then
			var c : Char
			if tree.dead
			then
				c = '&'
			else if tree.grown
			then
				c = 'T'
			else # growing
				var ss = (tree.size * 7.0 / 100.0).to_i + 1
				#c = ss.to_s[0] #'t'
				c = 't'
				
				# with colors : c = "\033[0;38m{ss.to_s}\033[0m" #'t'
			end
				
			return c.to_s
		else
			return " "
		end
	end
	
	fun draw( display : Display, imgs : HashMap[String,Image], 
			  x, y : Int )
	do
		if tree != null
		then
			if tree.dead then
				display.blit( imgs["dead"], x, y )
			else if tree.grown
			then
				display.blit( imgs["grown"], x, y )
			else if tree.size >= 4.0
			then
				display.blit( imgs["teen"], x, y )
			else
				display.blit( imgs["young"], x, y )
			end
		end
	end
end

class ThinForest
special Game
	var trees : List[ ThinTree ]
	var grid : Array[ Array[ Case ] ]

	var w : Int writable = 44
	var h : Int writable = 42
	
	var x : Int writable = 0 # center
	var y : Int writable = 0 # center
	
	init from_new_forest( f : Forest )
	do
		prepare
		
		# from forest part
		for t in f.trees
		do
			var p = t.ground.position
			grid[p.x+w/2][p.y+h/2].tree = new ThinTree( t.size_at( f.tick ), t.stage >= 2, t.growth_rate, t.stage >= 3 )
		end
	end
	
	fun prepare
	do
		
		trees = new List[ ThinTree ]
		grid = new Array[ Array[ Case ] ].with_capacity( w )
		
		for x in [ 0 .. w [
		do
			var c = new Array[ Case ].with_capacity( h )
			for y in [ 0 .. h [
			do
				c.add( new Case )
			end
			grid[x] = c
		end
	end

	fun integrate_turn( turn : ThinGameTurn[ Forest ] )
	do
		for e in turn.events
		do
			react_to_event( e )
		end
	end

	fun in_sight( p : Point ) : Bool
	do
		return p.x > x - w/2 and p.x < x + w/2 and
			   p.y > y - h/2 and p.y < y + h/2
	end

	fun local_case_for( p : Point ) : Case
	do
	   #print "away: {p} local: {new Point( p.x-x+w/2, p.y-y+h/2 )}"
		return grid[ p.x-x+w/2 ][ p.y-y+h/2 ]
	end

	fun react_to_event( e : GameEvent )
	do
		if e isa ThinTreeEvent then
			var p = e.pos

			if in_sight( p ) then
				if e isa ThinTreeFallEvent then
					var t = local_case_for( p ).tree

					if t != null then
						local_case_for( p ).tree = null
						trees.remove( t )
					else
						print "expected tree at {p}"
						abort
					end
				else if e isa ThinTreeBirthEvent then
					var t = new ThinTree.sprout( e.growth_rate )
					#print "thin gr: {e.tree.growth_rate}"

					local_case_for( p ).tree = t
					trees.add( t )
				else if e isa ThinTreeGrowthStopEvent then
					var t = local_case_for( p ).tree

					if t != null then
						t.grown = true
					else
						abort
					end
				else if e isa ThinTreeDeathEvent then
					var t = local_case_for( p ).tree

					if t != null then
						t.dead = true
					else
						abort
					end
				end
			end
		end
	end

	fun do_local_turn
	do
		for x in [ 0 .. w [ do
			for y in [ 0 .. h [ do
				var c = grid[ x ][ y ]
				if c.tree != null then
					c.tree.do_local_turn
				end
			end
		end
	end

	redef fun to_s
	do
		var buf = new Buffer
		for y in [ 0 .. h [ do
			for x in [ 0 .. w [ do
				var c = grid[x][y]
				buf.append( c.to_s )
			end
			buf.add( '\n' )
		end
		
		return buf.to_s
	end
	
	fun draw( display : Display, imgs : HashMap[String,Image] )
	do
		display.clear( 0.0, 0.3, 0.0 )
		
		for y in [ 0 .. h [ do
			for x in [ 0 .. w [ do
				grid[x][y].draw( display, imgs, x*24-16, y*16-16 )
			end
		end
	end
end

class ThinTree
	var size : Float
	
	var grown : Bool
	var growth_rate : Float
	
	var dead : Bool
	
	fun do_local_turn
	do
		if not grown then size += growth_rate
	end
	
	init ( s : Float, g : Bool, gr : Float, d : Bool )
	do
		size = s
		grown = g
		growth_rate = gr
		dead = d
	end
	
	init sprout( gr : Float )
	do
		size = 0.0
		grown = false
		growth_rate = gr
		dead = false
	end
end


class ThinPositionEvent
special PositionEvent
	redef var pos : Point writable
	
	#init ( p : Point ) do pos = p
end

class ThinMoveEvent
special MoveEvent
	redef var from : Point writable
	redef var to : Point writable
	
	#init ( f : Point, t : Point )
	#do
	#	from = f
	#	to = t
	#end
end

class ThinTreeEvent
special ThinPositionEvent
	#init ( p : Point ) do pos = p
end

class ThinTreeDeathEvent
special ThinTreeEvent
	#init ( p : Point ) do pos = p
end

class ThinTreeFallEvent
special ThinTreeEvent
	#init ( p : Point ) do pos = p
end

class ThinTreeGrowthStopEvent
special ThinTreeEvent
	#init ( p : Point ) do pos = p
end

class ThinTreeBirthEvent
special ThinTreeEvent
	var growth_rate : Float writable
	#init ( p : Point, gr : Float )
	#do
	#	super( p )
	#	growth_rate = gr
	#end
end
