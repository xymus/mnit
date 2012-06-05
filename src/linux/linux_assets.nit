module linux_assets

import mnit
import linux_app

redef class App
	var assets_dir : String

	redef init
	do
		print "mnit assets linux"

		assets_dir = sys.program_name.dirname + "/assets/"

		super
		print "mnit assets linux one"
	end

	redef fun try_loading_asset( id )
	do
		var path = "{assets_dir}/{id}"
		if not path.file_exists then
			log_error( "asset <{id}> does not exists." )
			exit(1)
			abort
		else
			var ext = path.file_extension
			if ext == "png" or ext == "jpg" or ext == "jpeg" then
				return new Opengles1Image.from_file( path )
			else if ext == "ttf" then
				return new FTGLFont.from_file( path )
			else # load as text
				var f = new IFStream.open(path)
				var content = f.read_all
				f.close

				return content
			end
		end
	end
end

