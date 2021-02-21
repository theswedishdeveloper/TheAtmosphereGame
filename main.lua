local backgroundColor  = {}
backgroundColor[0] = 0
backgroundColor[1] = 0
backgroundColor[2] = 0
backgroundColor[3] = 1

local enimiesCount = 10

local playerX = love.graphics.getWidth() / 2
local playerY = love.graphics.getHeight() - 90


function love.draw()
    --draw background
    love.graphics.setBackgroundColor(backgroundColor[0], 
    backgroundColor[1], backgroundColor[2], backgroundColor[3])
    --draw plattform
    love.graphics.rectangle("fill", 0, 
    love.graphics.getHeight() - 50, love.graphics.getWidth(), 50)
    --draw player
    love.graphics.rectangle("fill", playerX, playerY, 30, 30)
end

function love.update(dt)

    if(love.keyboard.isDown("a")) then
        playerX = 5 * dt - 5
    end

    if(love.keyboard.isDown("d")) then
        playerX = playerX + 5
    end

    if(love.keyboard.isDown("s")) then
        playerY = playerY + 5
    end

    if(love.keyboard.isDown("w")) then
        playerY = playerY - 5
    end
end
