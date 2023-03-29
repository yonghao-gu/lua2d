local graphics = require "graphics"
local polygon      = require "convex_polygon"


local l = 10
local p1 = polygon.new(100,100, {
    {x=0,y=l*2,},
    {x=l,y=l,},
    {x=l,y=-l,},
    {x=0,y=-l*2,},
    {x=-l,y= -l,},
    {x= -l,y= l,},
})
-- p1.draw_axis = true
local p2 = polygon.new(400,200, {
    {x=0 ,y=100,},
    {x=100,y=0,},
    {x=-100,y=0,},
})

local p3_size = 100
local p3 = polygon.new(400,400, {
    {x=p3_size,y=p3_size,},
    {x=p3_size,y=-p3_size,},
    {x=-p3_size,y=-p3_size,},
    {x=-p3_size,y=p3_size,},
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
    local b_collision = false
    if p1:check_collision(p2) then
        b_collision = true
        love.color_func(255,0,0, function()
            p2:draw()
        end)
    else
        p2:draw()
    end

    if p1:check_collision(p3) then
        b_collision = true
        love.color_func(255,0,0, function()
            p3:draw()
        end)
    else
        p3:draw()
    end
    if b_collision then
        love.color_func(255,0,0, function()
            p1:draw()
        end)
    else
        p1:draw()
    end
end




