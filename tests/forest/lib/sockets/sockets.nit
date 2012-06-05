extern Writable
    # write string to socket
	fun write( s : String ) is abstract
end

extern Readable
    # attepts to read a string from the socket
	fun read : nullable String is abstract
end

# socket for communications
extern CommunicationSocket
super Pointer
super Readable
super Writable
    # create a new CommunicationSocket connected to the remote address and port
	new connect_to( address : String, port : Int ) is extern import String::to_cstring
	
	# return error string from last error
	fun error : nullable String is extern import String::from_cstring, String as nullable
	
	# close this socket
	fun close is extern
	
	redef fun read : nullable String is extern import String::from_cstring, String as nullable
	redef fun write( s : String ) is extern import String::to_cstring
end

# socket to accept incomming connections and open communication sockets
extern ListeningSocket
super Pointer
	# bind and listen to specified address and port
	new bind_to( address : String, port : Int ) is extern import String::to_cstring
	
	# return error string from last error
	fun error : nullable String is extern import String::from_cstring, String as nullable
	
	# close this socket
	fun close is extern
	
	# accept incoming connection whan available
	# non-blocking, returns null if no client is waiting
	# returns communication socket
	fun accept : nullable CommunicationSocket is extern import CommunicationSocket as nullable
end

