local SHOW_SETTINGS = false
local menuButtons = {}
local settingsButtons = {}
local buttonHeight = 70
local buttonMargin = 32
local scaleFactor = 0.5
local buttonColor = {0.4, 0.4, 0.4, 1.0}
local buttonHoveredColor = {0.7, 0.7, 0.7, 1.0}
local cursorY

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
    cursorY = 0

    if(not SHOW_SETTINGS) then

     local buttonsPanelHeight = #menuButtons * (buttonHeight + buttonMargin)

     for i, button in ipairs(menuButtons) do

        --Check if button is hovered or clicked
        handleButton(button, windowWidth, windowHeight, buttonWidth, buttonsPanelHeight, cursorY)

     end

   else 

    local index = 0

    local buttonsPanelHeight = #settingsButtons * (buttonHeight + buttonMargin)

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

        --Check if button is hovered or clicked
        handleButton(button, windowWidth, windowHeight, buttonWidth, buttonsPanelHeight)

        index = index + 1

      end

    end

    -- Draw Game Title
    if(not IS_GAME_OVER) then
      local text = "The Atmosphere Game"
      local titleFont = love.graphics.newFont("assets/space_font.otf", windowWidth * (1 / 20))
      love.graphics.setFont(titleFont)
      love.graphics.print(text, love.graphics.getWidth() * (1/2) - titleFont:getWidth(text) / 2, love.graphics.getHeight() * (1 / 7))
    end
	
end

function handleButton(button, windowWidth, windowHeight, buttonWidth, buttonsPanelHeight)

    button.firstClick = button.lastClick

    local mouseX, mouseY = love.mouse.getPosition()

    local buttonX = (windowWidth * scaleFactor) - (buttonWidth * scaleFactor)

    local buttonY = (windowHeight * scaleFactor) -(buttonsPanelHeight * scaleFactor) + cursorY

    local isButtonHovered = mouseX > buttonX and mouseX < buttonX + buttonWidth and mouseY > buttonY and mouseY < buttonY + buttonHeight

    -- Get mouse click state
    button.lastClick = love.mouse.isDown(1)

    -- Check if a button was clicked
    if (button.lastClick and not button.firstClick and isButtonHovered) then
        button.func()
    end

    love.graphics.setColor(isButtonHovered and buttonHoveredColor or buttonColor)

    love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 20, 20)

    love.graphics.setColor(255, 255, 255, 1)

    local textWidth = FONT:getWidth(button.text)
    local textHeight = FONT:getHeight(button.text)

    love.graphics.print(button.text, (windowWidth * scaleFactor) - (textWidth * scaleFactor), buttonY + (textHeight * scaleFactor))

    cursorY = cursorY + (buttonHeight + buttonMargin)
    
end

function NEW_BUTTON(text, func)
    return {text = text, func = func, firstClick = false, lastClick = true}
end
