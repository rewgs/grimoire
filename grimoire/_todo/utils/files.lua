function WriteToFile(file, text) --> nil
    local f = io.open(file, "w")
    if f ~= nil then
        if text ~= nil then
            f:write(text)
        end
        f:close()
    end
end

function GetFileName(file) --> string
    return file:match("[^/]*.lua$")
end

function FileExists(name) --> bool
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end
