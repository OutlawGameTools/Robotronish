-- Automagically Generated using Desperado - http://OutlawGameTools.com
--^Desperado:Asset Name about
local composer = require( "composer" )

local scene = composer.newScene()

--^Desperado:Libraries

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- forward references for local functions


-- variables
--^Desperado:Variables

-- functions


-- -------------------------------------------------------------------------------


function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

    --^Desperado:create scene

    	
	--^Desperado:create scene

end


function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    --^Desperado:show scene

    	
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
        	
	--^Desperado:will hide phase

    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.

        --^Desperado:did hide phase
        --^did hide scene
        	
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


-- -------------------------------------------------------------------------------

return scene
