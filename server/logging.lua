function Log(webhook, data)
    if wx.LogSystem:lower() == "wx" then
        exports["wx_logs"]:SendLog(
            webhook,
            {
                color = 16737095,
                title = data.title,
                fields = data.fields
            }
        )
    elseif wx.LogSystem:lower() == "custom" then
        -- Integrate your logging system here, you may need to edit the data parameter that's being parsed from server.lua
    elseif not wx.LogSystem then
        return "Disabled"
    end
end
