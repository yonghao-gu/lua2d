local graphics = require "graphics"



local font_size = 15
function love.load()
    local newfont = love.graphics.newFont("STXIHEI.TTF", font_size)
    love.graphics.setFont(newfont)
end

function love.easy_rect(x, y, width, height, rad)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(rad)
    love.graphics.rectangle("line", -width/2, -height/2, width, height)
    love.graphics.pop()
end

function love.easy_arc(x, y, r, rad, rad1, rad2)
    assert(rad1>=0 and rad1 <=math.pi and rad2<=0 and rad2 >= -math.pi)
    love.graphics.arc("line", x, y, r, rad+rad1,rad+rad2)
    --love.graphics.arc("line", 400, 300, 100, 0, math.pi )
end

-- ALT + L
local key
function love.update()
    for i = 1,9 do
        if love.keyboard.isDown(tostring(i)) then
            key = i
            break
        end
    end
end

local menu = {
    "请按以下按钮，进入测试模块",
    "1:对象坐标测试",
    "2:点和图形测试",
    "3:圆和其他图形测试",
    "4:OBB旋转矩形",
    "5:凸边形-分离轴测试",
    "6:线段相交测试",
}

function love.draw()
    if not key then
        local width = love.graphics.getWidth()
        local height = love.graphics.getHeight()
        x = width/4
        y = height/3
        love.print_message(x, y, menu)
        -- for i,s in ipairs(menu) do
        --     love.graphics.print(s, x, y + i * 30)
        -- end
    else
        if key == 1 then
            require "test.coordinates"
        elseif key == 2 then
            require "test.point_geometry"
        elseif key == 3 then
            require "test.circle_geometry"
        elseif key == 4 then
            require "test.obb_example"
        elseif key == 5 then
            require "test.polygon_example"
        elseif key == 6 then
            require "test.cross_segment"
        end
    end
end


function love.print_message(x,y,...)
    local tbl = {...}
    if type(tbl[1]) == 'table' then
        tbl= tbl[1]
    end

    for i,s in ipairs(tbl) do
        love.graphics.print(s, x, y+i*font_size)
    end
end

function love.color_func(r1,r2,r3, func)
    local b1,b2,b3,b4
    b1,b2,b3,b4 = love.graphics.getColor()
    love.graphics.setColor(r1,r2,r3)
    func()
    love.graphics.setColor(b1,b2,b3,b4)
end

--按照点来画一个三角形
function love.draw_triangle(x,y, rad, r)
    local x1,y1 = graphics.trans2world_pos2(x,y, rad, r, 0)
    local x2,y2 = graphics.trans2world_pos2(x,y, rad, 0, r)
    local x3,y3 = graphics.trans2world_pos2(x,y, rad, 0, -r)
    love.graphics.line(x1,y1, x2,y2)
    love.graphics.line(x1,y1, x3,y3)
    love.graphics.line(x2,y2, x3,y3)
    --love.graphics.triangle( mode, x1, y1, x2, y2, x3, y3 ) --版本没有该函数
end

function love.draw_reference(t, x_color, y_color)
    local rad = t.rad
    x_color = x_color or {255,0,0} --默认红色是x轴
    y_color = y_color or {0,255,0}
    love.graphics.circle("fill", t.x, t.y, 5)
    local start_x,start_y = graphics.point_move(t.x, t.y, rad, 100)
    local end_x, end_y = graphics.point_move(t.x, t.y, graphics.turn_face(rad), 100)
    love.color_func(x_color[1],x_color[2], x_color[3], function()
        love.graphics.line(start_x, start_y, end_x, end_y)
        love.draw_triangle(start_x,start_y, rad, 5)
    end)
    rad = rad+math.rad(90)
    start_x,start_y = graphics.point_move(t.x, t.y, rad, 100)
    end_x, end_y = graphics.point_move(t.x, t.y, graphics.turn_face(rad), 100)
    love.color_func(y_color[1],y_color[2],y_color[3], function()
        love.graphics.line(start_x, start_y, end_x, end_y)
        love.draw_triangle(start_x,start_y, rad, 5)
    end)
end
