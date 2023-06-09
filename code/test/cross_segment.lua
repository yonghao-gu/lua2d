

local graphics = require "graphics"

local line1 = { x1 = 100, y1 = 100, x2 = 400, y2 = 100}
local line2 = { x1 = 100, y1 = 100, x2 = 400, y2 = 100}

function love.update()
    if love.keyboard.isDown('left') then
        line1.x1 = line1.x1  - 1
    end

    if love.keyboard.isDown('right') then
        line1.x1 = line1.x1  + 1
    end
    if love.keyboard.isDown('up') then
        line1.y1 = line1.y1  - 1
    end
    if love.keyboard.isDown('down') then
        line1.y1 = line1.y1  + 1
    end

    if love.keyboard.isDown('a') then
        line1.x2 = line1.x2  - 1
    end

    if love.keyboard.isDown('d') then
        line1.x2 = line1.x2  + 1
    end
    if love.keyboard.isDown('w') then
        line1.y2 = line1.y2  - 1
    end
    if love.keyboard.isDown('s') then
        line1.y2 = line1.y2  + 1
    end
    
end

function love.draw()
    local desc = {
        '通过方向键和adws来移动蓝色线段的两个端点',
        string.format('绿线坐标[%.2f,%.2f]-[%.2f,%.2f]',line2.x1, line2.y1, line2.x2, line2.y2),
        string.format('移动线坐标[%.2f,%.2f]-[%.2f,%.2f]',line1.x1, line1.y1, line1.x2, line1.y2),
    }

    love.color_func(0,255,0, 
        function() 
            love.graphics.line(line2.x1, line2.y1, line2.x2, line2.y2)
        end
    )

    local a1,a2 =  graphics.cross_segment(line2.x1, line2.y1, line2.x2, line2.y2, line1.x1, line1.y1, line1.x2, line1.y2)
    if a1 then
        love.color_func(255,0,0, 
        function() 
            love.graphics.line(line1.x1, line1.y1, line1.x2, line1.y2)
        end
        )
        table.insert(desc, string.format("相交，相交点位[%.2f, %.2f]", a1,a2))
    else
        love.color_func(0,0,255, 
        function() 
            love.graphics.line(line1.x1, line1.y1, line1.x2, line1.y2)
        end
        )
        table.insert(desc, "不相交")
    end

    love.print_message(0,0,desc)
end
