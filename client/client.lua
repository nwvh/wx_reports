ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('wx_reports:send')
AddEventHandler('wx_reports:send', function(id, name, message)
	local sourceID = PlayerId()
	local playerID = GetPlayerFromServerId(id)
	ESX.TriggerServerCallback('wx_reports:getPlayerGroup', function(pgroup)
		if playerID == sourceID then
			if message == '' or message == nil then
				TriggerEvent('chat:addMessage', {
					template = '<div style="padding: 0.4vw; margin: 0.4vw; background-color: rgba(24, 26, 32, 0.45); border-radius: 5px; border-right: 0px solid rgb(255, 0, 0);"><font style="padding: 0.22vw; margin: 0.22vw; background-color: rgb(180, 30, 30); border-radius: 5px; font-size: 15px;"> <b>ERROR</b></font>   <font style="background-color:rgba(0, 0, 0, 0); font-size: 17px; margin-left: 0px; padding-bottom: 2.5px; padding-left: 3.5px; padding-top: 2.5px; padding-right: 3.5px;border-radius: 0px;"></font>  <font style=" font-weight: 800; font-size: 15px; margin-left: 5px; padding-bottom: 3px; border-radius: 0px;"><b></b></font><font style=" font-weight: 200; font-size: 14px; border-radius: 0px;">Report message cannot be empty!</font></div>',
					args = { id, name, message }
				})
			else
			TriggerEvent('chat:addMessage', {
				template = '<div style="padding: 0.4vw; margin: 0.4vw; background-color: rgba(24, 26, 32, 0.45); border-radius: 5px; border-right: 0px solid rgb(255, 0, 0);"><font style="padding: 0.22vw; margin: 0.22vw; background-color: rgb(30, 180, 30); border-radius: 5px; font-size: 15px;"> <b>SUCCESS</b></font>   <font style="background-color:rgba(0, 0, 0, 0); font-size: 17px; margin-left: 0px; padding-bottom: 2.5px; padding-left: 3.5px; padding-top: 2.5px; padding-right: 3.5px;border-radius: 0px;"></font>  <font style=" font-weight: 800; font-size: 15px; margin-left: 5px; padding-bottom: 3px; border-radius: 0px;"><b></b></font><font style=" font-weight: 200; font-size: 14px; border-radius: 0px;">Report has been sent to active admins! Your message: <b>{2}</b></font></div>',
				args = { id, name, message }
			})
		end	
		elseif pgroup ~= "user" and playerID ~= sourceID and message ~= '' and message ~= nil then
			TriggerEvent('chat:addMessage', {
				template = '<div style="padding: 0.4vw; margin: 0.4vw; background-color: rgba(24, 26, 32, 0.45); border-radius: 5px; border-right: 0px solid rgb(255, 0, 0);"><font style="padding: 0.22vw; margin: 0.22vw; background-color: rgb(180, 30, 30); border-radius: 5px; font-size: 15px;"> <b>NEW REPORT</b></font>   <font style="background-color:rgba(0, 0, 0, 0); font-size: 17px; margin-left: 0px; padding-bottom: 2.5px; padding-left: 3.5px; padding-top: 2.5px; padding-right: 3.5px;border-radius: 0px;"> <b> [{0}] {1}: </b></font>  <font style=" font-weight: 800; font-size: 15px; margin-left: 5px; padding-bottom: 3px; border-radius: 0px;"><b></b></font><font style=" font-weight: 200; font-size: 14px; border-radius: 0px;">{2}</font></div>',
				args = { id, name, message }
			})		
		end
	end)	  	
end)