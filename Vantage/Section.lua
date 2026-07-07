--[[
    Vantage/Section.lua
    A titled card that lives inside a page and holds elements
    (buttons for now — the layout makes it trivial to bolt on more
    element types later, see README for the pattern).
--]]

local Vantage = ...

local Utility = Vantage.Utility
local Theme   = Vantage.Theme
local Button  = Vantage.Button

local Section = {}
Section.__index = Section

function Section.new(parent, name)
    local frame = Utility.Create("Frame", {
        Name             = name,
        BackgroundColor3 = Theme.Colors.Section,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        Parent           = parent,
    })
    Utility.Corner(frame, 10)
    Utility.Stroke(frame)

    Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position       = UDim2.new(0, 12, 0, 8),
        Size           = UDim2.new(1, -24, 0, 20),
        Font           = Theme.FontBold,
        Text           = name,
        TextColor3     = Theme.Colors.Text,
        TextSize       = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent         = frame,
    })

    local holder = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Position      = UDim2.new(0, 12, 0, 34),
        Size          = UDim2.new(1, -24, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent        = frame,
    })

    Utility.Create("UIListLayout", {
        Parent    = holder,
        Padding   = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    Utility.Create("UIPadding", {
        Parent        = frame,
        PaddingBottom = UDim.new(0, 12),
    })

    local self = setmetatable({
        Instance = frame,
        Holder   = holder,
    }, Section)

    return self
end

function Section:addButton(name, callback)
    return Button.new(self.Holder, name, callback)
end

return Section
