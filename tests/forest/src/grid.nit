
class Point
    var x : Int
    var y : Int
    
    redef fun == ( o : nullable Object ) : Bool
    do
        return o isa Point and
            o.x == x and o.y == y
    end
    
    redef fun hash
    do
        return x * 65536 + y
    end
    
    redef fun to_s
    do
        return "({x},{y})"
    end
    
    fun up : Point do return new Point( x, y-1 )
    fun down : Point do return new Point( x, y+1 )
    fun left : Point do return new Point( x-1, y )
    fun right : Point do return new Point( x+1, y )
end

class Node[ E ]
    private var grid : Grid[ E ]
    var position : Point
    
    readable writable var _e : nullable E
    
    fun up : Node[ E ] do return grid.get_node_at( position.up )
    fun down : Node[ E ] do return grid.get_node_at( position.down )
    fun left : Node[ E ] do return grid.get_node_at( position.left )
    fun right : Node[ E ] do return grid.get_node_at( position.right )
    
    fun random_next : Node[ E ]
    do
        var r = 4.rand
        if r == 0
        then
            return up
        else if r == 1
        then
            return down
        else if r == 2
        then
            return left
        else return right
    end
    
    fun next_with : nullable Node[ E ]
        !cond(e: Node[E]) : Bool
    do
        var ns = new List[ Node[E] ]
        ns.add( up )
        ns.add( down )
        ns.add( left )
        ns.add( right )
        
        for n in ns
        do
            if cond( n )
            then
                return n
            end
        end
        
        return null
    end
    
    fun random_next_with : nullable Node[ E ]
        !cond(e: Node[E]) : Bool
    do
        var ns = new List[ Node[E] ]
        ns.add( up )
        ns.add( down )
        ns.add( left )
        ns.add( right )
        
        var s = new List[ Node[E] ]
        for n in ns
        do
            if cond( n )
            then
                s.add( n )
            end
        end
        
        if not s.is_empty
        then
            return s[ s.length.rand ]
        else
            return null
        end
    end
    
    fun squared_dist_with( n : Node[E] ) : Int
    do
        var dx = position.x - n.position.x
        var dy = position.y - n.position.y
        
        return dx*dx + dy*dy
    end
    
    fun next_toward( n : Node[E] ) : Node[E]
    do
        if n == self
        then
            abort
        else
            var closest_node : nullable Node[E] = null
            var closest_node_d : Int = 0
            
            for o in [ up, down, left, right ]
            do
                var d = n.squared_dist_with( o )
                if closest_node == null or
                   d < closest_node_d
                then
                    closest_node = o
                    closest_node_d = d
                end
            end
            
            return closest_node.as(not null)
        end
    end
end

class Grid[ E ]
    var nodes : HashMap[ Point, Node[ E ] ] = new HashMap[ Point, Node[ E ] ]()
    
    fun get_node_at( p : Point ) : Node[ E ] do return self[ p ]
    
    fun []( p : Point ) : Node[ E ]
    do
        var node : Node[ E ]
        
        if nodes.has_key( p )
        then
            node = nodes[ p ]
        else
            node = new Node[ E ]( self, p, null )
            nodes[ p ] = node
        end
        
        return node
    end
end


