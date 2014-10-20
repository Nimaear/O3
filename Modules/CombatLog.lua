-- timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2
local addon, ns = ...
local O3 = ns.O3

local combatLog = O3:module({
	name = 'CombatLog',
	config = {
		enabled = true,
	},	

	listeners = {},
	events = {
		COMBAT_LOG_EVENT_UNFILTERED = true,	
	},
	setup = function (self)
		self.frame = CreateFrame('Frame', nil, UIParent)
		self:initEventHandler()
	end,
	COMBAT_LOG_EVENT_UNFILTERED = function (self, timeStamp, subEvent, ...)
		if (self.listeners[subEvent]) then
			for i = 1, #self.listeners[subEvent] do

				local handler = self.listeners[subEvent][i]
				handler(...)
			end
		end
	end,
	
	addListener = function (self, subEvent, func)
		self.listeners[subEvent] = self.listeners[subEvent] or {}
		table.insert(self.listeners[subEvent], func)
	end,
})

O3:module({
	name = 'AuraWatcher',
	config = {
		enabled = true,
	},
	events = {
		PLAYER_ENTERING_WORLD = true,
		PLAYER_TARGET_CHANGED = true,
		PLAYER_FOCUS_CHANGED = true,
		UPDATE_MOUSEOVER_UNIT = true,
	},
	guids = {
		player = nil,
		target = nil,
		mouseover = nil,
		focus = nil,
	},
	enteredWorld = false,
	listeners = {},
	watchedAuras = {},
	register = function (self, spellId, listener)
		self.listeners[spellId] = self.listeners[spellId] or {}
		table.insert(self.listeners[spellId], listener)
		self.watchedAuras[spellId] = true
		if (self.enteredWorld) then
			listener:reset()
		end
	end,
	unregister = function (self, spellId, listener)
		if (self.listeners[spellId]) then
			for i = 1, #self.listeners[spellId] do
				if self.listeners[spellId][i] == listener then
					table.remove(self.listeners[spellId], i)
					return
				end
			end
		end
	end,
	PLAYER_TARGET_CHANGED = function (self)
		self.guids.target = UnitGUID('target')
	end,
	PLAYER_FOCUS_CHANGED = function (self)
		self.guids.focus = UnitGUID('focus')
	end,
	UPDATE_MOUSEOVER_UNIT = function (self)
		self.guids.mouseover = UnitGUID('mouseover')
	end,
	setup = function (self)
		self.frame = CreateFrame('Frame', nil, UIParent)
		self:initEventHandler()
	end,	
	PLAYER_ENTERING_WORLD = function (self)
		self:initListeners()
		self.PLAYER_ENTERING_WORLD = self.reset
		self:reset()
		self.enteredWorld = true
	end,
	reset = function (self)
		for spellId, listeners in pairs(self.listeners) do
			for i = 1, #listeners do
				local listener = listeners[i]
				if (listener.enabled) then
					listener:reset()
				end
			end
		end	
	end,
	getAura = function (self, unitId, querySpellId, filter)
		local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3
		for i = 1, 40 do
			name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3 = UnitAura('player', i, filter)
			if (name and spellId == querySpellId) then
				return name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3
			elseif not name then
				break
			end
		end
		return null
	end,
	initListeners = function (self)
		self.guids.player = UnitGUID('player')
		local listeners = self.listeners
		local watchedAuras = self.watchedAuras
		combatLog:addListener('SPELL_AURA_APPLIED_DOSE', function (hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, auraType, amount) 
			local foundUnitId = nil
			for unitId, guid in pairs(self.guids) do
				if guid == destGUID then
					foundUnitId = unitId
					break
				end
			end
			if (watchedAuras[spellId]) then
				for i = 1, #listeners[spellId] do
					local listener = listeners[spellId][i]
					if (listener.enabled) then
						listener:dose(spellId, foundUnitId, destGUID, destName, sourceGUID == self.guids.player, amount)
					end
				end
			end
		end)

		combatLog:addListener('SPELL_AURA_REMOVED_DOSE', function (hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, auraType, amount) 
			local foundUnitId = nil
			for unitId, guid in pairs(self.guids) do
				if guid == destGUID then
					foundUnitId = unitId
					break
				end
			end

			if (watchedAuras[spellId]) then
				for i = 1, #listeners[spellId] do
					local listener = listeners[spellId][i]
					if (listener.enabled) then
						listener:dose(spellId, foundUnitId, destGUID, destName, sourceGUID == self.guids.player, amount)
					end
				end
			end
		end)

		combatLog:addListener('SPELL_AURA_APPLIED', function (hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, auraType) 
			local foundUnitId = nil
			for unitId, guid in pairs(self.guids) do
				if guid == destGUID then
					foundUnitId = unitId
					break
				end
			end
			if (watchedAuras[spellId]) then
				for i = 1, #listeners[spellId] do
					local listener = listeners[spellId][i]
					if (listener.enabled) then
						listener:apply(spellId, foundUnitId, destGUID, destName, sourceGUID == self.guids.player)
					end
				end
			end
		end)

		combatLog:addListener('SPELL_AURA_REMOVED', function (hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, auraType) 
			local foundUnitId = nil
			for unitId, guid in pairs(self.guids) do
				if guid == destGUID then
					foundUnitId = unitId
					break
				end
			end

			if (watchedAuras[spellId]) then
				for i = 1, #listeners[spellId] do
					local listener = listeners[spellId][i]
					if (listener.enabled) then
						listener:remove(spellId, foundUnitId, destGUID, destName, sourceGUID == self.guids.player)
					end
				end
			end
		end)

		combatLog:addListener('SPELL_AURA_REFRESH', function (hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, auraType) 
			local foundUnitId = nil
			for unitId, guid in pairs(self.guids) do
				if guid == destGUID then
					foundUnitId = unitId
					break
				end
			end
			if (watchedAuras[spellId]) then
				for i = 1, #listeners[spellId] do
					local listener = listeners[spellId][i]
					if (listener.enabled) then
						listener:refresh(spellId, foundUnitId, destGUID, destName, sourceGUID == self.guids.player)
					end
				end
			end
		end)
	end,
})

