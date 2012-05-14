module dino_android

import app

import android

redef class ImageSet
	redef fun start_over_path do return "images/play_again_mobile.png"
end

redef class SplashScreen
	redef fun splash_play_path do return "images/splash_play_mobile.png"
end

redef class DinoApp
	redef fun init_window
	do
		super
	end
end

super
