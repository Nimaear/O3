local addon, ns = ...
local O3 = ns.O3

O3:module({
	name = 'ExperienceBar',
	addOptions = function (self)
		self:addOption('_1', {
			type = 'Title',
			label = 'Announce',
		})
	end,	
	config = {
		enabled = true,
		font = O3.Media:font('Normal'),
		fontSize = 10,
		fontFlags = '',
		statusBar = O3.Media:statusBar('Default'),
		factionInfo = {
			[1] = {{ 170/255, 70/255,  70/255 }, "Hated", "FFaa4646"},
			[2] = {{ 170/255, 70/255,  70/255 }, "Hostile", "FFaa4646"},
			[3] = {{ 170/255, 70/255,  70/255 }, "Unfriendly", "FFaa4646"},
			[4] = {{ 200/255, 180/255, 100/255 }, "Neutral", "FFc8b464"},
			[5] = {{ 75/255,  175/255, 75/255 }, "Friendly", "FF4baf4b"},
			[6] = {{ 75/255,  175/255, 75/255 }, "Honored", "FF4baf4b"},
			[7] = {{ 75/255,  175/255, 75/255 }, "Revered", "FF4baf4b"},
			[8] = {{ 155/255,  255/255, 155/255 }, "Exalted","FF9bff9b"},
		},
	},
	events = {
		PLAYER_ENTERING_WORLD = true,
		PLAYER_LEVEL_UP = true,
		PLAYER_XP_UPDATE = true,
		UPDATE_EXHAUSTION = true,
		CHAT_MSG_COMBAT_FACTION_CHANGE = true,
		UPDATE_FACTION = true,
	},
	shortValue = function(self, value)
		if value >= 1e6 then
			return ("%.0fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
		elseif value >= 1e3 or value <= -1e3 then
			return ("%.0fk"):format(value / 1e3):gsub("%.?+([km])$", "%1")
		else
			return value
		end
	end,
	commaValue = function (self, amount)
		local formatted = amount
		while true do  
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if (k==0) then
				break
			end
		end
		return formatted
	end,
	createChatMessage = function(self, XP, maxXP)
		return "I'm currently at "..self:commaValue(XP).."/"..self:commaValue(maxXP).." ("..floor((XP/maxXP)*100).."%) experience."
	end,
	showBar = function (self)
		if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
			local XP, maxXP = UnitXP("player"), UnitXPMax("player")
			local restXP = GetXPExhaustion()
			if (maxXP < 1) then
				maxXP = 10000
			end
			local percXP = floor(XP/maxXP*100)
			local str
			--Setup Text
			if self.xpText then
				if restXP then
					str = format("%s/%s (%s%%|cffb3e1ff+%d%%|r)", self:shortValue(XP), self:shortValue(maxXP), percXP, restXP/maxXP*100)
				else
					str = format("%s/%s (%s%%)", self:shortValue(XP), self:shortValue(maxXP), percXP)
				end
				self.xpText:SetText(str)
			end
			--Setup Bar
			if GetXPExhaustion() then 
				if not self.restedxpBar:IsShown() then
					self.restedxpBar:Show()
				end
				self.restedxpBar:SetStatusBarColor(0, .4, .8)
				self.restedxpBar:SetMinMaxValues(min(0, XP), maxXP)
				self.restedxpBar:SetValue(XP+restXP)
			else
				if self.restedxpBar:IsShown() then
					self.restedxpBar:Hide()
				end
			end
			
			self.xpBar:SetStatusBarColor(.5, 0, .75)
			self.xpBar:SetMinMaxValues(min(0, XP), maxXP)
			self.xpBar:SetValue(XP)	

			if GetWatchedFactionInfo() then
				local name, rank, min, max, value = GetWatchedFactionInfo()
				if not self.repBar:IsShown() then self.repBar:Show() end
				self.repBar:SetStatusBarColor(unpack(self.config.factionInfo[rank][1]))
				self.repBar:SetMinMaxValues(min, max)
				self.repBar:SetValue(value)
			else
				if self.repBar:IsShown() then self.repBar:Hide() end
			end
			
			--Setup Exp Tooltip
			self.mouseFrame:SetScript("OnEnter", function(frame)
				GameTooltip:SetOwner(frame, "ANCHOR_BOTTOM")
				GameTooltip:ClearLines()
				GameTooltip:AddLine("Experience:")
				GameTooltip:AddLine(string.format('XP: %s/%s (%d%%)', self:commaValue(XP), self:commaValue(maxXP), (XP/maxXP)*100))
				GameTooltip:AddLine(string.format('Remaining: %s', self:commaValue(maxXP-XP)))	
				if restXP then
					GameTooltip:AddLine(string.format('|cffb3e1ffRested: %s (%d%%)', self:commaValue(restXP), restXP/maxXP*100))
				end
				if GetWatchedFactionInfo() then
					local name, rank, min, max, value = GetWatchedFactionInfo()
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(string.format('Reputation: %s', name))
					GameTooltip:AddLine(string.format('Standing: |c'..self.config.factionInfo[rank][3]..'%s|r', self.config.factionInfo[rank][2]))
					GameTooltip:AddLine(string.format('Rep: %s/%s (%d%%)', self:commaValue(value-min), self:commaValue(max-min), (value-min)/(max-min)*100))
					GameTooltip:AddLine(string.format('Remaining: %s', self:commaValue(max-value)))
				end
				GameTooltip:Show()
			end)
			self.mouseFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
			
			--Send experience info in chat
			self.mouseFrame:SetScript("OnMouseDown", function()
				if IsShiftKeyDown() then
					if IsInRaid() then
						SendChatMessage(self:createChatMessage(XP, maxXP),"RAID")
					elseif GetNumGroupMembers() > 0 then
						SendChatMessage(self:createChatMessage(XP, maxXP),"PARTY")
					end
				end
				if IsControlKeyDown() then
					local activeChat = ChatFrame1EditBox:GetAttribute("chatType")
					if activeChat == "WHISPER" then 
						local target = GetChannelName(ChatFrame1EditBox:GetAttribute("channelTarget"))
					end
					SendChatMessage(self:createChatMessage(XP, maxXP),activeChat, nil, target or nil)
				end
			end)
		else
			if GetWatchedFactionInfo() then
				local name, rank, min, max, value = GetWatchedFactionInfo()
				self.xpText:SetText(format("%d / %d (%d%%)", value-min, max-min, (value-min)/(max-min)*100))

				--Setup Bar
				self.xpBar:SetStatusBarColor(unpack(self.config.factionInfo[rank][1]))
				self.xpBar:SetMinMaxValues(min, max)
				self.xpBar:SetValue(value)
				--Setup Exp Tooltip
				self.mouseFrame:SetScript("OnEnter", function()
					GameTooltip:SetOwner(self.mouseFrame, "ANCHOR_BOTTOM")
					GameTooltip:ClearLines()
					GameTooltip:AddLine(string.format('Reputation: %s', name))
					GameTooltip:AddLine(string.format('Standing: |c'..self.config.factionInfo[rank][3]..'%s|r', self.config.factionInfo[rank][2]))
					GameTooltip:AddLine(string.format('Rep: %s/%s (%d%%)', self:commaValue(value-min), self:commaValue(max-min), (value-min)/(max-min)*100))
					GameTooltip:AddLine(string.format('Remaining: %s', self:commaValue(max-value)))
					GameTooltip:Show()
				end)
				self.mouseFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
				
				--Send reputation info in chat
				self.mouseFrame:SetScript("OnMouseDown", function()
					if IsShiftKeyDown() then
						if GetNumRaidMembers() > 0 then
							SendChatMessage("I'm currently "..self.config.factionInfo[rank][2].." with "..name.." "..(value-min).."/"..(max-min).."("..floor((((value-min)/(max-min))*100))..").","RAID")
						elseif GetNumPartyMembers() > 0 then
							SendChatMessage("I'm currently "..self.config.factionInfo[rank][2].." with "..name.." "..(value-min).."/"..(max-min).."("..floor((((value-min)/(max-min))*100))..").","PARTY")
						end
					end
				end)

				if not self.frame:IsShown() then self.frame:Show() end
			else
				self.frame:Hide()
			end
		end

	end,
	PLAYER_LEVEL_UP = function (self)
		self:showBar()
	end,
	PLAYER_XP_UPDATE = function (self)
		self:showBar()
	end,
	UPDATE_EXHAUSTION = function (self)
		self:showBar()
	end,
	CHAT_MSG_COMBAT_FACTION_CHANGE = function (self)
		self:showBar()
	end,
	UPDATE_FACTION = function (self)
		self:showBar()
	end,
	setup = function (self)

		self.panel = self.O3.UI.Panel:instance({
			name = self.name,
			offset = {nil, nil, 21, nil},
			width = 320,
			height = 20,
			createRegions = function (panel)
				self.text = panel:createFontString({
					offset = {0,0,-2,0},
				})
			end,
			style = function (panel)
				panel:createTexture({
					layer = 'BACKGROUND',
					file = O3.Media:texture('Background'),
					tile = true,
					color = {0.5, 0.5, 0.5, 0.9},
					offset = {1,1,1,1},
				})
				panel:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.03 },
					colorEnd = {1, 1, 1, 0.05 },
					offset = {1, 1, 1, 1},
					-- width = 2,
					-- height = 2,
				})
				panel:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {0, 0, 0, 1 },
					colorEnd = {0, 0, 0, 1 },
					offset = {0, 0, 0, 0 },
				})			
			end,
		})

        self.frame = self.panel.frame
		--O3.UI:shadow(self.frame)

	--Create XP Status Bar
		local xpBar = CreateFrame("StatusBar", nil, self.frame, "TextStatusBar")
		xpBar:SetPoint("BOTTOMLEFT", self.frame,"BOTTOMLEFT", 1, 1)
		xpBar:SetPoint("TOPRIGHT", self.frame,"TOPRIGHT", -1, -1)
		xpBar:SetStatusBarTexture(self.config.statusBar)
		xpBar:SetFrameLevel(2)
		self.xpBar = xpBar
		
		--Create Rested XP Status Bar
		local restedxpBar = CreateFrame("StatusBar", nil, self.frame, "TextStatusBar")
		restedxpBar:SetPoint("TOPLEFT", self.frame,"TOPLEFT", 1, -1)
		restedxpBar:SetPoint("BOTTOMRIGHT", self.frame,"BOTTOMRIGHT", -1, 1)
		restedxpBar:SetStatusBarTexture(self.config.statusBar)
		restedxpBar:SetFrameLevel(1)
		restedxpBar:Hide()
		self.restedxpBar = restedxpBar
		
		--Create Reputation Status Bar(Only used if not max level)
		local repBar = CreateFrame("StatusBar", nil, self.frame, "TextStatusBar")
		repBar:SetPoint("TOPLEFT", self.frame,"TOPLEFT", 2, -2)
		repBar:SetPoint("BOTTOMRIGHT", self.frame,"BOTTOMRIGHT", -2, 2)
		repBar:SetStatusBarTexture(self.config.statusBar)
		repBar:SetFrameLevel(1)
		repBar:Hide()
		self.repBar = repBar
		
		--Create frame used for mouseover and dragging
		local mouseFrame = CreateFrame("Frame", nil, self.frame)
		mouseFrame:SetAllPoints(self.frame)
		mouseFrame:SetFrameLevel(3)
		mouseFrame:EnableMouse(true)
		self.mouseFrame = mouseFrame

		--Create XP Text
		local xpText = mouseFrame:CreateFontString()
		xpText:SetFont(self.config.font, self.config.fontSize, self.config.fontFlags)
		xpText:SetPoint("CENTER", self.frame, "CENTER", 0, 0)
		self.xpText = xpText
		self:initEventHandler()

		
	end,
	PLAYER_ENTERING_WORLD = function (self)
		self:showBar()
		self:unregisterEvent('PLAYER_ENTERING_WORLD')
	end,
})

