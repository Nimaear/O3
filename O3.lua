local addon, ns = ...
local tInsert = table.insert
local tWipe = table.wipe

--- Base of all Class derivatives
local Class = {
	--- Internaally used to refered to a parent class
	_parent = nil,
	--- gets called upon 'creation' of an object of this class
	init = function (self, ...)
	end,
	--- The 'constructor' function for any class
	-- @param template A skeleton that should be used as the base object, this is optional
	new = function (self, ...)
		local instance = {}
		setmetatable(instance, {__index = self})
		instance:init(...)
		return instance
	end,
	--- The go to method for implementing inheritance.
	-- @param child The child class to extend
	extend = function (self, child)	
		local child = child or {}
		setmetatable(child, {__index = self, __call = self.instance})
		child._parent = self
		return child
	end,
	setCall = function (self, call)
		local mt = getmetatable(self)
		mt.__call = call
		setmetatable(self, mt)
	end,
	instance = function (self, child, ...)
		child = self:extend(child):new(...)
		return child
	end,
	--- The goto	method for mixing in this class with another one
	-- @param target Target object to mix this class in
	mixin = function (self, target)
		for k,v in pairs(self) do
			if (not target[k] and string.byte(k) ~= '_') then
				target[k] = v
			end
		end
		self:_mix(target)
	end,
	--- Gets called after mixing in is done
	_mix = function (self, target)
	end,
}
setmetatable(Class, {__call = Class.extend})

local EventHandler = Class:extend({
	unregisterEvents = function (self)
		self.frame:UnregisterAllEvents()
	end,
	registerEvents = function (self)
		if not self.events then
			return 
		end
		for event, enabled in pairs(self.events) do
			if (enabled) then
				self:registerEvent(event)
			end
		end
	end,
	unregisterEvent = function (self, event, object)
		object = object or self
		self._events[event][object] = false
		local hasEvent = false
		for object, enabled in pairs(self._events[event]) do
			hasEvent = hasEvent or enabled
			if hasEvent then
				break
			end
		end
		if not hasEvent then
			self.frame:UnregisterEvent(event)
		end
	end,
	registerEvent = function (self, event, object)
		self.frame:RegisterEvent(event)
		object = object or self
		self._events[event] = self._events[event] or {}
		self._events[event][object] = true
	end,
	setupEventHandler = function (self)
		self.frame:SetScript('OnEvent', function (frame, event, ...)
			local objects = self._events[event]
			if objects then
				for object, enabled in pairs(objects) do
					if enabled and object[event] then
						object[event](object, ...)
					end
				end
			end
		end)	
	end,
	initEventHandler = function (self)
		self:setupEventHandler()
		self:registerEvents()
	end,
	_mix = function (self, target)
		if not target.events then
			target.events = {}
		end
		target._events = {}
	end,
})

local Engine = Class:extend({
	Class = Class,
	EventHandler = EventHandler,
	modules = {},
	queue = {},
	config = {
	},
	settings = {
		Window = {},
	},
	events = {
		PLAYER_LOGIN = true,
		PLAYER_ENTERING_WORLD = true,
		VARIABLES_LOADED = true,
	},
	formatMoney = function(self, money)
		local money = money or 0
		return GetCoinTextureString(money)
		-- local gold = math.floor(money / 1e4)
		-- local silver = math.floor(mod(money / 1e2, 1e2))
		-- local copper = math.floor(money % 1e2)
		-- local goldAbbrev, silverAbbrev, copperAbbrev = "g","s","c"

		-- return gold > 0 and string.format('|cffffff66%d'..goldAbbrev..'|r |cffc0c0c0%d'..silverAbbrev..'|r |cffcc9900%d'..copperAbbrev..'|r', gold, silver, copper) or
		-- 	silver > 0 and string.format('|cffc0c0c0%d'..silverAbbrev..'|r |cffcc9900%d'..copperAbbrev..'|r', silver, copper) or
		-- 	copper > 0 and string.format('|cffcc9900%d'..copperAbbrev..'|r', copper) or ''
	end,
	shortValue = function (self, value)
		if value >= 1e6 then
			return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
		elseif value >= 1e3 or value <= -1e3 then
			return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
		else
			return value
		end
	end,
	shortValueNegative = function(self, value)
		if value <= 999 then return value end
		if value >= 1000000 then
			return string.format("%.1fm", value/1000000)
		elseif value >= 1000 then
			return string.format("%.1fk", value/1000)
		end
	end,		
	deepcopy = function(self, o, seen)
		seen = seen or {}
		if o == nil then return nil end
		if seen[o] then return seen[o] end

		local no
		if type(o) == 'table' then
			no = {}
			seen[o] = no

			for k, v in next, o, nil do
				no[self:deepcopy(k, seen)] = self:deepcopy(v, seen)
			end
			--setmetatable(no, deepcopy(self:getmetatable(o), seen))
		else 
			no = o
		end
		return no
	end,
	split = function (self, s, delimiter, result)
	    result = result or {}
    	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
	        table.insert(result, match)
    	end
    	return result
	end,	
	register = function (self, module)
		self[module.name] = module
		table.insert(self.modules, module)
		if (not self.settings[module.name]) then
			self.settings[module.name] = module.settings
		end
		module:register(self)
	end,
	PLAYER_LOGIN = function (self)
		local _, class = UnitClass("player")
		local _, race = UnitRace("player")

		self.playerFaction = UnitFactionGroup("player")
		self.playerClass = class
		self.playerRace = race
		self.playerName = UnitName("player") 
		self.playerRealm = GetRealmName()
		self.playerGUID = UnitGUID('player')

	end,
	-------------------------------------------------------------------------------------
	-- Unregisters all events from a region and hides it
	-- Also makes sure it can't be shown after this operation
	--
	-- @param region Region to "destroy"
	-------------------------------------------------------------------------------------
	destroy = function(self, region)
		if (region.UnregisterAllEvents) then
			region:UnregisterAllEvents()
		end
		region.Show = function () end
		region:Hide()
	end,
	-----------------------------------------------------------------
	-- Executes a function if or when the player is out of combat,
	-- This is mostly used to prevent taints.
	--
	-- @param func Function to be executed out of combat
	-----------------------------------------------------------------
	safe = function (self, func)
		if InCombatLockdown() then
			tInsert(self.queue,func)
			if (not self.frame:IsEventRegistered("PLAYER_REGEN_ENABLED")) then
				self:registerEvent("PLAYER_REGEN_ENABLED")
			end
		else
			func()
		end
	end,
	-----------------------------------------------------------------
	-- Execute the things in the queue when we get out of combat.
	-----------------------------------------------------------------
	PLAYER_REGEN_ENABLED = function(self, ...)
		for i, v in ipairs(self.queue) do
			v()
		end
		tWipe(self.queue)
		self:unregisterEvent("PLAYER_REGEN_ENABLED")
	end,	
	PLAYER_ENTERING_WORLD = function (self)
	end,
	VARIABLES_LOADED = function (self)
		if (O3Settings) then
			self.settings = O3Settings
		else
			O3Settings = self.settings
		end
		setmetatable(self.settings, {__index = self.config})
		for i = 1, #self.modules do
			local m = self.modules[i]
			if (self.settings[m.name]) then
				m.settings = self.settings[m.name]
			else
				self.settings[m.name] = m.settings
			end
			setmetatable(m.settings, {__index = m.config})
			m:VARIABLES_LOADED()
		end
	end,	
	init = function (self)
		local verticalPixelHeight = nil

		self.frame = CreateFrame('Frame', 'O3', UIParent)
		EventHandler:mixin(self)
		self:initEventHandler()

		--SetCVar("uiScale", self.uiScale)
		-- This function will calculate the "real" size for a pixel on the screen

	end,
})



ns.O3 = Engine:new()

_G['O3'] = ns.O3
-- local TestAddon = O3:addon({
-- 	name = 'Test',
-- 	config = {
-- 		test = 1,
-- 	},
-- 	init = function (self)
		
-- 	end,
-- })


SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI


BINDING_HEADER_O3General = 'General'
BINDING_HEADER_O3Targeting = 'Targeting'