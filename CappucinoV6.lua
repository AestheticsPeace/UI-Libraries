local function getExploit()
    if syn and type(syn.protect_gui) == 'function' then
        return 'synapse'
    else
        return 'krnl'
    end
end

local exploit = getExploit()

if exploit == 'krnl' then
    getgenv().syn = {
        request = function(s)
            return http_request(s)
        end
    }
end

getgenv().version = 'v1.3'
print('UI library made by boop71 // version: '..version)

local function instance(className,properties,children,funcs) local object = Instance.new(className,parent);for i,v in pairs(properties or {}) do object[i] = v;end;for i, self in pairs(children or {}) do self.Parent = object;end;for i,func in pairs(funcs or {}) do func(object);end;return object end
local function ts(object,tweenInfo,properties) if tweenInfo[2] and typeof(tweenInfo[2]) == 'string' then tweenInfo[2] = Enum.EasingStyle[ tweenInfo[2] ];end;game:service('TweenService'):create(object, TweenInfo.new(unpack(tweenInfo)), properties):Play();end
local function udim2(x1,x2,y1,y2) local t = tonumber;return UDim2.new(t(x1),t(x2),t(y1),t(y2)) end
local function rgb(r,g,b) return Color3.fromRGB(r,g,b);end

local http = game:service('HttpService')
local json = {
    encode = function(body)
        return http:JSONEncode(body)
    end,
    decode = function(body)
        return http:JSONDecode(body)
    end
}

if not blurModule then
    getgenv().blurModule = loadstring(syn.request({Url = 'https://raw.githubusercontent.com/boop71/cappuccino-new/main/utilities/blurModule.lua', Method = 'GET'}).Body)()
end

local bKeys = {'W','A','S','D','Space','Escape','RightShift', 'Return'}

local function scale(unscaled, minAllowed, maxAllowed, min, max)
    return (maxAllowed - minAllowed) * (unscaled - min) / (max - min) + minAllowed
end

setreadonly(table, false)
table.len = function(t)
    local c = 0
    for a,v in next, t do
        c = c + 1
    end
    return c
end
setreadonly(table, true)

if not game:service('Lighting'):FindFirstChild('cap_blur') then
    instance('DepthOfFieldEffect', {
        Parent = game:service('Lighting'),
        FarIntensity = 0,
        Name = 'cap_blur',
        FocusDistance = 51.5,
        InFocusRadius = 50,
        NearIntensity = 1,
        Enabled = true
    })
end

local function checkKey(en)
    local d = pcall(function()
        return Enum.KeyCode[en]
    end)
    if d then
        return Enum.KeyCode[en]
    else
        return nil
    end
end

local p = {}
for a,v in next, bKeys do
    table.insert(p, #p+1, Enum.KeyCode[v])
end
bKeys = p
p = nil

if not isfolder('cappuccino-v6') then
    makefolder('cappuccino-v6')
end

if not cap then
    getgenv().cap = {
        write = function(fileName, content)
            writefile(('cappuccino-v6/%s'):format(fileName), content)
        end,
        read = function(fileName)
            return readfile(('cappuccino-v6/%s'):format(fileName))
        end,
        isfile = function(fileName)
            return isfile(('cappuccino-v6/%s'):format(fileName))
        end
    }
end

if not cap.isfile('ui_settings.json') then
    cap.write('ui_settings.json', json.encode({
        theme = {124, 170, 255},
        rainbowSpeed = 15,
        blurLevel = 0.8,
        protectUi = false,
        showWatermark = false,
        hidePremium = false,
        tabAlignment = 'Left',
        tabRoundness = 16,
    }))
end

local gd = json.decode(cap.read('ui_settings.json'))

local mouse = game:service('Players').LocalPlayer:GetMouse()

local function checkPos(obj)
    local x, y = mouse.X, mouse.Y
    local abs, abp = obj.AbsoluteSize, obj.AbsolutePosition

    if x > abp.X and x < (abp.X + abs.X) and y > abp.Y and y < (abp.Y + abs.Y) then
        return true
    end
    return nil
end

local function onHover(obj, duration, callback, returnCall)
    spawn(function()
        local call = false
        while true do
            wait()
            if checkPos(obj) then
                repeat
                    wait()
                    if not call then
                        call = true

                        wait(0.05)
                        local pos = Vector3.new(mouse.X, mouse.Y, 0)
            
                        delay(duration, function()
                            if (pos - Vector3.new(mouse.X, mouse.Y, 0)).magnitude < 10 then
                                callback()
                                repeat
                                    wait(0.3)
                                until (pos - Vector3.new(mouse.X, mouse.Y, 0)).magnitude > 10
                                call = false
                                returnCall()
                            else
                                call = false
                            end
                        end)
                    end
                until not checkPos(obj)
            end
        end
    end)
end

local function bindToMouse(func)
    game:service('UserInputService').InputBegan:connect(function(k, t)
        if t then
            return
        end
        if k.UserInputType == Enum.UserInputType.MouseButton1 then
            func()
        end
    end)
end

local function bindToMoueUp(func)
    game:service('UserInputService').InputEnded:connect(function(k, t)
        if t then
            return
        end
        if k.UserInputType == Enum.UserInputType.MouseButton1 then
            func()
        end
    end)
end


local function getRel(object)
    return {
        X = (mouse.X - object.AbsolutePosition.X),
        Y = (mouse.Y - object.AbsolutePosition.Y)
    }
end

local function getTheme()
    local t = json.decode(cap.read('ui_settings.json')).theme
    return Color3.fromRGB(t[1], t[2], t[3])
end

local function bubble(object, color)
    local rel = getRel(object)

    local bInst = instance('Frame', {
        Parent = object,
        Size = udim2(0, 0, 0, 0),
        Position = udim2(0, rel.X, 0, rel.Y),
        BackgroundTransparency = 0,
        BackgroundColor3 = getTheme(),
    }, {
        instance('UICorner', {
            CornerRadius = UDim.new(1, 0)
        })
    })

    ts(bInst, {0.6, 'Exponential'}, {
        Size = udim2(0, 300, 0, 300),
        Position = udim2(0, rel.X - 150, 0, rel.Y - 150),
        BackgroundTransparency = 1
    })

    delay(0.6, function()
        bInst:Destroy()
    end)
end

local mouse = game:service('Players').LocalPlayer:GetMouse()

local function dragify(frame) 
    local connection, move, kill
    local function connect()
        connection = frame.InputBegan:Connect(function(inp) 
            pcall(function() 
                if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then 
                    local mx, my = mouse.X, mouse.Y 
                    move = mouse.Move:Connect(function() 
                        local nmx, nmy = mouse.X, mouse.Y 
                        local dx, dy = nmx - mx, nmy - my 
                        frame.Position = frame.Position + UDim2.fromOffset(dx, dy)
                        mx, my = nmx, nmy 
                    end) 
                    kill = frame.InputEnded:Connect(function(inputType) 
                        if inputType.UserInputType == Enum.UserInputType.MouseButton1 then 
                            move:Disconnect() 
                            kill:Disconnect() 
                        end 
                    end) 
                end 
            end) 
        end) 
    end
    connect()
    return {
        disconnect = function()
            connection:Disconnect()
        end,
        reconnect = connect,
        killConnection = function()
            move:Disconnect()
            kill:Disconnect()
        end
    }
end

local function makeBetter(obj)
    local drag = dragify(obj)

    local button = instance('TextButton', {
        Parent = obj,
        Size = udim2(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = '',
        Position = udim2(1, -10, 1, -10)
    })

    local holding = false
    button.MouseButton1Down:Connect(function()
        holding = true
        drag.disconnect()

        spawn(function()
            repeat
                local sX, sY = (getRel(obj).X - obj.AbsoluteSize.X), (getRel(obj).Y - obj.AbsoluteSize.Y)
                wait()
                ts(obj, {0.5, 'Exponential'}, {
                    Size = udim2(0, obj.AbsoluteSize.X + sX, 0, obj.AbsoluteSize.Y + sY)
                })
            until not holding
        end)
    end)

    local function unhold()
        if holding then
            holding = false
            drag.reconnect()
        end
    end

    button.MouseButton1Up:Connect(unhold)
    mouse.Button1Up:Connect(unhold)
end

local function randomText(len)
    local d = '' 
    for a=1,len do
        d = d .. utf8.char(math.random(20, 80))
    end
    return d
end

local function fixInt(int) 
    return tonumber(string.format('%.02f', int)) 
end

local function round(exact, quantum)
    local quant, frac = math.modf(exact/quantum)
    return fixInt(quantum * (quant + (frac > 0.5 and 1 or 0)))
end

local sgui

local sliderUsing = false

local create = { --all ui library features
    button = function(v2, data, obj)
        v2.text = typeof(v2.text) == 'string' and v2.text or '[button name emtpy]'
        v2.callback = typeof(v2.callback) == 'function' and v2.callback or function() end
        v2.tooltip = typeof(v2.tooltip) == 'string' and v2.tooltip or nil

        local button = instance('Frame', {
            Size = udim2(1, 0, 0, 30),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = rgb(0, 0, 0),
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 6)
            }),
            instance('TextButton', {
                Text = v2.text,
                Font = 'Gotham',
                Size = udim2(1, -13, 1, -6),
                Position = udim2(0, 10, 0, 3),
                TextSize = 13,
                TextColor3 = rgb(255, 255, 255),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                TextXAlignment = 'Left'
            }, {}, {
                function(self)
                    self.MouseButton1Down:Connect(function()
                        bubble(self, data.theme.accent)
                        v2.callback()
                    end)
                end
            }),
            instance('ImageLabel', {
                Size = udim2(0, 22, 0, 22),
                Position = udim2(1, -26, 0.5, -11),
                BackgroundTransparency = 1,
                Image = 'rbxassetid://11243256070'
            })
        })

        local tip = getgenv().tipMenu
        spawn(function()
            repeat
                wait()
                tip = getgenv().tipMenu
            until table.len(getgenv().tipMenu) == 3
        end)
        
        local toolTipActive = false
        if v2.tooltip then
            onHover(button.TextButton, 0.5, function()
                if checkPos(obj) then
                    toolTipActive = true
                    tipMenu.update(v2.text, v2.tooltip)
                    tipMenu.open()  
                end
            end, function()
                if toolTipActive then
                    tipMenu.update('', '')
                    tipMenu.close()
                end
            end)
        end

        button.Parent = obj
    end,
    toggle = function(v2, data, obj)
        v2.text = typeof(v2.text) == 'string' and v2.text or '[toggle name empty]'
        v2.state = typeof(v2.state) == 'boolean' and v2.state or false
        v2.callback = typeof(v2.callback) == 'function' and v2.callback or function() end

        local toggled = v2.state

        local body = instance('Frame', {
            Size = udim2(1, 0, 0, 30),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = rgb(0, 0, 0),
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 6)
            }),
            instance('Frame', {
                Position = udim2(1, -24, 0, 6),
                Size = udim2(0, 18, 0, 18),
                BackgroundTransparency = toggled and 0.5 or 0.9,
                BackgroundColor3 = data.theme.accent,
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(1, 0)
                }),
                instance('Frame', {
                    Size = toggled and udim2(0, 0, 0, 0) or udim2(1, -4, 1, -4),
                    Position = toggled and udim2(0.5, 0, 0.5, 0) or udim2(0, 2, 0, 2),
                    BackgroundColor3 = toggled and rgb(255, 255, 255) or rgb(0, 0, 0),
                    BackgroundTransparency = toggled and 1 or 0.8
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(1, 0)
                    })
                })
            }),
            instance('TextButton', {
                Position = udim2(0, 10, 0, 0),
                Size = udim2(1, -10, 1, 0),
                BackgroundTransparency = 1,
                Text = v2.text,
                Font = 'Gotham',
                TextSize = 13,
                TextColor3 = rgb(255, 255, 255),
                TextXAlignment = 'Left',
            }, {}, {
                function(self)
                    self.MouseButton1Down:Connect(function()
                        toggled = not toggled
                        ts(self.Parent.Frame, {0.3, 'Exponential'}, {
                            BackgroundTransparency = toggled and 0.5 or 0.9
                        })
                        ts(self.Parent.Frame.Frame, {0.3, 'Exponential'}, {
                            Size = toggled and udim2(0, 0, 0, 0) or udim2(1, -4, 1, -4),
                            Position = toggled and udim2(0.5, 0, 0.5, 0) or udim2(0, 2, 0, 2),
                            BackgroundColor3 = toggled and rgb(255, 255, 255) or rgb(0, 0, 0),
                            BackgroundTransparency = toggled and 1 or 0.7
                        })
                        v2.callback(toggled)
                    end)
                end
            }),
        })

        local tip = getgenv().tipMenu
        spawn(function()
            repeat
                wait()
                tip = getgenv().tipMenu
            until table.len(getgenv().tipMenu) == 3
        end)
        
        local toolTipActive = false
        if v2.tooltip then
            onHover(body.TextButton, 0.5, function()
                if checkPos(obj) then
                    toolTipActive = true
                    tipMenu.update(v2.text, v2.tooltip)
                    tipMenu.open()  
                end
            end, function()
                if toolTipActive then
                    tipMenu.update('', '')
                    tipMenu.close()
                end
            end)
        end

        body.Parent = obj
    end,
    keybind = function(v2, data, obj)
        v2.text = tostring(v2.text)
        v2.key = typeof(v2.key) == 'string' and checkKey(v2.key) or typeof(v2.key) == 'Enum' and v2.key or nil
        v2.callback = typeof(v2.callback) == 'function' and v2.callback or function() end
        v2.newCallback = typeof(v2.newCallback) == 'function' and v2.newCallback or function() end

        local binding = false

        local function measure(txt)
            local tt = game:service('TextService'):GetTextSize(txt, 11, 'Gotham', Vector2.new(math.huge, 22))
            return tt.X + 12
        end

        local function get()
            return measure(tostring(v2.key) ~= 'nil' and tostring(v2.key):split('.')[3] or 'Click here to bind')
        end

        local body = instance('Frame', {
            Size = udim2(1, 0, 0, 30),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = rgb(0, 0, 0),
            ClipsDescendants = true,
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 6)
            }),
            instance('Frame', {
                Size = udim2(0, get(), 1, -8),
                Position = udim2(1, -(get() + 4), 0, 4),
                BackgroundTransparency = 0.8,
                BackgroundColor3 = rgb(0, 0, 0)
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 4)
                }),
                instance('TextLabel', {
                    Text = tostring(v2.key) ~= 'nil' and tostring(v2.key):split('.')[3] or 'Click here to bind',
                    Size = udim2(1, 0, 1, 0),
                    Font = 'Gotham',
                    TextSize = 11,
                    TextColor3 = rgb(255, 255, 255),
                    BackgroundTransparency = 1
                })
            }),
            instance('TextButton', {
                Size = udim2(1, -10, 1, -6),
                Position = udim2(0, 10, 0, 3),
                BackgroundTransparency = 1,
                Font = 'Gotham',
                TextXAlignment = 'Left',
                TextColor3 = rgb(255, 255, 255),
                TextSize = 13,
                ClipsDescendants = true,
                Text = v2.text
            }, {}, {
                function(self)
                    self.MouseButton1Down:Connect(function()
                        bubble(self, data.theme.accent)
                        ts(self.Parent.Frame, {0.1, 'Exponential'}, {
                            BackgroundColor3 = rgb(255, 255, 255),
                            BackgroundTransparency = 0.3,
                            Size = udim2(0, measure('Binding'), 1, -8),
                            Position = udim2(1, -(measure('Binding') + 4), 0, 4),
                        })
                        ts(self.Parent.Frame.TextLabel, {0.3, 'Exponential'}, {
                            TextColor3 = rgb(0, 0, 0)
                        })
                        self.Parent.Frame.TextLabel.Text = 'Binding'

                        local uis;uis = game:service('UserInputService').InputBegan:Connect(function(k, t)
                            if t then return end

                            if not table.find(bKeys, k.KeyCode) then
                                if k.KeyCode == Enum.KeyCode.Unknown then
                                    v2.key = nil
                                    v2.newCallback(nil)
                                    ts(self.Parent.Frame, {0.1, 'Exponential'}, {
                                        BackgroundColor3 = rgb(0, 0, 0),
                                        BackgroundTransparency = 0.8,
                                        Size = udim2(0, measure('Click anywhere to bind'), 1, -8),
                                        Position = udim2(1, -(measure('Click anywhere to bind') + 4), 0, 4),
                                    })
                                    self.Parent.Frame.TextLabel.Text = 'Click anywhere to bind'
                                    uis:Disconnect()
                                    ts(self.Parent.Frame.TextLabel, {0.3, 'Exponential'}, {
                                        TextColor3 = rgb(255, 255, 255)
                                    })
                                    return
                                end
                                v2.newCallback(k.KeyCode)
                                v2.key = k.KeyCode
                                ts(self.Parent.Frame, {0.1, 'Exponential'}, {
                                    BackgroundColor3 = rgb(0, 0, 0),
                                    BackgroundTransparency = 0.8,
                                    Size = udim2(0, get(), 1, -8),
                                    Position = udim2(1, -(get() + 4), 0, 4),
                                })
                                self.Parent.Frame.TextLabel.Text = tostring(v2.key):split('.')[3]
                                uis:Disconnect()
                                ts(self.Parent.Frame.TextLabel, {0.3, 'Exponential'}, {
                                    TextColor3 = rgb(255, 255, 255)
                                })
                            end
                        end)
                    end)
                end
            })
        })

        local tip = getgenv().tipMenu
        spawn(function()
            repeat
                wait()
                tip = getgenv().tipMenu
            until table.len(getgenv().tipMenu) == 3
        end)
        
        local toolTipActive = false
        if v2.tooltip then
            onHover(body.TextButton, 0.5, function()
                if checkPos(obj) then
                    toolTipActive = true
                    tipMenu.update(v2.text, v2.tooltip)
                    tipMenu.open()  
                end
            end, function()
                if toolTipActive then
                    tipMenu.update('', '')
                    tipMenu.close()
                end
            end)
        end

        game:service('UserInputService').InputBegan:Connect(function(k, t)
            if t then return end

            pcall(function()
                if k.KeyCode == v2.key then
                    v2.callback()
                end
            end)
        end)

        body.Parent = obj
    end,
    togglebind = function(v2, data, obj)
        v2.text = typeof(v2.text) == 'string' and v2.text or '[empy togglebind text]'
        v2.state = typeof(v2.state) == 'boolean' and v2.state or false
        v2.key = typeof(v2.key) == 'string' and checkKey(v2.key) or typeof(v2.key) == 'Enum' and v2.key or nil
        v2.callback = typeof(v2.callback) == 'function' and v2.callback or function() end
        v2.newCallback = typeof(v2.newCallback) == 'function' and v2.newCallback or function() end
        v2.hold = typeof(v2.hold) == 'boolean' and v2.hold or false

        local toggled = v2.state

        local function measure(txt)
            local tt = game:service('TextService'):GetTextSize(txt, 11, 'Gotham', Vector2.new(math.huge, math.huge))
            return tt.X + 36
        end

        local function get()
            return measure(tostring(v2.key) ~= 'nil' and tostring(v2.key):split('.')[3] or 'Click here to bind')
        end

        local toggle

        local body = instance('Frame', {
            Size = udim2(1, 0, 0, 30),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = rgb(0, 0, 0),
            ClipsDescendants = true,
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 6)
            }),
            instance('TextButton', {
                Size = udim2(1, -10, 1, -6),
                Position = udim2(0, 10, 0, 3),
                BackgroundTransparency = 1,
                Font = 'Gotham',
                TextXAlignment = 'Left',
                TextColor3 = rgb(255, 255, 255),
                TextSize = 13,
                ClipsDescendants = true,
                Text = v2.text
            }, {}, {
                function(self)
                    self.MouseButton1Down:Connect(function()
                        bubble(self, data.theme.accent)
                        toggled = not toggled
                        toggle(toggled)
                        local d,d2 = pcall(function()
                            v2.callback(toggled)
                        end)
                        if not d then
                            warn('cappuccino error: '..d2)
                        end
                    end)
                end
            }),
            instance('Frame', {
                Size = udim2(0, get(), 1, -8),
                Position = udim2(1, -(get() + 4), 0, 4),
                BackgroundTransparency = 0.8,
                BackgroundColor3 = rgb(0, 0, 0)
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 4)
                }),
                instance('Frame', {
                    Size = udim2(0, 14, 0, 14),
                    Position = udim2(1, -18, 0, 4),
                    Name = 'toggle',
                    BackgroundTransparency = toggled and 0.5 or 0.9,
                    BackgroundColor3 = data.theme.accent
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(1, 0)
                    }),
                    instance('Frame', {
                        Size = udim2(1, -4, 1, -4),
                        Position = udim2(0, 2, 0, 2),
                        BackgroundTransparency = 0.7,
                        BackgroundColor3 = rgb(0, 0, 0)
                    }, {
                        instance('UICorner', {
                            CornerRadius = UDim.new(1, 0)
                        })
                    }),
                }),
                instance('TextButton', {
                    Position = udim2(0, 7, 0, 0),
                    Size = udim2(1, -7, 1, 0),
                    TextSize = 11,
                    TextColor3 = rgb(255, 255, 255),
                    TextXAlignment = 'Left',
                    Font = 'Gotham',
                    BackgroundTransparency = 1,
                    Text = tostring(v2.key) ~= 'nil' and tostring(v2.key):split('.')[3] or 'Click here to bind'
                }, {}, {
                    function(self)
                        self.MouseButton1Down:Connect(function()
                            ts(self.Parent, {0.1, 'Exponential'}, {
                                BackgroundColor3 = rgb(255, 255, 255),
                                BackgroundTransparency = 0.3,
                                Size = udim2(0, measure('Binding'), 1, -8),
                                Position = udim2(1, -(measure('Binding') + 4), 0, 4),
                            })
                            ts(self, {0.3, 'Exponential'}, {
                                TextColor3 = rgb(0, 0, 0)
                            })
                            self.Text = 'Binding'

                            local uis;uis = game:service('UserInputService').InputBegan:Connect(function(k, t)
                                if t then return end

                                if table.find(bKeys, k.KeyCode) or k.KeyCode == Enum.KeyCode.Unknown then
                                    v2.key = nil
                                    v2.newCallback(nil)
                                    ts(self.Parent, {0.1, 'Exponential'}, {
                                        BackgroundColor3 = rgb(0, 0, 0),
                                        BackgroundTransparency = 0.8,
                                        Size = udim2(0, measure('Clik here to bind  '), 1, -8),
                                        Position = udim2(1, -(measure('Click here to bind  ') - 2), 0, 4)
                                    })
                                    self.Text = 'Click here to bind'
                                    uis:Disconnect()
                                    ts(self, {0.3, 'Exponential'}, {
                                        TextColor3 = rgb(255, 255, 255)
                                    })
                                    return
                                end
                                v2.newCallback(k.KeyCode)
                                v2.key = k.KeyCode
                                ts(self.Parent, {0.1, 'Exponential'}, {
                                    BackgroundColor3 = rgb(0, 0, 0),
                                    BackgroundTransparency = 0.8,
                                    Size = udim2(0, get(), 1, -8),
                                    Position = udim2(1, -(get() + 4), 0, 4)
                                })
                                self.Text = tostring(v2.key):split('.')[3]
                                uis:Disconnect()
                                ts(self, {0.3, 'Exponential'}, {
                                    TextColor3 = rgb(255, 255, 255)
                                })
                            end)
                        end)
                    end
                }),
                instance('Frame', {
                    Size = udim2(0, 1, 1, -6),
                    Position = udim2(1, -24, 0, 3),
                    BackgroundColor3 = rgb(0, 0, 0),
                    BackgroundTransparency = 0.7,
                    BorderSizePixel = 0,
                })
            })
        })

        toggle = function(s)
            pcall(function()
                ts(body.Frame.toggle, {0.3, 'Exponential'}, {
                    BackgroundTransparency = s and 0.5 or 0.9
                })
                ts(body.Frame.toggle.Frame, {0.3, 'Exponential'}, {
                    Size = s and udim2(0, 0, 0, 0) or udim2(1, -4, 1, -4),
                    Position = s and udim2(0.5, 0, 0.5, 0) or udim2(0, 2, 0, 2),
                    BackgroundColor3 = s and rgb(255, 255, 255) or rgb(0, 0, 0),
                    BackgroundTransparency = s and 1 or 0.7
                })
            end)
        end

        local tip = getgenv().tipMenu
        spawn(function()
            repeat
                wait()
                tip = getgenv().tipMenu
            until table.len(getgenv().tipMenu) == 3
        end)
        
        local toolTipActive = false
        if v2.tooltip then
            onHover(body.TextButton, 0.5, function()
                if checkPos(obj) then
                    toolTipActive = true
                    tipMenu.update(v2.text, v2.tooltip)
                    tipMenu.open()  
                end
            end, function()
                if toolTipActive then
                    tipMenu.update('', '')
                    tipMenu.close()
                end
            end)
        end

        if not v2.hold then
            game:service('UserInputService').InputBegan:Connect(function(k, t)
                if t then return end
                if k.KeyCode == v2.key then
                    toggled = not toggled
                    toggle(toggled)
                    v2.callback(toggled)
                end
            end)
        else
            game:service('UserInputService').InputBegan:Connect(function(k, t)
                if t then return end
                if k.KeyCode == v2.key then
                    toggled = true
                    toggle(true)
                    v2.callback(true)
                end
            end)
            game:service('UserInputService').InputEnded:Connect(function(k, t)
                if t then return end
                if k.KeyCode == v2.key then
                    toggled = false
                    toggle(false)
                    v2.callback(false)
                end
            end)
        end

        body.Parent = obj
    end,
    databox = function(v2, data, obj)
        v2.text = typeof(v2.text) == 'string' and v2.text or '[unnamed databox]'
        v2.options = typeof(v2.options) == 'table' and v2.options or {}
        v2.callback = typeof(v2.callback) == 'function' and v2.callback or function() end

        local size = 36 + (24 * table.len(v2.options))

        local tsize = (game:service('TextService'):GetTextSize(v2.text, 13, 'Gotham', Vector2.new(math.huge, math.huge))).X / 2

        local toggle, toggled = nil,false

        local body = instance('Frame', {
            Size = udim2(1, 0, 0, 30),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = rgb(0, 0, 0),
            ClipsDescendants = true,
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 6)
            }),
            instance('TextLabel', {
                Text = '...',
                Font = 'Gotham',
                TextSize = 14,
                Position = udim2(1, -25, 0, 0),
                Size = udim2(0, 20, 1, -7),
                BackgroundTransparency = 1,
                TextColor3 = rgb(255, 255, 255),
                Name = 'dots'
            }),
            instance('TextButton', {
                Size = udim2(1, 0, 0, 30),
                Text = v2.text,
                TextSize = 13,
                TextColor3 = rgb(255, 255, 255),
                Font = 'Gotham',
                BackgroundTransparency = 1,
                Name = 'button'
            }, {}, {
                function(self)
                    self.MouseButton1Down:Connect(function()
                        toggled = not toggled
                        toggle(toggled)
                    end)
                end
            }),
            instance('Frame', {
                Size = udim2(1, -12, 1, -36),
                Position = udim2(0, 6, 0, 30),
                BackgroundColor3 = rgb(0, 0, 0),
                BackgroundTransparency = 1,
                Name = 'cont'
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 4)
                }),
                instance('UIListLayout')
            })
        })

        local optionTable = {}
        for a,v in next, v2.options do
            optionTable[v[1]] = v[2]
        end

        local c = 0
        for a=1,table.len(v2.options) do
            local v = v2.options[a]

            c = c + 1
            local text, bool = typeof(v[1]) == 'string' and v[1] or tostring(v[2]), typeof(v[2]) == 'boolean' and v[2] or false

            local frame = instance('Frame', {
                Size = udim2(1, 0, 0, 24),
                BackgroundTransparency = 1,
            }, {
                instance('Frame', {
                    Size = udim2(0, 12, 0, 12),
                    Position = udim2(1, -18, 0, 6),
                    BackgroundTransparency = bool and 0.4 or 0.6,
                    BackgroundColor3 = bool and data.theme.accent or rgb(0, 0, 0)
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 4)
                    })
                }),
                instance('TextButton', {
                    Size = udim2(1, -7, 1, 0),
                    Position = udim2(0, 7, 0, 0),
                    BackgroundTransparency = 1,
                    TextSize = 11,
                    Font = 'Gotham',
                    TextColor3 = rgb(255, 255, 255),
                    TextXAlignment = 'Left',
                    Text = tostring(v[1])
                }, {}, {
                    function(self)
                        self.MouseButton1Down:Connect(function()
                            optionTable[text] = not optionTable[text]
                            ts(self.Parent.Frame, {0.3, 'Exponential'}, {
                                BackgroundColor3 = optionTable[text] and data.theme.accent or rgb(0, 0, 0),
                                BackgroundTransparency = optionTable[text] and 0.4 or 0.6
                            })
                            v2.callback(optionTable)
                        end)
                    end
                })
            })

            if c < table.len(v2.options) then
                instance('Frame', {
                    Parent = frame,
                    Size = udim2(1, -16, 0, 1),
                    Position = udim2(0, 8, 1, -1),
                    BackgroundTransparency = 0.5,
                    BackgroundColor3 = rgb(0, 0, 0),
                    BorderSizePixel = 0
                })
            end

            frame.Parent = body.cont
        end

        
        toggle = function(s)
            ts(body, {0.3, 'Exponential'}, {
                Size = udim2(1, 0, 0, s and size or 30),
                BackgroundColor3 = s and rgb(20, 20, 20) or rgb(0, 0, 0)
            })
            ts(body.dots, {0.3, 'Exponential'}, {
                TextTransparency = s and 1 or 0
            })

            if s then
                body.button.Position = udim2(0.5, -tsize, 0, 0)
                body.button.TextXAlignment = 'Left'
                body.button.Font = 'GothamSemibold'
                ts(body.button, {0.3, 'Exponential'}, {
                    Position = udim2(0, 12, 0, 0)
                })
            else
                ts(body.button, {0.3, 'Exponential'}, {
                    Position = udim2(0.5, -tsize, 0, 0),
                })
                delay(0.3, function()
                    body.button.Position = udim2(0, 0, 0, 0)
                    body.button.TextXAlignment = 'Center'
                    body.button.Font = 'Gotham'
                end)
            end


            if s then
                body.cont.Visible = true
            else
                delay(0.3, function()
                    body.cont.Visible = false
                end)
            end

            ts(body.cont, {0.3, 'Exponential'}, {
                BackgroundTransparency = s and 0.7 or 1
            })
        end

        local tip = getgenv().tipMenu
        spawn(function()
            repeat
                wait()
                tip = getgenv().tipMenu
            until table.len(getgenv().tipMenu) == 3
        end)
        
        local toolTipActive = false
        if v2.tooltip then
            onHover(body.button, 0.5, function()
                if checkPos(obj) then
                    toolTipActive = true
                    tipMenu.update(v2.text, v2.tooltip)
                    tipMenu.open()  
                end
            end, function()
                if toolTipActive then
                    tipMenu.update('', '')
                    tipMenu.close()
                end
            end)
        end

        body.Parent = obj
    end,
    slider = function(v2, data, obj)
        v2.text = typeof(v2.text) == 'string' and v2.text or '[slider name empty]'
        v2.callback = typeof(v2.callback) == 'function' and v2.callback or function() end
        v2.min = typeof(v2.min) == 'number' and v2.min or 0
        v2.max = typeof(v2.max) == 'number' and v2.max or 100
        v2.value = typeof(v2.value) == 'number' and v2.value > v2.min and v2.value or v2.min
        v2.float = typeof(v2.float) == 'number' and v2.float or 1
        v2.deg = typeof(v2.deg) == 'string' and v2.deg or ''
        v2.sens = typeof(v2.sens) == 'number' and v2.sens or 3.14
        local pressed = false

        local tsize = game:service('TextService'):GetTextSize(v2.text, 13, 'Gotham', Vector2.new(math.huge, math.huge)).X

        local toggle, toggled = nil, false
        local update

        local function measure(txt)
            local t = game:service('TextService'):GetTextSize(txt, 11, 'GothamBold', Vector2.new(math.huge, math.huge))
            return t.X
        end

        local body = instance('Frame', {
            Size = udim2(1, 0, 0, 30),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = rgb(0, 0, 0),
            ClipsDescendants = true,
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 6)
            }),
            instance('Frame', {
                Size = udim2(1, -(tsize + 28), 0, 6),
                Position = udim2(0, tsize + 18, 0.5, -3),
                BackgroundTransparency = 0.8,
                BackgroundColor3 = rgb(0, 0, 0),
                Name = 'slider'
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(1, 0),
                }),
                instance('Frame', {
                    BackgroundTransparency = 0.4,
                    BackgroundColor3 = data.theme.accent,
                    Size = udim2(scale(v2.value, 0, 1, v2.min, v2.max), 0, 1, 0)
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(1, 0)
                    })
                }),
                instance('TextLabel', {
                    Text = tostring(v2.value) .. tostring(v2.deg),
                    TextColor3 = rgb(255, 255, 255),
                    TextStrokeTransparency = 0.8,
                    Size = udim2(1, 0, 1, 0),
                    TextSize = 11,
                    BackgroundTransparency = 1,
                    TextTransparency = 1,
                    Font = 'GothamBold',
                    Name = 'deg'
                })
            }),
            instance('TextButton', {
                Size = udim2(1, -10, 1, 0),
                Position = udim2(0, 10, 0, 0),
                TextSize = 13,
                TextXAlignment = 'Left',
                BackgroundTransparency = 1,
                Font = 'Gotham',
                TextColor3 = rgb(255, 255, 255),
                Text = v2.text,
                Name = 'button'
            }, {}, {
                function(self)
                    local bind
                    self.MouseButton1Down:Connect(function()
                        if sliderUsing then
                            return
                        end
                        sliderUsing = true
                        pressed = true
                        toggled = not toggled
                        toggle(toggled)
                        local val, mx = v2.value, mouse.X

                        bind = game:service('RunService').Stepped:Connect(function()
                            update(mx, val)
                        end)
                    end)
                    local function d()
                        pcall(function()
                            bind:Disconnect() 
                        end)
                        if pressed then
                            pressed = false
                            toggled = not toggled 
                            toggle(toggled) 
                        end
                    end
                    mouse.Button1Up:Connect(d)
                    self.MouseButton1Up:Connect(d)
                end
            })
        })

        toggle = function(s)
            if not s then 
                sliderUsing = false
            end
            ts(body.button, {0.3, 'Exponential'}, {
                TextTransparency = s and 1 or 0,
                Size = s and udim2(1, 10, 1, 0) or udim2(1, -10, 1, 0),
                Position = s and udim2(0, -10, 0, 0) or udim2(0, 10, 0, 0)
            })
            ts(body.slider, {0.3, 'Exponential'}, {
                Size = s and udim2(1, -12, 1, -12) or udim2(1, -(tsize + 28), 0, 6),
                Position = s and udim2(0, 6, 0, 6) or udim2(0, tsize + 18, 0.5, -3),
            })
            ts(body.slider.UICorner, {0.3, 'Exponential'}, {
                CornerRadius = s and UDim.new(0, 4) or UDim.new(1, 0)
            })
            ts(body.slider.Frame.UICorner, {0.3, 'Exponential'}, {
                CornerRadius = s and UDim.new(0, 3) or UDim.new(1, 0)
            })
            ts(body.slider.deg, {0.3, 'Exponential'}, {
                TextTransparency = s and 0 or 1,
                TextStrokeTransparency = s and 0.8 or 1
            })
        end

        update = function(mx, value)
            local nmx = (mouse.X - mx) / v2.sens
            local sv = scale(value, 0, 1, v2.min, v2.max)
            sv = sv + (nmx * 0.01)
            local sz = sv >= 1 and 1 or sv <= 0 and 0 or sv
            sv = scale(sv, v2.min, v2.max, 0, 1)
            if sv <= v2.min then
                sv = v2.min
            end
            if sv >= v2.max then
                sv = v2.max
            end

            sv = round(sv, v2.float)

            v2.value = sv
            v2.callback(sv)

            body.slider.deg.Text = tostring(round(sv, v2.float)) .. tostring(v2.deg)

            ts(body.slider.Frame, {0.3, 'Exponential'}, {
                Size = udim2(sz, 0, 1, 0)
            })
        end

        local tip = getgenv().tipMenu
        spawn(function()
            repeat
                wait()
                tip = getgenv().tipMenu
            until table.len(getgenv().tipMenu) == 3
        end)
        
        local toolTipActive = false
        if v2.tooltip then
            onHover(body.button, 0.5, function()
                if checkPos(obj) then
                    toolTipActive = true
                    tipMenu.update(v2.text, v2.tooltip)
                    tipMenu.open()  
                end
            end, function()
                if toolTipActive then
                    tipMenu.update('', '')
                    tipMenu.close()
                end
            end)
        end

        body.Parent = obj
    end,
    textbox = function(v2, data, obj)
        v2.text = typeof(v2.text) == 'string' and v2.text or '[empty textbox name]'
        v2.placeholder = typeof(v2.placeholder) == 'string' and v2.placeholder or 'insert text here'
        v2.callback = typeof(v2.callback) == 'function' and v2.callback or function() end
        v2.fillFunction = typeof(v2.fillFunction) == 'function' and v2.fillFunction or nil

        if v2.clear ~= false then
            if v2.clear == nil then
                v2.clear = true
            end
        end

        local function ms(a)
            return game:service('TextService'):GetTextSize(a, 11, 'Gotham', Vector2.new(math.huge, math.huge))
        end

        local ps = ms(v2.placeholder)
        ps = ps.X

        local toggle, toggled = nil, false
        local matchFound

        local body = instance('Frame', {
            Size = udim2(1, 0, 0, 30),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = rgb(0, 0, 0),
            ClipsDescendants = true,
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 6)
            }),
            instance('Frame', {
                Size = udim2(0, ps + 10, 0, 20),
                Position = udim2(1, -(ps + 15), 0.5, -10),
                BackgroundTransparency = 0.7,
                BackgroundColor3 = rgb(0, 0, 0),
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 4)
                }),
                instance('TextBox', {
                    BackgroundTransparency = 1,
                    Size = udim2(1, 0, 1, 0),
                    PlaceholderText = v2.placeholder,
                    Font = 'Gotham',
                    TextSize = 11,
                    TextColor3 = rgb(255, 255, 255),
                    Text = '',
                    ClipsDescendants = true,
                    ClearTextOnFocus = v2.clear
                }, {
                    instance('TextLabel', {
                        TextColor3 = rgb(255, 255, 255),
                        TextTransparency = 0.7,
                        Text = '',
                        Size = udim2(1, 0, 1, 0),
                        TextSize = 13,
                        Name = 'fill',
                        BackgroundTransparency = 1,
                        Font = 'Gotham',
                        TextXAlignment = 'Left',
                    })
                }, {
                    function(self)
                        self.FocusLost:Connect(function(enterPressed)
                            toggled = not toggled
                            toggle(toggled)
                            if not matchFound then
                                v2.callback(self.Text)
                            else
                                v2.callback(matchFound)
                            end
                            if v2.clear then 
                                self.Text = ''
                            else
                                if matchFound then
                                    self.Text = matchFound
                                end
                            end
                        end) 
                    end,
                    function(self)
                        self:GetPropertyChangedSignal('Text'):Connect(function()
                            if v2.fillFunction ~= nil then
                                local tb = v2.fillFunction()
                                local match = ''
                                if self.Text:gsub(' ', '') ~= '' then
                                    for a,v in next, tb do
                                        if v:sub(1, #self.Text) == self.Text:sub(1, #self.Text) then
                                            match = v
                                            matchFound = v
                                        end
                                    end
                                end
                                self.fill.Text = match
                            end
                        end)
                    end
                })
            }),
            instance('TextButton', {
                Size = udim2(1, -10, 1, 0),
                Position = udim2(0, 10, 0, 0),
                TextColor3 = rgb(255, 255, 255),
                BackgroundTransparency = 1,
                Font = 'Gotham',
                TextSize = 13, 
                Text = v2.text,
                TextXAlignment = 'Left'
            }, {}, {
                function(self)
                    self.MouseButton1Down:Connect(function()
                        toggled = not toggled
                        toggle(toggled)
                        self.Parent.Frame.TextBox:CaptureFocus()
                    end)
                end
            })
        })

        toggle = function(s)
            delay(0.02, function()
                ts(body.TextButton, {0.3, 'Exponential'}, {
                    Position = s and udim2(0, -50, 0, 0) or udim2(0, 10, 0, 0),
                    TextTransparency = s and 1 or 0
                })
            end)
            if not v2.clear and body.Frame.TextBox.Text:gsub(' ', '') ~= '' then
                if matchFound then
                    ps = ms(matchFound).X
                else
                    if body.Frame.TextBox.Text == '' then
                        ps = ms(v2.placeholder).X
                    else
                        ps = ms(body.Frame.TextBox.Text).X
                    end
                end
            else
                delay(0.2, function()
                    body.Frame.TextBox.Text = ''
                    ps = ms(v2.placeholder).X
                end)
            end
            ts(body.Frame, {0.3, 'Exponential'}, {
                Position = s and udim2(0, 4, 0, 4) or udim2(1, -(ps + 15), 0.5, -10),
                Size = s and udim2(1, -8, 1, -8) or udim2(0, ps + 10, 0, 20)
            })
            ts(body.Frame.TextBox, {0.15, 'Exponential'}, {
                TextTransparency = 1
            })
            delay(0.15, function()
                body.Frame.TextBox.TextSize = s and 13 or 11
                body.Frame.TextBox.TextXAlignment = s and 'Left' or 'Center'
                body.Frame.TextBox.Position = s and udim2(0, 6, 0, 0) or udim2(0, 0, 0, 0)
                body.Frame.TextBox.Size = s and udim2(1, -6, 1, 0) or udim2(1, 0, 1, 0)
                --body.Frame.TextBox.fill.Text = s and '' or body.Frame.fill.Text
                ts(body.Frame.TextBox, {0.15, 'Exponential'}, {
                    TextTransparency = 0
                })
                ts(body.Frame.TextBox.fill, {0.15, 'Exponential'}, {
                    TextTransparency = s and 0.7 or 1
                })
                delay(0.1, function()
                    matchFound = nil
                end)
            end)
        end

        local tip = getgenv().tipMenu
        spawn(function()
            repeat
                wait()
                tip = getgenv().tipMenu
            until table.len(getgenv().tipMenu) == 3
        end)
        
        local toolTipActive = false
        if v2.tooltip then
            onHover(body.TextButton, 0.5, function()
                if checkPos(obj) then
                    toolTipActive = true
                    tipMenu.update(v2.text, v2.tooltip)
                    tipMenu.open()  
                end
            end, function()
                if toolTipActive then
                    tipMenu.update('', '')
                    tipMenu.close()
                end
            end)
        end

        body.Parent = obj
    end,
    colorpicker = function(v2, data, obj)
        v2.text = typeof(v2.text) == 'string' and v2.text or '[empty colorpicker name]'
        v2.color = typeof(v2.color) == 'Color3' and v2.color or typeof(v2.color) == 'table' and Color3.fromRGB(v2.color[1], v2.color[2], v2.color[3]) or Color3.new(1, 1, 1)
        v2.callback = typeof(v2.callback) == 'function' and v2.callback or function() end

        local H, S, V = v2.color:ToHSV()

        local toggle,toggled,colorToggled = nil, false, false
        local textsize = game:service('TextService'):GetTextSize(v2.text, 13, 'Gotham', Vector2.new(math.huge, math.huge)).X

        local colorMain

        local body = instance('Frame', {
            Size = udim2(1, 0, 0, 30),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = rgb(0, 0, 0),
            ClipsDescendants = true,
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 6)
            }),
            instance('TextButton', {
                Position = udim2(0, 10, 0, 0),
                Size = udim2(1, -10, 1, 0),
                BackgroundTransparency = 1,
                Font = 'Gotham',
                TextSize = 13,
                TextColor3 = rgb(255, 255, 255),
                Text = v2.text,
                TextXAlignment = 'Left'
            }, {}, {
                function(self)
                    self.MouseButton1Down:Connect(function()
                        toggled = not toggled
                        toggle(toggled)
                    end)
                end
            }),
            instance('Frame', {
                Position = udim2(1, -95, 0.5, -10),
                Size = udim2(0, 90, 0, 20),
                BackgroundColor3 = v2.color
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 4)
                }),
                instance('UIGradient', {
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.2, 1),
                        NumberSequenceKeypoint.new(1, 0.5)
                    })
                })
            })
        })

        local rainbow = false
        local csk = ColorSequenceKeypoint.new

        colorMain = instance('Frame', {
            Parent = sgui,
            Size = udim2(0, 0, 0, 208),
            BackgroundColor3 = rgb(30, 30, 30),
            BackgroundTransparency = 0.3,
            Visible = false,
            Position = udim2(0, body.AbsolutePosition.X + body.AbsoluteSize.X + 20, 0, body.AbsolutePosition.Y + 10),
            BorderSizePixel = 0,
            ClipsDescendants = true
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 10),
            }),
            instance('Frame', {
                Position = udim2(0, 12, 0, 12),
                Size = udim2(1, -24, 1, -24),
                BackgroundTransparency = 1,
                Name = 'blur'
            }, {}, {
                function(self)
                    delay(0.5, function()
                        blurModule:BindFrame(self, {
                            Transparency = 0.999,
                            Material = 'Glass',
                            Color = rgb(255, 255, 255)
                        })
                    end)
                end
            }),
            instance('Frame', { --box1
                Size = udim2(0, 138, 0, 138),
                Position = udim2(0, 6, 0, 6),
                BackgroundColor3 = rgb(255, 255, 255),
                Name = 'hueBox'
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 6),
                }),
                instance('UIGradient', {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(H, 1, 1))
                    })
                })
            }),
            instance('Frame', { --box2
                Size = udim2(0, 138, 0, 138),
                Position = udim2(0, 6, 0, 6),
                BackgroundColor3 = rgb(0, 0, 0),
                Name = 'box'
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 6)
                }),
                instance('UIGradient', {
                    Rotation = 90,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.45, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    })
                }),
                instance('Frame', {
                    Size = udim2(0, 8, 0, 8),
                    BackgroundColor3 = rgb(0, 0, 0),
                    Position = udim2(V, -4, scale(S, 0, 1, 1, 0), -4)
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(1, 0),
                    }),
                    instance('Frame', {
                        Size = udim2(1, -4, 1, -4),
                        Position = udim2(0, 2, 0, 2),
                        BackgroundColor3 = rgb(255, 255, 255)
                    }, {
                        instance('UICorner', {
                            CornerRadius = UDim.new(1, 0)
                        })
                    })
                })
            }),
            instance('Frame', { --hue
                Name = 'hue',
                Position = udim2(0, 150, 0, 6),
                Size = udim2(0, 30, 0, 138),
                BackgroundColor3 = rgb(255, 255, 255)
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 6)
                }),
                instance('UIGradient', {
                    Rotation = 90,
                    Color = ColorSequence.new({
                        csk(0, rgb(255, 0, 0)),
                        csk(0.125, rgb(255, 191, 0)),
                        csk(0.250, rgb(128, 255, 0)),
                        csk(0.315, rgb(0, 255, 65)),
                        csk(0.45, rgb(59, 255, 255)),
                        csk(0.625, rgb(0, 64, 255)),
                        csk(0.715, rgb(128, 0, 255)),
                        csk(0.875, rgb(255, 0, 191)),
                        csk(1, rgb(255, 0, 0))
                    })
                }),
                instance('Frame', {
                    Size = udim2(1, -4, 0, 6),
                    Position = udim2(0, 2, H, -3),
                    BackgroundTransparency = 0.3,
                    BackgroundColor3 = rgb(0, 0, 0),
                    Name = 'bar'
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(1, 0)
                    }),
                    instance('Frame', {
                        Size = udim2(1, -4, 1, -4),
                        Position = udim2(0, 2, 0, 2),
                        BackgroundColor3 = rgb(255, 255, 255),
                    }, {
                        instance('UICorner', {
                            CornerRadius = UDim.new(1, 0)
                        })
                    })
                })
            }),
            instance('Frame', { --saturation
                Name = 'sat',
                Position = udim2(0, 186, 0, 6),
                Size = udim2(0, 30, 0, 138),
                BackgroundColor3 = rgb(255, 255, 255)   
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 6)
                }),
                instance('UIGradient', {
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(H, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                    })
                }),
                instance('Frame', {
                    Name = 'bar',
                    Size = udim2(1, -4, 0, 6),
                    Position = udim2(0, 2, S, -3),
                    BackgroundTransparency = 0.3,
                    BackgroundColor3 = rgb(0, 0, 0)
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(1, 0)
                    }),
                    instance('Frame', {
                        Size = udim2(1, -4, 1, -4),
                        Position = udim2(0, 2, 0, 2),
                        BackgroundColor3 = rgb(255, 255, 255),
                    }, {
                        instance('UICorner', {
                            CornerRadius = UDim.new(0, 1)
                        })
                    })
                })
            }),
            instance('Frame', { --value
                Name = 'val',
                Position = udim2(0, 222, 0, 6),
                Size = udim2(0, 30, 0, 138),
                BackgroundColor3 = rgb(255, 255, 255)
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 6)
                }),
                instance('UIGradient', {
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(H, 1, 1)),
                        ColorSequenceKeypoint.new(1, rgb(0, 0, 0))
                    })
                }),
                instance('Frame', {
                    Name = 'bar',
                    Size = udim2(1, -4, 0, 6),
                    Position = udim2(0, 2, S, -3),
                    BackgroundTransparency = 0.3,
                    BackgroundColor3 = rgb(0, 0, 0)
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(1, 0)
                    }),
                    instance('Frame', {
                        Size = udim2(1, -4, 1, -4),
                        Position = udim2(0, 2, 0, 2),
                        BackgroundColor3 = rgb(255, 255, 255),
                    }, {
                        instance('UICorner', {
                            CornerRadius = UDim.new(0, 1)
                        })
                    })
                })
            }),
            instance('Frame', { --apply
                Size = udim2(1, -12, 0, 30),
                Position = udim2(0, 6, 1, -36),
                BackgroundTransparency = 0.1,
                BackgroundColor3 = rgb(100, 200, 100)
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 6),
                }),
                instance('Frame', {
                    Size = udim2(1, -4, 1, -4),
                    Position = udim2(0, 2, 0, 2),
                    BackgroundColor3 = rgb(30, 40, 30),
                    BackgroundTransparency = 0.1
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    instance('TextButton', {
                        Size = udim2(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Font = 'GothamBold',
                        TextSize = 14,
                        TextColor3 = rgb(235, 255, 235),
                        Text = 'APPLY'
                    }, {}, {
                        function(self)
                            self.MouseButton1Down:Connect(function()
                                v2.callback(Color3.fromHSV(H, S, V))
                                toggle(false)
                                toggled = false
                                ts(body.Frame, {0.3, 'Exponential'}, {
                                    BackgroundColor3 = Color3.fromHSV(H, S, V)
                                })
                            end)
                        end
                    })
                })
            }),
            instance('Frame', {
                Size = udim2(0, 14, 0, 14),
                Position = udim2(0, 10, 1, -57),
                BackgroundTransparency = 0.7, 
                BackgroundColor3 = rgb(200, 200, 200),
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 4)
                }),
                instance('Frame', {
                    Size = udim2(1, -4, 1, -4),
                    Position = udim2(0, 2, 0, 2),
                    BackgroundTransparency = 0.6,
                    BackgroundColor3 = rgb(200, 200, 200)
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 3)
                    })
                }),
                instance('TextLabel', {
                    Position = udim2(1, 6, 0, 0),
                    Size = udim2(0, 50, 1, 0),
                    BackgroundTransparency = 1,
                    Text = 'Rainbow',
                    Font = 'Gotham',
                    TextSize = 12,
                    TextColor3 = rgb(255, 255, 255)
                }),
                instance('TextButton', {
                    Size = udim2(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = ''
                }, {}, {
                    function(self)
                        local toggled = false
                        self.MouseButton1Down:Connect(function()
                            toggled = not toggled
                            if toggled then
                                ts(self.Parent, {0.3, 'Exponential'}, {
                                    BackgroundColor3 = rgb(200, 255, 200),
                                    BackgroundTransparency = 0.4
                                })
                                ts(self.Parent.Frame, {0.3, 'Exponential'}, {
                                    BackgroundColor3 = rgb(200, 255, 200),
                                    BackgroundTransparency = 0.3
                                })
                                rainbow = true
                            else
                                ts(self.Parent, {0.3, 'Exponential'}, {
                                    BackgroundColor3 = rgb(200, 200, 200),
                                    BackgroundTransparency = 0.7
                                })
                                ts(self.Parent.Frame, {0.3, 'Exponential'}, {
                                    BackgroundColor3 = rgb(200, 200, 200),
                                    BackgroundTransparency = 0.6
                                })
                                rainbow = false
                            end
                        end)
                    end
                })
            })
        })

        spawn(function()
            while true do
                task.wait()
                if rainbow then
                    for a=0,1,0.001*data.theme.rainbowSpeed do
                        wait()
                        if not rainbow then
                            break
                        end
                        H = a
                        v2.callback(H, S, V)
                        ts(body.Frame, {0.3, 'Exponential'}, {
                            BackgroundColor3 = Color3.fromHSV(H, S, V)
                        })

                        ts(colorMain.hue.bar, {0.2, 'Exponential'}, {
                            Position = udim2(0, 2, H, -3)
                        })
                        colorMain.hueBox.UIGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(H, 1, 1))
                        })
                        colorMain.sat.UIGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromHSV(H, 1, 1)),
                            ColorSequenceKeypoint.new(1, rgb(255, 255, 255))
                        })
                        colorMain.val.UIGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromHSV(H, 1, 1)),
                            ColorSequenceKeypoint.new(1, rgb(0, 0, 0))
                        })
                    end
                end
            end
        end)

        local boxBind, boxConnected = nil, false
        local hueBind, hueConnected = nil, false
        local satBind, satConnected = nil, false
        local valBind, valConnected = nil, false

        local function initBox()
            boxConnected = true
            boxBind = game:service('RunService').Stepped:connect(function()
                if not checkPos(colorMain.box) then
                    boxBind:Disconnect()
                    dragConnection:reconnect()
                    boxConnected = false
                    return
                end

                local rel = getRel(colorMain.box)

                local v = scale(rel.Y, 0, 1, 0, 138)
                local s = scale(rel.X, 0, 1, 0, 138)

                ts(colorMain.box.Frame, {0.2, 'Exponential'}, {
                    Position = udim2(s, -4, v, -4)
                })
                ts(colorMain.sat.bar, {0.2, 'Exponential'}, {
                    Position = udim2(0, 2, scale(s, 0, 1, 1, 0), -3)
                })
                ts(colorMain.val.bar, {0.2, 'Exponential'}, {
                    Position = udim2(0, 2, v, -3)
                })
                colorMain.val.UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(H, s, 1)),
                    ColorSequenceKeypoint.new(1, rgb(0, 0, 0))
                })
                ts(colorMain.sat, {0.2, 'Exponential'}, {
                    BackgroundColor3 = Color3.fromHSV(0, 0, scale(v, 0, 1, 1, 0))
                })

                v = scale(v, 0, 1, 1, 0)
                
                V = v
                S = s 
            end)
        end
        local function initHue()
            hueConnected = true
            hueBind = game:service('RunService').Stepped:connect(function()
                if not checkPos(colorMain.hue) then
                    hueBind:Disconnect()
                    dragConnection.reconnect()
                    hueConnected = false
                    return
                end

                local rel = getRel(colorMain.hue)

                local h = scale(rel.Y, 0, 1, 0, 138)

                ts(colorMain.hue.bar, {0.2, 'Exponential'}, {
                    Position = udim2(0, 2, h, -3)
                })
                colorMain.hueBox.UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))
                })
                colorMain.sat.UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
                    ColorSequenceKeypoint.new(1, rgb(255, 255, 255))
                })
                colorMain.val.UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
                    ColorSequenceKeypoint.new(1, rgb(0, 0, 0))
                })

                H = h
            end)
        end
        local function initSat()
            satConnected = true
            satBind = game:service('RunService').Stepped:connect(function()
                if not checkPos(colorMain.sat) then
                    satBind:Disconnect()
                    dragConnection.reconnect()
                    satConnected = false
                    return
                end

                local rel = getRel(colorMain.sat)

                local s = scale(rel.Y, 0, 1, 0, 138)

                ts(colorMain.sat.bar, {0.2, 'Exponential'}, {
                    Position = udim2(0, 2, s, -3)
                })
                ts(colorMain.box.Frame, {0.2, 'Exponential'}, {
                    Position = udim2(scale(s, 0, 1, 1, 0), -4, scale(V, 0, 1, 1, 0), -4)
                })
                colorMain.val.UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(H, scale(s, 0, 1, 1, 0), 1)),
                    ColorSequenceKeypoint.new(1, rgb(0, 0, 0))
                })

                S = scale(s, 0, 1, 1, 0)
            end)
        end
        local function initVal()
            valConnected = true
            valBind = game:service('RunService').Stepped:connect(function()
                if not checkPos(colorMain.val) then
                    valBind:Disconnect()
                    dragConnection.reconnect()
                    valConnected = false
                    return
                end

                local rel = getRel(colorMain.val)

                local v = scale(rel.Y, 0, 1, 0, 138)

                ts(colorMain.val.bar, {0.2, 'Exponential'}, {
                    Position = udim2(0, 2, v, -3)
                })
                ts(colorMain.box.Frame, {0.2, 'Exponential'}, {
                    Position = udim2(S, -4, v, -4)
                })
                ts(colorMain.sat, {0.2, 'Exponential'}, {
                    BackgroundColor3 = Color3.fromHSV(0, 0, scale(v, 0, 1, 1, 0))
                })

                V = scale(v, 0, 1, 1, 0)
            end)
        end


        bindToMouse(function()
            if toggled then
                if checkPos(colorMain.box) then
                    initBox()
                elseif checkPos(colorMain.hue) then
                    initHue()
                elseif checkPos(colorMain.sat) then
                    initSat()
                elseif checkPos(colorMain.val) then
                    initVal()
                end
            end
        end)
        bindToMoueUp(function()
            if boxConnected then
                boxBind:Disconnect()
            end
            if hueConnected then
                hueBind:Disconnect()
            end
            if satConnected then
                satBind:Disconnect()
            end
            if valConnected then
                valBind:Disconnect()
            end
        end)

        toggle = function(s)
            if s then
                spawn(function()
                    repeat
                        wait()
                        ts(colorMain, {0.2, 'Exponential'}, {
                            Position = udim2(0, body.AbsolutePosition.X + body.AbsoluteSize.X + 20, 0, body.AbsolutePosition.Y)
                        })
                    until not toggled
                end)
                delay(0.31, function()
                    body.TextButton.Position = udim2(0, 0, 0, 0)
                    body.TextButton.TextXAlignment = 'Right' 
                end)
                ts(body.TextButton, {0.3, 'Exponential'}, {
                    Position = udim2(1, -(textsize + 13), 0, 0),
                })
                ts(body.Frame, {0.3, 'Exponential'}, {
                    BackgroundTransparency = 1
                })
                body.TextButton.Font = 'GothamBold'
                colorMain.Position = udim2(0, body.AbsolutePosition.X + body.AbsoluteSize.X + 20, 0, body.AbsolutePosition.Y)

                colorToggled = true
                ts(colorMain, {0.45, 'Exponential'}, {
                    Size = udim2(0, 258, 0, 208)
                })
                colorMain.Visible = true
            else
                ts(body.TextButton, {0.3, 'Exponential'}, {
                    Position = udim2(-1, textsize + 20, 0, 0),
                })
                ts(body.Frame, {0.3, 'Exponential'}, {
                    BackgroundTransparency = 0
                })
                delay(0.31, function()
                    body.TextButton.Position = udim2(0, 10, 0, 0)
                    body.TextButton.TextXAlignment = 'Left'
                end)
                body.TextButton.Font = 'Gotham'
                if colorToggled == true then
                    colorToggled = false
                    ts(colorMain, {0.45, 'Exponential'}, {
                        Size = udim2(0, 0, 0, 208)
                    })
                    delay(0.45, function()
                        colorMain.Position = udim2(-1, 0, -1, 0)
                    end)
                end
            end
        end

        local tip = getgenv().tipMenu
        spawn(function()
            repeat
                wait()
                tip = getgenv().tipMenu
            until table.len(getgenv().tipMenu) == 3
        end)
        
        local toolTipActive = false
        if v2.tooltip then
            onHover(body.TextButton, 0.5, function()
                if checkPos(obj) then
                    toolTipActive = true
                    tipMenu.update(v2.text, v2.tooltip)
                    tipMenu.open()  
                end
            end, function()
                if toolTipActive then
                    tipMenu.update('', '')
                    tipMenu.close()
                end
            end)
        end

        body.Parent = obj
    end,
    dropdown = function(v2, data, obj)
        v2.text = typeof(v2.text) == 'string' and v2.text or '[dropdown name empty]'
        v2.options = typeof(v2.options) and v2.options or {}
        v2.def = (typeof(v2.def) == 'string' and table.find(v2.options, v2.def)) and tostring(v2.def) or 'unset'
        v2.callback = typeof(v2.callback) == 'function' and v2.callback or function() end
        v2.updTable = typeof(v2.updTable) == 'table' and v2.updTable or nil

        local ts1 = game:service('TextService'):GetTextSize(v2.def, 11, 'Gotham', Vector2.new(math.huge, math.huge)).X

        local toggle, toggled = nil, false
        local option = v2.def
        
        local dropMain = instance('Frame', {
            Size = udim2(0, 200, 0, 0),
            BackgroundColor3 = data.theme.accent,
            BackgroundTransparency = 0.8,
            Parent = sgui,
            ClipsDescendants = true
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 6)
            }),
            instance('Frame', {
                Position = udim2(0, 12, 0, 12),
                Size = udim2(1, -24, 1, -24),
                BackgroundTransparency = 1,
                Name = 'blur'
            }, {}, {
                function(self)
                    delay(0.5, function()
                        blurModule:BindFrame(self, {
                            Transparency = 0.999,
                            Material = 'Glass',
                            Color = rgb(255, 255, 255)
                        })
                    end)
                end
            }),
            instance('Frame', {
                Size = udim2(1, -12, 1, -12),
                Position = udim2(0, 6, 0, 6),
                BackgroundColor3 = rgb(0, 0, 0),
                BackgroundTransparency = 0.4
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 4)
                }),
                instance('UIListLayout', {
                    Padding = UDim.new(0, 6)
                }),
                instance('Frame', {
                    BackgroundTransparency = 1,
                    Size = udim2(0, 0, 0, 0),
                    Name = 'size_fix_cap0x'
                })
            })
        })

        local function setOption(op)
            option = op
            v2.def = op
            v2.callback(op)
            for a,v4 in next, dropMain.Frame:GetChildren() do
                pcall(function()
                    if v4.TextButton.Text ~= op then
                        ts(v4, {0.3, 'Exponential'}, {
                            BackgroundTransparency = 1
                        })
                        ts(v4.Frame, {0.3, 'Exponential'}, {
                            BackgroundTransparency = 1
                        })
                        ts(v4.TextButton, {0.3, 'Exponential'}, {
                            Position = udim2(0, 10, 0, 0),
                            Size = udim2(1, -10, 1, 0),
                            TextColor3 = rgb(200, 200, 200)
                        })
                        v4.TextButton.Font = 'Gotham'
                    else
                        ts(v4, {0.3, 'Exponential'}, {
                            BackgroundTransparency = 0
                        })
                        ts(v4.Frame, {0.3, 'Exponential'}, {
                            BackgroundTransparency = 0
                        })
                        ts(v4.TextButton, {0.3, 'Exponential'}, {
                            Position = udim2(0, 16, 0, 0),
                            Size = udim2(1, -16, 1, 0),
                            TextColor3 = rgb(255, 255, 255)
                        })
                        v4.TextButton.Font = 'GothamMedium'
                    end
                end)
            end
        end

        local function refreshOptions()
            for a2,v4 in next, dropMain.Frame:GetChildren() do
                if v4:IsA('Frame') then
                    v4:Destroy()
                end
            end

            instance('Frame', {
                Parent = dropMain.Frame,
                Size = udim2(0, 0, 0, 0),
                BackgroundTransparency = 1,
            })

            for a,v3 in next, v2.options do
                local new = instance('Frame', {
                    Size = udim2(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                }, {
                    instance('UIGradient', {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, data.theme.accent),
                            ColorSequenceKeypoint.new(1, rgb(0, 0, 0))
                        }),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.625),
                            NumberSequenceKeypoint.new(0.1, 0.8),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                    }),
                    instance('Frame', {
                        Size = udim2(0, 2, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        BackgroundColor3 = rgb(255, 255, 255)
                    }),
                    instance('TextButton', {
                        Text = v3,
                        TextSize = 13,
                        Font = 'Gotham',
                        TextColor3 = rgb(200, 200, 200),
                        Position = udim2(0, 10, 0, 0),
                        Size = udim2(1, -10, 1, 0),
                        BackgroundTransparency = 1,
                        TextXAlignment = 'Left'
                    }, {}, {
                        function(self)
                            self.MouseButton1Down:Connect(function()
                                setOption(v3)
                            end)
                        end
                    })
                })

                if v3 == v2.def then
                    new.BackgroundTransparency = 0
                    new.Frame.BackgroundTransparency = 0
                    new.TextButton.TextColor3 = rgb(255, 255, 255)
                    new.TextButton.Font = 'GothamMedium'
                    new.TextButton.Position = udim2(0, 16, 0, 0)
                    new.TextButton.Size = udim2(1, -16, 1, 0)
                end

                new.Parent = dropMain.Frame
            end
        end
        refreshOptions()

        local body = instance('Frame', {
            Size = udim2(1, 0, 0, 30),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = rgb(0, 0, 0),
        }, {
            instance('TextButton', {
                Position = udim2(0, 10, 0, 0),
                Size = udim2(1, -10, 1, 0),
                BackgroundTransparency = 1,
                Text = v2.text,
                Font = 'Gotham',
                TextSize = 13,
                TextColor3 = rgb(255, 255, 255),
                TextXAlignment = 'Left',
            }, {}, {
                function(self)
                    self.MouseButton1Down:Connect(function()
                        toggled = not toggled
                        toggle(toggled)
                    end)
                end
            }),
            instance('UICorner', {
                CornerRadius = UDim.new(0, 6)
            }),
            instance('Frame', {
                Position = udim2(1, -(ts1 + 18), 0.5, -10),
                Size = udim2(0, ts1 + 12, 0, 20),
                BackgroundColor3 = rgb(0, 0, 0),
                BackgroundTransparency = 0.7
            }, {
                instance('TextLabel', {
                    Text = v2.def,
                    Font = 'Gotham',
                    TextSize = 11,
                    TextColor3 = rgb(255, 255, 255),
                    BackgroundTransparency = 1,
                    Size = udim2(1, 0, 1, 0)
                }),
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 4)
                })
            })
        })

        if v2.updTable then
            v2.updTable[v2.text] = function(newOptions)
                v2.options = newOptions

                if not table.find(newOptions, v2.def) then
                    v2.def = 'unset'
                    option = 'unset'
                end

                local ts2 = game:service('TextService'):GetTextSize(option, 11, 'Gotham', Vector2.new(math.huge, math.huge)).X
                body.Frame.TextLabel.Text = option
                ts(body.Frame, {0.2, 'Exponential'}, {
                    Position = udim2(1, -(ts2 + 18), 0.5, -10),
                    Size = udim2(0, ts2 + 12, 0, 20),
                    BackgroundColor3 = rgb(0, 0, 0),
                    BackgroundTransparency = 0.7
                })
                ts(body.Frame.UICorner, {0.2, 'Exponential'}, {
                    CornerRadius = UDim.new(0, 4)
                })

                refreshOptions()
            end
        end

        bindToMouse(function()
            if not checkPos(body) and toggled == true then
                toggle(false)
            end
        end)

        toggle = function(s)
            if s then
                dropMain.Visible = true
                dropMain.Position = udim2(0, body.AbsolutePosition.X + obj.AbsoluteSize.X + 20, 0, body.AbsolutePosition.Y)
                ts(dropMain, {0.3, 'Exponential'}, {
                    Size = udim2(0, 200, 0, 18 + (table.len(v2.options) * 26))
                })
                ts(body.Frame.TextLabel, {0.2, 'Exponential'}, {
                    TextTransparency = 1,
                    TextColor3 = rgb(0, 0, 0)
                })
                delay(0.2, function()
                    body.Frame.TextLabel.Text = '.'
                    ts(body.Frame.TextLabel, {0.35, 'Exponential'}, {
                        TextTransparency = 0
                    })
                end)
                spawn(function()
                    repeat
                        wait()
                        ts(body.Frame.TextLabel, {0.05, 'Linear'}, {
                            Rotation = body.Frame.TextLabel.Rotation + 40
                        })
                        ts(dropMain, {0.3, 'Exponential'}, {
                            Position = udim2(0, body.AbsolutePosition.X + obj.AbsoluteSize.X + 20, 0, body.AbsolutePosition.Y)
                        })
                    until toggled == false
                    ts(body.Frame.TextLabel, {0.2, 'Exponential'}, {
                        Rotation = 0
                    })
                    local abs = dropMain.AbsoluteSize.Y
                    local abp = dropMain.AbsolutePosition
                    ts(dropMain, {0.3, 'Exponential'}, {
                        Size = udim2(0, 200, 0, 0),
                        Position = udim2(0, abp.X, 0, abp.Y + abs + 40)
                    })
                    delay(0.32, function()
                        print(dropMain.AbsolutePosition)
                        dropMain.Position = udim2(-1, 0, -1, 0)
                        print(dropMain.AbsolutePosition)
                    end)
                    -- delay(0.3, function()
                    --     dropMain.Visible = false
                    -- end)
                end)
                ts(body.Frame, {0.2, 'Exponential'}, {
                    Size = udim2(0, 20, 0, 20),
                    Position = udim2(1, -26, 0.5, -10),
                    BackgroundColor3 = rgb(255, 255, 255),
                    BackgroundTransparency = 0.4
                })
                ts(body.Frame.UICorner, {0.2, 'Exponential'}, {
                    CornerRadius = UDim.new(1, 0)
                })
            else
                toggled = false
                ts(body.Frame.TextLabel, {0.2, 'Exponential'}, {
                    TextTransparency = 1,
                    TextColor3 = rgb(255, 255, 255)
                })
                delay(0.2, function()
                    body.Frame.TextLabel.Text = option
                    ts(body.Frame.TextLabel, {0.35, 'Exponential'}, {
                        TextTransparency = 0
                    })
                end)
                local ts2 = game:service('TextService'):GetTextSize(option, 11, 'Gotham', Vector2.new(math.huge, math.huge)).X
                ts(body.Frame, {0.2, 'Exponential'}, {
                    Position = udim2(1, -(ts2 + 18), 0.5, -10),
                    Size = udim2(0, ts2 + 12, 0, 20),
                    BackgroundColor3 = rgb(0, 0, 0),
                    BackgroundTransparency = 0.7
                })
                ts(body.Frame.UICorner, {0.2, 'Exponential'}, {
                    CornerRadius = UDim.new(0, 4)
                })
            end
        end

        local tip = getgenv().tipMenu
        spawn(function()
            repeat
                wait()
                tip = getgenv().tipMenu
            until table.len(getgenv().tipMenu) == 3
        end)
        
        local toolTipActive = false
        if v2.tooltip then
            onHover(body.TextButton, 0.5, function()
                if checkPos(obj) then
                    toolTipActive = true
                    tipMenu.update(v2.text, v2.tooltip)
                    tipMenu.open()  
                end
            end, function()
                if toolTipActive then
                    tipMenu.update('', '')
                    tipMenu.close()
                end
            end)
        end

        body.Parent = obj
    end,
    textlabel = function(v2, data, obj)
        v2.text = typeof(v2.text) == 'string' and v2.text or '[empty textlabel name]'
        v2.align = typeof(v2.align) == 'string' and v2.align or 'center'
        v2.align = v2.align:lower()
        v2.color = typeof(v2.color) == 'Color3' and v2.color or Color3.new(1, 1, 1)
        v2.thickness = typeof(v2.thickness) == 'number' and v2.thickness or 1
        v2.updTable = typeof(v2.updTable) == 'table' and v2.updTable or nil

        local id = v2.text

        local body = instance('Frame', {
            Size = udim2(1, 0, 0, 30),
            BackgroundTransparency = 1,
        }, {
            instance('TextLabel', {
                Name = 'text',
                TextSize = 15,
                Font = v2.thickness == 1 and 'Gotham' or v2.thickness == 2 and 'GothamMedium' or v2.thickness == 3 and 'GothamBold' or v2.thickness == 4 and 'GothamBlack',
                TextColor3 = v2.color,
                BackgroundTransparency = 1,
                Text = v2.text,
                TextColor3 = v2.color,
                Size = v2.align == 'center' and udim2(1, 0, 1, 0) or udim2(1, -10, 1, 0),
                Position = udim2(0, v2.align == 'left' and 10 or 0, 0, 0),
                TextXAlignment = v2.align == 'center' and 'Center' or v2.align == 'left' and 'Left' or v2.align == 'right' and 'Right'
            })
        })

        if v2.updTable then
            v2.updTable[id] = function(data1)
                local text = typeof(data1.text) == 'string' and data1.text or v2.text
                local color = typeof(data1.color) == 'Color3' and data1.color or v2.color
                local align = typeof(data1.align) == 'string' and data1.align or v2.align
                align = align:lower()
                local thickness = typeof(data1.thickness) == 'number' and data1.thickness or 1

                body.text.Text = tostring(data1.text)
                body.text.TextXAlignment = align == 'center' and 'Center' or align == 'left' and 'Left' or align == 'right' and 'Right'
                body.text.Font = thickness == 1 and 'Gotham' or thickness == 2 and 'GothamMedium' or thickness == 3 and 'GothamBold' or thickness == 4 and 'GothamBlack',
                ts(body.text, {0.3, 'Exponential'}, {
                    TextColor3 = color,
                    Size = align == 'center' and udim2(1, 0, 1, 0) or udim2(1, -10, 1, 0),
                    Position = udim2(0, align == 'left' and 10 or 0, 0, 0),
                })

                v2.text = text
                v2.color = color
                v2.align = align
                v2.thickness = thickness
            end
        end

        body.Parent = obj
    end,
    locked = function(v2, data, obj)
        v2.text = typeof(v2.text) == 'string' and v2.text or '[empty name]'

        local body = instance('Frame', {
            Size = udim2(1, 0, 0, 30),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = rgb(0, 0, 0),
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 6)
            }),
            instance('TextLabel', {
                Text = v2.text,
                Font = 'Gotham',
                Size = udim2(1, -10, 1, 0),
                Position = udim2(0, 10, 0, 0),
                TextSize = 13,
                TextColor3 = rgb(255, 255, 255),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                TextXAlignment = 'Left'
            }),
            instance('ImageLabel', {
                BackgroundTransparency = 1,
                Position = udim2(1, -30, 0, 0),
                Size = udim2(0, 30, 0, 30),
                Image = 'rbxassetid://10780023339'
            })
        })

        body.Parent = obj
    end
}

local function new(data) --main library function
    sgui = instance('ScreenGui', {
        Name = 'Cappuccino_v6',
        IgnoreGuiInset = true
    })

    pcall(function()
        game:service('CoreGui')['Cappuccino_v6']:Destroy()
    end)

    local toolTip = instance('Frame', {
        Parent = sgui,
        Size = udim2(0, 300, 0, 100),
        Position = udim2(0.5, -150, 0, -200),
        BackgroundColor3 = data.theme.accent,
        BackgroundTransparency = 0.8,
        ClipsDescendants = true
    }, {
        instance('UICorner', {
            CornerRadius = UDim.new(0, 12)
        }),
        instance('TextLabel', {
            Text = 'Tooltip',
            Size = udim2(1, 0, 0, 30),
            TextSize = 14,
            Font = 'GothamMedium',
            TextColor3 = rgb(255, 255, 255),
            BackgroundTransparency = 1,
        }),
        instance('Frame', {
            Name = 'blur',
            Size = udim2(1, -20, 1, -20),
            Position = udim2(0, 10, 0, 10),
            BackgroundTransparency = 1
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 12)
            })
        }),
        instance('Frame', {
            Size = udim2(1, -12, 1, -36),
            Position = udim2(0, 6, 0, 30),
            BackgroundColor3 = rgb(0, 0, 0),
            BackgroundTransparency = 0.7,
            Name = 'body'
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 9)
            }),
            instance('TextLabel', {
                Size = udim2(1, -8, 0, 26),
                Position = udim2(0, 8, 0, 0),
                TextSize = 11,
                Font = 'GothamMedium',
                TextColor3 = rgb(230, 230, 230),
                BackgroundTransparency = 1,
                TextXAlignment = 'Left',
                Name = 'obj'
            }, {
                instance('Frame', {
                    Position = udim2(0, -2, 1, -1),
                    Size = udim2(1, -12, 0, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255),
                    BackgroundTransparency = 0.5
                })
            }),
            instance('TextLabel', {
                TextSize = 11,
                TextColor3 = rgb(200, 200, 200),
                TextXAlignment = 'Left',
                TextYAlignment = 'Top',
                BackgroundTransparency = 1,
                Position = udim2(0, 6, 0, 32),
                Size = udim2(1, -12, 1, -38),
                Name = 'fill',
                Font = 'Gotham',
                TextWrapped = true
            })
        }),
    })


    blurModule:BindFrame(toolTip.blur, {
        Transparency = 0.999,
        Material = 'Glass',
        Color = rgb(255, 255, 255)
    })

    getgenv().tipMenu = {
        open = function()
            ts(toolTip, {0.5, 'Exponential'}, {
                Position = udim2(0.5, -150, 0, 150),
                Size = udim2(0, 300, 0, 200)
            })
        end,
        close = function()
            ts(toolTip, {0.5, 'Exponential'}, {
                Position = udim2(0.5, -150, 0, -200),
                Size = udim2(0, 300, 0, 100)
            })
        end,
        update = function(obj2, fill2)
            ts(toolTip.body.obj, {0.15, 'Exponential'}, {
                TextTransparency = 1
            })
            ts(toolTip.body.fill, {0.15, 'Exponential'}, {
                TextTransparency = 1
            })
            ts(toolTip.body.obj.Frame, {0.15, 'Exponential'}, {
                BackgroundTransparency = 1
            })
            delay(0.15, function()
                toolTip.body.obj.Text = obj2
                toolTip.body.fill.Text = fill2
                ts(toolTip.body.obj, {0.15, 'Exponential'}, {
                    TextTransparency = 0
                })
                ts(toolTip.body.obj.Frame, {0.15, 'Exponential'}, {
                    BackgroundTransparency = 0.5
                })
                ts(toolTip.body.fill, {0.15, 'Exponential'}, {
                    TextTransparency = 0
                })
            end)
        end
    }


    --syn.protect_gui(sgui)

    sgui.Parent = game:service('CoreGui')

    local frame = instance('Frame', {
        Parent = sgui,
        Size = data.theme.tabAlignment == 'Left' and udim2(0, 60, 1, 0) or data.theme.tabAlignment == 'Right' and udim2(0, 60, 1, 0) or udim2(1, 0, 0, 60),
        Position = data.theme.tabAlignment == 'Left' and udim2(0, 10, 0, 0) or data.theme.tabAlignment == 'Right' and udim2(1, -70, 0, 0) or data.theme.tabAlignment == 'Top' and udim2(0, 0, 0, 10) or data.theme.tabAlignment == 'Bottom' and udim2(0, 0, 1, -70),
        BackgroundTransparency = 1,
        Name = 'TabButtons'
    }, {
        instance('UIListLayout', {
            Padding = UDim.new(0, data.theme.tabPadding),
            HorizontalAlignment = 'Center',
            VerticalAlignment = 'Center',
            FillDirection = data.theme.tabAlignment == 'Left' and 'Vertical' or data.theme.tabAlignment == 'Right' and 'Vertical' or 'Horizontal'
        })
    })

    local c = 0

    for a,v in ipairs(data.tabs) do
        c = c + 0.1
        local toggled = false
        v.size = typeof(v.size) == 'table' and v.size or {350, 350}
        local oldSize = v.size[2]

        local savedPos = udim2(0.5, -350/2, 0.5, -350/2)
        local st = false

        local tabWindow = instance('Frame', {
            Size = udim2(0, v.size[1], 0, 0),
            Name = 'tab_'..v.name,
            BackgroundTransparency = data.theme.blurSize,
            BackgroundColor3 = data.theme.accent,
            Parent = sgui,
            Position = udim2(-1, 0, -1, 0),
            Visible = false,
            ClipsDescendants = true
        }, {
            instance('UIGradient', {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, getgenv().gradientKey1),
                    ColorSequenceKeypoint.new(1, getgenv().gradientKey2)
                })
            }, {}, {
                function(self)
                    spawn(function()
                        while true do
                            ts(self, {0.5, 'Linear'}, {
                                Rotation = self.Rotation + getgenv().gradientSpeed
                            })
                            wait(0.5)
                        end
                    end)
                    spawn(function()
                        while wait() do
                            self.Enabled = getgenv().gradientEnabled
                            self.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, getgenv().gradientKey1),
                                ColorSequenceKeypoint.new(1, getgenv().gradientKey2)
                            })
                        end
                    end)
                end
            }),
            instance('Frame', { --blur
                Name = 'blur',
                Size = udim2(1, -20, 1, -20),
                Position = udim2(0, 10, 0, 10),
                BackgroundTransparency = 1
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 14)
                })
            }),
            instance('UICorner', {
                CornerRadius = UDim.new(0, 14)
            }),
            instance('TextLabel', { --title
                Text = v.name,
                Size = udim2(1, -15, 0, 26),
                Position = udim2(0, 15, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = 'Left',
                TextSize = 14, 
                Font = 'GothamSemibold',
                TextColor3 = rgb(255, 255, 255),
            }),
            instance('Frame', {
                Size = udim2(0, 14, 0, 14),
                Position = udim2(1, -24, 0, 6),
                BackgroundTransparency = 1,
                BackgroundColor3 = rgb(0, 0, 0),
                Name = 'search',
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(1, 0)
                }),
                instance('Frame', {
                    Size = udim2(0, 20, 0, 20),
                    Position = udim2(1, -17, 0, -3),
                    BackgroundTransparency = 1,
                }, {
                    instance('TextButton', {
                        Text = '',
                        BackgroundTransparency = 1,
                        Size = udim2(1, 0, 1, 0)
                    }, {}, {
                        function(self)
                            spawn(function()
                                repeat
                                    wait()
                                until self.Parent

                                local s = false

                                self.MouseButton1Up:Connect(function()
                                    s = not s
                                    st = s
                                    local p = self.Parent

                                    ts(p.Parent, {0.27, 'Exponential'}, {
                                        BackgroundTransparency = s and 0.55 or 1,
                                        Size = s and udim2(1, -12, 0, 24) or udim2(0, 14, 0, 14),
                                        Position = s and udim2(0, 6, 0, 26) or udim2(1, -24, 0, 6)
                                    })
                                    ts(p.Parent.UICorner, {0.27, 'Exponential'}, {
                                        CornerRadius = s and UDim.new(0, 6) or UDim.new(1, 0)
                                    })
                                    ts(p.Parent.TextBox, {0.27, 'Exponential'}, {
                                        Size = s and udim2(1, -23, 1, 0) or udim2(0, 0, 1, 0),
                                        Position = s and udim2(0, 6, 0, 0) or udim2(0, 0, 0, 0),
                                        TextTransparency = s and 0 or 1,
                                    })
                                    ts(p.Parent.Parent.container, {0.27, 'Exponential'}, {
                                        Size = s and udim2(1, -12, 1, -62) or udim2(1, -12, 1, -32),
                                        Position = s and udim2(0, 6, 0, 56) or udim2(0, 6, 0, 26)
                                    })
                                    ts(p, {0.27, 'Exponential'}, {
                                       Position = s and udim2(1, -23, 0, 0) or udim2(1, -17, 0, -3),
                                       Size = s and udim2(0, 20, 0, 24) or udim2(0, 20, 0, 20)
                                    })
                                    ts(p.Parent.mag, {0.27, 'Exponential'}, {
                                        Position = s and udim2(1, -20, 0.5, -14/2) or udim2(1, -14, 0.5, -14/2)
                                    })
                                    ts(p.Parent.arrow, {0.27, 'Exponential'}, {
                                        Position = s and udim2(1, -20, 0.5, -14/2) or udim2(1, -14, 0.5, -14/2)
                                    })
                                end)
                            end)
                        end
                    })
                }, {
                    function(self)
                        spawn(function()
                            repeat
                                wait()
                            until self.Parent

                            local p = self.Parent

                            self.MouseEnter:Connect(function()
                                ts(p.mag, {0.3, 'Exponential'}, {
                                    Rotation = -180,
                                    ImageTransparency = 1
                                })
                                ts(p.arrow, {0.3, 'Exponential'}, {
                                    Rotation = not st and -180 or 0,
                                    ImageTransparency = 0
                                })
                            end)

                            self.MouseLeave:Connect(function()
                                ts(p.mag, {0.3, 'Exponential'}, {
                                    Rotation = 0,
                                    ImageTransparency = 0
                                })
                                ts(p.arrow, {0.3, 'Exponential'}, {
                                    Rotation = not st and 0 or 360,
                                    ImageTransparency = 1
                                })
                            end)
                        end)
                    end
                }),
                instance('ImageLabel', { --mag
                    Image = 'rbxassetid://10965065903',
                    BackgroundTransparency = 1,
                    ImageColor3 = rgb(255, 255, 255),
                    Size = udim2(0, 14, 0, 14),
                    Position = udim2(1, -14, 0.5, -14/2),
                    Name = 'mag'
                }),
                instance('ImageLabel', { --arrow
                    Image = 'rbxassetid://10973592921',
                    BackgroundTransparency = 1,
                    ImageColor3 = rgb(255, 255, 255),
                    Size = udim2(0, 14, 0, 14),
                    Position = udim2(1, -14, 0.5, -14/2),
                    Name = 'arrow',
                    ImageTransparency = 1
                }),
                instance('TextBox', { --textbox
                    Size = udim2(0, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextSize = 13,
                    Font = 'Gotham',
                    TextColor3 = rgb(255, 255, 255),
                    PlaceholderText = 'Start typing to search',
                    TextTransparency = 1,
                    Text = '',
                    ClipsDescendants = true,
                    TextXAlignment = 'Left',
                }, {}, {
                    function(self)
                        self:GetPropertyChangedSignal('Text'):Connect(function()
                            if self.Text:gsub(' ', '') ~= '' then
                                for a,v in next, self.Parent.Parent.container.ScrollingFrame:GetChildren() do
                                    if v:IsA('Frame') then
                                        local but = v:FindFirstChildWhichIsA('TextButton')
                                        if but then
                                            if not but.Text:lower():find(self.Text:lower()) then
                                                v.Visible = false
                                            end
                                        end
                                    end
                                end
                            else
                                for a,v in next, self.Parent.Parent.container.ScrollingFrame:GetChildren() do
                                    if v:IsA('Frame') then
                                        v.Visible = true
                                    end
                                end
                            end
                        end)
                    end
                })
            }),
            instance('Frame', {
                Name = 'container',
                Position = udim2(0, 6, 0, 26),
                Size = udim2(1, -12, 1, -32),
                BackgroundTransparency = 0.6,
                BackgroundColor3 = rgb(0, 0, 0)
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 10)
                }),
                instance('ScrollingFrame', {
                    Size = udim2(1, -12, 1, -12),
                    Position = udim2(0, 6, 0, 6),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 0,
                    BorderSizePixel = 0,
                    ScrollBarImageColor3 = data.theme.accent,
                    AutomaticCanvasSize = 'Y',
                    CanvasSize = udim2(0, 0, 0, 0)
                }, {
                    instance('UIListLayout', {
                        Padding = UDim.new(0, 6)
                    })
                }, {
                    function(self)
                        local debounce = false
                        self:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
                            if debounce then
                                return
                            end

                            debounce = true
                            delay(0.1, function()
                                debounce = false
                            end)
                            ts(self, {0.2, 'Linear'}, {
                                ScrollBarThickness = 4
                            })

                            wait(0.5)
                            local save = self.CanvasPosition

                            delay(0.7, function()
                                if self.CanvasPosition == save then
                                    ts(self, {0.2, 'Linear'}, {
                                        ScrollBarThickness = 0
                                    })
                                end
                            end)
                        end)
                    end
                })
            }),
        })
        makeBetter(tabWindow)

        if data.theme.blur == true then
            blurModule:BindFrame(tabWindow.blur, {
                Transparency = 0.999,
                Material = 'Glass',
                Color = rgb(255, 255, 255)
            })
        end

        local cont = tabWindow.container.ScrollingFrame

        for a,v2 in ipairs(v.content) do
            if v2.type == 'folder' then
                v2.name = typeof(v2.name) == 'string' and v2.name or '[empty folder name]'
                v2.content = typeof(v2.content) == 'table' and v2.content or {}
                v2.size = typeof(v2.size) == 'number' and v2.size or 200

                local toggle, toggled = nil, false

                local body = instance('Frame', {
                    Size = udim2(1, 0, 0, 30),
                    BackgroundColor3 = rgb(0, 0, 0),
                    BackgroundTransparency = 0.7,
                    ClipsDescendants = true
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 6)
                    }),
                    instance('TextButton', {
                        Size = udim2(1, -10, 0, 30),
                        Position = udim2(0, 10, 0, 0),
                        Text = v2.name,
                        Font = 'GothamMedium',
                        TextSize = 13,
                        TextXAlignment = 'Left',
                        TextColor3 = rgb(255, 255, 255),
                        BackgroundTransparency = 1
                    }, {}, {
                        function(self)
                            self.MouseButton1Down:Connect(function()
                                toggled = not toggled
                                toggle(toggled)
                            end)
                        end
                    }),
                    instance('TextLabel', {
                        Position = udim2(1, -20, 0, 0),
                        Size = udim2(0, 10, 0, 32),
                        Rotation = 180,
                        Text = '>',
                        Font = 'GothamBold',
                        BackgroundTransparency = 1,
                        TextSize = 15,
                        TextColor3 = rgb(255, 255, 255)
                    }),
                    instance('Frame', {
                        Position = udim2(0, 6, 0, 30),
                        Size = udim2(1, -12, 1, -36),
                        BackgroundColor3 = rgb(0, 0, 0),
                        BackgroundTransparency = 1,
                        ClipsDescendants = true
                    }, {
                        instance('UICorner', {
                            CornerRadius = UDim.new(0, 4)
                        }),
                        instance('ScrollingFrame', {
                            Size = udim2(1, -12, 1, -12),
                            Position = udim2(0, 6, 0, 6),
                            BackgroundTransparency = 1,
                            ScrollBarThickness = 0,
                            BorderSizePixel = 0,
                            ScrollBarImageColor3 = data.theme.accent,
                            AutomaticCanvasSize = 'Y',
                            CanvasSize = udim2(0, 0, 0, 0)
                        }, {
                            instance('UIListLayout', {
                                Padding = UDim.new(0, 6)
                            })
                        }, {
                            function(self)
                                local debounce = false
                                self:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
                                    if debounce then
                                        return
                                    end
        
                                    debounce = true
                                    delay(0.1, function()
                                        debounce = false
                                    end)
                                    ts(self, {0.2, 'Linear'}, {
                                        ScrollBarThickness = 4
                                    })
        
                                    wait(0.5)
                                    local save = self.CanvasPosition
        
                                    delay(0.7, function()
                                        if self.CanvasPosition == save then
                                            ts(self, {0.2, 'Linear'}, {
                                                ScrollBarThickness = 0
                                            })
                                        end
                                    end)
                                end)
                            end
                        })
                    })
                })

                for a3,v3 in ipairs(v2.content) do
                    create[v3.type](v3, data, body.Frame.ScrollingFrame)
                end

                toggle = function(s)
                    if s then
                        ts(body, {0.3, 'Exponential'}, {
                            Size = udim2(1, 0, 0, v2.size)
                        })
                        ts(body.Frame, {0.3, 'Exponential'}, {
                            BackgroundTransparency = 0.7,
                            Size = udim2(1, -12, 1, -36)
                        })
                        ts(body.TextLabel, {0.3, 'Exponential'}, {
                            Rotation = 90
                        })
                    else
                        ts(body, {0.3, 'Exponential'}, {
                            Size = udim2(1, 0, 0, 30)
                        })
                        ts(body.Frame, {0.3, 'Exponential'}, {
                            BackgroundTransparency = 1,
                            Size = udim2(1, -12, 1, 0)
                        })
                        ts(body.TextLabel, {0.3, 'Exponential'}, {
                            Rotation = 180
                        })
                    end
                end

                body.Parent = tabWindow.container.ScrollingFrame
            else
                create[v2.type](v2, data, cont)
            end
        end

        local function toggleTab(state)
            if state then
                tabWindow.Position = savedPos
                tabWindow.Visible = true
            else
                delay(0.3, function()
                    tabWindow.Visible = false
                    savedPos = tabWindow.Position
                    tabWindow.Position = udim2(-1, 0, -1, 0)
                end)
            end
            ts(tabWindow, {0.3, 'Exponential'}, {
                Size = state and udim2(0, v.size[1], 0, v.size[2]) or udim2(0, v.size[1], 0, 0)
            })
        end

        local cooldown = false

        getgenv().tabAlignment = data.theme.tabAlignment
        getgenv().tabRoundness = data.theme.tabRoundness
        getgenv().icons = data.theme.tabIcons

        local tsi = game:service('TextService'):GetTextSize(v.name, 14, 'GothamSemibold', Vector2.new(math.huge, 40))
        local tabButton = instance('Frame', {
            Size = udim2(0, 0, 0, 40),
            ClipsDescendants = true,
            BackgroundTransparency = 1,
            Parent = frame
        }, {
            instance('Frame', {
                Size = udim2(0, 40, 0, 40),
                Position = udim2(1, -40, 0, 0),
                BackgroundTransparency = 0.5,
                BackgroundColor3 = data.theme.accent
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, data.theme.tabRoundness)
                }),
                instance('TextButton', {
                    BackgroundColor3 = rgb(0, 0, 0),
                    BackgroundTransparency = 0.5,
                    Size = udim2(1, -6, 1, -6),
                    Position = udim2(0, 3, 0, 3),
                    Font = 'GothamSemibold',
                    TextSize = 14,
                    TextColor3 = rgb(255, 255, 255),
                    TextTransparency = 1,
                    Text = v.name,
                    ClipsDescendants = true,
                    AutoButtonColor = false
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, getgenv().tabRoundness - 1)
                    })
                }, {
                    function(self)
                        local function toggle(a)
                            self.Parent.Parent.ClipsDescendants = false
                            local t1 = 'Exponential'
                            ts(self, {0.3, t1}, {TextTransparency = a and 0 or 1})
                            ts(self.Parent.Parent, {0.3, t1}, {
                                Size = a and udim2(0, (getgenv().tabAlignment == 'Left' and 40 or getgenv().tabAlignment == 'Right' and 40 or getgenv().tabAlignment == 'Top' and tsi.X + 20 or getgenv().tabAlignment == 'Bottom' and tsi.X + 20), 0, 30) or udim2(0, 40, 0, 40),
                            })
                            ts(self.Parent, {0.3, t1}, {
                                Size = a and udim2(0, tsi.X + 20, 0, 30) or udim2(0, 40, 0, 40), 
                                Position = a and udim2(0, (getgenv().tabAlignment == 'Left' and 0
                                                        or getgenv().tabAlignment == 'Right' and -(tsi.X - 25) 
                                                        or getgenv().tabAlignment == 'Top' and 0
                                                        or getgenv().tabAlignment == 'Bottom' and 0)) or udim2(1, -40, 0, 0)                            
                            })
                            if getgenv().icons then
                                ts(self.Parent.icon, {0.3, tl}, {
                                    ImageTransparency = a and 1 or 0
                                })
                            else
                                ts(self.Parent.icon, {0.3, tl}, {
                                    ImageTransparency = 1
                                })
                            end
                            ts(self.UICorner, {0.3, t1}, {CornerRadius = a and UDim.new(0, 5) or UDim.new(0, getgenv().tabRoundness - 1)})
                            ts(self.Parent.UICorner, {0.3, t1}, {CornerRadius = a and UDim.new(0, 6) or UDim.new(0, getgenv().tabRoundness)})
                        end
                        local function changeButton(state2)
                            ts(self, {0.3, 'Exponential'}, {
                                TextColor3 = state2 and rgb(0, 0, 0) or rgb(255, 255, 255),
                                BackgroundColor3 = state2 and rgb(255, 255, 255) or rgb(0, 0, 0)
                            })
                            ts(self.Parent.icon, {0.3, 'Exponential'}, {
                                ImageColor3 = state2 and rgb(0, 0, 0) or rgb(255, 255, 255)
                            })
                        end
                        self.MouseEnter:Connect(function()
                            toggle(true)
                        end)
                        self.MouseLeave:Connect(function()
                            toggle(false)
                        end)
                        self.MouseButton1Down:Connect(function()
                            if cooldown == true then
                                return
                            end
                            cooldown = true
                            delay(0.4, function()
                                cooldown = false
                            end)

                            toggled = not toggled
                            toggleTab(toggled)
                            changeButton(toggled)
                            bubble(self, data.theme.accent)
                        end)
                    end
                }),
                instance('ImageLabel', {
                    BackgroundTransparency = 1,
                    Size = udim2(1, -14, 1, -14),
                    Position = udim2(0, 7, 0, 7),
                    ImageColor3 = rgb(255, 255, 255),
                    Image = v.icon,
                    Name = 'icon',
                    ImageTransparency = data.theme.tabIcons and 0 or 1
                }),
            }, {
                function(self)
                    if data.theme.blur == true then
                        spawn(function()
                            repeat
                                local a = pcall(function()
                                    blurModule:BindFrame(self, {
                                        Transparency = 0.999,
                                        Material = 'Glass',
                                        Color = rgb(255, 255, 255)
                                    })
                                end)
                            until a
                        end)
                    end
                end
            })
        }, {
            function(self)
                delay((1 + c), function()
                    ts(self, {0.3, 'Exponential'}, {
                        Size = udim2(0, 40, 0, 40)
                    }) 
                end)
            end
        })
    end
end

return new 
