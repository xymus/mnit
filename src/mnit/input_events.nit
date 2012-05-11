# Defines abstract classes for user inputs
module input_events

# General type of inputs
interface InputEvent
end

# Mouse and touch input events
interface PointerEvent
	super InputEvent

	# X position on screen (in pixels)
	fun x : Float is abstract

	# Y position on screen (in pixels)
	fun y : Float is abstract

	# Is down? either going down or already down
	fun down : Bool is abstract
end

# Pointer motion event, mais concern many events
interface MotionEvent
	super InputEvent

	# A pointer just went down?
	fun just_went_down : Bool is abstract

	# Which pointer is down, if any
	fun down_pointer : nullable PointerEvent is abstract
end

# Specific touch event
interface TouchEvent
	super PointerEvent

	# Pressure level of input
	fun pressure : Float is abstract
end

# Keyboard or other keys event
interface KeyEvent
	super InputEvent

	# Key is currently down?
	fun is_down : Bool is abstract

	# Key is currently up?
	fun is_up : Bool is abstract

	# Key is the up arrow key?
	fun is_arrow_up : Bool is abstract

	# Key is the left arrow key?
	fun is_arrow_left : Bool is abstract

	# Key is the down arrow key?
	fun is_arrow_down : Bool is abstract

	# Key is the right arrow key?
	fun is_arrow_right : Bool is abstract

	# Key code, is plateform specific
	fun code : Int is abstract

	# Get Char value of key, if any
	fun to_c : nullable Char is abstract
end

# Mobile hardware (or pseudo hardware) event
interface MobileKeyEvent
	super KeyEvent

	# Key is back button? (mostly for Android)
	fun is_back_key : Bool is abstract

	# Key is menu button? (mostly for Android)
	fun is_menu_key : Bool is abstract

	# Key is search button? (mostly for Android)
	fun is_search_key : Bool is abstract

	# Key is home button? (mostly for Android)
	fun is_home_key : Bool is abstract
end

# Quit event, used for window close button
interface QuitEvent
	super InputEvent
end
