local cooldown = false
lib.locale()

RegisterNetEvent("wx_reports:sound",function()
    local soundId = GetSoundId()
    PlaySoundFrontend(soundId, "DELETE", "HUD_DEATHMATCH_SOUNDSET", true)
    ReleaseSoundId(soundId)
end)

if wx.KeyBind then
    lib.addKeybind(
        {
            name = "openreportmenu",
            description = locale("keybindDesc"),
            defaultKey = wx.KeyBind,
            onReleased = function(self)
                ExecuteCommand(wx.Command)
            end
        }
    )
end
RegisterCommand(wx.Command,function()
    local isAdmin = lib.callback.await("wx_reports:isAdmin")
    local reportCount = lib.callback.await("wx_reports:getPlayerReportCount")
    lib.registerContext(
        {
            id = "reportmenu",
            title = locale("header"),
            options = {
                {
                    title = locale("newReport"),
                    icon = "flag",
                    onSelect = function()
                        if reportCount > wx.MaxReports - 1 and wx.MaxReports ~= -1 then
                            return lib.notify(
                                {
                                    title = locale("header"),
                                    description = locale("tooMany", locale("yourReports")),
                                    duration = 6000,
                                    type = "error"
                                }
                            )
                        end
                        if cooldown then
                            return lib.notify(
                                {
                                    title = locale("header"),
                                    description = locale("cooldown"),
                                    type = "error"
                                }
                            )
                        end
                        local reportdata =
                            lib.inputDialog(
                            locale("createReportTitle"),
                            {
                                {
                                    type = "input",
                                    label = locale("title"),
                                    description = locale("createReportTitleDesc"),
                                    required = true,
                                    min = 1,
                                    max = 16,
                                    placeholder = locale("createReportTitleDescPlaceholder")
                                },
                                {
                                    type = "textarea",
                                    label = locale("createReportDesc"),
                                    description = locale("createReportDescDesc"),
                                    required = true,
                                    min = 1,
                                    max = 128,
                                    placeholder = locale("createReportDescDescPlaceholder")
                                }
                            }
                        )
                        if reportdata then
                            lib.callback.await(
                                "wx_reports:sendReport",
                                wx.Cooldown,
                                {
                                    title = reportdata[1],
                                    message = reportdata[2]
                                }
                            )
                            cooldown = true
                            SetTimeout(
                                wx.Cooldown,
                                function()
                                    cooldown = false
                                end
                            )
                        else
                            return
                        end
                    end
                },
                {
                    title = locale("yourReports"),
                    icon = "clipboard-list",
                    arrow = true,
                    disabled = reportCount < 1 and true,
                    onSelect = function()
                        local playerReports = lib.callback.await("wx_reports:getPlayerReports")
                        local opt = {}
                        for k, v in pairs(playerReports) do
                            if v.admin ~= locale("none") then
                                table.insert(
                                    opt,
                                    {
                                        title = ("[#%s] %s"):format(v.reportid, v.title),
                                        description = ('"%s"'):format(v.message),
                                        metadata = {
                                            {label = locale("createdAt"), value = v.time},
                                            {label = locale("status"), value = v.status},
                                            {label = locale("admin"), value = v.admin}
                                        },
                                        arrow = true,
                                        onBack = function()
                                            lib.showContext("reportmenu")
                                        end,
                                        onSelect = function()
                                            lib.registerContext(
                                                {
                                                    id = "playerreport_" .. v.reportid,
                                                    title = locale("yourReport", v.reportid),
                                                    options = {
                                                        {
                                                            title = locale("delete"),
                                                            icon = "trash-alt",
                                                            onSelect = function()
                                                                local confirm =
                                                                    lib.alertDialog(
                                                                    {
                                                                        header = locale("deleteConfirmTitle"),
                                                                        content = locale(
                                                                            "deleteConfirmDescSelf",
                                                                            v.reportid
                                                                        ),
                                                                        centered = true,
                                                                        cancel = true
                                                                    }
                                                                )
                                                                if confirm == "confirm" then
                                                                    lib.callback.await(
                                                                        "wx_reports:deleteReport",
                                                                        nil,
                                                                        v.reportid,
                                                                        true
                                                                    )
                                                                end
                                                            end
                                                        }
                                                    }
                                                }
                                            )
                                            lib.showContext("playerreport_" .. v.reportid)
                                        end
                                    }
                                )
                            else
                                table.insert(
                                    opt,
                                    {
                                        title = ("[#%s] %s"):format(v.reportid, v.title),
                                        description = ('"%s"'):format(v.message),
                                        metadata = {
                                            {label = locale("createdAt"), value = v.time},
                                            {label = locale("status"), value = v.status},
                                            {label = locale("admin"), value = v.admin}
                                        },
                                        arrow = true,
                                        onBack = function()
                                            lib.showContext("reportmenu")
                                        end,
                                        onSelect = function()
                                            lib.registerContext(
                                                {
                                                    id = "playerreport_" .. v.reportid,
                                                    title = locale("yourReport", v.reportid),
                                                    options = {
                                                        {
                                                            title = locale("delete"),
                                                            icon = "trash-alt",
                                                            onSelect = function()
                                                                local confirm =
                                                                    lib.alertDialog(
                                                                    {
                                                                        header = locale("deleteConfirmTitle"),
                                                                        content = locale(
                                                                            "deleteConfirmDescSelf",
                                                                            v.reportid
                                                                        ),
                                                                        centered = true,
                                                                        cancel = true
                                                                    }
                                                                )
                                                                if confirm == "confirm" then
                                                                    lib.callback.await(
                                                                        "wx_reports:deleteReport",
                                                                        nil,
                                                                        v.reportid,
                                                                        true
                                                                    )
                                                                end
                                                            end
                                                        }
                                                    }
                                                }
                                            )
                                            lib.showContext("playerreport_" .. v.reportid)
                                        end
                                    }
                                )
                            end
                        end
                        lib.registerContext(
                            {
                                id = "playerreports",
                                title = locale("yourReports"),
                                options = opt
                            }
                        )
                        lib.showContext("playerreports")
                        print(json.encode(playerReports, {indent = true}))
                    end
                },
                {
                    title = locale("allReports"),
                    icon = "list",
                    disabled = not isAdmin,
                    arrow = true,
                    onBack = function()
                        lib.showContext("reportmenu")
                    end,
                    onSelect = function()
                        local reports = lib.callback.await("wx_reports:getReports")
                        local opt = {}
                        local completed = {}
                        if #reports == 0 then
                            opt = {
                                {
                                    title = locale("noReports"),
                                    disabled = true
                                }
                            }
                        else
                            table.insert(
                                opt,
                                {
                                    title = locale("sort"),
                                    description = locale("sortDesc"),
                                    icon = "arrow-up-1-9",
                                    onSelect = function()
                                        local sort =
                                            lib.inputDialog(
                                            locale("sort"),
                                            {
                                                {
                                                    type = "number",
                                                    label = locale("id"),
                                                    description = locale("idDesc"),
                                                    icon = "hashtag"
                                                }
                                            }
                                        )
                                        local sortopt = {}
                                        local sortedreports =
                                            lib.callback.await("wx_reports:getSortedReports", nil, sort[1])
                                        print(json.encode(sortedreports, {indent = true}))
                                        if #sortedreports == 0 then
                                            table.insert(
                                                sortopt,
                                                {
                                                    title = locale("noReportsFound"),
                                                    disabled = true
                                                }
                                            )
                                            lib.registerContext(
                                                {
                                                    id = "sortedReports",
                                                    title = locale("sortedReports"),
                                                    options = sortopt
                                                }
                                            )
                                            lib.showContext("sortedReports")
                                        else
                                            for _, sortdata in pairs(sortedreports) do
                                                if sortdata.status == locale("completed") then
                                                    table.insert(
                                                        sortopt,
                                                        {
                                                            title = ("[#%s] %s"):format(
                                                                sortdata.reportid,
                                                                sortdata.title
                                                            ),
                                                            description = ('"%s"'):format(sortdata.message),
                                                            metadata = {
                                                                {
                                                                    label = locale("receivedAt"),
                                                                    value = sortdata.time
                                                                },
                                                                {
                                                                    label = locale("playerId"),
                                                                    value = sortdata.playerid
                                                                },
                                                                {
                                                                    label = locale("playerName"),
                                                                    value = sortdata.playername
                                                                },
                                                                {label = locale("admin"), value = sortdata.admin},
                                                                {label = locale("status"), value = sortdata.status}
                                                            },
                                                            onSelect = function()
                                                                lib.registerContext(
                                                                    {
                                                                        id = "reportactions_" .. sortdata.reportid,
                                                                        title = locale("completedReports"),
                                                                        menu = "adminreports",
                                                                        options = {
                                                                            {
                                                                                title = locale("reopen"),
                                                                                icon = "arrow-rotate-left",
                                                                                onSelect = function()
                                                                                    lib.callback.await(
                                                                                        "wx_reports:reopenReport",
                                                                                        nil,
                                                                                        sortdata.reportid
                                                                                    )
                                                                                end
                                                                            },
                                                                            {
                                                                                title = locale("teleport"),
                                                                                icon = "street-view",
                                                                                onSelect = function()
                                                                                    local to =
                                                                                        lib.callback.await(
                                                                                        "wx_reports:getCoords",
                                                                                        nil,
                                                                                        sortdata.playerid
                                                                                    )
                                                                                    SetEntityCoords(cache.ped, to)
                                                                                end
                                                                            },
                                                                            {
                                                                                title = locale("bring"),
                                                                                icon = "map-location-dot",
                                                                                onSelect = function()
                                                                                    lib.callback.await(
                                                                                        "wx_reports:bringPlayer",
                                                                                        nil,
                                                                                        sortdata.playerid
                                                                                    )
                                                                                end
                                                                            }
                                                                        }
                                                                    }
                                                                )
                                                                lib.showContext(
                                                                    "reportactions_" .. sortdata.reportid
                                                                )
                                                            end
                                                        }
                                                    )
                                                else
                                                    table.insert(
                                                        sortopt,
                                                        {
                                                            title = ("[#%s] %s"):format(
                                                                sortdata.reportid,
                                                                sortdata.title
                                                            ),
                                                            description = ("[%s] %s: '%s'"):format(
                                                                sortdata.playerid,
                                                                sortdata.playername,
                                                                sortdata.message
                                                            ),
                                                            icon = "user-tie",
                                                            metadata = {
                                                                {
                                                                    label = locale("receivedAt"),
                                                                    value = sortdata.time
                                                                },
                                                                {
                                                                    label = locale("playerId"),
                                                                    value = sortdata.playerid
                                                                },
                                                                {
                                                                    label = locale("playerName"),
                                                                    value = sortdata.playername
                                                                },
                                                                {label = locale("admin"), value = sortdata.admin},
                                                                {label = locale("status"), value = sortdata.status}
                                                            },
                                                            onSelect = function()
                                                                local rid = sortdata.reportid
                                                                lib.registerContext(
                                                                    {
                                                                        id = "reportactions_" .. sortdata.reportid,
                                                                        title = locale("manageReport", rid),
                                                                        menu = "adminreports",
                                                                        options = {
                                                                            {
                                                                                title = locale("take"),
                                                                                icon = "handshake-simple",
                                                                                onSelect = function()
                                                                                    lib.callback.await(
                                                                                        "wx_reports:takeReport",
                                                                                        nil,
                                                                                        sortdata.reportid
                                                                                    )
                                                                                end
                                                                            },
                                                                            {
                                                                                title = locale("teleport"),
                                                                                icon = "street-view",
                                                                                onSelect = function()
                                                                                    local to =
                                                                                        lib.callback.await(
                                                                                        "wx_reports:getCoords",
                                                                                        nil,
                                                                                        sortdata.playerid
                                                                                    )
                                                                                    SetEntityCoords(cache.ped, to)
                                                                                end
                                                                            },
                                                                            {
                                                                                title = locale("bring"),
                                                                                icon = "map-location-dot",
                                                                                onSelect = function()
                                                                                    lib.callback.await(
                                                                                        "wx_reports:bringPlayer",
                                                                                        nil,
                                                                                        sortdata.playerid
                                                                                    )
                                                                                end
                                                                            },
                                                                            {
                                                                                title = locale("reply"),
                                                                                icon = "reply",
                                                                                onSelect = function()
                                                                                    local message =
                                                                                        lib.inputDialog(
                                                                                        locale(
                                                                                            "replyTitle",
                                                                                            sortdata.playername
                                                                                        ),
                                                                                        {
                                                                                            {
                                                                                                type = "textarea",
                                                                                                label = locale(
                                                                                                    "replyLabel"
                                                                                                ),
                                                                                                description = locale(
                                                                                                    "replyDesc"
                                                                                                ),
                                                                                                required = true,
                                                                                                min = 1,
                                                                                                max = 128,
                                                                                                placeholder = locale(
                                                                                                    "replyPlaceholder"
                                                                                                )
                                                                                            }
                                                                                        }
                                                                                    )
                                                                                    lib.callback.await(
                                                                                        "wx_reports:messagePlayer",
                                                                                        nil,
                                                                                        sortdata.playerid,
                                                                                        sortdata.reportid,
                                                                                        message[1]
                                                                                    )
                                                                                end
                                                                            },
                                                                            {
                                                                                title = locale("delete"),
                                                                                icon = "trash-alt",
                                                                                onSelect = function()
                                                                                    local confirm =
                                                                                        lib.alertDialog(
                                                                                        {
                                                                                            header = locale(
                                                                                                "deleteConfirmTitle"
                                                                                            ),
                                                                                            content = locale(
                                                                                                "deleteConfirmDesc",
                                                                                                sortdata.reportid,
                                                                                                sortdata.playername
                                                                                            ),
                                                                                            centered = true,
                                                                                            cancel = true
                                                                                        }
                                                                                    )
                                                                                    if confirm == "confirm" then
                                                                                        lib.callback.await(
                                                                                            "wx_reports:deleteReport",
                                                                                            nil,
                                                                                            rid
                                                                                        )
                                                                                    end
                                                                                end
                                                                            },
                                                                            {
                                                                                title = locale("markComplete"),
                                                                                icon = "circle-check",
                                                                                onSelect = function()
                                                                                    lib.callback.await(
                                                                                        "wx_reports:completeReport",
                                                                                        nil,
                                                                                        rid
                                                                                    )
                                                                                end
                                                                            }
                                                                        }
                                                                    }
                                                                )
                                                                lib.showContext("reportactions_" .. rid)
                                                            end
                                                        }
                                                    )
                                                end
                                            end
                                            lib.registerContext(
                                                {
                                                    id = "sortedReports",
                                                    title = locale("sortedReports"),
                                                    options = sortopt
                                                }
                                            )
                                            lib.showContext("sortedReports")
                                        end
                                    end
                                }
                            )
                        end
                        for k, v in pairs(reports) do
                            if v.status == locale("completed") then
                                table.insert(
                                    completed,
                                    {
                                        title = ("[#%s] %s"):format(v.reportid, v.title),
                                        description = ('"%s"'):format(v.message),
                                        metadata = {
                                            {label = locale("receivedAt"), value = v.time},
                                            {label = locale("playerId"), value = v.playerid},
                                            {label = locale("playerName"), value = v.playername},
                                            {label = locale("admin"), value = v.admin},
                                            {label = locale("status"), value = v.status}
                                        },
                                        onSelect = function()
                                            lib.registerContext(
                                                {
                                                    id = "reportactions_" .. v.reportid,
                                                    title = locale("completedReports"),
                                                    menu = "adminreports",
                                                    options = {
                                                        {
                                                            title = locale("reopen"),
                                                            icon = "arrow-rotate-left",
                                                            onSelect = function()
                                                                lib.callback.await(
                                                                    "wx_reports:reopenReport",
                                                                    nil,
                                                                    v.reportid
                                                                )
                                                            end
                                                        },
                                                        {
                                                            title = locale("teleport"),
                                                            icon = "street-view",
                                                            onSelect = function()
                                                                local to =
                                                                    lib.callback.await(
                                                                    "wx_reports:getCoords",
                                                                    nil,
                                                                    v.playerid
                                                                )
                                                                SetEntityCoords(cache.ped, to)
                                                            end
                                                        },
                                                        {
                                                            title = locale("bring"),
                                                            icon = "map-location-dot",
                                                            onSelect = function()
                                                                lib.callback.await(
                                                                    "wx_reports:bringPlayer",
                                                                    nil,
                                                                    v.playerid
                                                                )
                                                            end
                                                        }
                                                    }
                                                }
                                            )
                                            lib.showContext("reportactions_" .. v.reportid)
                                        end
                                    }
                                )
                                lib.registerContext(
                                    {
                                        id = "completed",
                                        title = locale("completedReports"),
                                        options = completed
                                    }
                                )
                                table.insert(
                                    opt,
                                    {
                                        title = locale("completedReports"),
                                        description = locale("completedReportsDesc"),
                                        menu = "completed"
                                    }
                                )
                            else
                                if v.admin ~= locale("none") then
                                    table.insert(
                                        opt,
                                        {
                                            title = ("[#%s] %s"):format(v.reportid, v.title),
                                            description = ("[%s] %s: '%s'"):format(
                                                v.playerid,
                                                v.playername,
                                                v.message
                                            ),
                                            icon = "user-tie",
                                            metadata = {
                                                {label = locale("receivedAt"), value = v.time},
                                                {label = locale("playerId"), value = v.playerid},
                                                {label = locale("playerName"), value = v.playername},
                                                {label = locale("admin"), value = v.admin},
                                                {label = locale("status"), value = v.status}
                                            },
                                            onSelect = function()
                                                local rid = v.reportid
                                                lib.registerContext(
                                                    {
                                                        id = "reportactions_" .. v.reportid,
                                                        title = locale("manageReport", rid),
                                                        menu = "adminreports",
                                                        options = {
                                                            {
                                                                title = locale("take"),
                                                                icon = "handshake-simple",
                                                                onSelect = function()
                                                                    lib.callback.await(
                                                                        "wx_reports:takeReport",
                                                                        nil,
                                                                        v.reportid
                                                                    )
                                                                end
                                                            },
                                                            {
                                                                title = locale("teleport"),
                                                                icon = "street-view",
                                                                onSelect = function()
                                                                    local to =
                                                                        lib.callback.await(
                                                                        "wx_reports:getCoords",
                                                                        nil,
                                                                        v.playerid
                                                                    )
                                                                    SetEntityCoords(cache.ped, to)
                                                                end
                                                            },
                                                            {
                                                                title = locale("bring"),
                                                                icon = "map-location-dot",
                                                                onSelect = function()
                                                                    lib.callback.await(
                                                                        "wx_reports:bringPlayer",
                                                                        nil,
                                                                        v.playerid
                                                                    )
                                                                end
                                                            },
                                                            {
                                                                title = locale("reply"),
                                                                icon = "reply",
                                                                onSelect = function()
                                                                    local message =
                                                                        lib.inputDialog(
                                                                        locale("replyTitle", v.playername),
                                                                        {
                                                                            {
                                                                                type = "textarea",
                                                                                label = locale("replyLabel"),
                                                                                description = locale("replyDesc"),
                                                                                required = true,
                                                                                min = 1,
                                                                                max = 128,
                                                                                placeholder = locale(
                                                                                    "replyPlaceholder"
                                                                                )
                                                                            }
                                                                        }
                                                                    )
                                                                    lib.callback.await(
                                                                        "wx_reports:messagePlayer",
                                                                        nil,
                                                                        v.playerid,
                                                                        v.reportid,
                                                                        message[1]
                                                                    )
                                                                end
                                                            },
                                                            {
                                                                title = locale("delete"),
                                                                icon = "trash-alt",
                                                                onSelect = function()
                                                                    local confirm =
                                                                        lib.alertDialog(
                                                                        {
                                                                            header = locale("deleteConfirmTitle"),
                                                                            content = locale(
                                                                                "deleteConfirmDesc",
                                                                                v.reportid,
                                                                                v.playername
                                                                            ),
                                                                            centered = true,
                                                                            cancel = true
                                                                        }
                                                                    )
                                                                    if confirm == "confirm" then
                                                                        lib.callback.await(
                                                                            "wx_reports:deleteReport",
                                                                            nil,
                                                                            rid
                                                                        )
                                                                    end
                                                                end
                                                            },
                                                            {
                                                                title = locale("markComplete"),
                                                                icon = "circle-check",
                                                                onSelect = function()
                                                                    lib.callback.await(
                                                                        "wx_reports:completeReport",
                                                                        nil,
                                                                        rid
                                                                    )
                                                                end
                                                            }
                                                        }
                                                    }
                                                )
                                                lib.showContext("reportactions_" .. rid)
                                            end
                                        }
                                    )
                                else
                                    table.insert(
                                        opt,
                                        {
                                            title = ("[#%s] %s"):format(v.reportid, v.title),
                                            description = ("[%s] %s: '%s'"):format(
                                                v.playerid,
                                                v.playername,
                                                v.message
                                            ),
                                            metadata = {
                                                {label = locale("receivedAt"), value = v.time},
                                                {label = locale("playerId"), value = v.playerid},
                                                {label = locale("playerName"), value = v.playername},
                                                {label = locale("admin"), value = v.admin},
                                                {label = locale("status"), value = v.status}
                                            },
                                            onSelect = function()
                                                local rid = v.reportid
                                                lib.registerContext(
                                                    {
                                                        id = "reportactions_" .. v.reportid,
                                                        title = locale("manageReport", rid),
                                                        menu = "adminreports",
                                                        options = {
                                                            {
                                                                title = locale("take"),
                                                                icon = "handshake-simple",
                                                                onSelect = function()
                                                                    lib.callback.await(
                                                                        "wx_reports:takeReport",
                                                                        nil,
                                                                        v.reportid
                                                                    )
                                                                end
                                                            },
                                                            {
                                                                title = locale("teleport"),
                                                                icon = "street-view",
                                                                onSelect = function()
                                                                    local to =
                                                                        lib.callback.await(
                                                                        "wx_reports:getCoords",
                                                                        nil,
                                                                        v.playerid
                                                                    )
                                                                    SetEntityCoords(cache.ped, to)
                                                                end
                                                            },
                                                            {
                                                                title = locale("bring"),
                                                                icon = "map-location-dot",
                                                                onSelect = function()
                                                                    lib.callback.await(
                                                                        "wx_reports:bringPlayer",
                                                                        nil,
                                                                        v.playerid
                                                                    )
                                                                end
                                                            },
                                                            {
                                                                title = locale("reply"),
                                                                icon = "reply",
                                                                onSelect = function()
                                                                    local message =
                                                                        lib.inputDialog(
                                                                        locale("replyTitle", v.playername),
                                                                        {
                                                                            {
                                                                                type = "textarea",
                                                                                label = locale("replyLabel"),
                                                                                description = locale("replyDesc"),
                                                                                required = true,
                                                                                min = 1,
                                                                                max = 128,
                                                                                placeholder = locale(
                                                                                    "replyPlaceholder"
                                                                                )
                                                                            }
                                                                        }
                                                                    )
                                                                    lib.callback.await(
                                                                        "wx_reports:messagePlayer",
                                                                        nil,
                                                                        v.playerid,
                                                                        v.reportid,
                                                                        message[1]
                                                                    )
                                                                end
                                                            },
                                                            {
                                                                title = locale("delete"),
                                                                icon = "trash-alt",
                                                                onSelect = function()
                                                                    local confirm =
                                                                        lib.alertDialog(
                                                                        {
                                                                            header = locale("deleteConfirmTitle"),
                                                                            content = locale(
                                                                                "deleteConfirmDesc",
                                                                                v.reportid,
                                                                                v.playername
                                                                            ),
                                                                            centered = true,
                                                                            cancel = true
                                                                        }
                                                                    )
                                                                    if confirm == "confirm" then
                                                                        lib.callback.await(
                                                                            "wx_reports:deleteReport",
                                                                            nil,
                                                                            rid
                                                                        )
                                                                    end
                                                                end
                                                            },
                                                            {
                                                                title = locale("markComplete"),
                                                                icon = "circle-check",
                                                                onSelect = function()
                                                                    lib.callback.await(
                                                                        "wx_reports:completeReport",
                                                                        nil,
                                                                        rid
                                                                    )
                                                                end
                                                            }
                                                        }
                                                    }
                                                )
                                                lib.showContext("reportactions_" .. rid)
                                            end
                                        }
                                    )
                                end
                            end
                        end
                        lib.registerContext(
                            {
                                id = "adminreports",
                                title = locale("allReports"),
                                options = opt
                            }
                        )
                        lib.showContext("adminreports")
                    end
                }
            }
        }
    )
    lib.showContext("reportmenu")
end,false)
