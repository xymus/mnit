module assets

import app
import display

interface Asset
end

redef class String
	super Asset
end

redef interface Image
	super Asset
end

redef class App
	fun load_asset( id : String ) : Asset
	do
		var asset = try_loading_asset( id )
		if asset == null then # error
			log_error( "asset <{id}> could not be loaded." )
			exit(1)
			abort
		else
			return asset
		end
	end

	fun load_image( id : String ) : Image
	do
		var asset = load_asset( id )
		if asset isa Image then
			return asset
		else
			log_error( "asset <{id}> is not an image." )
			exit(1)
			abort
		end
	end

	fun try_loading_asset( id : String ) : nullable Asset is abstract
end

