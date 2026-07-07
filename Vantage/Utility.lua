--[[
    Vantage/Utility.lua
    Small shared helpers every other module leans on.
--]]

local Vantage = ...

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Utility = {}

-- Instance.new + property/children shorthand
function Utility.Create(className, properties, children)
    local inst = Instance.new(className)

    for prop, value in pairs(properties or {}) do
        inst[prop] = value
    end

    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end

    return inst
end

-- Fire-and-forget tween, returns the Tween object in case you want to chain :Cancel() etc.
function Utility.Tween(inst, info, props)
    if typeof(info) == "number" then
        info = TweenInfo.new(info, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end
    local tween = TweenService:Create(inst, info, props)
    tween:Play()
    return tween
end

function Utility.Corner(inst, radius)
    return Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = inst,
    })
end

function Utility.Stroke(inst, color, thickness, transparency)
    return Utility.Create("UIStroke", {
        Color        = color or Vantage.Theme.Colors.Stroke,
        Thickness    = thickness or 1,
        Transparency = transparency or 0,
        Parent       = inst,
    })
end

-- Makes `frame` draggable using `handle` (defaults to itself) as the grab area.
function Utility.MakeDraggable(frame, handle)
    handle = handle or frame

    local dragging  = false
    local dragInput
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Posts a JSON body to `url`. Roblox blocks HttpService requests from
-- client-side scripts, so this leans on whichever request function your
-- executor exposes (request / http_request / syn.request). Returns true/false
-- plus an error message so callers can tell the player whether it worked.
function Utility.HttpPost(url, jsonBody)
    local requestFn = (syn and syn.request) or http_request or request
 
    if not requestFn then
        return false, "No HTTP request function available in this environment."
    end
 
    local ok, response = pcall(requestFn, {
        Url     = url,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = jsonBody,
    })
 
    if not ok then
        return false, tostring(response)
    end
 
    return true
end

return Utility
