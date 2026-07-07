local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)

local MIN_LOAD_TIME = 40
local MAX_LOAD_TIME = 45
local LOAD_DURATION = math.random(MIN_LOAD_TIME, MAX_LOAD_TIME)
local INTRO_DURATION = 2.6

local TIPS = {
	"Customize the interface to fit your playstyle",
	"Pulse Hub is optimizing your experience",
	"Loading world textures and assets",
	"Syncing player data",
	"Preparing the environment",
	"Almost ready, please wait",
}

local ACCENT_A = Color3.fromRGB(168, 118, 255)
local ACCENT_B = Color3.fromRGB(110, 168, 255)
local ACCENT_C = Color3.fromRGB(255, 130, 210)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PulseHubLoadingScreen"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 10000
screenGui.Parent = playerGui

local blocker = Instance.new("Frame")
blocker.Name = "Blocker"
blocker.Size = UDim2.fromScale(1, 1)
blocker.Position = UDim2.fromScale(0, 0)
blocker.BackgroundColor3 = Color3.fromRGB(6, 5, 12)
blocker.BorderSizePixel = 0
blocker.Active = true
blocker.Selectable = true
blocker.ZIndex = 1
blocker.ClipsDescendants = true
blocker.Parent = screenGui

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.0, Color3.fromRGB(16, 10, 34)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(26, 14, 46)),
	ColorSequenceKeypoint.new(1.0, Color3.fromRGB(8, 8, 18)),
})
bgGradient.Rotation = 45
bgGradient.Parent = blocker

local blobFolder = Instance.new("Folder")
blobFolder.Name = "Blobs"
blobFolder.Parent = blocker

local function createBlob(color, size, x, y)
	local halo = Instance.new("Frame")
	halo.AnchorPoint = Vector2.new(0.5, 0.5)
	halo.Size = UDim2.fromOffset(size, size)
	halo.Position = UDim2.fromScale(x, y)
	halo.BackgroundColor3 = color
	halo.BackgroundTransparency = 1
	halo.BorderSizePixel = 0
	halo.ZIndex = 2
	halo.Parent = blobFolder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = halo

	for i = 1, 4 do
		local ring = Instance.new("Frame")
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Position = UDim2.fromScale(0.5, 0.5)
		local scale = 1 - (i - 1) * 0.22
		ring.Size = UDim2.fromScale(scale, scale)
		ring.BackgroundColor3 = color
		ring.BackgroundTransparency = 0.9 + (i * 0.02)
		ring.BorderSizePixel = 0
		ring.ZIndex = 2
		ring.Parent = halo

		local ringCorner = Instance.new("UICorner")
		ringCorner.CornerRadius = UDim.new(1, 0)
		ringCorner.Parent = ring
	end

	return halo
end

local blob1 = createBlob(ACCENT_A, 480, 0.18, 0.22)
local blob2 = createBlob(ACCENT_B, 560, 0.82, 0.75)
local blob3 = createBlob(ACCENT_C, 380, 0.7, 0.18)

local function driftBlob(blob)
	task.spawn(function()
		while blob.Parent do
			local targetX = math.random(10, 90) / 100
			local targetY = math.random(10, 90) / 100
			local duration = math.random(9, 15)
			local tween = TweenService:Create(
				blob,
				TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ Position = UDim2.fromScale(targetX, targetY) }
			)
			tween:Play()
			tween.Completed:Wait()
		end
	end)
end

driftBlob(blob1)
driftBlob(blob2)
driftBlob(blob3)

task.spawn(function()
	local lastTime = os.clock()
	while blocker.Parent do
		local now = os.clock()
		local dt = now - lastTime
		lastTime = now
		bgGradient.Rotation = (bgGradient.Rotation + dt * 4) % 360
		RunService.Heartbeat:Wait()
	end
end)

local particlesActive = true
local particleFolder = Instance.new("Folder")
particleFolder.Name = "Particles"
particleFolder.Parent = blocker

local function spawnParticle()
	local dot = Instance.new("Frame")
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	local size = math.random(2, 4)
	dot.Size = UDim2.fromOffset(size, size)
	dot.Position = UDim2.fromScale(math.random(0, 1000) / 1000, 1.05)
	dot.BackgroundColor3 = Color3.fromRGB(220, 200, 255)
	dot.BackgroundTransparency = 0.4
	dot.BorderSizePixel = 0
	dot.ZIndex = 3
	dot.Parent = particleFolder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = dot

	local duration = math.random(60, 100) / 10

	local tween = TweenService:Create(
		dot,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{ Position = UDim2.fromScale(dot.Position.X.Scale, -0.05), BackgroundTransparency = 1 }
	)
	tween:Play()
	tween.Completed:Connect(function()
		dot:Destroy()
	end)
end

task.spawn(function()
	while particlesActive do
		spawnParticle()
		task.wait(0.35)
	end
end)

local warningLabel = Instance.new("TextLabel")
warningLabel.Name = "FallbackWarning"
warningLabel.AnchorPoint = Vector2.new(0.5, 1)
warningLabel.Position = UDim2.new(0.5, 0, 1, -18)
warningLabel.Size = UDim2.fromScale(0.9, 0.04)
warningLabel.BackgroundTransparency = 1
warningLabel.Font = Enum.Font.Gotham
warningLabel.Text = "If the loading screen does not disappear, please rejoin the game."
warningLabel.TextColor3 = Color3.fromRGB(170, 160, 195)
warningLabel.TextTransparency = 0.35
warningLabel.TextSize = 13
warningLabel.TextXAlignment = Enum.TextXAlignment.Center
warningLabel.TextYAlignment = Enum.TextYAlignment.Bottom
warningLabel.ZIndex = 9
warningLabel.Parent = blocker

local mainCard = Instance.new("Frame")
mainCard.Name = "MainCard"
mainCard.AnchorPoint = Vector2.new(0.5, 0.5)
mainCard.Position = UDim2.fromScale(0.5, 0.5)
mainCard.Size = UDim2.fromOffset(0, 0)
mainCard.BackgroundColor3 = Color3.fromRGB(18, 14, 30)
mainCard.BackgroundTransparency = 1
mainCard.BorderSizePixel = 0
mainCard.ZIndex = 5
mainCard.Parent = blocker

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 28)
cardCorner.Parent = mainCard

local cardSheen = Instance.new("UIGradient")
cardSheen.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 44, 90)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 12, 22)),
})
cardSheen.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.55),
	NumberSequenceKeypoint.new(1, 0.85),
})
cardSheen.Rotation = 90
cardSheen.Parent = mainCard

local cardStroke = Instance.new("UIStroke")
cardStroke.Thickness = 1.4
cardStroke.Transparency = 1
cardStroke.Parent = mainCard

local cardStrokeGradient = Instance.new("UIGradient")
cardStrokeGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, ACCENT_A),
	ColorSequenceKeypoint.new(0.5, ACCENT_B),
	ColorSequenceKeypoint.new(1, ACCENT_C),
})
cardStrokeGradient.Parent = cardStroke

task.spawn(function()
	local lastTime = os.clock()
	while mainCard.Parent do
		local now = os.clock()
		local dt = now - lastTime
		lastTime = now
		cardStrokeGradient.Rotation = (cardStrokeGradient.Rotation + dt * 25) % 360
		RunService.Heartbeat:Wait()
	end
end)

local cardHalo = Instance.new("Frame")
cardHalo.AnchorPoint = Vector2.new(0.5, 0.5)
cardHalo.Position = UDim2.fromScale(0.5, 0.5)
cardHalo.Size = UDim2.fromScale(1.12, 1.18)
cardHalo.BackgroundColor3 = ACCENT_A
cardHalo.BackgroundTransparency = 1
cardHalo.BorderSizePixel = 0
cardHalo.ZIndex = 3
cardHalo.Parent = mainCard

local cardHaloCorner = Instance.new("UICorner")
cardHaloCorner.CornerRadius = UDim.new(0, 40)
cardHaloCorner.Parent = cardHalo

local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.AnchorPoint = Vector2.new(0.5, 0.5)
divider.Position = UDim2.fromScale(0.5, 0.4)
divider.Size = UDim2.fromScale(0.55, 0)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 1
divider.BorderSizePixel = 0
divider.ZIndex = 6
divider.Parent = mainCard

local dividerGradient = Instance.new("UIGradient")
dividerGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0.4),
	NumberSequenceKeypoint.new(1, 1),
})
dividerGradient.Parent = divider

local logoContainer = Instance.new("Frame")
logoContainer.Name = "LogoContainer"
logoContainer.AnchorPoint = Vector2.new(0.5, 0.5)
logoContainer.Position = UDim2.fromScale(0.5, 0.24)
logoContainer.Size = UDim2.fromScale(0.82, 0.24)
logoContainer.BackgroundTransparency = 1
logoContainer.ZIndex = 6
logoContainer.Parent = mainCard

local glowLabel = Instance.new("TextLabel")
glowLabel.Name = "Glow"
glowLabel.Size = UDim2.fromScale(1, 1)
glowLabel.BackgroundTransparency = 1
glowLabel.Font = Enum.Font.GothamBlack
glowLabel.Text = "PULSE HUB"
glowLabel.TextColor3 = ACCENT_A
glowLabel.TextTransparency = 1
glowLabel.TextScaled = true
glowLabel.ZIndex = 6
glowLabel.Parent = logoContainer

local glowStroke = Instance.new("UIStroke")
glowStroke.Thickness = 6
glowStroke.Color = ACCENT_A
glowStroke.Transparency = 0.7
glowStroke.Parent = glowLabel

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.fromScale(1, 1)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.Text = "PULSE HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextTransparency = 1
titleLabel.TextScaled = true
titleLabel.ZIndex = 7
titleLabel.Parent = logoContainer

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.5, ACCENT_B),
	ColorSequenceKeypoint.new(1, ACCENT_A),
})
titleGradient.Parent = titleLabel

local introSubtitle = Instance.new("TextLabel")
introSubtitle.Name = "IntroSubtitle"
introSubtitle.AnchorPoint = Vector2.new(0.5, 0.5)
introSubtitle.Position = UDim2.fromScale(0.5, 0.62)
introSubtitle.Size = UDim2.fromScale(0.8, 0.16)
introSubtitle.BackgroundTransparency = 1
introSubtitle.Font = Enum.Font.Gotham
introSubtitle.Text = "Launching"
introSubtitle.TextColor3 = Color3.fromRGB(205, 195, 235)
introSubtitle.TextTransparency = 1
introSubtitle.TextSize = 17
introSubtitle.ZIndex = 6
introSubtitle.Parent = mainCard

local introDotsActive = true
task.spawn(function()
	local states = { "Launching", "Launching.", "Launching..", "Launching..." }
	local i = 1
	while introDotsActive do
		introSubtitle.Text = states[i]
		i = (i % #states) + 1
		task.wait(0.35)
	end
end)

local spinnerContainer = Instance.new("Frame")
spinnerContainer.Name = "Spinner"
spinnerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
spinnerContainer.Position = UDim2.fromScale(0.5, 0.52)
spinnerContainer.Size = UDim2.fromOffset(84, 84)
spinnerContainer.BackgroundTransparency = 1
spinnerContainer.ZIndex = 6
spinnerContainer.Parent = mainCard

local spinnerHalo = Instance.new("Frame")
spinnerHalo.AnchorPoint = Vector2.new(0.5, 0.5)
spinnerHalo.Position = UDim2.fromScale(0.5, 0.5)
spinnerHalo.Size = UDim2.fromScale(1.6, 1.6)
spinnerHalo.BackgroundColor3 = ACCENT_B
spinnerHalo.BackgroundTransparency = 1
spinnerHalo.BorderSizePixel = 0
spinnerHalo.ZIndex = 5
spinnerHalo.Parent = spinnerContainer

local spinnerHaloCorner = Instance.new("UICorner")
spinnerHaloCorner.CornerRadius = UDim.new(1, 0)
spinnerHaloCorner.Parent = spinnerHalo

local TICK_COUNT = 12
local ticks = {}

for i = 1, TICK_COUNT do
	local angle = (i - 1) * (360 / TICK_COUNT)
	local tick = Instance.new("Frame")
	tick.Name = "Tick" .. i
	tick.AnchorPoint = Vector2.new(0.5, 0.5)
	tick.Size = UDim2.fromOffset(4, 13)
	tick.BackgroundColor3 = Color3.fromRGB(200, 170, 255)
	tick.BackgroundTransparency = 1
	tick.BorderSizePixel = 0
	tick.Rotation = angle
	tick.ZIndex = 7
	tick.Parent = spinnerContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = tick

	local radius = 34
	local rad = math.rad(angle - 90)
	tick.Position = UDim2.new(0.5, math.cos(rad) * radius, 0.5, math.sin(rad) * radius)

	ticks[i] = { instance = tick, index = i }
end

local spinning = true
task.spawn(function()
	local startClock = os.clock()
	while spinning do
		local elapsed = os.clock() - startClock
		for _, tickData in ipairs(ticks) do
			local offset = (tickData.index - 1) / TICK_COUNT
			local phase = (elapsed * 0.9 - offset) % 1
			tickData.instance.BackgroundTransparency = 0.15 + phase * 0.85
		end
		RunService.Heartbeat:Wait()
	end
end)

local barBackground = Instance.new("Frame")
barBackground.Name = "BarBackground"
barBackground.AnchorPoint = Vector2.new(0.5, 0.5)
barBackground.Position = UDim2.fromScale(0.5, 0.76)
barBackground.Size = UDim2.fromScale(0.78, 0.052)
barBackground.BackgroundColor3 = Color3.fromRGB(28, 20, 44)
barBackground.BackgroundTransparency = 1
barBackground.BorderSizePixel = 0
barBackground.ClipsDescendants = true
barBackground.ZIndex = 6
barBackground.Parent = mainCard

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = barBackground

local barStroke = Instance.new("UIStroke")
barStroke.Color = Color3.fromRGB(130, 100, 180)
barStroke.Thickness = 1
barStroke.Transparency = 1
barStroke.Parent = barBackground

local barFill = Instance.new("Frame")
barFill.Name = "BarFill"
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = Color3.fromRGB(180, 120, 255)
barFill.BackgroundTransparency = 1
barFill.BorderSizePixel = 0
barFill.ClipsDescendants = true
barFill.ZIndex = 7
barFill.Parent = barBackground

local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(1, 0)
barFillCorner.Parent = barFill

local barFillGradient = Instance.new("UIGradient")
barFillGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, ACCENT_B),
	ColorSequenceKeypoint.new(1, ACCENT_A),
})
barFillGradient.Parent = barFill

local shimmer = Instance.new("Frame")
shimmer.Name = "Shimmer"
shimmer.AnchorPoint = Vector2.new(0.5, 0.5)
shimmer.Size = UDim2.fromScale(0.25, 2)
shimmer.Position = UDim2.fromScale(-0.2, 0.5)
shimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
shimmer.BackgroundTransparency = 0.55
shimmer.Rotation = 20
shimmer.BorderSizePixel = 0
shimmer.ZIndex = 8
shimmer.Parent = barFill

local shimmerGradient = Instance.new("UIGradient")
shimmerGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0.4),
	NumberSequenceKeypoint.new(1, 1),
})
shimmerGradient.Parent = shimmer

local shimmerActive = true
task.spawn(function()
	while shimmerActive do
		shimmer.Position = UDim2.fromScale(-0.3, 0.5)
		local tween = TweenService:Create(
			shimmer,
			TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{ Position = UDim2.fromScale(1.3, 0.5) }
		)
		tween:Play()
		tween.Completed:Wait()
		task.wait(0.5)
	end
end)

local percentLabel = Instance.new("TextLabel")
percentLabel.Name = "Percent"
percentLabel.AnchorPoint = Vector2.new(0.5, 0.5)
percentLabel.Position = UDim2.fromScale(0.5, 0.84)
percentLabel.Size = UDim2.fromScale(0.5, 0.07)
percentLabel.BackgroundTransparency = 1
percentLabel.Font = Enum.Font.GothamBold
percentLabel.Text = "0%"
percentLabel.TextColor3 = Color3.fromRGB(225, 215, 255)
percentLabel.TextTransparency = 1
percentLabel.TextSize = 16
percentLabel.ZIndex = 6
percentLabel.Parent = mainCard

local tipContainer = Instance.new("Frame")
tipContainer.Name = "TipContainer"
tipContainer.AnchorPoint = Vector2.new(0.5, 0.5)
tipContainer.Position = UDim2.fromScale(0.5, 0.93)
tipContainer.Size = UDim2.fromScale(0.9, 0.09)
tipContainer.BackgroundTransparency = 1
tipContainer.ZIndex = 6
tipContainer.Parent = mainCard

local tipListLayout = Instance.new("UIListLayout")
tipListLayout.FillDirection = Enum.FillDirection.Horizontal
tipListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tipListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tipListLayout.Padding = UDim.new(0, 8)
tipListLayout.Parent = tipContainer

local tipBullet = Instance.new("Frame")
tipBullet.Name = "Bullet"
tipBullet.Size = UDim2.fromOffset(6, 6)
tipBullet.BackgroundColor3 = ACCENT_B
tipBullet.BackgroundTransparency = 1
tipBullet.BorderSizePixel = 0
tipBullet.ZIndex = 6
tipBullet.LayoutOrder = 1
tipBullet.Parent = tipContainer

local tipBulletCorner = Instance.new("UICorner")
tipBulletCorner.CornerRadius = UDim.new(1, 0)
tipBulletCorner.Parent = tipBullet

local tipLabel = Instance.new("TextLabel")
tipLabel.Name = "Tip"
tipLabel.Size = UDim2.fromOffset(500, 24)
tipLabel.BackgroundTransparency = 1
tipLabel.Font = Enum.Font.Gotham
tipLabel.Text = TIPS[1]
tipLabel.TextColor3 = Color3.fromRGB(180, 170, 210)
tipLabel.TextTransparency = 1
tipLabel.TextSize = 15
tipLabel.TextXAlignment = Enum.TextXAlignment.Left
tipLabel.ZIndex = 6
tipLabel.LayoutOrder = 2
tipLabel.Parent = tipContainer

local bulletPulseActive = true
task.spawn(function()
	while bulletPulseActive do
		local grow = TweenService:Create(
			tipBullet,
			TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{ BackgroundTransparency = 0.1 }
		)
		grow:Play()
		grow.Completed:Wait()
		if not bulletPulseActive then
			break
		end
		local shrink = TweenService:Create(
			tipBullet,
			TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{ BackgroundTransparency = 0.7 }
		)
		shrink:Play()
		shrink.Completed:Wait()
	end
end)

local tipCyclingActive = true
task.spawn(function()
	local index = 1
	while tipCyclingActive do
		task.wait(3.4)
		if not tipCyclingActive then
			break
		end
		index = (index % #TIPS) + 1

		local fadeOut = TweenService:Create(tipLabel, TweenInfo.new(0.4), { TextTransparency = 1 })
		fadeOut:Play()
		fadeOut.Completed:Wait()

		tipLabel.Text = TIPS[index]

		if tipCyclingActive then
			local fadeIn = TweenService:Create(tipLabel, TweenInfo.new(0.4), { TextTransparency = 0 })
			fadeIn:Play()
		end
	end
end)

local introSize = UDim2.fromOffset(420, 200)
local expandedSize = UDim2.fromOffset(580, 400)

TweenService:Create(
	mainCard,
	TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{ Size = introSize, BackgroundTransparency = 0.08 }
):Play()

TweenService:Create(cardStroke, TweenInfo.new(0.65), { Transparency = 0.15 }):Play()
TweenService:Create(cardHalo, TweenInfo.new(0.9), { BackgroundTransparency = 0.93 }):Play()
TweenService:Create(glowLabel, TweenInfo.new(0.6), { TextTransparency = 0.55 }):Play()
TweenService:Create(titleLabel, TweenInfo.new(0.6), { TextTransparency = 0 }):Play()

task.delay(0.2, function()
	TweenService:Create(introSubtitle, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()
end)

task.wait(INTRO_DURATION)

introDotsActive = false

TweenService:Create(introSubtitle, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()

local expandTween = TweenService:Create(
	mainCard,
	TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{ Size = expandedSize }
)
expandTween:Play()

task.wait(0.25)

TweenService:Create(logoContainer, TweenInfo.new(0.5), { Position = UDim2.fromScale(0.5, 0.16) }):Play()
TweenService:Create(divider, TweenInfo.new(0.5), { BackgroundTransparency = 0 }):Play()

task.delay(0.15, function()
	TweenService:Create(barBackground, TweenInfo.new(0.5), { BackgroundTransparency = 0 }):Play()
	TweenService:Create(barStroke, TweenInfo.new(0.5), { Transparency = 0.4 }):Play()
	TweenService:Create(barFill, TweenInfo.new(0.5), { BackgroundTransparency = 0 }):Play()
	TweenService:Create(percentLabel, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()
	TweenService:Create(tipLabel, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()

	for _, tickData in ipairs(ticks) do
		tickData.instance.BackgroundTransparency = 1
	end
	spinnerHalo.BackgroundTransparency = 1
	TweenService:Create(spinnerHalo, TweenInfo.new(0.6), { BackgroundTransparency = 0.9 }):Play()
end)

expandTween.Completed:Wait()

local startTime = os.clock()

local progressConnection
progressConnection = RunService.Heartbeat:Connect(function()
	local elapsed = os.clock() - startTime
	local alpha = math.clamp(elapsed / LOAD_DURATION, 0, 1)
	local eased = 1 - (1 - alpha) ^ 2

	barFill.Size = UDim2.fromScale(eased, 1)
	percentLabel.Text = math.floor(eased * 100) .. "%"

	if alpha >= 1 then
		progressConnection:Disconnect()

		task.wait(0.5)

		spinning = false
		particlesActive = false
		tipCyclingActive = false
		bulletPulseActive = false
		shimmerActive = false

		local finalFade = TweenService:Create(blocker, TweenInfo.new(0.9, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1,
		})

		TweenService:Create(mainCard, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1,
		}):Play()

		TweenService:Create(titleLabel, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		TweenService:Create(glowLabel, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		TweenService:Create(percentLabel, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		TweenService:Create(tipLabel, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		TweenService:Create(barBackground, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(barFill, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(barStroke, TweenInfo.new(0.5), { Transparency = 1 }):Play()
		TweenService:Create(cardStroke, TweenInfo.new(0.5), { Transparency = 1 }):Play()
		TweenService:Create(cardHalo, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()

		task.wait(0.9)
		finalFade:Play()
		finalFade.Completed:Wait()

		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
		end)

		screenGui:Destroy()
	end
end)
