-- config.lua for project: Robotronish
-- Using Desperado from http://OutlawGameTools.com
-- Copyright 2014 Three Ring Ranch. All Rights Reserved.

--calculate the aspect ratio of the device:
local aspectRatio = display.pixelHeight / display.pixelWidth

--application = {
--   content = {
--      width = aspectRatio > 1.5 and 800 or math.floor( 1200 / aspectRatio ),
--      height = aspectRatio < 1.5 and 1200 math.floor( 800 * aspectRatio ),
--      scale = "letterBox",
--      fps = 60,
--
--      imageSuffix = {
--         ["@2x"] = 1.3,
--      },
--   },
--}

application = {
   content = {
      scale = "adaptive",
      fps = 60,

      imageSuffix = {
         ["@2x"] = 1.5,
         ["@3x"] = 2.5,
      },
   },
}
