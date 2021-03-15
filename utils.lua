function resetScreenColors() love.graphics.setColor(255, 255, 255) end

function getRandomObstacleYPosition()
    return love.graphics.getHeight() +
               math.random(love.graphics.getHeight(),
                           love.graphics.getHeight() * 3)
end

function getRandomObstacleSpeed()
    return math.random(obstacleMinSpeed, obstacleMaxSpeed)
end

function getRandomObstacleSize()
    return math.random(obstacleMinSize, obstacleMaxSize)
end

function getNewObstaclePosition(obstacleSize)
    local newPos = 0

    -- Check that there is no other obstacles that has same X to prevent the obstacles from collidate with each other.
    while newPos == 0 do
        local newPos2 = math.random(obstacleSize / 2,
                                    love.graphics.getWidth() - obstacleSize / 2)
        local foundObstacleInThatRange = false
        for ii = 1, #obstaclePositions do
            if newPos2 > obstaclePositions[ii][1] - obstacleSize and newPos2 <
                obstaclePositions[ii][1] + obstacleSize then
                foundObstacleInThatRange = true
            end
        end
        if (foundObstacleInThatRange == false) then newPos = newPos2 end
    end

    return newPos
end

function calculateDistance(playerX, playerY, playerSize, obstacleX, obstacleY,
                           obstacleSize)
    local distance = math.sqrt((math.abs(playerX - obstacleX) ^ 2 +
                                   math.abs(playerY - obstacleY) ^ 2))
    if (distance - obstacleSize <= playerSize) then
        return true
    else
        return false
    end
end
