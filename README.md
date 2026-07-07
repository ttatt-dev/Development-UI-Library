# Vantage

A modular, modern-styled client-sided UI library for Roblox. Everything is
fetched straight from your GitHub repo at runtime — no giant single-file
script — so you can edit one module (say, `Button.lua`) without touching
anything else.

## How it's structured

```
Vantage/
├── Loader.lua                 ← the only file you loadstring in-game
├── Vantage/
│   ├── Utility.lua             (Instance creation, tweens, dragging)
│   ├── Theme.lua                (colors/fonts — re-skin here)
│   ├── Notification.lua         (toast notifications)
│   ├── Library.lua               (window, sidebar, topbar)
│   ├── Page.lua                   (scrollable content area)
│   ├── Section.lua                 (titled card grouping elements)
│   └── Elements/
│       └── Button.lua               (clickable row -> callback)
├── README.md
└── LICENSE
```

`Loader.lua` downloads each module via `game:HttpGet`, compiles it with
`loadstring`, and passes a shared `Vantage` table into every module so they
can reference each other (`Vantage.Theme`, `Vantage.Utility`, etc.) without
real `require()` calls — which is what makes this work purely off raw
GitHub URLs.

## Setup

1. Push this folder to a GitHub repo (public, so raw URLs are reachable
   without auth).
2. Open `Loader.lua` and change:
   ```lua
   local REPO_RAW = "https://raw.githubusercontent.com/YOUR_USERNAME/Vantage/main/"
   ```
   to your actual `username/repo/branch`.
3. Loadstring `Loader.lua` from your executor/script:

   ```lua
   local Vantage = loadstring(game:HttpGet(
       "https://raw.githubusercontent.com/YOUR_USERNAME/Vantage/main/Loader.lua"
   ))({
       Title     = "Vantage",              -- window title, optional
       ToggleKey = Enum.KeyCode.RightControl -- show/hide hotkey, optional
   })
   ```

That's it. `Vantage` is now your live window object.

## API

### Pages

```lua
local PlayerPage    = Vantage:addPage("Player", 5012544693)
local TeleportsPage = Vantage:addPage("Teleports", 5012543481)
local MainPage      = Vantage:addPage("Features", 5012544092)
local ESPPage       = Vantage:addPage("ESP", 5012543246)
local SettingsPage  = Vantage:addPage("Settings", 5012544372)
```

`addPage(name, iconId)` adds a page to the window and a matching entry in
the sidebar. `iconId` is a Roblox asset id used as `rbxassetid://<id>` for
the sidebar icon — it's optional, pass `nil` to skip it. The first page you
add is shown by default.

### Sections

```lua
local Teleports = TeleportsPage:addSection("Locations")
local Abilities = MainPage:addSection("Abilities")
local Universal = PlayerPage:addSection("Player")
```

`page:addSection(name)` adds a titled card to that page. Add as many
sections per page as you want — they stack vertically and the page scrolls.

### Buttons

```lua
Abilities:addButton("Get Grateful Frog", function()
    -- your code here, runs when clicked
    print("frog acquired")
end)
```

`section:addButton(name, callback)` adds a clickable row. The callback runs
in a `pcall`, so an error inside it gets `warn()`'d to console instead of
breaking the rest of your UI. `addButton` returns the button object, and you
can rename it later with `button:SetText("New Label")`.

### Notifications

```lua
Vantage:Notify({
    Title    = "Teleported",
    Content  = "You've been sent to Grateful Frog.",
    Duration = 4, -- seconds, optional (default 4)
})
```

Notifications stack in the top-right corner, fade in, and auto-dismiss.

### Window controls

```lua
Vantage:SetVisible(false) -- hide the whole window in code
```

The window can also be toggled by the player with the `ToggleKey` passed
into the loader config (defaults to Right Control), and closed with the ×
button in the top-right of the titlebar. The titlebar is draggable.

## Adding new element types

Sections only know about buttons out of the box, but the pattern is meant
to be copy-pasted. To add e.g. a Toggle:

1. Create `Vantage/Elements/Toggle.lua` following the same shape as
   `Button.lua` — it receives `Vantage` as its only argument and returns a
   constructor table.
2. Load it in `Loader.lua`: `Vantage.Toggle = load("Vantage/Elements/Toggle.lua", Vantage)`.
3. Add a method in `Section.lua`:
   ```lua
   function Section:addToggle(name, default, callback)
       return Vantage.Toggle.new(self.Holder, name, default, callback)
   end
   ```

No other file needs to change.

## Theming

Everything pulls its colors from `Vantage/Theme.lua`. Change
`Theme.Colors.Accent` and every hover state, active tab, and notification
accent bar updates with it.

## License

MIT — see [LICENSE](LICENSE).
