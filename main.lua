require("options")
require "utils"
require("menu")
require("tutorial")
require("keyevents")

OBSTACLES = {}
OBSTACLES_TEXTURES = {}
FONT = nil
FONT_BIG = nil
IS_GAME_OVER = false
IS_GAME_MENU_VISIBLE = true
IS_GAME_PAUSED = false

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
local musicTrack = nil
local lookingLeft = false

function love.load()

    print("The epic Atmosphere game is loading...")

    -- Hide mouse pointer on load
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
        OBSTACLES_TEXTURES[i] = {}
        OBSTACLES_TEXTURES[i].img = love.graphics.newImage("assets/obstacles/obstacle" .. i ..".png")
        OBSTACLES_TEXTURES[i].width = OBSTACLES_TEXTURES[i].img:getWidth()
        OBSTACLES_TEXTURES[i].height = OBSTACLES_TEXTURES[i].img:getHeight()
    end

    -- Initialize player
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 4
    player.img = love.graphics.newImage("assets/player.png")

    -- Setup game menu
    SETUP_GAME_MENU()

    -- Load music track
    musicTrack = love.audio.newSource("assets/music.mp3", "static")
    musicTrack:setVolume(MUSIC_VOLUME)
    musicTrack:setLooping(true)

    print("Game successfully loaded.")
    print("Have Fun!")
    print("Created by Benjamin Ojanne 2021")

    -- Show mouse pointer
    love.mouse.setVisible(true)

    -- Get latest highscore from file
    highScore = LOAD_HIGHSCORE()

    isGameLoaded = true

end

function love.draw()

    -- Draw the background
    love.graphics.draw(backgroundImage, 0, backgroundY, 0, backgroundScaleFactor, backgroundScaleFactor)

    love.graphics.draw(backgroundImage, 0, backgroundY2, 0,backgroundScaleFactor, backgroundScaleFactor)

    -- Draw FPS on the screen
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), love.graphics.getWidth() - 80, 10)

    love.graphics.setFont(FONT)

    -- Draw your high score on the screen
    love.graphics.print({
        grayColorRGB, ("DIFFICULTY: "), greenColorRGB, (" " .. DIFFICULTY)
    }, 40, 20)

    -- Draw your high score on the screen
    love.graphics.print({
        grayColorRGB, ("HIGH SCORE: "), greenColorRGB, (" " .. highScore)
    }, 40, 60)

    -- Draw your score on the screen
    love.graphics.print({
        grayColorRGB, ("SCORE: "), greenColorRGB, (" " .. score)
    }, 40, 100)

    love.graphics.setColor(grayColorRGB)

    -- Draw obstacles
    for i = 1, #OBSTACLES do
        local x = OBSTACLES[i].x
        local y = OBSTACLES[i].y
        local size = OBSTACLES[i].size
        local texture = OBSTACLES[i].texture
        local rotation = OBSTACLES[i].rotation
        love.graphics.draw(OBSTACLES_TEXTURES[texture].img, x, y, rotation,
                           OBSTACLE_SCALE_FACTOR * size,
                           OBSTACLE_SCALE_FACTOR * size,
                           OBSTACLES_TEXTURES[texture].width / 2,
                           OBSTACLES_TEXTURES[texture].height / 2)
    end

    -- Reset colors
    RESET_SCREEN_COLORS()

    -- Show game over screen if game is over.
    if (IS_GAME_OVER) then
        love.graphics.setFont(FONT_BIG)
        local gameOverText = " GAME OVER!"
        love.graphics.print({redColorRGB, (gameOverText)}, love.graphics.getWidth() / 2 - FONT_BIG:getWidth(gameOverText) / 2, love.graphics.getHeight() / 7)
       -- Set font back to default
       love.graphics.setFont(FONT)
    end

    -- Draw "Game Paused" on the screen if game is paused
    if (IS_GAME_PAUSED) then
        love.graphics.setFont(FONT_BIG)
        love.graphics.print({redColorRGB, "GAME PAUSED"}, love.graphics.getWidth() / 2 - FONT_BIG:getWidth("GAME PAUSED") / 2, love.graphics.getHeight() / 4)
        -- Set font back to default
        love.graphics.setFont(FONT)
    end

    -- Draw player
    local playerSize = PLAYER_SCALE_FACTOR

    if (not lookingLeft) then playerSize = playerSize * -1 end

    if (not IS_GAME_MENU_VISIBLE or IS_GAME_PAUSED) then
        love.graphics.draw(player.img, player.x, player.y, 0, playerSize, math.abs(playerSize), player.img:getWidth() / 2, player.img:getHeight() / 2) 
    end
    
    if (IS_GAME_MENU_VISIBLE) then RENDER_GAME_MENU() end

    -- Reset screen colors
    RESET_SCREEN_COLORS()

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
    if (not isGameLoaded or IS_GAME_PAUSED) then return end

    -- This handles the smooth background scrolling behavior.
    backgroundY = backgroundY + (not IS_GAME_MENU_VISIBLE and BACKGROUND_SPEED or BACKGROUND_SPEED_IDLE) * dt

    backgroundY2 = backgroundY2 + (not IS_GAME_MENU_VISIBLE and BACKGROUND_SPEED or BACKGROUND_SPEED_IDLE) * dt

    if (backgroundY >= backgroundImage:getHeight() * backgroundScaleFactor) then
        backgroundY = 0
    end

    if (backgroundY2 >= 0) then
        backgroundY2 = -backgroundImage:getHeight() * backgroundScaleFactor
    end

    -- check if have spawned required amount of obstacles
    local obstaclesSpawned = #OBSTACLES

    local obstaclesCount = 0

    if (DIFFICULTY == "EASY") then
        obstaclesCount = OBSTACLES_COUNT_EASY
    else
        if (DIFFICULTY == "NORMAL") then
            obstaclesCount = OBSTACLES_COUNT_NORMAL
        else
            obstaclesCount = OBSTACLES_COUNT_HARD
        end
    end

    -- Check if more obstacles need to be spawned
    if obstaclesSpawned < obstaclesCount then
        while obstaclesSpawned <= obstaclesCount do
            local size = GET_RANDOM_OBSTACLE_SIZE()
            local speed = GET_RANDOM_OBSTACLE_SPEED()
            local y = GET_RANDOM_OBSTACLE_Y_POSITION()
            local texture = GET_RANDOM_OBSTACLE_TEXTURE()
            local rotation = GET_RANDOM_OBSTACLE_ROTATION()
            local x = GET_RANDOM_OBSTACLE_X_POSITION()
            local direction = GET_RANDOM_OBSTACLE_DIRECTION()
            local directionSpeed = GET_RANDOM_OBSTACLE_DIRECTION_SPEED()
            OBSTACLES[obstaclesSpawned] = {}
            OBSTACLES[obstaclesSpawned].x = x
            OBSTACLES[obstaclesSpawned].y = y
            OBSTACLES[obstaclesSpawned].size = size
            OBSTACLES[obstaclesSpawned].speed = speed
            OBSTACLES[obstaclesSpawned].texture = texture
            OBSTACLES[obstaclesSpawned].rotation = rotation
            OBSTACLES[obstaclesSpawned].direction = direction
            OBSTACLES[obstaclesSpawned].directionSpeed = directionSpeed
            obstaclesSpawned = obstaclesSpawned + 1
        end
    end

    -- Move all obstacles
    for i = 1, #OBSTACLES do
        OBSTACLES[i].y = OBSTACLES[i].y - OBSTACLES[i].speed
        if (OBSTACLES[i].direction == "right") then
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
            OBSTACLES[ii].speed = GET_RANDOM_OBSTACLE_SPEED()
            OBSTACLES[ii].size = GET_RANDOM_OBSTACLE_SIZE()
            OBSTACLES[ii].x = GET_RANDOM_OBSTACLE_X_POSITION()
            OBSTACLES[ii].y = GET_RANDOM_OBSTACLE_Y_POSITION()
            OBSTACLES[ii].texture = GET_RANDOM_OBSTACLE_TEXTURE()
            OBSTACLES[ii].rotation = GET_RANDOM_OBSTACLE_ROTATION()
            OBSTACLES[ii].direction = GET_RANDOM_OBSTACLE_DIRECTION()
            OBSTACLES[ii].directionSpeed = GET_RANDOM_OBSTACLE_DIRECTION_SPEED()
        end
    end

    --Check if obstacles has collided with eachother.
    HANDLE_OBSTACLE_COLLISIONS()

    -- If the game is over return
    if (IS_GAME_OVER) then return end

    if (PLAY_MUSIC and not isMusicPlaying) then
        -- Start music if not started
        musicTrack:play()
        isMusicPlaying = true
    else
        if (not PLAY_MUSIC and isMusicPlaying) then
            musicTrack:stop()
            isMusicPlaying = false
        end
    end

    -- If some obstacle gets outside of the screen send them to the other side.
    for i = 1, #OBSTACLES do
        local offset = 50
        local outsideMargin = 50
        if (OBSTACLES[i].x < -offset) then
            OBSTACLES[i].x = love.graphics.getWidth() + outsideMargin
        else
            if (OBSTACLES[i].x > love.graphics.getWidth() + offset) then
                OBSTACLES[i].x = -outsideMargin
            end
        end
    end

    -- Game is not started, return.
    if (IS_GAME_MENU_VISIBLE) then return end

    if love.keyboard.isDown("d") then
        player.x = player.x + PLAYER_MOVE_SPEED * dt
        lookingLeft = false
    end

    if love.keyboard.isDown("a") then
        player.x = player.x - PLAYER_MOVE_SPEED * dt
        lookingLeft = true
    end

    if love.keyboard.isDown("s") then
        player.y = player.y + PLAYER_MOVE_SPEED * dt
    end

    if love.keyboard.isDown("w") then
        if (player.y > 0) then
            player.y = player.y - PLAYER_MOVE_SPEED * dt
        end
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
        if OVERLAP(player.x, player.y,
                   player.img:getWidth() * PLAYER_SCALE_FACTOR / 2,
                   player.img:getHeight() * PLAYER_SCALE_FACTOR / 2,
                   OBSTACLES[i].x, OBSTACLES[i].y,
                   OBSTACLES_TEXTURES[OBSTACLES[i].texture].width *
                       OBSTACLE_SCALE_FACTOR, OBSTACLES_TEXTURES[OBSTACLES[i]
                       .texture].height * OBSTACLE_SCALE_FACTOR) then
         
            -- Game over!
            IS_GAME_OVER = true
            IS_GAME_MENU_VISIBLE = true
           
            -- play sound effect
            local src = love.audio.newSource("assets/explosion.mp3", "static")
            src:setVolume(1)
            src:setPitch(0.8)
            src:play()
           
            if (PLAY_MUSIC) then
                -- Stop music track
                musicTrack:stop()
            end
          
            -- Show mouse pointer again
            love.mouse.setVisible(true)

        end
    end

    -- If the player is located at the bottom of the screen give twice as fast points.
    if (player.y > love.graphics.getHeight() / 2) then
        score = score + 2
    else
        score = score + 1
    end

    if (IS_GAME_OVER) then
        -- Check if we have reached a new high score!
        if (tonumber(highScore) < score) then
             highScore = score 
             SAVE_HIGHSCORE(highScore)
        end
    end

    -- Add gravity to the player
    player.y = player.y + playerGravity

end

function START_GAME()
    RESTART_GAME()
    -- Hide mouse pointer
    love.mouse.setVisible(false)
    IS_GAME_OVER = false
    IS_GAME_MENU_VISIBLE = false
end

function RESUME_GAME()
    if (PLAY_MUSIC) then
        -- Resume music
        musicTrack:play()
    end
    love.mouse.setVisible(false)
    IS_GAME_PAUSED = false
    IS_GAME_MENU_VISIBLE = false
end

function PAUSE_GAME()
    if (PLAY_MUSIC) then
        -- Pause music
        musicTrack:pause()
    end
    love.mouse.setVisible(true)
    IS_GAME_PAUSED = true
    IS_GAME_MENU_VISIBLE = true
end