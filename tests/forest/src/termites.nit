
intrude import forest # intrudes to solve visibility issues with events

class Termite
special Bucketable[ Forest ]
    var ground : Node[ Tree ]
    var failed_move : Int = 0
    
    init ( g : Node[ Tree ] )
    do
        ground = g
    end

    redef fun do_turn( turn )
    do
        #print "t"
        var tree = ground.e
        if tree != null and not tree.is_dead
        then
            tree.die( turn )
        end
        
        #var move_to = ground.random_next
        var move_to = ground.random_next_with !cond( n ) = n.e!=null and not n.e.as(not null).is_dead
        
        if move_to != null # .e
        then
           #print "t move"
            var e = new TermiteMoveEvent( 
                self, ground.position, move_to.position )
            turn.events.add( e )
            
            ground = move_to
            
            turn.act_in( self, 5+10 .rand )
        else
           #print "t not move"
            failed_move += 1
            if failed_move > 4
            then
               #print "t die"
                var e = new TermiteDeathEvent( self )
                turn.events.add( e )
            else
                turn.act_in( self, 25+20 .rand )
            end
        end
        
    end
end

class RandomTermiteSeeder
special Bucketable[ Forest ]
    redef fun do_turn( turn )
    do
        var otree_key = turn.game.trees.length.rand
        var original_tree = turn.game.trees[ otree_key ]
        
        var pos = original_tree.ground
        
        #print "seeding at {pos.position}"
       
        var e = new TermiteAppearanceEvent( pos )
        turn.events.add( e )
        
        # spawn termites
        var termite
        for i in [ 0 .. 30 [
        do
            termite = new Termite( pos )
            turn.game.buckets.add_at( termite, turn.tick+1 )
            turn.events.add( new TermiteBirthEvent( termite ) )
        end
        
        # prepare next outbreak
        var delai = 10000/turn.game.trees.length # 100+400 .rand
        if delai == 0 then delai = 1
        turn.act_in( self, delai )
    end
end

redef class Forest
    var termites : List[Termite] = new List[Termite]()
    
    redef fun react_to_event( e )
    do
        super( e )
        
        if e isa TermiteBirthEvent
        then
            termites.add( e.termite.as(not null) )
        else if e isa TermiteDeathEvent
        then
            termites.remove( e.termite.as(not null) )
        end
    end
    
    redef fun prepare
    do
        super
        
        var seeder = new RandomTermiteSeeder
        buckets.add_at( seeder, 1000 )
    end
end

class TermiteEvent
special GameEvent
end

class TermitePositionEvent
special TermiteEvent
special PositionEvent
    var termite : Termite
    redef fun pos do return termite.ground.position
end

class TermiteBirthEvent
special TermitePositionEvent
    init ( t : Termite ) do termite = t
end

class TermiteDeathEvent
special TermitePositionEvent
    init ( t : Termite ) do termite = t
end

class TermiteMoveEvent
special TermiteEvent
special MoveEvent
    var termite : Termite
    
    redef var from : Point
    redef var to : Point
    
    init ( ter : Termite, f : Point, t : Point )
    do
        termite = ter
        
        from = f
        to = t
    end
end

class TermiteAppearanceEvent
special TermiteEvent
special PositionEvent
    var ground : Node[ Tree ]
    
    redef fun pos do return ground.position
    
    init ( p : Node[ Tree ] ) do ground = p
end

