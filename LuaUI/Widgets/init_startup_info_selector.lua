local versionNumber = "1.337"
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
	return {
		name	= "Startup Info and Selector",
		desc	= "[v" .. string.format("%s", versionNumber ) .. "] Shows important information and options on startup.",
		author	= "SirMaverick",
		date	= "2009,2010",
		license	= "GNU GPL, v2 or later",
		layer	= 0,
		enabled	= false --turned off for chicken run
	}
end
