
import serialize
import termites_jack_ex

redef class GameEvent
special Serializable
    fun name : String do return ""
    redef fun dump_to( b )
    do
        name.dump_to( b )
    end
end

redef class PositionEvent
special Serializable
    redef fun name do return "PositionEvent"
    redef fun dump_to( b )
    do
        super
        
        pos.x.dump_to( b )
        pos.y.dump_to( b )
    end
end

redef class MoveEvent
    redef fun name do return "MoveEvent"
    redef fun dump_to( b )
    do
        super
        
        to.x.dump_to( b )
        to.y.dump_to( b )
        
        from.x.dump_to( b )
        from.y.dump_to( b )
    end
end

redef class TreeDeathEvent
    redef fun name do return "TDeath"
    redef fun dump_to( b )
    do
        super
        cut.dump_to( b )
    end
end

redef class TreeFallEvent
    redef fun name do return "TFall"
end

redef class TreeBirthEvent
    redef fun name do return "TBirth"
    redef fun dump_to( b )
    do
        super
        tree.growth_rate.dump_to( b )
    end
end

redef class TreeGrowthStopEvent
    redef fun name do return "TGrowthStop"
end

redef class LumberjackBirthEvent
    redef fun name do return "LBirth"
end

redef class LumberjackMoveEvent
    redef fun name do return "LMove"
end

redef class LumberjackWorkEvent
    redef fun name do return "LWork"
    redef fun dump_to( b )
    do
        super
        begins.dump_to( b )
    end
end

redef class TermiteBirthEvent
    redef fun name do return "terBirth"
end

redef class TermiteDeathEvent
    redef fun name do return "terDeath"
end

redef class TermiteMoveEvent
    redef fun name do return "terMove"
end

redef class TermiteAppearanceEvent
    redef fun name do return "terAppear"
end

