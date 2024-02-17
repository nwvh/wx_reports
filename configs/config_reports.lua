wx = {}

wx.AdminGroups = { -- ESX admin groups
    ["admin"] = true
}

wx.Command = "report" -- Report menu command
wx.Cooldown = 2500 -- Cooldown players have before creating another report
wx.LogSystem = "wx" -- [wx/custom/false] -- If "wx", make sure you have wx_logs installed, if custom, edit the functions in server/editme.lua, if false, discord logs won't be used
wx.DefaultColor = "#7048E8" -- HEX Color code that will be used mostly for notification icons
wx.MaxReports = 3 -- Maximum reports one player can have at once. Set to -1 to disable
wx.Sounds = { -- Choose whenever to play notification sounds
    Reply = true, -- When player receives a reply
    NewReport = true, -- When admins receive a new report
    Other = true -- When player receives a notification about their report being closed or deleted
}

if wx.LogSystem == "wx" then
    wx.Webhooks = { -- Only edit this if you set the LogSystem to "wx" and wx_logs is installed
        -- Set only the webhook id/name, make sure it's the same as in the wx_logs config. Do NOT set it to the webhook URL
        Received = "receive",
        Completed = "complete",
        Deleted = "delete",
    }
end