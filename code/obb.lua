

local graphics = require "graphics"

local CRect  = {}
CRect.__index = CRect


function CRect:init(x,y, width, height, rad)
    --坐标是矩形中心点
    self.x = x
    self.y = y
    self.height = height
    self.width = width
    self.rad = rad
end


function CRect:draw()
    love.easy_rect(self.x, self.y, self.width, self.height, self.rad)
end


function CRect:projection(vec1, vec2)
    return vec1.x * vec2.x + vec1.y * vec2.y
end

--获取两条边的向量
function CRect:line_vec()
    lcoal x1,y1 = graphics.trans2world_pos2(self.x, self.y, self.rad, self.width, 0)
    lcoal x2,y2 = graphics.trans2world_pos2(self.x, self.y, self.rad, 0, self.height)
    return { x = x1, y= y1}, { x = x2, y = y2 }
end

function CRect:check_collision(obb)
    --矩形四个边的法向量和坐标系可以认为一样
    local vec_x, vec_y = graphics.default_coordinate_system(self.rad)
    local vec_x1, vec_y1 = graphics.default_coordinate_system(obb.rad)
    local vec_array = {
        vec_x, vec_y, vec_x1, vec_y1
    }
    --矩形四条边，2条平衡，所以只需要判断2条边即可
    local w1,h1 = self:line_vec()
    local w2,h2 = obb:line_vec()
    local center_v = { x = self.x - obb.x, y = self.y - obb.y}
    
end

