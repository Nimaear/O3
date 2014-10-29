local addon, ns = ...
local O3 = ns.O3

O3:module({
	name = 'SmallPleasures',
	readable = 'Small Pleasures',
	config = {
		enabled = true,
		rareWarning = true,
		rareWarningMessage = "%s spotted!",
	},
	events = {
	},
	settings = {},
	addOptions = function (self)
		self:addOption('_1', {
			type = 'Title',
			label = 'Rare warning',
		})
		self:addOption('rareWarning', {
			type = 'Toggle',
			label = 'Enabled',
		})
		self:addOption('rareWarningMessage', {
			type = 'String',
			label = 'Warning message',
		})
	end,
	VARIABLES_LOADED = function (self)
		if (self.settings.rareWarning) then
			self.events.VIGNETTE_ADDED = true
		end
	end,
	VIGNETTE_ADDED = function (self, vignetteInstanceId, ...)
		PlaySoundFile("Sound\\Interface\\RaidWarning.wav")
		local x, y, name, objectIcon = C_Vignettes.GetVignetteInfoFromInstanceID(vignetteInstanceId)
		name = name or 'Rare'
		RaidNotice_AddMessage(RaidWarningFrame, self.settings.rareWarningMessage:format(name), ChatTypeInfo["RAID_WARNING"])
	end,
	rareWarningSet = function (self)
		if (self.settings.rareWarning) then
			self:registerEvent('VIGNETTE_ADDED')
		else
			self:unregisterEvent('VIGNETTE_ADDED')
		end
	end,
	register = function (self, O3)
	end,
	makeTrackerMovable = function (self)
		ObjectiveTrackerFrame.ignoreFramePositionManager = true
		ObjectiveTrackerFrame:SetMovable(true)
		ObjectiveTrackerFrame:SetUserPlaced(false)

		local adjustSetPoint =  function (self,...)
			local a1,af,a2,x,y = ...
			if af == "MinimapCluster" and not done then    
				self:SetPoint(a1,af,a2,36,-36)
			end
		end

		hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", adjustSetPoint)
	
	end,
	postInit = function (self)
		self:makeTrackerMovable()
	end,
})
