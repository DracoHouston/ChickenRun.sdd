function widget:GetInfo()
	return {
		name      = "Chicken Run InGame Widget",
		desc      = "Vitals panel for Chicken Run and announcements/timers",
		author    = "DracoHouston",
		date      = "2024",
		license   = "GPL",
		layer     = 0,
		enabled   = true,
	}
end

--------------------------------------------------------------------------------
--locals
--------------------------------------------------------------------------------


local panelFont		  = "LuaUI/Fonts/komtxt__.ttf"
local waveFont        = LUAUI_DIRNAME.."Fonts/Skrawl_40"
local panelTexture    = LUAUI_DIRNAME.."Images/panel.tga"

local window, labelStack, background
local global_command_button
local label_wavenumandtype, label_tidelevel, label_eggquota, label_remainingtime

local WaveTime
local PhaseTime
local CurrentWaveNum = 0
local CurrentWavePhase = 0
local CurrentWaveQuota = 0
local CurrentWaveEggs = 0
local CurrentWaveType = 0
local CurrentWaveTide = 0

local Constants = { 
	MaxWaves = 4, 
	MaxEnemies = 100, 
	MaxBosses = 15,
	MaxBossesByRole = { Artillery = 6, Skirmish = 9, Rush = 15 },
	WavePhases = { PreGame = 0, InGrace = 1, InWave = 2, PostWave = 3, PostGame = 4 },
	WaveTimes = { GracePeriod = 30, Duration = 150, PostWave = 10 },
	WaveTypes = { Normal = 1, Glowflies = 2, TenderCharge = 3, Mothership = 4, Gushers = 5, Fog = 6, Grillers = 7, Tornado = 8, XtraWave = 9 }, 
	TideLevels = { Low = 1, Mid = 2, High = 3 },
}

local spGetGameSeconds = Spring.GetGameSeconds

--------------------------------------------------------------------------------
--helpers
--------------------------------------------------------------------------------

-- these both ripped out of chicken mode widget (zk:luaui/widgets/gui_chilli_chicken.lua)
local function FormatTime(s)
	if not s then return '' end
	s = math.floor(s)
	local neg = (s < 0)
	if neg then s = -s end	-- invert it here and add the minus sign later, since it breaks if we try to work on it directly
	local m = math.floor(s/60)
	s = s%60
	local h = math.floor(m/60)
	m = m%60
	if s < 10 then s = "0"..s end
	if m < 10 then m = "0"..m end
	local str = (h..":"..m..":"..s)
	if neg then str = "-"..str end
	return str
end

local function GetColor(percent)
	local midpt = (percent > 50)
	local r, g
	if midpt then
		r = 255
		g = math.floor(255*(100-percent)/50)
	else
		r = math.floor(255*percent/50)
		g = 255
	end
	return string.char(255,r,g,0)
end

local function UpdateWaveNumAndType()
	local s = "Wave " .. CurrentWaveNum .. ": "
	if CurrentWaveType == Constants.WaveTypes.Normal then
		s = s .. "Chickenid Assault!"
	elseif CurrentWaveType == Constants.WaveTypes.Glowflies then
		s = s .. "Rushing Swarm!"
	elseif CurrentWaveType == Constants.WaveTypes.TenderCharge then
		s = s .. "Spicy Tenders!"
	elseif CurrentWaveType == Constants.WaveTypes.Mothership then
		s = s .. "Special Delivery!"
	elseif CurrentWaveType == Constants.WaveTypes.Gushers then
		s = s .. "Sneaky Goldie!"
	elseif CurrentWaveType == Constants.WaveTypes.Fog then
		s = s .. "Goldies in the mist!"
	elseif CurrentWaveType == Constants.WaveTypes.Grillers then
		s = s .. "Relentless Grilling!"
	elseif CurrentWaveType == Constants.WaveTypes.Tornado then
		s = s .. [[It's raining eggs!]]
	elseif CurrentWaveType == Constants.WaveTypes.XtraWave then		
		s = s .. "Mandatory overtime!"
	end
	label_wavenumandtype:SetCaption(s)
end

local function UpdateWaveTide()
	if CurrentWaveTide == Constants.TideLevels.Mid then
		label_tidelevel:SetCaption("Forecast: Mid tide")
	elseif CurrentWaveTide == Constants.TideLevels.Low then
		label_tidelevel:SetCaption("Forecast: Low tide")
	elseif CurrentWaveTide == Constants.TideLevels.High then
		label_tidelevel:SetCaption("Forecast: High tide")
	end
end

local function UpdateWaveQuota()
	local s = "Power Eggs: " .. CurrentWaveEggs .. "/" .. CurrentWaveQuota
	label_eggquota:SetCaption(s)
end

local function UpdateRemainingTime()
	local curTime = spGetGameSeconds()
	if CurrentWavePhase == Constants.WavePhases.InGrace then
		local s = "Wave starting: " .. FormatTime(Constants.WaveTimes.GracePeriod - (curTime - PhaseTime))
		label_remainingtime:SetCaption(s)
		--Spring.Echo("called update remaining time" .. s)
	elseif CurrentWavePhase == Constants.WavePhases.InWave then
		local s = "Time remaining: " .. FormatTime(Constants.WaveTimes.Duration - (curTime - PhaseTime))
		label_remainingtime:SetCaption(s)
		--Spring.Echo("called update remaining time" .. s)
	elseif CurrentWavePhase == Constants.WavePhases.PostWave then
		local s = "Unpaid time off: " .. FormatTime(Constants.WaveTimes.PostWave - (curTime - PhaseTime))
		label_remainingtime:SetCaption(s)
		--Spring.Echo("called update remaining time" .. s)
	elseif CurrentWavePhase == Constants.WavePhases.PostGame then
		label_remainingtime:SetCaption("Eggcellent work!")
	end
end

--------------------------------------------------------------------------------
--callins
--------------------------------------------------------------------------------

function ChickenRunEvent(chickenRunEventArgs)
	--Spring.Echo("Chicken Run Event got called")
	if (chickenRunEventArgs.type == "wavestart") then
		local curTime = spGetGameSeconds()
		WaveTime = curTime
		PhaseTime = curTime
		CurrentWaveNum = chickenRunEventArgs.wavenum
		CurrentWaveTide = chickenRunEventArgs.wavetide
		CurrentWaveType = chickenRunEventArgs.wavetype
		CurrentWaveQuota = chickenRunEventArgs.wavequota
		CurrentWaveEggs = 0
		CurrentWavePhase = Constants.WavePhases.InGrace
		UpdateWaveNumAndType()
		UpdateWaveTide()
		UpdateWaveQuota()
		UpdateRemainingTime()
	elseif (chickenRunEventArgs.type == "wavephasestart") then
		CurrentWavePhase = chickenRunEventArgs.phase
		PhaseTime = spGetGameSeconds()
		UpdateRemainingTime()
	elseif (chickenRunEventArgs.type == "eggsdunked") then
		CurrentWaveEggs = CurrentWaveEggs + chickenRunEventArgs.eggs
		UpdateWaveQuota()
	end
end

--------------------------------------------------------------------------------
--widget interface
--------------------------------------------------------------------------------

function widget:Initialize()
	local Chili = WG.Chili
	if not Chili then
		widgetHandler:RemoveWidget()
		return
	end

	widgetHandler:RegisterGlobal("ChickenRunEvent", ChickenRunEvent)

	-- setup Chili
	Chili = WG.Chili
	Button = Chili.Button
	Label = Chili.Label
	Checkbox = Chili.Checkbox
	Window = Chili.Window
	Panel = Chili.Panel
	StackPanel = Chili.StackPanel
	TextBox = Chili.TextBox
	Image = Chili.Image
	Progressbar = Chili.Progressbar
	Font = Chili.Font
	Control = Chili.Control
	screen0 = Chili.Screen0
	
	--create main Chili elements
	local labelHeight = 22
	local fontSize = 16
	
	window = Window:New{
		parent = screen0,
		name   = 'chickenrunpanel';
		color = {0, 0, 0, 0},
		width = 270;
		height = 189;
		right = 0;
		y = 100,
		dockable = true;
		draggable = false,
		resizable = false,
		tweakDraggable = true,
		tweakResizable = false,
		minWidth = MIN_WIDTH,
		minHeight = MIN_HEIGHT,
		padding = {0, 0, 0, 0},
		--itemMargin  = {0, 0, 0, 0},
	}
	
	labelStack = StackPanel:New{
		parent = window,
		resizeItems = false;
		orientation   = "vertical";
		height = 180;
		width =  265;
		x = 20,
		y = 10,
		padding = {0, 0, 0, 0},
		itemMargin  = {0, 0, 0, 0},
	}
	
	background = Image:New{
		width=270;
		height=189;
		y=0;
		x=0;
		keepAspect = false,
		file = panelTexture;
		parent = window;
		disableChildrenHitTest = false,
	}

	label_wavenumandtype = Label:New{
		parent = labelStack,
		autosize=false;
		align="left";
		valign="center";
		caption = '';
		height = labelHeight,
		width = "100%";
		font = {font = panelFont, size = fontSize, shadow = true, outline = true,},
	}
	label_tidelevel = Label:New{
		parent = labelStack,
		autosize=false;
		align="left";
		valign="center";
		caption = '';
		height = labelHeight,
		width = "100%";
		font = {font = panelFont, size = fontSize, shadow = true, outline = true,},
	}
	label_eggquota = Label:New{
		parent = labelStack,
		autosize=false;
		align="left";
		valign="center";
		caption = '';
		height = labelHeight,
		width = "100%";
		font = {font = panelFont, size = fontSize, shadow = true, outline = true,},
	}
	label_remainingtime = Label:New{
		parent = labelStack,
		autosize=false;
		align="left";
		valign="center";
		caption = '';
		height = labelHeight * 4,
		width = "100%";
		font = {font = panelFont, size = fontSize, shadow = true, outline = true,},
	}
end

function widget:Shutdown()
	widgetHandler:DeregisterGlobal("ChickenRunEvent")
end

function widget:GameFrame(n)
	if (n%30< 1) then UpdateRemainingTime() end
end
