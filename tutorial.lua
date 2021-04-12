
function DRAW_GAME_TUTORIAL()

    local titleFont = love.graphics.newFont("assets/space_font.otf", 25)
    local greenColorRGB = {0, 1, 0, 1}
    local centerX = love.graphics.getWidth() / 2
    local textY = love.graphics.getHeight() / 5 * 4
    local text = "Steering: W, A, S, D"

    love.graphics.setColor(greenColorRGB)

    love.graphics.setFont(titleFont)

    love.graphics.print(text, centerX - titleFont:getWidth(text) / 2, textY)

    text = "Pause (P), Resume (P) and Restart (R)"
    textY = textY + titleFont:getHeight(text) + 10

    love.graphics.print(text, centerX - titleFont:getWidth(text) / 2, textY)

    text = "Beware of the rocks on the way down!"
    textY = textY + titleFont:getHeight(text) + 15

    love.graphics.print(text, centerX - titleFont:getWidth(text) / 2, textY)

    -- Reset the screen colors
    RESET_SCREEN_COLORS()

end

