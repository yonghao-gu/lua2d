

local graphics = require "graphics"

local CRect  = {}
CRect.__index = CRect

local function dot(vec1, vec2)
    return math.abs(vec1.x * vec2.x + vec1.y * vec2.y)
end


function CRect:init(x,y, width, height, rad)
    --坐标是矩形中心点
    self.x = x
    self.y = y
    self.height = height
    self.width = width
    self.rad = rad
 
end

function CRect:set_deg(deg)
    self.rad = math.rad(math.deg(self.rad) + deg)
end

function CRect:draw()
    love.easy_rect(self.x, self.y, self.width, self.height, self.rad)
end



function CRect:projection(vec_x, vec_y, vec1)
    local a = dot(vec_x, vec1)
    local b = dot(vec_y, vec1)

    return (a * self.width+ b * self.height)/2
end



function CRect:check_collision(obb)
    --矩形四个边的法向量和坐标系可以认为一样
    local vec_x, vec_y = graphics.default_coordinate_system(self.rad)
    local vec_x1, vec_y1 = graphics.default_coordinate_system(obb.rad)
    local vec_array = {
        vec_x, vec_y, vec_x1, vec_y1
    }
    local center_v = { x = self.x - obb.x, y = self.y - obb.y}
    for _, vec in ipairs(vec_array) do
        if self:projection(vec_x, vec_y, vec) + obb:projection( vec_x1, vec_y1, vec) < dot( center_v, vec) then
            return false
        end
    end
    return true
end



local M  = {}

function M.new_rect(x, y,  width, height, rad)
    local obj = setmetatable({}, CRect)
 
    obj:init(x, y, width, height, rad)
    return obj
end
return M
