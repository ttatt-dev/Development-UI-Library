--[[
    Vantage/Notification.lua
    Toast-style notifications, stacked top-right, fade + auto dismiss.
    Call Vantage:Notify({ Title = "...", Content = "...", Duration = 4 })
--]]

local Vantage = ...

local Utility = Vantage.Utility
local Theme   = Vantage.Theme

local Notification = {}
Notification.Container = nil

function Notification.Init(screenGui)
    Notification.Container = Utility.Create("Frame", {
        Name                = "NotificationContainer",
        BackgroundTransparency = 1,
        AnchorPoint         = Vector2.new(1, 0),
        Position            = UDim2.new(1, -16, 0, 16),
        Size                = UDim2.new(0, 300, 1, -32),
        Parent              = screenGui,
    })

    Utility.Create("UIListLayout", {
        Parent               = Notification.Container,
        Padding              = UDim.new(0, 8),
        HorizontalAlignment  = Enum.HorizontalAlignment.Right,
        SortOrder            = Enum.SortOrder.LayoutOrder,
    })
end

function Notification.Send(opts)
    opts = opts or {}
    local title    = opts.Title or "Notification"
    local content  = opts.Content or ""
    local duration = opts.Duration or 4

    local frame = Utility.Create("Frame", {
        BackgroundColor3   = Theme.Colors.Section,
        Size               = UDim2.new(1, 0, 0, 0),
        AutomaticSize      = Enum.AutomaticSize.Y,
        ClipsDescendants   = true,
        Parent             = Notification.Container,
    })
    Utility.Corner(frame, 10)
    Utility.Stroke(frame)

    local accent = Utility.Create("Frame", {
        BackgroundColor3 = Theme.Colors.Accent,
        Size             = UDim2.new(0, 4, 1, 0),
        Parent           = frame,
    })
    Utility.Corner(accent, 10)

    local titleLabel = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position          = UDim2.new(0, 16, 0, 10),
        Size              = UDim2.new(1, -28, 0, 18),
        Font              = Theme.FontBold,
        Text              = title,
        TextColor3        = Theme.Colors.Text,
        TextSize          = 14,
        TextXAlignment    = Enum.TextXAlignment.Left,
        Parent            = frame,
    })

    local contentLabel = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position          = UDim2.new(0, 16, 0, 30),
        Size              = UDim2.new(1, -28, 0, 0),
        AutomaticSize     = Enum.AutomaticSize.Y,
        Font              = Theme.Font,
        Text              = content,
        TextColor3        = Theme.Colors.SubText,
        TextSize          = 13,
        TextWrapped       = true,
        TextXAlignment    = Enum.TextXAlignment.Left,
        Parent            = frame,
    })

    -- start invisible, fade everything in
    frame.BackgroundTransparency        = 1
    accent.BackgroundTransparency       = 1
    titleLabel.TextTransparency         = 1
    contentLabel.TextTransparency       = 1

    task.defer(function()
        Utility.Tween(frame,        0.25, { BackgroundTransparency = 0 })
        Utility.Tween(accent,       0.25, { BackgroundTransparency = 0 })
        Utility.Tween(titleLabel,   0.25, { TextTransparency = 0 })
        Utility.Tween(contentLabel, 0.25, { TextTransparency = 0 })
    end)

    task.delay(duration, function()
        if frame and frame.Parent then
            Utility.Tween(frame,        0.25, { BackgroundTransparency = 1 })
            Utility.Tween(accent,       0.25, { BackgroundTransparency = 1 })
            Utility.Tween(titleLabel,   0.25, { TextTransparency = 1 })
            Utility.Tween(contentLabel, 0.25, { TextTransparency = 1 })
            task.wait(0.3)
            if frame then frame:Destroy() end
        end
    end)
end

return Notification
