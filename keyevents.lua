function love.keypressed(key)
    -- Exit the game if press "ESC"
    if key == "escape" then
        if (IS_GAME_PAUSED) then
            RESUME_GAME()
        else
            if (SHOW_SETTINGS) then
                SHOW_SETTINGS = false
            elseif(not IS_GAME_MENU_VISIBLE) then
                PAUSE_GAME()
            end
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
