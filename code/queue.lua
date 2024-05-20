



local function unpack(t, i)
    i = i or 1
    if t[i] then
        return t[i], unpack(t, i + 1)
    end
end

--[[
    优先级队列--使用堆实现
    默认最小堆, reverse 参数可以改变为最大堆
]]
local CPriorityQueue = {}

CPriorityQueue.__index = CPriorityQueue

function CPriorityQueue:init(reverse)
    self.list = {}
    self.compare = nil --自定义比较函数
    self.reverse = reverse
end

function CPriorityQueue:size()
    return #self.list
end

function CPriorityQueue:is_empty()
    return self:size() == 0
end

function CPriorityQueue:clean()
    self.list = {}
end

function CPriorityQueue:top()
    return self.list[1]
end

function CPriorityQueue:set_compare(func)
    self.compare = func
end

function CPriorityQueue.default_compare(e1, e2)
    return e1[1] > e2[1]
end

function CPriorityQueue.default_compare_reverse(e1, e2)
    return e1[1] < e2[1] 
end



function CPriorityQueue:push(key, value)
    local element = { key , value }
    table.insert(self.list, element)
    local index = #self.list
    local parent = math.floor(index/2)

    local cmp = self.compare or (self.reverse and self.default_compare_reverse) or self.default_compare
    while parent > 0 do
        if cmp(self.list[parent], element) then
            self.list[index] = self.list[parent]
            self.list[parent] = element
            index = parent
            parent = math.floor(index/2)
        else
            break
        end
    end
    return index
end

function CPriorityQueue:pop()
    local element =  self.list[1]
    if not element then
        return
    end
    local len = self:size()
    local last = self.list[len]
    local parent = 1
    local child = nil
    local cmp = self.compare or (self.reverse and self.default_compare_reverse) or self.default_compare
    while( parent <= len ) do
        child = parent * 2 --左子树
        if not self.list[child] then
            break
        end
        if self.list[child + 1] and cmp(self.list[child], self.list[child + 1]) then
            child = child + 1 --右子树
        end
        if cmp(last, self.list[child]) then
            self.list[parent] = self.list[child]
            parent = child
        else
            break
        end
    end

    self.list[parent] = last
    self.list[len] = nil
    return unpack(element)
end



local function _priority_tostring(tbl, result, idx, fix)
    local parent = tbl[idx]
    if not parent then
        return
    end
    table.insert(result, string.format("%s %s", fix, tostring(parent[1])))
    local left = idx * 2
    _priority_tostring(tbl, result, left, fix.."-")
    _priority_tostring(tbl, result, left + 1, fix.."-")
end

function CPriorityQueue:tostring()
    local result = {}
    _priority_tostring(self.list, result, 1, "-")
    return table.concat(result, "\n")
end



return CPriorityQueue
