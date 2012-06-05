
## import any one of the 4 modules for different scenarios
import forest
#import termites
#import lumberjacks
#import termites_jack

var f = new Forest

for i in [ 0 .. 10000 [
do
    var turn : GameTurn[Forest] = f.do_turn
end

