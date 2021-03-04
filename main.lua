local green = {0, 1, 0, 1}
local background;
local background_y
local background_y_2
local fallSpeed = 6
local score = 0
local playerX
local playerY
local playerSize = 50
local moveSpeed = 5
local playerOutSideOffset = 4;

function love.load()
    print("Game loading...")
    background = love.graphics.newImage("assets/sky.jpg")
    background_y = 0
    background_y_2 = background:getHeight()
    playerX = love.graphics.getWidth() / 2 - playerSize / 2;
    playerY = 100
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("The ")
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

function love.update(dt)
--This piece of code handle the smooth background scrolling behavior.
background_y = background_y - fallSpeed
background_y_2 = background_y_2 - fallSpeed
 if(background_y < -background:getHeight())
 then background_y = 0 end if(background_y_2 < 0)
  then background_y_2 = background:getHeight() end
     --Add 1 to the score count
     score = score + 1
     --If hold right key, move player right
     if love.keyboard.isDown("right") then
        playerX = playerX + moveSpeed end
        --If hold left key, move player left
        if love.keyboard.isDown("left") then
            playerX = playerX - moveSpeed end
        --If hold isDown key, move player down
        if love.keyboard.isDown("down") then
            playerY = playerY + moveSpeed end
        --If hold isDown key, move player up
        if love.keyboard.isDown("up") then
            playerY = playerY - moveSpeed end
      --If player gets outside the screen on the right side, sent player to left side.
      if playerX > love.graphics.getWidth() then
        playerX = -playerSize + playerOutSideOffset; end
      --If player gets outside the screen on the left side, sent player to right side.
      if playerX < -playerSize - playerOutSideOffset then
        playerX = love.graphics.getWidth(); end
end

function love.keypressed(key, scancode, isrepeat)
   --Exit game if press "ESC"
   if key == "escape" then
      love.event.quit() end
end