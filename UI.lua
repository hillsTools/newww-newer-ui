-- miniui.lua  •  mobile-first UI lib (tabs/sections/scroll/toggles/sliders/dropdowns)
-- Improved version with better mobile support, corner labels, and open/close functionality

local MiniUI = {}

-- ========= THEME =========
local THEME = {
    bg        = Color3.fromRGB(10,10,12),
    panel     = Color3.fromRGB(18,20,25),
    panel2    = Color3.fromRGB(14,16,22),
    text      = Color3.fromRGB(230,235,240),
    dim       = Color3.fromRGB(180,185,195),
    accent    = Color3.fromRGB(0,140,255),
    border    = Color3.fromRGB(0,200,255),
    on        = Color3.fromRGB(0,170,255),
    off       = Color3.fromRGB(55,60,70),
}

-- ========= HELPERS =========
local function mk(class, props, children)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    for _,c in ipairs(children or {}) do c.Parent = o end
    return o
end

local function round(p, r) mk("UICorner", {Parent=p, CornerRadius=UDim.new(0, r or 8)}) end
local function stroke(p, t, c, a) mk("UIStroke", {Parent=p, Thickness=t or 1, Color=c or THEME.border, Transparency=a or 0.25}) end
local function text(parent, str, size, bold, color, center)
    return mk("TextLabel", {
        Parent=parent, BackgroundTransparency=1, Text=str,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json",
            Enum.FontWeight[bold and "Bold" or "Medium"], Enum.FontStyle.Normal),
        TextSize=size or 16, TextColor3=color or THEME.text,
        TextXAlignment = center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    })
end

-- Responsive scale (keeps window readable on phones)
local function autoScale(frame)
    local scale = Instance.new("UIScale"); scale.Parent = frame
    local function rescale()
        local w = frame.AbsoluteSize.X > 0 and frame.AbsoluteSize.X or frame.Parent.AbsoluteSize.X
        -- target 620px design width => compute factor from viewport width
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 800
        local s = math.clamp(vp / 1000, 0.65, 1) -- 0.65x on small phones, up to 1x on desktop
        scale.Scale = s
    end
    rescale()
    game:GetService("RunService").RenderStepped:Connect(rescale)
end

-- ========= ROOT / WINDOW =========
function MiniUI:CreateWindow(opts)
    opts = opts or {}
    local title = opts.title or "MiniUI Window"
    local sizeW, sizeH = opts.width or 640, opts.height or 560

    local gui = mk("ScreenGui", {
        Name = opts.name or "MiniUI", 
        ResetOnSpawn=false, 
        IgnoreGuiInset=true,
        DisplayOrder = 999
    })
    gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    -- Main window frame
    local root = mk("Frame", {
        Parent=gui, 
        BackgroundColor3=THEME.bg,
        Size=UDim2.fromOffset(sizeW, sizeH),
        Position=UDim2.fromScale(0.5, 0.5), 
        AnchorPoint=Vector2.new(0.5,0.5),
        Visible = false -- Start hidden
    })
    round(root, 10); stroke(root, 2, THEME.border, 0.2)
    autoScale(root)

    -- Drag functionality (improved for mobile)
    local dragging, dragInput, dragStart, startPos
    local function updateInput(input)
        local delta = input.Position - dragStart
        root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    root.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    root.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)

    -- Top bar with title and close button
    local top = mk("Frame", {
        Parent=root, 
        BackgroundTransparency=1, 
        Size=UDim2.new(1,-16,0,36), 
        Position=UDim2.fromOffset(8,6)
    })
    
    -- Close button (top right)
    local closeBtn = mk("TextButton", {
        Parent=top,
        BackgroundTransparency=1,
        Size=UDim2.fromOffset(24,24),
        Position=UDim2.new(1,-24,0,6),
        TextColor3=THEME.text,
        Text="X",
        TextSize=18,
        Font=Enum.Font.GothamBold
    })
    closeBtn.MouseButton1Click:Connect(function()
        root.Visible = false
        if gui:FindFirstChild("OpenButton") then
            gui.OpenButton.Visible = true
        end
    end)

    -- Title label
    local titleLbl = text(top, title, 18, true)
    titleLbl.Size = UDim2.new(1,-60,1,0)
    titleLbl.Position = UDim2.fromOffset(30,0)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Tabs row
    local tabBar = mk("Frame", {
        Parent=root, 
        BackgroundTransparency=1, 
        Size=UDim2.new(1,-16,0,28), 
        Position=UDim2.fromOffset(8,44)
    })
    local tabLayout = mk("UIListLayout", {
        Parent=tabBar, 
        FillDirection=Enum.FillDirection.Horizontal, 
        Padding=UDim.new(0,14), 
        VerticalAlignment=Enum.VerticalAlignment.Center
    })

    -- Content host
    local content = mk("Frame", {
        Parent=root, 
        BackgroundTransparency=1, 
        Size=UDim2.new(1,-16,1,-90), 
        Position=UDim2.fromOffset(8,76)
    })

    -- Corner labels (bottom left and right)
    local bottomLeftLabel = text(root, opts.leftLabel or "", 14, false, THEME.dim)
    bottomLeftLabel.Size = UDim2.fromOffset(200,20)
    bottomLeftLabel.Position = UDim2.fromOffset(12, sizeH-24)
    bottomLeftLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local bottomRightLabel = text(root, opts.rightLabel or "", 14, false, THEME.dim)
    bottomRightLabel.Size = UDim2.fromOffset(200,20)
    bottomRightLabel.Position = UDim2.new(1,-212,1,-24)
    bottomRightLabel.TextXAlignment = Enum.TextXAlignment.Right

    -- Open button (shown when UI is closed)
    local openBtn = mk("TextButton", {
        Parent=gui,
        Name = "OpenButton",
        BackgroundColor3=THEME.panel2,
        Size=UDim2.fromOffset(80,36),
        Position=UDim2.fromScale(0.5, 0.02),
        AnchorPoint=Vector2.new(0.5,0),
        TextColor3=THEME.text,
        Text="Open",
        TextSize=16,
        AutoButtonColor=false
    })
    round(openBtn, 6)
    stroke(openBtn, 1, THEME.border, 0.5)
    
    openBtn.MouseButton1Click:Connect(function()
        root.Visible = true
        openBtn.Visible = false
    end)

    -- Public window object
    local win = { 
        _gui = gui, 
        _root = root, 
        _tabBar = tabBar, 
        _content = content, 
        _tabs = {}, 
        _active = nil,
        _openBtn = openBtn,
        _closeBtn = closeBtn,
        _leftLabel = bottomLeftLabel,
        _rightLabel = bottomRightLabel
    }

    function win:SetLeftLabel(text)
        self._leftLabel.Text = text or ""
    end

    function win:SetRightLabel(text)
        self._rightLabel.Text = text or ""
    end

    function win:Toggle()
        root.Visible = not root.Visible
        openBtn.Visible = not root.Visible
    end

    function win:AddTab(name)
        local btn = mk("TextButton", {
            Parent=tabBar, 
            AutoButtonColor=false, 
            BackgroundTransparency=1, 
            Text=name,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
            TextColor3 = THEME.text, 
            TextSize=18
        })
        btn.Size = UDim2.fromOffset(#name*9+14, 28)

        local page = mk("Frame", {
            Parent=content, 
            BackgroundTransparency=1, 
            Size=UDim2.new(1,0,1,0), 
            Visible=false
        })

        local function activate()
            for _,t in pairs(win._tabs) do 
                t.page.Visible=false; 
                t.btn.TextColor3=THEME.text 
            end
            page.Visible=true; 
            btn.TextColor3=THEME.accent; 
            win._active = page
        end
        btn.MouseButton1Click:Connect(activate)

        local tabObj = {btn=btn, page=page}
        table.insert(win._tabs, tabObj)
        if #win._tabs==1 then activate() end

        -- Sections container (scrolling)
        local scroller = mk("ScrollingFrame", {
            Parent = page, 
            BackgroundTransparency=1, 
            Size=UDim2.fromScale(1,1),
            CanvasSize=UDim2.new(0,0,0,0), 
            ScrollBarThickness=6, 
            AutomaticCanvasSize=Enum.AutomaticSize.Y
        })
        local list = mk("UIListLayout", {
            Parent=scroller, 
            Padding=UDim.new(0,10)
        })
        list.SortOrder = Enum.SortOrder.LayoutOrder

        function tabObj:AddSection(headerText)
            local holder = mk("Frame", {
                Parent=scroller, 
                BackgroundTransparency=1, 
                Size=UDim2.new(1,0,0,0), 
                AutomaticSize=Enum.AutomaticSize.Y
            })
            local header = text(holder, headerText, 18, true, THEME.accent, true)
            header.Size = UDim2.new(1,0,0,26)

            local panel = mk("Frame", {
                Parent=holder, 
                BackgroundColor3=THEME.panel2, 
                Size=UDim2.new(1,0,0,0), 
                AutomaticSize=Enum.AutomaticSize.Y
            })
            round(panel, 8); stroke(panel, 1, THEME.border, 0.45)

            local innerScroll = mk("ScrollingFrame", {
                Parent=panel, 
                BackgroundColor3=THEME.panel, 
                BorderSizePixel=0,
                Position=UDim2.fromOffset(8,8), 
                Size=UDim2.new(1,-16,0,0), 
                AutomaticSize=Enum.AutomaticSize.Y,
                CanvasSize=UDim2.fromScale(0,0), 
                ScrollBarThickness=6
            })
            round(innerScroll, 6); stroke(innerScroll, 1, THEME.border, 0.6)

            local lay = mk("UIListLayout", {
                Parent=innerScroll, 
                Padding=UDim.new(0,8)
            })
            lay.SortOrder = Enum.SortOrder.LayoutOrder

            local sec = {}

            -- item builders -------------
            local function rowBase(h)
                local r = mk("Frame", {
                    Parent=innerScroll, 
                    BackgroundColor3=THEME.panel, 
                    Size=UDim2.new(1,-16,0,h or 36)
                })
                r.AutomaticSize = Enum.AutomaticSize.None; round(r,6); stroke(r,1,THEME.border,0.55)
                return r
            end

            function sec:AddButton(labelText, callback)
                local r = rowBase()
                local lbl = text(r, labelText, 16, false); lbl.Size=UDim2.new(1,-110,1,0); lbl.Position=UDim2.fromOffset(12,0)
                local btn = mk("TextButton", {
                    Parent=r, 
                    BackgroundColor3=THEME.panel2, 
                    AutoButtonColor=false, 
                    Text="Click", 
                    TextColor3=THEME.text, 
                    TextSize=16, 
                    Size=UDim2.fromOffset(64,26), 
                    Position=UDim2.new(1,-76,0.5,-13)
                })
                round(btn,6); stroke(btn,1,THEME.border,0.5)
                btn.MouseButton1Click:Connect(function() if callback then callback() end end)
                return btn
            end

            function sec:AddToggle(labelText, default, callback)
                local r = rowBase()
                local lbl = text(r, labelText, 16, false); lbl.Size=UDim2.new(1,-110,1,0); lbl.Position=UDim2.fromOffset(12,0)
                local btn = mk("TextButton", {
                    Parent=r, 
                    BackgroundColor3= default and THEME.on or THEME.off, 
                    AutoButtonColor=false, 
                    Text= default and "On" or "Off", 
                    TextColor3=THEME.text, 
                    TextSize=16, 
                    Size=UDim2.fromOffset(64,26), 
                    Position=UDim2.new(1,-76,0.5,-13)
                })
                round(btn,6); stroke(btn,1,THEME.border,0.5)
                local state = default and true or false
                btn.MouseButton1Click:Connect(function()
                    state = not state
                    btn.BackgroundColor3 = state and THEME.on or THEME.off
                    btn.Text = state and "On" or "Off"
                    if callback then callback(state) end
                end)
                return btn
            end

            function sec:AddNumberBox(labelText, default, callback)
                local r = rowBase()
                local lbl = text(r, labelText, 16, false); lbl.Size=UDim2.new(1,-160,1,0); lbl.Position=UDim2.fromOffset(12,0)
                local box = mk("TextBox", {
                    Parent=r, 
                    BackgroundColor3=THEME.panel2, 
                    Text=tostring(default or 0), 
                    TextSize=16, 
                    TextColor3=THEME.text, 
                    ClearTextOnFocus=false, 
                    Size=UDim2.fromOffset(80,26), 
                    Position=UDim2.new(1,-92,0.5,-13)
                })
                round(box,6); stroke(box,1,THEME.border,0.5)
                box.FocusLost:Connect(function()
                    local n = tonumber(box.Text) or 0; box.Text = tostring(n); if callback then callback(n) end
                end)
                return box
            end

            function sec:AddSlider(labelText, min, max, default, callback)
                min = min or 0; max = max or 100; default = math.clamp(default or min, min, max)
                local r = rowBase(44)
                local lbl = text(r, labelText.." ("..tostring(default)..")", 16, false); lbl.Size=UDim2.new(1,-160,0,20); lbl.Position=UDim2.fromOffset(12,4)

                local bar = mk("Frame", {
                    Parent=r, 
                    BackgroundColor3=THEME.panel2, 
                    Size=UDim2.new(1,-32,0,8), 
                    Position=UDim2.fromOffset(12,28)
                })
                round(bar,4); stroke(bar,1,THEME.border,0.6)
                local fill = mk("Frame", {
                    Parent=bar, 
                    BackgroundColor3=THEME.accent, 
                    Size=UDim2.new((default-min)/(max-min),0,1,0)
                })
                round(fill,4)
                local dragging=false
                local function setFromX(x)
                    local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + rel*(max-min) + 0.5)
                    fill.Size = UDim2.new((val-min)/(max-min),0,1,0)
                    lbl.Text = labelText.." ("..tostring(val)..")"
                    if callback then callback(val) end
                end
                bar.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; setFromX(i.Position.X) end
                end)
                bar.InputEnded:Connect(function(i) dragging=false end)
                game:GetService("UserInputService").InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setFromX(i.Position.X) end
                end)
                return {Set=function(v) setFromX(bar.AbsolutePosition.X + (math.clamp(v,min,max)-min)/(max-min)*bar.AbsoluteSize.X) end}
            end

            function sec:AddDropdown(labelText, options, defaultIndex, callback)
                options = options or {}
                local r = rowBase(40)
                local lbl = text(r, labelText, 16, false); lbl.Size=UDim2.new(1,-160,1,0); lbl.Position=UDim2.fromOffset(12,0)

                local current = options[defaultIndex or 1] or ""
                local dd = mk("TextButton", {
                    Parent=r, 
                    BackgroundColor3=THEME.panel2, 
                    AutoButtonColor=false, 
                    Text=current, 
                    TextColor3=THEME.text, 
                    TextSize=16, 
                    Size=UDim2.fromOffset(140,26), 
                    Position=UDim2.new(1,-156,0.5,-13)
                })
                round(dd,6); stroke(dd,1,THEME.border,0.5)

                local listOpen = mk("Frame", {
                    Parent=r, 
                    BackgroundColor3=THEME.panel2, 
                    Visible=false, 
                    Position=UDim2.new(1,-156,0,34), 
                    Size=UDim2.fromOffset(140,0), 
                    AutomaticSize=Enum.AutomaticSize.Y
                })
                round(listOpen,8); stroke(listOpen,1,THEME.border,0.5)
                local s = mk("ScrollingFrame", {
                    Parent=listOpen, 
                    BackgroundTransparency=1, 
                    CanvasSize=UDim2.fromScale(0,0), 
                    AutomaticCanvasSize=Enum.AutomaticSize.Y, 
                    Size=UDim2.new(1,0,1,0), 
                    ScrollBarThickness=6
                })
                local l = mk("UIListLayout", {
                    Parent=s, 
                    Padding=UDim.new(0,4)
                })

                local function setChoice(v)
                    dd.Text = v; if callback then callback(v) end
                end
                for _,opt in ipairs(options) do
                    local b = mk("TextButton", {
                        Parent=s, 
                        AutoButtonColor=true, 
                        BackgroundColor3=THEME.panel, 
                        Text=opt, 
                        TextColor3=THEME.text, 
                        TextSize=16, 
                        Size=UDim2.new(1,-8,0,28)
                    })
                    round(b,6); stroke(b,1,THEME.border,0.6)
                    b.MouseButton1Click:Connect(function() setChoice(opt); listOpen.Visible=false end)
                end
                dd.MouseButton1Click:Connect(function() listOpen.Visible = not listOpen.Visible end)

                return {Set=setChoice, Open=function(x) listOpen.Visible=true end, Close=function() listOpen.Visible=false end}
            end

            return sec
        end

        return tabObj
    end

    return win
end

return MiniUI
