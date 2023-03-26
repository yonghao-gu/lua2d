

--[[
    工具盒，乱七八糟的与平台无关的方法
    原则上均为函数，并且参数不应该有对象
    规则1：矩形的构造
        中心点:位于矩形中心
        长: 平行于x轴的边（策划要求），很多画图接口定义为宽width，所以这里要注意
        宽：平行于y轴的边，很多接口定义为height高，需要注意
    规则2：碰撞定义，如果点在边上，则认为是相交
]]

--赋值变量来提升一点微不足道的效率
local pi = math.pi
local pi2 = pi * 2

local math_cos = math.cos
local math_sin = math.sin
local math_random = math.random
local math_abs = math.abs
local math_sqrt = math.sqrt
local math_rad  = math.rad
local table_insert = table.insert
local string_gsub = string.gsub
local math_asin   = math.asin
local math_deg    = math.deg

local M = {}

--------------------------------------
-- lua相关
---------------------------------------


--浅拷贝
function M.clone(t)
    local T = {}
    for k,v in pairs(t) do
        T[k] = v 
    end
    return T
end

--T中元素不能有元表
function M.deep_clone(T)
    local mark={}
    local function copy_table(t)
        if type(t) ~= 'table' then return t end
        local res = {}
        for k,v in pairs(t) do
            if type(v) == 'table' then
                if not mark[v] then
                    mark[v] = copy_table(v)
                end
                res[k] = mark[v]
            else
                res[k] = v
            end
        end
        return res
    end
    return copy_table(T)
end

--简单的面向对象
function M.simple_class(clss)
    local c = {}
    if clss then
        c = setmetatable({}, clss)
    end
    c.__index = c
    return c
end

--创建一个简单对象
function M.new_obj(clss, ...)
    local obj = setmetatable({}, clss)
    obj:init(...)
    return obj
end 

--table hash
function M.table_val_max(tbl)
    local max = nil
    local key = nil
    for k,v in pairs(tbl) do
        if not max or max < v then
            max = v
            key = k
        end
    end
    return key, max
end


--返回key 列表
function M.table_keys(tbl)
    local list = {}
    for k,v in pairs(tbl) do
        list[#list+1] = k
    end
    return list
end

--返回val列表
function M.table_vals(tbl)
    local list = {}
    for k,v in pairs(tbl) do
        list[#list+1] = v
    end
    return list
end

--从列表里随机一个值
function M.random_list(list)
    if not next(list) then
        return nil
    end
    local idx = math_random(1, #list)
    return list[idx]
end

--从tables随机一个值，is_key随机key值，否则随机value
function M.random_table_kv(tbl, is_key)
    local list
    if is_key then
        list = M.table_keys(tbl)
    else
        list = M.table_vals(tbl)
    end
    return M.random_list(list)
end

--字符串split操作
function M.split(s, p)
    local rt= {}
    string_gsub(s, '[^'..p..']+', function(w)
        table_insert(rt, w) 
    end)
    return rt
end

function M.in_array(list, val)
    for k,v in ipairs(list) do
        if v == val then
            return k
        end
    end
end

-----------------------------------------
-- 坐标/弧度相关
-----------------------------------------


--角度转弧度
function M.degree2rad(degree)
    return math_rad(degree%360)
end

--获取反方向
function M.turn_face(rad)
    return (rad+pi)%pi2
end


--已知一点，求朝向
function M.point_to_arc(x, y)
    if x == 0 and y == 0 then --零向量特殊处理
        return 0
    end
    local z = math_sqrt(x ^ 2 + y ^ 2)
    local arc = math_asin(math_abs(y) / z)
    if y >= 0 then
        if x < 0 then
            arc = pi - arc
        end
    else
        if y < 0 then
            if x < 0 then
                arc = pi + arc
            else
                arc = pi2 - arc
            end
        end
    end
    return arc
end



--求点（x1,z1）向点(x2,z2)的朝向
function M.two_point_face(x1, z1, x2, z2)
    --向量2-向量1
    local x = x2 - x1
    local z = z2 - z1
    return M.point_to_arc(x, z)
end



--[[
默认的获取单位的坐标轴的方法，返回x轴和z轴的单位向量（x=x,y=y）
我们认为一个单位的正面朝向为+x轴方向
@rad:单位朝向
]]
function M.default_coordinate_system(rad)
    local vec_x = { x = math_cos(rad),  z = math_sin(rad) }
    local vec_z = { x = -math_sin(rad), z = math_cos(rad) }
    return vec_x, vec_z
end

--[[ 
将对象坐标进行偏移，然后转为世界坐标
@ox,oy: 原点的世界坐标
@vec_x,vec_y，对象坐标的x,y轴单位向量
    对于旋转矩形，为vec_x,vec_y为垂直边框的法线，vec_x的正方向是对象的朝向
@x,y 偏移的坐标
@rad 旋转的弧度
]]
function M.trans2world_pos(ox, oz, vec_x, vec_z, x, z, rad)
    --先算旋转偏移
    if rad and rad ~= 0 then
        local r = math_sqrt(x^2+z^2)
        x =  r * math_cos(rad)
        z =  z * math_sin(rad)
    end
    local gx = ox + vec_x.x*x + vec_z.x*z
    local gz = oz + vec_x.z*x + vec_z.z*z
    return gx, gz
end


--[[ 
将对象坐标进行偏移，然后转为世界坐标,对trans2world_pos再封装
@ox,oy: 原点的世界坐标
@orad: 对象的朝向
@x,y 偏移的坐标
@rad 旋转的弧度
]]
function M.trans2world_pos2(ox, oz,orad, x, z, rad)
    --先算旋转偏移
    local vec_x, vec_z = M.default_coordinate_system(orad)
    return M.trans2world_pos(ox, oz, vec_x, vec_z, x, z, rad)
end



--[[
将世界坐标转换为对象坐标
@ox,oz: 原点的世界坐标
@px,pz 世界坐标
@rad: 旋转弧度（对单位来说就是朝向）
]]
function M.world2relative_pos(ox, oz, gx, gz, rad)
    local nx = gx - ox
    local nz = gz - oz
    local x = nx * math_cos(rad) + nz * math_sin(rad)
    local z = nz * math_cos(rad) - nx * math_sin(rad) 
    -- local x = vec_x.x * nx - vec_z.z * nz
    -- local z = vec_x.z * nx + vec_z.z * nz 
    return x,z
end


--[[
求原点与坐标的夹角
@x,z,rad:原点和朝向
@px,pz:世界坐标
@fix：角度修正，取最少夹角，并且为正
]]
function M.arc_angle(ox, oz, rad, px, pz, fix)
    local nx,nz = M.world2relative_pos(ox, oz, px, pz, rad)
    local arc = M.point_to_arc(nx, nz)
    if fix and arc > pi then
        arc = pi2 - arc
    end
    return math_deg(arc)
end


----------------------------------------------------------------
-- 几何相关
-----------------------------------------------------------------


------------------------- 点和线 ------------------------


--2点距离
function M.point_distance(x1,z1, x2, z2)
    return math_sqrt((x1-x2)^2 + (z1-z2)^2)
end

function M.point_square_distance(x1, z1, x2, z2)
    return (x1-x2)^2 + (z1-z2)^2
end

--[[
求从点(x1,z1)到点(x2,z2)上，距离为distance的点坐标,ray表示是否为射线，否则为线段
如果2点是重合，那么直接返回x1,z1
ray不是射线且2点距离小于distance，那么返回x2,z2

]]
function M.line_point(x1, z1, x2, z2, distance, ray)
    --求线段的向量，再求弧度，最后乘以distance即可
    local x3 = x2 - x1
    local z3 = z2 - z1
    local dst = M.point_distance(x3, z3, 0, 0)
    if dst == 0 then
        return x1, z1
    end
    if not ray and dst <= distance then
        return x2, z2
    end
    return M.point_move(x1, z1, M.point_to_arc(x3, z3), distance)
end


--求点在x,z按rad移动distance后的坐标
function M.point_move(ox, oz, rad, distance)
    return ox + distance * math_cos(rad), oz + distance * math_sin(rad)
end

--求点P(x,z)到线段ab的最短的距离
function M.point2segment(px, pz, ax, az, bx, bz)
    if ax == bx and az == bz then
        return M.point_distance(px, pz, ax, az)
    end
    --[[使用投影方式计算，即t = AP.AB单位向量/AB长度 = AP.AB/|AB|^2
        如果 t <= 0则在A端,t>=1则在B
        否则在AB内
    ]]
    local apx,apz = px - ax, pz - az
    local abx, abz = bx-ax, bz - az
    --AP.AB
    local dot1 = apx * abx + apz * abz
    --AB.AB= |AB|^2
    local dot2 = abx ^2 + abz^2
    t = dot1/dot2
    if t <= 0 then --在A点
        return M.point_distance(px, pz, ax, az)
    elseif t >= 1 then --在B点
        return M.point_distance(px, pz, bx, bz)
    else --投影再AB内
        local xf = ax + abx * t
        local yf = az + abz * t
        return M.point_distance(px, pz, xf, yf)
    end
end



--[[
从原点(ox,oz)按照速度speed,加速度aspeed,弧度rad方向前进time后的新位置和距离
]]
function M.move_distance(ox, oz, rad, speed, time, aspeed)
    --speed为每秒速度，则移动距离为
    aspeed   = aspeed or 0
    local sec =  time / 1000
    local distance = speed * sec + aspeed * sec^2/2
    
    aspeed   = aspeed or 0
    --单位向量为[cos(rad),sin(rad)]，则更新后向量为distance*[cos(rad),sin(rad)],加上原点则转换为世界坐标

    local new_x = ox + distance * math_cos(rad)
    local new_z = oz + distance * math_sin(rad)
    return new_x, new_z, distance
end

--随机旋转圆上的一点
function M.random_range(ox, oz, range)
    local rad = M.degree2rad(math_random(0, 360))
    local x = ox + range * math_cos(rad)
    local z = oz + range * math_sin(rad)
    return x, z
end


--判断线段ab和线段cd是否相交，返回交点
function M.cross_segment(ax, az, bx, bz,  cx, cz, dx, cz)
    --利用叉积计算
    local area_abc = (ax - cx) * (bz - cz) - (az - cz) * (bx - cx)
    local area_abd = (ax - dx) * (bz - dz) - (az - dz) * (bx - dx)
    if area_abc * area_abd >= 0 then
        return nil,nil
    end

    local area_cda = (cx - ax) * (dz - az) - (cz - az) * (dx - ax)
    local area_cdb = area_cda + area_abc - area_abd
    if area_cda * area_cdb >= 0 then
        return nil,nil
    end

    local t = area_cda / (area_abd- area_abc)
    local dx = t * (bx - ax)
    local dy = t * (bz - az)
    return  ax + dx,  az + dz
end

------------------------- 点和图形 ------------------------


--[[
判断点(px,pz)是否在弧形[半径r,弧度[rad1-rad2]的区域内
@px,pz:坐标，这里不用世界坐标转换，用的都是相对坐标，即圆心为0,0， 世界坐标需要使用world2relative_pos进行转换
@rad1逆时针，取值在[0-pi]，为了方便判断，只要求rad1和rad2只是从x轴进行旋转
@rad2顺时针，取值在[-pi,0]
]]
function M.in_arc_arena(r, rad1, rad2, px, pz)
    if px  == 0 and pz == 0 then
        return true
    end
    if rad1 > pi or rad1 < 0 or rad2 > 0 or rad2 < -pi then
        return false
    end
    if rad1 == rad2 or M.point_distance(0, 0, px, pz) > r then
        return false
    end
    local prad = M.point_to_arc(px, pz)
    if prad > pi then --转为负
        prad = prad - pi2
    end
    return prad >= rad2 and prad <= rad1 
end

--[[
判断是否在弧形区域内
in_arc_arena的封装版
@ox,oz：中心
@rad: 单位旋转弧度
@r: 半径
@rad1: 弧度1
@rad2: 弧度2
@px,pz: 目标点
]]
function M.in_arc_arena2(ox, oz, r, rad, rad1, rad2, px, pz)
    local nx,nz = M.world2relative_pos(ox, oz, px, pz, rad)
    return M.in_arc_arena(r, rad1, rad2, nx, nz)
end


--[[
判断点是否在矩形内
@ox,oz:矩形中心点
@length:长，平行于单位坐标轴的x轴
@width: 宽，平行于单做坐标轴的y轴
@rad: 矩形的选择弧度
@px, pz: 坐标
]]
function M.in_rect_arena(ox, oz, length, width, rad, px, pz)
    local nx,nz = M.world2relative_pos(ox, oz, px, pz, rad)
    length = length/2
    width = width/2
    return nx <= length and nz <= width and nx >= -length and nz >= -width
end

--同上，AAABB检测
function M.rect_AABB(length, width, nx,nz)
    length = length/2
    width = width/2
    return nx <= length and nz <= width and nx >= -length and nz >= -width
end


function M.in_circle_arena(ox, oz, r, px, pz)
    local distance = M.point_distance(ox, oz, px, pz)
    return distance <= r
end



------------------------- 图形和图形 ------------------------

--[[
判断两个圆是否相交
]]
function M.collision_circle_circle(x1, z1, r1, x2, z2, r2)
    return M.point_distance(x1, z1,  x2, z2) <= r1 + r2
end

--[[
圆形和旋转矩形相交
]]
function M.collision_circle_rect(ox, oz, r, rx, rz, length, width, rad)
    --先做相对坐标处理，容易求出四个角的点
    local nx,nz = M.world2relative_pos(rx , rz, ox, oz, rad)
    --将矩形的长宽分别增加2r形成两个新矩形，如果圆心在内个矩形内，则认为是相交
    local r2 = 2*r
    if M.rect_AABB(length+r2, width, nx,nz) or M.rect_AABB(length, width+r2, nx,nz) then
        return true
    end

    --判断4个角和圆心的距离，<=半径则相交
    if M.point_distance(nx, nz, length/2, width/2) <= r then
        return true
    end
    if M.point_distance(nx, nz, -length/2, width/2) <= r then
        return true
    end
    if M.point_distance(nx, nz, -length/2, -width/2) <= r then
        return true
    end
    if M.point_distance(nx, nz, length/2, -width/2) <= r then
        return true
    end
    return false
end


--[[
圆形和弧形测试相交
弧形：原点(x2,z2)，朝向为rad, 半径r2
弧度[rad1-rad2]的区域内
@rad1逆时针，取值在[0-pi]
@rad2顺时针，取值在[-pi,0]
]]
function M.collision_circle_arc(x1, z1, r1, x2, z2, r2, rad, rad1, rad2)
    local dst = M.point_distance(x1, z1,  x2, z2)
    if dst > r1 + r2 then --两圆不想交
        return false,dst
    end
    if dst <= r1 then --点在圆内
        return true,dst
    end

    --用弧的中心对圆的中心做相对坐标转化，如果圆点的朝向在rad1,rad2内即相交
    local nx,nz = M.world2relative_pos(x2, z2, x1, z1, rad)
    local nrad = M.point_to_arc(nx,nz)
    if nrad > pi then --转为负
        nrad = nrad - pi2
    end
    if nrad >= 0 and nrad <= rad1 then
        return true
    end
    if nrad <= 0 and nrad >= rad2 then
        return true
    end

    --否则，不在弧内，那么需要判断弧的两条半径和圆心的最短距离

    --求出弧一边的线段的点(x2,z2,nx1,nz1)
    local nx1,nz1 = M.point_move(x2, z2, rad+rad1, r2)
    --计算圆形x1,z1和弧的距离，如果小于圆的半径则相交
    local dst2 = M.point2segment(x1, z1, x2, z2, nx1, nz1)
    if dst2 < r1 then
        return true
    end
    --再求另一边
    nx1,nz1 = M.point_move(x2, z2, rad+rad2, r2)
    dst2 = M.point2segment(x1, z1, x2, z2, nx1, nz1)
    if dst2 < r1 then
        return true
    end
    --按逻辑来说这里不会执行
    return false
end






return M
