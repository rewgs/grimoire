# Grimoire

> A grimoire (/ɡrɪmˈwɑːr/), also known as a book of spells, magic book, or a spellbook,[1] is a textbook of magic, typically including instructions on how to create magical objects...

<p align="center">
    <!-- Original width: 512 px -->
  <img src="./images/grimoire-icon.svg" width="256"/>
</p>

`grimoire` is a library that significantly speeds up ReaScript development by providing a more object-oriented approach for interacting with the Reaper [ReaScript Lua API](https://www.reaper.fm/sdk/reascript/reascripthelp.html#l). It wraps each of ReaScript's data types (`ReaProject`, `MediaTrack`, `MediaItem`, etc) with a [class](https://www.lua.org/pil/16.1.html) (`Project`, `Track`, and `Item`, respectively); each class provides a number of useful methods, and each class's namespace provides some utility functions related to it.

There are several other classes/types original to this library which are intended to increase quality-of-life, such as [`track.FolderDepth`](./grimoire/track/folderDepth.lua).

<!-- Utilizes the [Ultraschall API](https://mespotin.uber.space/Ultraschall/US_Api_Introduction_and_Concepts.html) render table-related functionality. -->

All symbols have type annotations according to the [`lua-language-server` specification](https://github.com/LuaLS/lua-language-server/wiki/Annotations).

<!-- Powers the [`rea`](https://github.com/rewgs/rea) script library. -->

<!-- ## setup -->
<!-- Any ReaScript file that references this library needs to be able to import it from an absolute location that does not change from computer to computer. -->
<!-- 1. Install the [Ultraschall API](https://github.com/Ultraschall/ultraschall-lua-api-for-reaper?tab=readme-ov-file#reapack) via ReaPack. -->

> [!WARNING]
>
> **grimoire is a work in progress
> and does not have a `1.0` release yet.**

## why?

While the ReaScript API is extensive, it isn't _expressive_ -- ReaScript developers often find themselves writing a lot of the same code over and over, and most tasks take more lines of code than seems necessary.

For example, this is how one might go about getting a particular track by name:

```lua
local function getTrackByName(query)
    local matches = {}
    local numTracks = reaper.CountTracks(0)
    for i = 0, numTracks - 1 do
        local track = reaper.GetTrack(0, i)
        local _, name = reaper.GetTrackName(track)
        -- Excludes tracks with empty names
        if name == query and name ~= ("Track " .. i + 1) then
            table.insert(matches, track)
        end
    end
end

local track = getTrackByName("some track")
```

And this is how one achieves the same thing with `grimoire`:

```lua
local g = require("grimoire")
local project = g.Project:New()
local track = project:GetTrackByName("some track")
```

<!-- TODO: Uncomment once this is actually true :p
Additionally, calls like `defer()` are typically no longer necessary, as they are called at the appropriate times by the functions in this library. You can focus on actually writing functionality, not dancing our Reaper's needs.
-->

## use

It is highly recommended that you use VS Code along with [Antoine Balaine](https://www.linkedin.com/in/antoinebalaine/)'s excellent [`REAPER ReaScript`](https://marketplace.visualstudio.com/items?itemName=AntoineBalaine.reascript-docs) extension, as `grim`'s type annotations for Reaper's types are in accordance with this extension.
