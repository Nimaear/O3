local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.Option.DropDown = UI.Option:extend({
	callback = function (self, value, label)
		self:change(value)
	end,
	reset = function (self)
		if (self.subModule) then
			self.value = handler.settings[self.subModule][self.token]
		else
			self.value = handler.settings[self.token]
		end
		self:update()
	end,
	update = function (self)
		self.control:selectValue(self.value)
	end,
	createControl = function (self)
		self.control = O3.UI.DropDown:instance({
			parentFrame = self.frame,
			offset = {nil, 0, 0, 0},
			value = self.value,
			_values = self._values,
			callback = function (dropdown, value, label)
				self:callback(value, label)
			end,
		})
		self.control:point('LEFT', self.label, 'RIGHT', 5, 0)
	end,
})

UI.Option.FontDropDown = UI.Option.DropDown:extend({
	_values = O3.Media.fontRegistry,
	createControl = function (self)
		self.control = O3.UI.FontDropDown:instance({
			parentFrame = self.frame,
			offset = {nil, 0, 0, 0},
			value = self.value,
			_values = self._values,
			callback = function (dropdown, value, label)
				self:callback(value, label)
			end,
		})
		self.control:point('LEFT', self.label, 'RIGHT', 5, 0)
	end,
})

UI.Option.StatusBarDropDown = UI.Option.DropDown:extend({
	_values = O3.Media.statusBarRegistry,
	createControl = function (self)
		self.control = O3.UI.StatusBarDropDown:instance({
			parentFrame = self.frame,
			offset = {nil, 0, 0, 0},
			color = self.color or {0.1,0.9,0.1,1},
			value = self.value,
			_values = self._values,
			callback = function (dropdown, value, label)
				self:callback(value, label)
			end,
		})
		self.control:point('LEFT', self.label, 'RIGHT', 5, 0)
	end,
})

