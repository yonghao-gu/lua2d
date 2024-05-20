
local log = require "log"
local Utils = require "utils"
local graphics = require "graphics"

local astar = require "astar"

local M = {}


M.space = 0
M.walk = 1


local map_mt = {}
map_mt.__index = map_mt

function map_mt:init( path)
    self.width = 0
    self.heigth = 0
    self.path = path
    self.data = {}
    self.gride_size = 25
    --右上角的坐标
    self.x = 0
    self.y = 0
    self:load(path)
end

function map_mt:set_pos(x,y)
    self.x = x
    self.y = y
end

function map_mt:set_find_path(path)
    local function set_path(path)
        if not path then
            return None
        end
        local tmp = {}
        for _, node in ipairs(path) do
            if not tmp[node.x] then
                tmp[node.x] = {}
            end
            tmp[node.x][node.y] = true
        end
        return tmp
    end
    self.find_path = set_path(path)
end

function map_mt:set_find_pos(start, target)
     local is_find = true
    --  if not self.start_pos or self.start_pos.x ~= start.x or self.start_pos.y ~= start.y 
    --     or not self.target_pos or self.target_pos.x ~= target.x or self.target_pos.y ~= target.y 
    --  then
    --     is_find = true
    -- end
    self.start_pos = start
    self.target_pos = target
    if is_find then
        local map_path = M.astar(self, { x= start.x, y= start.y }, { x= target.x, y = target.y })
        self:set_find_path(map_path)
    end
end

function map_mt:load(path)
    local file = io.open(path, "r")
    local idx = 1
    for line in file:lines() do
        if idx == 1 then
            local nlist = Utils.split(line, ",")
            self.width = tonumber(nlist[1])
            self.height= tonumber(nlist[2])
            for x = 1, self.width do
                self.data[x] = {}
                for y = 1, self.height do
                    self.data[x][y] = M.space
                end
            end
        else
            local y = idx - 1
            local x = 1
            for match in string.gmatch(line, ".") do
                if x <= self.width and y <= self.height then
                    if match == "*" then
                        self.data[x][y] = M.walk
                    end
                end
                x = x + 1
            end
        end
        idx = idx + 1
    end
    file:close()
    log.log_Info("init map")
end

function map_mt:info()
    return {
        width = self.width,
        height = self.height,
        data = self.data,
        path = self.path,
    }
end

function map_mt:world_pos(x, y)
    return graphics.trans2world_pos( self.x, self.y, {x=1, y = 0,}, {x = 0, y =1 }, x,y)
end

function map_mt:draw()
    local wx,wy
    local flag
    local color
    for x = 1, self.width do
        wx,wy = self:world_pos(x*self.gride_size, -1 * self.gride_size)
        love.print_message(wx,wy, tostring(x))
    end
    for y = 1, self.height do
        wx,wy = self:world_pos(-1*self.gride_size, y * self.gride_size)
        love.print_message(wx,wy, tostring(y))
    end

    for x = 1, self.width do
        for y = 1, self.height do
            flag = self.data[x][y]
            wx,wy = self:world_pos(x*self.gride_size,y*self.gride_size)
            color = {0,0,0}
            if flag == M.walk then
                color = {255, 0, 0}
            elseif self.start_pos and self.start_pos.x == x and self.start_pos.y == y then
                color = {0, 0, 255}
            elseif self.target_pos and self.target_pos.x == x and self.target_pos.y == y then
                color = {255, 0, 255}
            elseif self.find_path and self.find_path[x] and self.find_path[x][y] then
                color = {0, 255, 0}
            
            end
            love.color_func(255, 255, 255 , function()
                love.easy_rect(wx, wy, self.gride_size, self.gride_size, 0)
            end)  
            love.color_func(color[1], color[2], color[3] , function()
                love.easy_rect(wx, wy, self.gride_size-2, self.gride_size-2, 0, "fill")
            end)
        end
    end
end

function M.load_map(path)
    local obj = setmetatable({}, map_mt)
    obj:init(path)
    log.log_Info("map:", obj:info())
    return obj
end


function M.astar(map, start_pos, end_pos)
    return astar(map, start_pos, end_pos)
end


return M

