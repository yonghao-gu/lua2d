

local Utils = require "utils"
local log = require "log"
local map = require "map"

local map_obj = nil


map_obj = map.load_map("code/res/map.txt")
map_obj:set_pos(map_obj.gride_size*3,map_obj.gride_size*3)
map_obj:set_find_pos({ x=1, y=1 }, { x= 29, y = 10 })

lastUpdateTime = 0  

function love.update()
    local currentTime = love.timer.getTime() 
    if currentTime - lastUpdateTime < 0.1 then
        return
    end
    log.log_Info("update:", currentTime, currentTime - lastUpdateTime)
    lastUpdateTime = currentTime
    local start_pos =  map_obj.start_pos
    local target_pos = map_obj.target_pos
    if love.keyboard.isDown('left') then
        start_pos.x = math.max(1, start_pos.x - 1)
    end
    if love.keyboard.isDown('right') then
        start_pos.x = math.min(map_obj.width, start_pos.x + 1)
    end
    if love.keyboard.isDown('up') then
        start_pos.y = math.max(1, start_pos.y - 1)
    end
    if love.keyboard.isDown('down') then
        start_pos.y = math.min(map_obj.height, start_pos.y + 1)
    end

    if love.keyboard.isDown('a') then
        target_pos.x = math.max(1, target_pos.x - 1)
    end
    if love.keyboard.isDown('d') then
        target_pos.x = math.min(map_obj.width, target_pos.x + 1)
    end
    if love.keyboard.isDown('w') then
        target_pos.y = math.max(1, target_pos.y - 1)
    end
    if love.keyboard.isDown('s') then
        target_pos.y = math.min(map_obj.height, target_pos.y + 1)
    end
    map_obj:set_find_pos(start_pos, target_pos)
end


function love.draw()
    love.graphics.print("按方向键移动开始节点，wsad移动目标节点", 0, 0)
    local pos_msg = string.format("[%d-%d]开始节点(%d,%d) - 目标节点(%d, %d)",map_obj.width, map_obj.height, map_obj.start_pos.x, map_obj.start_pos.y, map_obj.target_pos.x, map_obj.target_pos.y)
    love.graphics.print(pos_msg, 0, 25)
    map_obj:draw()
end







