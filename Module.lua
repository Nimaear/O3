local addon, ns = ...
local O3 = ns.O3

local Module = O3.Class:extend({
	name = nil,
	O3 = nil,
	weight = 1,
	config = {
		enabled = true,
	},
	settings = {
	},
	createPanel = function (self)
		self.panel = self.O3.UI.Panel:new({
			name = self.name
		})
	end,
	setup = function (self)
		self:createPanel()
		self.frame = self.panel.frame
		self:setupEventHandler()
	end,
	enable = function (self)
		if (not self.frame) then
			self:setup()
		end
		if (self._eventHandlerInitialized) then
			self:reRegisterEvents()
		else
			self:registerEvents()
		end
		self.settings.enabled = true
		if (self.panel) then
			self.panel:show()
		elseif (self.frame) then
			self.frame:Show()
		end
	end,
	addOptions = function (self)
	end,
	disable = function (self)
		self.settings.enabled = false
		self:unregisterEvents()
		if (self.panel) then
			self.panel:hide()
		elseif (self.frame) then
			self.frame:Hide()
		end
	end,
	resetSettings = function (self)
		self.settings = {}
		setmetatable(self.settings, {__index = self.config})
		if (self.applyOptions) then
			self:applyOptions()
		end
	end,
	init = function (self)
		self:preInit()
		
		if (self.settings.enabled) then
			self:enable()
		end
		self:postInit()
	end,
	VARIABLES_LOADED = function (self)
		setmetatable(self.settings, {__index = self.config})
	end,
	register = function (self, O3)
	end,	
	preInit = function (self)
	end,
	postInit = function (self)
	end,
})

O3.Module = Module

local EmptyModule = Module:extend({
	empty = function (self, ...)
	end,
})

setmetatable(EmptyModule, {
	__index = function (self, key)
		return self.empty
	end
})

O3.module = function (self, template)
	if not template.name then
		template.name = 'O3Module'..self.counter
		self.counter = self.counter+1
	end
	template.O3 = self
	template.options = {}
	O3.EventHandler:mixin(template)
	local mod = Module:instance(template)
	self:register(mod)
	return mod
end
