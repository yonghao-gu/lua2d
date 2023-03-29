local graphics = require "graphics"
local obb      = require "obb"



local rect1 = obb.new_rect(200, 200,  200, 300, 0)

local rect2 = obb.new_rect(300, 400,  400, 300, 0)

function love.update()
    if love.keyboard.isDown('left') then
        rect1.x = rect1.x - 1
    end
    if love.keyboard.isDown('right') then
        rect1.x = rect1.x + 1
    end
    if love.keyboard.isDown('up') then
        rect1.y = rect1.y - 1
    end
    if love.keyboard.isDown('down') then
        rect1.y = rect1.y + 1
    end
    if love.keyboard.isDown('1') then
        rect1:set_deg(1)
    end
    if love.keyboard.isDown('3') then
        rect1:set_deg(-1)
    end

    if love.keyboard.isDown('a') then
        rect2.x = rect2.x - 1
    end
    if love.keyboard.isDown('d') then
        rect2.x = rect2.x + 1
    end
    if love.keyboard.isDown('w') then
        rect2.y = rect2.y - 1
    end
    if love.keyboard.isDown('s') then
        rect2.y = rect2.y + 1
    end
    if love.keyboard.isDown('q') then
        rect2:set_deg(1)
    end
    if love.keyboard.isDown('e') then
        rect2:set_deg(-1)
    end


end



function love.draw()
    local desc = {
        '蓝色矩形通过方向键来移动,1,3来旋转',
        '绿色矩形通过aswd来移动，q,e来旋转',
        '相交会变红',
    }

    if rect1:check_collision(rect2) then
        love.color_func(255,0,0, function()
            rect1:draw()
            rect2:draw()
        end)
    else
        love.color_func(0,0,255, function()
            rect1:draw()
        end)
        love.color_func(0,255,0, function()
            rect2:draw()
        end)
    end


    love.print_message(0,0,desc)
end


