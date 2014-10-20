local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.ScrollBar = UI.Panel:extend({
	managed = true,
	width = 20,
	createRegions = function (self)
		self.thumb = self:createPanel({
			offset = {1,1,1,nil},
			height = 22,
			style = function (self)
				self:createTexture({
					layer = 'BACKGROUND',
					file = O3.Media:texture('Background'),
					tile = true,
					color = {147/255, 153/255, 159/255, 0.95},
					offset = {0,0,0,0},
				})
				self:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.03 },
					colorEnd = {1, 1, 1, 0.05 },
					offset = {0, 0, 0, 0 },
				})
				self:createTexture({
					layer = 'ARTWORK',
					gradient = 'VERTICAL',
					color = {1,1,1,0.05},
					colorEnd = {1,1,1,0.10},
					offset = {0,0,0,0},
				})
			end,
		})	
	end,
	style = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			file = O3.Media:texture('Background'),
			tile = true,
			color = {0.1, 0.1, 0.1, 0.95},
			offset = {0,0,0,0},
		})
		self:createOutline({
			layer = 'BORDER',
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.03 },
			colorEnd = {1, 1, 1, 0.05 },
			offset = {0, 0, 0, 0 },
		})
	end,	
})

UI.ScrollPanel = UI.Panel:extend({
	createRegions = function (self)
		local scrollBar = UI.ScrollBar:instance({
			width = 11,
			parentFrame = self.frame,
			offset = {nil, -1, -1, -1},
		})
		self.bar = scrollBar
		self.scrollFrame = self:createPanel({
			type = 'ScrollFrame',
			offset = {0, 10, 0, 0},
			createRegions = function (self)
				local scrollFrame = self.frame
				self.content = self:createPanel({
					parentFrame = UIParent,
					height = 1,
					width = 1,
					offset = {0, 0, nil, nil},
				})
				self.frame:SetScrollChild(self.content.frame)
				self.frame:SetScript('OnMouseWheel', function (scrollFrame, delta)
					self.parent:update()
					local scrollPos = scrollFrame:GetVerticalScroll()
					local scrollMax = scrollFrame:GetVerticalScrollRange()
					local maxHeight = scrollFrame:GetHeight()-20
					if (delta < 0) then
						scrollPos = scrollPos + 25
						if (scrollPos > scrollMax) then
							scrollPos = scrollMax
						end
					elseif (delta > 0) then
						scrollPos = scrollPos-25
						if (scrollPos < 0) then
							scrollPos = 0
						end
					end
					scrollFrame:SetVerticalScroll(scrollPos)
					scrollPos = scrollFrame:GetVerticalScroll()
					scrollBar.thumb.frame:SetPoint('TOP' , 0, -1* (scrollPos/scrollMax)*maxHeight)
				end)
			end,

			style = function (self)
			end
		})
		self.content = self.scrollFrame.content
	end,
	setVerticalScroll = function (self, scroll)
		self.scrollFrame.frame:SetVerticalScroll(scroll)
	end,
	update = function (self)
		local left, bottom, width, height = self.scrollFrame.content.frame:GetBoundsRect()
		if not height or height > self.scrollFrame.frame:GetHeight() then
			self.scrollFrame:point('RIGHT', -10, 0)
			self.bar:show()
		else
			self.scrollFrame:point('RIGHT', 0, 0)
			self.bar:hide()
		end
		self.scrollFrame.frame:UpdateScrollChildRect()
	end,
	hook = function (self)
		self.frame:SetScript('OnSizeChanged', function () 
			self:update()
		end)
		self.frame:SetScript('OnShow', function () 
			self:update()
		end)
	end,
	style = function (self)


	end,
	position = function (self)
		local offset = self.offset
		if (offset) then
			if offset[1] then
				self.frame:SetPoint('LEFT', offset[1]+1, 0)
			else
				self.frame:SetPoint('LEFT', 1, 0)
			end
			if offset[2] then
				self.frame:SetPoint('RIGHT', -offset[2]-1, 0)
			else
				self.frame:SetPoint('RIGHT', 1, 0)
			end
			if offset[3] then
				self.frame:SetPoint('TOP', 0, -offset[3]-1)
			else
				self.frame:SetPoint('TOP', 0, -1)
			end
			if offset[4] then
				self.frame:SetPoint('BOTTOM', 0, offset[4]+1)
			else
				self.frame:SetPoint('BOTTOM', 0, 1)
			end
		end
		if (self.width) then
			self.frame:SetWidth(self.width)
		end
		if (self.height) then
			self.frame:SetHeight(self.height)
		end
	end,

})
