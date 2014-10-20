local addon, ns = ...
local O3 = ns.O3


O3:module({
	name = 'ChatBubbles',
	readable = 'Chat bubbles',
	config = {
		enabled = true,
		font = O3.Media:font('Normal'),
		fontSize = 12, 
		fontFlags = '',
	},
	settings = {},
    fontSet = function (self)
        for i = 1, #self.frames do 
            self.frames[i].text:SetFont(self.settings.font, self.settings.fontSize)
        end
    end,
    frames = {},	
	addOptions = function (self)
		self:addOption('_1', {
			type = 'Title',
			label = 'Font',
		})
        self:addOption('font', {
            type = 'FontDropDown',
            label = 'Font',
            setter = 'fontSet'
        })
        self:addOption('fonta', {
            type = 'Toggle',
            label = 'Font',
            setter = 'fontSet'
        })
        self:addOption('fontSize', {
            type = 'Range',
            label = 'Font size',
            min = 6,
            max = 20,
            step = 1,
			setter = 'fontSet'
        })
	end,
    isBubble = function (self, frame)
        if frame:GetName() or not frame:GetRegions() then 
            return false
        end
        local region = frame:GetRegions()
        return region:GetTexture() == [[Interface\Tooltips\ChatBubble-Background]]
    end,	
    skin = function (self, frame)
        frame:SetScale(1)
        -- frame.shadow:SetBackdropColor(0, 0, 0, 0.7)
        -- frame:SetFrameStrata('BACKGROUND')
        for i=1, frame:GetNumRegions() do
            local region = select(i, frame:GetRegions())
            if region:GetObjectType() == "Texture" then
                region:SetTexture(nil)
            elseif region:GetObjectType() == "FontString" then
                frame.text = region
                --frame.text:SetTextColor(1,1,1)
                -- frame:ClearAllPoints()
                -- frame:SetPoint('TOPLEFT', frame.text, 'TOPLEFT',-2,2)
                -- frame:SetPoint('BOTTOMRIGHT', frame.text, 'BOTTOMRIGHT',2,-2)
                frame.text:SetFont(self.settings.font, self.settings.fontSize)
            end
        end

        local chatBubble = O3.UI.Panel:instance({
            frame = frame,
            style = function (self)
                self:createTexture({
                    layer = 'BACKGROUND',
                    subLayer = 0,
                    color = {0, 0, 0, 0.8},
                    offset = {10, 10, 10, 10},
                    -- height = 1,
                })
                self:createOutline({
                    layer = 'ARTWORK',
                    subLayer = 3,
                    gradient = 'VERTICAL',
                    color = {1, 1, 1, 0.01 },
                    colorEnd = {1, 1, 1, 0.15 },
                    offset = {10, 10, 10, 10},
                })
            end,
        })
        frame.bubbled = true
        table.insert(self.frames, frame)
    end,
    search = function (self, startIndex, ...)
        for index = startIndex, select('#', ...) do
            local frame = select(index, ...)

            if self:isBubble(frame) and not frame.bubbled then 
                self:skin(frame) 
            end
        end
    end,
    setup = function (self)
        local frame = CreateFrame('Frame', self.name, UIParent)
        local count = 0

        local searcher = frame:CreateAnimationGroup()
        searcher.looper = searcher:CreateAnimation()
        searcher.looper:SetDuration(0.33)
        searcher:SetLooping('REPEAT')
        searcher:SetScript("OnLoop", function (searcher) 
            local childrenCount = WorldFrame:GetNumChildren()
            if (count ~= childrenCount) then
                self:search(count+1, WorldFrame:GetChildren())
                count = childrenCount
            end
        end)
        searcher:Play()

        self.frame = frame
    end, 	
})

