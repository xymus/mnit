# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2011 Alexis Laferrière <alexis.laf@xymus.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Defines abstract classes to represent user inputs
module input_events

interface InputEvent
end

interface PointerEvent
	super InputEvent

	fun x : Float is abstract
	fun y : Float is abstract
	fun down : Bool is abstract
end

interface MotionEvent
	super InputEvent

	fun just_went_down : Bool is abstract
	fun down_pointer : nullable PointerEvent is abstract
end

interface TouchEvent
	super PointerEvent

	fun pressure : Float is abstract
end

interface KeyEvent
	super InputEvent

	fun is_down : Bool is abstract
	fun is_up : Bool is abstract

	fun is_arrow_up : Bool is abstract
	fun is_arrow_left : Bool is abstract
	fun is_arrow_down : Bool is abstract
	fun is_arrow_right : Bool is abstract

	fun code : Int is abstract
	fun to_c : nullable Char is abstract
end

interface MobileKeyEvent
	super KeyEvent

	fun is_back_key : Bool is abstract
	fun is_menu_key : Bool is abstract
	fun is_search_key : Bool is abstract
	fun is_home_key : Bool is abstract
end

# input to quit app event
# used for window close button
interface QuitEvent
	super InputEvent
end
