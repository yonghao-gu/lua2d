local graphics = require "graphics"
local polygon      = require "convex_polygon"



local p1 = polygon.new(100,100, {
    {x=100,y=100,},
    {x=150,y=50,},
    {x=200,y=100,},
    {x=200,y=200,},
    {x=150,y=250,},
    {x=100,y=200,},
})

local p2 = polygon.new(400,200, {
    {x=100,y=100,},
    {x=150,y=50,},
    {x=200,y=100,},
})

function love.update()
    if love.keyboard.isDown('left') then
        p1.x = p1.x - 1
    end
    if love.keyboard.isDown('right') then
        p1.x = p1.x + 1
    end
    if love.keyboard.isDown('up') then
        p1.y = p1.y - 1
    end
    if love.keyboard.isDown('down') then
        p1.y = p1.y + 1

    end
end



function love.draw()
    if p1:check_collision(p2) then
        love.color_func(255,0,0, function()
            p1:draw()
            p2:draw()
        end)
    else
        p1:draw()
        p2:draw()
    end
end




