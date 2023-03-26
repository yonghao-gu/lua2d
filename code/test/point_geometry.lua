

local graphics = require "graphics"

--[[
    点和几何相交测试
    
]]

local point = {x=100,y=100}

function love.update()
    if love.keyboard.isDown('left') then
        point.x = point.x - 1
    end
    if love.keyboard.isDown('right') then
        point.x = point.x + 1
    end
    if love.keyboard.isDown('up') then
        point.y = point.y - 1
    end
    if love.keyboard.isDown('down') then
        point.y = point.y + 1
    end
end



local rect = {x=400,y=300, width = 100, height = 200, rad=math.rad(600)}
local circle = { x= 60, y=450, r= 60}
local arc = {x=500, y =400, r = 200, rad=math.rad(0), rad1 = math.rad(45), rad2 = -math.rad(45)}

function love.draw()
    local desc = {
        '通过方向键来移动点,在图形内时会变红',
        string.format("当前点坐标[%d %d]", point.x, point.y)
    }
    love.color_func(0,0,255, 
        function() 
            love.graphics.circle("fill", point.x, point.y, 5) 
        end
    )
    local color1 = {255,0,0}
    local color2 = {255,255,255}
    local color  = color2
    if graphics.in_rect_arena(rect.x, rect.y, rect.width, rect.height, rect.rad, point.x, point.y) then
        color = color1
    end
    love.color_func(color[1],color[2], color[3], function()
        love.easy_rect(rect.x, rect.y, rect.width, rect.height, rect.rad)
    end)
    color  = color2
    if graphics.in_circle_arena(circle.x, circle.y,circle.r, point.x, point.y) then
        color = color1
    end
    love.color_func(color[1],color[2], color[3], function()
        love.graphics.circle("line", circle.x, circle.y,circle.r)
    end)

    color  = color2
    if graphics.in_arc_arena2(arc.x, arc.y, arc.r, arc.rad, arc.rad1, arc.rad2, point.x, point.y) then
        color = color1
    end
    love.color_func(color[1],color[2], color[3], function()
        love.easy_arc(arc.x, arc.y, arc.r, arc.rad, arc.rad1, arc.rad2)
    end)


    love.print_message(0,0,desc)
end
