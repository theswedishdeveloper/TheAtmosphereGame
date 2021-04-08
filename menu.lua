local SHOW_SETTINGS = false

local menuButtons = {}
local settingsButtons = {}
local buttonHeight = 80
local buttonMargin = 32
local scaleFactor = 0.5

function SETUP_GAME_MENU()

    table.insert(menuButtons, NEW_BUTTON("START GAME", function() START_GAME() end))
    
    table.insert(menuButtons, NEW_BUTTON("SETTINGS", function() 
        SHOW_SETTINGS = not SHOW_SETTINGS end))

    table.insert(menuButtons, NEW_BUTTON("EXIT GAME", function() love.event.quit(0) end))

    table.insert(settingsButtons, NEW_BUTTON("MUSIC:", function() 
        PLAY_MUSIC = not PLAY_MUSIC
    end))  
    
    table.insert(settingsButtons, NEW_BUTTON("DIFFICULTY:", function() 
        if(DIFFICULTY == "EASY") then
            DIFFICULTY = "NORMAL"
        else if(DIFFICULTY == "NORMAL") then
            DIFFICULTY = "HARD"
        else
            DIFFICULTY = "EASY"
        end
      end
    end))

    table.insert(settingsButtons, NEW_BUTTON("BACK TO MENU", function() 
        SHOW_SETTINGS = false
    end))  
    
end

function RENDER_GAME_MENU()

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local buttonWidth = windowWidth * (1 / 4)
    local buttonsPanelHeight = #menuButtons * (buttonHeight + buttonMargin)
    local cursorY = 0

    if(not SHOW_SETTINGS) then
        
     for i, button in ipairs(menuButtons) do

        button.firstClick = button.lastClick

        local mouseX, mouseY = love.mouse.getPosition()

        local buttonX = (windowWidth * scaleFactor) -
                            (buttonWidth * scaleFactor)

        local buttonY = (windowHeight * scaleFactor) -
                            (buttonsPanelHeight * scaleFactor) + cursorY

        local buttonHovered = mouseX > buttonX and mouseX < buttonX +
                                  buttonWidth and mouseY > buttonY and mouseY <
                                  buttonY + buttonHeight

        local buttonColor = {0.4, 0.4, 0.4, 1.0}

        if (buttonHovered) then 
            buttonColor = {0.8, 0.8, 0.8, 1.0}
        end

        -- Get mouse click state
        button.lastClick = love.mouse.isDown(1)

        -- Check if a button was clicked
        if (button.lastClick and not button.firstClick and buttonHovered) then
            button.func()
        end

        love.graphics.setColor(buttonColor)
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 20, 20)

        love.graphics.setColor(255, 255, 255, 1)

        local textWidth = FONT:getWidth(button.text)
        local textHeight = FONT:getHeight(button.text)

        love.graphics.print(button.text, (windowWidth * scaleFactor) - (textWidth * scaleFactor), buttonY + (textHeight * scaleFactor ^ 2))

        cursorY = cursorY + (buttonHeight + buttonMargin)

    end

   else 


    local index = 0

    for i, button in ipairs(settingsButtons) do

        if(index == 0) then
            if(PLAY_MUSIC) then
                button.text = "MUSIC: ENABLED"                 
            else
                button.text = "MUSIC: DISABLED"
            end
        else if(index == 1) then
            button.text = "DIFFICULTY: "..DIFFICULTY          
          end
        end

        button.firstClick = button.lastClick

        local mouseX, mouseY = love.mouse.getPosition()

        local buttonX = (windowWidth * scaleFactor) -
                            (buttonWidth * scaleFactor)

        local buttonY = (windowHeight * scaleFactor) -
                            (buttonsPanelHeight * scaleFactor) + cursorY

        local buttonHovered = mouseX > buttonX and mouseX < buttonX +
                                  buttonWidth and mouseY > buttonY and mouseY <
                                  buttonY + buttonHeight

        local buttonColor = {0.4, 0.4, 0.4, 1.0}

        if (buttonHovered) then 
            buttonColor = {0.8, 0.8, 0.8, 1.0}
        end

        -- Get mouse click state
        button.lastClick = love.mouse.isDown(1)

        -- Check if a button was clicked
        if (button.lastClick and not button.firstClick and buttonHovered) then
            button.func()
        end

        love.graphics.setColor(buttonColor)
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 20, 20)

        love.graphics.setColor(255, 255, 255, 1)

        local textWidth = FONT:getWidth(button.text)
        local textHeight = FONT:getHeight(button.text)

        love.graphics.print(button.text, (windowWidth * scaleFactor) - (textWidth * scaleFactor), buttonY + (textHeight * scaleFactor ^ 2))

        cursorY = cursorY + (buttonHeight + buttonMargin)

        index = index + 1

    end
 end

    -- Draw game creators name
    local text = "Developed by Benjamin Ojanne"
    love.graphics.print(text, 50, love.graphics.getHeight() - 80)

end

function NEW_BUTTON(text, func)
    return {text = text, func = func, firstClick = false, lastClick = true}
end
