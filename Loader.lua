--[[
    Vantage UI Library — Loader
    ---------------------------------------------------------------
    This is the ONLY file you loadstring in-game. It pulls every
    other module straight from your GitHub repo's raw content and
    wires them together, so the whole library stays modular and
    editable without ever cramming everything into one giant script.

    Usage (client side):

        local Vantage = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/YOUR_USERNAME/Vantage/main/Loader.lua"
        ))({
            Title     = "Vantage",
            ToggleKey = Enum.KeyCode.RightControl, -- show/hide the UI
        })

    That's it — `Vantage` above is your fully built window, ready for
    :addPage(), :addSection(), :addButton() and :Notify().
--]]

local config = ...

-- ============================================================
-- 1. Point this at your own repo (user/repo/branch)
-- ============================================================
local REPO_RAW = "https://raw.githubusercontent.com/ttatt-dev/Development-UI-Library/main/"
-- ============================================================
-- 2. Fetch + compile helpers
-- ============================================================
local Vantage = {
    Version = "1.0.0",
    Repo    = REPO_RAW,
}

local function fetch(path)
    local success, result = pcall(function()
        return game:HttpGet(Vantage.Repo .. path, true)
    end)

    if not success or type(result) ~= "string" or #result == 0 then
        error(("[Vantage] Failed to fetch module '%s': %s"):format(path, tostring(result)), 0)
    end

    return result
end

local function load(path, ...)
    local source = fetch(path)
    local chunk, compileErr = loadstring(source, "=Vantage/" .. path)

    if not chunk then
        error(("[Vantage] Failed to compile module '%s': %s"):format(path, tostring(compileErr)), 0)
    end

    return chunk(...)
end

-- ============================================================
-- 3. Load every module, in dependency order.
--    Each module receives the shared `Vantage` table so it can
--    read whatever was already loaded before it (Theme, Utility,
--    etc.) without any real `require()` calls — everything is
--    fetched as plain text and compiled with loadstring.
-- ============================================================
Vantage.Utility      = load("Vantage/Utility.lua", Vantage)
Vantage.Theme        = load("Vantage/Theme.lua", Vantage)
Vantage.Notification = load("Vantage/Notification.lua", Vantage)
Vantage.Button       = load("Vantage/Elements/Button.lua", Vantage)
Vantage.Section      = load("Vantage/Section.lua", Vantage)
Vantage.Page         = load("Vantage/Page.lua", Vantage)
Vantage.Library      = load("Vantage/Library.lua", Vantage)

-- ============================================================
-- 4. Build and hand back the actual window instance.
-- ============================================================
return Vantage.Library.new(config)
