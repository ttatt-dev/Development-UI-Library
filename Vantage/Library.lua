--[[
    Vantage/Library.lua
    Builds the actual window: topbar, sidebar nav, page container.
    This is what Loader.lua instantiates and hands back to you as
    the object you call :addPage() / :Notify() on.
--]]

local Vantage = ...

local Utility      = Vantage.Utility
local Theme         = Vantage.Theme
local Page          = Vantage.Page
local Notification  = Vantage.Notification

local UserInputService = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")
local Players            = game:GetService("Players")

local Library = {}
Library.__index = Library

function Library.new(config)
    config = config or {}
    local title     = config.Title or "Vantage"
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    local screenGui = Utility.Create("ScreenGui", {
        Name             = "Vantage",
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        DisplayOrder     = 999,
    })

    local parented = pcall(function()
        screenGui.Parent = CoreGui
    end)
    if not parented then
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    Notification.Init(screenGui)

    local main = Utility.Create("Frame", {
        Name             = "Main",
        BackgroundColor3 = Theme.Colors.Background,
        Position         = UDim2.new(0.5, -300, 0.5, -190),
        Size             = UDim2.new(0, 600, 0, 380),
        Parent           = screenGui,
    })
    Utility.Corner(main, 12)
    Utility.Stroke(main)

    -- ---------------- top bar ----------------
    local topBar = Utility.Create("Frame", {
        BackgroundColor3 = Theme.Colors.Sidebar,
        Size             = UDim2.new(1, 0, 0, 40),
        Parent           = main,
    })
    Utility.Corner(topBar, 12)

    -- squares off the bottom of the topbar so it sits flush against the body
    Utility.Create("Frame", {
        BackgroundColor3 = Theme.Colors.Sidebar,
        Position         = UDim2.new(0, 0, 1, -12),
        Size             = UDim2.new(1, 0, 0, 12),
        Parent           = topBar,
    })

    Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position       = UDim2.new(0, 16, 0, 0),
        Size           = UDim2.new(1, -100, 1, 0),
        Font           = Theme.FontBold,
        Text           = title,
        TextColor3     = Theme.Colors.Text,
        TextSize       = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent         = topBar,
    })

    local closeBtn = Utility.Create("TextButton", {
        BackgroundTransparency = 1,
        Position   = UDim2.new(1, -36, 0, 0),
        Size       = UDim2.new(0, 36, 1, 0),
        Font       = Theme.FontBold,
        Text       = "×",
        TextColor3 = Theme.Colors.SubText,
        TextSize   = 20,
        Parent     = topBar,
    })
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
    end)
    closeBtn.MouseEnter:Connect(function()
        Utility.Tween(closeBtn, 0.1, { TextColor3 = Theme.Colors.Error })
    end)
    closeBtn.MouseLeave:Connect(function()
        Utility.Tween(closeBtn, 0.1, { TextColor3 = Theme.Colors.SubText })
    end)

    Utility.MakeDraggable(main, topBar)

    -- ---------------- sidebar ----------------
    local sidebar = Utility.Create("Frame", {
        BackgroundColor3 = Theme.Colors.Sidebar,
        Position         = UDim2.new(0, 0, 0, 40),
        Size             = UDim2.new(0, 150, 1, -40),
        Parent           = main,
    })

    local sidebarList = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 8),
        Size     = UDim2.new(1, -16, 1, -16),
        Parent   = sidebar,
    })
    Utility.Create("UIListLayout", {
        Parent    = sidebarList,
        Padding   = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- ---------------- page container ----------------
    local pagesContainer = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 40),
        Size     = UDim2.new(1, -150, 1, -40),
        Parent   = main,
    })
    Utility.Create("UIPadding", {
        Parent       = pagesContainer,
        PaddingLeft  = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop   = UDim.new(0, 10),
    })

    local self = setmetatable({
        ScreenGui       = screenGui,
        Main            = main,
        SidebarList     = sidebarList,
        PagesContainer  = pagesContainer,
        Pages           = {},
        ActivePage      = nil,
    }, Library)

    -- keybind to show/hide the whole window
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == toggleKey then
            main.Visible = not main.Visible
        end
    end)

    return self
end

function Library:addPage(name, iconId)
    local page = Page.new(self.PagesContainer, name, iconId)
    table.insert(self.Pages, page)

    local navBtn = Utility.Create("TextButton", {
        Name                    = name,
        BackgroundColor3        = Theme.Colors.Element,
        BackgroundTransparency  = 1,
        Size                    = UDim2.new(1, 0, 0, 32),
        Text                    = "",
        AutoButtonColor         = false,
        Parent                  = self.SidebarList,
    })
    Utility.Corner(navBtn, 8)

    local icon = Utility.Create("ImageLabel", {
        BackgroundTransparency = 1,
        Position   = UDim2.new(0, 8, 0.5, -9),
        Size       = UDim2.new(0, 18, 0, 18),
        Image      = iconId and ("rbxassetid://" .. tostring(iconId)) or "",
        ImageColor3 = Theme.Colors.SubText,
        Parent     = navBtn,
    })

    local navLabel = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position       = UDim2.new(0, 34, 0, 0),
        Size           = UDim2.new(1, -40, 1, 0),
        Font           = Theme.Font,
        Text           = name,
        TextColor3     = Theme.Colors.SubText,
        TextSize       = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent         = navBtn,
    })

    local function select()
        for _, otherPage in ipairs(self.Pages) do
            otherPage.Instance.Visible = false
        end

        for _, child in ipairs(self.SidebarList:GetChildren()) do
            if child:IsA("TextButton") then
                Utility.Tween(child, 0.15, { BackgroundTransparency = 1 })
                local lbl = child:FindFirstChildOfClass("TextLabel")
                local img = child:FindFirstChildOfClass("ImageLabel")
                if lbl then lbl.TextColor3 = Theme.Colors.SubText end
                if img then img.ImageColor3 = Theme.Colors.SubText end
            end
        end

        page.Instance.Visible = true
        Utility.Tween(navBtn, 0.15, { BackgroundTransparency = 0 })
        navLabel.TextColor3 = Theme.Colors.Text
        icon.ImageColor3    = Theme.Colors.Accent
        self.ActivePage      = page
    end

    navBtn.MouseButton1Click:Connect(select)

    navBtn.MouseEnter:Connect(function()
        if self.ActivePage ~= page then
            Utility.Tween(navBtn, 0.15, { BackgroundTransparency = 0.6 })
        end
    end)
    navBtn.MouseLeave:Connect(function()
        if self.ActivePage ~= page then
            Utility.Tween(navBtn, 0.15, { BackgroundTransparency = 1 })
        end
    end)

    -- first page added becomes the default view
    if #self.Pages == 1 then
        select()
    end

    return page
end

function Library:Notify(opts)
    Notification.Send(opts)
end

function Library:SetVisible(visible)
    self.Main.Visible = visible
end

return Library
