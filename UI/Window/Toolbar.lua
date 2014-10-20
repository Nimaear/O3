local addon, ns = ...
local O3 = O3

O3.UI.Toolbar = O3.UI.Panel:extend({
	height = 28,
	buttons = {},
	style = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			subLayer = -7,
			file = O3.Media:texture('Background'),
			tile = true,
			color = {147/255, 153/255, 159/255, 0.95},
			offset = {1,1,1,1},
		})
		self:createOutline({
			layer = 'BORDER',
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.03 },
			colorEnd = {1, 1, 1, 0.05 },
			offset = {1, 1, 1, 1},
			-- width = 2,
			-- height = 2,
		})
		self:createOutline({
			layer = 'BORDER',
			gradient = 'VERTICAL',
			color = {0, 0, 0, 1 },
			colorEnd = {0, 0, 0, 1 },
			offset = {0, 0, 0, 0 },
		})
	end,
})