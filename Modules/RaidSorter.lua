local addon, ns = ...
local O2 = ns.O2

local raidSorter = O2:module({
	name = 'RaidSorter',
	config = {
		enabled = true,
	},
	settings = {

	},
	done = true,
	events = {
		GROUP_ROSTER_UPDATE = true,
	},
	cache = {},
	wantedOrder = {},
	wantedGroup = {},
	started = false,
	lookup = {},
	groupLookup = {},
	lastUpdate = 0,
	addOptions = function (self)
		-- self:addOption('_1', {
		-- 	type = 'Title',
		-- 	label = 'Announce',
		-- })
		-- self:addOption('channel', {
		-- 	type = 'DropDown',
		-- 	label = 'Channel',
		-- 	choices = {
		-- 		{ label = 'None', value = nil},
		-- 		{ label = 'Say', value = 'SAY'},
		-- 		{ label = 'Party', value = 'PARTY'},
		-- 		{ label = 'Raid', value = 'RAID'},
		-- 		{ label = 'Print', value = 'PRINT'},
		-- 		}
		-- })
		-- self:addOption('message', {
		-- 	type = 'String',
		-- 	label = 'Interupt message',
		-- })
  --       self:addOption('statusBar', {
  --           type = 'DropDown',
  --           dropDownType = 'StatusBarDropDown',
  --           label = 'Health texture',
  --       })  		
  --       self:addOption('font', {
  --           type = 'DropDown',
  --           dropDownType = 'FontDropDown',
  --           label = 'Health texture',
  --       })
  --       self:addOption('check', {
  --           type = 'CheckBox',
  --           label = 'Check meh',
  --       })
  --       self:addOption('button', {
  --           type = 'Button',
  --           label = 'Toggle meh',
  --       })        
  --       self:addOption('toggle', {
  --           type = 'Toggle',
  --           label = 'Toggle meh',
  --       })
  --       self:addOption('range', {
  --           type = 'Range',
  --           label = 'Range meh',
  --       })
    end,	
	setup = function (self)
		self.frame = CreateFrame('Frame', nil, UIParent)
		self:setupEventHandler()	

		self.frame:SetSize(5,5)

	end,
	explode = function (pString, pPattern)
		local values = {}
		local fpat = "(.-)" .. pPattern
		local last_end = 1
		local s, e, cap = pString:find(fpat, 1)
		while s do
			if s ~= 1 or cap ~= "" then
				table.insert(values,cap)
			end
			last_end = e+1
			s, e, cap = pString:find(fpat, last_end)
		end
		if last_end <= #pString then
			cap = pString:sub(last_end)
			table.insert(values, cap)
		end
		return values
	end,
	updateLookups = function (self)
		local raidMemberCount =  GetNumGroupMembers()
		table.wipe(self.lookup)
		table.wipe(self.groupLookup)
		for index = 1, raidMemberCount do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(index)
			self.lookup[name] = index
			self.groupLookup[name] = subgroup
		end
	end,
	findSomeoneForGroup = function(self, subgroup)
		local raidMemberCount =  GetNumGroupMembers()
		for index = 1, raidMemberCount do
			local name, rank, actualGroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(index)
			if (not self.wantedGroup[name]) or (actualGroup ~= subgroup and subgroup == self.wantedGroup[name]) then
				return index
			end
		end
	end,
	GROUP_ROSTER_UPDATE = function (self)
		if (not self.started) then
			return
		end
		local time = GetTime()
		if (not self.done and time > self.lastUpdate + 0.2) then
			if (not InCombatLockdown()) then
				self:tick()
				self.lastUpdate = time
			end
		end
	end,
	tick = function (self)
		self:updateLookups()
		
		for i = 1, #self.wantedOrder do
			local name = self.wantedOrder[i]
			local wantedGroup = math.ceil(i/5)
			local actualGroup = self.groupLookup[name]
			if (not self.lookup[name]) then
				print(name, ' not known')
			elseif wantedGroup ~= actualGroup then

				local replacer = self:findSomeoneForGroup(actualGroup)
				print(name, 'wants', wantedGroup, 'but is in', actualGroup, 'Switching with', replacer)
				if replacer then
					SwapRaidSubgroup(self.lookup[name], replacer)					
				else
					SetRaidSubgroup(self.lookup[name], wantedGroup)
				end
				return
			end
		end
		self.done = true
		self.started = false
	end,
	reorganizeRaidGroup = function (self, list)
		self.done = false
		self.started = true
		self.wantedOrder = self.explode(list, " ")
		for i = 1, #self.wantedOrder do
			self.wantedGroup[self.wantedOrder[i]] = math.ceil(i/5)
		end
		O2:safe(function ()
			self:GROUP_ROSTER_UPDATE()
		end)
	end,
})


SLASH_RAIDSORT1 = "/rsort"
SlashCmdList.RAIDSORT = function (list, editBox)
	O2:safe(function ()
		raidSorter:reorganizeRaidGroup(list)
	end)
end
