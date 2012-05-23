module linux_displays

import displays
import linux

redef class Display
	redef fun wanted_width do return sys.w
	redef fun wanted_height do return sys.h
end

super
