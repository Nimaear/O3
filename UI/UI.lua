local addon, ns = ...
local O3 = ns.O3

local UI = O3.Class:extend({
	anchorPoints = {
		{ label = 'Center', value = 'CENTER'},
		{ label = 'Top Left', value = 'TOPLEFT'},
		{ label = 'Top', value = 'TOP'},
		{ label = 'Top Right', value = 'TOPRIGHT'},
		{ label = 'Right', value = 'RIGHT'},
		{ label = 'Bottom Right', value = 'BOTTOMRIGHT'},
		{ label = 'Bottom', value = 'BOTTOM'},
		{ label = 'Bottom Left', value = 'BOTTOMLEFT'},
		{ label = 'Left', value = 'LEFT'},
	},	
	addContainer = function (self, container, setAsDefault)
		table.insert(self.containers, container)
		if (setAsDefault) then
			self.defaultContainer = container
		end
	end,
	-------------------------------------------------------------------------------------
	-- Place a shadow frame underneath another frame
	--
	-- @param frame The frame to create a shadow for
	-------------------------------------------------------------------------------------
	shadow = function (self, frame)
		if (frame.shadow) then 
			return frame.shadow
		end 
		local frameLevel = frame:GetFrameLevel()
		local shadow = CreateFrame("Frame", nil, frame)
		shadow:SetFrameStrata(frame:GetFrameStrata())
		shadow:SetFrameLevel(frameLevel-1)
		-- frame:SetFrameLevel(frameLevel+1)
		shadow:SetPoint("TOPLEFT", -4, 4)
		shadow:SetPoint("BOTTOMRIGHT", 4, -4)
		shadow:SetBackdrop( { 
			edgeFile    = O3.Media:border('Shadow'),
			edgeSize    = 4,
			
			bgFile      = O3.Media:texture('Solid'),
			insets = {
				left    = 3, 
				right   = 3, 
				top     = 3, 
				bottom  = 3
			},
		})
		shadow:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
		shadow:SetBackdropBorderColor(0, 0, 0, 0.4)
		frame.shadow = shadow
		return shadow    
	end,
	style = function (self, frame)

		frame:SetBackdrop( { 
			edgeFile    = O3.Media:border('Shadow'),
			edgeSize    = 4,
			
			bgFile      = O3.Media:texture('Solid'),
			insets = {
				left    = 4, 
				right   = 4, 
				top     = 4, 
				bottom  = 4
			},
		})
		frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
		frame:SetBackdropBorderColor(0, 0, 0, 0.9)
	end,	
	wod = function (self, frame, borderColor, backgroundColor)
		return Panel:wod(borderColor, backgroundColor, frame)
	end,	

})
O3.UI = UI

ns.UI = UI