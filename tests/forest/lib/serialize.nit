
import sockets

interface Serializable
    # serializes the object in the buffer
    fun dump_to( buffer : Buffer ) is abstract
end

redef class Int
special Serializable
    # serializes where the 1st char is the length of the number.to_s, folled by data
    # current limitation, does not support ints longer than 9 chars in decimals
    # TODO implement in hex or better
    redef fun dump_to( buffer )
    do
        var s = self.to_s
        var l
        
        if s.length > 9
        then
            l = 9
            abort
        else l = s.length
            
        buffer.append( l.to_s )
        buffer.append( s.substring( 0, 9 ) )
    end
end

redef class Bool
special Serializable
    # serializes to 't' if true, else 'f' 
    redef fun dump_to( buffer )
    do # maxed at 10 chars
        if self
        then
            buffer.append( "t" )
        else
            buffer.append( "f" )
        end
    end
end

redef class Float
special Serializable
    # serializes where the 1st char is the length of the number.to_s, folled by data
    # current limitation, does not support floats longer than 9 chars in decimals
    # TODO implement in hex or better
    redef fun dump_to( buffer )
    do
        var s = self.to_s
        var l
        
        if s.length > 9
        then
            l = 9
        else l = s.length
            
        buffer.append( l.to_s )
        buffer.append( s.substring( 0, 9 ) )
    end
end

redef class String
special Serializable
    # serializes first the length of the string, then the data
    redef fun dump_to( buffer )
    do
        length.dump_to( buffer )
        buffer.append( self )
    end
end

redef class Sequence[ E ]
special Serializable
    # serializes first the length of the array, then the data
    redef fun dump_to( buffer )
    do
        length.dump_to( buffer )
        for e in self
        do
            if e isa Serializable
            then
                e.dump_to( buffer )
            end
        end
    end
    
    # uses a closure
    # change to inits when constructor specialisation is available
    fun fill_from( stream : DeserializationStream ) !const( s : DeserializationStream ) : E
    do
        #print "filling list"
        var count = stream.read_int
        #print "count {count}"
        
        for i in [ 0 .. count [
        do
            var e = const( stream )
            add( e )
        end
    end
    
    # uses a closure
    # change to inits when constructor specialisation is available
    fun fill_from_not_null( stream : DeserializationStream ) !const( s : DeserializationStream ) : nullable E
    do
        var count = stream.read_int
        
        for i in [ 0 .. count [
        do
            var e = const( stream )
            if e != null then add( e )
        end
    end
end

# disabled, using Buffer for now
#class SerializationStream
#end

# stream used for deserialization of objects
class DeserializationStream
    # reads from stream
    fun read( count : Int ) : String is abstract
    
    # peaks ahead on stream without moving pointer
    fun peak( count : Int ) : String is abstract
    
    # is at end of file?
    fun at_eof : Bool is abstract

    # reads an Int from the stream    
    # must be defined here since Int's cannot have inits
    # move when they have gets or something similar
    fun read_int : Int
    do
        var s = read( 1 )
        var size = s.to_i
        
        var i = read( size )
        
        return i.to_i
    end
    
    # reads a Float from the stream   
    fun read_float : Float
    do
        var s = read( 1 )
        var size = s.to_i
        
        var i = read( size )
        return i.to_f
    end
    
    # reads a Bool from the stream   
    fun read_bool : Bool
    do
        var s = read( 1 )
        
        if s == "t"
        then
            return true
        else if s == "f"
        then
            return false
        else
            print s
            abort
        end
    end
    
    # reads a String from the stream   
    fun read_string : String
    do
        var size = read_int
        var s = read( size )
        return s
    end
end

# minimal implementation of DeserializationStream using a string as buffer
# not to be used in production
class StringDeserializationStream
special DeserializationStream

    private var str : String
    private var position : Int = 0
    
    init ( s : String )
    do
        str = s
    end
    
    redef fun read( count )
    do
        var r = peak( count )
        position += count
        return r
    end
    
    redef fun peak( count )
    do
        return str.substring( position, count )
    end
    
    redef fun at_eof
    do
        return position >= str.length
    end
end

# deserialization stream based on a communication socket
# uses a String as a buffer and fetces extra data from socket
class SocketDeserializationStream
special DeserializationStream

    # buffer string
    private var str : nullable String = null
    
    # position in buffer
    private var position : Int = 0
    
    # communication socket
    private var conn : CommunicationSocket
    
    init ( c : CommunicationSocket )
    do
        conn = c
    end
    
    redef fun read( count )
    do
        var b = new Buffer
        
        while count > 0
        do
            var lstr = str
            if lstr != null
            then # already as buffer loaded
                var left = str.length - position
                
                if count > left
                then # read buffer and fetch more
                    
                    if left > 0
                    then
                        count -= left
                        b.append( peak( left ) )
                    end
                    
                    # get more
                    str = conn.read
                    position = 0
                else # everything needed is in buffer
                    b.append( peak( count ) )
                    position += count
                    count = 0
                end
            else # fill buffer
                str = conn.read
            end
        end
        
       #print "SDS result: {b.to_s}"
        return b.to_s
    end
    
    # bad implementation of peak
    # will only peak at what is already in the buffer
    redef fun peak( count )
    do
        return str.substring( position, count )
    end
    
    redef fun at_eof
    do
        return position >= str.length
    end
end

# tests

var b = new Buffer
34.dump_to( b )
0.0.dump_to( b )
true.dump_to( b )
false.dump_to( b )
"hello".dump_to( b )

print b.to_s

var s = new StringDeserializationStream( b.to_s )
print s.read_int
print s.read_float
print s.read_bool
print s.read_bool
print s.read_string

