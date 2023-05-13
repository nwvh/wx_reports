wx = {} -- Don't touch
wx.enableAdminChat = true -- Do you want the command /a for admin chat enabled?

wx.AdminGroups = { -- Edit this to match your server's admin groups
	'moderator',
	'staff',
	'admin',
	'headadmin',
    'owner'
}

-- [ Webhook Settings ]
wx.UseWebhooks = true -- Do you want to send every report content to a discord webhook?
wx.Webhook = '' -- Webhook URL
wx.WebhookAvatar = 'https://cdn2.thecatapi.com/images/O2Xx5d4rV.jpg' -- Webhook profile picture (avatar) URL
wx.WebHookName = 'WX Reports' -- Webhook username
wx.WebhookColor = 10053324 -- Webhook message color - Use spycolor.com (Decimal Value)