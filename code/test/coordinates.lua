--[[
    对象坐标系转换测试
]]

local graphics = require "graphics"

local point = {x=100,y=100}
--参考系
local reference = {
    {x = 200, y = 500,rad = math.rad(45)},
    {x = 150, y = 200,rad = math.rad(90)},
    {x = 350, y = 300,rad = math.rad(130)},
    {x = 540, y = 600,rad = math.rad(270)},
}
local idx = 1
local wait = 0
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
    if os.time() - wait > 0 then
        if love.keyboard.isDown('a') then
            idx = idx + 1
            if idx > #reference then
                idx = 1
            end
            wait = os.time()
        end
        if love.keyboard.isDown('d') then
            waite = os.time()
            idx = idx - 1
            if idx <= 0 then
                idx = #reference
            end
        end
    end
end


function love.draw()
    local desc = {
        '通过方向键来移动点，通过ad来选择参考坐标',

    }
    local color = {0,0,0}
    local now = reference[idx]
    for i, t in ipairs(reference) do
        if t ~= now then
            love.draw_reference(t, color, color)
        else
            love.draw_reference(t)
        end
    end
    love.color_func(0,0,255, 
        function() 
            love.graphics.circle("fill", point.x, point.y, 10) 
        end
    )
    local x1,y1 = graphics.world2relative_pos(now.x, now.y, point.x, point.y,  now.rad)
    local s1 = string.format("坐标系世界坐标(%.2f,%.2f),朝向:%.2f度",now.x, now.y, math.deg(now.rad))
    local s2 = string.format("点世界坐标:(%.2f,%.2f), 相对坐标:(%.2f, %.2f)", point.x, point.y, x1,y1)
    table.insert(desc,s1)
    table.insert(desc,s2)
    love.print_message(0,0,desc)
end
