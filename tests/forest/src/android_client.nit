module android_client

import client
import android

redef class NfsApp
	# auto: accept linearisation conflict
	redef fun init_window do super
end

super
