
import termites_jack_ex
import thin_termites
import thin_lumberjacks

# basic redf to resolve conflicts
redef class Case
    redef fun to_s do return super
    redef fun draw( d, imgs, x, y ) do super
end

redef class ThinForest
    redef fun react_to_event( e ) do super
end

