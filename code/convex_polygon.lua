

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
    return (mina >= minb and mina <= maxb) or ( maxa >= minb and maxa <= maxb) or (minb >= mina and minb <= maxa ) or (maxb >= mina and maxb <= maxa ) 
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
        local distance = graphics.point_distance(point1.x, point1.y, point2.x, point2.y)
        local vec = { x = (point2.y - point1.y)/distance,  y = (point2.x-point1.x)/distance }
        table.insert(vecs, vec)
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
    local desc = {
        string.format("长度:%d (%f,%f)", #axiss, self.x, self.y)
    }

    local points1 = self:world_points()
    local points2 = convex:world_points()
    local tt = {}
    for _, p in ipairs(points1) do
        table.insert(tt, string.format("(%d-%d) ", p.x, p.y))
    end
    table.insert(desc, table.concat(tt, "|"))
    for _, vec in ipairs(axiss) do
        local mina,maxa = self:get_projection(vec, points1)
        local minb,maxb = convex:get_projection(vec, points2)

        table.insert(desc, string.format("[%f,%f]映射：(%.2f ,%.2f) || （%.2f， %.2f）",vec.x,vec.y, mina,maxa, minb,maxb))
        if not is_cross(mina,maxa, minb,maxb) then
            if self.draw_axis then
                love.print_message(self.x,self.y,desc)
            end
            return false
        end
    end
    if self.draw_axis then
        love.print_message(self.x,self.y,desc)
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
    love.graphics.polygon("line", points2)
    if self.draw_axis then
        local  axiss = self:axis_list()
        for _, vec in ipairs(axiss) do
            local x2,y2 = vec.x * 100, vec.y * 100
            x2,y2 = graphics.trans2world_pos2(self.x, self.y, 0, x2,y2)
            love.graphics.line(self.x, self.y, x2,y2)
        end
    end
end


local M = {}
function M.new(x, y, points)
    local obj = setmetatable({}, CConvex)
    obj:init(x, y, points)
    return obj
end

return M


