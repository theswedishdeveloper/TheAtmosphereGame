function love.keypressed(key)
    -- Exit the game if press "ESC"
    if key == "escape" then

        if (IS_GAME_PAUSED) then
            RESUME_GAME()
        elseif (SHOW_SETTINGS) then
                
            SHOW_SETTINGS = false

            elseif(not IS_GAME_MENU_VISIBLE) then

                PAUSE_GAME()
                
            end
    
        -- Restart the game if press "R"
    elseif key == "r" then
       
        if not IS_GAME_PAUSED then
            love.event.quit("restart")
        else
            RESUME_GAME()
        end

    elseif key == "p" then 
       
        -- Pause/resume game
        if (IS_GAME_PAUSED) then
            RESUME_GAME()
        else
            PAUSE_GAME()
        end

    end
end

function HANDLE_PLAYER_KEY_EVENTS(player, dt)
   
    if love.keyboard.isDown("d") then
        player.x = player.x + PLAYER_MOVE_SPEED * dt
        PLAYER_LOOKING_LEFT = false
    end
    
    if love.keyboard.isDown("a") then
        player.x = player.x - PLAYER_MOVE_SPEED * dt
        PLAYER_LOOKING_LEFT = true
    end
    
    if love.keyboard.isDown("s") then
        player.y = player.y + PLAYER_MOVE_SPEED * dt
    end
    
    if love.keyboard.isDown("w") then
        if (player.y > 0) then
            player.y = player.y - PLAYER_MOVE_SPEED * 1.5 * dt
        end
    end

end
