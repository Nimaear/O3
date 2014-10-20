local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.ItemListWindow = UI.PagerWindow:extend({
	scrollTo = function (self, offset)
		offset = self._offset or 0
		local oldNumItems = self.numItems
		self:getNumItems()
		if not self:process() then
			return
		end
		
		for i = 1, self.itemCount do
			local item = self.items[i]
			local realOffset = offset+i
			if  realOffset <= self.numItems then
				if (item.update) then
					item:update(realOffset)
				else
					self:updateItem(item, realOffset)
				end

				item:show()
			else
				item:hide()
			end
		end
		self:updateBar()
	end,
	updateBar = function (self)
		if (self.numItems > self.itemCount) then
			self.bar:show()
			self.content:point('RIGHT', -12, -2)
		else
			self.bar:hide()
			self.content:point('RIGHT',  0, -2)
		end
	end,
	process = function (self)
		return true
		--return self.numItems > 0
	end,
	reset = function (self)
		self:scrollTo(0)
	end,	
	postCreate = function (self)
		self:createItems()
		self.bar = UI.ScrollBar:instance({
			width = 11,
			parentFrame = self.content.frame,
			offset = {nil, -11, 0, 0},
		})

		self._offset = 0

		self:reset()
	end,
	hook = function (self)
		self.content.frame:SetScript('OnMouseWheel', function (contentFrame, delta)
			local maxHeight = self.bar.frame:GetHeight()-24

			local maxOffset = self.numItems - self.itemCount
			local oldOffset = self._offset

			self._offset = self._offset - (delta * 5)
			if (self._offset > maxOffset) then
				self._offset = maxOffset
			end
			if (self._offset < 0) then
				self._offset = 0
			end

			if (oldOffset ~= self._offset) then
				self:scrollTo()
			end
			self.bar.thumb.frame:SetPoint('TOP' , 0, -1* math.floor((self._offset/maxOffset)*maxHeight)-1)
			--self.bar.thumb.frame:SetPoint('TOP' , 0, -1* math.floor((self._offset/self.numItems)*maxHeight)+1)
		end)
	end,
})
