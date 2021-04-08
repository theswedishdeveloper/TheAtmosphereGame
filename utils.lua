function resetScreenColors() love.graphics.setColor(255, 255, 255) end

function getRandomObstacleYPosition()
    return love.graphics.getHeight() +
               math.random(love.graphics.getHeight(),
                           love.graphics.getHeight() * 4)
end

function getRandomObstacleXPosition()
    local newPos = 0
    -- Check that there is no other obstacles that has same X to prevent the obstacles from collidate with each other.
    while newPos == 0 do
        local newPos2 = math.random(0, love.graphics.getWidth())
        local foundObstacleInThatRange = false
        for ii = 1, #OBSTACLES do
            if newPos2 - 25 < OBSTACLES[ii].x and newPos2 + 25 > OBSTACLES[ii].x then
                foundObstacleInThatRange = true
            end
        end
        if (foundObstacleInThatRange == false) then newPos = newPos2 end
    end
    return newPos
end

function getRandomObstacleSpeed()
    return math.random(obstacleMinSpeed, obstacleMaxSpeed)
end

function getRandomObstacleSize()
    return math.random(obstacleMinSize, obstacleMaxSize)
end

function getRandomObstacleDesign() return math.random(1, 4) end

function getRandomObstacleRotation() return math.random(50, 150) end

function overlap(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function getRandomObstacleDirectionSpeed() 
    return math.random(obstacleMinDirectionSpeed, obstacleMaxDirectionSpeed) 
end

function getRandomObstacleDirection() 
  local right = math.random(0, 1) == 1
    if(right) then
       return "right"
    else 
       return "left"
    end
end
