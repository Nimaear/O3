local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.Option.Title = UI.Option:extend({
	height = 30,
	createRegions = function (self)
		local parent = self
		self.label = self:createFontString({
			fontSize = 14,
			offset = {0, 0, 0, 0},
			width = self.labelWidth,
			text = self.label, 
			justifyH = 'LEFT',
		})
		-- self:createTexture({
		-- 	drawLayer = 'BACKGROUND',
		-- 	offset = {0, 0, nil, 5},
		-- 	color = {1, 1, 1, 0.25},
		-- 	height = 1,
		-- })

	end,
})
