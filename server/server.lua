ESX = exports["es_extended"]:getSharedObject()

if wx.enableAdminChat then
	RegisterCommand("a", function(source, args, rawCommand)
		if source ~= 0 then
			local xPlayer = ESX.GetPlayerFromId(source)
			local username = GetPlayerName(source)
			if havePermission(xPlayer) then
				if args[1] then
					local message = string.sub(rawCommand, 3)
					local xAll = ESX.GetPlayers()
					for i=1, #xAll, 1 do
						local xTarget = ESX.GetPlayerFromId(xAll[i])
						if havePermission(xTarget) then
							TriggerClientEvent('chat:addMessage', xTarget.source, {
								template = '<div style="padding: 0.4vw; margin: 0.4vw; background-color: rgba(24, 26, 32, 0.45); border-radius: 3px; border-right: 0px solid rgb(180, 0, 0);"><font style="padding: 0.22vw; margin: 0.22vw; background-color: rgb(180, 30, 30); border-radius: 5px; font-size: 15px;"> <b>ADMIN CHAT</b></font>   <font style="background-color:rgba(0, 0, 0, 0); font-size: 17px; margin-left: 0px; padding-bottom: 2.5px; padding-left: 3.5px; padding-top: 2.5px; padding-right: 3.5px;border-radius: 0px;"> <b> [' ..source.. '] '..username..': </b></font>  <font style=" font-weight: 800; font-size: 15px; margin-left: 5px; padding-bottom: 3px; border-radius: 0px;"><b></b></font><font style=" font-weight: 200; font-size: 14px; border-radius: 0px;">'..message..'</font></div>',
									args = {}
								})
						end
					end
				else
					TriggerClientEvent('chat:addMessage', xPlayer.source, {
						template = '<div style="padding: 0.4vw; margin: 0.4vw; background-color: rgba(24, 26, 32, 0.45); border-radius: 3px; border-right: 0px solid rgb(180, 0, 0);"><font style="padding: 0.22vw; margin: 0.22vw; background-color: rgb(180, 30, 30); border-radius: 5px; font-size: 15px;"> <b>ERROR</b></font>   <font style="background-color:rgba(0, 0, 0, 0); font-size: 17px; margin-left: 0px; padding-bottom: 2.5px; padding-left: 3.5px; padding-top: 2.5px; padding-right: 3.5px;border-radius: 0px;"> <b></b></font>  <font style=" font-weight: 800; font-size: 15px; margin-left: 5px; padding-bottom: 3px; border-radius: 0px;"><b></b></font><font style=" font-weight: 200; font-size: 14px; border-radius: 0px;">Message cannot be empty!</font></div>',
							args = {}
						})
				end
			end
		end
	end, false)
end

function havePermission(xPlayer)
	local group = xPlayer.getGroup()
	for _,v in pairs(wx.AdminGroups) do
		if v == group then
			return true
		end
	end
	return false
end

ESX.RegisterServerCallback('wx_reports:getPlayerGroup', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(tonumber(source))
	if xPlayer then
		local playergroup = xPlayer.getGroup()
		cb(tostring(playergroup))
	else
		cb('user')
	end
end)

RegisterCommand("report", function(source, args, raw)
	local xPlayer = ESX.GetPlayerFromId(source)
	local name = GetPlayerName(source)
	local content = table.concat(args, " ")
	TriggerClientEvent("wx_reports:send", -1, source, name, content)
	if wx.UseWebhooks and content ~= '' then
		reportDiscord("New Report Received", source,name,content, "💜 wx_reports - [github.com/nwvh/wx_reports]")
	end
end, false)

function reportDiscord(title, playerID, playerName, reportmessage, footer)
  local embed = {
        {
            ["color"] = wx.WebhookColor,
            ["title"] = "**".. title .."**",
			["fields"] = {
        {
          ["name"]= "Player ID",
          ["value"]= playerID,
          ["inline"] = false
        },
        {
          ["name"]= "Player Name",
          ["value"]= playerName,
          ["inline"] = false
        },
        {
          ["name"]= "Report Message",
          ["value"]= reportmessage,
          ["inline"] = false
        },
	},
            ["description"] = message,
            ["footer"] = {
                ["text"] = footer,
            },
        }
    }

  PerformHttpRequest(wx.Webhook, function(err, text, headers) end, 'POST', json.encode({username = wx.WebHookName, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

