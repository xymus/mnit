# Manages all assets usable by an Mnit app
module assets

import app
import display

# General asset
interface Asset
end

# An String is an asset, returned from a text file
redef class String
	super Asset
end

# An Image is an asset
redef interface Image
	super Asset
end

redef class App
	# Load a genereal asset from file name
	# Will find the file within the assets/ directory
	# Crashes if file not found
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

	# Load an Image assets
	# Crashes if file not found or not an image
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

	# Load an assets without error if not found
	fun try_loading_asset( id : String ) : nullable Asset is abstract
end

