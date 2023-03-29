

local graphics = require "graphics"

--[[
    凸多边型碰撞
]]

local CConvex = {}
CConvex.__index = CConvex

local function dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y
end

local function is_cross(mina, maxa, minb, maxb)
    return mina >= minb or mina <= maxb or maxa >= minb or maxa <= maxb
end

--[x,y是坐标点，而points则是相对该坐标系的点]
function CConvex:init(x,y, points)
    self.points = points
    self.x = x
    self.y = y

end

--转换世界坐标的points
function CConvex:world_points()
    local points = {}
    local vec_x,vec_y = graphics.default_coordinate_system(0)
    for _ , point in ipairs(self.points) do
        local x,y = graphics.trans2world_pos(self.x , self.y, vec_x, vec_y, point.x, point.y)
        table.insert(points, {
            x = x,
            y = y,
        })
    end
    return points
end

--获取所有分离轴
function CConvex:axis_list()
    local len = #self:world_points()
    local vecs = {}
    for i = 1, len do
        local point1 = self.points[i]
        local point2 = self.points[i+1] or self.points[1]
        --偷懒直接用现成的接口，转换为坐标系后,y轴方向就是法向量
        local rad = graphics.two_point_face(point1.x, point1.y, point2.x, point2.y)
        local vec_x, vec_y = graphics.default_coordinate_system(rad)
        table.insert(vecs, vec_y)
    end
    return vecs
end



--获取向量方向上的投影
function CConvex:get_projection(vec, points)
    points = points or self:world_points()
    local min,max = nil
    for i = 1, #points do
        local point = points[i]
        local val = dot(point, vec)
        if not min or val < min then
            min = val
        end
        if not max or val > max then
            max = val
        end
    end
    return min, max
end


function CConvex:check_collision(convex)
    local axis1 = self:axis_list()
    local axis2 = convex:axis_list()
    local axiss = axis1
    for _, v in ipairs(axis2) do
        table.insert(axiss, v)
    end
    local points1 = self:world_points()
    local points2 = convex:world_points()
    for _, vec in ipairs(axiss) do
        local mina,maxa = self:get_projection(vec, points1)
        local minb,maxb = convex:get_projection(vec, points2)
        if not is_cross(mina,maxa, minb,maxb) then
            return false
        end
    end
    return true
end


function CConvex:draw()
    local points = self:world_points()
    local points2 = {}
    for _, point in ipairs(points) do
        table.insert(points2, point.x)
        table.insert(points2, point.y)
    end
    --points2 = {100, 100, 150, 50, 200, 100, 200, 200, 150, 250, 100, 200}
    love.graphics.polygon("line", points2)
end


local M = {}
function M.new(x, y, points)
    local obj = setmetatable({}, CConvex)
    obj:init(x, y, points)
    return obj
end

return M


