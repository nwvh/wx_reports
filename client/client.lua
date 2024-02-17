local cooldown = false
lib.locale()

RegisterNetEvent('wx_reports:sound',function ()
    local soundId = GetSoundId()
    PlaySoundFrontend(soundId, "DELETE", "HUD_DEATHMATCH_SOUNDSET", true)
    ReleaseSoundId(soundId)
end)

RegisterCommand('report',function ()
    local isAdmin = lib.callback.await('wx_reports:isAdmin')
    lib.registerContext({
        id = 'reportmenu',
        title = locale("header"),
        options = {
          {
            title = locale("newReport"),
            icon = "flag",
            onSelect = function ()
                local playerReports = lib.callback.await('wx_reports:getPlayerReports')
                if playerReports > wx.MaxReports-1 and wx.MaxReports ~= -1 then
                    return lib.notify({
                        title = locale("header"),
                        description = locale("tooMany"),
                        type = "error",
                    })
                end
                if cooldown then
                    return lib.notify({
                        title = locale("header"),
                        description = locale("cooldown"),
                        type = "error",
                    })
                end
                local reportdata = lib.inputDialog(locale("createReportTitle"), {
                    {type = 'input', label = locale("title"), description = locale("createReportTitleDesc"), required = true, min = 1, max = 16, placeholder = locale("createReportTitleDescPlaceholder")},
                    {type = 'textarea', label = locale("createReportDesc"), description = locale("createReportDescDesc"), required = true, min = 1, max = 128,placeholder = locale("createReportDescDescPlaceholder")},
                  })
                if reportdata then
                    lib.callback.await('wx_reports:sendReport',wx.Cooldown,{
                        title = reportdata[1],
                        message = reportdata[2]
                    })
                    cooldown = true
                    SetTimeout(wx.Cooldown,function ()
                        cooldown = false
                    end)
                else
                    return
                end
            end
          },
          { 
            title = locale("allReports"),
            icon = "list",
            disabled = not isAdmin,
            onSelect = function ()
                local reports = lib.callback.await('wx_reports:getReports')
                local opt = {

                }
                local completed = {}
                if #reports == 0 then
                    opt = {
                        {
                            title = locale("noReports"),
                            disabled = true
                        }
                    }
                end
                for k,v in pairs(reports) do
                    if v.status == locale("completed") then
                        table.insert(completed,
                            {
                                title = ("[#%s] %s"):format(v.reportid,v.title),
                                description = ('"%s"'):format(v.message),
                                metadata = {
                                    {label = locale("receivedAt"), value = v.time},
                                    {label = locale("playerId"), value = v.playerid},
                                    {label = locale("playerName"), value = v.playername},
                                    {label = locale("status"), value = v.status},
                                },
                                onSelect = function ()
                                    lib.registerContext({
                                        id = 'reportactions_'..v.reportid,
                                        title = locale("completedReports"),
                                        menu = 'adminreports',
                                        options = {
                                            {
                                                title = locale("teleport"),
                                                icon = "street-view",
                                                onSelect = function ()
                                                    local to = lib.callback.await('wx_reports:getCoords',nil,v.playerid)
                                                    SetEntityCoords(cache.ped,to)
                                                end
                                            },
                                            {
                                                title = locale("bring"),
                                                icon = "map-location-dot",
                                                onSelect = function ()
                                                    lib.callback.await('wx_reports:bringPlayer',nil,v.playerid)
                                                end
                                            },
  
                                        }
                                    })
                                    lib.showContext('reportactions_'..v.reportid)
                                end
                            }
                        )
                        lib.registerContext({
                            id="completed",
                            title=locale("completedReports"),
                            options=completed
                        })
                        table.insert(opt,{
                            title = locale("completedReports"),
                            description = locale("completedReportsDesc"),
                            menu = "completed"
                        })
                    else
                        table.insert(opt,
                            {
                                title = ("[#%s] %s"):format(v.reportid,v.title),
                                description = ("[%s] %s: '%s'"):format(v.playerid,v.playername,v.message),
                                metadata = {
                                    {label = locale("receivedAt"), value = v.time},
                                    {label = locale("playerId"), value = v.playerid},
                                    {label = locale("playerName"), value = v.playername},
                                    {label = locale("status"), value = v.status},
                                },
                                onSelect = function ()
                                    local rid = v.reportid
                                    lib.registerContext({
                                        id = 'reportactions_'..v.reportid,
                                        title = locale("manageReport",rid),
                                        menu = 'adminreports',
                                        options = {
                                        {
                                            title = locale("teleport"),
                                            icon = "street-view",
                                            onSelect = function ()
                                                local to = lib.callback.await('wx_reports:getCoords',nil,v.playerid)
                                                SetEntityCoords(cache.ped,to)
                                            end
                                        },
                                        {
                                            title = locale("bring"),
                                            icon = "map-location-dot",
                                            onSelect = function ()
                                                lib.callback.await('wx_reports:bringPlayer',nil,v.playerid)
                                            end
                                        },
                                        {
                                            title = locale("reply"),
                                            icon = "reply",
                                            onSelect = function ()
                                                local message = lib.inputDialog(locale("replyTitle",v.playername), {
                                                    {type = 'textarea', label = locale("replyLabel"), description = locale("replyDesc"), required = true, min = 1, max = 128,placeholder = locale("replyPlaceholder")},
                                                  })
                                                lib.callback.await('wx_reports:messagePlayer',nil,v.playerid,v.reportid,message[1])
                                            end
                                        },
                                        {
                                            title = locale("delete"),
                                            icon = "trash-alt",
                                            onSelect = function ()
                                                lib.callback.await('wx_reports:deleteReport',nil,rid)
                                            end
                                        },
                                        {
                                            title = locale("markComplete"),
                                            icon = "circle-check",
                                            onSelect = function ()
                                                print(json.encode(v,{indent=true}))
                                                print(rid)
                                                lib.callback.await('wx_reports:completeReport',nil,rid)
                                            end
                                        },
                                        }
                                    })
                                    lib.showContext('reportactions_'..rid)
                                end
                            }
                        )
                    end
                end
                lib.registerContext({
                    id = 'adminreports',
                    title = locale("allReports"),
                    options = opt
                })
                lib.showContext('adminreports')
            end
          },
        }
      })
    lib.showContext('reportmenu')
end,false)