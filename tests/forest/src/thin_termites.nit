import mnit

import grid
import termites
import thin_forest

redef class Case
	var termite_count : Int writable = 0

	redef fun to_s
	do
		var s = super

		if termite_count > 0 then
			return "\e[0;31m{s}\e[0m"
		else
			return s
		end
	end

	redef fun draw( display : Display, imgs : HashMap[String,Image],
			  x, y : Int )
	do
		super

		if termite_count > 0 then
			var c : Int = 8
			if termite_count < c then
				c = termite_count
			end

			display.blit( imgs["termites{c}"], x, y )
		end
	end
end

redef class ThinForest
	redef fun react_to_event( e )
	do
		if e isa ThinTermiteEvent then
			if e isa ThinTermiteMoveEvent then
				if in_sight( e.from ) then
					local_case_for( e.from ).termite_count -= 1
				end
				if in_sight( e.to ) then
					local_case_for( e.to ).termite_count += 1
				end
			else if e isa ThinTermiteBirthEvent then
				var p = e.pos
				if in_sight( p ) then
					local_case_for( p ).termite_count += 1
				end
			else if e isa ThinTermiteDeathEvent then
				var p = e.pos
				if in_sight( p ) then
					local_case_for( p ).termite_count -= 1
				end
			end
		else
			super( e )
		end
	end
end


class ThinTermiteEvent
	super GameEvent
end

class ThinTermiteBirthEvent
	super ThinTermiteEvent
	super ThinPositionEvent
end

class ThinTermiteDeathEvent
	super ThinTermiteEvent
	super ThinPositionEvent
end

class ThinTermiteMoveEvent
	super ThinTermiteEvent
	super ThinMoveEvent
end

class ThinTermiteAppearanceEvent
	super ThinTermiteEvent
	super ThinPositionEvent
end

