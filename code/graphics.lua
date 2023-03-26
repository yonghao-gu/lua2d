
--[[
    2d图形的算法
    规则1：单位朝向，为单位坐标的x轴方向
    规则2：碰撞定义，如果点在边上，则认为是相交
    规则3：
        一些图形结构的定义
        矩形的构造
            坐标点:矩形中心
            高: 平行于单位坐标y轴
            宽：平行于单位坐标x轴
        圆：
            坐标点：圆心
            半径
        弧形:
            坐标点：圆心
            朝向： 单位坐标x轴方向
            弧度1：逆时针方向，值为[0,pi]
            弧度2: 顺时针方向，值为[-pi,0]
        
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
local math_atan   = math.atan
local M = {}

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
    local arc = math_atan(y,x)
    if arc < 0 then
        arc = arc + pi2
    end
    return arc
end



--求点（x1,y1）向点(x2,y2)的朝向
function M.two_point_face(x1, y1, x2, y2)
    --向量2-向量1
    local x = x2 - x1
    local y = y2 - y1
    return M.point_to_arc(x, y)
end



--[[
默认的获取单位的坐标轴的方法，返回x轴和z轴的单位向量（x=x,y=y）
我们认为一个单位的正面朝向为+x轴方向
@rad:单位朝向
]]
function M.default_coordinate_system(rad)
    local vec_x = { x = math_cos(rad),  y = math_sin(rad) }
    local vec_y = { x = -math_sin(rad), y = math_cos(rad) }
    return vec_x, vec_y
end

--[[ 
将对象坐标进行偏移，然后转为世界坐标
@ox,oy: 原点的世界坐标
@vec_x,vec_y，对象坐标的x,y轴单位向量
    对于旋转矩形，为vec_x,vec_y为垂直边框的法线，vec_x的正方向是对象的朝向
@x,y 偏移的坐标
]]
function M.trans2world_pos(ox, oy, vec_x, vec_y, x, y)
    local gx = ox + vec_x.x*x + vec_y.x*y
    local gz = oy + vec_x.y*x + vec_y.y*y
    return gx, gz
end


--[[ 
将对象坐标进行偏移，然后转为世界坐标,对trans2world_pos再封装
@ox,oy: 原点的世界坐标
@orad: 对象的朝向
@x,y 偏移的坐标
]]
function M.trans2world_pos2(ox, oy,orad, x, y)
    --先算旋转偏移
    local vec_x, vec_y = M.default_coordinate_system(orad)
    return M.trans2world_pos(ox, oy, vec_x, vec_y, x, y)
end



--[[
将世界坐标转换为对象坐标
@ox,oy: 坐标系原点
@px,py 要转换的世界坐标
@rad: 旋转弧度（对单位来说就是朝向）
]]
function M.world2relative_pos(ox, oy, gx, gy, rad)
    local nx = gx - ox
    local ny = gy - oy
    local x = nx * math_cos(rad) + ny * math_sin(rad)
    local y = ny * math_cos(rad) - nx * math_sin(rad) 
    return x,y
end


--[[
求原点与坐标的夹角
@x,y,rad:原点和朝向
@px,py:世界坐标
@fix：角度修正，取最少夹角，并且为正
]]
function M.arc_angle(ox, oy, rad, px, py, fix)
    local nx,ny = M.world2relative_pos(ox, oy, px, py, rad)
    local arc = M.point_to_arc(nx, ny)
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
function M.point_distance(x1,y1, x2, y2)
    return math_sqrt((x1-x2)^2 + (y1-y2)^2)
end

function M.point_square_distance(x1, y1, x2, y2)
    return (x1-x2)^2 + (y1-y2)^2
end

--[[
求从点(x1,y1)到点(x2,y2)上，距离为distance的点坐标,ray表示是否为射线，否则为线段
如果2点是重合，那么直接返回x1,y1
ray不是射线且2点距离小于distance，那么返回x2,y2

]]
function M.line_point(x1, y1, x2, y2, distance, ray)
    --求线段的向量，再求弧度，最后乘以distance即可
    local x3 = x2 - x1
    local y3 = y2 - y1
    local dst = M.point_distance(x3, y3, 0, 0)
    if dst == 0 then
        return x1, y1
    end
    if not ray and dst <= distance then
        return x2, y2
    end
    return M.point_move(x1, y1, M.point_to_arc(x3, y3), distance)
end


--求点在x,y按rad移动distance后的坐标
function M.point_move(ox, oy, rad, distance)
    return ox + distance * math_cos(rad), oy + distance * math_sin(rad)
end

--求点P(x,y)到线段ab的最短的距离
function M.point2segment(px, py, ax, ay, bx, by)
    if ax == bx and ay == by then
        return M.point_distance(px, py, ax, ay)
    end
    --[[使用投影方式计算，即t = AP.AB单位向量/AB长度 = AP.AB/|AB|^2
        如果 t <= 0则在A端,t>=1则在B
        否则在AB内
    ]]
    local apx,apy = px - ax, py - ay
    local abx, aby = bx-ax, by - ay
    --AP.AB
    local dot1 = apx * abx + apy * aby
    --AB.AB= |AB|^2
    local dot2 = abx ^2 + aby^2
    local t = dot1/dot2
    if t <= 0 then --在A点
        return M.point_distance(px, py, ax, ay)
    elseif t >= 1 then --在B点
        return M.point_distance(px, py, bx, by)
    else --投影再AB内
        local xf = ax + abx * t
        local yf = ay + aby * t
        return M.point_distance(px, py, xf, yf)
    end
end



--[[
从原点(ox,oy)按照速度speed,加速度aspeed,弧度rad方向前进time后的新位置和距离
]]
function M.move_distance(ox, oy, rad, speed, time, aspeed)
    --speed为每秒速度，则移动距离为
    aspeed   = aspeed or 0
    local sec =  time / 1000
    local distance = speed * sec + aspeed * sec^2/2
    
    aspeed   = aspeed or 0
    --单位向量为[cos(rad),sin(rad)]，则更新后向量为distance*[cos(rad),sin(rad)],加上原点则转换为世界坐标

    local new_x = ox + distance * math_cos(rad)
    local newy = oy + distance * math_sin(rad)
    return new_x, newy, distance
end

--随机旋转圆上的一点
function M.random_range(ox, oy, range)
    local rad = M.degree2rad(math_random(0, 360))
    local x = ox + range * math_cos(rad)
    local y = oy + range * math_sin(rad)
    return x, y
end


--判断线段ab和线段cd是否相交，返回交点
function M.cross_segment(ax, ay, bx, by,  cx, cy, dx, dy)
    --利用叉积计算
    local area_abc = (ax - cx) * (by - cy) - (ay - cy) * (bx - cx)
    local area_abd = (ax - dx) * (by - dy) - (ay - dy) * (bx - dx)
    if area_abc * area_abd >= 0 then
        return nil,nil
    end

    local area_cda = (cx - ax) * (dy - ay) - (cy - ay) * (dx - ax)
    local area_cdb = area_cda + area_abc - area_abd
    if area_cda * area_cdb >= 0 then
        return nil,nil
    end

    local t = area_cda / (area_abd- area_abc)
    local dx = t * (bx - ax)
    local dy = t * (by - ay)
    return  ax + dx,  ay + dy
end

------------------------- 点和图形 ------------------------


--[[
判断点(px,py)是否在弧形[半径r,弧度[rad1-rad2]的区域内
@px,py:坐标，这里不用世界坐标转换，用的都是相对坐标，即圆心为0,0， 世界坐标需要使用world2relative_pos进行转换
@rad1逆时针，取值在[0-pi]，为了方便判断，只要求rad1和rad2只是从x轴进行旋转
@rad2顺时针，取值在[-pi,0]
]]
function M.in_arc_arena(r, rad1, rad2, px, py)
    if px  == 0 and py == 0 then
        return true
    end
    if rad1 > pi or rad1 < 0 or rad2 > 0 or rad2 < -pi then
        return false
    end
    if rad1 == rad2 or M.point_distance(0, 0, px, py) > r then
        return false
    end
    local prad = M.point_to_arc(px, py)
    if prad > pi then --转为负
        prad = prad - pi2
    end
    return prad >= rad2 and prad <= rad1 
end

--[[
判断是否在弧形区域内
in_arc_arena的封装版
@ox,oy：中心
@rad: 单位旋转弧度
@r: 半径
@rad1: 弧度1
@rad2: 弧度2
@px,py: 目标点
]]
function M.in_arc_arena2(ox, oy, r, rad, rad1, rad2, px, py)
    local nx,ny = M.world2relative_pos(ox, oy, px, py, rad)
    return M.in_arc_arena(r, rad1, rad2, nx, ny)
end


--[[
判断点是否在矩形内
@ox,oy:矩形中心点
@width:宽，平行于单位坐标轴的x轴
@height:高，平行于单做坐标轴的y轴
@rad: 矩形朝向
@px, py: 坐标
]]
function M.in_rect_arena(ox, oy, width, height, rad, px, py)
    local nx,ny = M.world2relative_pos(ox, oy, px, py, rad)
    height = height/2
    width = width/2
    return nx <= width and ny <= height and nx >= -width and ny >= -height
end

--同上，AAABB检测
function M.rect_AABB(width, height, nx,ny)
    height = height/2
    width = width/2
    return nx <= width and ny <= height and nx >= -width and ny >= -height
end


function M.in_circle_arena(ox, oy, r, px, py)
    local distance = M.point_distance(ox, oy, px, py)
    return distance <= r
end



------------------------- 图形和图形 ------------------------

--[[
判断两个圆是否相交
]]
function M.collision_circle_circle(x1, y1, r1, x2, y2, r2)
    return M.point_distance(x1, y1,  x2, y2) <= r1 + r2
end

--[[
圆形和旋转矩形相交
]]
function M.collision_circle_rect(ox, oy, r, rx, ry, width, height, rad)
    --先做相对坐标处理，容易求出四个角的点
    local nx,ny = M.world2relative_pos(rx , ry, ox, oy, rad)
    --将矩形的长宽分别增加2r形成两个新矩形，如果圆心在内个矩形内，则认为是相交
    local r2 = 2*r
    if M.rect_AABB(width+r2, height, nx,ny) or M.rect_AABB(width, height+r2, nx,ny) then
        return true
    end

    --判断4个角和圆心的距离，<=半径则相交
    if M.point_distance(nx, ny, width/2, height/2) <= r then
        return true
    end
    if M.point_distance(nx, ny, -width/2, height/2) <= r then
        return true
    end
    if M.point_distance(nx, ny, -width/2, -height/2) <= r then
        return true
    end
    if M.point_distance(nx, ny, width/2, -height/2) <= r then
        return true
    end
    return false
end


--[[
圆形和弧形测试相交
弧形：原点(x2,y2)，朝向为rad, 半径r2
弧度[rad1-rad2]的区域内
@rad1逆时针，取值在[0-pi]
@rad2顺时针，取值在[-pi,0]
]]
function M.collision_circle_arc(x1, y1, r1, x2, y2, r2, rad, rad1, rad2)
    local dst = M.point_distance(x1, y1,  x2, y2)
    if dst > r1 + r2 then --两圆不想交
        return false,dst
    end
    if dst <= r1 then --点在圆内
        return true,dst
    end

    --用弧的中心对圆的中心做相对坐标转化，如果圆点的朝向在rad1,rad2内即相交
    local nx,ny = M.world2relative_pos(x2, y2, x1, y1, rad)
    local nrad = M.point_to_arc(nx,ny)
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

    --求出弧一边的线段的点(x2,y2,nx1,ny1)
    local nx1,ny1 = M.point_move(x2, y2, rad+rad1, r2)
    --计算圆形x1,y1和弧的距离，如果小于圆的半径则相交
    local dst2 = M.point2segment(x1, y1, x2, y2, nx1, ny1)
    if dst2 < r1 then
        return true
    end
    --再求另一边
    nx1,ny1 = M.point_move(x2, y2, rad+rad2, r2)
    dst2 = M.point2segment(x1, y1, x2, y2, nx1, ny1)
    if dst2 < r1 then
        return true
    end
    --按逻辑来说这里不会执行
    return false
end



return M
