local addon, ns = ...
local O3 = ns.O3

local CopyWindow = O3.UI.Window:extend({
	name = 'O3Copy',
	title = 'O3',
	subTitle = 'Copy',
	width = 500,
	height = 300,
	frameStrata = 'HIGH',
	closeWithEscape = true,			
	offset = {nil, nil, nil, 10},
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
					width = 486,
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

local copy = O3:module({
	name = 'Copy',
	readable = 'Copy',
	config = {
		enabled = true,
	},
	settings = {},
	copy = function (self, text)
		if (not self.editBox) then
			self:create()
		end
		self.panel:show()
		self.panel:raise()
		self.editBox:SetText(text)
		self.editBox:HighlightText(0)
		self.editBox:Enable()
		self.panel.frame:Raise()
	end,
	create = function (self)
        self.panel = CopyWindow:instance({
        	--frame = self.frame,
        })
        self.panel:show()
		self.editBox = self.panel.editBox		
	end,
})

copy:setCall(copy.copy)