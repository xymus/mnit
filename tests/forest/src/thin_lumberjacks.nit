module thin_lumberjacks

import thin_forest
import lumberjacks

redef class Case
	var lumberjack_count : Int writable = 0
	var worked_on_count : Int writable = 0

	redef fun to_s
	do
		var s = super

		if lumberjack_count > 0 then
			if s[0] == ' '
			then
				return "\e[0;34mL\e[0m"
			else
				return "\e[0;34m{s}\e[0m"
			end
		else if worked_on_count > 0 then
			return "\e[0;35m{s}\e[0m"
		else
			return s
		end
	end

	redef fun draw( display : Display, imgs : HashMap[String,Image],
			  x, y : Int )
	do
		if tree != null then
			if tree.cut then
				display.blit( imgs["trunk"], x, y )
			else
				super
			end
		end

		if lumberjack_count > 0 then
			display.blit( imgs["lumberjack"], x, y )
		end
	end
end

redef class ThinTree
	var cut : Bool = false
end

redef class ThinForest
	redef fun react_to_event( e )
	do
		if e isa ThinLumberjackEvent then
			if e isa ThinLumberjackBirthEvent then
				var p = e.pos
				if in_sight( p ) then
					local_case_for( p ).lumberjack_count += 1
				end
			else if e isa ThinLumberjackWorkEvent then
				var p = e.pos
				if in_sight( p ) then
					if e.begins then
						local_case_for( p ).worked_on_count += 1
					else
						local_case_for( p ).worked_on_count -= 1
					end
				end
			else if e isa ThinLumberjackMoveEvent then
				var from = e.from
				var to = e.to

				if in_sight( from ) then
					local_case_for( from ).lumberjack_count -= 1
				end

				if in_sight( to ) then
					local_case_for( to ).lumberjack_count += 1
				end
			end
		else
			super( e )

			if e isa ThinTreeDeathEvent then
				if e.cut then
					var p = e.pos

					if in_sight( p ) then
						var t = local_case_for( p ).tree

						if t != null then
							t.cut = true
						else
							abort
						end
					end
				end
			end
		end
	end
end


class ThinLumberjackEvent
special GameEvent
end

class ThinLumberjackBirthEvent
special ThinLumberjackEvent
special ThinPositionEvent
end

class ThinLumberjackMoveEvent
special ThinLumberjackEvent
special ThinMoveEvent
end

class ThinLumberjackWorkEvent
special ThinPositionEvent
	var begins : Bool writable
	fun ends : Bool do return not begins
	fun target : Point do return pos
end

redef class ThinTreeDeathEvent
	var cut : Bool writable = false
end
