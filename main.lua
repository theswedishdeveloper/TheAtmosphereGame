-- function love.draw()
-- draw background
--  love.graphics.setBackgroundColor(backgroundColor[0], 
-- backgroundColor[1], backgroundColor[2], backgroundColor[3])
-- draw plattform
-- love.graphics.rectangle("fill", 0, 
-- love.graphics.getHeight() - 50, love.graphics.getWidth(), 50)
-- draw player
-- love.graphics.rectangle("fill", playerX, playerY, 30, 30)
-- end
local green = {0, 1, 0, 1}
local background;
local background_y
local background_y_2
local fallSpeed = 4
local score = 0
local playerX
local playerY
local playerSize = 50

function love.load()
    print("Game loading...")
    background = love.graphics.newImage("assets/sky.jpg")
    background_y = 0
    background_y_2 = background:getHeight()
    playerX = love.graphics.getWidth() / 2 - playerSize / 2;
    playerY = 100
    love.graphics.setDefaultFilter("nearest", "nearest")
    print("Game successfully loaded.")
end

function love.draw()
    --Draw the background
    love.graphics.draw(background, 0, background_y)
    love.graphics.draw(background, 0, background_y_2)
    --Draw your score on the screen
    love.graphics.print({green, ("Your Score: "..score)}, 10, 10)
    --Draw player
    love.graphics.rectangle("fill", playerX, playerY, playerSize, playerSize)
end

function love.update()
--This piece of code handle the smooth background scrolling behavior.
background_y = background_y - fallSpeed
background_y_2 = background_y_2 - fallSpeed
 if(background_y < -background:getHeight())
 then background_y = 0 end if(background_y_2 < 0)
  then background_y_2 = background:getHeight() end
  --Add 1 to score
  score = score + 1

  
end

