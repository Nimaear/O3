local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.StatusBar = UI.Panel:extend({
	type = 'StatusBar',
	min = 0,
	max = 1,
	color = {1,1,1,1},
	bg = false,
	textureLayer = 'BACKGROUND',
	textureSubLayer = -7,
	texture = O3.Media:statusBar('Default'),
	style = function (self)
		self:createOutline({
			layer = 'BORDER',
			subLayer = 3,
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.05 },
			colorEnd = {1, 1, 1, 0.07 },
			offset = {1, 1, 1, 1 },
		})
		self:createOutline({
			layer = 'BORDER',
			color = {0, 0, 0, 1 },
			offset = {0, 0, 0, 0 },
		})
		if (self.bg) then
			self.self:createTexture({
				layer = 'BACKGROUND',
				subLayer = -7,
				color = {0.1, 0.1, 0.1, 0.7},
			})
		end
	end,
	postInit = function (self)
		self.frame:SetStatusBarTexture(self.texture, self.textureLayer, self.textureSubLayer)
		self.frame:SetStatusBarColor(unpack(self.color))
		self.frame:SetMinMaxValues(self.min, self.max)
		self.frame:SetValue(self.min)
	end,
})
