local addon, ns = ...
local O3 = ns.O3

O3:module({
	config = {
		enabled = true,
		message = "Interrrupted %s.",
		channel = nil,
	},
	settings = {},
	addOptions = function (self)
		self:addOption('_1', {
			type = 'Title',
			label = 'Announce',
		})
		self:addOption('channel', {
			type = 'DropDown',
			label = 'Channel',
			_values = {
				{ label = 'None', value = nil},
				{ label = 'Say', value = 'SAY'},
				{ label = 'Party', value = 'PARTY'},
				{ label = 'Raid', value = 'RAID'},
				{ label = 'Print', value = 'PRINT'},
				}
		})
		self:addOption('message', {
			type = 'String',
			label = 'Interupt message',
		})
	end,
	name = 'Interrupt',
	readable = 'Interrupt announce',
	SAY = function (self, message, spellId)
		SendChatMessage(string.format(message, GetSpellLink(spellId)), 'SAY')
	end,
	PARTY = function (self, message, spellId)
		if IsInGroup then
			SendChatMessage(string.format(message, GetSpellLink(spellId)), 'PARTY')
		end
	end,
	RAID = function (self, message, spellId)
		if IsInRaid() then
			SendChatMessage(string.format(message, GetSpellLink(spellId)), 'RAID')
		end
	end,
	PRINT = function (self, message, spellId)
		print(string.format(self.settings.message, GetSpellLink(spellId)))
	end,
	postInit = function (self)
		O3.CombatLog:addListener('SPELL_INTERRUPT', function (hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSchool) 
			if sourceGUID ~= UnitGUID("player") then 
				return 
			end
			if self[self.settings.channel] then
				self[self.settings.channel](self, self.settings.message, extraSpellId)
			end
		end)
	end,
})


local CopyWindow = O3.UI.Window:extend({
	name = 'O3Copy',
	title = 'O3',
	subTitle = 'Copy',
	width = 500,
	height = 300,
	frameStrata = 'HIGH',
	closeWithEscape = true,			
	offset = {nil, nil, 500, nil},
    parentFrame = UIParent,
    postCreate = function (self)
		self.scrollFrame = self.content:createPanel({
			type = 'ScrollFrame',
			offset = {2, 2, 2, 2},
			parentFrame = self.content.frame,
			createRegions = function (scrollFrame)
				scrollFrame.scrollChild = O3.UI.EditBox:instance({
					parentFrame = scrollFrame.parentFrame,
					justifyH = 'LEFT',
					justifyV = 'TOP',
					--offset = {0, nil, 0, nil},
					width = 400,
					height = 400,
					lines = 2,
					onEscapePressed = function (editBox)
						editBox.frame:Disable()
						self:hide()
					end,
					style = function (editBox)

					end,
					onCursorChanged =  function (editBox, frame, x, y, width, height)
						local frame = editBox.frame
						y = -1*y
						local scrollHeight = scrollFrame.frame:GetHeight()
						local contentHeight =  math.ceil(frame:GetHeight())
						local scrollMax = scrollFrame.frame:GetVerticalScrollRange()
						local scrollPos = scrollFrame.frame:GetVerticalScroll()
						if y < scrollPos then
							scrollFrame.frame:SetVerticalScroll(y)
						elseif contentHeight < scrollHeight then
							scrollFrame.frame:SetVerticalScroll(0)
						else
							if y > contentHeight - (height*2) then
								scrollFrame.frame:SetVerticalScroll(scrollMax)
							elseif y > scrollHeight then
								scrollFrame.frame:SetVerticalScroll(y-scrollHeight+height*2)
							end
						end
					end,
				})
			end,
			hook = function (scrollFrame)
				scrollFrame.frame:SetScript('OnMouseDown', function ()
					scrollFrame.scrollChild.frame:Enable()
				end)	
			end,
			postInit = function (scrollFrame)
				scrollFrame.frame:SetScrollChild(scrollFrame.scrollChild.frame)
				-- scrollFrame.frame:SetVerticalScroll(0)
				-- scrollFrame.frame:SetHorizontalScroll(0)
				-- scrollFrame.frame:UpdateScrollChildRect()
			end,
		})
		self.editBox = self.scrollFrame.scrollChild.frame
		
	end
})

O3:module({
	name = 'Copy',
	readable = 'Copy',
	config = {
		enabled = true,
		message = "Interrrupted %s.",
		channel = nil,
	},
	settings = {},
	copy = function (self, text)
		if (not self.editBox) then
			self:create()
		end
		self.panel:show()
		self.editBox:SetText(text)
		self.editBox:HighlightText(0)
		self.editBox:Enable()
	end,
	create = function (self)
        self.panel = CopyWindow:instance({
        	--frame = self.frame,
        })
        self.panel:show()
		self.editBox = self.panel.editBox		
	end,
})