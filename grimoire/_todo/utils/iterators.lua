-- range(from) returns an iterator from 1 to a (step = 1)
-- range(from, to) returns an iterator from a to b (step = 1)
-- range(from, to, step) returns an iterator from a to b, counting by step.
--
-- Source: http://lua-users.org/wiki/RangeIterator
--
---@param from integer
---@param to integer (optional)
---@param step integer (optional)
function Range(from, to, step)
    if not to then
        to = from
        from = 1
    end
    step = step or 1
    local f =
        step > 0 and
        function(_, lastvalue)
            local nextvalue = lastvalue + step
            if nextvalue <= to then return nextvalue end
        end or
        step < 0 and
        function(_, lastvalue)
            local nextvalue = lastvalue + step
            if nextvalue >= to then return nextvalue end
        end or
        function(_, lastvalue) return lastvalue end
    return f, nil, from - step
end
