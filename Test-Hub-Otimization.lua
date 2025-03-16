local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local PhysicsService = game:GetService("PhysicsService")
local RenderSettings = game:GetService("RenderSettings")
local SoundService = game:GetService("SoundService")
local NetworkSettings = game:GetService("NetworkSettings")
local TextureManager = game:GetService("TextureManager")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local MemoryManager = game:GetService("MemoryManager")

-- Configurações Atualizadas 2025
local Config = {
    Version = "4.0",
    IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
    Assets = {
        Icons = {
            Menu = "rbxassetid://14433434359", -- Menu icon 2025
            Close = "rbxassetid://14433434412", -- Close icon 2025
            Performance = "rbxassetid://14433434478", -- Performance icon 2025
            Memory = "rbxassetid://14433434523", -- Memory icon 2025
            Network = "rbxassetid://14433434567", -- Network icon 2025
            Graphics = "rbxassetid://14433434612" -- Graphics icon 2025
        },
        UI = {
            Background = "rbxassetid://14433434698", -- Modern UI background 2025
            Border = "rbxassetid://14433434745", -- Modern border 2025
            Shadow = "rbxassetid://14433434789" -- Dynamic shadow 2025
        }
    },
    Performance = {
        MaxFPS = 240, -- Atualizado para monitores modernos
        MinFPS = 30,
        TargetMemoryUsage = 512, -- MB
        NetworkLatencyThreshold = 100, -- ms
        AutoScaleQuality = true,
        EnableDynamicLOD = true,
        UseGPUAcceleration = true,
        EnableThreading = true,
        BatchSize = 512,
        CacheSize = 256,
        TextureCompressionLevel = 3,
        PhysicsSteps = 60,
        NetworkUpdateRate = 60
    }
}

-- Sistema de Otimização Avançado 2025
local OptimizationEngine = {
    -- Otimizações de Renderização
    RenderOptimizations = {
        EnableMeshReduction = function(level)
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("MeshPart") then
                    obj.RenderFidelity = level
                    obj.CollisionFidelity = level
                end
            end
        end,
        
        SetLODDistance = function(distance)
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.LODDistance = distance
                end
            end
        end,
        
        OptimizeTextures = function(quality)
            TextureManager.TextureQuality = quality
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.CompressLevel = Config.Performance.TextureCompressionLevel
                end
            end
        end,
        
        DisableUnusedEffects = function()
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") then
                    effect.Enabled = false
                end
            end
        end
    },

    -- Otimizações de Memória
    MemoryOptimizations = {
        EnableMemoryManagement = function()
            MemoryManager.AutomaticMemoryManagement = true
            MemoryManager.MemoryUsageTarget = Config.Performance.TargetMemoryUsage
        end,
        
        ClearUnusedAssets = function()
            ContentProvider:PreloadAsync({})
            game:GetService("Debris"):AddItem(Instance.new("Folder"), 0)
            collectgarbage("collect")
        end,
        
        OptimizeInstances = function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Massless = true
                    obj.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0, 0, 0, 0)
                end
            end
        end
    },

    -- Otimizações de Rede
    NetworkOptimizations = {
        OptimizeReplication = function()
            NetworkSettings.IncomingReplicationLag = 0
            NetworkSettings.SerializationCompression = true
            NetworkSettings.PacketOptimization = true
        end,
        
        SetupNetworkBoundaries = function()
            for _, player in ipairs(Players:GetPlayers()) do
                NetworkSettings:SetPlayerBoundaries(player, {
                    MaxDataRate = 1024 * 1024, -- 1MB/s
                    MaxPacketSize = 1024,
                    CompressionLevel = 9
                })
            end
        end,
        
        EnableStreamingOptimization = function()
            workspace.StreamingEnabled = true
            workspace.StreamingMinRadius = 64
            workspace.StreamingTargetRadius = 1024
        end
    },

    -- Otimizações de Física
    PhysicsOptimizations = {
        OptimizePhysics = function()
            PhysicsService.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Enabled
            PhysicsService.AllowSleep = true
            PhysicsService.PhysicsSteppingMethod = Enum.PhysicsSteppingMethod.Adaptive
        end,
        
        SetupCollisionGroups = function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    PhysicsService:SetPartCollisionGroup(obj, "OptimizedCollision")
                end
            end
        end
    }
}

-- Sistema de Monitoramento de Performance em Tempo Real
local PerformanceMonitor = {
    Stats = {
        FPS = {},
        Memory = {},
        Network = {},
        Physics = {},
        Rendering = {}
    },
    
    Thresholds = {
        FPS = {
            Critical = 20,
            Warning = 30,
            Good = 60
        },
        Memory = {
            Critical = 900, -- MB
            Warning = 700,
            Good = 500
        },
        Network = {
            Critical = 200, -- ms
            Warning = 100,
            Good = 50
        }
    },
    
    StartMonitoring = function(self)
        -- Monitor FPS
        RunService.RenderStepped:Connect(function(deltaTime)
            local fps = math.floor(1/deltaTime)
            table.insert(self.Stats.FPS, fps)
            if #self.Stats.FPS > 60 then
                table.remove(self.Stats.FPS, 1)
            end
            
            -- Auto-otimização baseada em FPS
            if self:GetAverageFPS() < self.Thresholds.FPS.Warning then
                OptimizationEngine.RenderOptimizations.EnableMeshReduction(3)
                OptimizationEngine.RenderOptimizations.SetLODDistance(100)
            end
        end)
        
        -- Monitor de Memória
        spawn(function()
            while wait(1) do
                local memoryUsage = math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())
                table.insert(self.Stats.Memory, memoryUsage)
                if #self.Stats.Memory > 60 then
                    table.remove(self.Stats.Memory, 1)
                end
                
                -- Auto-otimização baseada em memória
                if memoryUsage > self.Thresholds.Memory.Warning then
                    OptimizationEngine.MemoryOptimizations.ClearUnusedAssets()
                end
            end
        end)
        
        -- Monitor de Rede
        spawn(function()
            while wait(1) do
                local ping = math.floor(Players.LocalPlayer:GetNetworkPing() * 1000)
                table.insert(self.Stats.Network, ping)
                if #self.Stats.Network > 60 then
                    table.remove(self.Stats.Network, 1)
                end
                
                -- Auto-otimização baseada em rede
                if ping > self.Thresholds.Network.Warning then
                    OptimizationEngine.NetworkOptimizations.OptimizeReplication()
                end
            end
        end)
        
        -- Monitor de Física
        spawn(function()
            while wait(1) do
                local physicsTime = game:GetService("Stats").PhysicsStepTime
                table.insert(self.Stats.Physics, physicsTime)
                if #self.Stats.Physics > 60 then
                    table.remove(self.Stats.Physics, 1)
                end
                
                -- Auto-otimização baseada em física
                if physicsTime > 0.016 then -- Mais de 16ms por frame
                    OptimizationEngine.PhysicsOptimizations.OptimizePhysics()
                end
            end
        end)
        
        -- Monitor de Renderização
        spawn(function()
            while wait(1) do
                local renderTime = game:GetService("Stats").RenderStepTime
                table.insert(self.Stats.Rendering, renderTime)
                if #self.Stats.Rendering > 60 then
                    table.remove(self.Stats.Rendering, 1)
                end
            end
        end)
    end,
    
    GetAverageFPS = function(self)
        local sum = 0
        for _, fps in ipairs(self.Stats.FPS) do
            sum = sum + fps
        end
        return math.floor(sum / #self.Stats.FPS)
    end,
    
    GetAverageMemory = function(self)
        local sum = 0
        for _, mem in ipairs(self.Stats.Memory) do
            sum = sum + mem
        end
        return math.floor(sum / #self.Stats.Memory)
    end,
    
    GetAveragePing = function(self)
        local sum = 0
        for _, ping in ipairs(self.Stats.Network) do
            sum = sum + ping
        end
        return math.floor(sum / #self.Stats.Network)
    end,
    
    GenerateReport = function(self)
        return {
            fps = {
                current = self.Stats.FPS[#self.Stats.FPS],
                average = self:GetAverageFPS(),
                status = self:GetAverageFPS() > self.Thresholds.FPS.Good and "Good" or 
                        self:GetAverageFPS() > self.Thresholds.FPS.Warning and "Warning" or "Critical"
            },
            memory = {
                current = self.Stats.Memory[#self.Stats.Memory],
                average = self:GetAverageMemory(),
                status = self:GetAverageMemory() < self.Thresholds.Memory.Good and "Good" or 
                        self:GetAverageMemory() < self.Thresholds.Memory.Warning and "Warning" or "Critical"
            },
            network = {
                current = self.Stats.Network[#self.Stats.Network],
                average = self:GetAveragePing(),
                status = self:GetAveragePing() < self.Thresholds.Network.Good and "Good" or 
                        self:GetAveragePing() < self.Thresholds.Network.Warning and "Warning" or "Critical"
            },
            physics = {
                current = self.Stats.Physics[#self.Stats.Physics],
                average = math.floor(mean(self.Stats.Physics) * 1000),
            },
            rendering = {
                current = self.Stats.Rendering[#self.Stats.Rendering],
                average = math.floor(mean(self.Stats.Rendering) * 1000),
            }
        }
    end
}

-- Sistema de Cache Inteligente
local CacheSystem = {
    TextureCache = {},
    MeshCache = {},
    SoundCache = {},
    
    InitializeCache = function(self)
        game:GetService("ContentProvider").PreloadAsync = function(...)
            local assets = {...}
            for _, asset in ipairs(assets) do
                if asset:IsA("Texture") then
                    self.TextureCache[asset.Id] = true
                elseif asset:IsA("MeshPart") then
                    self.MeshCache[asset.MeshId] = true
                elseif asset:IsA("Sound") then
                    self.SoundCache[asset.SoundId] = true
                end
            end
        end
    end,
    
    CleanCache = function(self)
        local function cleanTable(tbl)
            for k, v in pairs(tbl) do
                if not game:GetService("ContentProvider"):IsAssetCached(k) then
                    tbl[k] = nil
                end
            end
        end
        
        cleanTable(self.TextureCache)
        cleanTable(self.MeshCache)
        cleanTable(self.SoundCache)
    end,
    
    PreloadCommonAssets = function(self)
        local commonAssets = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("MeshPart") or obj:IsA("Sound") then
                table.insert(commonAssets, obj)
            end
        end
        game:GetService("ContentProvider"):PreloadAsync(commonAssets)
    end
}

-- Sistema de Otimização de Áudio
local AudioOptimizer = {
    Settings = {
        MaxConcurrentSounds = 16,
        MaxDistance = 1000,
        MinDistance = 10,
        RolloffScale = 2,
        DopplerScale = 0.5,
        MaxQuality = 2, -- 0 = Low, 1 = Medium, 2 = High
        EnableDistanceOptimization = true,
        EnableDynamicAudioQuality = true
    },

    Initialize = function(self)
        SoundService.RespectFilteringEnabled = true
        SoundService.DistanceFactor = 100
        SoundService.DopplerScale = self.Settings.DopplerScale
        SoundService.RolloffScale = self.Settings.RolloffScale
        
        -- Configurar grupos de áudio
        local groups = {
            {name = "Effects", volume = 0.8},
            {name = "Music", volume = 0.5},
            {name = "Ambient", volume = 0.3},
            {name = "UI", volume = 1}
        }
        
        for _, group in ipairs(groups) do
            local soundGroup = Instance.new("SoundGroup")
            soundGroup.Name = group.name
            soundGroup.Volume = group.volume
            soundGroup.Parent = SoundService
        end
    end,

    OptimizeSound = function(self, sound)
        if not sound:IsA("Sound") then return end
        
        -- Configurações básicas
        sound.RollOffMode = Enum.RollOffMode.InverseTapered
        sound.RollOffMaxDistance = self.Settings.MaxDistance
        sound.RollOffMinDistance = self.Settings.MinDistance
        
        -- Otimização baseada na distância
        if self.Settings.EnableDistanceOptimization then
            local function updateSoundQuality()
                local character = Players.LocalPlayer.Character
                if not character then return end
                
                local distance = (character.PrimaryPart.Position - sound.Parent.Position).Magnitude
                if distance > self.Settings.MaxDistance then
                    sound.Volume = 0
                else
                    sound.Volume = math.clamp(1 - (distance/self.Settings.MaxDistance), 0, 1)
                end
            end
            
            RunService.Heartbeat:Connect(updateSoundQuality)
        end
        
        -- Qualidade dinâmica
        if self.Settings.EnableDynamicAudioQuality then
            sound:SetAttribute("OriginalQuality", sound.PlaybackQuality)
            
            local function updateQuality()
                local fps = PerformanceMonitor:GetAverageFPS()
                if fps < 30 then
                    sound.PlaybackQuality = 0 -- Low
                elseif fps < 60 then
                    sound.PlaybackQuality = 1 -- Medium
                else
                    sound.PlaybackQuality = self.Settings.MaxQuality
                end
            end
            
            RunService.Heartbeat:Connect(updateQuality)
        end
    end,

    OptimizeAllSounds = function(self)
        for _, sound in ipairs(game:GetDescendants()) do
            if sound:IsA("Sound") then
                self:OptimizeSound(sound)
            end
        end
        
        game.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("Sound") then
                self:OptimizeSound(descendant)
            end
        end)
    end
}

-- Interface Gráfica Moderna (GUI)
local Interface = {
    Elements = {},
    Theme = {
        Primary = Color3.fromRGB(147, 112, 219),
        Secondary = Color3.fromRGB(30, 30, 35),
        Background = Color3.fromRGB(20, 20, 25),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(200, 200, 200),
        Success = Color3.fromRGB(50, 255, 50),
        Warning = Color3.fromRGB(255, 255, 50),
        Error = Color3.fromRGB(255, 50, 50),
        Highlight = Color3.fromRGB(160, 125, 230)
    },
    
    CreateMainWindow = function(self)
        local gui = Instance.new("ScreenGui")
        gui.Name = "OptimizationHub"
        gui.ResetOnSpawn = false
        
        -- Proteção da GUI
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
        
        -- Frame Principal
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = Config.IsMobile and 
            UDim2.new(0.9, 0, 0.8, 0) or 
            UDim2.new(0, 500, 0, 600)
        mainFrame.Position = Config.IsMobile and
            UDim2.new(0.05, 0, 0.1, 0) or
            UDim2.new(0.5, -250, 0.5, -300)
        mainFrame.BackgroundColor3 = self.Theme.Background
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = gui
        
        -- Efeito de Sombra
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Size = UDim2.new(1, 40, 1, 40)
        shadow.Position = UDim2.new(0, -20, 0, -20)
        shadow.BackgroundTransparency = 1
        shadow.Image = Config.Assets.UI.Shadow
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.6
        shadow.Parent = mainFrame
        
        -- Barra Superior
        local topBar = Instance.new("Frame")
        topBar.Name = "TopBar"
        topBar.Size = UDim2.new(1, 0, 0, 40)
        topBar.BackgroundColor3 = self.Theme.Primary
        topBar.BorderSizePixel = 0
        topBar.Parent = mainFrame
        
        -- Título
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -100, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "Optimization Hub v" .. Config.Version
        title.TextColor3 = self.Theme.Text
        title.TextSize = Config.IsMobile and 22 or 18
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = topBar
        
        -- Container de Conteúdo
        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Name = "Content"
        contentFrame.Size = UDim2.new(1, -20, 1, -60)
        contentFrame.Position = UDim2.new(0, 10, 0, 50)
        contentFrame.BackgroundTransparency = 1
        contentFrame.ScrollBarThickness = Config.IsMobile and 8 or 4
        contentFrame.Parent = mainFrame
        
        self.Elements.MainFrame = mainFrame
        self.Elements.ContentFrame = contentFrame
        
        return gui
    end,
    
    CreateCategory = function(self, name, icon)
        local category = Instance.new("Frame")
        category.Name = name
        category.Size = UDim2.new(1, 0, 0, 30)
        category.BackgroundColor3 = self.Theme.Secondary
        category.BorderSizePixel = 0
        
        local iconLabel = Instance.new("ImageLabel")
        iconLabel.Size = UDim2.new(0, 20, 0, 20)
        iconLabel.Position = UDim2.new(0, 5, 0.5, -10)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Image = icon
        iconLabel.Parent = category
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -30, 1, 0)
        titleLabel.Position = UDim2.new(0, 30, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = name
        titleLabel.TextColor3 = self.Theme.Text
        titleLabel.TextSize = Config.IsMobile and 18 or 14
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = category
        
        return category
    end
}

-- Sistema de Perfis de Otimização
local OptimizationProfiles = {
    Profiles = {
        Ultra = {
            name = "Ultra Performance",
            description = "Máxima performance, mínima qualidade visual",
            settings = {
                graphics = {
                    QualityLevel = 1,
                    MeshDetail = 0,
                    TextureQuality = 0,
                    ShadowQuality = 0,
                    PostProcessing = false,
                    Particles = false
                },
                physics = {
                    PhysicsLevel = 1,
                    SimulationRadius = 100,
                    SleepThreshold = 0.1
                },
                memory = {
                    TextureCache = 64,
                    MeshCache = 32,
                    InstanceCache = 128
                },
                network = {
                    UpdateRate = 30,
                    CompressionLevel = 3,
                    StreamingEnabled = true
                },
                audio = {
                    Quality = 0,
                    MaxConcurrentSounds = 8,
                    DistanceFactor = 0.5
                }
            }
        },
        High = {
            name = "High Performance",
            description = "Boa performance com qualidade visual aceitável",
            settings = {
                graphics = {
                    QualityLevel = 3,
                    MeshDetail = 2,
                    TextureQuality = 1,
                    ShadowQuality = 1,
                    PostProcessing = true,
                    Particles = true
                },
                physics = {
                    PhysicsLevel = 2,
                    SimulationRadius = 250,
                    SleepThreshold = 0.5
                },
                memory = {
                    TextureCache = 256,
                    MeshCache = 128,
                    InstanceCache = 512
                },
                network = {
                    UpdateRate = 60,
                    CompressionLevel = 2,
                    StreamingEnabled = true
                },
                audio = {
                    Quality = 1,
                    MaxConcurrentSounds = 16,
                    DistanceFactor = 1
                }
            }
        },
        Balanced = {
            name = "Balanced",
            description = "Equilíbrio entre performance e qualidade",
            settings = {
                graphics = {
                    QualityLevel = 5,
                    MeshDetail = 3,
                    TextureQuality = 2,
                    ShadowQuality = 2,
                    PostProcessing = true,
                    Particles = true
                },
                physics = {
                    PhysicsLevel = 3,
                    SimulationRadius = 500,
                    SleepThreshold = 1
                },
                memory = {
                    TextureCache = 512,
                    MeshCache = 256,
                    InstanceCache = 1024
                },
                network = {
                    UpdateRate = 60,
                    CompressionLevel = 1,
                    StreamingEnabled = true
                },
                audio = {
                    Quality = 2,
                    MaxConcurrentSounds = 32,
                    DistanceFactor = 1.5
                }
            }
        }
    },

    ApplyProfile = function(self, profileName)
        local profile = self.Profiles[profileName]
        if not profile then return end

        -- Aplicar configurações gráficas
        settings().Rendering.QualityLevel = profile.settings.graphics.QualityLevel
        OptimizationEngine.RenderOptimizations.EnableMeshReduction(profile.settings.graphics.MeshDetail)
        OptimizationEngine.RenderOptimizations.OptimizeTextures(profile.settings.graphics.TextureQuality)
        
        -- Configurar sombras e pós-processamento
        Lighting.GlobalShadows = profile.settings.graphics.ShadowQuality > 0
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = profile.settings.graphics.PostProcessing
            end
        end

        -- Configurar física
        PhysicsService.PhysicsThrottle = profile.settings.physics.PhysicsLevel
        workspace.PhysicsSimulationRate = profile.settings.physics.SimulationRadius
        
        -- Configurar memória
        ContentProvider.RequestQueueSize = profile.settings.memory.InstanceCache
        settings().Rendering.MeshCacheSize = profile.settings.memory.MeshCache
        settings().Rendering.TextureCacheSize = profile.settings.memory.TextureCache
        
        -- Configurar rede
        NetworkSettings.IncomingReplicationLag = 1000 / profile.settings.network.UpdateRate
        NetworkSettings.DataCompressionLevel = profile.settings.network.CompressionLevel
        workspace.StreamingEnabled = profile.settings.network.StreamingEnabled
        
        -- Configurar áudio
        SoundService.RespectFilteringEnabled = true
        SoundService.DopplerScale = profile.settings.audio.DistanceFactor
        AudioOptimizer.Settings.MaxConcurrentSounds = profile.settings.audio.MaxConcurrentSounds
        AudioOptimizer.Settings.MaxQuality = profile.settings.audio.Quality
    end
}

-- Sistema de Diagnóstico
local DiagnosticSystem = {
    Tests = {
        Graphics = {
            RunTest = function()
                local results = {
                    fps = PerformanceMonitor:GetAverageFPS(),
                    renderTime = game:GetService("Stats").RenderStepTime,
                    meshCount = 0,
                    textureMemory = 0,
                    particleCount = 0
                }
                
                -- Contar meshes e partículas
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("MeshPart") then
                        results.meshCount = results.meshCount + 1
                    elseif obj:IsA("ParticleEmitter") then
                        results.particleCount = results.particleCount + 1
                    end
                end
                
                -- Calcular memória de texturas
                results.textureMemory = game:GetService("Stats"):GetMemoryUsageMbForTag("Textures")
                
                return results
            end
        },
        
        Memory = {
            RunTest = function()
                return {
                    total = game:GetService("Stats"):GetTotalMemoryUsageMb(),
                    textures = game:GetService("Stats"):GetMemoryUsageMbForTag("Textures"),
                    instances = game:GetService("Stats"):GetMemoryUsageMbForTag("Instances"),
                    signals = game:GetService("Stats"):GetMemoryUsageMbForTag("Signals"),
                    luaHeap = collectgarbage("count") / 1024
                }
            end
        },
        
        Network = {
            RunTest = function()
                return {
                    ping = Players.LocalPlayer:GetNetworkPing() * 1000,
                    incomingKbps = NetworkSettings.IncomingKbps,
                    outgoingKbps = NetworkSettings.OutgoingKbps,
                    serverTickRate = 1 / RunService.Heartbeat:Wait()
                }
            end
        },
        
        Physics = {
            RunTest = function()
                return {
                    stepTime = game:GetService("Stats").PhysicsStepTime,
                    simulating = workspace:GetRealPhysicsFPS(),
                    contacts = game:GetService("Stats"):GetPhysicsContactsCount(),
                    parts = workspace:GetNumAwakeParts()
                }
            end
        }
    },
    
    RunFullDiagnostic = function(self)
        local report = {
            timestamp = os.time(),
            platform = {
                isMobile = Config.IsMobile,
                processor = game:GetService("Stats").processorType,
                gpu = game:GetService("Stats").graphicsCard
            },
            tests = {}
        }
        
        for name, test in pairs(self.Tests) do
            report.tests[name] = test.RunTest()
        end
        
        return report
    end,
    
    AnalyzeResults = function(self, report)
        local recommendations = {}
        
        -- Análise gráfica
        if report.tests.Graphics.fps < 30 then
            table.insert(recommendations, {
                priority = "High",
                category = "Graphics",
                message = "FPS baixo detectado. Considere reduzir a qualidade gráfica.",
                action = function()
                    OptimizationProfiles:ApplyProfile("Ultra")
                end
            })
        end
        
        -- Análise de memória
        if report.tests.Memory.total > 800 then
            table.insert(recommendations, {
                priority = "High",
                category = "Memory",
                message = "Alto uso de memória detectado. Limpeza recomendada.",
                action = function()
                    OptimizationEngine.MemoryOptimizations.ClearUnusedAssets()
                end
            })
        end
        
        -- Análise de rede
        if report.tests.Network.ping > 150 then
            table.insert(recommendations, {
                priority = "Medium",
                category = "Network",
                message = "Latência alta detectada. Otimizando configurações de rede.",
                action = function()
                    OptimizationEngine.NetworkOptimizations.OptimizeReplication()
                end
            })
        end
        
        return recommendations
    end
}

-- Controles da Interface
local InterfaceControls = {
    Elements = {},
    
    CreateToggle = function(self, parent, text, description, callback)
        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(1, 0, 0, 60)
        toggle.BackgroundColor3 = Interface.Theme.Secondary
        toggle.BorderSizePixel = 0
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 40, 0, 24)
        button.Position = UDim2.new(1, -50, 0.5, -12)
        button.BackgroundColor3 = Interface.Theme.Primary
        button.Text = ""
        button.Parent = toggle
        
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1, 0)
        uiCorner.Parent = button
        
        local switchKnob = Instance.new("Frame")
        switchKnob.Size = UDim2.new(0, 20, 0, 20)
        switchKnob.Position = UDim2.new(0, 2, 0.5, -10)
        switchKnob.BackgroundColor3 = Interface.Theme.Text
        switchKnob.Parent = button
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = switchKnob
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -70, 0, 20)
        title.Position = UDim2.new(0, 10, 0, 10)
        title.BackgroundTransparency = 1
        title.Text = text
        title.TextColor3 = Interface.Theme.Text
        title.TextSize = Config.IsMobile and 16 or 14
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = toggle
        
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -70, 0, 20)
        desc.Position = UDim2.new(0, 10, 0, 30)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Interface.Theme.TextDim
        desc.TextSize = Config.IsMobile and 14 or 12
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = toggle
        
        local enabled = false
        button.MouseButton1Click:Connect(function()
            enabled = not enabled
            local targetPos = enabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            local targetColor = enabled and Interface.Theme.Success or Interface.Theme.Primary
            
            game:GetService("TweenService"):Create(switchKnob, 
                TweenInfo.new(0.2), 
                {Position = targetPos}):Play()
            
            game:GetService("TweenService"):Create(button,
                TweenInfo.new(0.2),
                {BackgroundColor3 = targetColor}):Play()
                
            callback(enabled)
        end)
        
        return toggle
    end,
    
    CreateSlider = function(self, parent, text, min, max, default, callback)
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 70)
        slider.BackgroundColor3 = Interface.Theme.Secondary
        slider.BorderSizePixel = 0
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 20)
        title.Position = UDim2.new(0, 10, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = text
        title.TextColor3 = Interface.Theme.Text
        title.TextSize = Config.IsMobile and 16 or 14
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = slider
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 50, 0, 20)
        valueLabel.Position = UDim2.new(1, -60, 0, 5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Interface.Theme.TextDim
        valueLabel.TextSize = Config.IsMobile and 16 or 14
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.Parent = slider
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Size = UDim2.new(1, -20, 0, 6)
        sliderBar.Position = UDim2.new(0, 10, 0, 40)
        sliderBar.BackgroundColor3 = Interface.Theme.Background
        sliderBar.BorderSizePixel = 0
        sliderBar.Parent = slider
        
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1, 0)
        uiCorner.Parent = sliderBar
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
        fill.BackgroundColor3 = Interface.Theme.Primary
        fill.BorderSizePixel = 0
        fill.Parent = sliderBar
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill
        
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new((default - min)/(max - min), -8, 0.5, -8)
        knob.BackgroundColor3 = Interface.Theme.Text
        knob.Text = ""
        knob.Parent = sliderBar
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob
        
        local dragging = false
        
        local function updateSlider(input)
            local pos = math.clamp(
                (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X,
                0,
                1
            )
            
            local value = math.floor(min + (max - min) * pos)
            valueLabel.Text = tostring(value)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -8, 0.5, -8)
            
            callback(value)
        end
        
        knob.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        return slider
    end,
    
    CreateDropdown = function(self, parent, text, options, callback)
        local dropdown = Instance.new("Frame")
        dropdown.Size = UDim2.new(1, 0, 0, 40)
        dropdown.BackgroundColor3 = Interface.Theme.Secondary
        dropdown.BorderSizePixel = 0
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -20, 1, -10)
        button.Position = UDim2.new(0, 10, 0, 5)
        button.BackgroundColor3 = Interface.Theme.Background
        button.Text = text
        button.TextColor3 = Interface.Theme.Text
        button.TextSize = Config.IsMobile and 16 or 14
        button.Font = Enum.Font.GothamBold
        button.Parent = dropdown
        
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 6)
        uiCorner.Parent = button
        
        local optionsFrame = Instance.new("Frame")
        optionsFrame.Size = UDim2.new(1, -20, 0, #options * 30)
        optionsFrame.Position = UDim2.new(0, 10, 1, 5)
        optionsFrame.BackgroundColor3 = Interface.Theme.Background
        optionsFrame.BorderSizePixel = 0
        optionsFrame.Visible = false
        optionsFrame.ZIndex = 2
        optionsFrame.Parent = dropdown
        
        local optionsCorner = Instance.new("UICorner")
        optionsCorner.CornerRadius = UDim.new(0, 6)
        optionsCorner.Parent = optionsFrame
        
        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 30)
            optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
            optionButton.BackgroundTransparency = 1
            optionButton.Text = option
            optionButton.TextColor3 = Interface.Theme.Text
            optionButton.TextSize = Config.IsMobile and 14 or 12
            optionButton.Font = Enum.Font.Gotham
            optionButton.ZIndex = 2
            optionButton.Parent = optionsFrame
            
            optionButton.MouseButton1Click:Connect(function()
                button.Text = option
                optionsFrame.Visible = false
                callback(option)
            end)
        end
        
        button.MouseButton1Click:Connect(function()
            optionsFrame.Visible = not optionsFrame.Visible
        end)
        
        return dropdown
    end
}

-- Sistema de Inicialização
local function Initialize()
    -- Inicializar sistemas
    PerformanceMonitor:StartMonitoring()
    AudioOptimizer:Initialize()
    CacheSystem:InitializeCache()
    
    -- Criar interface
    local gui = Interface:CreateMainWindow()
    
    -- Criar categorias
    local categories = {
        {name = "Performance", icon = Config.Assets.Icons.Performance},
        {name = "Graphics", icon = Config.Assets.Icons.Graphics},
        {name = "Network", icon = Config.Assets.Icons.Network},
        {name = "Memory", icon = Config.Assets.Icons.Memory}
    }
    
    local yOffset = 0
    for _, category in ipairs(categories) do
        local categoryFrame = Interface:CreateCategory(category.name, category.icon)
        categoryFrame.Position = UDim2.new(0, 0, 0, yOffset)
        categoryFrame.Parent = Interface.Elements.ContentFrame
        yOffset = yOffset + 40
        
        -- Adicionar controles específicos para cada categoria
        if category.name == "Performance" then
            -- Perfis de otimização
            local profileDropdown = InterfaceControls:CreateDropdown(
                categoryFrame,
                "Optimization Profile",
                {"Ultra", "High", "Balanced"},
                function(profile)
                    OptimizationProfiles:ApplyProfile(profile)
                end
            )
            profileDropdown.Position = UDim2.new(0, 0, 0, yOffset)
            profileDropdown.Parent = Interface.Elements.ContentFrame
            yOffset = yOffset + 50
        end
        
        if category.name == "Graphics" then
            -- Controles gráficos
            local qualitySlider = InterfaceControls:CreateSlider(
                categoryFrame,
                "Graphics Quality",
                1,
                10,
                5,
                function(value)
                    settings().Rendering.QualityLevel = value
                end
            )
            qualitySlider.Position = UDim2.new(0, 0, 0, yOffset)
            qualitySlider.Parent = Interface.Elements.ContentFrame
            yOffset = yOffset + 80
            
            local shadowsToggle = InterfaceControls:CreateToggle(
                categoryFrame,
                "Shadows",
                "Enable real-time shadows",
                function(enabled)
                    Lighting.GlobalShadows = enabled
                end
            )
            shadowsToggle.Position = UDim2.new(0, 0, 0, yOffset)
            shadowsToggle.Parent = Interface.Elements.ContentFrame
            yOffset = yOffset + 70
        end
    end
    
    -- Iniciar diagnóstico automático
    spawn(function()
        while wait(30) do
            local report = DiagnosticSystem:RunFullDiagnostic()
            local recommendations = DiagnosticSystem:AnalyzeResults(report)
            
            for _, recommendation in ipairs(recommendations) do
                if recommendation.priority == "High" then
                    recommendation.action()
                end
            end
        end
    end)
    
    -- Retornar GUI
    return gui
end

-- Executar inicialização
local success, result = pcall(Initialize)
if not success then
    warn("Erro na inicialização:", result)
end
