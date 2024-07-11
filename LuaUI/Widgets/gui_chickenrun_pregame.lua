function widget:GetInfo()
	return {
		name      = "Chicken Run PreGame Widget",
		desc      = "ready up and briefing window widget for Chicken Run",
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

local playerready = false

local window

--------------------------------------------------------------------------------
--widget interface
--------------------------------------------------------------------------------

function widget:GameSetup()
	if playerready then
		return true, true
	end
	return true, false
end

function widget:GameStart()
	widgetHandler:RemoveWidget()
end

function widget:Initialize()
	local Chili = WG.Chili
	if not Chili then
		widgetHandler:RemoveWidget()
		return
	end

	local window = Chili.Window:New {
		caption = "Grizzly Beam Co.",
		x = "30%",
		y = "30%",
		right = "20%",
		bottom = "20%",
		parent = Chili.Screen0,
		classname = "main_window",
	}

	Chili.Label:New {
		x = 0,
		y = 50,
		right = 0,
		parent = window,
		align = "center",
		valign = "center",
		caption = "Employee Reference Card",
		fontsize = 64,
		textColor = {1,1,1,1},
	}

	Chili.Label:New {
		x = 0,
		y = 180,
		right = 0,
		parent = window,
		align = "center",
		valign = "center",
		caption = "Egg.",
		fontsize = 16,
		textColor = {1,1,1,1},
	}

	Chili.Button:New {
		x = "50%",
		y = "90%",
		parent = window,
		align = "center",
		valign = "bottom",
		caption = "Ready",
		OnClick = {function() playerready = not playerready end},
	}
end
