require("options")
require("utils")
require("menu")

OBSTACLES = {} -- global variable
OBSTACLES_APPERANCE = {} -- global variable
FONT = nil -- global variable
FONT_BIG = nil -- global variable
IS_GAME_OVER = false -- global variable

local greenColorRGB = {0, 1, 0, 1}
local redColorRGB = {255, 0, 0, 1}
local grayColorRGB = {50, 50, 50, 1}
local backgroundImage
local backgroundY
local backgroundY2
local score = 0
local highScore = 0
local player = {}
local playerGravity = 3
local playerOutSideOffset = 10
local backgroundScaleFactor = 2
local isMusicPlaying = false
local isGameLoaded = false
local isGameMenuVisible = true
local isGamePaused = false
local musicTrack = nil
local lookingLeft = false

function love.load()

    print("The epic Atmosphere game is loading...")

    --Hide mouse pointer on load
    love.mouse.setVisible(false)
    
    -- Window options
    FONT = love.graphics.newFont("assets/space_font.otf", 30)
    FONT_BIG = love.graphics.newFont("assets/space_font.otf", 70)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("The Atmosphere Game")
    love.window.setFullscreen(FULLSCREEN)

    -- Initialize background
    backgroundImage = love.graphics.newImage("assets/sky.jpg")
    backgroundY = 0
    backgroundY2 = -backgroundImage:getHeight() * backgroundScaleFactor

    -- Get all obstacle images into an array
    for i = 1, 4 do
        OBSTACLES_APPERANCE[i] = {}
        OBSTACLES_APPERANCE[i].img = love.graphics.newImage("assets/obstacles/obstacle" .. i .. ".png")
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
    musicTrack:setVolume(MUSIC_VOLUME)
    musicTrack:setLooping(true)

    print("Game successfully loaded.")
    print("Have Fun!")
    print("Created by Benjamin Ojanne 2021")

    --Show mouse pointer
    love.mouse.setVisible(true)

    isGameLoaded = true

end

function love.draw()

    -- Draw the background
    love.graphics.draw(backgroundImage, 0, backgroundY, 0,
                       backgroundScaleFactor, backgroundScaleFactor)

    love.graphics.draw(backgroundImage, 0, backgroundY2, 0,
                       backgroundScaleFactor, backgroundScaleFactor)

    --Draw FPS on the screen
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), love.graphics.getWidth() - 80, 10)

    love.graphics.setFont(FONT)

    -- Draw your high score on the screen
    love.graphics.print({grayColorRGB, ("DIFFICULTY: "), greenColorRGB, (" " .. DIFFICULTY)}, 40, 20)

    -- Draw your high score on the screen
    love.graphics.print({grayColorRGB, ("HIGH SCORE: "), greenColorRGB, (" " .. highScore)}, 40, 60)

    -- Draw your score on the screen
    love.graphics.print({grayColorRGB, ("SCORE: "), greenColorRGB, (" " .. score)}, 40, 100)

    love.graphics.setColor(grayColorRGB)

    -- Draw obstacles
    for i = 1, #OBSTACLES do
        local x = OBSTACLES[i].x
        local y = OBSTACLES[i].y
        local size = OBSTACLES[i].size
        local design = OBSTACLES[i].design
        local rotation = OBSTACLES[i].rotation
        love.graphics.draw(OBSTACLES_APPERANCE[design].img, x, y, rotation,
                           OBSTACLE_SCALE_FACTOR * size,
                           OBSTACLE_SCALE_FACTOR * size,
                           OBSTACLES_APPERANCE[design].width / 2,
                           OBSTACLES_APPERANCE[design].height / 2)
    end

    -- Reset colors
    resetScreenColors()

    -- Game is not started then show game menu
    if (isGameMenuVisible) then RENDER_GAME_MENU() end

    -- Show game over screen if game is over.
    if (IS_GAME_OVER) then
        love.graphics.setFont(FONT_BIG)
        local gameOverText = " GAME OVER!"
        love.graphics.print({redColorRGB, (gameOverText)}, 
        love.graphics.getWidth() / 2 - FONT_BIG:getWidth(gameOverText) / 2, love.graphics.getHeight() / 7)
        return
    end

    if (isGameMenuVisible) then return end

    -- Draw player
    local playerSize = PLAYER_SCALE_FACTOR

    if (not lookingLeft) then 
        playerSize = playerSize * -1 
    end

    love.graphics.draw(player.img, player.x, player.y, 0, playerSize,
                       math.abs(playerSize), player.img:getWidth() / 2,
                       player.img:getHeight() / 2)

    -- Reset colors
    resetScreenColors()

        --Draw "Game Paused" on the screen if game is paused
    if(isGamePaused) then 
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
    if (not isGameLoaded or isGamePaused) then 
        return
    end

    -- This handles the smooth background scrolling behavior.
    backgroundY = backgroundY + (not isGameMenuVisible and BACKGROUND_SPEED or BACKGROUND_SPEED_IDLE) * dt
    backgroundY2 = backgroundY2 + (not isGameMenuVisible and BACKGROUND_SPEED or BACKGROUND_SPEED_IDLE) * dt

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
        obstaclesCount = OBSTACLES_COUNT_EASY
    else if(DIFFICULTY == "NORMAL") then
        obstaclesCount = OBSTACLES_COUNT_NORMAL
    else 
        obstaclesCount = OBSTACLES_COUNT_HARD
      end
    end

    -- Check if more obstacles need to be spawned
    if obstaclesSpawned < obstaclesCount then
        while obstaclesSpawned <= obstaclesCount do
            local size = getRandomObstacleSize()
            local speed = getRandomObstacleSpeed()
            local y = getRandomObstacleYPosition()
            local design = getRandomObstacleDesign()
            local rotation = getRandomObstacleRotation()
            local x = getRandomObstacleXPosition()
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
        if (rotation + OBSTACLE_ROTATION_SPEED >= 360) then rotation = 0 end
        if (i % 2 == 0) then
            OBSTACLES[i].rotation = rotation - OBSTACLE_ROTATION_SPEED
        else
            OBSTACLES[i].rotation = rotation + OBSTACLE_ROTATION_SPEED
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
            OBSTACLES[ii].direction = getRandomObstacleDirection()
            OBSTACLES[ii].directionSpeed = getRandomObstacleDirectionSpeed()
        end
    end

    handleObstacleCollisions()

    -- If the game is over return
    if (IS_GAME_OVER) then 
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
            local offset = 50
            local outsideMargin = 50
            if(OBSTACLES[i].x < -offset) then
                  OBSTACLES[i].x = love.graphics.getWidth() + outsideMargin
                else if(OBSTACLES[i].x > love.graphics.getWidth() + offset) then
                 OBSTACLES[i].x = -outsideMargin
            end
          end
    end

    -- Game is not started, return.
    if (isGameMenuVisible) then 
        return 
    end

    -- If hold right key, move player to right
    if love.keyboard.isDown("right") then
        player.x = player.x + PLAYER_MOVE_SPEED * dt
        lookingLeft = false
    end

    -- If hold left key, move player left
    if love.keyboard.isDown("left") then
        player.x = player.x - PLAYER_MOVE_SPEED * dt
        lookingLeft = true
    end

    -- If hold isDown key, move player down
    if love.keyboard.isDown("down") then player.y = player.y + PLAYER_MOVE_SPEED * dt end

    -- If hold isDown key, move player up
    if love.keyboard.isDown("up") then
        if (player.y > 0) then player.y = player.y - PLAYER_MOVE_SPEED * dt end
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
                    player.img:getWidth() * PLAYER_SCALE_FACTOR / 2,
                    player.img:getHeight() * PLAYER_SCALE_FACTOR / 2,
                    OBSTACLES[i].x, OBSTACLES[i].y,
                    OBSTACLES_APPERANCE[OBSTACLES[i].design].width * OBSTACLE_SCALE_FACTOR, 
                    OBSTACLES_APPERANCE[OBSTACLES[i].design].height * OBSTACLE_SCALE_FACTOR) then
                        
                -- Game is over!
                IS_GAME_OVER = true
                isGameMenuVisible = true
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

    if(IS_GAME_OVER) then
     --Check if we have reached a new high score!
      if(highScore < score)then
         highScore = score
      end
    end

    -- Add gravity to the player
    player.y = player.y + playerGravity

end

function handleObstacleCollisions()
    -- Check if a obstacle has collided with a another obstacle!
    -- If that is the case, send them at opposite directions.
    for i = 0, #OBSTACLES do

        for ii = 0, #OBSTACLES do

            if (ii == i) then goto continue end

            if overlap(OBSTACLES[ii].x, OBSTACLES[ii].y,
                      OBSTACLES_APPERANCE[OBSTACLES[ii].design].width * OBSTACLE_SCALE_FACTOR, 
                      OBSTACLES_APPERANCE[OBSTACLES[ii].design].height * OBSTACLE_SCALE_FACTOR,
                      OBSTACLES[i].x, OBSTACLES[i].y,
                      OBSTACLES_APPERANCE[OBSTACLES[i].design].width * OBSTACLE_SCALE_FACTOR, 
                      OBSTACLES_APPERANCE[OBSTACLES[i].design].height * OBSTACLE_SCALE_FACTOR) then
                        
                      local difX = math.abs(OBSTACLES[i].x - OBSTACLES[ii].x)
                      local upForceSpeed = 10

                      --If difX is less than 20 then, the other obstacle has probably hit the obstacle from bottom side.

                      if(difX < 20) then
                        
                        if(OBSTACLES[ii].y < OBSTACLES[i].y) then
                            OBSTACLES[ii].speed = upForceSpeed
                        else
                            OBSTACLES[i].speed = upForceSpeed
                        end
                      
                      elseif(OBSTACLES[i].x < OBSTACLES[ii].x) then

                        OBSTACLES[i].direction = "left"
                        OBSTACLES[ii].direction = "right"

                      else
                        
                        OBSTACLES[i].direction = "right"
                        OBSTACLES[ii].direction = "left"

                      end

            end

            ::continue::

         end

      end
end

function START_GAME()
    RESTART_GAME()
    --Hide mouse pointer
    love.mouse.setVisible(false)
    IS_GAME_OVER = false
    isGameMenuVisible = false  
end

function resumeGame()
    if(PLAY_MUSIC) then
      --Resume music
       musicTrack:play() 
    end
    isGamePaused = false
end

function pauseGame()
    if(PLAY_MUSIC) then
      --Pause music
      musicTrack:pause() 
    end
    isGamePaused = true
end

function love.keypressed(key)
    -- Exit the game if press "ESC"
    if key == "escape" then
        if(isGamePaused) then
            resumeGame()
        else if(showSettings) then
            showSettings = false
        else
          love.event.quit()
        end
    end
    -- Restart the game if press "R"
    elseif key == "r" then
        if not isGamePaused then
        love.event.quit("restart")
      else
        resumeGame()
      end
    elseif key == "p" then
      --Check if game is started
      if(isGameMenuVisible) then
          return
      end
      --Pause/resume game
      isGamePaused = not isGamePaused
      if(isGamePaused) then
          pauseGame()
      else
         resumeGame()
      end
    end
end

