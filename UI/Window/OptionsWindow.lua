local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.OptionsWindow = UI.ScrollWindow:extend({
	width = 512,
	postCreate = function (self)
		local contentFrame = self.contentFrame
		local options = self.module.options
		local lastFrame = nil
		for i=1,#options do
			local option = options[i]
			local type = option.type
			local optionCreator = O3.UI.Option[type]
			if optionCreator then
				option.type = nil
				option.handler = self.module
				option.parentFrame = contentFrame
				option.offset =  {2, nil, 2, nil}
				local createdOption = optionCreator:instance(option)
				if (lastFrame) then					
					createdOption:point('TOP', lastFrame, 'BOTTOM', 0, -2)
				else
					createdOption:point('TOP')
				end
				lastFrame = createdOption.frame
			end
		end
	end,
})