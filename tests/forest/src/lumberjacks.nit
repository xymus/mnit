
intrude import forest # intrudes to solve visibility issues with events

class Lumberjack
special Bucketable[ Forest ]
    var working_on : nullable Tree = null
    var walking_to : nullable Node[Tree] = null
    var ground : Node[Tree]
    
    init ( g : Node[Tree] )
    do
        ground = g
    end
    
    redef fun do_turn( turn )
    do
        if working_on == null
        then # find new target
        
            var t = ground.next_with !cond( node ) =
                node.e != null and not node.e.is_dead
            
            if t != null
            then # valid target
                working_on = t.e
                var e = new LumberjackWorkEvent( self, working_on.as(not null), true )
                turn.events.add( e )
                walking_to = null
            else if walking_to != null
            then
                if walking_to == ground
                then # there!
                    walking_to = null
                else
                    do_walk( turn )
                end
            else
                var random_point = new Point(-20+40 .rand,-20+40 .rand)
                walking_to = turn.game.grid[ random_point ]
            end
        else
            if not working_on.is_dead
            then # cut down
                working_on.cut_down( turn )
            end
            
            var e = new LumberjackWorkEvent( self, working_on.as(not null), false )
            turn.events.add( e )
            
            working_on = null
        end
        
        turn.act_in( self, 10 )
    end
    
    fun do_walk( turn : GameTurn[Forest] )
    do
        if walking_to != null
        then
            if walking_to == ground
            then
                walking_to = null
            else
                var next_step = ground.next_toward( walking_to.as(not null) )
                var e = new LumberjackMoveEvent( self, ground, next_step )
                turn.events.add( e )
                ground = next_step
            end
        end
    end
end

class LumberjackSeeder
special Bucketable[ Forest ]
    redef fun do_turn( turn )
    do # act only once
        for i in [ 0 .. 12 [
        do
            var p = new Point( -20+40 .rand, -20+40 .rand )
            var lj = new Lumberjack( turn.game.grid.get_node_at( p ) )
            turn.events.add( new LumberjackBirthEvent( lj ) )
            turn.act_next( lj )
        end
    end
end

redef class Forest
    var lumberjacks : List[ Lumberjack ] = new List[Lumberjack]
    
    redef fun react_to_event( e )
    do
        if e isa LumberjackEvent
        then
            if e isa LumberjackBirthEvent
            then
                lumberjacks.add( e.lumberjack )
                
            #else if e isa LumberjackDeathEvent
            #then
            #    lumberjacks.remove( e.lumberjack )
            end
        else
            super( e )
        end
    end
    
    redef fun prepare
    do
        super
        
        var seeder = new LumberjackSeeder
        buckets.add_at( seeder, 500 )
    end
end

redef class Tree
    fun cut_down( turn : GameTurn[ Forest ] )
    do
        var e = die( turn )
        e.cut = true
    end
end

class LumberjackEvent
    var lumberjack : Lumberjack
    
    init lumberjack_const( l : Lumberjack ) do lumberjack = l
end

class LumberjackPositionEvent
special LumberjackEvent
special PositionEvent
    redef fun pos do return lumberjack.ground.position
    init ( l : Lumberjack ) do lumberjack_const( l )
end

class LumberjackBirthEvent
special LumberjackPositionEvent
    init ( l : Lumberjack ) do lumberjack_const( l )
end

class LumberjackMoveEvent
special LumberjackEvent
special MoveEvent

    redef fun from do return from_node.position    
    redef fun to do return to_node.position

    var from_node : Node[ Tree ]
    var to_node : Node[ Tree ]
    
    init ( lj : Lumberjack, f : Node[Tree], t : Node[Tree] )
    do
        lumberjack_const( lj )
        
        from_node = f
        to_node = t
    end
end

class LumberjackWorkEvent
special LumberjackPositionEvent
    var begins : Bool
    var target : Tree
    fun ends : Bool do return not begins
    
    init ( lj : Lumberjack, t : Tree, b : Bool )
    do
        super( lj )
        
        target = t
        begins = b
    end
end

redef class TreeDeathEvent
    var cut : Bool = false
end

