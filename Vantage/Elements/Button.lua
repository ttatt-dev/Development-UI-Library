--[[
    Vantage/Elements/Button.lua
    A single clickable row. section:addButton(name, callback) makes one
    of these — clicking it runs `callback` in a pcall so one broken
    button can never crash the whole UI.
--]]

local Vantage = ...

local Utility = Vantage.Utility
local Theme   = Vantage.Theme

local Button = {}
Button.__index = Button

function Button.new(parent, name, callback)
    callback = callback or function() end

    local holder = Utility.Create("TextButton", {
        Name             = name,
        BackgroundColor3 = Theme.Colors.Element,
        Size             = UDim2.new(1, 0, 0, 36),
        Text             = "",
        AutoButtonColor  = false,
        Parent           = parent,
    })
    Utility.Corner(holder, 8)
    Utility.Stroke(holder)

    local label = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position       = UDim2.new(0, 12, 0, 0),
        Size           = UDim2.new(1, -16, 1, 0),
        Font           = Theme.Font,
        Text           = name,
        TextColor3     = Theme.Colors.Text,
        TextSize       = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent         = holder,
    })

    holder.MouseEnter:Connect(function()
        Utility.Tween(holder, 0.15, { BackgroundColor3 = Theme.Colors.ElementHover })
    end)

    holder.MouseLeave:Connect(function()
        Utility.Tween(holder, 0.15, { BackgroundColor3 = Theme.Colors.Element })
    end)

    holder.MouseButton1Click:Connect(function()
        -- quick accent flash so every click feels acknowledged
        Utility.Tween(holder, 0.08, { BackgroundColor3 = Theme.Colors.Accent })
        task.delay(0.12, function()
            if holder and holder.Parent then
                Utility.Tween(holder, 0.15, { BackgroundColor3 = Theme.Colors.Element })
            end
        end)

        local ok, err = pcall(callback)
        if not ok then
            warn(("[Vantage] Button '%s' errored: %s"):format(name, tostring(err)))
        end
    end)

    local self = setmetatable({
        Instance = holder,
        Label    = label,
    }, Button)

    return self
end

-- lets you rename a button after creation, e.g. Button:SetText("Enabled")
function Button:SetText(text)
    self.Label.Text = text
end

return Button
