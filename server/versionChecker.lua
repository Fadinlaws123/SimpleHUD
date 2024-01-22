-- Do not touch anything below here --

local branding = 
[[ 
  // 
  ||
  ||   ____  _                 _      _   _ _   _ ____  
  ||  / ___|(_)_ __ ___  _ __ | | ___| | | | | | |  _ \ 
  ||  \___ \| | '_ ` _ \| '_ \| |/ _ \ |_| | | | | | | |
  ||   ___) | | | | | | | |_) | |  __/  _  | |_| | |_| |
  ||  |____/|_|_| |_| |_| .__/|_|\___|_| |_|\___/|____/ 
  ||                    |_|    
  ||             Made by Fadin_laws
  ||
  ||]]                         
-- Check for version updates.

Citizen.CreateThread(function()
	local CurrentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
	if not CurrentVersion then
		print('[^1SimpleHUD^0] ^SimpleHUD failed to check for any updates!')
	end

	function VersionCheckHTTPRequest()
		PerformHttpRequest('https://raw.githubusercontent.com/Fadinlaws123/ScriptVersionChecker/main/SimpleHUD.json', VersionCheck, 'GET')
	end

	function VersionCheck(err, response, headers)
		Citizen.Wait(3000)
		if err == 200 then
			local Data = json.decode(response)
			if CurrentVersion ~= Data.NewestVersion then
				print( branding )			
				print('  ||    \n  ||    SimpleHUD is outdated!')
				print('  ||    Current version: ^2' .. Data.NewestVersion .. '^7')
				print('  ||    Your version: ^1' .. CurrentVersion .. '^7')
				print('  ||    Please download the lastest version from ^5' .. Data.DownloadLocation .. '^7')
				if Data.Changes ~= '' then
					print('  ||    \n  ||    ^5Changes: ^7' .. Data.Changes .. "\n^0  \\\\\n")
				end
			else
				print( branding )			
				print('  ||    ^2SimpleHUD is up to date!!^0')
				print('  ||    ^2Your version: ^3' .. CurrentVersion .. '\n^0  ||\n  \\\\\n')
			end
		else
			print( branding )			
			print('  ||    ^1There was an issue attempting to get the latest version info regarding SimpleHUD. If this issue continues contact fadin_laws via Simple Development™️ @ https://discord.gg/mxcu8Az8XG \n^0  ||\n  \\\\\n')
		end
		
		SetTimeout(60000000, VersionCheckHTTPRequest)
	end

	VersionCheckHTTPRequest()
end)
