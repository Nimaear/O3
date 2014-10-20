local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.Option.Button = UI.Option:extend({
	createRegions = function (self)
		self.control = UI.Button:instance({
			offset = {0, 0, 0, 0},
			text = self.label,
			parentFrame = self.frame,
			onClick = function (button)
				self:onClick()
			end,
		})
	end,
	onClick = function (self)
	end,
})