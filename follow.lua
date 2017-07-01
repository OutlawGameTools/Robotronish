-- Automagically Generated using Desperado - http://OutlawGameTools.com
--^Desperado:Asset Name follow


--[[
	
Follow (and avoid) Object
Posted by canupa.com, Posted on January 18, 2012, Last updated April 30, 2012
I ported this nice AS2 follow-object script by Philip Radvan
see the original post here http://www.freeactionscript.com/2009/04/enemy-behavior-run-away-follow-player/

	
--]]
--^Desperado:Libraries

-- forward references for local functions


-- variables
--^Desperado:Variables

-- functions


-- -------------------------------------------------------------------------------


local fin = {}
local radians = 180/math.pi  --> precalculate radians
 
fin.distanceBetween = function ( pos1, pos2 )
         local sqrt = math.sqrt
        if not pos1 or not pos2 then
                return
        end
        if not pos1.x or not pos1.y or not pos2.x or not pos2.y then
                return
        end
        local factor = { x = pos2.x - pos1.x, y = pos2.y - pos1.y }
        return sqrt( ( factor.x * factor.x ) + ( factor.y * factor.y ) )
end
 
 
 
fin.doFollow = function (follower, targetObject, missileSpeed, turnRate, doRotate, runAway)
 
        local missileSpeed = missileSpeed or 8
        local turnRate = turnRate or 0.8
      
        -- get distance between follower and target
        
        local target = targetObject
        
        local distanceX = target.x - follower.x;
        local distanceY = target.y - follower.y;
        
        -- get total distance as one number
        local distanceTotal = fin.distanceBetween (follower, target)
        
        -- calculate how much to move
         local moveDistanceX = turnRate * distanceX / distanceTotal;
         local moveDistanceY = turnRate * distanceY / distanceTotal;
        
        -- increase current speed
        follower.moveX = follower.moveX + moveDistanceX; 
        follower.moveY = follower.moveY + moveDistanceY;
                
        -- get total move distance
        local totalmove = math.sqrt(follower.moveX * follower.moveX + follower.moveY * follower.moveY);
        
        -- apply easing
        follower.moveX = missileSpeed*follower.moveX/totalmove;
        follower.moveY = missileSpeed*follower.moveY/totalmove;
        
        -- move follower (or runner)
        
        if runAway then
                follower.x = follower.x - follower.moveX;
                follower.y = follower.y - follower.moveY;
                if doRotate == true then
                  follower.rotation = math.atan2(follower.moveY, follower.xMove) * radians;
                end
        else
                follower.x = follower.x + follower.moveX;
                follower.y = follower.y + follower.moveY;
                if doRotate == true then
                  follower.rotation = (math.atan2(follower.moveY, follower.moveX) * radians)+180;
                end
        end
 
        -- !!!!! you got to check if we hit the target - here or in main game logic !!!!!
 
end
return fin
--^Desperado:misc code


-- -------------------------------------------------------------------------------

