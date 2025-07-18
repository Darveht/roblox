
-- Squid Game Math Classroom Game
-- Game configuration
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Game variables
local GameManager = {}
GameManager.MaxPlayers = 35
GameManager.TotalQuestions = 100
GameManager.CurrentQuestion = 1
GameManager.QuestionTime = 30 -- seconds per question
GameManager.GameActive = false
GameManager.Players = {}
GameManager.Desks = {}
GameManager.Blackboard = nil
GameManager.RegisteredStudents = {
    Aula1 = {},
    Aula2 = {}
}

-- Math API simulation
local MathAPI = {}
function MathAPI:GenerateQuestion()
    local operations = {"+", "-", "*", "/"}
    local operation = operations[math.random(1, #operations)]
    local num1 = math.random(1, 100)
    local num2 = math.random(1, 100)
    
    -- Ensure division results in whole numbers
    if operation == "/" then
        num2 = math.random(1, 10)
        num1 = num1 * num2
    end
    
    local question = num1 .. " " .. operation .. " " .. num2
    local answer
    
    if operation == "+" then
        answer = num1 + num2
    elseif operation == "-" then
        answer = num1 - num2
    elseif operation == "*" then
        answer = num1 * num2
    elseif operation == "/" then
        answer = num1 / num2
    end
    
    return {
        question = question,
        answer = answer,
        options = {answer, answer + math.random(1, 10), answer - math.random(1, 10), answer + math.random(11, 20)}
    }
end

-- Create spawn points
function GameManager:CreateSpawnPoints()
    local workspace = game.Workspace
    
    -- Main spawn point in hallway
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "MainSpawn"
    spawn.Size = Vector3.new(10, 1, 10)
    spawn.Position = Vector3.new(-125, 1, 0)
    spawn.Material = Enum.Material.Neon
    spawn.BrickColor = BrickColor.new("Bright green")
    spawn.Anchored = true
    spawn.Parent = workspace
    
    -- Additional spawn points
    for i = 1, 5 do
        local extraSpawn = Instance.new("SpawnLocation")
        extraSpawn.Name = "Spawn" .. i
        extraSpawn.Size = Vector3.new(6, 1, 6)
        extraSpawn.Position = Vector3.new(-125, 1, (i - 3) * 15)
        extraSpawn.Material = Enum.Material.Neon
        extraSpawn.BrickColor = BrickColor.new("Bright blue")
        extraSpawn.Anchored = true
        extraSpawn.Parent = workspace
    end
end

-- Create classroom environment
function GameManager:CreateClassroom()
    local workspace = game.Workspace
    
    -- Create spawn points first
    self:CreateSpawnPoints()
    
    -- Create floor
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Size = Vector3.new(200, 1, 200)
    floor.Position = Vector3.new(0, 0, 0)
    floor.Material = Enum.Material.Concrete
    floor.BrickColor = BrickColor.new("Light gray")
    floor.Anchored = true
    floor.Parent = workspace
    
    -- Create walls for Classroom 1 with entrance opening
    local walls = {
        {Vector3.new(200, 20, 1), Vector3.new(0, 10, 100)}, -- Back wall
        {Vector3.new(1, 20, 200), Vector3.new(100, 10, 0)}, -- Right wall
        {Vector3.new(1, 20, 200), Vector3.new(-100, 10, 0)} -- Left wall
    }
    
    for i, wallData in ipairs(walls) do
        local wall = Instance.new("Part")
        wall.Name = "Classroom1_Wall" .. i
        wall.Size = wallData[1]
        wall.Position = wallData[2]
        wall.Material = Enum.Material.Concrete
        wall.BrickColor = BrickColor.new("Institutional white")
        wall.Anchored = true
        wall.Parent = workspace
    end
    
    -- Create front wall with entrance opening (split into two parts)
    local frontWallLeft = Instance.new("Part")
    frontWallLeft.Name = "Classroom1_FrontWallLeft"
    frontWallLeft.Size = Vector3.new(75, 20, 1) -- Left side of front wall
    frontWallLeft.Position = Vector3.new(-37.5, 10, -100)
    frontWallLeft.Material = Enum.Material.Concrete
    frontWallLeft.BrickColor = BrickColor.new("Institutional white")
    frontWallLeft.Anchored = true
    frontWallLeft.Parent = workspace
    
    local frontWallRight = Instance.new("Part")
    frontWallRight.Name = "Classroom1_FrontWallRight"
    frontWallRight.Size = Vector3.new(110, 20, 1) -- Right side of front wall
    frontWallRight.Position = Vector3.new(45, 10, -100)
    frontWallRight.Material = Enum.Material.Concrete
    frontWallRight.BrickColor = BrickColor.new("Institutional white")
    frontWallRight.Anchored = true
    frontWallRight.Parent = workspace
    
    -- Create entrance arch/frame decoration
    local entranceTop = Instance.new("Part")
    entranceTop.Name = "Classroom1_EntranceTop"
    entranceTop.Size = Vector3.new(25, 5, 1)
    entranceTop.Position = Vector3.new(-75, 17.5, -100)
    entranceTop.Material = Enum.Material.Concrete
    entranceTop.BrickColor = BrickColor.new("Institutional white")
    entranceTop.Anchored = true
    entranceTop.Parent = workspace
    
    -- Create ceiling for Classroom 1
    local ceiling = Instance.new("Part")
    ceiling.Name = "Classroom1_Ceiling"
    ceiling.Size = Vector3.new(200, 1, 200)
    ceiling.Position = Vector3.new(0, 20, 0)
    ceiling.Material = Enum.Material.Concrete
    ceiling.BrickColor = BrickColor.new("Light grey")
    ceiling.Anchored = true
    ceiling.Parent = workspace
    
    -- Add ceiling lights
    for x = -60, 60, 40 do
        for z = -60, 60, 40 do
            local light = Instance.new("Part")
            light.Name = "CeilingLight"
            light.Size = Vector3.new(8, 0.5, 8)
            light.Position = Vector3.new(x, 19.5, z)
            light.Material = Enum.Material.Neon
            light.BrickColor = BrickColor.new("Bright white")
            light.Anchored = true
            light.Parent = workspace
            
            local pointLight = Instance.new("PointLight")
            pointLight.Brightness = 2
            pointLight.Range = 30
            pointLight.Parent = light
        end
    end
    
    
    
    -- Classroom number sign
    local sign = Instance.new("Part")
    sign.Name = "ClassroomSign1"
    sign.Size = Vector3.new(3, 2, 0.2)
    sign.Position = Vector3.new(-85, 12, -98)
    sign.Material = Enum.Material.Plastic
    sign.BrickColor = BrickColor.new("Bright white")
    sign.Anchored = true
    sign.Parent = workspace
    
    local signGui = Instance.new("SurfaceGui")
    signGui.Face = Enum.NormalId.Front
    signGui.Parent = sign
    
    local signLabel = Instance.new("TextLabel")
    signLabel.Size = UDim2.new(1, 0, 1, 0)
    signLabel.BackgroundTransparency = 1
    signLabel.Text = "AULA 1"
    signLabel.TextColor3 = Color3.new(0, 0, 0)
    signLabel.TextScaled = true
    signLabel.Font = Enum.Font.GothamBold
    signLabel.Parent = signGui
    
    -- Create registration board for classroom 1 (positioned correctly)
    local regBoard = Instance.new("Part")
    regBoard.Name = "RegistrationBoard1"
    regBoard.Size = Vector3.new(8, 6, 0.5)
    regBoard.Position = Vector3.new(-95, 8, -85)
    regBoard.Material = Enum.Material.Plastic
    regBoard.BrickColor = BrickColor.new("Bright white")
    regBoard.Anchored = true
    regBoard.Parent = workspace
    
    local regGui = Instance.new("SurfaceGui")
    regGui.Face = Enum.NormalId.Front
    regGui.Parent = regBoard
    
    local regTitle = Instance.new("TextLabel")
    regTitle.Name = "RegistrationTitle"
    regTitle.Size = UDim2.new(1, 0, 0.3, 0)
    regTitle.Position = UDim2.new(0, 0, 0, 0)
    regTitle.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
    regTitle.Text = "REGISTRO - AULA 1"
    regTitle.TextColor3 = Color3.new(1, 1, 1)
    regTitle.TextScaled = true
    regTitle.Font = Enum.Font.GothamBold
    regTitle.Parent = regGui
    
    local regButton = Instance.new("TextButton")
    regButton.Name = "RegisterButton1"
    regButton.Size = UDim2.new(0.8, 0, 0.4, 0)
    regButton.Position = UDim2.new(0.1, 0, 0.35, 0)
    regButton.BackgroundColor3 = Color3.new(0, 0.7, 0)
    regButton.Text = "REGISTRARSE COMO ESTUDIANTE"
    regButton.TextColor3 = Color3.new(1, 1, 1)
    regButton.TextScaled = true
    regButton.Font = Enum.Font.Gotham
    regButton.Parent = regGui
    
    local studentCount = Instance.new("TextLabel")
    studentCount.Name = "StudentCount1"
    studentCount.Size = UDim2.new(1, 0, 0.25, 0)
    studentCount.Position = UDim2.new(0, 0, 0.75, 0)
    studentCount.BackgroundTransparency = 1
    studentCount.Text = "Estudiantes registrados: 0"
    studentCount.TextColor3 = Color3.new(0, 0, 0)
    studentCount.TextScaled = true
    studentCount.Font = Enum.Font.Gotham
    studentCount.Parent = regGui
    
    -- Registration button functionality
    regButton.MouseButton1Click:Connect(function()
        local player = Players.LocalPlayer
        if self:RegisterStudent(player, 1) then
            regButton.Text = "¡REGISTRADO!"
            regButton.BackgroundColor3 = Color3.new(0, 0.5, 0)
        else
            regButton.Text = "YA REGISTRADO"
            regButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
        end
        wait(2)
        regButton.Text = "REGISTRARSE COMO ESTUDIANTE"
        regButton.BackgroundColor3 = Color3.new(0, 0.7, 0)
    end)
    
    -- Create blackboard
    local blackboard = Instance.new("Part")
    blackboard.Name = "Blackboard"
    blackboard.Size = Vector3.new(30, 15, 1)
    blackboard.Position = Vector3.new(0, 8, 95)
    blackboard.Material = Enum.Material.Plastic
    blackboard.BrickColor = BrickColor.new("Really black")
    blackboard.Anchored = true
    blackboard.Parent = workspace
    
    -- Add blackboard screen GUI
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.Parent = blackboard
    
    local questionLabel = Instance.new("TextLabel")
    questionLabel.Name = "QuestionLabel"
    questionLabel.Size = UDim2.new(1, 0, 0.5, 0)
    questionLabel.Position = UDim2.new(0, 0, 0, 0)
    questionLabel.BackgroundTransparency = 1
    questionLabel.Text = "Esperando jugadores..."
    questionLabel.TextColor3 = Color3.new(1, 1, 1)
    questionLabel.TextScaled = true
    questionLabel.Font = Enum.Font.GothamBold
    questionLabel.Parent = surfaceGui
    
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "TimerLabel"
    timerLabel.Size = UDim2.new(1, 0, 0.3, 0)
    timerLabel.Position = UDim2.new(0, 0, 0.5, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "El juego comenzará pronto"
    timerLabel.TextColor3 = Color3.new(1, 0, 0)
    timerLabel.TextScaled = true
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.Parent = surfaceGui
    
    local progressLabel = Instance.new("TextLabel")
    progressLabel.Name = "ProgressLabel"
    progressLabel.Size = UDim2.new(1, 0, 0.2, 0)
    progressLabel.Position = UDim2.new(0, 0, 0.8, 0)
    progressLabel.BackgroundTransparency = 1
    progressLabel.Text = "Pregunta 0/100"
    progressLabel.TextColor3 = Color3.new(0, 1, 0)
    progressLabel.TextScaled = true
    progressLabel.Font = Enum.Font.Gotham
    progressLabel.Parent = surfaceGui
    
    self.Blackboard = blackboard
    
    -- Create hallway
    self:CreateHallway()
    
    -- Create second classroom
    self:CreateClassroom2()
    
    -- Create third classroom (under construction)
    self:CreateClassroom3()
    
    -- Create desks and chairs
    self:CreateDesks()
end

function GameManager:CreateHallway()
    local workspace = game.Workspace
    
    -- Hallway floor
    local hallwayFloor = Instance.new("Part")
    hallwayFloor.Name = "HallwayFloor"
    hallwayFloor.Size = Vector3.new(50, 1, 300)
    hallwayFloor.Position = Vector3.new(-125, 0, 0)
    hallwayFloor.Material = Enum.Material.Concrete
    hallwayFloor.BrickColor = BrickColor.new("Medium grey")
    hallwayFloor.Anchored = true
    hallwayFloor.Parent = workspace
    
    -- Hallway walls
    local hallwayWalls = {
        {Vector3.new(50, 20, 1), Vector3.new(-125, 10, 150)}, -- North wall
        {Vector3.new(50, 20, 1), Vector3.new(-125, 10, -150)}, -- South wall
    }
    
    for i, wallData in ipairs(hallwayWalls) do
        local wall = Instance.new("Part")
        wall.Name = "HallwayWall" .. i
        wall.Size = wallData[1]
        wall.Position = wallData[2]
        wall.Material = Enum.Material.Concrete
        wall.BrickColor = BrickColor.new("Institutional white")
        wall.Anchored = true
        wall.Parent = workspace
    end
    
    -- Hallway ceiling
    local hallwayCeiling = Instance.new("Part")
    hallwayCeiling.Name = "HallwayCeiling"
    hallwayCeiling.Size = Vector3.new(50, 1, 300)
    hallwayCeiling.Position = Vector3.new(-125, 20, 0)
    hallwayCeiling.Material = Enum.Material.Concrete
    hallwayCeiling.BrickColor = BrickColor.new("Light grey")
    hallwayCeiling.Anchored = true
    hallwayCeiling.Parent = workspace
    
    -- Hallway lights
    for z = -120, 120, 60 do
        local light = Instance.new("Part")
        light.Name = "HallwayLight"
        light.Size = Vector3.new(6, 0.5, 6)
        light.Position = Vector3.new(-125, 19.5, z)
        light.Material = Enum.Material.Neon
        light.BrickColor = BrickColor.new("Bright white")
        light.Anchored = true
        light.Parent = workspace
        
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 1.5
        pointLight.Range = 25
        pointLight.Parent = light
    end
end

function GameManager:CreateClassroom2()
    local workspace = game.Workspace
    
    -- Classroom 2 floor
    local floor2 = Instance.new("Part")
    floor2.Name = "Classroom2_Floor"
    floor2.Size = Vector3.new(200, 1, 200)
    floor2.Position = Vector3.new(-250, 0, 0)
    floor2.Material = Enum.Material.Concrete
    floor2.BrickColor = BrickColor.new("Light gray")
    floor2.Anchored = true
    floor2.Parent = workspace
    
    -- Classroom 2 walls with entrance opening
    local walls2 = {
        {Vector3.new(200, 20, 1), Vector3.new(-250, 10, 100)}, -- Back wall
        {Vector3.new(200, 20, 1), Vector3.new(-250, 10, -100)}, -- Front wall
        {Vector3.new(1, 20, 200), Vector3.new(-350, 10, 0)} -- Left wall
    }
    
    for i, wallData in ipairs(walls2) do
        local wall = Instance.new("Part")
        wall.Name = "Classroom2_Wall" .. i
        wall.Size = wallData[1]
        wall.Position = wallData[2]
        wall.Material = Enum.Material.Concrete
        wall.BrickColor = BrickColor.new("Institutional white")
        wall.Anchored = true
        wall.Parent = workspace
    end
    
    -- Create right wall with entrance opening (split into two parts)
    local rightWallTop = Instance.new("Part")
    rightWallTop.Name = "Classroom2_RightWallTop"
    rightWallTop.Size = Vector3.new(1, 20, 88) -- Top part of right wall
    rightWallTop.Position = Vector3.new(-150, 10, 56)
    rightWallTop.Material = Enum.Material.Concrete
    rightWallTop.BrickColor = BrickColor.new("Institutional white")
    rightWallTop.Anchored = true
    rightWallTop.Parent = workspace
    
    local rightWallBottom = Instance.new("Part")
    rightWallBottom.Name = "Classroom2_RightWallBottom"
    rightWallBottom.Size = Vector3.new(1, 20, 88) -- Bottom part of right wall
    rightWallBottom.Position = Vector3.new(-150, 10, -56)
    rightWallBottom.Material = Enum.Material.Concrete
    rightWallBottom.BrickColor = BrickColor.new("Institutional white")
    rightWallBottom.Anchored = true
    rightWallBottom.Parent = workspace
    
    -- Create entrance arch/frame decoration for classroom 2
    local entranceLeft2 = Instance.new("Part")
    entranceLeft2.Name = "Classroom2_EntranceLeft"
    entranceLeft2.Size = Vector3.new(1, 4, 4)
    entranceLeft2.Position = Vector3.new(-150, 16, 12)
    entranceLeft2.Material = Enum.Material.Concrete
    entranceLeft2.BrickColor = BrickColor.new("Institutional white")
    entranceLeft2.Anchored = true
    entranceLeft2.Parent = workspace
    
    local entranceRight2 = Instance.new("Part")
    entranceRight2.Name = "Classroom2_EntranceRight"
    entranceRight2.Size = Vector3.new(1, 4, 4)
    entranceRight2.Position = Vector3.new(-150, 16, 28)
    entranceRight2.Material = Enum.Material.Concrete
    entranceRight2.BrickColor = BrickColor.new("Institutional white")
    entranceRight2.Anchored = true
    entranceRight2.Parent = workspace
    
    -- Classroom 2 ceiling
    local ceiling2 = Instance.new("Part")
    ceiling2.Name = "Classroom2_Ceiling"
    ceiling2.Size = Vector3.new(200, 1, 200)
    ceiling2.Position = Vector3.new(-250, 20, 0)
    ceiling2.Material = Enum.Material.Concrete
    ceiling2.BrickColor = BrickColor.new("Light grey")
    ceiling2.Anchored = true
    ceiling2.Parent = workspace
    
    -- Classroom 2 lights
    for x = -310, -190, 40 do
        for z = -60, 60, 40 do
            local light = Instance.new("Part")
            light.Name = "Classroom2_Light"
            light.Size = Vector3.new(8, 0.5, 8)
            light.Position = Vector3.new(x, 19.5, z)
            light.Material = Enum.Material.Neon
            light.BrickColor = BrickColor.new("Bright white")
            light.Anchored = true
            light.Parent = workspace
            
            local pointLight = Instance.new("PointLight")
            pointLight.Brightness = 2
            pointLight.Range = 30
            pointLight.Parent = light
        end
    end
    
    
    
    -- Classroom 2 number sign
    local sign2 = Instance.new("Part")
    sign2.Name = "ClassroomSign2"
    sign2.Size = Vector3.new(0.2, 2, 3)
    sign2.Position = Vector3.new(-148, 12, 25)
    sign2.Material = Enum.Material.Plastic
    sign2.BrickColor = BrickColor.new("Bright white")
    sign2.Anchored = true
    sign2.Parent = workspace
    
    local signGui2 = Instance.new("SurfaceGui")
    signGui2.Face = Enum.NormalId.Front
    signGui2.Parent = sign2
    
    local signLabel2 = Instance.new("TextLabel")
    signLabel2.Size = UDim2.new(1, 0, 1, 0)
    signLabel2.BackgroundTransparency = 1
    signLabel2.Text = "AULA 2"
    signLabel2.TextColor3 = Color3.new(0, 0, 0)
    signLabel2.TextScaled = true
    signLabel2.Font = Enum.Font.GothamBold
    signLabel2.Parent = signGui2
    
    -- Create registration board for classroom 2 (positioned correctly)
    local regBoard2 = Instance.new("Part")
    regBoard2.Name = "RegistrationBoard2"
    regBoard2.Size = Vector3.new(0.5, 6, 8)
    regBoard2.Position = Vector3.new(-148, 8, -20)
    regBoard2.Material = Enum.Material.Plastic
    regBoard2.BrickColor = BrickColor.new("Bright white")
    regBoard2.Anchored = true
    regBoard2.Parent = workspace
    
    local regGui2 = Instance.new("SurfaceGui")
    regGui2.Face = Enum.NormalId.Front
    regGui2.Parent = regBoard2
    
    local regTitle2 = Instance.new("TextLabel")
    regTitle2.Name = "RegistrationTitle"
    regTitle2.Size = UDim2.new(1, 0, 0.3, 0)
    regTitle2.Position = UDim2.new(0, 0, 0, 0)
    regTitle2.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    regTitle2.Text = "REGISTRO - AULA 2"
    regTitle2.TextColor3 = Color3.new(1, 1, 1)
    regTitle2.TextScaled = true
    regTitle2.Font = Enum.Font.GothamBold
    regTitle2.Parent = regGui2
    
    local regButton2 = Instance.new("TextButton")
    regButton2.Name = "RegisterButton2"
    regButton2.Size = UDim2.new(0.8, 0, 0.4, 0)
    regButton2.Position = UDim2.new(0.1, 0, 0.35, 0)
    regButton2.BackgroundColor3 = Color3.new(0, 0.7, 0)
    regButton2.Text = "REGISTRARSE COMO ESTUDIANTE"
    regButton2.TextColor3 = Color3.new(1, 1, 1)
    regButton2.TextScaled = true
    regButton2.Font = Enum.Font.Gotham
    regButton2.Parent = regGui2
    
    local studentCount2 = Instance.new("TextLabel")
    studentCount2.Name = "StudentCount2"
    studentCount2.Size = UDim2.new(1, 0, 0.25, 0)
    studentCount2.Position = UDim2.new(0, 0, 0.75, 0)
    studentCount2.BackgroundTransparency = 1
    studentCount2.Text = "Estudiantes registrados: 0"
    studentCount2.TextColor3 = Color3.new(0, 0, 0)
    studentCount2.TextScaled = true
    studentCount2.Font = Enum.Font.Gotham
    studentCount2.Parent = regGui2
    
    -- Registration button functionality
    regButton2.MouseButton1Click:Connect(function()
        local player = Players.LocalPlayer
        if self:RegisterStudent(player, 2) then
            regButton2.Text = "¡REGISTRADO!"
            regButton2.BackgroundColor3 = Color3.new(0, 0.5, 0)
        else
            regButton2.Text = "YA REGISTRADO"
            regButton2.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
        end
        wait(2)
        regButton2.Text = "REGISTRARSE COMO ESTUDIANTE"
        regButton2.BackgroundColor3 = Color3.new(0, 0.7, 0)
    end)
    
    -- Blackboard for classroom 2
    local blackboard2 = Instance.new("Part")
    blackboard2.Name = "Blackboard2"
    blackboard2.Size = Vector3.new(30, 15, 1)
    blackboard2.Position = Vector3.new(-250, 8, 95)
    blackboard2.Material = Enum.Material.Plastic
    blackboard2.BrickColor = BrickColor.new("Really black")
    blackboard2.Anchored = true
    blackboard2.Parent = workspace
    
    -- Blackboard GUI for classroom 2
    local surfaceGui2 = Instance.new("SurfaceGui")
    surfaceGui2.Face = Enum.NormalId.Front
    surfaceGui2.Parent = blackboard2
    
    local questionLabel2 = Instance.new("TextLabel")
    questionLabel2.Name = "QuestionLabel"
    questionLabel2.Size = UDim2.new(1, 0, 1, 0)
    questionLabel2.BackgroundTransparency = 1
    questionLabel2.Text = "Aula 2 - Preparándose..."
    questionLabel2.TextColor3 = Color3.new(1, 1, 1)
    questionLabel2.TextScaled = true
    questionLabel2.Font = Enum.Font.GothamBold
    questionLabel2.Parent = surfaceGui2
end

function GameManager:CreateClassroom3()
    local workspace = game.Workspace
    
    -- Classroom 3 floor
    local floor3 = Instance.new("Part")
    floor3.Name = "Classroom3_Floor"
    floor3.Size = Vector3.new(200, 1, 200)
    floor3.Position = Vector3.new(0, 0, 250)
    floor3.Material = Enum.Material.Concrete
    floor3.BrickColor = BrickColor.new("Light gray")
    floor3.Anchored = true
    floor3.Parent = workspace
    
    -- Classroom 3 walls - all red for construction
    local walls3 = {
        {Vector3.new(200, 20, 1), Vector3.new(0, 10, 350)}, -- Back wall
        {Vector3.new(200, 20, 1), Vector3.new(0, 10, 150)}, -- Front wall
        {Vector3.new(1, 20, 200), Vector3.new(-100, 10, 250)}, -- Left wall
        {Vector3.new(1, 20, 200), Vector3.new(100, 10, 250)} -- Right wall
    }
    
    for i, wallData in ipairs(walls3) do
        local wall = Instance.new("Part")
        wall.Name = "Classroom3_Wall" .. i
        wall.Size = wallData[1]
        wall.Position = wallData[2]
        wall.Material = Enum.Material.Concrete
        wall.BrickColor = BrickColor.new("Really red")
        wall.Anchored = true
        wall.Parent = workspace
    end
    
    -- Classroom 3 ceiling - also red
    local ceiling3 = Instance.new("Part")
    ceiling3.Name = "Classroom3_Ceiling"
    ceiling3.Size = Vector3.new(200, 1, 200)
    ceiling3.Position = Vector3.new(0, 20, 250)
    ceiling3.Material = Enum.Material.Concrete
    ceiling3.BrickColor = BrickColor.new("Really red")
    ceiling3.Anchored = true
    ceiling3.Parent = workspace
    
    -- Construction barriers at entrance
    local barrier1 = Instance.new("Part")
    barrier1.Name = "ConstructionBarrier1"
    barrier1.Size = Vector3.new(12, 8, 1)
    barrier1.Position = Vector3.new(-6, 4, 149)
    barrier1.Material = Enum.Material.Plastic
    barrier1.BrickColor = BrickColor.new("Bright yellow")
    barrier1.Anchored = true
    barrier1.Parent = workspace
    
    local barrier2 = Instance.new("Part")
    barrier2.Name = "ConstructionBarrier2"
    barrier2.Size = Vector3.new(12, 8, 1)
    barrier2.Position = Vector3.new(6, 4, 149)
    barrier2.Material = Enum.Material.Plastic
    barrier2.BrickColor = BrickColor.new("Bright yellow")
    barrier2.Anchored = true
    barrier2.Parent = workspace
    
    -- Construction warning signs
    local warningSign = Instance.new("Part")
    warningSign.Name = "ConstructionWarning"
    warningSign.Size = Vector3.new(8, 4, 0.2)
    warningSign.Position = Vector3.new(0, 8, 148)
    warningSign.Material = Enum.Material.Plastic
    warningSign.BrickColor = BrickColor.new("Bright yellow")
    warningSign.Anchored = true
    warningSign.Parent = workspace
    
    local warningGui = Instance.new("SurfaceGui")
    warningGui.Face = Enum.NormalId.Front
    warningGui.Parent = warningSign
    
    local warningLabel = Instance.new("TextLabel")
    warningLabel.Size = UDim2.new(1, 0, 1, 0)
    warningLabel.BackgroundColor3 = Color3.new(1, 0, 0)
    warningLabel.Text = "⚠️ AULA 3 - EN CONSTRUCCIÓN ⚠️\nACCESO RESTRINGIDO"
    warningLabel.TextColor3 = Color3.new(1, 1, 1)
    warningLabel.TextScaled = true
    warningLabel.Font = Enum.Font.GothamBold
    warningLabel.Parent = warningGui
    
    -- Classroom 3 number sign
    local sign3 = Instance.new("Part")
    sign3.Name = "ClassroomSign3"
    sign3.Size = Vector3.new(3, 2, 0.2)
    sign3.Position = Vector3.new(-8, 12, 148)
    sign3.Material = Enum.Material.Plastic
    sign3.BrickColor = BrickColor.new("Really red")
    sign3.Anchored = true
    sign3.Parent = workspace
    
    local signGui3 = Instance.new("SurfaceGui")
    signGui3.Face = Enum.NormalId.Front
    signGui3.Parent = sign3
    
    local signLabel3 = Instance.new("TextLabel")
    signLabel3.Size = UDim2.new(1, 0, 1, 0)
    signLabel3.BackgroundTransparency = 1
    signLabel3.Text = "AULA 3"
    signLabel3.TextColor3 = Color3.new(1, 1, 1)
    signLabel3.TextScaled = true
    signLabel3.Font = Enum.Font.GothamBold
    signLabel3.Parent = signGui3
    
    -- Construction equipment scattered around
    for i = 1, 5 do
        local equipment = Instance.new("Part")
        equipment.Name = "ConstructionEquipment" .. i
        equipment.Size = Vector3.new(
            math.random(2, 6),
            math.random(1, 4),
            math.random(2, 6)
        )
        equipment.Position = Vector3.new(
            math.random(-80, 80),
            equipment.Size.Y / 2 + 1,
            math.random(170, 330)
        )
        equipment.Material = Enum.Material.Metal
        equipment.BrickColor = BrickColor.new("Dark stone grey")
        equipment.Anchored = true
        equipment.Parent = workspace
    end
    
    -- Construction cones
    for i = 1, 8 do
        local cone = Instance.new("Part")
        cone.Name = "TrafficCone" .. i
        cone.Size = Vector3.new(2, 4, 2)
        cone.Shape = Enum.PartType.Cylinder
        cone.Position = Vector3.new(
            math.random(-15, 15),
            2,
            145 + math.random(0, 8)
        )
        cone.Material = Enum.Material.Plastic
        cone.BrickColor = BrickColor.new("Neon orange")
        cone.Anchored = true
        cone.Parent = workspace
    end
end

function GameManager:CreateDesks()
    local workspace = game.Workspace
    local rows = 7
    local cols = 5
    local deskSpacing = 12
    local deskCount = 0
    
    for row = 1, rows do
        for col = 1, cols do
            if deskCount >= 35 then break end
            deskCount = deskCount + 1
            
            local deskPosition = Vector3.new(
                (col - 3) * deskSpacing,
                2.5,
                (row - 4) * deskSpacing - 20
            )
            
            -- Create modern desk
            local desk = Instance.new("Part")
            desk.Name = "Desk_" .. row .. "_" .. col
            desk.Size = Vector3.new(8, 1, 5)
            desk.Position = deskPosition
            desk.Material = Enum.Material.Glass
            desk.BrickColor = BrickColor.new("Institutional white")
            desk.Anchored = true
            desk.Parent = workspace
            
            -- Add desk legs (modern metal legs)
            for i = 1, 4 do
                local leg = Instance.new("Part")
                leg.Name = "DeskLeg_" .. i
                leg.Size = Vector3.new(0.3, 4, 0.3)
                leg.Material = Enum.Material.Metal
                leg.BrickColor = BrickColor.new("Dark stone grey")
                leg.Anchored = true
                leg.Parent = workspace
                
                local xOffset = (i <= 2) and -3.5 or 3.5
                local zOffset = (i % 2 == 1) and -2 or 2
                leg.Position = deskPosition + Vector3.new(xOffset, -2.5, zOffset)
            end
            
            -- Create modern chair with seat functionality
            local chair = Instance.new("Part")
            chair.Name = "Chair_" .. row .. "_" .. col
            chair.Size = Vector3.new(4, 0.5, 4)
            chair.Position = deskPosition + Vector3.new(0, 1.5, -6)
            chair.Material = Enum.Material.Fabric
            chair.BrickColor = BrickColor.new("Really red")
            chair.Anchored = true
            chair.Parent = workspace
            
            -- Add seat functionality with proper positioning
            local seat = Instance.new("Seat")
            seat.Name = "Seat_" .. row .. "_" .. col
            seat.Size = Vector3.new(4, 0.2, 4)
            seat.Position = deskPosition + Vector3.new(0, 2.1, -6)
            seat.Material = Enum.Material.Fabric
            seat.BrickColor = BrickColor.new("Really red")
            seat.Anchored = true
            seat.Disabled = false -- Enable sitting
            seat.Parent = workspace
            
            -- Chair back
            local chairBack = Instance.new("Part")
            chairBack.Name = "ChairBack_" .. row .. "_" .. col
            chairBack.Size = Vector3.new(4, 6, 0.5)
            chairBack.Position = deskPosition + Vector3.new(0, 4, -8)
            chairBack.Material = Enum.Material.Fabric
            chairBack.BrickColor = BrickColor.new("Really red")
            chairBack.Anchored = true
            chairBack.Parent = workspace
            
            -- Chair legs (modern style)
            for i = 1, 4 do
                local chairLeg = Instance.new("Part")
                chairLeg.Name = "ChairLeg_" .. i
                chairLeg.Size = Vector3.new(0.3, 3, 0.3)
                chairLeg.Material = Enum.Material.Metal
                chairLeg.BrickColor = BrickColor.new("Dark stone grey")
                chairLeg.Anchored = true
                chairLeg.Parent = workspace
                
                local xOffset = (i <= 2) and -1.5 or 1.5
                local zOffset = (i % 2 == 1) and -1.5 or 1.5
                chairLeg.Position = deskPosition + Vector3.new(xOffset, 0, zOffset - 6)
            end
            
            -- Create answer GUI on desk
            local surfaceGui = Instance.new("SurfaceGui")
            surfaceGui.Face = Enum.NormalId.Top
            surfaceGui.Parent = desk
            
            local answerFrame = Instance.new("Frame")
            answerFrame.Size = UDim2.new(1, 0, 1, 0)
            answerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
            answerFrame.Parent = surfaceGui
            
            -- Answer buttons
            for i = 1, 4 do
                local button = Instance.new("TextButton")
                button.Name = "Option" .. i
                button.Size = UDim2.new(0.45, 0, 0.45, 0)
                button.Position = UDim2.new(
                    ((i - 1) % 2) * 0.5 + 0.025,
                    0,
                    math.floor((i - 1) / 2) * 0.5 + 0.025,
                    0
                )
                button.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
                button.Text = "?"
                button.TextScaled = true
                button.Font = Enum.Font.Gotham
                button.Parent = answerFrame
                
                -- Button click handler
                button.MouseButton1Click:Connect(function()
                    self:SubmitAnswer(desk, i)
                end)
            end
            
            -- Store desk info
            table.insert(self.Desks, {
                desk = desk,
                chair = chair,
                seat = seat,
                occupied = false,
                player = nil,
                answered = false,
                correctAnswer = false
            })
        end
    end
end

function GameManager:RegisterStudent(player, classroom)
    local aula = "Aula" .. classroom
    
    -- Check if already registered
    for _, registeredPlayer in ipairs(self.RegisteredStudents[aula]) do
        if registeredPlayer.UserId == player.UserId then
            return false -- Already registered
        end
    end
    
    -- Register student
    table.insert(self.RegisteredStudents[aula], player)
    
    -- Update counter on registration board
    local boardName = "RegistrationBoard" .. classroom
    local board = game.Workspace:FindFirstChild(boardName)
    if board and board.SurfaceGui then
        local counter = board.SurfaceGui:FindFirstChild("StudentCount" .. classroom)
        if counter then
            counter.Text = "Estudiantes registrados: " .. #self.RegisteredStudents[aula]
        end
    end
    
    return true
end

function GameManager:AssignPlayerToDesk(player)
    for i, deskData in ipairs(self.Desks) do
        if not deskData.occupied then
            deskData.occupied = true
            deskData.player = player
            
            -- Add player to game
            self.Players[player.UserId] = {
                player = player,
                desk = i,
                score = 0,
                alive = true
            }
            
            break
        end
    end
end

function GameManager:StartGame()
    if self.GameActive then return end
    
    local playerCount = #Players:GetPlayers()
    if playerCount < 2 then
        local questionLabel = self.Blackboard.SurfaceGui.QuestionLabel
        questionLabel.Text = "Necesitas al menos 2 jugadores para comenzar"
        return
    end
    
    self.GameActive = true
    self.CurrentQuestion = 1
    
    -- Update blackboard
    local questionLabel = self.Blackboard.SurfaceGui.QuestionLabel
    local progressLabel = self.Blackboard.SurfaceGui.ProgressLabel
    
    questionLabel.Text = "¡El juego comienza en 3..."
    wait(1)
    questionLabel.Text = "¡El juego comienza en 2..."
    wait(1)
    questionLabel.Text = "¡El juego comienza en 1..."
    wait(1)
    questionLabel.Text = "¡SQUID GAME MATH CHALLENGE!"
    wait(2)
    
    -- Start question loop
    for question = 1, self.TotalQuestions do
        self:PresentQuestion(question)
        wait(self.QuestionTime)
        self:ProcessAnswers()
        
        if self:CountAlivePlayers() <= 1 then
            break
        end
    end
    
    self:EndGame()
end

function GameManager:PresentQuestion(questionNumber)
    self.CurrentQuestion = questionNumber
    local mathQuestion = MathAPI:GenerateQuestion()
    
    -- Update blackboard
    local questionLabel = self.Blackboard.SurfaceGui.QuestionLabel
    local timerLabel = self.Blackboard.SurfaceGui.TimerLabel
    local progressLabel = self.Blackboard.SurfaceGui.ProgressLabel
    
    questionLabel.Text = "Pregunta: " .. mathQuestion.question .. " = ?"
    progressLabel.Text = "Pregunta " .. questionNumber .. "/100"
    
    -- Shuffle options
    local shuffledOptions = {}
    for i, option in ipairs(mathQuestion.options) do
        table.insert(shuffledOptions, option)
    end
    
    for i = #shuffledOptions, 2, -1 do
        local j = math.random(i)
        shuffledOptions[i], shuffledOptions[j] = shuffledOptions[j], shuffledOptions[i]
    end
    
    -- Update all desk GUIs
    for i, deskData in ipairs(self.Desks) do
        if deskData.occupied then
            local surfaceGui = deskData.desk.SurfaceGui
            for j = 1, 4 do
                local button = surfaceGui.Frame["Option" .. j]
                button.Text = tostring(shuffledOptions[j])
                button.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
            end
            deskData.answered = false
            deskData.correctAnswer = false
        end
    end
    
    -- Store correct answer
    self.CurrentCorrectAnswer = mathQuestion.answer
    
    -- Start countdown
    for timeLeft = self.QuestionTime, 1, -1 do
        timerLabel.Text = "Tiempo: " .. timeLeft .. "s"
        wait(1)
    end
    
    timerLabel.Text = "¡Se acabó el tiempo!"
end

function GameManager:SubmitAnswer(desk, optionNumber)
    -- Find desk data
    for i, deskData in ipairs(self.Desks) do
        if deskData.desk == desk and deskData.occupied and not deskData.answered then
            local surfaceGui = desk.SurfaceGui
            local selectedButton = surfaceGui.Frame["Option" .. optionNumber]
            local selectedAnswer = tonumber(selectedButton.Text)
            
            deskData.answered = true
            
            if selectedAnswer == self.CurrentCorrectAnswer then
                deskData.correctAnswer = true
                selectedButton.BackgroundColor3 = Color3.new(0, 1, 0) -- Green
                self.Players[deskData.player.UserId].score = self.Players[deskData.player.UserId].score + 1
            else
                deskData.correctAnswer = false
                selectedButton.BackgroundColor3 = Color3.new(1, 0, 0) -- Red
            end
            
            break
        end
    end
end

function GameManager:CreateMeteoriteStrike(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local character = player.Character
    local rootPart = character.HumanoidRootPart
    local strikePosition = rootPart.Position
    
    -- Create meteorite above player
    local meteorite = Instance.new("Part")
    meteorite.Name = "Meteorite"
    meteorite.Size = Vector3.new(4, 4, 4)
    meteorite.Shape = Enum.PartType.Ball
    meteorite.Position = strikePosition + Vector3.new(0, 50, 0)
    meteorite.Material = Enum.Material.Rock
    meteorite.BrickColor = BrickColor.new("Really black")
    meteorite.Anchored = false
    meteorite.Parent = workspace
    
    -- Add fire effect
    local fire = Instance.new("Fire")
    fire.Size = 8
    fire.Heat = 15
    fire.Parent = meteorite
    
    -- Add particle effect
    local attachment = Instance.new("Attachment")
    attachment.Parent = meteorite
    
    local particles = Instance.new("ParticleEmitter")
    particles.Texture = "rbxasset://textures/particles/fire_main.dds"
    particles.Lifetime = NumberRange.new(0.3, 1.0)
    particles.Rate = 100
    particles.SpreadAngle = Vector2.new(45, 45)
    particles.Speed = NumberRange.new(8)
    particles.Parent = attachment
    
    -- Add velocity to fall down fast
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Velocity = Vector3.new(0, -80, 0)
    bodyVelocity.Parent = meteorite
    
    -- Create explosion when meteorite hits
    meteorite.Touched:Connect(function(hit)
        if hit.Name == "Floor" or hit.Name == "Classroom1_Floor" or hit.Name == "Classroom2_Floor" then
            -- Create explosion effect
            local explosion = Instance.new("Explosion")
            explosion.Position = meteorite.Position
            explosion.BlastRadius = 15
            explosion.BlastPressure = 0 -- Don't affect other players
            explosion.Parent = workspace
            
            -- Destroy meteorite
            meteorite:Destroy()
            
            -- Eliminate player
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.Health = 0
            end
        end
    end)
    
    -- Clean up after 10 seconds if it doesn't hit anything
    game:GetService("Debris"):AddItem(meteorite, 10)
end

function GameManager:ProcessAnswers()
    for i, deskData in ipairs(self.Desks) do
        if deskData.occupied and self.Players[deskData.player.UserId].alive then
            if not deskData.answered or not deskData.correctAnswer then
                -- Player is eliminated with meteorite strike
                self.Players[deskData.player.UserId].alive = false
                
                -- Launch meteorite at player
                self:CreateMeteoriteStrike(deskData.player)
                
                -- Change desk color to red
                deskData.desk.BrickColor = BrickColor.new("Really red")
                deskData.chair.BrickColor = BrickColor.new("Really red")
            end
        end
    end
end

function GameManager:CountAlivePlayers()
    local count = 0
    for userId, playerData in pairs(self.Players) do
        if playerData.alive then
            count = count + 1
        end
    end
    return count
end

function GameManager:EndGame()
    self.GameActive = false
    
    -- Find winner(s)
    local winners = {}
    local highestScore = 0
    
    for userId, playerData in pairs(self.Players) do
        if playerData.alive and playerData.score > highestScore then
            highestScore = playerData.score
            winners = {playerData.player}
        elseif playerData.alive and playerData.score == highestScore then
            table.insert(winners, playerData.player)
        end
    end
    
    -- Announce winner
    local questionLabel = self.Blackboard.SurfaceGui.QuestionLabel
    local timerLabel = self.Blackboard.SurfaceGui.TimerLabel
    
    if #winners == 1 then
        questionLabel.Text = "GANADOR: " .. winners[1].Name
        timerLabel.Text = "Puntuación: " .. highestScore .. "/" .. self.CurrentQuestion
        
        -- Give winner prize
        self:GivePrize(winners[1])
    elseif #winners > 1 then
        local winnerNames = ""
        for i, winner in ipairs(winners) do
            winnerNames = winnerNames .. winner.Name
            if i < #winners then
                winnerNames = winnerNames .. ", "
            end
        end
        questionLabel.Text = "GANADORES: " .. winnerNames
        timerLabel.Text = "Puntuación: " .. highestScore .. "/" .. self.CurrentQuestion
    else
        questionLabel.Text = "¡NO HAY GANADORES!"
        timerLabel.Text = "¡Mejor suerte la próxima vez!"
    end
    
    wait(10)
    
    -- Reset game
    self:ResetGame()
end

function GameManager:GivePrize(winner)
    print("Premio otorgado a " .. winner.Name)
    
    -- Create prize effect
    if winner.Character and winner.Character:FindFirstChild("HumanoidRootPart") then
        local attachment = Instance.new("Attachment")
        attachment.Parent = winner.Character.HumanoidRootPart
        
        local particles = Instance.new("ParticleEmitter")
        particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        particles.Lifetime = NumberRange.new(1.0, 3.0)
        particles.Rate = 50
        particles.SpreadAngle = Vector2.new(45, 45)
        particles.Speed = NumberRange.new(5)
        particles.Parent = attachment
        
        wait(5)
        attachment:Destroy()
    end
end

function GameManager:ResetGame()
    -- Reset all game variables
    self.CurrentQuestion = 1
    self.GameActive = false
    self.Players = {}
    
    -- Reset all desks
    for i, deskData in ipairs(self.Desks) do
        deskData.occupied = false
        deskData.player = nil
        deskData.answered = false
        deskData.correctAnswer = false
        deskData.desk.BrickColor = BrickColor.new("Institutional white")
        deskData.chair.BrickColor = BrickColor.new("Really red")
        
        -- Reset desk GUI
        local surfaceGui = deskData.desk.SurfaceGui
        for j = 1, 4 do
            local button = surfaceGui.Frame["Option" .. j]
            button.Text = "?"
            button.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
        end
    end
    
    -- Reset blackboard
    local questionLabel = self.Blackboard.SurfaceGui.QuestionLabel
    local timerLabel = self.Blackboard.SurfaceGui.TimerLabel
    local progressLabel = self.Blackboard.SurfaceGui.ProgressLabel
    
    questionLabel.Text = "Esperando jugadores..."
    timerLabel.Text = "El juego comenzará cuando haya suficientes jugadores"
    progressLabel.Text = "Pregunta 0/100"
end

-- Player connection handlers
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(2) -- Wait for character to fully load
        GameManager:AssignPlayerToDesk(player)
        
        -- Start game with any number of players (minimum 2)
        if #Players:GetPlayers() >= 2 and not GameManager.GameActive then
            wait(5)
            GameManager:StartGame()
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    -- Free up desk
    if GameManager.Players[player.UserId] then
        local deskIndex = GameManager.Players[player.UserId].desk
        if GameManager.Desks[deskIndex] then
            GameManager.Desks[deskIndex].occupied = false
            GameManager.Desks[deskIndex].player = nil
        end
        GameManager.Players[player.UserId] = nil
    end
end)

-- Initialize game
GameManager:CreateClassroom()

-- Admin commands (for testing)
game.Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        if player.Name == game.CreatorId or player:GetRankInGroup(0) >= 100 then
            if message:lower() == "/startgame" then
                GameManager:StartGame()
            elseif message:lower() == "/resetgame" then
                GameManager:ResetGame()
            end
        end
    end)
end)

print("¡Squid Game Math Classroom inicializado!")
print("Los jugadores pueden unirse y serán asignados a escritorios automáticamente.")
print("El juego comienza con 2+ jugadores o usa el comando /startgame.")
