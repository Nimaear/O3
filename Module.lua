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
		self:initEventHandler()

	end,
	enable = function (self)
		if (not self.frame) then
			self:setup()
		end
		self.settings.enabled = true
		self:show()
	end,
	addOptions = function (self)
	end,
	disable = function (self)
		self.settings.enabled = false
		self:unregisterEvents()
		self:hide()
	end,
	show = function (self)
		if (self.frame) then
			self.frame:Show()
		end
	end,
	hide = function (self)
		if (self.frame) then
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
		setmetatable(self.settings, {__index = self.config})
		if (self.settings.enabled) then
			self:enable()
			self:addOptions()
		end
		self:postInit()
	end,
	VARIABLES_LOADED = function (self)
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
