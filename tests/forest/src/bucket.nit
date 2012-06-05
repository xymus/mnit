
class Turnable[ G : Game ]    
    fun do_turn( turn : GameTurn[ G ] ) is abstract
end

class Bucketable[ G : Game ]
special Turnable[ G ]
    private var act_at : Int = 0
end

class Buckets[ G : Game ]
special Turnable[ G ]
    type Bucket : HashSet[Bucketable[G]]

    private var buckets : Array[Bucket]
    
    var next_bucket : nullable Bucket = null
    var current_bucket_key : Int = -1
    
    init
    do
        var n_buckets = 100
        buckets = new Array[Bucket].with_capacity( n_buckets )
        
        for b in [ 0 .. n_buckets [
        do
            buckets[ b ] = new Bucket
        end
    end
    
    fun add_at( e : Bucketable[G], at_tick : Int )
    do
        var at_key = key_for_tick( at_tick )
        
        if at_key == current_bucket_key
        then
            next_bucket.as(not null).add( e )
        else
            buckets[ at_key ].add( e )
        end
        
        e.act_at = at_tick
    end
    
    private fun key_for_tick( at_tick : Int ) : Int
    do
        return at_tick % buckets.length
    end
    
    redef fun do_turn( turn : GameTurn[ G ] )
    do
        current_bucket_key = key_for_tick( turn.tick )
        var current_bucket = buckets[ current_bucket_key ]
        
        next_bucket = new Bucket
        
        for e in current_bucket
        do
            if e.act_at == turn.tick
            then
                e.do_turn( turn )
            else if e.act_at > turn.tick and
                key_for_tick( e.act_at ) == current_bucket_key
            then
                #print "{e} put in next bucket"
                next_bucket.as(not null).add( e )
            end
        end
        
        #current_bucket.clear
        buckets[ current_bucket_key ] = next_bucket.as(not null)
    end
end

class GameEvent
end

class FirstTurnEvent
special GameEvent
end

class ThinGameTurn[ G : Game ]
    var tick : Int protected writable = 0
    
    var events : List[ GameEvent ] protected writable = new List[ GameEvent ]()
    
    init ( t : Int )
    do
        tick = t
    end
end

class GameTurn[ G : Game ]
super ThinGameTurn[ G ]
    var game : G
    
    init ( g : G )
    do
        super( g.tick )
        game = g
    end
    
    fun act_next( e : Bucketable[G] )
    do
        game.buckets.add_at( e, tick + 1 )
    end
    
    fun act_in( e : Bucketable[G], t : Int )
    do
        game.buckets.add_at( e, tick + t )
    end
end

class Game
    type G : Game

    var tick : Int
    
    var buckets : Buckets[ G ]
    
    init
    do
        buckets = new Buckets[ G ]()
        tick = 0
    end

    fun do_turn : GameTurn[ G ]
    do
        var turn = new GameTurn[ G ]( self )
        
        do_pre_turn( turn )
        
        buckets.do_turn( turn )
        
        do_post_turn( turn )
      
        tick += 1
        
        return turn
    end
    
    fun do_pre_turn( turn : GameTurn[ G ] ) do end
    fun do_post_turn( turn : GameTurn[ G ] ) do end
end

