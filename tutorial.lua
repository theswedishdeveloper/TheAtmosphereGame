function drawTutorial()

    local titleFont = love.graphics.newFont("assets/space_font.otf", 30)
    local greenColorRGB = {0, 1, 0, 1}

    love.graphics.setColor(greenColorRGB)

    love.graphics.setFont(titleFont)

    local centerX = love.graphics.getWidth() / 2
    local textY = love.graphics.getHeight() / 4 * 3
    
    local text = "Use W to move UP"

    love.graphics.print(text, centerX - titleFont:getWidth(text) / 2, textY)

    textY = textY + titleFont:getHeight(text)
    text = "Use A to move LEFT"

    love.graphics.print(text, centerX - titleFont:getWidth(text) / 2, textY)

    textY = textY + titleFont:getHeight(text)
    text = "Use S to move DOWN"
    
    love.graphics.print(text, centerX - titleFont:getWidth(text) / 2, textY)

    textY = textY + titleFont:getHeight(text)
    text = "Use D to move RIGHT"

    love.graphics.print(text, centerX - titleFont:getWidth(text) / 2, textY)

    -- Reset the screen colors
    RESET_SCREEN_COLORS()

end

