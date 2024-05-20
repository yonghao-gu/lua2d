
local queue = require "queue"




local Queue = setmetatable({}, queue)

Queue:init()

Queue:set_compare(function(e1, e2)
    return e1[1] > e2[1]
end)



local Node = {}
Node.__index = Node
Node.__eq = function(p1, p2)
    return p1.x == p2.x and p1.y == p2.y
end

Node.__lt = function(t1, t2)
    return t1.f < t2.f
end


Node.__le = function(t1, t2)
    return t1.f <= t2.f
end


function Node:init(x, y, parent)
    --self.pos = {x = x, y = y}
    self.x = x
    self.y = y
    self.parent = parent --父节点
    self.g = 99999999999999999999
    self.h = 0
    self.f = 99999999999999999999 -- g+h
end



local function new_node(x, y , parent)
    local obj = setmetatable({}, Node)
    obj:init(x, y, parent)
    return obj
end



--计算曼哈顿距离
local function ManhattanDistance(x1,y1, x2, y2)
    return math.abs(x1-x2) + math.abs(y1-y2)
end



local function pos_id(pos)
    return pos.x * 100000 + pos.y
end


local function get_neighbors(map_obj, parent)
    local mmap = map_obj.data
    local directions = { {0,1},{0,  -1}, { -1, 0}, {1, 0} }
    local new_nodes = {}
    for _, v in ipairs(directions) do
        local x = parent.x + v[1]
        local y = parent.y + v[2]
        if not ( x<= 0 or y <= 0 or not mmap[x] or not mmap[x][y] or mmap[x][y] == 1 ) then
            local node =new_node(x, y, parent)
            table.insert(new_nodes, node)
        end
    end
    return new_nodes
end


local function astar(map_obj, start, target)
    Queue:clean()
    local open_list = {}
    local closed_list = {}
    local mmap = map_obj.data
    if mmap[start.x][start.y] == 1 or  mmap[target.x][target.y] == 1 then
        return nil
    end
    local start_node = new_node(start.x, start.y)
    local target_node = new_node(target.x, target.y)

    start_node.g = 0
    start_node.h = ManhattanDistance(start.x, start.y, target.x, target.y)
    start_node.f = start_node.h

    Queue:push(start_node, start_node)
    open_list[pos_id(start_node)] = true
    while Queue:size() > 0 do
        local current_node,_  = Queue:pop()
        closed_list[pos_id(current_node)] = true
        if current_node == target_node then
            local path = {}
            while current_node.parent do
                table.insert(path, current_node)
                current_node = current_node.parent
            end
            table.insert(path, start_node)
            return path
        end
        local new_nodes = get_neighbors(map_obj, current_node)
        for _, neighbor in ipairs(new_nodes) do
            local tentative_g = current_node.g + 1
            if  not open_list[pos_id(neighbor)] or tentative_g < neighbor.g then
                neighbor.parent = current_node
                neighbor.g = tentative_g
                neighbor.h = ManhattanDistance(neighbor.x, neighbor.y, target_node.x, target_node.y)
                neighbor.f = neighbor.g + neighbor.h
                if not open_list[pos_id(neighbor)] then
                    open_list[pos_id(neighbor)] = true
                    Queue:push(neighbor, neighbor)
                end
            end
        end
    end
    return nil
end

return astar
