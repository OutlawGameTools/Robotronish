-- Automagically Generated using Desperado - http://OutlawGameTools.com
--^Desperado:Asset Name globals

--^Desperado:Libraries

-- forward references for local functions


-- variables
--^Desperado:Variables

-- functions
--^Desperado:round
function round(num,  numDecimalPlaces)

	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
	
	
end
--^Desperado:round



-- -------------------------------------------------------------------------------


local g = {}

g.currLevel = 1

return g
--^Desperado:misc code


-- -------------------------------------------------------------------------------

