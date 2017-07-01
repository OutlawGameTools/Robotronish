--In case you forgot to add these libraries, I did it for you. Love, Desperado.
local widget = require("widget")
-----------------------------------------------------
-- Automagically Generated using Desperado - http://OutlawGameTools.com
--^Desperado:Asset Name score
local composer = require( "composer" )

local scene = composer.newScene()

local widget = require("widget")
widget.setTheme ( "widget_theme_ios" )
--^Desperado:Libraries

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- forward references for local functions
local goBack


-- variables
-- most commonly used screen coordinates
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.viewableContentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.viewableContentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight

local m = {
	abs = math.abs,
	atan = math.atan,
	ceil = math.ceil,
	cos = math.cos,
	deg = math.deg,
	floor = math.floor,
	pi = math.pi,
	rad = math.rad,
	random = math.random,
	sin = math.sin,
	sqrt = math.sqrt
}

local parent
--^Desperado:Variables

-- functions
--^Desperado:goBack
function goBack(event)

	if event.phase=="began" then 
		parent:resumeFromScore()
		composer.hideOverlay("fade")
	end 
	
	return true	
end
--^Desperado:goBack



-- -------------------------------------------------------------------------------


function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

    --^Desperado:create scene

    	
local tapBG = display.newRect( scene.view, centerX, centerY, screenWidth, screenHeight )
tapBG.alpha = .01
tapBG:addEventListener ( "tap", function() return true end )

local bg = display.newRect( scene.view, centerX, centerY, 240, 200 )
bg:setFillColor(1,1,1)
bg.alpha = .5

local backBtn = widget.newButton {
	label = "OK",
	onEvent = goBack,
	x = centerX,
	y = bg.y + bg.height/2 - 20,
	width = 50,
	height = 30
	}
scene.view:insert(backBtn)
	--^Desperado:create scene

end


function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    --^Desperado:show scene

    	
parent = event.parent
	--^Desperado:show scene

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        
        --^Desperado:will show phase
        --^will show scene
        	
	--^Desperado:will show phase

    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.

        --^Desperado:did show phase
        --^did show scene
        	
	--^Desperado:did show phase

    end
end


function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    --^Desperado:hide scene
    
    	
	--^Desperado:hide scene

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
        
        --^Desperado:will hide phase
        --^will hide scene
        	
print("score:will hide phase")

	--^Desperado:will hide phase

    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.

        --^Desperado:did hide phase
        --^did hide scene
        	
print("score:did hide phase")
	--^Desperado:did hide phase

    end
end


function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.

    --^Desperado:destroy scene
    	
	--^Desperado:destroy scene
    
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )


-- -------------------------------------------------------------------------------

return scene
