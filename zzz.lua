local function fRGB(t)
    return Color3.new(t.r, t.g, t.b)
end

local h = game:service('HttpService')
local json = {
    encode = function(str)
        return h:JSONEncode(str)
    end,
    decode = function(str)
        return h:JSONDecode(str)
    end
}

xpcall(function()
    return json.decode(readfile('cv5.3uiconf.json'))
end, function()
    writefile('cv5.3uiconf.json', json.encode({
        ['AutoTransparency'] = true,
        ['ColorTheme'] = {
            r = 0.0001,
            g = 0.0001, 
            b = 0.0001
        },
        ['ReducedMotion'] = false,
        ['BlurColorEffect'] = true,
    }))
end)

getgenv().uiConfig = json.decode(readfile('cv5.3uiconf.json'))

spawn(function()
    while wait(0.5) do
        writefile('cv5.3uiconf.json', json.encode(uiConfig))
    end
end)

local function instance(className,properties,children,funcs)
    local object = Instance.new(className,parent)

    for i, v in pairs(properties or {}) do
        object[i] = v
    end

    for i, self in pairs(children or {}) do
        self.Parent = object
    end

    for i,func in pairs(funcs or {}) do
        func(object)
    end

    return object
end
local function ts(object,tweenInfo,properties)
    if tweenInfo[2] and typeof(tweenInfo[2]) == 'string' then
        tweenInfo[2] = Enum.EasingStyle[ tweenInfo[2] ]
    end

    game:service('TweenService'):create(object, TweenInfo.new(unpack(tweenInfo)), properties):Play()
end
local function udim2(x1,x2,y1,y2)
    local t = tonumber
    return UDim2.new(t(x1),t(x2),t(y1),t(y2))
end
local function rgb(r,g,b)
    return Color3.fromRGB(r,g,b)
end

local mouse = game:service('Players').LocalPlayer:GetMouse()
local input = game:service('UserInputService')

local function dragify(frame)
    frame.InputBegan:connect(function(inp)
        pcall(function()
            if (inp.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                local mx, my = mouse.X, mouse.Y
                local move, kill
                move = mouse.Move:connect(function()
                    local nmx, nmy = mouse.X, mouse.Y
                    local dx, dy = nmx - mx, nmy - my
                    frame.Position = frame.Position + UDim2.fromOffset(dx, dy)
                    mx, my = nmx, nmy
                end)
                kill = input.InputEnded:connect(function(inputType)
                    if inputType.UserInputType == Enum.UserInputType.MouseButton1 then
                        move:Disconnect()
                        kill:Disconnect()
                    end
                end)
            end
        end)
    end)
end

local function round(exact, quantum)
    local quant, frac = math.modf(exact/quantum)
    return quantum * (quant + (frac > 0.5 and 1 or 0))
end

local function scale(unscaled, minAllowed, maxAllowed, min, max)
    return (maxAllowed - minAllowed) * (unscaled - min) / (max - min) + minAllowed
end

local library = {}
local mouseMove = {}
mouse.Move:connect(function()
    for a,v in next, mouseMove do
        v()
    end
end)

local function getRel(object)
    return {
        X = (mouse.X - object.AbsolutePosition.X),
        Y = (mouse.Y - object.AbsolutePosition.Y)
    }
end

getgenv().theme = {
    background = rgb(29, 30, 34),
    accent = fRGB(uiConfig.ColorTheme),
    text = rgb(255, 255, 255),
    passive = rgb(60, 60, 60),
}

local function bubble(object)
    local rel = getRel(object)

    local bInst = instance('Frame', {
        Parent = object,
        Size = udim2(0, 0, 0, 0),
        Position = udim2(0, rel.X, 0, rel.Y),
        BackgroundTransparency = 0,
        BackgroundColor3 = theme.accent,
    }, {
        instance('UICorner', {
            CornerRadius = UDim.new(1, 0)
        })
    })

    ts(bInst, {0.6, 'Sine'}, {
        Size = udim2(0, 300, 0, 300),
        Position = udim2(0, rel.X - 150, 0, rel.Y - 150),
        BackgroundTransparency = 1
    })

    delay(0.6, function()
        bInst:Destroy()
    end)
end

function library:New(data)
    pcall(function()
        game:service('CoreGui')['cap_lib']:Destroy()
        game:service('Lighting')['cap_blur']:Destroy()
        game:service('Lighting')['cap_color']:Destroy()
    end)

    local toggled = false

    local blur = instance('BlurEffect', {
        Name = 'cap_blur',
        Parent = game:service('Lighting'),
        Size = 0
    })
    local color = instance('ColorCorrectionEffect', {
        Name = 'cap_color',
        Parent = game:service('Lighting'),
    })

    getgenv().sGui = instance('ScreenGui', {
        Name = 'cap_lib',
        IgnoreGuiInset = true
    })

    if syn and syn.protect_gui then
        syn.protect_gui(sGui)
    end

    sGui.Parent = game:service('CoreGui')

    local mainFrame = instance('Frame', {
        Parent = sGui,
        Size = udim2(0, 330, 1, 0),
        Position = udim2(0, -330, 0, 0),
        BackgroundColor3 = theme.background,
        BorderColor3 = theme.accent
    }, {
        instance('Frame', {
            Name = 'color',
            Size = udim2(1, -32, 1, -92),
            Position = udim2(0, 16, 0, 76),
            BackgroundColor3 = theme.accent,
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 4)
            }),
            instance('Frame', {
                Name = 'container',
                Size = udim2(1, -2, 1, -2),
                Position = udim2(0, 1, 0, 1),
                BackgroundColor3 = theme.background,
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 3)
                }),
                instance('Frame', {
                    Size = udim2(1, 0, 1, -6),
                    Position = udim2(0, 0, 0, 3),
                    BackgroundTransparency = 1,
                    Name = 'container'
                }, {
                    instance('UIListLayout', {
                        Padding = UDim.new(0, 3),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                })
            }),
        }),
        instance('TextLabel', {
            Size = udim2(0, 200, 0, 36),
            Position = udim2(0, 30, 0, 40),
            BackgroundTransparency = 1,
            Text = data.Title,
            TextColor3 = theme.text,
            TextSize = 18,
            Font = 'GothamSemibold',
            TextXAlignment = 'Left'
        })
    }, {
        function(self)
            table.insert(mouseMove, function()
                if mouse.X < 30 then
                    toggled = true
                    ts(self, {0.3, 'Sine'}, {
                        Position = udim2(0, 0, 0, 0)
                    })
                    ts(blur, {0.3, 'Sine'}, {
                        Size = (uiConfig.BlurColorEffect and 34 or 0)
                    })
                    ts(color, {0.3, 'Sine'}, {
                        TintColor = (uiConfig.BlurColorEffect and theme.accent or Color3.new(1, 1, 1)),
                    })
                elseif (toggled and mouse.X > 330) or not toggled then
                    ts(self, {0.3, 'Sine'}, {
                        Position = udim2(0, -330, 0, 0)
                    })
                    ts(blur, {0.3, 'Sine'}, {
                        Size = 0
                    })
                    ts(color, {0.3, 'Sine'}, {
                        TintColor = rgb(255, 255, 255),
                    })
                end
            end)
        end
    })

    local tabCount = 0

    local function createTabWindow(name, objects)
        objects.Size = (typeof(objects.Size) == 'table') and objects.Size or {360, 360}
        local tabOpened = false
        tabCount = tabCount + 1

        local tabButton = instance('Frame', {
            Parent = mainFrame.color.container.container,
            Size = udim2(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Name = tostring(name),
            ClipsDescendants = true
        }, {
            instance('Frame', {
                Name = 'color',
                Size = udim2(1, -6, 1, 0),
                Position = udim2(0, 3, 0, 0),
                BackgroundColor3 = theme.accent,
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 4)
                }),
                instance('Frame', {
                    Name = 'button_holder',
                    Size = udim2(1, -2, 1, -2),
                    Position = udim2(0, 1, 0, 1),
                    BackgroundColor3 = theme.background,
                    ClipsDescendants = true
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 3)
                    }),
                    instance('TextButton', {
                        Size = udim2(1, -12, 1, 0),
                        Position = udim2(0, 6, 0, 0),
                        TextXAlignment = 'Left',
                        Font = 'Gotham',
                        TextColor3 = theme.text,
                        TextSize = 14,
                        BackgroundTransparency = 1,
                        Text = tostring(name) 
                    })
                })
            })
        })

        local tabWindow

        local function toggleTransparency(bool)
            local final = (uiConfig.AutoTransparency and (bool and 0 or 0.9) or 0)
            ts(tabWindow, {0.3, 'Quint'}, {
                BackgroundTransparency = final
            })
            for a,v in next, tabWindow:GetDescendants() do
                pcall(function()
                    if v.BackgroundTransparency ~= 1 then
                        if not uiConfig.ReducedMotion then
                            ts(v, {0.3, 'Quint'}, {
                                BackgroundTransparency = final
                            })
                        else
                            v.BackgroundTransparency = final
                        end
                    end
                end)
                pcall(function()
                    if v.TextTransparency ~= 1 then
                        if not uiConfig.ReducedMotion then
                            ts(v, {0.3, 'Quint'}, {
                                TextTransparency = final
                            })
                        else
                            v.TextTransparency = final
                        end
                    end
                end)
                pcall(function()
                    if v.ImageTransparency ~= 1 then
                        if not uiConfig.ReducedMotion then
                            ts(v, {0.3, 'Quint'}, {
                                ImageTransparency = final
                            })
                        else
                            v.ImageTransparency = final
                        end
                    end
                end)
            end
        end

        local realSize = udim2(0, objects.Size[1], 0, objects.Size[2])
        local lastToggled = false

        tabWindow = instance('Frame', {
            Parent = sGui,
            Visible = false,
            Size = udim2(0, 0, 0, 0),
            Position = udim2(0, (550 + (0 * tabCount)), 0, (210 + (25 * tabCount))),
            BackgroundColor3 = theme.accent,
            BackgroundTransparency = 0.6,
            ClipsDescendants = true,
            Visible = false, -- stupid dots
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 10)
            }),
            instance('Frame', {
                Name = 'background',
                Size = udim2(1, -4, 1, -4),
                Position = udim2(0, 2, 0, 2),
                BackgroundColor3 = theme.background,
                BackgroundTransparency = 0
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 9)
                }),
                instance('Frame', {
                    Size = udim2(1, 0, 0, 30),
                    BackgroundColor3 = rgb(45, 47, 53),
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 9)
                    }),
                    instance('Frame', {
                        Size = udim2(1, 0, 0, 10),
                        Position = udim2(0, 0, 1, -10),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(45, 47, 53)
                    }),
                    instance('TextLabel', {
                        Position = udim2(0, 10, 0, 0),
                        TextXAlignment = 'Left',
                        Size = udim2(0, 150, 1, 0),
                        Font = 'GothamSemibold',
                        TextColor3 = theme.text,
                        BackgroundTransparency = 1,
                        TextSize = 14,
                        Text = tostring(name)
                    })
                }),
                instance('Frame', {
                    Position = udim2(0, 8, 0, 38),
                    Size = udim2(1, -16, 1, -46),
                    BackgroundColor3 = theme.accent,
                    BackgroundTransparency = 0,
                    Name = 'container_color'
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 7)
                    }),
                    instance('Frame', {
                        Size = udim2(1, -2, 1, -2),
                        Position = udim2(0, 1, 0, 1),
                        BackgroundColor3 = theme.background,
                        BackgroundTransparency = 0
                    }, {
                        instance('UICorner', {
                            CornerRadius = UDim.new(0, 6)
                        }),
                        instance('ScrollingFrame', {
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ScrollBarThickness = 0,
                            Name = 'container',
                            Size = udim2(1, -6, 1, -6),
                            Position = udim2(0, 3, 0, 3)
                        }, {
                            instance('UIListLayout', {
                                Padding = UDim.new(0, 2)
                            })
                        })
                    })
                })
            })
        }, {
            function(self)
                table.insert(mouseMove, function()
                    local ap, as = self.AbsolutePosition, self.AbsoluteSize
                    if mouse.X > ap.X and mouse.X < (ap.X + as.X) and mouse.Y > ap.Y and mouse.Y < (ap.Y + as.Y) then
                        if lastToggled == false then
                            lastToggled = true
                            toggleTransparency(true)
                        else
                            return
                        end
                    else
                        if lastToggled == true then
                            lastToggled = false
                            toggleTransparency(false)
                        else
                            return
                        end
                    end
                end)
            end
        })
        dragify(tabWindow)

        local realButton = tabButton.color.button_holder.TextButton
        local opening = false
        realButton.MouseButton1Up:connect(function()
            if opening then 
                return
            end
            opening = true
            tabOpened = not tabOpened
            local abs = tabWindow.AbsolutePosition

            local tween = ts(tabWindow, {0.45, 'Quint'}, {
                Size = (tabOpened and realSize or udim2(0, 0, 0, 0)),
                Position = (tabOpened and udim2(0, abs.X - 180, 0, abs.Y - 108) or udim2(0, abs.X + 180, 0, abs.Y + 180))
            })
            
            if (not tabOpened) then -- stupid dots
                task.delay(0.45, function()
                    if (not tabOpened) then
                        tabWindow.Visible = false
                    end
                end)
            else
                tabWindow.Visible = true
            end

            ts(realButton.Parent, {1, 'Sine'}, {
                BackgroundColor3 = (tabOpened and theme.accent or theme.background)
            })
            bubble(realButton.Parent)
            delay(0.5, function()
                opening = false
            end)
        end)

        local rParent = tabWindow.background.container_color.Frame.container

        local function createButton(name, callback)
            local main = instance('Frame', {
                Parent = rParent,
                Size = udim2(1, 0, 0, 30),
                BackgroundColor3 = theme.accent,
                BackgroundTransparency = 0
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 5)
                }),
                instance('Frame', {
                    Size = udim2(1, -2, 1, -2),
                    Position = udim2(0, 1, 0, 1),
                    BackgroundColor3 = theme.background,
                    BackgroundTransparency = 0
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    instance('TextButton', {
                        Size = udim2(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Font = 'Gotham',
                        TextSize = 12,
                        TextColor3 = theme.text,
                        Text = tostring(name),
                        ClipsDescendants = true
                    }, {}, {
                        function(self)
                            self.MouseButton1Up:connect(function()
                                spawn(callback)
                                bubble(self)
                            end)
                        end
                    })
                })
            })
        end

        local function createToggle(text, state, callback)
            local imgData = {
                'rbxassetid://3229285359',
                'rbxassetid://7702365559'
            }
            local toggled = state

            local main;main = instance('Frame', {
                Parent = rParent,
                Size = udim2(1, 0, 0, 30),
                BackgroundColor3 = theme.accent,
                BackgroundTransparency = 0
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 5)
                }),
                instance('Frame', {
                    Size = udim2(1, -2, 1, -2),
                    Position = udim2(0, 1, 0, 1),
                    BackgroundColor3 = theme.background,
                    BackgroundTransparency = 0
                }, {
                    instance('ImageLabel', {
                        Size = udim2(0, 16, 0, 16),
                        Position = udim2(1, -24, 0.5, -8),
                        BackgroundTransparency = 1,
                        Image = (state and imgData[1] or imgData[2]),
                        ImageColor3 = (state and rgb(90, 255, 90) or rgb(255, 90, 90))
                    }),
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    instance('TextButton', {
                        Size = udim2(1, -8, 1, 0),
                        Position = udim2(0, 8, 0, 0),
                        TextXAlignment = 'Left',
                        BackgroundTransparency = 1,
                        Font = 'Gotham',
                        TextSize = 12,
                        TextColor3 = theme.text,
                        Text = tostring(text),
                        ClipsDescendants = true
                    }, {}, {
                        function(self)
                            self.MouseButton1Up:connect(function()
                                toggled = not toggled

                                spawn(function()
                                    callback(toggled)
                                end)

                                local img = main.Frame.ImageLabel
                                ts(img, {0.1, 'Quint'}, {
                                    ImageTransparency = 1
                                })
                                delay(0.1, function()
                                    img.Image = (toggled and imgData[1] or imgData[2])
                                    img.ImageColor3 = (toggled and rgb(90, 255, 90) or rgb(255, 90, 90))
                                    ts(img, {0.1, 'Quint'}, {
                                        ImageTransparency = 0
                                    })
                                end)
                            end)
                        end
                    })
                })
            })
        end

        local function createTextBox(txt, PlaceHolder, NumbersOnly, Callback)
            local frameSize = game:service('TextService'):GetTextSize(txt, 12, 'Gotham', Vector2.new(math.huge, math.huge))

            local main = instance('Frame', {
                Parent = rParent,
                Size = udim2(1, 0, 0, 30),
                BackgroundColor3 = theme.accent,
                BackgroundTransparency = 0
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 5)
                }),
                instance('Frame', {
                    Size = udim2(1, -2, 1, -2),
                    Position = udim2(0, 1, 0, 1),
                    BackgroundColor3 = theme.background,
                    BackgroundTransparency = 0
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    instance('TextLabel', {
                        Size = udim2(1, -8, 1, 0),
                        Position = udim2(0, 8, 0, 0),
                        Name = 'Text',
                        Text = tostring(txt),
                        Font = 'Gotham',
                        BackgroundTransparency = 1,
                        TextSize = 12,
                        TextColor3 = theme.text,
                        TextXAlignment = 'Left'
                    }),
                    instance('TextBox', {
                        Size = udim2(1, -(frameSize.X + 18), 1, -8),
                        Position = udim2(0, (frameSize.X + 14), 0, 4),
                        BorderSizePixel = 0,
                        BackgroundColor3 = theme.passive,
                        Font = 'Gotham',
                        TextSize = 12,
                        TextColor3 = theme.text,
                        ClipsDescendants = true,
                        PlaceholderText = tostring(PlaceHolder),
                        Text = '',
                    }, {
                        instance('UICorner', {
                            CornerRadius = UDim.new(0, 4)
                        })
                    }, {
                        function(self)
                            if NumbersOnly then
                                local function filter(str)
                                    return str:gsub('.', function(x)
                                        if x:byte() > 47 and x:byte() < 58 then
                                            return x
                                        end
                                        return ''
                                    end)
                                end
                                self:GetPropertyChangedSignal('Text'):connect(function()
                                    self.Text = filter(self.Text)
                                end)
                            end

                            self.FocusLost:connect(function(e)
                                if e then
                                    Callback(self.Text)
                                end
                            end)
                        end
                    })
                })
            })
        end

        local function createKeybind(text, default, callback, newcallback)
            local key = typeof(default) ~= nil and Enum.KeyCode[default] or nil

            game:service('UserInputService').InputBegan:connect(function(k, t)
                if t then
                    return
                end
                if k.KeyCode == key then
                    callback()
                end
            end)

            local main = instance('Frame', {
                Parent = rParent,
                Size = udim2(1, 0, 0, 30),
                BackgroundColor3 = theme.accent,
                BackgroundTransparency = 0
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 5)
                }),
                instance('Frame', {
                    Size = udim2(1, -2, 1, -2),
                    Position = udim2(0, 1, 0, 1),
                    BackgroundColor3 = theme.background,
                    BackgroundTransparency = 0,
                    ClipsDescendants = true
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    instance('TextButton', {
                        Size = udim2(1, -8, 1, 0),
                        Position = udim2(0, 8, 0, 0),
                        Name = 'Text',
                        Text = tostring(text),
                        Font = 'Gotham',
                        BackgroundTransparency = 1,
                        TextSize = 12,
                        TextColor3 = theme.text,
                        TextXAlignment = 'Left'
                    }, {}, {
                        function(self)
                            spawn(function()
                                repeat
                                    wait()
                                until self.Parent ~= nil
                                self.Parent:WaitForChild('Frame')
                                self.Parent.Frame:WaitForChild('TextLabel')

                                if key then
                                    self.Parent.Frame.TextLabel.Text = tostring(key):split('.')[3]
                                end
                                self.MouseButton1Up:connect(function()
                                    bubble(self.Parent)
                                    local txt = self.Parent.Frame.TextLabel
                                    txt.Text = '...'

                                    local input;input = game:service('UserInputService').InputBegan:connect(function(k, t)
                                        if t or k.KeyCode == Enum.KeyCode.Unknown then
                                            key = nil
                                            txt.Text = '[unbinded]'
                                            input:Disconnect()
                                            return
                                        end
                                        txt.Text = tostring(k.KeyCode):split('.')[3]
                                        key = k.KeyCode
                                        local d,a = pcall(function()
                                            newcallback(k.KeyCode)
                                        end)
                                        if not d then warn(('cappuccino_library error: "%s"'):format(a)) end
                                        input:Disconnect()
                                    end)
                                end)
                            end)
                        end
                    }),
                    instance('Frame', {
                        Size = udim2(0, 20, 0, 20),
                        Position = udim2(1, -24, 0, 4),
                        BackgroundColor3 = theme.passive
                    }, {
                        instance('TextLabel', {
                            BackgroundTransparency = 1,
                            TextSize = 12,
                            Font = 'Gotham',
                            Text = '[unbinded]',
                            TextColor3 = theme.text,
                            Size = udim2(1, 0, 1, 0), 
                        }),
                        instance('UICorner', {
                            CornerRadius = UDim.new(0, 4)
                        })
                    }, {
                        function(self)
                            spawn(function()
                                while wait() do
                                    pcall(function()
                                        local size = game:service('TextService'):GetTextSize(self.TextLabel.Text, 12, 'Gotham', Vector2.new(math.huge, math.huge))

                                        ts(self, {0.3, 'Sine'}, {
                                            Position = udim2(1, -((size.X + 8) + 4), 0, 4),
                                            Size = udim2(0, (size.X + 8), 0, 20)
                                        })
                                    end)
                                end
                            end)
                        end
                    })
                })
            })
        end

        local function createSlider(text, default, min, max, float, callback)
            local frameSize = game:service('TextService'):GetTextSize(text, 12, 'Gotham', Vector2.new(math.huge, math.huge))
            min = min or 0
            max = max or 100
            local value = default or min
            if value > max then
                value = max
            end
            float = float or 1

            local main = instance('Frame', {
                Parent = rParent,
                Size = udim2(1, 0, 0, 30),
                BackgroundColor3 = theme.accent,
                BackgroundTransparency = 0
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 5)
                }),
                instance('Frame', {
                    Size = udim2(1, -2, 1, -2),
                    Position = udim2(0, 1, 0, 1),
                    BackgroundColor3 = theme.background,
                    BackgroundTransparency = 0,
                    ClipsDescendants = true
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    instance('TextLabel', {
                        Size = udim2(1, -8, 1, 0),
                        Position = udim2(0, 8, 0, 0),
                        Name = 'Text',
                        Text = tostring(text),
                        Font = 'Gotham',
                        BackgroundTransparency = 1,
                        TextSize = 12,
                        TextColor3 = theme.text,
                        TextXAlignment = 'Left',
                    }),
                    instance('Frame', {
                        Size = udim2(1, -(frameSize.X + 12), 1, 0),
                        Position = udim2(0, frameSize.X + 12, 0, 0),
                        BackgroundTransparency = 1,
                    }, {
                        instance('Frame', {
                            Size = udim2(1, -8, 0, 8),
                            Position = udim2(0, 2, 0.5, -4),
                            BackgroundColor3 = theme.passive,
                            ClipsDescendants = true
                        }, {
                            instance('UICorner', {
                                CornerRadius = UDim.new(1, 0)
                            }),
                            instance('Frame', {
                                Size = udim2(scale(value, 0, 1, min, max), -4, 1, -4),
                                Position = udim2(0, 2, 0, 2),
                                BackgroundColor3 = theme.accent
                            }, {
                                instance('UICorner', {
                                    CornerRadius = UDim.new(1, 0)
                                })
                            })
                        }),
                        instance('TextLabel', {
                            BorderSizePixel = 0,
                            BackgroundColor3 = theme.background,
                            Font = 'Gotham',
                            TextSize = 9,
                            TextColor3 = theme.text
                        }, {}, {
                            function(self)
                                spawn(function()
                                    while wait(0.1) do
                                        self.Text = ('%s / %s'):format(value, max)
                                        local size = game:service('TextService'):GetTextSize(self.Text, 9, 'Gotham', Vector2.new(math.huge, math.huge))
                                        ts(self, {0.3, 'Sine'}, {
                                            Size = udim2(0, size.X + 6, 0, 20),
                                            Position = udim2(0.5, -((size.X + 6) / 2), 0.5, -10)
                                        })
                                    end
                                end)
                            end
                        }),
                        instance('TextButton', {
                            Text = '',
                            Size = udim2(1, 0, 1, 0),
                            BackgroundTransparency = 1 
                        }, {}, {
                            function(self)
                                spawn(function()
                                    repeat
                                        wait()
                                    until self.Parent ~= nil
                                    self.Parent:WaitForChild('Frame')
                                    local update, frame = nil, self.Parent.Frame
                                    self.MouseButton1Down:connect(function()
                                        if update ~= nil then
                                            update:Disconnect()
                                            update = nil
                                            return
                                        end
                                        update = mouse.Move:connect(function()
                                            local f2 = frame.Parent
                                            if mouse.X > f2.AbsolutePosition.X and mouse.X < (f2.AbsolutePosition.X + f2.AbsoluteSize.X) and mouse.Y > f2.AbsolutePosition.Y and mouse.Y < (f2.AbsolutePosition.Y + f2.AbsoluteSize.Y) then
                                                local p0, p1, pm = frame.AbsolutePosition.X, (frame.AbsolutePosition.X + frame.AbsoluteSize.X), mouse.X
                                                if pm > p1 then
                                                    pm = p1
                                                elseif pm < p0 then
                                                    pm = p0
                                                end
                                                local floatScale = scale(float, 0, 1, min, max)
                                                local sizeScale = round(scale(pm, 0, 1, p0, p1), floatScale)
                                                local numScale = round(scale(pm, min, max, p0, p1), float)

                                                value = numScale
                                                local d,a = pcall(function()
                                                    callback(value)
                                                end)
                                                if not d then warn('cappuccino_library: '..a) end
                                                ts(frame.Frame, {0.3, 'Sine'}, {
                                                    Size = udim2(scale(value, 0, 1, min, max), -4, 1, -4)
                                                })
                                            else
                                                pcall(function()
                                                    update:Disconnect()
                                                    update = nil
                                                end)
                                            end
                                        end)
                                    end)
                                    self.MouseButton1Up:connect(function()
                                        pcall(function()
                                            update:Disconnect()
                                            update = nil
                                        end)
                                    end)
                                end)
                            end
                        })
                    })
                })
            })
        end

        local function createColorPicker(text, default, callback)
            if not default then
                default = Color3.new(1, 1, 1)
            end
            local h, s, v = default:ToHSV()
            local kp, hsv = ColorSequenceKeypoint.new, Color3.fromHSV
            local smallPreview

            local main;main = instance('Frame', {
                Parent = rParent,
                Size = udim2(1, 0, 0, 30),
                BackgroundColor3 = theme.accent,
                BackgroundTransparency = 0
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 5)
                }),
                instance('Frame', {
                    Size = udim2(1, -2, 1, -2),
                    Position = udim2(0, 1, 0, 1),
                    BackgroundColor3 = theme.background,
                    BackgroundTransparency = 0,
                    ClipsDescendants = true
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    instance('TextLabel', {
                        Size = udim2(1, -8, 1, 0),
                        Position = udim2(0, 8, 0, 0),
                        Name = 'Text',
                        Text = tostring(text),
                        Font = 'Gotham',
                        BackgroundTransparency = 1,
                        TextSize = 12,
                        TextColor3 = theme.text,
                        TextXAlignment = 'Left',
                    }),
                    instance('Frame', {
                        Size = udim2(0, 30, 1, -8),
                        Position = udim2(1, -34, 0, 4),
                        BackgroundColor3 = default
                    }, {
                        instance('UICorner', {
                            CornerRadius = UDim.new(0, 4)
                        })
                    }, {
                        function(self)
                            smallPreview = self
                        end
                    }),
                    instance('TextButton', {
                        Size = udim2(1, -8, 1, 0),
                        Position = udim2(0, 8, 0, 0),
                        Name = 'Text',
                        Text = tostring(text),
                        Font = 'Gotham',
                        BackgroundTransparency = 1,
                        TextSize = 12,
                        TextColor3 = theme.text,
                        TextXAlignment = 'Left',
                    }, {}, {
                        function(self)
                            local toggled = false

                            local ui;ui = instance('Frame', {
                                Parent = sGui,
                                Size = udim2(0, 0, 0, 300),
                                Position = udim2(0.5, -250/2, 0.5, -300/2),
                                BackgroundColor3 = theme.accent,
                                BackgroundTransparency = 0.6,
                                Visible = false,
                                ClipsDescendants = true
                            }, {
                                instance('UICorner', {
                                    CornerRadius = UDim.new(0, 10),
                                }),
                                instance('Frame', {
                                    Name = 'container',
                                    Size = udim2(1, -4, 1, -4),
                                    Position = udim2(0, 2, 0, 2),
                                    BackgroundColor3 = theme.background,
                                }, {
                                    instance('UICorner', {
                                        CornerRadius = UDim.new(0, 9)
                                    }),
                                    instance('TextLabel', {
                                        TextSize = 14,
                                        Font = 'GothamSemibold',
                                        Text = tostring(text),
                                        TextColor3 = theme.text,
                                        Size = udim2(1, 0, 0, 30),
                                        BackgroundTransparency = 1,
                                    }),
                                    instance('Frame', {
                                        Name = 'saturation',
                                        Size = udim2(1, -20, 0.5, 0),
                                        Position = udim2(0, 10, 0, 30),
                                        BackgroundColor3 = Color3.new(1, 1, 1),
                                    }, {
                                        instance('UICorner', {
                                            CornerRadius = UDim.new(0, 3)
                                        }),
                                        instance('UIGradient', {}, {}, {
                                            function(self)
                                                spawn(function()
                                                    while wait() do
                                                        self.Color = ColorSequence.new({
                                                            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                                                            ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))
                                                        })
                                                    end
                                                end)
                                            end
                                        })
                                    }),
                                    instance('Frame', {
                                        Name = 'value',
                                        Size = udim2(1, -20, 0.5, 0),
                                        Position = udim2(0, 10, 0, 30),
                                        BackgroundColor3 = Color3.new(1, 1, 1),
                                    }, {
                                        instance('UICorner', {
                                            CornerRadius = UDim.new(0, 2)
                                        }),
                                        instance('UIGradient', {
                                            Rotation = 90,
                                            Color = ColorSequence.new({
                                                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                                                ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
                                            }),
                                            Transparency = NumberSequence.new({
                                                NumberSequenceKeypoint.new(0, 1),
                                                NumberSequenceKeypoint.new(1, 0)
                                            })
                                        }),
                                        instance('Frame', {
                                            Size = udim2(0, 8, 0, 8),
                                            BackgroundColor3 = rgb(0, 0, 0),
                                            Position = udim2(v, -4, s, -4),
                                            Name = 'pointer'
                                        }, {
                                            instance('UICorner', {
                                                CornerRadius = UDim.new(1, 0)
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
                                        }),
                                        instance('TextButton', {
                                            Size = udim2(1, 0, 1, 0),
                                            Text = '',
                                            BackgroundTransparency = 1,
                                        }, {}, {
                                            function(self)
                                                local update
                                                
                                                self.MouseButton1Down:connect(function()
                                                    local frame = self.Parent
                                                    update = mouse.Move:connect(function()
                                                        local ap, as = frame.AbsolutePosition, frame.AbsoluteSize
                                                        if mouse.X < (ap.X + as.X) and mouse.X > ap.X and mouse.Y < (ap.Y + as.Y) and mouse.Y > ap.Y then
                                                            s = scale(mouse.X, 0, 1, ap.X, (ap.X + as.X))
                                                            v = scale(mouse.Y, 1, 0, ap.Y, (ap.Y + as.Y))

                                                            ts(self.Parent.pointer, {0.3, 'Quint'}, {
                                                                Position = udim2(0, (mouse.X - ap.X) - 4, 0, (mouse.Y - ap.Y) - 4)
                                                            })
                                                        else
                                                            update:Disconnect()
                                                        end
                                                    end)
                                                end)

                                                self.MouseButton1Up:connect(function()
                                                    update:Disconnect()
                                                end)
                                            end
                                        })
                                    }),
                                    instance('TextButton', {
                                        Name = 'hue',
                                        Text = '',
                                        Size = udim2(1, -20, 0, 20),
                                        Position = udim2(0, 10, 0, 188),
                                        BackgroundColor3 = rgb(255, 255, 255),
                                        AutoButtonColor = false
                                    }, {
                                        instance('UICorner', {
                                            CornerRadius = UDim.new(0, 3)
                                        }),
                                        instance('UIGradient', {
                                            Color = ColorSequence.new({
                                                kp(0, hsv(0, 1, 1)),
                                                kp(0.1, hsv(0.1, 1, 1)),
                                                kp(0.2, hsv(0.2, 1, 1)),
                                                kp(0.3, hsv(0.3, 1, 1)),
                                                kp(0.4, hsv(0.4, 1, 1)),
                                                kp(0.5, hsv(0.5, 1, 1)),
                                                kp(0.6, hsv(0.6, 1, 1)),
                                                kp(0.7, hsv(0.7, 1, 1)),
                                                kp(0.8, hsv(0.8, 1, 1)),
                                                kp(0.9, hsv(0.9, 1, 1)),
                                                kp(1, hsv(1, 1, 1)),
                                            })
                                        }),
                                        instance('Frame', {
                                            Size = udim2(0, 2, 1, -4),
                                            Position = udim2(h, -1, 0, 2),
                                            BackgroundColor3 = rgb(255, 255, 255),
                                            BorderColor3 = rgb(0, 0, 0),
                                        })
                                    }, {
                                        function(self)
                                            local update
                                            
                                            self.MouseButton1Down:connect(function()
                                                local frame = self.Parent
                                                update = mouse.Move:connect(function()
                                                    local ap, as = frame.AbsolutePosition, frame.AbsoluteSize
                                                    if mouse.X < (ap.X + as.X) and mouse.X > ap.X then
                                                        h = scale(mouse.X, 0, 1, ap.X, (ap.X + as.X))

                                                        ts(self.Frame, {0.3, 'Quint'}, {
                                                            Position = udim2(scale(mouse.X, 0, 1, ap.X, (ap.X + as.X)), 0, 0, 2)
                                                        })
                                                    else
                                                        update:Disconnect()
                                                    end
                                                end)
                                            end)

                                            self.MouseButton1Up:connect(function()
                                                update:Disconnect()
                                            end)
                                        end
                                    }),
                                    instance('Frame', {
                                        Position = udim2(0, 10, 0, 218),
                                        Size = udim2(1, -20, 1, -262),
                                        BackgroundColor3 = Color3.fromHSV(h, s, v)
                                    }, {
                                        instance('UICorner', {
                                            CornerRadius = UDim.new(0, 3)
                                        }),
                                        instance('TextLabel', {
                                            Size = udim2(1, 0, 1, 0),
                                            TextSize = 12,
                                            Font = 'GothamBlack',
                                            Text = 'PREVIEW',
                                            TextTransparency = 0.5,
                                            TextColor3 = rgb(0, 0, 0),
                                            BackgroundTransparency = 1,
                                        })
                                    }, {
                                        function(self)
                                            spawn(function()
                                                while wait() do
                                                    ts(self, {0.3, 'Sine'}, {
                                                        BackgroundColor3 = Color3.fromHSV(h, s, v)
                                                    })
                                                end
                                            end)
                                        end
                                    }),
                                    instance('TextButton', {
                                        Position = udim2(0, 10, 1, -34),
                                        Size = udim2(1, -20, 0, 24),
                                        BackgroundColor3 = theme.passive,
                                        Text = 'Apply',
                                        TextSize = 12,
                                        Font = 'Gotham',
                                        TextColor3 = theme.text,
                                    }, {
                                        instance('UICorner', {
                                            CornerRadius = UDim.new(0, 3)
                                        })
                                    }, {
                                        function(self)
                                            self.MouseButton1Down:connect(function()
                                                smallPreview.BackgroundColor3 = Color3.fromHSV(h, s, v)
                                                delay(0.3, function()
                                                    ui.Visible = false
                                                end)
                                                toggled = false
                                                ts(ui, {0.3, 'Quint'}, {
                                                    Size = udim2(0, 0, 0, 300)
                                                })
                                                callback(Color3.fromHSV(h, s, v))
                                            end)
                                        end
                                    })
                                })
                            })

                            spawn(function()
                                while wait() do
                                    ts(ui, {0.3, 'Sine'}, {
                                        Position = udim2(0, main.AbsolutePosition.X + main.AbsoluteSize.X + 20, 0, main.AbsolutePosition.Y + 30)
                                    })
                                end
                            end)

                            self.MouseButton1Up:connect(function()
                                toggled = not toggled
                                if toggled then
                                    ui.Visible = true
                                else
                                    delay(0.3, function()
                                        ui.Visible = false
                                    end)
                                end

                                ts(ui, {0.3, 'Quint'}, {
                                    Size = toggled and udim2(0, 250, 0, 300) or udim2(0, 0, 0, 300)
                                })
                            end)
                        end
                    })
                })
            })                    
        end

        local function createDropdown(text, default, options, callback)
            local option = default or 'nil'

            local main;main = instance('Frame', {
                Parent = rParent,
                Size = udim2(1, 0, 0, 30),
                BackgroundColor3 = theme.accent,
                BackgroundTransparency = 0
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 5)
                }),
                instance('Frame', {
                    Size = udim2(1, -2, 1, -2),
                    Position = udim2(0, 1, 0, 1),
                    BackgroundColor3 = theme.background,
                    BackgroundTransparency = 0,
                    ClipsDescendants = true
                }, {
                    instance('UICorner', {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    instance('TextButton', {
                        Size = udim2(1, -8, 1, 0),
                        Position = udim2(0, 8, 0, 0),
                        Name = 'Text',
                        Text = tostring(text),
                        Font = 'Gotham',
                        BackgroundTransparency = 1,
                        TextSize = 12,
                        TextColor3 = theme.text,
                        TextXAlignment = 'Left',
                    }, {}, {
                        function(self)
                            local function setOption(opt)
                                option = opt
                                callback(opt)
                            end

                            local toggled = false

                            local ui;ui = instance('ScrollingFrame', {
                                Parent = sGui,
                                Size = udim2(0, 0, (#options - 10), 4),
                                BackgroundColor3 = theme.accent,
                                Visible = false,
                                BackgroundTransparency = 0.6,
                                ClipsDescendants = true
                            }, {
                                instance('UICorner', {
                                    CornerRadius = UDim.new(0, 10),
                                }),
                                instance('Frame', {
                                    Name = 'container',
                                    Size = udim2(1, -4, 1, -2),
                                    Position = udim2(0, 2, 0, 2),
                                    BackgroundColor3 = theme.background,
                                }, {
                                    instance('UICorner', {
                                        CornerRadius = UDim.new(0, 9),
                                    }),
                                    instance('TextLabel', {
                                        Size = udim2(1, 0, 0, 30),
                                        BackgroundTransparency = 1,
                                        Text = tostring(text),
                                        Font = 'GothamSemibold',
                                        TextSize = 14,
                                        TextColor3 = theme.text
                                    }),
                                    instance('Frame', {
                                        Size = udim2(1, 0, 1, -5),
                                        Position = udim2(0, 0, 0, 30),
                                        BackgroundTransparency = 1
                                    }, {
                                        instance('UIListLayout', {
                                            Padding = UDim.new(0, 3)
                                        })
                                    }, {
                                        function(self)
                                            local option_listing = {}

                                            local function add_option(name)
                                                option_listing[name] = true

                                                instance('Frame', {
                                                    Parent = self,
                                                    Size = udim2(1, 0, 0, 10),
                                                    BackgroundTransparency = 1,
                                                    Name = name
                                                }, {
                                                    instance('TextButton', {
                                                        Size = udim2(1, -6, 1, 0),
                                                        Position = udim2(0, 3, 0, 0),
                                                        BackgroundColor3 = theme.passive,
                                                        Font = 'Gotham',
                                                        TextSize = 11,
                                                        TextColor3 = theme.text,
                                                        Text = tostring(name),
                                                        ClipsDescendants = true
                                                    }, {
                                                        instance('UICorner', {
                                                            CornerRadius = UDim.new(0, 6)
                                                        })
                                                    }, {
                                                        function(self2)
                                                            self2.MouseButton1Up:connect(function()
                                                                delay(0.3, function()
                                                                    ui.Visible = false
                                                                end)
                                                                toggled = false
                                                                ts(ui, {0.3, 'Quint'}, {
                                                                    Size = udim2(0, 0, 0, (30 + 23 * #options + 1) + 4)
                                                                })
                                                                setOption(self2.Text)
                                                            end)
                                                        end
                                                    })
                                                })
                                            end

                                            local function remove_option(name)
                                                local f = self:FindFirstChild(name)

                                                if (f) then
                                                    f:Destroy()
                                                end

                                                option_listing[name] = false
                                            end

                                            task.spawn(function()
                                                local CoreGui = game:GetService("CoreGui")
                                                while (mainFrame:IsDescendantOf(CoreGui)) do
                                                    for _, value in next, options do
                                                        if (not option_listing[value]) then
                                                            add_option(value)
                                                        end
                                                    end

                                                    for name, boolean in next, option_listing do
                                                        if (boolean and typeof(table.find(options, name)) == "nil") then
                                                            remove_option(name)
                                                        end
                                                    end
                                                    task.wait(1)
                                                end
                                            end)
                                        end
                                    })
                                })
                            })

                            spawn(function()
                                while wait() do
                                    ts(ui, {0.3, 'Sine'}, {
                                        Position = udim2(0, main.AbsolutePosition.X + main.AbsoluteSize.X + 20, 0, main.AbsolutePosition.Y + 30)
                                    })
                                end
                            end)

                            self.MouseButton1Up:connect(function()
                                toggled = not toggled
                                if toggled then
                                    ui.Visible = true
                                else
                                    delay(0.3, function()
                                        ui.Visible = false
                                    end)
                                end

                                ts(ui, {0.3, 'Quint'}, {
                                    Size = toggled and udim2(0, 250, 0, (30 + 23 * #options + 1) + 4) or udim2(0, 0, 0, (30 + 23 * #options + 1) + 4)
                                })
                            end)
                        end
                    }),
                    instance('Frame', {
                        BackgroundColor3 = theme.passive,
                    }, {
                        instance('Frame', {
                            Size = udim2(1, -2, 1, -2),
                            Position = udim2(0, 1, 0, 1),
                            BackgroundColor3 = theme.background
                        }, {
                            instance('UICorner', {
                                CornerRadius = UDim.new(0, 3)
                            })
                        }),
                        instance('UICorner', {
                            CornerRadius = UDim.new(0, 4),
                        }),
                        instance('TextLabel', {
                            Text = option,
                            Font = 'Gotham',
                            TextSize = 12,
                            BackgroundTransparency = 1,
                            Size = udim2(1, 0, 1, 0),
                            TextColor3 = theme.text
                        }, {}, {
                            function(self)
                                spawn(function()
                                    while wait(0.1) do
                                        pcall(function()
                                            self.Text = option

                                            local size = game:service('TextService'):GetTextSize(self.Text, 12, 'Gotham', Vector2.new(math.huge, math.huge))
    
                                            ts(self.Parent, {0.1, 'Quint'}, {
                                                Position = udim2(1, -((size.X + 8) + 4), 0, 4),
                                                Size = udim2(0, (size.X + 8), 0, 20)
                                            })
                                        end)
                                    end
                                end)
                            end
                        })
                    })
                })
            })
        end

        for a,v in next, objects do
            if typeof(v.type) == 'string' then
                if v.type:lower() == 'button' then
                    v.text = tostring(v.text); v.callback = (typeof(v.callback) == 'function') and v.callback or function() end
                    createButton(v.text, v.callback)
                elseif v.type:lower() == 'toggle' then
                    v.text = tostring(v.text); v.state = (typeof(v.state) == 'boolean') and v.state or false; v.callback = (typeof(v.callback) == 'function') and v.callback or function() end
                    createToggle(v.text, v.state, v.callback)
                elseif v.type:lower() == 'textbox' then
                    v.text = tostring(v.text); v.placeholder = (typeof(v.placeholder) == 'string') and v.placeholder or ''; v.numbersOnly = (typeof(v.numbersOnly) == 'boolean') and v.numbersOnly or false; v.callback = (typeof(v.callback) == 'function') and v.callback or function() end
                    createTextBox(v.text, v.placeholder, v.numbersOnly, v.callback)
                elseif v.type:lower() == 'keybind' then
                    v.text = tostring(v.text); v.callback = (typeof(v.callback) == 'function') and v.callback or function() end; v.newCallback = (typeof(v.newCallback) == 'function') and v.newCallback or function() end
                    createKeybind(v.text, v.default, v.callback, v.newCallback)
                elseif v.type:lower() == 'slider' then
                    v.text = tostring(v.text); if typeof(v.min) ~= 'number' then return error('"min" must be a number') elseif typeof(v.max) ~= 'number' then return error('"max" must be a number') end; v.default = ((typeof(v.default) == 'number') and (v.default > v.min)) and v.default or v.min; v.float = (typeof(v.float) == 'number') and v.float or 1; v.callback = (typeof(v.callback) == 'function') and v.callback or function() end
                    createSlider(v.text, v.default, v.min, v.max, v.float, v.callback)
                elseif v.type:lower() == 'colorpicker' then
                    v.text = tostring(v.text); v.default = (typeof(v.default) == 'Color3') and v.default or Color3.new(1, 1, 1); v.callback = (typeof(v.callback) == 'function') and v.callback or function() end
                    createColorPicker(v.text, v.default, v.callback)
                elseif v.type:lower() == 'dropdown' then
                    v.text = tostring(v.text); v.default = (typeof(v.default) == 'string') and v.default or '[unset]'; v.options = (typeof(v.options) == 'table') and v.options or {}; v.callback = (typeof(v.callback) == 'function') and v.callback or function() end
                    createDropdown(v.text, v.default, v.options, v.callback)
                end
            end
        end
    end

    for a,v in next, data.Tabs do
        createTabWindow(v.TabName, v.TabObjects)
    end
end

-- getgenv().getlibrary = true
-- getgenv().library = library

return library