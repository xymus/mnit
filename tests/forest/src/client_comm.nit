
import serialize

import thin_termites_jack

### ThinEvents
redef class ThinPositionEvent
    fun load ( stream : DeserializationStream )
    do
        pos = new Point( stream.read_int, stream.read_int )
    end
end

redef class ThinMoveEvent
    fun load ( stream : DeserializationStream )
    do
        to = new Point( stream.read_int, stream.read_int )
        from = new Point( stream.read_int, stream.read_int )
    end
end

redef class ThinTreeDeathEvent
    init deserialize ( stream : DeserializationStream )
    do
        load( stream )
        
        cut = stream.read_bool
    end
end

redef class ThinTreeFallEvent
    init deserialize ( stream : DeserializationStream )
    do
        load( stream )
    end
end

redef class ThinTreeBirthEvent
    init deserialize( stream : DeserializationStream )
    do
        load( stream )
        
        growth_rate = stream.read_float
    end
end

redef class ThinTreeGrowthStopEvent
    init deserialize( stream : DeserializationStream )
    do
        load( stream )
    end
end

redef class ThinLumberjackBirthEvent
    init deserialize( stream : DeserializationStream )
    do
        load( stream )
    end
end

redef class ThinLumberjackMoveEvent
    init deserialize( stream : DeserializationStream )
    do
        load( stream )
    end
end

redef class ThinLumberjackWorkEvent
    init deserialize( stream : DeserializationStream )
    do
        load( stream )
        
        begins = stream.read_bool
    end
end

redef class ThinTermiteBirthEvent
    init deserialize( stream : DeserializationStream )
    do
        load( stream )
    end
end

redef class ThinTermiteDeathEvent
    init deserialize( stream : DeserializationStream )
    do
        load( stream )
    end
end

redef class ThinTermiteMoveEvent
    init deserialize( stream : DeserializationStream )
    do
        load( stream )
    end
end

redef class ThinTermiteAppearanceEvent
    init deserialize( stream : DeserializationStream )
    do
        load( stream )
    end
end


redef class DeserializationStream
    fun load_ForestEvent : nullable GameEvent
    do
        var name = read_string
        
        if name == "TDeath"
        then
            return new ThinTreeDeathEvent.deserialize( self )
        else if name == "TFall"
        then
            return new ThinTreeFallEvent.deserialize( self )
        else if name == "TBirth"
        then
            return new ThinTreeBirthEvent.deserialize( self )
        else if name == "TGrowthStop"
        then
            return new ThinTreeGrowthStopEvent.deserialize( self )
        else if name == "LBirth"
        then
            return new ThinLumberjackBirthEvent.deserialize( self )
        else if name == "LMove"
        then
            return new ThinLumberjackMoveEvent.deserialize( self )
        else if name == "LWork"
        then
            return new ThinLumberjackWorkEvent.deserialize( self )
        else if name == "terBirth"
        then
            return new ThinTermiteBirthEvent.deserialize( self )
        else if name == "terDeath"
        then
            return new ThinTermiteDeathEvent.deserialize( self )
        else if name == "terMove"
        then
            return new ThinTermiteMoveEvent.deserialize( self )
        else if name == "terAppear"
        then
            return new ThinTermiteAppearanceEvent.deserialize( self )
        #then if name == "terAppearance"
        #then
        else
            print "cannot deserialize \"{name}\""
            abort
        end
            
    #"Game"
    #"FirstTurn"
    #"Position"
    #"Move"
    #"Tree"
    #"Lumberjack"
    #"ter"
    #"terPosition"

    end
end

redef class ThinGameTurn[ G ]
    init deserialize( stream : DeserializationStream )
    do
        tick = stream.read_int
        
        events = new List[GameEvent]
        events.fill_from_not_null( stream ) !const( s ) = s.load_ForestEvent
    end
end

