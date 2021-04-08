require("options")
require("utils")
require("menu")
OBSTACLES = {} -- global variable
OBSTACLES_APPERANCE = {} -- global variable
FONT = nil
FONT_BIG = nil
local greenColorRGB = {0, 1, 0, 1}
local redColorRGB = {255, 0, 0, 1}
local grayColorRGB = {50, 50, 50, 1}
local backgroundImage
local backgroundY
local backgroundY2
local score = 0
local highScore = 0
local player = {}
local playerGravity = 2
local playerOutSideOffset = 4
local isGameOver = false
local backgroundScaleFactor = 2
local isMusicPlaying = false
local musicTrack = nil
local isGameLoaded = false
local lookingLeft = false
local showGameMenu = true
local gamePaused = false

function love.load()

    print("The epic Atmosphere game is loading...")

    --Hide mouse pointer on load
    love.mouse.setVisible(false)
    -- Window options
    FONT = love.graphics.newFont("assets/space_font.otf", 40)
    FONT_BIG = love.graphics.newFont("assets/space_font.otf", 80)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("The Atmosphere Game")
    love.window.setFullscreen(fullScreen)
    -- Initialize background
    backgroundImage = love.graphics.newImage("assets/sky.jpg")
    backgroundY = 0
    backgroundY2 = -backgroundImage:getHeight() * backgroundScaleFactor
    -- Get all obstacle images into an array
    for i = 1, 4 do
        OBSTACLES_APPERANCE[i] = {}
        OBSTACLES_APPERANCE[i].img = love.graphics.newImage(
                                     "assets/obstacles/obstacle" .. i .. ".png")
        OBSTACLES_APPERANCE[i].width = OBSTACLES_APPERANCE[i].img:getWidth()
        OBSTACLES_APPERANCE[i].height = OBSTACLES_APPERANCE[i].img:getHeight()
    end

    -- Initialize player
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 4
    player.img = love.graphics.newImage("assets/player.png")

    -- Setup game menu
    SETUP_GAME_MENU()

    --Load music track
    musicTrack = love.audio.newSource("assets/music.mp3", "static")
    musicTrack:setVolume(musicVolume)
    musicTrack:setLooping(true)

    print("Game successfully loaded!")
    print("Have Fun!")
    print("Created by Benjamin Ojanne 2021")

    --Show mouse pointer
    love.mouse.setVisible(true)

    isGameLoaded = true

end

function love.draw()

    love.graphics.setFont(FONT)

    -- Draw the background
    love.graphics.draw(backgroundImage, 0, backgroundY, 0,
                       backgroundScaleFactor, backgroundScaleFactor)

    love.graphics.draw(backgroundImage, 0, backgroundY2, 0,
                       backgroundScaleFactor, backgroundScaleFactor)

    -- Draw your high score on the screen
    love.graphics.print({grayColorRGB, ("DIFFICULTY: "), greenColorRGB, (" " .. DIFFICULTY)}, 40, 20)

    -- Draw your high score on the screen
    love.graphics.print({grayColorRGB, ("HIGH SCORE: "), greenColorRGB, (" " .. highScore)}, 40, 80)

    -- Draw your score on the screen
    love.graphics.print({grayColorRGB, ("SCORE: "), greenColorRGB, (" " .. score)}, 40, 140)

    love.graphics.setColor(grayColorRGB)

    -- Draw obstacles
    for i = 1, #OBSTACLES do
        local x = OBSTACLES[i].x
        local y = OBSTACLES[i].y
        local size = OBSTACLES[i].size
        local design = OBSTACLES[i].design
        local rotation = OBSTACLES[i].rotation
        love.graphics.draw(OBSTACLES_APPERANCE[design].img, x, y, rotation,
                           obstacleScaleFactor * size,
                           obstacleScaleFactor * size,
                           OBSTACLES_APPERANCE[design].width / 2,
                           OBSTACLES_APPERANCE[design].height / 2)
    end

    -- Reset colors
    resetScreenColors()

    -- Game is not started then show game menu
    if (showGameMenu) then RENDER_GAME_MENU() end

    -- Show game over screen if game is over.
    if (isGameOver) then
        love.graphics.setFont(FONT_BIG)
        local gameOverText = " GAME OVER!"
        love.graphics.print({redColorRGB, (gameOverText)}, love.graphics.getWidth() / 2 -
                                FONT_BIG:getWidth(gameOverText) / 2,
                            love.graphics.getHeight() / 7)
        return
    end

    if (showGameMenu) then return end

    -- Draw player
    local playerSize = playerScaleFactor

    if (not lookingLeft) then 
        playerSize = playerSize * -1 
    end

    love.graphics.draw(player.img, player.x, player.y, 0, playerSize,
                       math.abs(playerSize), player.img:getWidth() / 2,
                       player.img:getHeight() / 2)

    -- Reset colors
    resetScreenColors()

        --Draw "Game Paused" on the screen if game is paused
    if(gamePaused) then 
        love.graphics.setFont(FONT_BIG)
        love.graphics.print({grayColorRGB, "GAME PAUSED"}, love.graphics.getWidth() / 2 - FONT_BIG:getWidth("GAME PAUSED") / 2, 
        love.graphics.getHeight() / 2 - FONT_BIG:getHeight("GAME PAUSED") / 2)
        --Set font back to default
        love.graphics.setFont(FONT)
    end

end

function RESTART_GAME()
    -- Reset player position
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 4
    -- Reset music by setting music track
    isMusicPlaying = false
    -- Destroy all obstacles
    for k, v in pairs(OBSTACLES) do OBSTACLES[k] = nil end
    -- Reset score
    score = 0
end

function love.update(dt)

    
    -- If the game is over or game is not loaded, return!
    if (not isGameLoaded or gamePaused) then 
        return
    end

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
    local obstaclesSpawned = #OBSTACLES

    local obstaclesCount = 0

    if(DIFFICULTY == "EASY") then
        obstaclesCount = obstaclesCountEasy
    else if(DIFFICULTY == "NORMAL") then
        obstaclesCount = obstaclesCountNormal
    else 
        obstaclesCount = obstaclesCountHard
      end
    end

    print(obstaclesCount)

    -- Check if more obstacles need to be spawned
    if obstaclesSpawned < obstaclesCount then
        while obstaclesSpawned <= obstaclesCount do
            local size = getRandomObstacleSize()
            local speed = getRandomObstacleSpeed()
            local y = getRandomObstacleYPosition()
            local design = getRandomObstacleDesign()
            local rotation = getRandomObstacleRotation()
            local x = getRandomObstacleXPosition(size)
            local direction = getRandomObstacleDirection()
            local directionSpeed = getRandomObstacleDirectionSpeed()
            OBSTACLES[obstaclesSpawned] = {}
            OBSTACLES[obstaclesSpawned].x = x
            OBSTACLES[obstaclesSpawned].y = y
            OBSTACLES[obstaclesSpawned].size = size
            OBSTACLES[obstaclesSpawned].speed = speed
            OBSTACLES[obstaclesSpawned].design = design
            OBSTACLES[obstaclesSpawned].rotation = rotation
            OBSTACLES[obstaclesSpawned].direction = direction
            OBSTACLES[obstaclesSpawned].directionSpeed = directionSpeed
            obstaclesSpawned = obstaclesSpawned + 1
        end
    end

    -- Move all obstacles
    for i = 1, #OBSTACLES do
        OBSTACLES[i].y = OBSTACLES[i].y - OBSTACLES[i].speed
        if(OBSTACLES[i].direction == "right") then
            OBSTACLES[i].x = OBSTACLES[i].x + OBSTACLES[i].directionSpeed 
        else
            OBSTACLES[i].x = OBSTACLES[i].x - OBSTACLES[i].directionSpeed 
        end
    end

    -- Rotate all obstacles
    for i = 1, #OBSTACLES do
        local rotation = OBSTACLES[i].rotation
        if (rotation + obstacleRotationSpeed >= 360) then rotation = 0 end
        if (i % 2 == 0) then
            OBSTACLES[i].rotation = rotation - obstacleRotationSpeed
        else
            OBSTACLES[i].rotation = rotation + obstacleRotationSpeed
        end
    end

    -- Check if obstacles need to be respawned
    for ii = 1, #OBSTACLES do
        local obstacleYPos = OBSTACLES[ii].y
        if (obstacleYPos < -100) then
            -- Respawn obstacle
            OBSTACLES[ii].speed = getRandomObstacleSpeed()
            OBSTACLES[ii].size = getRandomObstacleSize()
            OBSTACLES[ii].x = getRandomObstacleXPosition()
            OBSTACLES[ii].y = getRandomObstacleYPosition()
            OBSTACLES[ii].design = getRandomObstacleDesign()
            OBSTACLES[ii].rotation = getRandomObstacleRotation()
        end
    end

    -- If the game is over return
    if (isGameOver) then 
        return
    end

    if (PLAY_MUSIC and not isMusicPlaying) then
        -- Start music if not started
        musicTrack:play()
        isMusicPlaying = true
    else if(not PLAY_MUSIC and isMusicPlaying) then
        musicTrack:stop()
        isMusicPlaying = false
      end
    end

    -- If some obstacle gets outside of the screen send them to the other side.
    for i = 1, #OBSTACLES do
            local offset = 100
            if(OBSTACLES[i].x < -offset) then
                  OBSTACLES[i].x = love.graphics.getWidth()
                else if(OBSTACLES[i].x > love.graphics.getWidth() + offset) then
                 OBSTACLES[i].x = 0
            end
          end
    end

    -- Game is not started, return.
    if (showGameMenu) then 
        return 
    end

    -- If hold right key, move player to right
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
       
    -- Check if player has collided with some obstacle!
    for i = 1, #OBSTACLES do
          if overlap(player.x, player.y,
                    player.img:getWidth() * playerScaleFactor / 2,
                    player.img:getHeight() * playerScaleFactor / 2,
                    OBSTACLES[i].x, OBSTACLES[i].y,
                    OBSTACLES_APPERANCE[OBSTACLES[i].design].width * obstacleScaleFactor, 
                    OBSTACLES_APPERANCE[OBSTACLES[i].design].height * obstacleScaleFactor) 
                then
                -- Game is over!
                isGameOver = true
                showGameMenu = true
                -- play sound effect
                local src = love.audio.newSource("assets/explosion.mp3", "static")
                src:setVolume(1)
                src:setPitch(0.9)
                src:play()
                if(PLAY_MUSIC) then
                  -- Stop music track
                  musicTrack:stop() 
                end
                --Show mouse pointer again
                love.mouse.setVisible(true) 
        end
    end

    -- If the player is located at the bottom of the screen give twice as fast points.
    if (player.y > love.graphics.getHeight() / 2) then
        score = score + 2
    else
        score = score + 1
    end

    
    if(isGameOver) then
     --Check if we have reached a new high score!
      if(highScore < score)then
         highScore = score
      end
    end

    -- Add gravity to the player
    player.y = player.y + playerGravity

end

function START_GAME()
    RESTART_GAME()
    --Hide mouse pointer
    love.mouse.setVisible(false)
    isGameOver = false
    showGameMenu = false
end

function resumeGame()
    if(PLAY_MUSIC) then
      --Resume music
       musicTrack:play() 
    end
    gamePaused = false
end

function pauseGame()
    if(PLAY_MUSIC) then
      --Pause music
      musicTrack:pause() 
    end
    gamePaused = true
end

function love.keypressed(key)
    -- Exit the game if press "ESC"
    if key == "escape" then
        if(gamePaused) then
            resumeGame()
        else if(showSettings) then
            showSettings = false
        else
          love.event.quit()
        end
    end
        -- Restart the game if press "R"
    elseif key == "r" then
        love.event.quit("restart")
    elseif key == "p" then
      --Check if game is started
      if(showGameMenu) then
          return
      end
      --Pause/resume game
      gamePaused = not gamePaused
      if(gamePaused) then
          pauseGame()
      else
         resumeGame()
      end
    end
end

