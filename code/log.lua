
local utils = require "utils"

local tbl2str = utils.tbl2str
local M = {}


M.log_file = nil

function M.init(log)
    if M.log_file then
        return M.log_file
    end
    M.log_file = io.open(log, "w")
    return M.log_file
end


function M.to_string(s)
    if type(s) == "string" then
        return s
    elseif type(s) == "table" then
        return tbl2str(s)
    else
        return tostring(s)
    end
end

function M.log_Info(...)
    if not M.log_file then
        return
    end
    local t = {...}
    for i, s in ipairs(t) do
        M.log_file:write(M.to_string(s))
        if i > 1 then
            M.log_file:write(' ')
        end
    end
    M.log_file:write('\n')
    M.log_file:flush()
end

return M