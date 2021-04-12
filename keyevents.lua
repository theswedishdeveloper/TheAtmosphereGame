function love.keypressed(key)

    if key == "escape" then

        if (IS_GAME_PAUSED) then
            
            RESUME_GAME()

        elseif (SHOW_SETTINGS) then
                
            SHOW_SETTINGS = false

        elseif(not IS_GAME_MENU_VISIBLE) then

            PAUSE_GAME()
                
        end
    
    elseif key == "r" then
       
        if not IS_GAME_PAUSED then

            love.event.quit("restart")

        else
            
            RESUME_GAME()

        end

    elseif key == "p" then

        if (IS_GAME_PAUSED) then

            RESUME_GAME()

        elseif(not IS_GAME_MENU_VISIBLE) then

            PAUSE_GAME()

        end

    end
end

function HANDLE_PLAYER_KEY_EVENTS(player, dt)
    
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        
        player.x = player.x + PLAYER_MOVE_SPEED * dt
        PLAYER_LOOKING_LEFT = false

    end
    
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then

        player.x = player.x - PLAYER_MOVE_SPEED * dt
        PLAYER_LOOKING_LEFT = true

    end
    
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then

        player.y = player.y + PLAYER_MOVE_SPEED * 0.75 * dt

    end
    
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
       
        if (player.y > 0) then
            player.y = player.y - PLAYER_MOVE_SPEED * 1.25 * dt
        end

    end

end

