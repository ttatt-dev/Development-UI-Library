--[[
    Vantage/Theme.lua
    One place to re-skin the entire library. Change these and every
    page/section/button/notification updates automatically.
--]]

local Vantage = ...

local Theme = {}

Theme.Colors = {
    Background   = Color3.fromRGB(24, 24, 27),
    Sidebar      = Color3.fromRGB(18, 18, 20),
    Section      = Color3.fromRGB(30, 30, 34),
    Element      = Color3.fromRGB(38, 38, 43),
    ElementHover = Color3.fromRGB(46, 46, 52),
    Accent       = Color3.fromRGB(114, 137, 255),
    Text         = Color3.fromRGB(235, 235, 240),
    SubText      = Color3.fromRGB(150, 150, 160),
    Stroke       = Color3.fromRGB(50, 50, 56),
    Success      = Color3.fromRGB(87, 201, 130),
    Error        = Color3.fromRGB(230, 90, 90),
}

Theme.Font     = Enum.Font.GothamMedium
Theme.FontBold = Enum.Font.GothamBold

return Theme
