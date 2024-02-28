lib.locale()
local reports = {}

local function isAdmin(playerId)
    for k,v in pairs(wx.AllowedIds) do
        for _,id in pairs(GetPlayerIdentifiers(playerId)) do
            if id == v then
                return true
            end
        end
    end
    return false
end

lib.callback.register(
    "wx_reports:isAdmin",
    function(source)
        if wx.Framework:lower() == "esx" then
            ESX = exports["es_extended"]:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(source)
            return wx.AdminGroups[xPlayer.getGroup()]
        else
            return isAdmin(source)
        end
    end
)


function Notify(id, data)
    TriggerClientEvent("ox_lib:notify", id, data)
end

function CheckSQL(id)
    local identifier = GetPlayerIdentifierByType(id,'license')
    local response = MySQL.query.await('SELECT * FROM `wx_reports` WHERE `admin_identifier` = ?', {
        identifier
    })
    if #response == 0 then
        return MySQL.insert.await('INSERT INTO `wx_reports` (admin_identifier, admin_name) VALUES (?, ?)', {
            identifier, GetPlayerName(id)
        })
    end
end

lib.callback.register(
    "wx_reports:getCoords",
    function(source, target)
        return GetEntityCoords(GetPlayerPed(target))
    end
)

lib.callback.register(
    "wx_reports:getLicense",
    function(source, target)
        return GetPlayerIdentifierByType(source,'license')
    end
)

lib.callback.register(
    "wx_reports:getStats",
    function(source)
        local toReturn = {}
        CheckSQL(source)
        local identifier = GetPlayerIdentifierByType(source,'license')
        local response = MySQL.query.await('SELECT * FROM `wx_reports` WHERE `admin_identifier` = ?', {
            identifier
        })
        for k,v in pairs(response) do
            if v.admin_identifier == identifier then
                if v.admin_name ~= GetPlayerName(source) then
                    MySQL.update.await('UPDATE wx_reports SET admin_name = ? WHERE admin_identifier = ?', {
                        GetPlayerName(source), identifier
                    })
                end
            end
            table.insert(toReturn,{
                adminName = v.admin_name,
                license = v.admin_identifier,
                resolved = v.resolved_reports,
                replied = v.replied_reports
            })
        end
        return toReturn


    end
)

lib.callback.register(
    "wx_reports:bringPlayer",
    function(source, target)
        return SetEntityCoords(GetPlayerPed(target), GetEntityCoords(GetPlayerPed(source)))
    end
)

lib.callback.register(
    "wx_reports:takeReport",
    function(source, reportid)
        for k, v in pairs(reports) do
            if v.reportid == reportid then
                v.admin = GetPlayerName(source)
                Notify(
                    source,
                    {
                        title = locale("reportTaken"),
                        description = locale("reportTakenDesc", v.reportid),
                        icon = "flag",
                        iconAnimation = "beat",
                        type = "success",
                        duration = 4000
                    }
                )
                Notify(
                    v.playerid,
                    {
                        title = locale("reportTakenPlayer"),
                        description = locale("reportTakenPlayerDesc", GetPlayerName(source), v.playerid),
                        icon = "flag",
                        iconAnimation = "beat",
                        type = "info",
                        duration = 10000
                    }
                )
            end
        end
    end
)

lib.callback.register(
    "wx_reports:messagePlayer",
    function(source, target, reportid, message)
        Notify(
            target,
            {
                title = locale("replyNotifTitle", reportid),
                description = ("%s: **%s**"):format(GetPlayerName(source), message),
                icon = "comment",
                iconAnimation = "beatFade",
                iconColor = "#C53030",
                position = "top",
                duration = 10000
            }
        )
        Log(
            wx.Webhooks.Reply,
            {
                title = ("Reply to Report - [#%s]"):format(reportid),
                fields = {
                    {
                        ["name"] = "Admin Name",
                        ["value"] = GetPlayerName(source),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Reporter Name",
                        ["value"] = GetPlayerName(target),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Message",
                        ["value"] = message,
                        ["inline"] = true
                    }
                }
            }
        )
        CheckSQL(source)
        MySQL.update.await('UPDATE wx_reports SET replied_reports = replied_reports + 1 WHERE admin_identifier = ?', {
            GetPlayerIdentifierByType(source,'license')
        })
        TriggerClientEvent("wx_reports:sound", target)
    end
)

lib.callback.register(
    "wx_reports:getReports",
    function()
        return reports
    end
)

lib.callback.register(
    "wx_reports:getPlayerReportCount",
    function(source)
        local count = 0
        for k, v in pairs(reports) do
            if v.playerid == source and v.status == locale("active") then
                count = count + 1
            end
        end
        return count
    end
)
lib.callback.register(
    "wx_reports:getPlayerReports",
    function(source)
        local playerreports = {}
        for k, v in pairs(reports) do
            if v.playerid == source and v.status == locale("active") then
                table.insert(playerreports, v)
            end
        end
        return playerreports
    end
)
lib.callback.register(
    "wx_reports:getSortedReports",
    function(source, id)
        local tosort = {}
        for k, v in pairs(reports) do
            if v.playerid == id or v.reportid == id then
                table.insert(tosort, v)
            end
        end
        return tosort
    end
)

lib.callback.register(
    "wx_reports:reopenReport",
    function(source, reportid)
        for k, v in pairs(reports) do
            if v.reportid == reportid and v.status == locale("completed") then
                v.status = locale("active")
                Notify(
                    source,
                    {
                        title = locale("reopenTitle"),
                        description = locale("reopenDesc", v.reportid),
                        icon = "flag",
                        iconAnimation = "beat",
                        type = "success",
                        duration = 4000
                    }
                )
                Notify(
                    v.playerid,
                    {
                        title = locale("reopenTitlePlayer"),
                        description = locale("reopenDescPlayer", v.reportid, GetPlayerName(source)),
                        icon = "flag",
                        iconAnimation = "beat",
                        type = "info",
                        duration = 10000
                    }
                )
                if wx.Sounds.Other then
                    TriggerClientEvent("wx_reports:sound", v.playerid)
                end
            end
        end
    end
)

lib.callback.register(
    "wx_reports:completeReport",
    function(source, reportid)
        for k, v in pairs(reports) do
            if v.reportid == reportid then
                v.status = locale("completed")
                Notify(
                    source,
                    {
                        title = locale("completeNotifTitle"),
                        description = locale("completeNotifDesc", v.reportid),
                        icon = "flag",
                        iconAnimation = "beat",
                        type = "success",
                        duration = 4000
                    }
                )
                Notify(
                    v.playerid,
                    {
                        title = locale("completeNotifTitle"),
                        description = locale("completeNotifDescPlayer", v.reportid, GetPlayerName(source)),
                        icon = "flag",
                        iconAnimation = "beat",
                        type = "info",
                        duration = 10000
                    }
                )
                if wx.Sounds.Other then
                    TriggerClientEvent("wx_reports:sound", v.playerid)
                end
                Log(
                    wx.Webhooks.Completed,
                    {
                        title = ("Report Completed - [#%s]"):format(v.reportid),
                        fields = {
                            {
                                ["name"] = "Admin Name",
                                ["value"] = GetPlayerName(source),
                                ["inline"] = true
                            },
                            {
                                ["name"] = "Reporter Name",
                                ["value"] = GetPlayerName(v.playerid),
                                ["inline"] = true
                            },
                            {
                                ["name"] = "Report Title",
                                ["value"] = v.title,
                                ["inline"] = true
                            },
                            {
                                ["name"] = "Report Message",
                                ["value"] = v.message,
                                ["inline"] = true
                            }
                        }
                    }
                )
                CheckSQL(source)
                MySQL.update.await('UPDATE wx_reports SET resolved_reports = resolved_reports + 1 WHERE admin_identifier = ?', {
                    GetPlayerIdentifierByType(source,'license')
                })
                break
            end
        end
    end
)

lib.callback.register(
    "wx_reports:deleteReport",
    function(source, reportid, self)
        for k, v in pairs(reports) do
            if v.reportid == reportid then
                table.remove(reports, k)
                if not self then
                    Notify(
                        source,
                        {
                            title = locale("deleteNotifTitle"),
                            description = locale("deleteNotifDesc", v.reportid),
                            icon = "flag",
                            iconAnimation = "beat",
                            type = "success",
                            duration = 4000
                        }
                    )
                    Notify(
                        v.playerid,
                        {
                            title = locale("deleteNotifTitlePlayer"),
                            description = locale("deleteNotifDescPlayer", v.reportid, GetPlayerName(source)),
                            icon = "flag",
                            iconAnimation = "beat",
                            type = "info",
                            duration = 10000
                        }
                    )
                    if wx.Sounds.Other then
                        TriggerClientEvent("wx_reports:sound", v.playerid)
                    end
                else
                    Notify(
                        source,
                        {
                            title = locale("deleteNotifTitle"),
                            description = locale("deleteNotifDesc", v.reportid),
                            icon = "flag",
                            iconAnimation = "beat",
                            type = "success",
                            duration = 4000
                        }
                    )
                end
                Log(
                    wx.Webhooks.Deleted,
                    {
                        title = ("Report Deleted - [#%s]"):format(v.reportid),
                        fields = {
                            {
                                ["name"] = "Admin Name",
                                ["value"] = GetPlayerName(source),
                                ["inline"] = true
                            },
                            {
                                ["name"] = "Reporter Name",
                                ["value"] = GetPlayerName(v.playerid),
                                ["inline"] = true
                            },
                            {
                                ["name"] = "Report Title",
                                ["value"] = v.title,
                                ["inline"] = true
                            },
                            {
                                ["name"] = "Report Message",
                                ["value"] = v.message,
                                ["inline"] = true
                            }
                        }
                    }
                )

                break
            end
        end
    end
)

lib.callback.register(
    "wx_reports:sendReport",
    function(source, data)
        local playername = GetPlayerName(source)
        local playerid = source
        local title = data.title
        local message = data.message
        table.insert(
            reports,
            {
                reportid = #reports + 1,
                playername = GetPlayerName(source),
                playerid = source,
                title = data.title,
                message = data.message,
                time = os.date("%H:%M"),
                status = locale("active"),
                admin = locale("none"),
                ped = GetPlayerPed(playerid)
            }
        )
        Notify(
            source,
            {
                title = locale("reportSent"),
                description = locale("reportSentDesc", #reports),
                icon = "flag",
                iconAnimation = "beat",
                iconColor = wx.DefaultColor,
                duration = 5000
            }
        )
        Log(
            wx.Webhooks.Received,
            {
                title = ("New Report Received - [#%s]"):format(#reports),
                fields = {
                    {
                        ["name"] = "Player Name",
                        ["value"] = GetPlayerName(playerid),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Player License",
                        ["value"] = "```" .. GetPlayerIdentifierByType(playerid, "license") .. "```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Report Title",
                        ["value"] = title,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Report Message",
                        ["value"] = message,
                        ["inline"] = true
                    }
                }
            }
        )
        if wx.Framework:lower() == "esx" then
            local xPlayers = ESX.GetPlayers()
            for i = 1, #xPlayers, 1 do
                local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
                if wx.AdminGroups[xPlayer.getGroup()] then
                    Notify(
                        xPlayers[i],
                        {
                            title = locale("newReportTitle"),
                            description = locale("newReportDesc", playerid, playername, title, message),
                            duration = 10000,
                            icon = "flag",
                            iconAnimation = "beat",
                            iconColor = wx.DefaultColor
                        }
                    )
                    if wx.Sounds.NewReport then
                        TriggerClientEvent("wx_reports:sound", xPlayers[i])
                    end
                end
            end
        else
            for k,id in pairs(GetPlayers()) do
                if isAdmin(id) then
                    Notify(
                        id,
                        {
                            title = locale("newReportTitle"),
                            description = locale("newReportDesc", playerid, playername, title, message),
                            duration = 10000,
                            icon = "flag",
                            iconAnimation = "beat",
                            iconColor = wx.DefaultColor
                        }
                    )
                    if wx.Sounds.NewReport then
                        TriggerClientEvent("wx_reports:sound", id)
                    end
                end
            end
        end
    end
)
