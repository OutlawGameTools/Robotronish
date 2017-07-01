--In case you forgot to add these libraries, I did it for you. Love, Desperado.
local sqlite3 = require("sqlite3")
-----------------------------------------------------
-- Project: OGT Lib
-- Description: Utilities to use to create cool games and apps
--
-- Version: 1.0
-- Managed with http://OutlawGameTools.com
--
-- Copyright 2011-2016 J. A. Whye. All Rights Reserved.
--

--[[

function ogt.bringToFront(obj)
function ogt.coinToss(weighted)
function ogt.columnExists(dbase, tbl, col)
function ogt.commaValue(amount)
function ogt.convHexColor(hex)
function ogt.linePrinter(t, xStart, yStart, grp)
function ogt.loadTextFile( filename, base )
function ogt.makeDriftingText(txt, opts)
function ogt.prnt(msg)
function ogt.setRP(object, rp)
function ogt.setUpDatabase(dbName)
function ogt.tableExists(dbase, tbl)
function ogt.trim (s)

--]]

-- most commonly used screen coordinates
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.viewableContentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.viewableContentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight
local screenTopSB = screenTop + display.topStatusBarContentHeight -- when status bar is showing
local screenHeightSB = display.viewableContentHeight - screenTopSB
local screenBottomSB = screenTopSB + screenHeightSB

local mAbs = math.abs
local mCeil = math.ceil
local mFloor = math.floor
local mSin = math.sin
local mCos = math.cos
local mSqrt = math.sqrt
local mRandom = math.random( )

math.randomseed( os.time() )

local ogt = {}

ogt.isSimulator = ("simulator" == system.getInfo("environment"))

function ogt.bringToFront(obj)
	obj.parent:insert( obj )
end

---============================================================
-- from http://spiralcodestudio.com/corona-sdk-pro-tip-of-the-day-13/
-- Instead of using anchorX and anchorY you can
-- set the "reference point" with setRP(obj, "TopLeft") or
-- pass in a table holding the x/y values like: setRP(obj, {.75, .25})

local referencePoints = {
    TopLeft      = {0, 0},
    TopRight     = {1, 0},
    TopCenter    = {0.5, 0},
    BottomLeft   = {0, 1},
    BottomRight  = {1, 1},
    BottomCenter = {0.5, 1},
    CenterLeft   = {0, 0.5},
    CenterRight  = {1, 0.5},
    Center       = {0.5, 0.5}
}
function ogt.setRP(object, rp)
    local anchor = referencePoints[rp] or rp
    if anchor and #anchor == 2 then
        object.anchorX, object.anchorY = anchor[1], anchor[2]
    else
        print('ERROR: No such reference point: ' .. tostring(rp) )
    end
end
function ogt.setAP(object, rp)	-- just an alias
	ogt.setRP(object, rp)
end

---============================================================
-- Get a random true or false.
-- Pass in optional parameter to get a weighted return.
-- Example: coinToss(63) for a 63% chance to return true.

function ogt.coinToss(weighted)
	local w = weighted or 50
	local result = mRandom
	return result <= w/100
end


--[[ =========================================
Convert Hex Color to Decimal
Pass in a hex string such as "FF00EE" and
get back the three RGB values (0-1) for
setFillColor, etc.
--==========================================]]
function ogt.convHexColor(hex)
  local r = hex:sub(1, 2)
  local g = hex:sub(3, 4)
  local b = hex:sub(5, 6)
  return tonumber(r, 16)/255, tonumber(g, 16)/255, tonumber(b, 16)/255
end


---============================================================
-- add comma to separate thousands
--
function ogt.commaValue(amount)
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

--[[
local fields = {
	{"My Cool App", size=18, color={255/255,0/255,0/255}, align="center", font="Marker Felt" },
	{"By A. N. Onymous", align="center"},
	{" "},
	{"Version " .. versionNumber, size=11},
	{" "},
	{"Something else...", align="right"},
	}
linePrinter(fields, screenLeft + 10, screenTopSB, scrollView)
--]]

function ogt.linePrinter(t, xStart, yStart, grp)

	local lineSpacing = 18
	local xLoc = xStart
	local yLoc = yStart
	local idx = 1
	local fontSize = 14
	local fontFace = "Helvetica"
	local lineColor

	for i = 1, #t do
		if t[i][1] ~= nil and t[i][1] ~= "" then

			fontSize = t[i]["size"] or 14
			fontFace = t[i]["font"] or "Helvetica"
			lineColor = t[i]["color"] or {0,0,0}

			local txt = display.newText( t[i][1], xLoc, yLoc + ((idx - 1) * lineSpacing), fontFace, fontSize )
			txt.anchorX = 0
			txt:setFillColor ( lineColor[1], lineColor[2], lineColor[3] )
			lineSpacing = fontSize + 4

			if t[i]["align"] ~= nil then
				if t[i]["align"] == "center" then
					txt.anchorX = .5
					txt.anchorY = .5
					txt.x = screenWidth / 2
				elseif t[i]["align"] == "right" then
					txt.anchorX = 1
					txt.x = screenWidth - xLoc
				end
			end

			if grp then
				grp:insert(txt)
			end
			idx = idx + 1
		end
	end
end

--[[ =========================================

makeDriftingText("Hop to Here!", {del=1000, t=4000, x=tX, y=tY, yVal=20, grp=dGroup} )

--==========================================]]
ogt.isDrifting = 0

function ogt.makeDriftingText(txt, opts)

	local opts = opts
	local function killDTxt(obj)
		display.remove(obj)
		obj = nil
		ogt.isDrifting = ogt.isDrifting - 1
	end
	local dTime = opts.t or 500
	local del = opts.del or 0
	local yVal = opts.yVal or 40
	local fontFace = opts.fontFace or "Helvetica"
	local fontSize = opts.fontSize or 18
	local dTxt = display.newText(txt, 0, 0, fontFace, fontSize)
	dTxt:toFront()
	dTxt.x = opts.x
	dTxt.y = opts.y
	if opts.grp then
		opts.grp:insert(dTxt)
	end
	transition.to(dTxt, { delay=del, time=dTime, y=opts.y-yVal, alpha=0, onComplete=killDTxt} )
	ogt.isDrifting = ogt.isDrifting + 1

end


---============================================================
-- trim whitespace from left and right of string
--
function ogt.trim (s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end


--=====================================================
-- database functions
--=====================================================

function ogt.setUpDatabase(dbName)

	local isSimulator = "simulator" == system.getInfo("environment")

	local path = system.pathForFile( dbName, system.DocumentsDirectory )
	local file = io.open( path, "r" )

	--if( file == nil or isSimulator )then
	if( file == nil )then
		-- copy the database file if doesn't exist or if we're in the Simulator
		local pathSource     = system.pathForFile( dbName, system.ResourceDirectory )
		local fileSource     = io.open( pathSource, "r" )
		local contentsSource = fileSource:read( "*a" )

		local pathDest = system.pathForFile( dbName, system.DocumentsDirectory )
		local fileDest = io.open( pathDest, "w" )
		fileDest:write( contentsSource )

		io.close( fileSource )
		io.close( fileDest )
	end

	local gameDB = system.pathForFile(dbName, system.DocumentsDirectory)
	local dbNew = sqlite3.open( gameDB )

	return dbNew

end

--[[ =========================================
Pass in database, table and column name
Returns true or false depending on whether column exists
--==========================================]]
function ogt.columnExists(dbase, tbl, col)
	local sql = [[select * from ]] .. tbl .. [[ limit 1;]]
	local stmt = dbase:prepare(sql)
	local tb = stmt:get_names()
	local found = false
	for v = 1, stmt:columns() do
		if tb[v] == col then
			found = true
		end
	end
	return found
end

--[[ =========================================


--==========================================]]
function ogt.tableExists(dbase, tbl)

	local found=false
	dbase:exec([[select * from sqlite_master where name= ]] .. tbl .. [[;]],
		function(...)
		print(...)
		found=true
		return 0
		end)
	return found

end

--[[ =========================================


--==========================================]]

-- load a text file and return it as a string
function ogt.loadTextFile( filename, base )
	-- set default base dir if none specified
	if not base then base = system.ResourceDirectory; end

	-- create a file path for corona i/o
	local path = system.pathForFile( filename, base )

	-- will hold contents of file
	local contents

	-- io.open opens a file at path. returns nil if no file found
	local file = io.open( path, "r" )
	if file then
	   -- read all contents of file into a string
	   contents = file:read( "*a" )
	   io.close( file )	-- close the file after using it
	end

	return contents
end


--=============================================================
-- use print() if we're in the simulator, otherwise
-- post to a URL
function ogt.prnt(msg)
  -- do return end -- uncomment this for production build
  if ogt.isSimulator then
    print(msg)
  else
    local postURL = "http://requestb.in/1fpzz7f1" --"http://www.postbin.org/mo3kzk"
    local function networkListener( event )
      -- nada because if not in sim won't ever see it
    end
    local params = {}
    params.body = msg
    network.request( postURL, "POST", networkListener, params)
  end
end

--===============================================================
-- NO FUNCTIONS BELOW HERE!
--===============================================================

return ogt
