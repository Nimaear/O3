local addon, ns = ...
local O3 = ns.O3

O3:module({
    config = {
        fontSize = 12,
        font = O3.Media:font('Normal'),
        fontStyle = '',
    },
    addOptions = function (self)
        self:addOption('_1', {
            type = 'Title',
            label = 'Font',
        })
        self:addOption('fontSize', {
            type = 'Range',
            min = 6,
            max = 20,
            step = 1,
            label = 'Font size',
        })
        self:addOption('font', {
            type = 'FontDropDown',
            label = 'Font',
        })
        self:addOption('fontStyle', {
            type = 'DropDown',
            label = 'Outline',
            _values = O3.Media.fontStyles
        })          
    end,
    name = 'Minimap',
    readable = 'Minimap',
    onEnter = function (button)
        -- button.border:SetVertexColor(0.5, 0.5, 0.5)
    end,
    onLeave = function (button)
        -- button.border:SetVertexColor(0.3, 0.3, 0.3)
    end,
    createButton = function (self, texture, parent, mouseDown)
        local button = CreateFrame('Button', nil, parent)
        button:SetSize(32, 32)

        button:RegisterForClicks('AnyDown')

        -- local background = button:CreateTexture()
        -- background:SetDrawLayer('BACKGROUND', 4)
        -- background:SetTexture(O3.Media:texture('ButtonBackground'))
        -- background:SetPoint('BOTTOMLEFT', 2, 2)
        -- background:SetPoint('TOPRIGHT', -2, -2)
        -- background:SetTexCoord(0, 24/32, 0, 24/32)
        -- background:SetAlpha(0.5)

        if (texture) then
            local icon = button:CreateTexture()
            icon:SetDrawLayer('BACKGROUND', 5)
            icon:SetTexture(texture)
            icon:SetPoint('BOTTOMLEFT', 4, 4)
            icon:SetPoint('TOPRIGHT', -4, -4)
            icon:SetTexCoord(0, 0.92, 0, 0.92)
            button.icon = icon
        end

        -- local border = button:CreateTexture()
        -- border:SetDrawLayer('BACKGROUND', 6)
        -- border:SetAllPoints()
        -- border:SetTexCoord(0, 0.5, 0, 0.5)
        -- border:SetVertexColor(0.3, 0.3, 0.3)
        -- border:SetTexture(O3.Media:texture('ButtonBorder'))

        button:SetScript('OnEnter', self.onEnter)
        button:SetScript('OnLeave', self.onLeave)
        button:SetScript('OnMouseDown', mouseDown or function () end)

        -- button.border = border

        return button
    end,
    postCreate = function (self)

        O3.UI.Panel:instance({
            frame = MinimapCluster,
            style = function (cluster)
                cluster:createTexture({
                    layer = 'BACKGROUND',
                    offset = {0, 0, 0, 0},
                    subLayer = -7,
                    color = {0.1, 0.1, 0.1, 0.9},
                    height = 1,
                })
            end,
        })
        O3.UI.Panel:instance({
            frame = MiniMap,
            style = function (miniMap)
                miniMap.outline = miniMap:createOutline({
                    layer = 'ARTWORK',
                    gradient = 'VERTICAL',
                    color = {1, 1, 1, 0.2 },
                    colorEnd = {1, 1, 1, 0.3 },
                    offset = {1, 1, 1, 1},
                })
            end,
        })
        MinimapCluster:EnableMouse(false)

        -- hide border
        MinimapBorder:Hide()
        MinimapBorderTop:Hide()
        -- hide worldmap button
        MiniMapWorldMapButton:Hide()
        -- hide zoom
        MinimapZoomIn:Hide()
        MinimapZoomOut:Hide()
        -- hide voice frame
        MiniMapVoiceChatFrame:Hide()
        -- hide zone text
        MinimapZoneTextButton:Hide()
        -- hide calendar button
        --GameTimeFrame:Hide()

        --the clock button
        -- LoadAddOn("Blizzard_TimeManager")
        -- if TimeManagerClockButton then
        --     local region = TimeManagerClockButton:GetRegions()
        --     region:Hide()
        --     TimeManagerClockTicker:SetFont(self.settings.font, self.settings.fontSize, self.settings.fontStyle)
        --     TimeManagerClockButton:ClearAllPoints()
        --     TimeManagerClockButton:SetPoint("TOPRIGHT",Minimap,"TOPRIGHT", 0, 0)
        -- end

        Minimap:SetMaskTexture(O3.Media:texture('Solid'))
        MinimapCluster:ClearAllPoints()
        MinimapCluster:SetPoint('TOPRIGHT', -29, -4)

        --scale minimap
        MinimapCluster:SetScale(1)

        Minimap:ClearAllPoints()
        MinimapCluster:SetSize(199, 199)
        Minimap:SetSize(197, 197)
        MinimapCluster:SetFrameStrata('BACKGROUND')
        Minimap:SetFrameStrata('BACKGROUND')

        --minimap position inside the cluster
        Minimap:ClearAllPoints()
        Minimap:SetPoint("TOPLEFT", 1, -1)

        -- local border = frame:CreateTexture()
        -- border:SetAllPoints()
        -- border:SetTexture(O3.Media:texture('tabs'))
        -- border:SetTexCoord(1640/2048, 1, 0, 438/2048)
        -- border:SetVertexColor(0.3, 0.3, 0.3)
        -- border:SetDrawLayer('BORDER', 6)

        -- --TRACKING O3
        O3:destroy(MiniMapTracking)
        MiniMapTrackingDropDown:SetParent(test)
        --minimap tracking button
        O3:destroy(MiniMapTrackingButton)

        local queueButton = self:createButton(nil, QueueStatusMinimapButton)
        queueButton:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', -2, -240)

        local mailButton = self:createButton([[Interface\Icons\Inv_Letter_04]], MiniMapMailFrame)
        mailButton:SetPoint('RIGHT', queueButton, 'LEFT', 0, 0)
        mailButton:SetFrameLevel(1)
        MiniMapMailFrame:SetFrameLevel(2)


        --icon overlay
        --MiniMapTrackingIconOverlay:SetTexture(nil)

        -- --MAIL ICON
        MiniMapMailFrame:SetParent(Minimap)
        
        MiniMapMailFrame:ClearAllPoints()
        MiniMapMailFrame:SetPoint('BOTTOMLEFT', mailButton, 'BOTTOMLEFT', 4, 4)
        MiniMapMailFrame:SetPoint('TOPRIGHT', mailButton, 'TOPRIGHT', -4, -4)

        --mail icon border
        O3:destroy(MiniMapMailBorder)
        --mail icon
        O3:destroy(MiniMapMailIcon)
        
        --CALENDAR ICON
        O3:destroy(GameTimeFrame)



        --text
        local OldGameTimeFrameText = select(5, GameTimeFrame:GetRegions())
        O3:destroy(OldGameTimeFrameText)

        --QUEUE STATUS ICON (LFG)
        QueueStatusMinimapButton:ClearAllPoints()
        QueueStatusMinimapButton:SetPoint('BOTTOMLEFT', queueButton, 'BOTTOMLEFT', 4, 4)
        QueueStatusMinimapButton:SetPoint('TOPRIGHT', queueButton, 'TOPRIGHT', -4, -4)
        O3:destroy(QueueStatusMinimapButtonBorder)
        queueButton:SetFrameLevel(1)
        QueueStatusMinimapButton:SetFrameLevel(2)

        --minimap mousewheel zoom
        Minimap:EnableMouseWheel()
        Minimap:SetScript("OnMouseWheel", function(self, direction)
                if(direction > 0) then
                Minimap_ZoomIn()
            else
                Minimap_ZoomOut()
            end
        end)        
    end,
})