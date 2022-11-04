Config = {}

-- Discord Webhook URL (IF YOU DON'T KNOW HOW, WATCH THIS VIDEO: https://www.youtube.com/watch?v=fKksxz2Gdnc)
Config.DiscordWebhook = ""

Config.MinCharacterToSendReport = 10

-- You can disable the commands
Config.EnableCommands = {
	["Report"] = true,
	["Reply"] = true,
	["ToggleReports"] = true,
	["CloseReport"] = true,
	["PM"] = true,
	["TogglePM"] = true,
}
-- Commands name
Config.Commands = {
	["Report"] = "report",
	["Reply"] = "r",
	["ToggleReports"] = "togreports",
	["CloseReport"] = "cr",
	["PM"] = "pm",
	["TogglePM"] = "togpm",
}

-- Reply settings
Config.OnlyReportReply = true

-- PM settings
Config.NotifyPlayerOnPM = true
Config.LogPM = true

-- Blacklisted words (You can add more...)
Config.BlacklistedWords = {
	"szar a szerver",
	"köcsög adminok",
}

Config.ActionIfBlacklisted = {
	["KickPlayer"] = false,
	["NotifyPlayer"] = true,
}
