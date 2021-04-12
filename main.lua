require("options")
require "utils"
require("menu")
require("tutorial")
require("keyevents")
require("music")

OBSTACLES = {}
OBSTACLES_TEXTURES = {}
FONT = nil
FONT_BIG = nil
IS_GAME_MENU_VISIBLE = true
IS_GAME_PAUSED = false
IS_GAME_OVER = false
PLAYER_LOOKING_LEFT = false
PLAYER_SCORE = 0

local greenColorRGB = {0, 1, 0, 1}
local redColorRGB = {255, 0, 0, 1}
local grayColorRGB = {50, 50, 50, 1}
local backgroundImage
local backgroundY
local backgroundY2
local highScore = 0
local player = {}
local backgroundScaleFactor = 2
local isGameLoaded = false


function love.load()

    print("The epic Atmosphere game is loading...")

    -- Hide mouse pointer on load
    love.mouse.setVisible(false)

    -- Window options
    FONT = love.graphics.newFont("assets/space_font.otf", 30)
    FONT_BIG = love.graphics.newFont("assets/space_font.otf", 60)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("The Atmosphere Game")
    love.window.setFullscreen(FULLSCREEN)

    -- Initialize background
    backgroundImage = love.graphics.newImage("assets/sky.jpg")
    backgroundY2 = -(backgroundImage:getHeight() * backgroundScaleFactor)
    backgroundY = 0

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

    -- Setup music track
    SETUP_MUSIC_TRACK()

    print("Game successfully loaded.")
    print("Have Fun!")
    print("Created by Benjamin Ojanne 2021")

    -- Get latest highscore from file
    highScore = LOAD_HIGHSCORE()

    -- Show mouse pointer
    love.mouse.setVisible(true)

    isGameLoaded = true

end


function love.draw()

    -- Draw the background
    love.graphics.draw(backgroundImage, 0, backgroundY, 0, backgroundScaleFactor, backgroundScaleFactor)

    love.graphics.draw(backgroundImage, 0, backgroundY2, 0, backgroundScaleFactor, backgroundScaleFactor)

    -- Draw FPS on the screen
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), love.graphics.getWidth() - 80, 10)

    love.graphics.setFont(FONT)

    love.graphics.print({
        grayColorRGB, ("DIFFICULTY: "), greenColorRGB, (" " .. DIFFICULTY)
    }, 40, 20)

    love.graphics.print({
        grayColorRGB, ("HIGH SCORE: "), greenColorRGB, (" " .. highScore)
    }, 40, 60)

    love.graphics.print({
        grayColorRGB, ("SCORE: "), greenColorRGB, (" " .. PLAYER_SCORE)
    }, 40, 100)

    love.graphics.setColor(grayColorRGB)

    -- Draw obstacles
    for i = 0, #OBSTACLES do
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
       
        local text = "GAME OVER!"
       
        love.graphics.print({
            redColorRGB, (text)
        }, love.graphics.getWidth() / 2 -FONT_BIG:getWidth(text) / 2,love.graphics.getHeight() / 7)
    
    elseif(IS_GAME_PAUSED) then 
        
        -- Draw "Game Paused" on the screen if game is paused
          
        love.graphics.setFont(FONT_BIG)
      
        local text = "GAME PAUSED"

        love.graphics.print({redColorRGB, text}, 
            love.graphics.getWidth() / 2 - FONT_BIG:getWidth(text) / 2, 
            love.graphics.getHeight() / 5 + FONT_BIG:getHeight(text))
    
    end

    -- Draw player
    local playerScaleFactor = PLAYER_SCALE_FACTOR

    if (not PLAYER_LOOKING_LEFT) then 
        playerScaleFactor = playerScaleFactor * -1 
    end

    if (not IS_GAME_MENU_VISIBLE or IS_GAME_PAUSED) then
        love.graphics.draw(player.img, player.x, player.y, 0, playerScaleFactor, 
        math.abs(playerScaleFactor), player.img:getWidth() / 2, player.img:getHeight() / 2)
    end

    -- Render the game menu
    if (IS_GAME_MENU_VISIBLE) then 
        RENDER_GAME_MENU() 
    end

    -- Reset screen colors
    RESET_SCREEN_COLORS()

end

function love.update(dt)

    --Don't let the FPS to go much over 60!
    LIMIT_FPS()

    -- If the game is over or game is not loaded, return!
    if (not isGameLoaded or IS_GAME_PAUSED) then 
        return 
    end

    -- This handles the smooth background scrolling behavior.
    backgroundY = backgroundY - (not IS_GAME_MENU_VISIBLE and BACKGROUND_SPEED or BACKGROUND_SPEED_IDLE) * dt

    backgroundY2 = backgroundY2 - (not IS_GAME_MENU_VISIBLE and BACKGROUND_SPEED or BACKGROUND_SPEED_IDLE) * dt

    if (backgroundY <= -backgroundImage:getHeight() * backgroundScaleFactor) then
        backgroundY = 0
    end

    if (backgroundY2 <= 0) then
        backgroundY2 = backgroundImage:getHeight() * backgroundScaleFactor
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
    for i = 0, #OBSTACLES do
        OBSTACLES[i].y = OBSTACLES[i].y - OBSTACLES[i].speed
        if (OBSTACLES[i].direction == "right") then
            OBSTACLES[i].x = OBSTACLES[i].x + OBSTACLES[i].directionSpeed
        else
            OBSTACLES[i].x = OBSTACLES[i].x - OBSTACLES[i].directionSpeed
        end
    end

    -- Rotate all obstacles
    for i = 0, #OBSTACLES do
        local rotation = OBSTACLES[i].rotation
        if (rotation + OBSTACLE_ROTATION_SPEED >= 360) then rotation = 0 end
        if (i % 2 == 0) then
            OBSTACLES[i].rotation = rotation - OBSTACLE_ROTATION_SPEED
        else
            OBSTACLES[i].rotation = rotation + OBSTACLE_ROTATION_SPEED
        end
    end

    -- Check if obstacles need to be respawned
    for ii = 0, #OBSTACLES do
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

    -- If some obstacle gets outside of the screen send them to the other side.
    for i = 0, #OBSTACLES do

        local obstacleSize = OBSTACLES_TEXTURES[OBSTACLES[i].texture].width * OBSTACLES[i].size

        if (OBSTACLES[i].x < -obstacleSize) then
            OBSTACLES[i].x = love.graphics.getWidth() + obstacleSize
        elseif (OBSTACLES[i].x > love.graphics.getWidth() + obstacleSize) then
            OBSTACLES[i].x = -obstacleSize
        end

    end

    -- Check if obstacles has collided with eachother.
    HANDLE_OBSTACLE_COLLISIONS()

    -- If the game is over return
    if (IS_GAME_OVER) then 
        return 
    end

    -- Game is not started, return.
    if (IS_GAME_MENU_VISIBLE) then 
        return 
    end

    if(PLAY_MUSIC) then
        PLAY_MUSIC_TRACK()
    else
        STOP_MUSIC_TRACK()
    end

    --Move player if user press w,a,s or d
    HANDLE_PLAYER_KEY_EVENTS(player, dt)

    -- If player gets outside of the screen on the right side then sent the player to left side.
    if player.x > love.graphics.getWidth() then
        player.x = 0
    end

    -- If player gets outside of the screen on the left side then sent the player to right side.
    if player.x < 0 then
        player.x = love.graphics.getWidth()
    end

    -- Check if player has collided with some obstacle!
    for i = 0, #OBSTACLES do
        
        if OVERLAP(player.x, player.y,
                   player.img:getWidth() * PLAYER_SCALE_FACTOR / 2,
                   player.img:getHeight() * PLAYER_SCALE_FACTOR / 2,
                    OBSTACLES[i].x, OBSTACLES[i].y,
                    OBSTACLES_TEXTURES[OBSTACLES[i].texture].width *
                    OBSTACLE_SCALE_FACTOR, OBSTACLES_TEXTURES[OBSTACLES[i]
                       .texture].height * OBSTACLE_SCALE_FACTOR) then

            -- GAME OVER!
            IS_GAME_OVER = true
            IS_GAME_MENU_VISIBLE = true

            -- play sound effect
            local src = love.audio.newSource("assets/explosion.mp3", "static")
            src:setVolume(1)
            src:setPitch(0.8)
            src:play()

            -- Stop music track
            STOP_MUSIC_TRACK()

            -- Show mouse pointer again
            love.mouse.setVisible(true)

            -- Check if we have reached a new high score!
            if (tonumber(highScore) < PLAYER_SCORE) then
                highScore = PLAYER_SCORE
                SAVE_HIGHSCORE(highScore)
            end

            return

        end
    end

    -- If the player is located at the bottom of the screen give twice as fast points.
    if (player.y > love.graphics.getHeight() / 2) then
        PLAYER_SCORE = PLAYER_SCORE + 2
    else
        PLAYER_SCORE = PLAYER_SCORE + 1
    end

    -- Add gravity to the player
    player.y = player.y + PLAYER_GRAVITY

end

function RESTART_GAME()
    
    -- Player start position
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 4
        
    -- Reset score count
    PLAYER_SCORE = 0    
    
    -- Destroy all obstacles
    CLEAR_OBSTACLES()

end