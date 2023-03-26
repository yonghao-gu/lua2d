local graphics = require "graphics"

--[[
    圆和几何相交测试
    
]]

local circle = {x=100,y=100, r = 20}


function love.update()
    if love.keyboard.isDown('left') then
        circle.x = circle.x - 1
    end
    if love.keyboard.isDown('right') then
        circle.x = circle.x + 1
    end
    if love.keyboard.isDown('up') then
        circle.y = circle.y - 1
    end
    if love.keyboard.isDown('down') then
        circle.y = circle.y + 1
    end
end

local rect = {x=400,y=300, width = 100, height = 200, rad=math.rad(600)}
local circle2 = { x= 60, y=450, r= 60}
local arc = {x=500, y =400, r = 200, rad=math.rad(0), rad1 = math.rad(45), rad2 = -math.rad(45)}


function love.draw()
    local desc = {
        '通过方向键来移动点,在图形内时会变红',
        string.format("当前点坐标[%d %d]", circle.x, circle.y)
    }

    love.color_func(0,0,255, 
        function() 
            love.graphics.circle("line", circle.x, circle.y, circle.r) 
        end
    )
    local color1 = {255,0,0}
    local color2 = {255,255,255}
    local color  = color2
    --矩形碰撞
    if graphics.collision_circle_rect(circle.x, circle.y,circle.r, rect.x, rect.y, rect.width, rect.height, rect.rad) then
        color = color1
    end
    love.color_func(color[1],color[2], color[3], function()
        love.easy_rect(rect.x, rect.y, rect.width, rect.height, rect.rad)
    end)
    color  = color2
    --圆形碰撞
    if graphics.collision_circle_circle(circle.x, circle.y,circle.r, circle2.x, circle2.y, circle2.r) then
        color = color1
    end
    love.color_func(color[1],color[2], color[3], function()
        love.graphics.circle("line", circle2.x, circle2.y,circle2.r)
    end)
    --弧形碰撞
    color  = color2
    if graphics.collision_circle_arc(circle.x, circle.y, circle.r, arc.x, arc.y, arc.r, arc.rad, arc.rad1, arc.rad2) then
        color = color1
    end
    love.color_func(color[1],color[2], color[3], function()
        love.easy_arc(arc.x, arc.y, arc.r, arc.rad, arc.rad1, arc.rad2)
    end)
    love.print_message(0,0,desc)
end



