function is_list_like(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then
            return false
        end
    end
    return true
end

function recursively_traverse(t)
    -- Recursively traverses the members of both list-like and dict-like tables.
    if type(t) ~= "table" then
        reaprint("recurisvely_traverse() requires that its arg be a table!")
        -- reaprint(t)
    else
        -- reaprint("t is a table")
        local table_type = is_list_like(t)
        if table_type then -- list-like table
            reaprint("t is a list-like table")
            for i, x in ipairs(t) do
                if type(x) == "table" then
                    recursively_traverse(x)
                end
            end
        else
            reaprint("t is a dict-like table")
            local index = {}
            for k, v in pairs(t) do
                if type(k) == "table" then
                    recursively_traverse(k)
                end
            end
        end
    end
end

function recursively_search(search_term, input)
    -- Searches for `search_term`, which is presumably an element of an list-like table, or a value of a dict-like table.
    -- Returns two values, depending on one of these outcomes:
    --  1. If `search_term` is a bad type (i.e. a table):
    --      a. return val 1 is `nil`
    --      b. return val 2 is an error message.
    --  2. If `search_term`  is a valid type (i.e. not a table):
    --      a. return val 1 is a bool for whether `search_term` exists in `input`
    --      b. if return val 1 is true, return val 2 is the index of `search_term`; if return val 1 is false, return val 2 is nil

    assert(search_term ~= nil, "arg1 should not be nil!")
    assert(type(search_term) ~= "table", search_term .. " should not be a table!")

    if type(input) == "table" then
        print("input is a table")
        if not is_list_like(input) then -- dict-like table
            print("input is a dict-like table")
            local index = {}
            for k, v in pairs(table) do
                if type(v) ~= "table" then
                    index[v] = k
                    if v == search_term then
                        return true, index[v]
                    end
                else
                    recursively_search(search_term, v)
                end
            end
            return false, nil
        elseif is_list_like(input) then -- list-like table
            print("input is an list-like table")
            for i, t in ipairs(table) do
                if type(t) ~= "table" then
                    if t == search_term then
                        return true, i
                    end
                else
                    recursively_search(search_term, t)
                end
            end
            return false, nil
        else
            -- TODO: needs more graceful exit with error message, etc
            -- This indicates that something very strange went wrong. Should never run.
            return
        end
    end
end

function get_length_of_dict_like_table(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function print_names_of_track_table(t)
    for i, track in ipairs(t) do
        reaper.ShowConsoleMsg(track.number .. ": " .. track.name .. "\n")
    end
end

function print_values_of_table_keys(t)
    for key, value in pairs(t) do
        reaper.ShowConsoleMsg(key .. ": " .. tostring(value) .. "\n")
    end
end

function remove_duplicates_from_table(t)
    local hash = {}
    local res = {}
    for _, v in ipairs(t) do
        if (not hash[v]) then
            res[#res + 1] = v
            hash[v] = true
        end
    end
    return res
end

function table_contains(table, value)
    for i = 1, #table do
        if (table[i] == value) then
            return true
        end
    end
    return false
end
