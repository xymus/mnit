module dino_linux

import app

import linux

redef class ImageSet
	redef fun start_over_path do return "images/play_again.png"
end

redef class SplashScreen
	redef fun splash_play_path do return "images/splash_play.png"
end

super
