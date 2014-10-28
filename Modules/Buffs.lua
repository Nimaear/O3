local addon, ns = ...
local O3 = ns.O3

O3:module({
	config = {
		enabled = true,
        font = O3.Media:font('Normal'),
        fontStyle = 'THINOUTLINE',
        buffsAnchor = {'TOPRIGHT', UIParent, 'TOPRIGHT', -235, -4},
        tempAnchor = {'TOPRIGHT', UIParent, 'TOPRIGHT', -8, -412},
        durationAnchor = {"BOTTOM", 0, 2},
        countAnchor = {"TOPLEFT", 2, -2},
        buffWidth = 32,
        buffHeight = 32,
        durationSize = 10,
        countSize = 10,
        colSpacing = 1,
        rowSpacing = 12,
        buffsPerRow = 14,
        debuffGap = 64,
	},
	settings = {},
	addOptions = function (self)
        self:addOption('_1', {
            type = 'Title',
            label = 'Font',
        })
        self:addOption('font', {
            type = 'FontDropDown',
            label = 'Font',
            setter = 'fontSet',
        })
        self:addOption('durationSize', {
            type = 'Range',
            min = 6,
            max = 20,
            step = 1,
            label = 'Duration size',
            setter = 'fontSet',
        })
        self:addOption('countSize', {
            type = 'Range',
            min = 6,
            max = 20,
            step = 1,
            label = 'Count size',
            setter = 'fontSet',
        })
        self:addOption('fontStyle', {
            type = 'DropDown',
            label = 'Outline',
            _values = O3.Media.fontStyles,
            setter = 'fontSet',
        })   
	end,
	skinned = {},
	name = 'Buffs',
	readable = 'Buffs',
	--move tempenchant frame
	moveTempEnchantFrame = function(self)
		TemporaryEnchantFrame:SetParent(self.tempBuffAnchor)
		TemporaryEnchantFrame:ClearAllPoints()
		TemporaryEnchantFrame:SetPoint("TOPRIGHT",0,0)
		TemporaryEnchantFrame:SetScale(1)
	end,
	moveBuffFrame = function(self)
		BuffFrame:SetParent(self.buffAnchor)
		BuffFrame:ClearAllPoints()
		BuffFrame:SetPoint("TOPRIGHT",0,0)
		BuffFrame:SetScale(1)
	end,
	updateTempEnchantAnchors = function(self)
		local previousBuff
		for i=1, NUM_TEMP_ENCHANT_FRAMES do
			local b = _G["TempEnchant"..i]
			if b then
				if (i == 1) then
					b:SetPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPRIGHT", 0, 0)
				else
					b:SetPoint("RIGHT", previousBuff, "LEFT", -self.settings.colSpacing, 0)
				end
				previousBuff = b
			end
		end
	end,
	fontSet = function (self)
		for i = 1, #self.skinned do 
			local button = self.skinned[i]
			button.duration:SetFont(self.settings.font, self.settings.durationSize, self.settings.fontStyle)
			button.count:SetFont(self.settings.font, self.settings.countSize, self.settings.fontStyle)
		end
	end,
	skin = function(self, b, type)

		if not b or (b and b.styled) then return end
		table.insert(self.skinned, b)
		b:SetSize(self.settings.buffWidth, self.settings.buffHeight)
		local name = b:GetName()
		--print("applying skin for "..name)
		local border = _G[name.."Border"]
		local icon = _G[name.."Icon"]

		O3.UI.Panel:instance({
			frame = b,
			style = function (buff)
				buff:createTexture({
					layer = 'BACKGROUND',
					offset = {0, 0, 0, 0},
					subLayer = -7,
					color = {0.1, 0.1, 0.1, 0.9},
					height = 1,
				})
				buff.outline = buff:createOutline({
					layer = 'ARTWORK',
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.2 },
					colorEnd = {1, 1, 1, 0.3 },
					offset = {1, 1, 1, 1},
				})
			end,
		})
		-- local shadow = O3.UI:shadow(b)
		-- if (border) then
		-- 	O3:destroy(border)
		-- end

		-- if type == "debuff" then
		-- 	shadow:SetBackdropColor(1, 0, 0, 1)
		-- end

		icon:SetTexCoord(.08, .92, .08, .92)
		icon:ClearAllPoints()
		icon:SetPoint("BOTTOMLEFT", 1, 1)
		icon:SetPoint("TOPRIGHT", -1, -1)
		icon:SetDrawLayer("BACKGROUND",-6)

		b.duration:SetFont(self.settings.font, self.settings.durationSize, self.settings.fontStyle)
		b.duration:ClearAllPoints()
		b.duration:SetPoint(unpack(self.settings.durationAnchor))

		b.count:SetFont(self.settings.font, self.settings.countSize, self.settings.fontStyle)
		b.count:ClearAllPoints()
		b.count:SetPoint(unpack(self.settings.countAnchor))

		b.styled = true
	end,
	postInit = function (self)
		SetCVar("consolidateBuffs", 0)
		self.buffAnchor = CreateFrame("Frame", "O3BuffFrame", UIParent)
		self.tempBuffAnchor = CreateFrame("Frame", "O3TempBuffFrame", UIParent)
		self.buffAnchor:SetSize(100,100)
		self.tempBuffAnchor:SetSize(100,100)

		self.buffAnchor:SetPoint(unpack(self.settings.buffsAnchor))
		self.tempBuffAnchor:SetPoint(unpack(self.settings.tempAnchor))

		hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", function ()
			--print(BUFF_ACTUAL_DISPLAY)
			local numBuffs = 0
			local buff, previousBuff, aboveBuff
			for i = 1, BUFF_ACTUAL_DISPLAY do
				buff = _G["BuffButton"..i]
				if not buff.styled then self:skin(buff,"buff") end
				buff:SetParent(BuffFrame)
				buff.consolidated = nil
				buff.parent = BuffFrame
				buff:ClearAllPoints()
				numBuffs = numBuffs + 1
				index = numBuffs
				if ((index > 1) and (mod(index, self.settings.buffsPerRow) == 1)) then
					buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -self.settings.rowSpacing)
					aboveBuff = buff
				elseif (index == 1) then
					buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
					aboveBuff = buff
				else
					buff:SetPoint("RIGHT", previousBuff, "LEFT", -self.settings.colSpacing, 0)
				end
				previousBuff = buff
			end			
		end)
		hooksecurefunc("DebuffButton_UpdateAnchors", function(buttonName, index)
			local numBuffs = BUFF_ACTUAL_DISPLAY
			local rows = ceil(numBuffs/self.settings.buffsPerRow)
			local gap = self.settings.debuffGap
			if rows == 0 then gap = 0 end
			local buff = _G[buttonName..index]
			if not buff.styled then self:skin(buff,"debuff") end
			-- Position debuffs
			if ((index > 1) and (mod(index, self.settings.buffsPerRow) == 1)) then
				buff:SetPoint("TOP", _G[buttonName..(index-self.settings.buffsPerRow)], "BOTTOM", 0, -self.settings.rowSpacing)
			elseif (index == 1) then
				buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, -(rows*(self.settings.rowSpacing+buff:GetHeight())+gap))
			else
				buff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", -self.settings.colSpacing, 0)
			end
		end)

		--position buff frame
		self:moveBuffFrame()
		--position temp enchant icons
		self:moveTempEnchantFrame()
		--skin temp enchant
		for i=1, NUM_TEMP_ENCHANT_FRAMES do
			local b = _G["TempEnchant"..i]
			if b and not b.styled then
				self:skin(b, "wpn")
			end
		end
		--move temp enchant icons in position
		self:updateTempEnchantAnchors()
		--hook the consolidatedbuffs
		if ConsolidatedBuffs then
			ConsolidatedBuffs:UnregisterAllEvents()
			ConsolidatedBuffs:HookScript("OnShow", function(s)
				s:Hide()
				moveTempEnchantFrame()
			end)
			ConsolidatedBuffs:HookScript("OnHide", function(s)
				moveTempEnchantFrame()
			end)
			ConsolidatedBuffs:Hide()
		end

	end,
})