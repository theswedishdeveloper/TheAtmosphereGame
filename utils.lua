function RESET_SCREEN_COLORS() 
    love.graphics.setColor(255, 255, 255) 
end


function GET_RANDOM_OBSTACLE_Y_POSITION()
    return love.graphics.getHeight() + math.random(love.graphics.getHeight(), love.graphics.getHeight() * 3)
end


function GET_RANDOM_OBSTACLE_X_POSITION()
    local newPos = math.random(0, love.graphics.getWidth())
    return newPos
end


function GET_RANDOM_OBSTACLE_SPEED()
    return math.random(OBSTACLE_MIN_SPEED, OBSTACLE_MAX_SPEED)
end


function GET_RANDOM_OBSTACLE_SIZE()
    return math.random(OBSTACLE_MIN_SIZE, OBSTACLE_MAX_SIZE)
end


function GET_RANDOM_OBSTACLE_TEXTURE() 
    return math.random(1, 4) 
end


function GET_RANDOM_OBSTACLE_ROTATION() 
    return math.random(50, 150) 
end


function OVERLAP(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 <= x2 + w2 and x2 <= x1 + w1 and y1 <= y2 + h2 and y2 <= y1 + h1
end


function GET_RANDOM_OBSTACLE_DIRECTION_SPEED()
    return math.random(OBSTACLE_MIN_DIRECTION_SPEED, OBSTACLE_MAX_DIRECTION_SPEED)
end


function GET_RANDOM_OBSTACLE_DIRECTION()
    
    local right = math.random(0, 1) == 1
   
    if (right) then
        return "right"
    else
        return "left"
    end

end


function LOAD_HIGHSCORE() 

    local highscore = love.filesystem.read("highscore.sav")

    if(highscore == nil) then
        highscore = 0
    end

    return highscore

end


function SAVE_HIGHSCORE(newHighScore)
    
    love.filesystem.write("highscore.sav", newHighScore)

end


function LIMIT_FPS()
 
    --keep the FPS around 60 frames per second!
    love.timer.sleep("0.0110")

end


function CLEAR_OBSTACLES()
    
    for k, v in pairs(OBSTACLES) do 
        OBSTACLES[k] = nil 
    end

end


function START_GAME()
    RESTART_GAME()
    love.mouse.setVisible(false)
    IS_GAME_OVER = false
    IS_GAME_MENU_VISIBLE = false
    PLAY_MUSIC_TRACK()
end


function RESUME_GAME()   
    love.mouse.setVisible(false)
    IS_GAME_PAUSED = false
    IS_GAME_MENU_VISIBLE = false
    PLAY_MUSIC_TRACK()
end


function PAUSE_GAME()   
    love.mouse.setVisible(true)
    PAUSE_MUSIC_TRACK()
    IS_GAME_PAUSED = true
    IS_GAME_MENU_VISIBLE = true
    PAUSE_MUSIC_TRACK()
end


function HANDLE_OBSTACLE_COLLISIONS()
    -- Check if a obstacle has collided with a another obstacle!
    -- If that is the case, send them at opposite directions.
    for i = 0, #OBSTACLES do

        for ii = 0, #OBSTACLES do

            if (ii == i) then 
                goto continue 
            end

            if OVERLAP(OBSTACLES[ii].x, OBSTACLES[ii].y,
                       OBSTACLES_TEXTURES[OBSTACLES[ii].texture].width *
                           OBSTACLE_SCALE_FACTOR,
                       OBSTACLES_TEXTURES[OBSTACLES[ii].texture].height *
                           OBSTACLE_SCALE_FACTOR, OBSTACLES[i].x,
                       OBSTACLES[i].y, OBSTACLES_TEXTURES[OBSTACLES[i].texture]
                           .width * OBSTACLE_SCALE_FACTOR,
                       OBSTACLES_TEXTURES[OBSTACLES[i].texture].height *
                           OBSTACLE_SCALE_FACTOR) then

                local difX = math.abs(OBSTACLES[i].x - OBSTACLES[ii].x)

                local upForceSpeed = 10

                -- If difX is less than 20 then, the other obstacle has probably hit the obstacle from the bottom side.

                if (difX < 20) then

                    if (OBSTACLES[ii].y < OBSTACLES[i].y) then
                        OBSTACLES[ii].speed = upForceSpeed
                    else
                        OBSTACLES[i].speed = upForceSpeed
                    end

                elseif (OBSTACLES[i].x < OBSTACLES[ii].x) then

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
