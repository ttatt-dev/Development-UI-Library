--[[
    Vantage/Page.lua
    A scrollable content area. window:addPage(name, iconId) makes one
    of these plus its sidebar nav button (wired up in Library.lua).
--]]

local Vantage = ...

local Utility = Vantage.Utility
local Theme   = Vantage.Theme
local Section = Vantage.Section

local Page = {}
Page.__index = Page

function Page.new(parent, name, iconId)
    local frame = Utility.Create("ScrollingFrame", {
        Name                    = name,
        BackgroundTransparency  = 1,
        Size                    = UDim2.new(1, 0, 1, 0),
        Visible                 = false,
        ScrollBarThickness      = 4,
        ScrollBarImageColor3    = Theme.Colors.Accent,
        CanvasSize              = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize     = Enum.AutomaticSize.Y,
        Parent                  = parent,
    })

    Utility.Create("UIListLayout", {
        Parent    = frame,
        Padding   = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    Utility.Create("UIPadding", {
        Parent        = frame,
        PaddingTop    = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 16),
        PaddingLeft   = UDim.new(0, 4),
        PaddingRight  = UDim.new(0, 4),
    })

    local self = setmetatable({
        Instance = frame,
        Name     = name,
        Icon     = iconId,
    }, Page)

    return self
end

function Page:addSection(name)
    return Section.new(self.Instance, name)
end

return Page
