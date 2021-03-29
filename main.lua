require("options")
require("utils")
require("menu")
obstaclePositions = {} -- global variable
obstacleDesigns = {} -- global variable
FONT = nil
FONT_BIG = nil
local greenColorRGB = {0, 1, 0, 1}
local redColorRGB = {255, 0, 0, 1}
local grayColorRGB = {50, 50, 50, 1}
local backgroundImage
local backgroundY
local backgroundY2
local score = 0
local player = {}
local playerVelocity = 2
local playerOutSideOffset = 4
local isGameOver = false
local backgroundScaleFactor = 3
local isMusicPlaying = false
local musicTrack = nil
local isGameLoaded = false
local lookingLeft = false
local showGameMenu = true

function love.load()

    print("The epic Atmosphere Game is loading...")

    -- Window options
    FONT = love.graphics.newFont("assets/space_font.otf", 45)
    FONT_BIG = love.graphics.newFont("assets/space_font.otf", 90)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("The Atmosphere Game")
    love.window.setFullscreen(fullScreen)
    -- Initialize background
    backgroundImage = love.graphics.newImage("assets/photo-1518818419601-72c8673f5852.jfif")
    backgroundY = 0
    backgroundY2 = -backgroundImage:getHeight() * backgroundScaleFactor
    -- Get all obstacle images into an array
    for i = 1, 4 do
        obstacleDesigns[i] = {}
        obstacleDesigns[i].img = love.graphics.newImage(
                                     "assets/obstacles/obstacle" .. i .. ".png")
        obstacleDesigns[i].width = obstacleDesigns[i].img:getWidth()
        obstacleDesigns[i].height = obstacleDesigns[i].img:getHeight()
    end

    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 4
    player.img = love.graphics.newImage("assets/player.png")

    -- Setup game menu
    setupGameMenu()

    print("Game successfully loaded!")
    print("Have Fun!")
    print("Created by Benjamin Ojanne")

    isGameLoaded = true

end

function love.draw()

    love.graphics.setFont(FONT)

    -- Draw the background
    love.graphics.draw(backgroundImage, 0, backgroundY, 0,
                       backgroundScaleFactor, backgroundScaleFactor)
    love.graphics.draw(backgroundImage, 0, backgroundY2, 0,
                       backgroundScaleFactor, backgroundScaleFactor)

    -- Draw your score on the screen
    love.graphics.print({
        grayColorRGB, ("SCORE: "), greenColorRGB, (" " .. score)
    }, love.graphics.getHeight() * (1 / 10), love.graphics.getWidth() * (1 / 15))

    love.graphics.setColor(grayColorRGB)

    -- Draw obstacles
    for i = 1, #obstaclePositions do
        local x = obstaclePositions[i].x
        local y = obstaclePositions[i].y
        local size = obstaclePositions[i].size
        local design = obstaclePositions[i].design
        local rotation = obstaclePositions[i].rotation
        love.graphics.draw(obstacleDesigns[design].img, x, y, rotation,
                           obstacleScaleFactor * size,
                           obstacleScaleFactor * size,
                           obstacleDesigns[design].width / 2,
                           obstacleDesigns[design].height / 2)
    end

    -- Reset colors
    resetScreenColors()

    -- Game is not started, show menu and return.
    if (showGameMenu) then renderGameMenu() end

    -- Show game over screen if needed.
    if (isGameOver) then
        love.graphics.setFont(FONT_BIG)
        local gameOverText = " GAME OVER!"
        love.graphics.print({redColorRGB, (gameOverText)}, love.graphics
                                .getWidth() / 2 -
                                FONT_BIG:getWidth(gameOverText) / 2,
                            love.graphics.getHeight() / 7)
        return
    end

    if (showGameMenu) then return end

    -- Draw player
    local playerSize = playerScaleFactor

    if (lookingLeft == false) then playerSize = playerSize * -1 end

    love.graphics.draw(player.img, player.x, player.y, 0, playerSize,
                       math.abs(playerSize), player.img:getWidth() / 2,
                       player.img:getHeight() / 2)

    -- Reset colors
    resetScreenColors()

end

function resetGame()
    -- Reset player position
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 4
    -- Reset music by setting music track to nil
    musicTrack = nil
    isMusicPlaying = false
    -- Destroy all obstacles
    for k, v in pairs(obstaclePositions) do obstaclePositions[k] = nil end
    -- Reset score
    score = 0
end

-- Update function
function love.update(dt)

    -- If the game is over, return!
    if (isGameOver) then return end

    if (isGameLoaded == false) then return end

    -- This handles the smooth background scrolling behavior.
    backgroundY = backgroundY + fallSpeed
    backgroundY2 = backgroundY2 + fallSpeed
    if (backgroundY >= backgroundImage:getHeight() * backgroundScaleFactor) then
        backgroundY = 0
    end
    if (backgroundY2 >= 0) then
        backgroundY2 = -backgroundImage:getHeight() * backgroundScaleFactor
    end

    -- check if have spawned required amount of obstacles
    local obstaclesSpawned = #obstaclePositions

    -- Check if more obstacles need to be spawned
    if obstaclesSpawned < obstaclesCount then
        while obstaclesSpawned <= obstaclesCount do
            local size = getRandomObstacleSize()
            local speed = getRandomObstacleSpeed()
            local y = getRandomObstacleYPosition()
            local design = getRandomObstacleDesign()
            local rotation = getRandomObstacleRotation()
            local x = getRandomObstacleXPosition(size)
            obstaclePositions[obstaclesSpawned] = {}
            obstaclePositions[obstaclesSpawned].x = x
            obstaclePositions[obstaclesSpawned].y = y
            obstaclePositions[obstaclesSpawned].size = size
            obstaclePositions[obstaclesSpawned].speed = speed
            obstaclePositions[obstaclesSpawned].design = design
            obstaclePositions[obstaclesSpawned].rotation = rotation
            obstaclesSpawned = obstaclesSpawned + 1
        end
    end

    -- Move all obstacles
    for i = 1, #obstaclePositions do
        obstaclePositions[i].y = obstaclePositions[i].y -
                                     obstaclePositions[i].speed
    end

    -- Rotate all obstacles
    for i = 1, #obstaclePositions do
        local rotation = obstaclePositions[i].rotation
        if (rotation + obstacleRotationSpeed >= 360) then rotation = 0 end
        if (i % 2 == 0) then
            obstaclePositions[i].rotation = rotation - obstacleRotationSpeed
        else
            obstaclePositions[i].rotation = rotation + obstacleRotationSpeed
        end
    end

    -- Check if obstacles need to be respawned
    for ii = 1, #obstaclePositions do
        local obstacleYPos = obstaclePositions[ii].y
        if (obstacleYPos < -100) then
            -- Respawn obstacle
            obstaclePositions[ii].speed = getRandomObstacleSpeed()
            obstaclePositions[ii].size = getRandomObstacleSize()
            obstaclePositions[ii].x = getRandomObstacleXPosition(
                                          obstaclePositions[ii].size)
            obstaclePositions[ii].y = getRandomObstacleYPosition()
            obstaclePositions[ii].design = getRandomObstacleDesign()
            obstaclePositions[ii].rotation = getRandomObstacleRotation()
        end
    end

    if (enableMusic and isMusicPlaying == false) then
        -- Start music if not started
        if (musicTrack == nil) then
            musicTrack = love.audio.newSource("assets/music.mp3", "static")
            musicTrack:setVolume(musicVolume)
        end
        musicTrack:play()
        isMusicPlaying = true
    end

    -- Game is not started, return.
    if (showGameMenu) then return end

    -- If hold right key, move player right
    if love.keyboard.isDown("right") then
        player.x = player.x + moveSpeed
        lookingLeft = false
    end

    -- If hold left key, move player left
    if love.keyboard.isDown("left") then
        player.x = player.x - moveSpeed
        lookingLeft = true
    end

    -- If hold isDown key, move player down
    if love.keyboard.isDown("down") then player.y = player.y + moveSpeed end

    -- If hold isDown key, move player up
    if love.keyboard.isDown("up") then
        if (player.y > 0) then player.y = player.y - moveSpeed end
    end

    -- If player gets outside of the screen on the right side then sent the player to left side.
    if player.x - playerOutSideOffset >= love.graphics.getWidth() then
        player.x = 0
    end

    -- If player gets outside of the screen on the left side then sent the player to right side.
    if player.x + playerOutSideOffset <= 0 then
        player.x = love.graphics.getWidth()
    end

    -- Check if the player has collided with a obstacles
    for i = 1, #obstaclePositions do
        if overlap(player.x, player.y,
                   player.img:getWidth() * playerScaleFactor,
                   player.img:getHeight() * playerScaleFactor,
                   obstaclePositions[i].x, obstaclePositions[i].y,
                   obstacleDesigns[obstaclePositions[i].design].width *
                       obstacleScaleFactor, obstacleDesigns[obstaclePositions[i]
                       .design].height * obstacleScaleFactor) then
            -- Game is over!
            isGameOver = true
            showGameMenu = true
            -- play sound effect
            local src = love.audio.newSource("assets/explosion.mp3", "static")
            src:setVolume(1)
            src:setPitch(0.8)
            src:play()
            -- Pause music track
            musicTrack:pause()
        end
    end

    -- If the player is located at the bottom of the screen give twice as fast points.
    if (player.y > love.graphics.getHeight() / 2) then
        score = score + 2
    else
        score = score + 1
    end

    -- Add some velocity to the player
    player.y = player.y + playerVelocity

end

function startGame()
    if (isGameOver) then resetGame() end
    isGameOver = false
    showGameMenu = false
end

function love.keypressed(key)
    -- Exit the game if press "ESC"
    if key == "escape" then
        love.event.quit()
        -- Restart the game if press "R"
    elseif key == "r" then
        love.event.quit("restart")
    end
end

