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

# Defines abstract display classes
module display

import input_events

interface Sized
	fun width : Int is abstract
	fun height : Int is abstract
end

interface Image
	super Sized
	fun destroy is abstract

	#var scale : Float is abstract
	# scale this image when blit
	fun scale : Float is abstract
	fun scale=( v : Float ) is abstract

	#var blended : Bool is abstract
	# use blending on this image?
	fun blended : Bool is abstract
	fun blended=( v : Bool ) is abstract

	fun subimage( x, y, w, h : Int ) : Image is abstract
end

interface Drawable
	type I : Image

	fun begin is abstract
	fun finish is abstract
	fun set_viewport( x, y, w, h : Int ) is abstract

	fun blit( image : I, x, y : Int ) is abstract
	fun blit_centered( image : I, x, y : Int ) is abstract
	fun blit_rotated( image : I, x, y, angle : Float ) is abstract
	fun blit_rotated_scaled( image : I, x, y, angle, scale : Float ) is abstract
	fun blit_stretched( image : I, ax, ay, bx, by, cx, cy, dx, dy : Float )
		is abstract
end

interface Display
	super Sized
	super Drawable

	type IE : InputEvent
end

interface DrawableImage
	super Drawable
	super Image
end
