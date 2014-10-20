local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.ScrollWindow = UI.Window:extend({
	createContent = function (self)
		local headerHeight = self.settings.headerHeight
		local footerHeight = self.settings.footerHeight
		local scrollPanel = UI.ScrollPanel:instance({
			parentFrame = self.frame,
			offset = {0, 0, headerHeight-1, footerHeight-1},
			style = function (self)
				self.scrollFrame:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.03 },
					colorEnd = {1, 1, 1, 0.05 },
					offset = {0, 0, 0, 0 },
				})
				self.scrollFrame:createTexture({
					layer = 'BACKGROUND',
					file = O3.Media:texture('Background'),
					tile = true,
					color = {0.5, 0.5, 0.5, 0.5},
					offset = {0, 0, 0, 0},
				})
				self:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {0, 0, 0, 1 },
					colorEnd = {0, 0, 0, 1 },
					offset = {-1, -1, -1, -1 },
				})

			end,
		})
		self.content = scrollPanel.scrollFrame.content
		self.contentFrame = self.content.frame
		self.scrollPanel = scrollPanel
	end,
})
