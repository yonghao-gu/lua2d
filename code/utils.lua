
local string_gsub = string.gsub
local string_format = string.format
local table_insert = table.insert
local table_concat = table.concat

local M = {}


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



function M.tbl2str(T)
	local mark={}
	local assign={}
	local function ser_table(tbl,parent)
		mark[tbl]=parent
		local tmp={}
		for k,v in pairs(tbl) do
			local key= type(k)=="number" and "["..k.."]" or "['" .. k .. "']"
            if type(v)=="table" then
				local dotkey= parent .. key
                if mark[v] then
					table_insert(assign,dotkey.."="..mark[v])
				else
					table_insert(tmp, key.."="..ser_table(v,dotkey))
				end
			elseif type(v) == "string" then
				table_insert(tmp, key.."=".. string_format("%q", v))
            else
				table_insert(tmp, key.."=".. tostring(v))
            end
		end
		return "{"..table_concat(tmp,",").."}"
	end
	return ser_table(T,"ret")..table_concat(assign," ")
end

function M.split(s, p)
    local rt= {}
    string_gsub(s, '[^'..p..']+', function(w)
        table_insert(rt, w) 
    end)
    return rt
end


return M
