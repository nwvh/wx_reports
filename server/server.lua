ESX = exports["es_extended"]:getSharedObject()
lib.locale()

local reports = {}
function Notify(id,data)
    TriggerClientEvent('ox_lib:notify', id, data)
end

lib.callback.register('wx_reports:getCoords', function(source,target)
    return GetEntityCoords(GetPlayerPed(target))
end)

lib.callback.register('wx_reports:bringPlayer', function(source,target)
    return SetEntityCoords(GetPlayerPed(target),GetEntityCoords(GetPlayerPed(source)))
end)

lib.callback.register('wx_reports:messagePlayer', function(source,target,reportid,message)
    Notify(target,{
        title = locale("replyNotifTitle",reportid),
        description = ("%s: **%s**"):format(GetPlayerName(source),message),
        icon = "comment",
        iconAnimation = "beatFade",
        iconColor = '#C53030',
        position = "top",
        duration = 10000
    })
    TriggerClientEvent('wx_reports:sound',target)

end)


lib.callback.register('wx_reports:isAdmin', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    return wx.AdminGroups[xPlayer.getGroup()]
end)

lib.callback.register('wx_reports:getReports', function()
    return reports
end)

lib.callback.register('wx_reports:getPlayerReports', function(source)
    local count = 0
    for k,v in pairs(reports) do
        if v.playerid == source and v.status == "Active" then
            count = count + 1
        end
    end
    return count
end)

lib.callback.register('wx_reports:completeReport', function(source,reportid)
    for k,v in pairs(reports) do
        if v.reportid == reportid then
            v.status = locale("title")
            Notify(source,{
                title = locale("completeNotifTitle"),
                description = locale("completeNotifDesc",v.reportid),
                icon = "flag",
                iconAnimation = "beat",
                iconColor = wx.DefaultColor,
                duration = 4000
            })
            Notify(v.playerid,{
                title = locale("completeNotifTitle"),
                description = locale("completeNotifDescPlayer",v.reportid,GetPlayerName(source)),
                icon = "flag",
                iconAnimation = "beat",
                iconColor = wx.DefaultColor,
                duration = 10000
            })
            if wx.Sounds.Other then
                TriggerClientEvent('wx_reports:sound',v.playerid)
            end
            Log(wx.Webhooks.Completed,{
                title = ("Report Completed - [#%s]"):format(v.reportid),
                fields = {
                    {
                        ["name"]= "Admin Name",
                        ["value"]= GetPlayerName(source),
                        ["inline"] = true
                    },
                    {
                        ["name"]= "Reporter Name",
                        ["value"]= GetPlayerName(v.playerid),
                        ["inline"] = true
                    },
                    {
                        ["name"]= "Report Title",
                        ["value"]= v.title,
                        ["inline"] = true
                    },
                    {
                        ["name"]= "Report Message",
                        ["value"]= v.message,
                        ["inline"] = true
                    },
                }
            })
            break
        end
    end

end)

lib.callback.register('wx_reports:deleteReport', function(source,reportid)
    for k,v in pairs(reports) do
        if v.reportid == reportid then
            table.remove(reports,k)
            Notify(source,{
                title = locale("deleteNotifTitle"),
                description = locale("deleteNotifDesc",v.reportid),
                icon = "flag",
                iconAnimation = "beat",
                iconColor = '#C53030',
                duration = 4000
            })
            Notify(v.playerid,{
                title = locale("deleteNotifTitlePlayer"),
                description = locale("deleteNotifDescPlayer",v.reportid,GetPlayerName(source)),
                icon = "flag",
                iconAnimation = "beat",
                iconColor = '#C53030',
                duration = 10000
            })
            if wx.Sounds.Other then
                TriggerClientEvent('wx_reports:sound',v.playerid)
            end
            Log(wx.Webhooks.Deleted,{
                title = ("Report Deleted - [#%s]"):format(v.reportid),
                fields = {
                    {
                        ["name"]= "Admin Name",
                        ["value"]= GetPlayerName(source),
                        ["inline"] = true
                    },
                    {
                        ["name"]= "Reporter Name",
                        ["value"]= GetPlayerName(v.playerid),
                        ["inline"] = true
                    },
                    {
                        ["name"]= "Report Title",
                        ["value"]= v.title,
                        ["inline"] = true
                    },
                    {
                        ["name"]= "Report Message",
                        ["value"]= v.message,
                        ["inline"] = true
                    },
                }
            })
            
            break
        end
    end

end)

lib.callback.register('wx_reports:sendReport',function (source,data)
    local playername = GetPlayerName(source)
    local playerid = source
    local title = data.title
    local message = data.message
    local xPlayers = ESX.GetPlayers()
    table.insert(reports,{
        reportid = #reports+1,
        playername = GetPlayerName(source),
        playerid = source,
        title = data.title,
        message = data.message,
        time = os.date("%H:%M"),
        status = "Active",
        ped = GetPlayerPed(playerid)
    })
    Log(wx.Webhooks.Received,{
        title = ("New Report Received - [#%s]"):format(#reports),
        fields = {
            {
                ["name"]= "Player Name",
                ["value"]= GetPlayerName(playerid),
                ["inline"] = true
            },
            {
                ["name"]= "Report Title",
                ["value"]= title,
                ["inline"] = true
            },
            {
                ["name"]= "Report Message",
                ["value"]= message,
                ["inline"] = true
            },
        }
    })
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if wx.AdminGroups[xPlayer.getGroup()] then
            Notify(xPlayers[i],{
                title = locale("newReportTitle"),
                description = locale("newReportDesc",playerid,playername,title,message),
                duration = 10000,
                icon = "flag",
                iconAnimation = "beat",
                iconColor = wx.DefaultColor,
            })
            if wx.Sounds.NewReport then
                TriggerClientEvent('wx_reports:sound',xPlayers[i])
            end
        end
    end
end)