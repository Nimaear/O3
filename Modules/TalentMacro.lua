local addon, ns = ...
local O3 = ns.O3


O3:module({
	name = 'TalentMacro',
	config = {
		enabled = true,
		format = "#showtooltip %s\n/cast [@mouseover,exists] %s; %s"
	},
	settings = {},
	addOptions = function (self)
		self:addOption('format', {
			lines = 5,
			type = 'Text',
			label = 'Format',
		})
	end,
	events = {
		PLAYER_SPECIALIZATION_CHANGED = true,
		ACTIVE_TALENT_GROUP_CHANGED = true,
		PLAYER_ENTERING_WORLD = true,
	},
	setup = function (self)
		self.frame = CreateFrame('Frame', nil, UIParent)
		self:initEventHandler()
	end,
	getRowMacro = function (self, row)
		local maxAccountMacros, maxCharacterMacros =  GetNumMacros()
		for i = 1, (maxAccountMacros) do
			local name, texture, body = GetMacroInfo(i)
			if (name and string.lower(name) == 'row'..row) then
				return i, name, texture, body
			end
		end
		return nil
	end,
	getSelectedTalent = function (self, row, selectedSpec)
		for i = 1, 3 do
			local talentID, name, texture, selected, available = GetTalentInfo(row, i, selectedSpec)
			if (selected) then
				return name, texture
			end
		end
		return nil
	end,
	searchMacro = function (self)
		local selectedSpec = GetActiveSpecGroup()
		local rows = 7
		for i = 1, rows do
			local foundMacroId, name, texture, body = self:getRowMacro(i)
			if (foundMacroId) then
				local selectedTalent, texture = self:getSelectedTalent(i, selectedSpec)
				if (selectedTalent) then
					local spellName, rank, spellID = GetMacroSpell(foundMacroId)
					EditMacro(foundMacroId, name, nil, string.format(self.settings.format, selectedTalent, selectedTalent, selectedTalent))
				end
			end
		end	
	end,
	PLAYER_SPECIALIZATION_CHANGED = function (self)
		O3:safe(function ()
			self:searchMacro()
		end)
	end,
	applyOptions = function (self)
		O3:safe(function ()
			self:searchMacro()
		end)		
	end,
	ACTIVE_TALENT_GROUP_CHANGED = function (self)
		O3:safe(function ()
			self:searchMacro()
		end)
	end,
	PLAYER_ENTERING_WORLD = function (self)
		O3:safe(function ()
			self:searchMacro()
		end)
		self:unregisterEvent('PLAYER_ENTERING_WORLD')
	end,
})



O3:module({
	name = 'Notification',
	readable = 'Notification',
	info = function(self, message)
		print(message)
	end,
})