local green = {0, 1, 0, 1}
local gray = {128, 128, 128, 1}
local background
local background_y
local background_y_2
local fallSpeed = 12
local score = 0
local playerX
local playerY
local playerSize = 30
local moveSpeed = 8
local playerVelocity = 2
local playerOutSideOffset = 4
local obstacles = 10 -- Must not be too big and freezes the game
local obstaclePositions = {}
local obstacleMaxSpeed = 5
local obstacleMinSpeed = 2
local obstacleMaxSize = 32
local obstacleMinSize = 15
local gameOver = false
local blinked = false

function love.load()
    print("Game loading...")
    background = love.graphics.newImage("assets/sky.jpg")
    background_y = 0
    background_y_2 = -background:getHeight()
    playerX = love.graphics.getWidth() / 2 - playerSize / 2
    playerY = 100
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("The Atmosphere Game")
    print("Game successfully loaded!")
end

function love.draw()
    -- Draw the background
    love.graphics.draw(background, 0, background_y)
    love.graphics.draw(background, 0, background_y_2)
    -- Draw your score on the screen
    love.graphics.print({green, ("Your Score: " .. score)}, 30, 30)
    love.graphics.setColor(gray)
    -- Draw obstacles
    for i = 1, #obstaclePositions do
        love.graphics.circle("fill", obstaclePositions[i][1],
                             obstaclePositions[i][2], obstaclePositions[i][3])
    end
    love.graphics.setColor(255, 255, 255) -- reset colours
    -- Draw player
    love.graphics.setColor(green)
    love.graphics.circle("fill", playerX, playerY, playerSize, playerSize)
    love.graphics.setColor(255, 255, 255) -- reset colours

    if (gameOver and blinked == false) then
        local a = math.abs(math.cos(love.timer.getTime() * 2 % 2 * math.pi))
        love.graphics.setColor(1, 1, 1, a)
        blinked = true
    end

end

function love.update(dt)
    -- If the game is over, return.
    if (gameOver) then return false end

    -- This piece of code handle the smooth background scrolling behavior.
    background_y = background_y + fallSpeed
    background_y_2 = background_y_2 + fallSpeed

    if (background_y >= background:getHeight()) then background_y = 0 end
    if (background_y_2 >= 0) then background_y_2 = -background:getHeight() end

    -- Add 1 to the score count
    score = score + 1

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
    -- If player gets outside the screen on the right side, sent player to left side.
    if playerX > love.graphics.getWidth() then
        playerX = -playerSize + playerOutSideOffset
    end
    -- If player gets outside the screen on the left side, sent player to right side.
    if playerX < -playerSize - playerOutSideOffset then
        playerX = love.graphics.getWidth()
    end
    -- check if have spawned required amount of obstacles
    local obstaclesSpawned = 0
    for i = 1, #obstaclePositions do obstaclesSpawned = obstaclesSpawned + 1 end
    -- Spawn more obstacles if needed.
    local i = obstaclesSpawned
    -- Check if need more obstacles.
    if obstaclesSpawned < obstacles then
        while i <= obstacles do
            local size = getNewObstacleSize()
            local speed = getNewObstacleSpeed()
            local position = getNewObstaclePosition(size)
            local Y = getNewObstacleYPosition()
            obstaclePositions[i] = {position, Y, size, speed}
            i = i + 1
        end
    end
    -- Caluclate the obstacles new positions
    for ii = 1, #obstaclePositions do
        obstaclePositions[ii][2] = obstaclePositions[ii][2] -
                                       obstaclePositions[ii][4]
        obstaclePositions[ii][2] = obstaclePositions[ii][2] -
                                       obstaclePositions[ii][4]
    end
    -- Check if obstacles need to be respawned.
    for ii = 1, #obstaclePositions do
        local obstacleYPos = obstaclePositions[ii][2]
        local obstacleSpeed = obstaclePositions[ii][3]
        if (obstacleYPos < -2 * obstacleSpeed) then
            -- Respawn obstacle
            obstaclePositions[ii][4] = getNewObstacleSpeed()
            obstaclePositions[ii][3] = getNewObstacleSize()
            obstaclePositions[ii][1] = getNewObstaclePosition(
                                           obstaclePositions[ii][3])
            obstaclePositions[ii][2] = getNewObstacleYPosition()
        end
    end
    -- Do collision check
    for ii = 1, #obstaclePositions do
        if collision(playerX, playerY, playerSize, obstaclePositions[ii][1],
                     obstaclePositions[ii][2], obstaclePositions[ii][3]) then
            gameOver = true
            -- play sound effect
            src1 = love.audio.newSource("assets/explosion.mp3", "static")
            src1:setVolume(1) -- 90% of ordinary volume
            src1:setPitch(0.9) -- one octave lower
            src1:play()
        end
    end

    -- Add some velocity to the player
    playerY = playerY + playerVelocity

end

function getNewObstacleYPosition()
    return love.graphics.getHeight() +
               math.random(love.graphics.getHeight(),
                           love.graphics.getHeight() * 3)
end

function getNewObstacleSpeed()
    return math.random(obstacleMinSpeed, obstacleMaxSpeed)
end

function getNewObstacleSize()
    return math.random(obstacleMinSize, obstacleMaxSize)
end

function getNewObstaclePosition(obstacleSize)
    local newPos = 0
    -- The obstacles cannot collide, check so that there is no obstacles on the same X
    while newPos == 0 do
        local newPos2 = math.random(obstacleSize,
                                    love.graphics.getWidth() - obstacleSize)
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

function collision(playerX, playerY, playerSize, obstacleX, obstacleY,
                   obstacleSize)
    local distance = math.sqrt((math.abs(playerX - obstacleX) ^ 2 +
                                   math.abs(playerY - obstacleY) ^ 2))
    if (distance - obstacleSize <= playerSize) then return true end
end

function love.keypressed(key)
    -- Exit game if press "ESC"
    if key == "escape" then love.event.quit() end
    -- Restart game if press "R"
    if key == "r" then love.event.quit("restart") end
end