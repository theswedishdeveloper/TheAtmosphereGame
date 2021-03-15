local greenColorRGB = {0, 1, 0, 1}
local redColorRGB = {255, 0, 0, 1}
local grayColorRGB = {50, 50, 50, 1}
local backgroundImage
local backgroundY
local backgroundY2
local fallSpeed = 12
local score = 0
local playerX
local playerY
local playerSize = 30
local moveSpeed = 8
local playerVelocity = 2
local playerOutSideOffset = 4
local obstaclesCount = 10 -- Must not be too big and freezes the game
local obstaclePositions = {}
local obstacleMaxSpeed = 5
local obstacleMinSpeed = 2
local obstacleMaxSize = 30
local obstacleMinSize = 10
local isGameOver = false

function love.load()
    print("The epic Atmosphere Game is loading...")
    backgroundImage = love.graphics.newImage("assets/sky.jpg")
    backgroundY = 0
    backgroundY2 = -backgroundImage:getHeight()
    -- Spawn in center of the screen
    playerX = love.graphics.getWidth() / 2 - playerSize / 2
    playerY = love.graphics.getHeight() / 2 - playerSize / 2
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("The Atmosphere Game")
    print("Game successfully loaded!")
    print("Have Fun!")
    print("Created by Benjamin Ojanne")
end

function love.draw()

    local Font = love.graphics.newFont("assets/OpenSans-Bold.ttf", 24)
    love.graphics.setFont(Font)
    -- Draw the background
    love.graphics.draw(backgroundImage, 0, backgroundY)
    love.graphics.draw(backgroundImage, 0, backgroundY2)
    -- Draw your score on the screen
    love.graphics.print({grayColorRGB, ("Score: "), greenColorRGB, (" " .. score)}, 50, 50)
    love.graphics.setColor(grayColorRGB)
    -- Draw obstacles
    for i = 1, #obstaclePositions do
        love.graphics.circle("fill", obstaclePositions[i][1],
                             obstaclePositions[i][2], obstaclePositions[i][3])
    end
    -- Reset colors
    resetScreenColors()
    -- Draw player
    love.graphics.setColor(greenColorRGB)
    love.graphics.circle("fill", playerX, playerY, playerSize, playerSize)
    -- Reset colors
    resetScreenColors()

    -- Show game over screen if needed.
    if (isGameOver) then
        love.graphics.print({redColorRGB, ("PRESS R TO RESTART")}, 50, 100)
    end

end

function resetScreenColors() love.graphics.setColor(255, 255, 255) end

-- Update function
function love.update(dt)

    -- If the game is over, return!
    if (isGameOver) then return false end

    -- This handles the smooth background scrolling behavior.
    backgroundY = backgroundY + fallSpeed
    backgroundY2 = backgroundY2 + fallSpeed
    if (backgroundY >= backgroundImage:getHeight()) then backgroundY = 0 end
    if (backgroundY2 >= 0) then backgroundY2 = -backgroundImage:getHeight() end

    -- If the player is located at the bottom of the screen give twice as fast points.
    if (playerY > love.graphics.getHeight() / 2) then score = score + 1 end

    -- If hold right key, move player right
    if love.keyboard.isDown("right") then playerX = playerX + moveSpeed end

    -- If hold left key, move player left
    if love.keyboard.isDown("left") then playerX = playerX - moveSpeed end

    -- If hold isDown key, move player down
    if love.keyboard.isDown("down") then playerY = playerY + moveSpeed end

    -- If hold isDown key, move player up
    if love.keyboard.isDown("up") then
        if (playerY + playerSize / 2 > 0) then
            playerY = playerY - moveSpeed
        end
    end

    -- If player gets outside of the screen on the right side then sent the player to left side.
    if playerX >= love.graphics.getWidth() then
        playerX = -playerSize + playerOutSideOffset
    end

    -- If player gets outside of the screen on the left side then sent the player to right side.
    if playerX <= -playerSize - playerOutSideOffset then
        playerX = love.graphics.getWidth()
    end

    -- check if have spawned required amount of obstacles
    local obstaclesSpawned = #obstaclePositions

    -- Check if more obstacles need to be spawned
    if obstaclesSpawned < obstaclesCount then
        while obstaclesSpawned <= obstaclesCount do
            local size = getRandomObstacleSize()
            local speed = getRandomObstacleSpeed()
            local position = getNewObstaclePosition(size)
            local Y = getRandomObstacleYPosition()
            obstaclePositions[obstaclesSpawned] = {position, Y, size, speed}
            obstaclesSpawned = obstaclesSpawned + 1
        end
    end

    -- Move all obstacles
    for ii = 1, #obstaclePositions do
        obstaclePositions[ii][2] = obstaclePositions[ii][2] -
                                       obstaclePositions[ii][4]
        obstaclePositions[ii][2] = obstaclePositions[ii][2] -
                                       obstaclePositions[ii][4]
    end

    -- Check if obstacles need to be respawned
    for ii = 1, #obstaclePositions do
        local obstacleYPos = obstaclePositions[ii][2]
        local obstacleSpeed = obstaclePositions[ii][3]
        if (obstacleYPos < -2 * obstacleSpeed) then
            -- Respawn obstacle
            obstaclePositions[ii][4] = getRandomObstacleSpeed()
            obstaclePositions[ii][3] = getRandomObstacleSize()
            obstaclePositions[ii][1] = getNewObstaclePosition(
                                           obstaclePositions[ii][3])
            obstaclePositions[ii][2] = getRandomObstacleYPosition()
        end
    end

    -- Check if the player has collided with a obstacles
    for ii = 1, #obstaclePositions do
        if calculateDistance(playerX, playerY, playerSize,
                             obstaclePositions[ii][1], obstaclePositions[ii][2],
                             obstaclePositions[ii][3]) then
            -- Game is over!
            isGameOver = true
            -- play sound effect
            local src = love.audio.newSource("assets/explosion.mp3", "static")
            src:setVolume(1)
            src:setPitch(0.85)
            src:play()
        end
    end

    -- Add some velocity to the player
    playerY = playerY + playerVelocity
    -- Increase score count with 1
    score = score + 1

end

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

function love.keypressed(key)
    -- Exit the game if press "ESC"
    if key == "escape" then love.event.quit() end
    -- Restart the game if press "R"
    if key == "r" then love.event.quit("restart") end
end

