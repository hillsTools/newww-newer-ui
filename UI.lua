-- bronx.lol UI
-- Improved version with better organization, mobile support, and requested features

local BronxUI = {}

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

-- Responsive scale for mobile
local function autoScale(frame)
    local scale = Instance.new("UIScale"); scale.Parent = frame
    local function rescale()
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 800
        local s = math.clamp(vp / 1000, 0.65, 1)
        scale.Scale = s
    end
    rescale()
    game:GetService("RunService").RenderStepped:Connect(rescale)
end

-- ========= MAIN UI =========
function BronxUI:CreateUI()
    local gui = mk("ScreenGui", {Name = "BronxUI", ResetOnSpawn=false, IgnoreGuiInset=true})
    gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    -- Main container
    local mainFrame = mk("Frame", {
        Parent = gui, 
        BackgroundColor3 = THEME.bg,
        Size = UDim2.fromOffset(650, 600),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Visible = false
    })
    round(mainFrame, 12)
    stroke(mainFrame, 2, THEME.border, 0.2)
    autoScale(mainFrame)

    -- Open button (centered top)
    local openBtn = mk("TextButton", {
        Parent = gui,
        BackgroundColor3 = THEME.panel2,
        TextColor3 = THEME.text,
        Text = "bronx.lol",
        Size = UDim2.fromOffset(120, 36),
        Position = UDim2.fromScale(0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        TextSize = 18,
        Font = Enum.Font.GothamBold
    })
    round(openBtn, 6)
    stroke(openBtn, 1, THEME.border, 0.5)

    -- Close button (top right)
    local closeBtn = mk("TextButton", {
        Parent = mainFrame,
        BackgroundColor3 = THEME.panel2,
        TextColor3 = THEME.text,
        Text = "X",
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -40, 0, 10),
        TextSize = 18,
        Font = Enum.Font.GothamBold
    })
    round(closeBtn, 6)
    stroke(closeBtn, 1, THEME.border, 0.5)

    -- Corner labels
    local bottomLeftLabel = mk("TextLabel", {
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Text = "Left Label",
        TextColor3 = THEME.dim,
        Size = UDim2.fromOffset(150, 20),
        Position = UDim2.new(0, 10, 1, -25),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local bottomRightLabel = mk("TextLabel", {
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Text = "Right Label",
        TextColor3 = THEME.dim,
        Size = UDim2.fromOffset(150, 20),
        Position = UDim2.new(1, -160, 1, -25),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    -- Title
    local title = mk("TextLabel", {
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Text = "bronx.lol",
        TextColor3 = THEME.accent,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.fromOffset(0, 10),
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    -- Tab system
    local tabContainer = mk("Frame", {
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -80),
        Position = UDim2.fromOffset(10, 60)
    })

    -- Left tabs column
    local tabButtons = mk("Frame", {
        Parent = tabContainer,
        BackgroundColor3 = THEME.panel2,
        Size = UDim2.fromOffset(120, 1),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0)
    })
    round(tabButtons, 8)
    stroke(tabButtons, 1, THEME.border, 0.4)

    local tabListLayout = mk("UIListLayout", {
        Parent = tabButtons,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    -- Content area
    local contentFrame = mk("Frame", {
        Parent = tabContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -140, 1, 0),
        Position = UDim2.fromOffset(130, 0)
    })

    local contentScroller = mk("ScrollingFrame", {
        Parent = contentFrame,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.fromScale(0, 0),
        ScrollBarThickness = 6,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    local contentLayout = mk("UIListLayout", {
        Parent = contentScroller,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    -- Tab sections
    local tabs = {}
    local currentTab = nil

    local function createTab(name)
        local tabBtn = mk("TextButton", {
            Parent = tabButtons,
            BackgroundColor3 = THEME.panel,
            TextColor3 = THEME.text,
            Text = name,
            Size = UDim2.new(1, -10, 0, 36),
            TextSize = 16,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false
        })
        round(tabBtn, 6)
        stroke(tabBtn, 1, THEME.border, 0.5)

        local tabContent = mk("Frame", {
            Parent = contentScroller,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false
        })

        local tabSections = {}

        local function activate()
            if currentTab then
                currentTab.content.Visible = false
                currentTab.button.BackgroundColor3 = THEME.panel
            end
            
            tabContent.Visible = true
            tabBtn.BackgroundColor3 = THEME.accent
            currentTab = {content = tabContent, button = tabBtn}
        end

        tabBtn.MouseButton1Click:Connect(activate)

        local tabObj = {
            button = tabBtn,
            content = tabContent,
            activate = activate,
            addSection = function(header)
                local section = mk("Frame", {
                    Parent = tabContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y
                })

                local sectionHeader = mk("TextLabel", {
                    Parent = section,
                    BackgroundTransparency = 1,
                    Text = header,
                    TextColor3 = THEME.accent,
                    Size = UDim2.new(1, 0, 0, 30),
                    TextSize = 18,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local sectionContent = mk("Frame", {
                    Parent = section,
                    BackgroundColor3 = THEME.panel2,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                round(sectionContent, 8)
                stroke(sectionContent, 1, THEME.border, 0.4)

                local sectionLayout = mk("UIListLayout", {
                    Parent = sectionContent,
                    Padding = UDim.new(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                local sectionPadding = mk("UIPadding", {
                    Parent = sectionContent,
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    PaddingTop = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8)
                })

                local sectionObj = {}

                -- Add toggle function
                function sectionObj:addToggle(text, default, callback)
                    local toggleFrame = mk("Frame", {
                        Parent = sectionContent,
                        BackgroundColor3 = THEME.panel,
                        Size = UDim2.new(1, 0, 0, 36),
                        AutomaticSize = Enum.AutomaticSize.None
                    })
                    round(toggleFrame, 6)
                    stroke(toggleFrame, 1, THEME.border, 0.5)

                    local toggleLabel = mk("TextLabel", {
                        Parent = toggleFrame,
                        BackgroundTransparency = 1,
                        Text = text,
                        TextColor3 = THEME.text,
                        Size = UDim2.new(0.7, 0, 1, 0),
                        Position = UDim2.fromOffset(10, 0),
                        TextSize = 16,
                        Font = Enum.Font.GothamMedium,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    local toggleBtn = mk("TextButton", {
                        Parent = toggleFrame,
                        BackgroundColor3 = default and THEME.on or THEME.off,
                        TextColor3 = THEME.text,
                        Text = default and "ON" or "OFF",
                        Size = UDim2.fromOffset(70, 26),
                        Position = UDim2.new(1, -80, 0.5, -13),
                        TextSize = 16,
                        Font = Enum.Font.GothamBold,
                        AutoButtonColor = false
                    })
                    round(toggleBtn, 6)
                    stroke(toggleBtn, 1, THEME.border, 0.5)

                    local state = default or false

                    toggleBtn.MouseButton1Click:Connect(function()
                        state = not state
                        toggleBtn.BackgroundColor3 = state and THEME.on or THEME.off
                        toggleBtn.Text = state and "ON" or "OFF"
                        if callback then callback(state) end
                    end)

                    return {
                        set = function(value)
                            state = value
                            toggleBtn.BackgroundColor3 = state and THEME.on or THEME.off
                            toggleBtn.Text = state and "ON" or "OFF"
                            if callback then callback(state) end
                        end,
                        get = function() return state end
                    }
                end

                -- Add button function
                function sectionObj:addButton(text, callback)
                    local btnFrame = mk("TextButton", {
                        Parent = sectionContent,
                        BackgroundColor3 = THEME.panel,
                        TextColor3 = THEME.text,
                        Text = text,
                        Size = UDim2.new(1, 0, 0, 36),
                        TextSize = 16,
                        Font = Enum.Font.GothamMedium,
                        AutoButtonColor = false
                    })
                    round(btnFrame, 6)
                    stroke(btnFrame, 1, THEME.border, 0.5)

                    btnFrame.MouseButton1Click:Connect(function()
                        if callback then callback() end
                    end)

                    return btnFrame
                end

                -- Add label function
                function sectionObj:addLabel(text)
                    local label = mk("TextLabel", {
                        Parent = sectionContent,
                        BackgroundTransparency = 1,
                        Text = text,
                        TextColor3 = THEME.text,
                        Size = UDim2.new(1, 0, 0, 20),
                        TextSize = 14,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    return label
                end

                table.insert(tabSections, sectionObj)
                return sectionObj
            end
        }

        table.insert(tabs, tabObj)
        return tabObj
    end

    -- Create all tabs from your structure
    local gameTab = createTab("Game")
    local worldTab = createTab("World")
    local farmingTab = createTab("Farming")
    local manualFarmsTab = createTab("Manual Farms")
    local farmingSettingsTab = createTab("Farming Settings")
    local miscTab = createTab("Misc")
    local vulnerabilityTab = createTab("Vulnerability")
    local killAuraTab = createTab("Kill Aura")

    -- Game tab sections
    do
        local mainSection = gameTab.addSection("Main")
        mainSection:addToggle("Combat", false)
        mainSection:addToggle("Silent Aim", false)
        mainSection:addToggle("Aimlock", false)
        
        local modSection = gameTab.addSection("Modifications")
        -- Add modification options here
    end

    -- World tab sections
    do
        local visualsSection = worldTab.addSection("Visuals")
        -- Add visuals options here
        
        local settingsSection = worldTab.addSection("Settings")
        -- Add settings options here
        
        local configsSection = worldTab.addSection("Configs")
        -- Add configs options here
    end

    -- Farming tab sections
    do
        farmingTab.addSection("Auto Farm"):addToggle("Construction", false)
        farmingTab.addSection("Auto Farm"):addToggle("Bank Robbery", false)
        farmingTab.addSection("Auto Farm"):addToggle("House Robbery", false)
        farmingTab.addSection("Auto Farm"):addToggle("Studio Robbery", false)
        farmingTab.addSection("Auto Farm"):addToggle("Dumpsters", false)
    end

    -- Manual Farms tab sections
    do
        manualFarmsTab.addSection("Auto Collect"):addToggle("Dropped Cash", false)
        manualFarmsTab.addSection("Auto Collect"):addToggle("Dropped Bags", false)
        manualFarmsTab.addSection(""):addButton("Clean All Filthy Money")
    end

    -- Farming Settings tab sections
    do
        farmingSettingsTab.addSection(""):addToggle("AFK Safety Teleport", false)
        farmingSettingsTab.addSection(""):addToggle("Auto Sell Trash", false)
    end

    -- Misc tab sections
    do
        local dupingSection = miscTab.addSection("Duping Section")
        dupingSection:addButton("Duplicate Current Item")
        dupingSection:addLabel("This might bug if you have more than 1 of the item you're duping!")
    end

    -- Vulnerability tab sections
    do
        local moneySection = vulnerabilityTab.addSection("Generate Max Illegal Money")
        moneySection:addLabel("Money Generator takes around 3 minutes, and can take longer")
        moneySection:addLabel("if some items are not in stock. You will need around 5K to do this.")
        moneySection:addButton("Generate Money")
    end

    -- Kill Aura tab sections
    do
        local killAuraSection = killAuraTab.addSection("Kill Aura Settings")
        killAuraSection:addToggle("Enabled - Hold Gun", false)
        killAuraSection:addLabel("Kill Aura Range")
        -- Could add a slider here for range
    end

    -- UI toggle functionality
    openBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        openBtn.Visible = false
        if #tabs > 0 then
            tabs[1].activate()
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        openBtn.Visible = true
    end)

    -- Make draggable
    local dragging = false
    local dragInput, dragStart, startPos

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Public methods
    local public = {
        _gui = gui,
        setLeftLabel = function(text) bottomLeftLabel.Text = text end,
        setRightLabel = function(text) bottomRightLabel.Text = text end,
        toggle = function() 
            mainFrame.Visible = not mainFrame.Visible 
            openBtn.Visible = not mainFrame.Visible
        end
    }

    return public
end

return BronxUI
