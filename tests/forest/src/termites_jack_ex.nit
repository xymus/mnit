
# solves conflicts and adds interaction between termites and lumberjacks

import forest
import termites
intrude import lumberjacks

redef class Forest
    var afraid_of_termites : List[Lumberjack] = new List[Lumberjack]
    
    redef fun prepare
    do
        super
        
        for l in lumberjacks
        do
                print "b"
            #if 2 .rand == 0 # half of lumberjacks are afraid of termites
            #then
                afraid_of_termites.add( l )
            #end
        end
    end
    
    redef fun react_to_event( e )
    do
        super
        
        if e isa TermiteAppearanceEvent
        then
            var scary_termite_ground : Node[Tree] = e.ground
            
            for l in lumberjacks #afraid_of_termites
            do
                l.scare( self, scary_termite_ground )
            end
        end
    end
end

# bonuses
redef class Lumberjack
    var fleeing_to : nullable Node[Tree] = null
    
    redef fun do_turn( turn )
    do
        if fleeing_to != null
        then
            do_walk( turn )
        end
        
        super( turn )
    end
    
    redef fun do_walk( turn )
    do
        super( turn )
        
        if fleeing_to == ground
        then # there
            fleeing_to = null
        end
    end
    
    fun scare( forest : Forest, from : Node[Tree] )
    do
        var dx = from.position.x - ground.position.x
        var dy = from.position.y - ground.position.y
        
        if dx.abs > 10 then dx = 10 * (dx/dx.abs)
        if dy.abs > 10 then dy = 10 * (dy/dy.abs)
        
        if dx.abs < 10 and dy.abs < 10
        then # flee
            var target = new Point( ground.position.x-dx, ground.position.y-dy )
            
            #print "{self} scared from {ground.position} running to {target}"
            
            walking_to = forest.grid[ target ]
            fleeing_to = walking_to
        end
    end
end

