local ToggledReports = {}
local ToggledPMs = {}
local Reporters = {}

--Function

function isAdmin(group)
	for k, v in pairs(Config.AdminRoles) do
		if v == group then
			return true
		end
	end
	return false
end

function GetAdmins()
	local Admins = {}
	local xAll = ESX.GetPlayers()
	for i = 1, #xAll, 1 do
		local xTarget = ESX.GetPlayerFromId(xAll[i])
		if isAdmin(xTarget.getGroup()) then
			Admins[xTarget.source] = xTarget.source
		end
	end
	return Admins
end

function IsAnyBlacklistedWord(message)
	local isBlacklisted = false
	for k, v in pairs(Config.BlacklistedWords) do
		if string.find(message, v) then
			isBlacklisted = true
		end
	end
	return isBlacklisted
end

function Discord(name, message)
	local embed = {
		{
			["title"] = "**" .. name .. "**",
			["description"] = message,
		},
	}
	PerformHttpRequest(
		Config.DiscordWebhook,
		function(err, text, headers) end,
		"POST",
		json.encode({ username = name, embeds = embed }),
		{ ["Content-Type"] = "application/json" }
	)
end

--Send Report
if Config.EnableCommands["Report"] then
	RegisterCommand(Config.Commands["Report"], function(source, args, rawCommand)
		local xPlayer = ESX.GetPlayerFromId(source)
		local message = rawCommand:sub(string.len(Config.Commands["Report"]) + 1)
		if #message > Config.MinCharacterToSendReport then
			if not IsAnyBlacklistedWord(message) then
				Reporters[xPlayer.source] = xPlayer.source
				for k, v in pairs(GetAdmins()) do
					local xTarget = ESX.GetPlayerFromId(k)
					if xPlayer.source ~= xTarget.source then
						if not ToggledReports[xPlayer.source] then
							TriggerClientEvent("chat:addMessage", xTarget.source, {
								template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw; background-color:#2b2b2b; border: 2.2px solid #ff0000; border-radius: 10px;"><i class="fas fa-question-circle" style="font-size: medium;"></i>  <span style="font-weight: 600;">Jelentés tőle: <span style="color: red; font-weight:600 ;">'
									.. GetPlayerName(xPlayer.source)
									.. "</span> (^3"
									.. xPlayer.source
									.. "^0) (^3"
									.. xPlayer.getName()
									.. '^0)  <span style="font-weight: 600;">  <br><i class="fas fa-comment-dots"></i> Üzenet: </span> <span style="color: #ff9100;">'
									.. message
									.. "</span></div>",
							})
						end
					end
				end
				Discord(
					"Új jelentés",
					"``"
						.. GetPlayerName(xPlayer.source)
						.. " ("
						.. xPlayer.source
						.. ")`` segítséget kért!```Üzenet: "
						.. message
						.. "```"
				)
				TriggerClientEvent("chat:addMessage", xPlayer.source, {
					template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw;  background-color:#2b2b2b; border: 2.2px solid #00ffa6; border-radius: 10px;"><i class="fas fa-info-circle" style="font-size: medium;"></i>  <span style="font-weight: 600; color: #00ffa6;">Sikeresen</span> elküldted jelentésed! (Üzeneted: ^3'
						.. message
						.. "^0)</div>",
				})
			else
				if Config.ActionIfBlacklisted["KickPlayer"] then
					xPlayer.kick("Blacklisted word!")
				end
				if Config.ActionIfBlacklisted["NotifyPlayer"] then
					xPlayer.showNotification("Feketelistás szó!")
				end
			end
		else
			xPlayer.showNotification("Helytelen üzenet bevitel!")
		end
	end, false)
end

--Toggle Reports
if Config.EnableCommands["ToggleReports"] then
	RegisterCommand(Config.Commands["ToggleReports"], function(source, args, rawCommand)
		local xPlayer = ESX.GetPlayerFromId(source)
		if isAdmin(xPlayer.getGroup()) then
			if ToggledReports[xPlayer.source] then
				ToggledReports[xPlayer.source] = nil
				TriggerClientEvent("chat:addMessage", xPlayer.source, {
					template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw;  background-color:#2b2b2b; border: 2.2px solid #c20000; border-radius: 10px;"><i class="fas fa-comment-slash" style="font-size: medium;"></i> <span style="color: white;"> A jelentések láthatósága: <span style="font-weight:600 ; color: red;">kikapcsolva</span></div>',
				})
			elseif not ToggledReports[xPlayer.source] then
				ToggledReports[xPlayer.source] = xPlayer.source
				TriggerClientEvent("chat:addMessage", xPlayer.source, {
					template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw;  background-color:#2b2b2b; border: 2.2px solid #00d62e; border-radius: 10px;"><i class="fas fa-comment-dots" style="font-size: medium;"></i> <span style="color: white;"> A jelentések láthatósága: <span style="font-weight:600 ; color: #00d62e;">bekapcsolva</span></div>',
				})
			end
		else
			xPlayer.showNotification("Nincsen jogosultságod!")
		end
	end, false)
end

--Reply to a Report
if Config.EnableCommands["Reply"] then
	RegisterCommand(Config.Commands["Reply"], function(source, args, rawCommand)
		local xTarget = ESX.GetPlayerFromId(args[1])
		local xPlayer = ESX.GetPlayerFromId(source)
		table.remove(args, 1)
		local onlyReportReply = Config.ReplyOnlyReport and false or Reporters[xTarget.source]
		local message = table.concat(args, " ")
		if isAdmin(xPlayer.getGroup()) then
			if xTarget then
				if message then
					if onlyReportReply then
						TriggerClientEvent("chat:addMessage", xTarget.source, {
							template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw; background-color:#2b2b2b; border: 2.2px solid #00ddff; border-radius: 10px;"><i class="fas fa-envelope" style="font-size: medium;"></i> <span style="color: #00ddff; font-weight:600 ;">'
								.. GetPlayerName(xPlayer.source)
								.. "</span> (^3"
								.. xPlayer.source
								.. '^0) válaszolt  a jelentésedre.  <span style="font-weight: 600;">Válasz:</span> <span style="color: orange; font-weight:600 ;">'
								.. message
								.. "</span></div>",
						})
						TriggerClientEvent("chat:addMessage", xPlayer.source, {
							template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw; background-color:#2b2b2b; border: 2.2px solid #00ddff; border-radius: 10px;"><i class="fas fa-envelope" style="font-size: medium;"></i> Sikeresen válaszoltál <span style="color: #00ddff; font-weight:600 ;">'
								.. GetPlayerName(xTarget.source)
								.. "</span> (^3"
								.. xTarget.source
								.. '^0) jelentésére.  <span style="font-weight: 600;">Válaszod:</span> <span style="color: orange; font-weight:600 ;">'
								.. message
								.. "</span></div>",
						})
						Discord(
							"Admin válasz",
							"``"
								.. GetPlayerName(xPlayer.source)
								.. " ("
								.. xPlayer.source
								.. ")`` Admin válaszolt ``"
								.. GetPlayerName(xTarget.source)
								.. " ("
								.. xTarget.source
								.. ")`` jelentésére! ```Üzenet: "
								.. message
								.. "```"
						)

						for k, v in pairs(GetAdmins()) do
							local xTarget = ESX.GetPlayerFromId(k)
							if xPlayer.source ~= xTarget.source then
								if ToggledReports[xTarget.source] then
									TriggerClientEvent("chat:addMessage", xTarget.source, {
										template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw; background-color:#2b2b2b; border: 2.2px solid #00d62e; border-radius: 10px;"><i class="fas fa-user-edit" style="font-size: medium;"></i> <span style="color: #00ff48; font-weight:600 ;">'
											.. GetPlayerName(xPlayer.source)
											.. "</span> (^3"
											.. xPlayer.source
											.. '^0) válaszolt  <span style="color: #00aaff; font-weight:600 ;">'
											.. GetPlayerName(xTarget.source)
											.. "</span> (^3"
											.. xTarget.source
											.. '^0) jelentésére.   (Válasza: <span style="color: orange; font-weight:600 ;">'
											.. message
											.. "</span>)</div>",
									})
								end
							end
						end
					else
						TriggerClientEvent("chat:addMessage", xPlayer.source, {
							template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw; background-color:#2b2b2b; border: 2.2px solid #c20000; border-radius: 10px;"><i class="fas fa-exclamation-circle" style="font-size: medium;"></i> <span style="color: white;"><span style="font-weight:600 ; color: red;">Sikertelen</span> válasz! <span style="font-weight:600 ;">Hiba:</span> <span style="color: orange;">A játékos nem kért segítséget</span></div>',
						})
					end
				else
					TriggerClientEvent("chat:addMessage", xPlayer.source, {
						template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw;  background-color:#2b2b2b; border: 2.2px solid #c20000; border-radius: 10px;"><i class="fas fa-exclamation-circle" style="font-size: medium;"></i> <span style="color: white;"><span style="font-weight:600 ; color: red;">Sikertelen</span> válasz! <span style="font-weight:600 ;">Hiba:</span> <span style="color: orange;">Az üzenet nincsen megadva</span></div>',
					})
				end
			else
				TriggerClientEvent("chat:addMessage", xPlayer.source, {
					template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw; background-color:#2b2b2b; border: 2.2px solid #c20000; border-radius: 10px;"><i class="fas fa-exclamation-circle" style="font-size: medium;"></i> <span style="color: white;"><span style="font-weight:600 ; color: red;">Sikertelen</span> válasz! <span style="font-weight:600 ;">Hiba:</span> <span style="color: orange;">A játékos (ID) nincsen megadva</span></div>',
				})
			end
		else
			xPlayer.showNotification("Nincsen jogosultságod!")
		end
	end, false)
end

--Close Report
if Config.EnableCommands["CloseReport"] then
	RegisterCommand(Config.Commands["CloseReport"], function(source, args, rawCommand)
		local xPlayer = ESX.GetPlayerFromId(source)
		local xTarget = ESX.GetPlayerFromId(args[1])
		local xAdmins = ESX.GetExtendedPlayers("group", "admin")
		if isAdmin(xPlayer.getGroup()) then
			if xPlayer and xTarget then
				if Reporters[xTarget.source] then
					Reporters[xTarget.source] = nil
					TriggerClientEvent("chat:addMessage", xTarget.source, {
						template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw; background-color:#2b2b2b; border: 2.2px solid #00ddff; border-radius: 10px;"><i class="fas fa-envelope" style="font-size: medium;"></i> <span style="color: #00ddff; font-weight:600 ;">'
							.. GetPlayerName(xPlayer.source)
							.. "</span> (^3"
							.. xPlayer.source
							.. "^0) bezárta a jelentésedet.</div>",
					})
					TriggerClientEvent("chat:addMessage", xPlayer.source, {
						template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw; background-color:#2b2b2b; border: 2.2px solid #00ddff; border-radius: 10px;"><i class="fas fa-envelope" style="font-size: medium;"></i> <span style="color: #00ddff; font-weight:600 ;">'
							.. GetPlayerName(xTarget.source)
							.. "</span> (^3"
							.. xTarget.source
							.. "^0) játékos jelentése be lett zárva.</div>",
					})
					Discord(
						"Jelentés bezárása",
						"``"
							.. GetPlayerName(xPlayer.source)
							.. " ("
							.. xPlayer.source
							.. ")`` bezárta ``"
							.. GetPlayerName(xTarget.source)
							.. " ("
							.. xTarget.source
							.. ")`` jelentését!"
					)
					for k, v in pairs(GetAdmins()) do
						local xTarget = ESX.GetPlayerFromId(k)
						if xPlayer.source ~= xTarget.source then
							TriggerClientEvent("chat:addMessage", xTarget.source, {
								template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw; background-color:#2b2b2b; border: 2.2px solid #00d62e; border-radius: 10px;"><i class="fas fa-user-edit" style="font-size: medium;"></i> <span style="color: #00ff48; font-weight:600 ;">'
									.. GetPlayerName(xPlayer.source)
									.. "</span> (^3"
									.. xPlayer.source
									.. '^0) bezárta  <span style="color: #00aaff; font-weight:600 ;">'
									.. GetPlayerName(xTarget.source)
									.. "</span> (^3"
									.. xTarget.source
									.. "^0) jelentését.</div>",
							})
						end
					end
				else
					TriggerClientEvent("chat:addMessage", xPlayer.source, {
						template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw; background-color:#2b2b2b; border: 2.2px solid #c20000; border-radius: 10px;"><i class="fas fa-exclamation-circle" style="font-size: medium;"></i> <span style="color: white;"><span style="font-weight:600 ; color: red;">Sikertelen</span> bezárás! <span style="font-weight:600 ;">Hiba:</span> <span style="color: orange;">Ez a játékos nem kért segítséget</span></div>',
					})
				end
			else
				TriggerClientEvent("chat:addMessage", xPlayer.source, {
					template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw; background-color:#2b2b2b; border: 2.2px solid #c20000; border-radius: 10px;"><i class="fas fa-exclamation-circle" style="font-size: medium;"></i> <span style="color: white;"><span style="font-weight:600 ; color: red;">Sikertelen</span> bezárás! <span style="font-weight:600 ;">Hiba:</span> <span style="color: orange;">A játékos (ID) nincsen megadva</span></div>',
				})
			end
		else
			xPlayer.showNotification("Nincsen jogosultságod!")
		end
	end, false)
end

--PM
if Config.EnableCommands["PM"] then
	RegisterCommand(Config.Commands["PM"], function(source, args, rawCommand)
		local xPlayer = ESX.GetPlayerFromId(source)
		local xTarget = ESX.GetPlayerFromId(args[1])
		table.remove(args, 1)
		local message = table.concat(args, " ")
		if xPlayer and xTarget then
			if message then
				if not IsAnyBlacklistedWord(message) then
					if not ToggledPMs[xTarget.source] then
						xTarget.showNotification(
							"~b~Új privát üzeneted érkezett! [" .. GetPlayerName(xPlayer.source) .. "]"
						)
						TriggerClientEvent("chat:addMessage", xTarget.source, {
							template = '<div style="padding: 0.4vw 0.5vw;margin-top: 10px; margin-bottom:10px; font-size: 15px; margin: 0.5vw; background-color:#141414; border: 3.2px solid #00856d; border-radius: 10px;"><i class="fas fa-envelope"></i> ['
								.. GetPlayerName(xPlayer.source)
								.. " | "
								.. xPlayer.source
								.. "] privát üzenete: </span> <span style='color: #f77300;'> "
								.. message
								.. "</span></div>",
						})
						TriggerClientEvent("chat:addMessage", xPlayer.source, {
							template = '<div style="padding: 0.4vw 0.5vw;margin-top: 10px; margin-bottom:10px; font-size: 15px; margin: 0.5vw; background-color:#141414; border: 3.2px solid #078500; border-radius: 10px;"><i class="fas fa-envelope"></i> ['
								.. GetPlayerName(xPlayer.source)
								.. " | "
								.. xPlayer.source
								.. "] => ["
								.. GetPlayerName(xTarget.source)
								.. " | "
								.. xTarget.source
								.. "]: </span> <span style='color: #f77300;'> "
								.. message
								.. "</span></div>",
						})
						if Config.LogPM then
							Discord(
								"PM üzenet",
								"``"
									.. GetPlayerName(xPlayer.source)
									.. " ("
									.. xPlayer.source
									.. ")`` üzenetet küldött ``"
									.. GetPlayerName(xTarget.source)
									.. " ("
									.. xTarget.source
									.. ")`` számára! ```Üzenet: "
									.. message
									.. "```"
							)
						end
					else
						xPlayer.showNotification("A játékos nem fogad privát üzeneteket!")
					end
				else
					if Config.ActionIfBlacklisted["KickPlayer"] then
						xPlayer.kick("Blacklisted word!")
					end
					if Config.ActionIfBlacklisted["NotifyPlayer"] then
						xPlayer.showNotification("Feketelistás szó!")
					end
				end
			end
		else
			xPlayer.showNotification("Helytelen játékod ID!")
		end
	end, false)
end

-- Toggle PM
if Config.EnableCommands["TogglePM"] then
	RegisterCommand(Config.Commands["TogglePM"], function(source, args, rawCommand)
		local xPlayer = ESX.GetPlayerFromId(source)
		if ToggledPMs[xPlayer.source] then
			ToggledPMs[xPlayer.source] = nil
			TriggerClientEvent("chat:addMessage", xPlayer.source, {
				template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw;  background-color:#2b2b2b; border: 2.2px solid #c20000; border-radius: 10px;"><i class="fas fa-comment-slash" style="font-size: medium;"></i> <span style="color: white;"> A PM-ek fogadása: <span style="font-weight:600 ; color: red;">kikapcsolva</span></div>',
			})
		elseif not ToggledPMs[xPlayer.source] then
			ToggledPMs[xPlayer.source] = xPlayer.source
			TriggerClientEvent("chat:addMessage", xPlayer.source, {
				template = '<div style="padding: 0.4vw 0.5vw; font-size: 15px; margin: 0.5vw;  background-color:#2b2b2b; border: 2.2px solid #00d62e; border-radius: 10px;"><i class="fas fa-comment-dots" style="font-size: medium;"></i> <span style="color: white;"> A PM-ek fogadása: <span style="font-weight:600 ; color: #00d62e;">bekapcsolva</span></div>',
			})
		end
	end, false)
end
