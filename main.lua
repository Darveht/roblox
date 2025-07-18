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
GameManager.MaxStudentsPerClass = 3 -- Máximo 3 estudiantes por aula
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
GameManager.MaxErrors = 2 -- Máximo de errores antes de eliminación
GameManager.MeteoriteAnimationDuration = 8 -- Duración de la animación en segundos

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
		local result = self:RegisterStudent(player, 1)

		if result == true then
			regButton.Text = "¡REGISTRADO!"
			regButton.BackgroundColor3 = Color3.new(0, 0.5, 0)
		elseif result == "FULL" then
			regButton.Text = "AULA LLENA (3/3)"
			regButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
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
		local result = self:RegisterStudent(player, 2)

		if result == true then
			regButton2.Text = "¡REGISTRADO!"
			regButton2.BackgroundColor3 = Color3.new(0, 0.5, 0)
		elseif result == "FULL" then
			regButton2.Text = "AULA LLENA (3/3)"
			regButton2.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
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
				3,
				(row - 4) * deskSpacing - 20
			)

			-- Create futuristic holographic base platform
			local holoBase = Instance.new("Part")
			holoBase.Name = "HoloBase_" .. row .. "_" .. col
			holoBase.Size = Vector3.new(10, 0.5, 6)
			holoBase.Position = deskPosition + Vector3.new(0, -2, 0)
			holoBase.Material = Enum.Material.ForceField
			holoBase.BrickColor = BrickColor.new("Cyan")
			holoBase.Anchored = true
			holoBase.Transparency = 0.3
			holoBase.Parent = workspace

			-- Add glowing effect to base
			local baseGlow = Instance.new("PointLight")
			baseGlow.Brightness = 2
			baseGlow.Range = 15
			baseGlow.Color = Color3.new(0, 1, 1)
			baseGlow.Parent = holoBase

			-- Create main holographic screen (this replaces the desk)
			local desk = Instance.new("Part")
			desk.Name = "Desk_" .. row .. "_" .. col
			desk.Size = Vector3.new(9, 6, 0.2)
			desk.Position = deskPosition + Vector3.new(0, 1, 0)
			desk.Material = Enum.Material.ForceField
			desk.BrickColor = BrickColor.new("Bright blue")
			desk.Anchored = true
			desk.Transparency = 0.1
			desk.Parent = workspace

			-- Add holographic glow effect
			local screenGlow = Instance.new("PointLight")
			screenGlow.Brightness = 3
			screenGlow.Range = 20
			screenGlow.Color = Color3.new(0, 0.5, 1)
			screenGlow.Parent = desk

			-- Create energy support pillars instead of legs
			for i = 1, 4 do
				local energyPillar = Instance.new("Part")
				energyPillar.Name = "EnergyPillar_" .. i
				energyPillar.Size = Vector3.new(0.8, 4, 0.8)
				energyPillar.Material = Enum.Material.Neon
				energyPillar.BrickColor = BrickColor.new("Electric blue")
				energyPillar.Anchored = true
				energyPillar.Transparency = 0.2
				energyPillar.Parent = workspace

				local xOffset = (i <= 2) and -4 or 4
				local zOffset = (i % 2 == 1) and -2.5 or 2.5
				energyPillar.Position = deskPosition + Vector3.new(xOffset, -1, zOffset)

				-- Add energy effect to pillars
				local pillarGlow = Instance.new("PointLight")
				pillarGlow.Brightness = 1.5
				pillarGlow.Range = 10
				pillarGlow.Color = Color3.new(0, 0.8, 1)
				pillarGlow.Parent = energyPillar

				-- Add particle effect to pillars
				local attachment = Instance.new("Attachment")
				attachment.Parent = energyPillar

				local particles = Instance.new("ParticleEmitter")
				particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
				particles.Lifetime = NumberRange.new(0.5, 1.5)
				particles.Rate = 20
				particles.SpreadAngle = Vector2.new(15, 15)
				particles.Speed = NumberRange.new(3)
				particles.Color = ColorSequence.new(Color3.new(0, 0.8, 1))
				particles.Parent = attachment
			end

			-- Create futuristic floating chair with energy field
			local chair = Instance.new("Part")
			chair.Name = "Chair_" .. row .. "_" .. col
			chair.Size = Vector3.new(4, 0.6, 4)
			chair.Position = deskPosition + Vector3.new(0, 1.5, -6)
			chair.Material = Enum.Material.ForceField
			chair.BrickColor = BrickColor.new("Bright violet")
			chair.Anchored = true
			chair.Transparency = 0.2
			chair.Shape = Enum.PartType.Cylinder
			chair.Parent = workspace

			-- Add chair glow effect
			local chairGlow = Instance.new("PointLight")
			chairGlow.Brightness = 2
			chairGlow.Range = 12
			chairGlow.Color = Color3.new(0.8, 0, 1)
			chairGlow.Parent = chair

			-- Add floating seat functionality
			local seat = Instance.new("Seat")
			seat.Name = "Seat_" .. row .. "_" .. col
			seat.Size = Vector3.new(3.5, 0.3, 3.5)
			seat.Position = deskPosition + Vector3.new(0, 2.2, -6)
			seat.Material = Enum.Material.Neon
			seat.BrickColor = BrickColor.new("Magenta")
			seat.Anchored = true
			seat.Disabled = false -- Enable sitting
			seat.Transparency = 0.1
			-- Orient the seat to face the holographic screen
			seat.CFrame = CFrame.new(seat.Position, seat.Position + Vector3.new(0, 0, 1))
			seat.Parent = workspace

			-- Add seat glow
			local seatGlow = Instance.new("PointLight")
			seatGlow.Brightness = 1.5
			seatGlow.Range = 8
			seatGlow.Color = Color3.new(1, 0, 0.8)
			seatGlow.Parent = seat

			-- Create energy field back support
			local chairBack = Instance.new("Part")
			chairBack.Name = "ChairBack_" .. row .. "_" .. col
			chairBack.Size = Vector3.new(4, 6, 0.3)
			chairBack.Position = deskPosition + Vector3.new(0, 4, -8)
			chairBack.Material = Enum.Material.ForceField
			chairBack.BrickColor = BrickColor.new("Bright violet")
			chairBack.Anchored = true
			chairBack.Transparency = 0.3
			chairBack.Parent = workspace

			-- Add back support glow
			local backGlow = Instance.new("PointLight")
			backGlow.Brightness = 1.8
			backGlow.Range = 10
			backGlow.Color = Color3.new(0.6, 0, 1)
			backGlow.Parent = chairBack

			-- Create floating energy orbs instead of legs
			for i = 1, 3 do
				local energyOrb = Instance.new("Part")
				energyOrb.Name = "EnergyOrb_" .. i
				energyOrb.Size = Vector3.new(1, 1, 1)
				energyOrb.Shape = Enum.PartType.Ball
				energyOrb.Material = Enum.Material.Neon
				energyOrb.BrickColor = BrickColor.new("Electric blue")
				energyOrb.Anchored = true
				energyOrb.Transparency = 0.1
				energyOrb.Parent = workspace

				-- Position orbs in a triangle under the chair
				local angle = (i - 1) * 120 -- 120 degrees apart
				local radius = 2.5
				local xOffset = math.cos(math.rad(angle)) * radius
				local zOffset = math.sin(math.rad(angle)) * radius
				energyOrb.Position = deskPosition + Vector3.new(xOffset, 0.5, zOffset - 6)

				-- Add orb glow
				local orbGlow = Instance.new("PointLight")
				orbGlow.Brightness = 2
				orbGlow.Range = 8
				orbGlow.Color = Color3.new(0, 1, 1)
				orbGlow.Parent = energyOrb

				-- Add floating animation
				local orbTween = TweenService:Create(
					energyOrb,
					TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{Position = energyOrb.Position + Vector3.new(0, 1, 0)}
				)
				orbTween:Play()
			end

			-- Create futuristic holographic nameplate
			local nameplate = Instance.new("Part")
			nameplate.Name = "Nameplate_" .. row .. "_" .. col
			nameplate.Size = Vector3.new(5, 2.5, 0.1)
			nameplate.Position = deskPosition + Vector3.new(0, 7, -8.5)
			nameplate.Material = Enum.Material.ForceField
			nameplate.BrickColor = BrickColor.new("Cyan")
			nameplate.Anchored = true
			nameplate.Transparency = 0.8 -- Initially semi-transparent
			nameplate.Parent = workspace

			-- Add nameplate glow
			local nameplateGlow = Instance.new("PointLight")
			nameplateGlow.Brightness = 1.5
			nameplateGlow.Range = 10
			nameplateGlow.Color = Color3.new(0, 1, 1)
			nameplateGlow.Parent = nameplate

			-- Add player info GUI to nameplate
			local nameplateGui = Instance.new("SurfaceGui")
			nameplateGui.Face = Enum.NormalId.Front
			nameplateGui.Parent = nameplate

			-- Circular profile picture frame
			local profileFrame = Instance.new("Frame")
			profileFrame.Name = "ProfileFrame"
			profileFrame.Size = UDim2.new(0.4, 0, 0.8, 0)
			profileFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
			profileFrame.BackgroundColor3 = Color3.new(1, 1, 1)
			profileFrame.BorderSizePixel = 2
			profileFrame.Parent = nameplateGui

			-- Make frame circular
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = profileFrame

			-- Profile picture
			local profilePicture = Instance.new("ImageLabel")
			profilePicture.Name = "ProfilePicture"
			profilePicture.Size = UDim2.new(1, -4, 1, -4)
			profilePicture.Position = UDim2.new(0, 2, 0, 2)
			profilePicture.BackgroundTransparency = 1
			profilePicture.Image = ""
			profilePicture.Parent = profileFrame

			-- Make picture circular
			local pictureCorner = Instance.new("UICorner")
			pictureCorner.CornerRadius = UDim.new(1, 0)
			pictureCorner.Parent = profilePicture

			-- Player name label
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Name = "PlayerName"
			nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
			nameLabel.Position = UDim2.new(0.5, 0, 0, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = ""
			nameLabel.TextColor3 = Color3.new(0, 0, 0)
			nameLabel.TextScaled = true
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.Parent = nameplateGui

			-- Create holographic interface on screen
			local surfaceGui = Instance.new("SurfaceGui")
			surfaceGui.Face = Enum.NormalId.Front
			surfaceGui.Parent = desk

			local answerFrame = Instance.new("Frame")
			answerFrame.Size = UDim2.new(1, 0, 1, 0)
			answerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
			answerFrame.BackgroundTransparency = 0.2
			answerFrame.BorderSizePixel = 0
			answerFrame.Parent = surfaceGui

			-- Add holographic border effect
			local borderGradient = Instance.new("UIGradient")
			borderGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.new(0, 1, 1)),
				ColorSequenceKeypoint.new(0.5, Color3.new(0, 0.5, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(0.5, 0, 1))
			}
			borderGradient.Parent = answerFrame

			-- Add scanning line effect
			local scanLine = Instance.new("Frame")
			scanLine.Name = "ScanLine"
			scanLine.Size = UDim2.new(1, 0, 0.02, 0)
			scanLine.Position = UDim2.new(0, 0, 0, 0)
			scanLine.BackgroundColor3 = Color3.new(0, 1, 1)
			scanLine.BorderSizePixel = 0
			scanLine.Parent = answerFrame

			-- Animate scanning line
			local scanTween = TweenService:Create(
				scanLine,
				TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
				{Position = UDim2.new(0, 0, 1, 0)}
			)
			scanTween:Play()

			-- Create futuristic answer buttons
			for i = 1, 4 do
				local button = Instance.new("TextButton")
				button.Name = "Option" .. i
				button.Size = UDim2.new(0.42, 0, 0.35, 0)
				button.Position = UDim2.new(
					((i - 1) % 2) * 0.47 + 0.04,
					0,
					math.floor((i - 1) / 2) * 0.45 + 0.1,
					0
				)
				button.BackgroundColor3 = Color3.new(0, 0.2, 0.4)
				button.BorderSizePixel = 2
				button.BorderColor3 = Color3.new(0, 1, 1)
				button.Text = "?"
				button.TextColor3 = Color3.new(0, 1, 1)
				button.TextScaled = true
				button.Font = Enum.Font.Code
				button.Parent = answerFrame

				-- Add corner radius for futuristic look
				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 8)
				corner.Parent = button

				-- Add glow effect to buttons
				local buttonGlow = Instance.new("UIStroke")
				buttonGlow.Thickness = 2
				buttonGlow.Color = Color3.new(0, 1, 1)
				buttonGlow.Transparency = 0.3
				buttonGlow.Parent = button

				-- Button hover effect
				button.MouseEnter:Connect(function()
					button.BackgroundColor3 = Color3.new(0, 0.4, 0.6)
					buttonGlow.Color = Color3.new(1, 1, 0)
				end)

				button.MouseLeave:Connect(function()
					button.BackgroundColor3 = Color3.new(0, 0.2, 0.4)
					buttonGlow.Color = Color3.new(0, 1, 1)
				end)

				-- Button click handler with effect
				button.MouseButton1Click:Connect(function()
					-- Flash effect when clicked
					button.BackgroundColor3 = Color3.new(1, 1, 1)
					wait(0.1)
					button.BackgroundColor3 = Color3.new(0, 0.2, 0.4)

					self:SubmitAnswer(desk, i)
				end)
			end

			-- Store desk info
			table.insert(self.Desks, {
				desk = desk,
				chair = chair,
				seat = seat,
				nameplate = nameplate,
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

	-- Check if classroom is full
	if #self.RegisteredStudents[aula] >= self.MaxStudentsPerClass then
		return "FULL"
	end

	-- Check if already registered in this classroom
	for _, registeredPlayer in ipairs(self.RegisteredStudents[aula]) do
		if registeredPlayer.UserId == player.UserId then
			return false -- Already registered
		end
	end

	-- Check if registered in other classroom
	for aulaName, students in pairs(self.RegisteredStudents) do
		if aulaName ~= aula then
			for _, registeredPlayer in ipairs(students) do
				if registeredPlayer.UserId == player.UserId then
					return false -- Already registered in another classroom
				end
			end
		end
	end

	-- Register student
	table.insert(self.RegisteredStudents[aula], player)

	-- Update counter on registration board
	self:UpdateStudentCounter(classroom)

	-- Check if we should auto-start the game
	local totalRegistered = #self.RegisteredStudents.Aula1 + #self.RegisteredStudents.Aula2
	if totalRegistered >= 2 and not self.GameActive then
		self:AutoStartGame()
	end

	return true
end

function GameManager:UpdateStudentCounter(classroom)
	local aula = "Aula" .. classroom
	local boardName = "RegistrationBoard" .. classroom
	local board = game.Workspace:FindFirstChild(boardName)
	if board and board.SurfaceGui then
		local counter = board.SurfaceGui:FindFirstChild("StudentCount" .. classroom)
		if counter then
			counter.Text = "Estudiantes registrados: " .. #self.RegisteredStudents[aula] .. "/3"
		end
	end
end

function GameManager:UpdateAllCounters()
	-- Update both classroom counters
	self:UpdateStudentCounter(1)
	self:UpdateStudentCounter(2)

	-- Update blackboard with total registration info
	if self.Blackboard and self.Blackboard.SurfaceGui then
		local totalRegistered = #self.RegisteredStudents.Aula1 + #self.RegisteredStudents.Aula2
		local questionLabel = self.Blackboard.SurfaceGui.QuestionLabel
		local timerLabel = self.Blackboard.SurfaceGui.TimerLabel

		if not self.GameActive then
			questionLabel.Text = "Esperando jugadores..."
			timerLabel.Text = "Total registrados: " .. totalRegistered .. " (Mínimo 2 para iniciar)"

			if totalRegistered >= 2 then
				timerLabel.Text = "¡Suficientes jugadores! El juego iniciará pronto..."
			end
		end
	end
end

function GameManager:AutoStartGame()
	if self.GameActive then return end

	local totalRegistered = #self.RegisteredStudents.Aula1 + #self.RegisteredStudents.Aula2
	if totalRegistered < 2 then return end

	-- Announce countdown
	local questionLabel = self.Blackboard.SurfaceGui.QuestionLabel
	local timerLabel = self.Blackboard.SurfaceGui.TimerLabel

	questionLabel.Text = "¡INICIANDO JUEGO AUTOMÁTICAMENTE!"
	timerLabel.Text = "El juego comenzará en 10 segundos..."

	for i = 10, 1, -1 do
		timerLabel.Text = "El juego comenzará en " .. i .. " segundos..."
		wait(1)
	end

	-- Assign registered players to desks
	for aula, students in pairs(self.RegisteredStudents) do
		for _, player in ipairs(students) do
			if player.Character then
				self:AssignPlayerToDesk(player)
			end
		end
	end

	self:StartGame()
end

function GameManager:CreateArrowPath(startPos, endPos, player)
	local distance = (endPos - startPos).Magnitude
	local segments = math.floor(distance / 8) -- Arrow every 8 studs

	for i = 1, segments do
		local progress = i / segments
		local arrowPos = startPos:Lerp(endPos, progress)
		arrowPos = arrowPos + Vector3.new(0, 0.5, 0) -- Slightly above ground

		local arrow = Instance.new("Part")
		arrow.Name = "Arrow_" .. player.UserId .. "_" .. i
		arrow.Size = Vector3.new(2, 0.2, 4)
		arrow.Position = arrowPos
		arrow.Material = Enum.Material.Neon
		arrow.BrickColor = BrickColor.new("Bright green")
		arrow.Anchored = true
		arrow.Shape = Enum.PartType.Cylinder
		arrow.Parent = workspace

		-- Orient arrow towards destination
		local direction = (endPos - startPos).Unit
		arrow.CFrame = CFrame.lookAt(arrowPos, arrowPos + direction)
		arrow.CFrame = arrow.CFrame * CFrame.Angles(0, math.rad(90), 0)

		-- Add pulsing effect
		local tween = TweenService:Create(
			arrow,
			TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{Transparency = 0.7}
		)
		tween:Play()

		-- Remove arrow after 15 seconds
		game:GetService("Debris"):AddItem(arrow, 15)
	end

	-- Create final destination marker
	local marker = Instance.new("Part")
	marker.Name = "DeskMarker_" .. player.UserId
	marker.Size = Vector3.new(6, 0.2, 6)
	marker.Position = endPos + Vector3.new(0, 0.1, 0)
	marker.Material = Enum.Material.Neon
	marker.BrickColor = BrickColor.new("Bright yellow")
	marker.Anchored = true
	marker.Shape = Enum.PartType.Cylinder
	marker.Parent = workspace

	-- Add pulsing effect to marker
	local markerTween = TweenService:Create(
		marker,
		TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Transparency = 0.5, Size = Vector3.new(8, 0.2, 8)}
	)
	markerTween:Play()

	-- Remove marker after 20 seconds
	game:GetService("Debris"):AddItem(marker, 20)
end

function GameManager:AssignPlayerToDesk(player)
	for i, deskData in ipairs(self.Desks) do
		if not deskData.occupied then
			deskData.occupied = true
			deskData.player = player

			-- Update nameplate with player info
			local nameplate = deskData.nameplate
			nameplate.Transparency = 0 -- Make visible

			local nameplateGui = nameplate.SurfaceGui
			local profilePicture = nameplateGui.ProfileFrame.ProfilePicture
			local nameLabel = nameplateGui.PlayerName

			-- Set player profile picture
			profilePicture.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"

			-- Set player name
			nameLabel.Text = player.Name

			-- Create arrow path from spawn to desk (first time registration)
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local startPos = player.Character.HumanoidRootPart.Position
				local endPos = deskData.desk.Position
				self:CreateArrowPath(startPos, endPos, player)

				-- Show welcome message
				local gui = Instance.new("ScreenGui")
				gui.Name = "WelcomeGui"
				gui.Parent = player.PlayerGui

				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(0.6, 0, 0.2, 0)
				frame.Position = UDim2.new(0.2, 0, 0.1, 0)
				frame.BackgroundColor3 = Color3.new(0, 0.8, 0)
				frame.BorderSizePixel = 0
				frame.Parent = gui

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 10)
				corner.Parent = frame

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = "¡Bienvenido! Sigue las flechas verdes hacia tu asiento asignado 🪑"
				label.TextColor3 = Color3.new(1, 1, 1)
				label.TextScaled = true
				label.Font = Enum.Font.GothamBold
				label.Parent = frame

				-- Remove welcome message after 8 seconds
				game:GetService("Debris"):AddItem(gui, 8)
			end

			-- Add player to game
			self.Players[player.UserId] = {
				player = player,
				desk = i,
				score = 0,
				alive = true,
				errors = 0,
				lastAnswerCorrect = false
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
			local playerData = self.Players[deskData.player.UserId]

			deskData.answered = true

			if selectedAnswer == self.CurrentCorrectAnswer then
				deskData.correctAnswer = true
				selectedButton.BackgroundColor3 = Color3.new(0, 1, 0) -- Green
				selectedButton.BorderColor3 = Color3.new(0, 1, 0)
				selectedButton.Text = "✓ " .. selectedButton.Text
				playerData.score = playerData.score + 1
				playerData.lastAnswerCorrect = true

				-- Add success effect
				local successGlow = selectedButton:FindFirstChild("UIStroke")
				if successGlow then
					successGlow.Color = Color3.new(0, 1, 0)
					successGlow.Thickness = 4
				end
			else
				deskData.correctAnswer = false
				selectedButton.BackgroundColor3 = Color3.new(1, 0, 0) -- Red
				selectedButton.BorderColor3 = Color3.new(1, 0, 0)
				selectedButton.Text = "✗ " .. selectedButton.Text
				playerData.errors = playerData.errors + 1
				playerData.lastAnswerCorrect = false

				-- Add error effect
				local errorGlow = selectedButton:FindFirstChild("UIStroke")
				if errorGlow then
					errorGlow.Color = Color3.new(1, 0, 0)
					errorGlow.Thickness = 4
				end

				-- Show error counter on nameplate
				self:UpdateErrorDisplay(deskData.nameplate, playerData.errors)

				-- Flash red warning on desk
				self:FlashDeskWarning(deskData.desk)
			end

			break
		end
	end
end

function GameManager:UpdateErrorDisplay(nameplate, errorCount)
	local nameplateGui = nameplate.SurfaceGui

	-- Add error counter if it doesn't exist
	local errorLabel = nameplateGui:FindFirstChild("ErrorLabel")
	if not errorLabel then
		errorLabel = Instance.new("TextLabel")
		errorLabel.Name = "ErrorLabel"
		errorLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
		errorLabel.Position = UDim2.new(0.7, 0, 0.6, 0)
		errorLabel.BackgroundColor3 = Color3.new(1, 0, 0)
		errorLabel.TextColor3 = Color3.new(1, 1, 1)
		errorLabel.TextScaled = true
		errorLabel.Font = Enum.Font.GothamBold
		errorLabel.Parent = nameplateGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = errorLabel
	end

	errorLabel.Text = "❌ " .. errorCount .. "/" .. self.MaxErrors

	if errorCount >= self.MaxErrors then
		errorLabel.BackgroundColor3 = Color3.new(0.5, 0, 0)
		errorLabel.Text = "💀 ELIMINADO"
	end
end

function GameManager:FlashDeskWarning(desk)
	local originalColor = desk.BrickColor

	-- Flash red 3 times
	for i = 1, 3 do
		desk.BrickColor = BrickColor.new("Really red")
		wait(0.2)
		desk.BrickColor = originalColor
		wait(0.2)
	end
end

function GameManager:CreateSkipButton(player)
	local gui = Instance.new("ScreenGui")
	gui.Name = "MeteoriteSkipGui"
	gui.Parent = player.PlayerGui

	local skipButton = Instance.new("TextButton")
	skipButton.Name = "SkipButton"
	skipButton.Size = UDim2.new(0.15, 0, 0.08, 0)
	skipButton.Position = UDim2.new(0.82, 0, 0.1, 0)
	skipButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	skipButton.BorderColor3 = Color3.new(1, 1, 1)
	skipButton.BorderSizePixel = 2
	skipButton.Text = "⏭️ OMITIR"
	skipButton.TextColor3 = Color3.new(1, 1, 1)
	skipButton.TextScaled = true
	skipButton.Font = Enum.Font.GothamBold
	skipButton.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = skipButton

	local skipped = false
	skipButton.MouseButton1Click:Connect(function()
		if not skipped then
			skipped = true
			gui:Destroy()
		end
	end)

	return gui, skipped
end

function GameManager:CreateEpicMeteoriteAnimation(player)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character.HumanoidRootPart
	local camera = workspace.CurrentCamera

	-- Store original camera settings
	local originalCameraType = camera.CameraType
	local originalCameraSubject = camera.CameraSubject

	-- Create skip button for all players
	local skipGuis = {}
	local skipped = false

	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local skipGui, isSkipped = self:CreateSkipButton(plr)
			table.insert(skipGuis, {gui = skipGui, player = plr, skipped = isSkipped})
		end
	end

	-- Phase 1: Space view - Meteorite forming
	camera.CameraType = Enum.CameraType.Scriptable

	local spacePosition = Vector3.new(0, 500, 0)
	camera.CFrame = CFrame.new(spacePosition, spacePosition + Vector3.new(0, -1, 0))

	-- Create space meteorite
	local spaceMeteor = Instance.new("Part")
	spaceMeteor.Name = "SpaceMeteor"
	spaceMeteor.Size = Vector3.new(20, 20, 20)
	spaceMeteor.Shape = Enum.PartType.Ball
	spaceMeteor.Position = Vector3.new(0, 800, 0)
	spaceMeteor.Material = Enum.Material.Rock
	spaceMeteor.BrickColor = BrickColor.new("Really black")
	spaceMeteor.Anchored = true
	spaceMeteor.Parent = workspace

	-- Add space effects
	local spaceGlow = Instance.new("PointLight")
	spaceGlow.Brightness = 5
	spaceGlow.Range = 50
	spaceGlow.Color = Color3.new(1, 0.5, 0)
	spaceGlow.Parent = spaceMeteor

	-- Create cosmic fire effect
	local spaceAttachment = Instance.new("Attachment")
	spaceAttachment.Parent = spaceMeteor

	local cosmicParticles = Instance.new("ParticleEmitter")
	cosmicParticles.Texture = "rbxasset://textures/particles/fire_main.dds"
	cosmicParticles.Lifetime = NumberRange.new(1.0, 3.0)
	cosmicParticles.Rate = 200
	cosmicParticles.SpreadAngle = Vector2.new(180, 180)
	cosmicParticles.Speed = NumberRange.new(15)
	cosmicParticles.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1, 0.5, 0)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
	}
	cosmicParticles.Parent = spaceAttachment

	-- Check for skip
	wait(0.5)
	for _, skipData in ipairs(skipGuis) do
		if skipData.skipped then
			skipped = true
			break
		end
	end

	if not skipped then
		-- Phase 2: Zoom towards Earth
		local earthPosition = Vector3.new(0, 300, 0)

		local zoomTween = TweenService:Create(
			camera,
			TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{CFrame = CFrame.new(earthPosition, earthPosition + Vector3.new(0, -1, 0))}
		)
		zoomTween:Play()

		local meteorTween = TweenService:Create(
			spaceMeteor,
			TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{Position = Vector3.new(0, 400, 0), Size = Vector3.new(15, 15, 15)}
		)
		meteorTween:Play()

		wait(2)

		-- Check for skip again
		for _, skipData in ipairs(skipGuis) do
			if skipData.skipped then
				skipped = true
				break
			end
		end
	end

	if not skipped then
		-- Phase 3: Atmospheric entry
		local atmosPosition = Vector3.new(rootPart.Position.X, 150, rootPart.Position.Z + 30)

		local atmosTween = TweenService:Create(
			camera,
			TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{CFrame = CFrame.new(atmosPosition, rootPart.Position)}
		)
		atmosTween:Play()

		-- Move meteor towards player
		local targetPos = rootPart.Position + Vector3.new(0, 100, 0)
		local entryTween = TweenService:Create(
			spaceMeteor,
			TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{Position = targetPos, Size = Vector3.new(8, 8, 8)}
		)
		entryTween:Play()

		-- Add atmospheric trail effect
		local trailAttachment = Instance.new("Attachment")
		trailAttachment.Parent = spaceMeteor

		local trail = Instance.new("Trail")
		trail.Attachment0 = trailAttachment
		trail.Attachment1 = trailAttachment
		trail.Lifetime = 2
		trail.MinLength = 0
		trail.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
		}
		trail.Parent = spaceMeteor

		wait(1.5)

		-- Check for skip one more time
		for _, skipData in ipairs(skipGuis) do
			if skipData.skipped then
				skipped = true
				break
			end
		end
	end

	if not skipped then
		-- Phase 4: Final approach and impact
		local finalPosition = Vector3.new(rootPart.Position.X + 15, 8, rootPart.Position.Z + 15)

		local finalTween = TweenService:Create(
			camera,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{CFrame = CFrame.new(finalPosition, rootPart.Position)}
		)
		finalTween:Play()

		-- Final descent
		local impactTween = TweenService:Create(
			spaceMeteor,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{Position = rootPart.Position + Vector3.new(0, 5, 0)}
		)
		impactTween:Play()

		wait(1)
	end

	-- Phase 5: Impact and destruction
	spaceMeteor.Position = rootPart.Position
	spaceMeteor.Anchored = false

	-- Create massive explosion
	local explosion = Instance.new("Explosion")
	explosion.Position = rootPart.Position
	explosion.BlastRadius = 25
	explosion.BlastPressure = 500000
	explosion.Visible = true
	explosion.Parent = workspace

	-- Add dramatic screen shake effect for all players
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			spawn(function()
				local playerCamera = workspace.CurrentCamera
				local originalCFrame = playerCamera.CFrame

				for i = 1, 10 do
					local randomOffset = Vector3.new(
						math.random(-2, 2),
						math.random(-2, 2),
						math.random(-2, 2)
					)
					playerCamera.CFrame = originalCFrame + randomOffset
					wait(0.1)
				end

				playerCamera.CFrame = originalCFrame
			end)
		end
	end

	-- Eliminate player
	if humanoid then
		humanoid.Health = 0
	end

	-- Clean up space meteor
	game:GetService("Debris"):AddItem(spaceMeteor, 5)

	wait(2)

	-- Restore camera for all players
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("Humanoid") then
			workspace.CurrentCamera.CameraType = originalCameraType
			workspace.CurrentCamera.CameraSubject = plr.Character.Humanoid
		end
	end

	-- Clean up skip GUIs
	for _, skipData in ipairs(skipGuis) do
		if skipData.gui and skipData.gui.Parent then
			skipData.gui:Destroy()
		end
	end
end

function GameManager:CreateMeteoriteStrike(player)
	-- Show elimination message
	local gui = Instance.new("ScreenGui")
	gui.Name = "EliminationGui"
	gui.Parent = player.PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.8, 0, 0.3, 0)
	label.Position = UDim2.new(0.1, 0, 0.35, 0)
	label.BackgroundColor3 = Color3.new(1, 0, 0)
	label.Text = "💀 HAS SIDO ELIMINADO 💀\n¡2 RESPUESTAS INCORRECTAS!\n\nPreparando castigo celestial..."
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = label

	wait(3)
	gui:Destroy()

	-- Launch epic meteorite animation
	self:CreateEpicMeteoriteAnimation(player)
end

function GameManager:ProcessAnswers()
	for i, deskData in ipairs(self.Desks) do
		if deskData.occupied and self.Players[deskData.player.UserId].alive then
			local playerData = self.Players[deskData.player.UserId]

			-- Check if player didn't answer or answered incorrectly
			if not deskData.answered then
				-- No answer counts as incorrect
				playerData.errors = playerData.errors + 1
				self:UpdateErrorDisplay(deskData.nameplate, playerData.errors)
				self:FlashDeskWarning(deskData.desk)
			end

			-- Check if player has reached maximum errors
			if playerData.errors >= self.MaxErrors then
				-- Player is eliminated with epic meteorite strike
				playerData.alive = false

				-- Launch epic meteorite animation
				spawn(function()
					self:CreateMeteoriteStrike(deskData.player)
				end)

				-- Change desk color to red to indicate elimination
				deskData.desk.BrickColor = BrickColor.new("Really red")
				deskData.chair.BrickColor = BrickColor.new("Really red")

				-- Update nameplate to show elimination
				self:UpdateErrorDisplay(deskData.nameplate, playerData.errors)
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
	self.CurrentCorrectAnswer = nil

	-- Reset all desks
	for i, deskData in ipairs(self.Desks) do
		deskData.occupied = false
		deskData.player = nil
		deskData.answered = false
		deskData.correctAnswer = false
		deskData.desk.BrickColor = BrickColor.new("Institutional white")
		deskData.chair.BrickColor = BrickColor.new("Really red")

		-- Hide nameplate and reset error display
		deskData.nameplate.Transparency = 1
		local nameplateGui = deskData.nameplate.SurfaceGui
		nameplateGui.ProfileFrame.ProfilePicture.Image = ""
		nameplateGui.PlayerName.Text = ""

		-- Remove error label if it exists
		local errorLabel = nameplateGui:FindFirstChild("ErrorLabel")
		if errorLabel then
			errorLabel:Destroy()
		end

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

			-- Hide nameplate
			GameManager.Desks[deskIndex].nameplate.Transparency = 1
			local nameplateGui = GameManager.Desks[deskIndex].nameplate.SurfaceGui
			nameplateGui.ProfileFrame.ProfilePicture.Image = ""
			nameplateGui.PlayerName.Text = ""
		end
		GameManager.Players[player.UserId] = nil
	end

	-- Clean up any remaining arrows for this player
	for _, arrow in pairs(workspace:GetChildren()) do
		if arrow.Name:find("Arrow_" .. player.UserId) or arrow.Name:find("DeskMarker_" .. player.UserId) then
			arrow:Destroy()
		end
	end
end)

-- Initialize game
GameManager:CreateClassroom()

-- Real-time update loop for counters
spawn(function()
	while true do
		if not GameManager.GameActive then
			GameManager:UpdateAllCounters()
		end
		wait(1) -- Update every second
	end
end)

-- Admin commands (for testing)
game.Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if player.Name == game.CreatorId or player:GetRankInGroup(0) >= 100 then
			if message:lower() == "/startgame" then
				GameManager:StartGame()
			elseif message:lower() == "/resetgame" then
				GameManager:ResetGame()
			elseif message:lower() == "/maxstudents" then
				-- Change max students to 3 for testing
				GameManager.MaxPlayers = 3
				print("Máximo de estudiantes cambiado a 3")
			end
		end
	end)
end)

print("¡Squid Game Math Classroom inicializado!")
print("Los jugadores pueden unirse y serán asignados a escritorios automáticamente.")
print("El juego comienza con 2+ jugadores o usa el comando /startgame.")
