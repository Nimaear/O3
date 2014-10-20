local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.PagerWindow = UI.Window:extend({
	itemCount = 15,
	preInit = function (self)
		self._defaults.spacing = 1
		self._defaults.resizable = false
		self._defaults.maximizable = false
		self._defaults.itemsTopGap = 24
		self._defaults.itemsBottomGap = 24
		self._defaults.itemHeight = 24
		self.items = {}
	end,
	postInit = function (self)
		self.height = (self.settings.itemHeight+self.settings.spacing)*self.itemCount+self.settings.spacing+self.settings.spacing+self.settings.itemsTopGap+self.settings.itemsBottomGap+self.settings.headerHeight+self.settings.footerHeight
	end,
	createContent = function (self)
		local headerHeight = self.settings.headerHeight+self.settings.itemsTopGap
		local footerHeight = self.settings.footerHeight+self.settings.itemsBottomGap
		self.content = self:createPanel({
			offset = {0, 0, headerHeight, footerHeight-1},
			style = function (self)
				self:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {0, 0, 0, 1 },
					colorEnd = {0, 0, 0, 1 },
					offset = {0, 0, 0, 0 },
				})

			end,
		})
		self.contentFrame = self.content.frame
	end,	
	createFooterControls = function (self)
		local footerControl = CreateFrame('Frame', nil, self.footer.frame)
		footerControl:SetPoint('TOP', 0, -4)
		footerControl:SetPoint('BOTTOM', 0, 4)
		footerControl:SetWidth(250)
		self.footerControl = footerControl
		local firstPage = self:createFooterControl('', function ()
			self:pageTo(1)
		end)
		local prevPage = self:createFooterControl('', function () 
			if self.page > 1 then
				self:pageTo(self.page-1)
			end
		end)
		local pageLabel = footerControl:CreateFontString()
		pageLabel:SetFont(O3.Media:font('Normal'), 12, 'OUTLINE')
		pageLabel:SetHeight(18)
		pageLabel:SetTextColor(1,1,1)
		pageLabel:SetText('1/1')
		local nextPage = self:createFooterControl('', function () 
			if self.page < self.maxPage then
				self:pageTo(self.page+1)
			end
		end)
		local lastPage = self:createFooterControl('', function () 
			self:pageTo(self.maxPage)
		end)
		firstPage:point('LEFT')
		prevPage:point('LEFT', firstPage.frame, 'RIGHT', 5, 0)

		lastPage:point('RIGHT')
		nextPage:point('RIGHT', lastPage.frame, 'LEFT', -5, 0)
		pageLabel:SetPoint('LEFT', prevPage.frame, 'RIGHT', 5, 0)
		pageLabel:SetPoint('RIGHT', nextPage.frame, 'LEFT', -5, 0)
		self.pagingControls = {
			prevPage = prevPage,
			nextPage = nextPage,
			pageLabel = pageLabel,
			firstPage = firstPage,
			lastPage = lastPage
		}
	end,
	createFooterControl = function (self, text, onMouseDown)
		return O3.UI.GlyphButton:instance({
			parentFrame = self.footerControl,
			width = 40,
			height = 20,
			text = text,
			onClick = function ()
				onMouseDown()
			end,

		})
	end,
	hook = function (self)
		self.content.frame:SetScript('OnMouseWheel', function (contentFrame, delta)
			local oldPage = self.page
			if (delta == 1) then
				self.page = self.page - 1
			else
				self.page = self.page + 1
			end
			if (self.page < 1 ) then
				self.page = 1
			elseif (self.page > self.maxPage) then
				self.page = self.maxPage
			end
			if (oldPage ~= self.page) then
				self:pageTo(self.page)
			end
		end)	
	end,

	createItem = function (self)
		local itemHeight = self.settings.itemHeight
		local item = self.content:createPanel({
			type = 'Button',
			offset = {2, 2, nil, nil},
			height = itemHeight,
			onIconClick = function (self)
				print('Icon click')
			end,
			createRegions = function (self)
				self.button = O3.UI.IconButton:instance({
					parent = self,
					icon = nil,
					parentFrame = self.frame,
					height = itemHeight,
					width = itemHeight,
					onClick = function (self)
						if (self.parent.onIconClick) then
							self.parent:onIconClick()
						end
					end,
				})
				self.button:point('TOPLEFT')
				self.panel = self:createPanel({
					offset = {itemHeight+2, 0, 0, 0},
					style = function (self)
						self.text = self:createFontString({
							offset = {2, 2, 2, 2},
							justifyV = 'TOP',
							justifyH = 'LEFT',
						})
						self:createOutline({
							layer = 'BORDER',
							gradient = 'VERTICAL',
							color = {1, 1, 1, 0.03 },
							colorEnd = {1, 1, 1, 0.05 },
							offset = {0, 0, 0, 0},
							-- width = 2,
							-- height = 2,
						})	
						self.highlight = self:createTexture({
							layer = 'ARTWORK',
							gradient = 'VERTICAL',
							color = {0,1,1,0.10},
							colorEnd = {0,0.5,0.5,0.20},
							offset = {1,1,1,1},
						})
						self.highlight:Hide()						
					end,
				})
				self.text = self.panel.text
			end,
			hook = function (self)
				self.frame:SetScript('OnEnter', function (frame)
					self.panel.highlight:Show()
					if (self.onEnter) then
						self:onEnter()
					end
				end)
				self.frame:SetScript('OnLeave', function (frame)
					self.panel.highlight:Hide()
					if (self.onLeave) then
						self:onLeave()
					end
				end)
				self.frame:SetScript('OnClick', function (frame)
					if (self.onClick) then
						self:onClick()
					end
				end)
			end,
		})
		return item
	end,
	createItems = function (self)
		for i = 1, self.itemCount do
			local item = self:createItem(i)
			item:hide()
			self.items[i] = item
			if i == 1 then
				item:point('TOP', self.content.frame, 'TOP', 0, -2)
			else
				item:point('TOP', self.items[i-1].frame, 'BOTTOM', 0, -self.settings.spacing)
			end
		end
	end,	
	postCreate = function (self)
		self:createItems()
		self:createFooterControls()
		self:reset()
		-- button1:point('TOPLEFT', openButton.frame, 'TOPRIGHT', 1, 0)
		-- button2:point('TOPLEFT', button1.frame, 'TOPRIGHT', 1, 0)
	end,
	getNumItems = function (self)
		self.numItems = 1
	end,
	changeToPage = function (self, page)
		local page = page or 1
		local startIndex = (page-1)*self.itemCount+1
		local endIndex = min(self.numItems, startIndex+self.itemCount-1)		
		local index = 1
		for i = startIndex, endIndex do
			local item = self.items[index]
			item.id = i
			if (item.update) then
				item:update(i)
			else
				self:updateItem(item, i)
			end
			item:show()
--			item:Show()
			index = index + 1
		end
		if (index <= self.itemCount) then
			for i = index, self.itemCount do
				local item = self.items[i]
--				item:Hide()
				item:hide()
			end
		end
	end,	
	updateItem = function (self, item, i)
	end,
	process = function (self)
		return true
	end,
	reset = function (self)
		self:pageTo(1)
	end,
	pageTo = function (self, page)
		self:getNumItems()
		if not self:process() then
			return
		end
		local pages = math.ceil(self.numItems/self.itemCount)
		self.maxPage = pages	

		self.page = page or 1
		self.pagingControls.pageLabel:SetText(self.page..'/'..pages)
		if self.page > 1 then
			self.pagingControls.prevPage:enable()
			self.pagingControls.firstPage:enable()
		else
			self.pagingControls.prevPage:disable()
			self.pagingControls.firstPage:disable()
		end
		if self.page < self.maxPage then
			self.pagingControls.nextPage:enable()
			self.pagingControls.lastPage:enable()
		else
			self.pagingControls.nextPage:disable()
			self.pagingControls.lastPage:disable()
		end
		self:changeToPage(self.page)
	end,	
})



--UI.IconButton:instance({
--	width = 32,
--	height = 32,
--	icon = icon,
--	parentFrame = UIParent,
--	offset = {500, nil, 300, nil},
--})