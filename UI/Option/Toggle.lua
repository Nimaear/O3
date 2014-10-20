local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.Option.Toggle = UI.Option:extend({
	on = true,
	off = false,
	createRegions = function (self)
		self.control = UI.CheckBox:instance({
			on = self.on,
			off = self.off,
			offset = {self.labelWidth+2},
			parentFrame = self.frame,
			callback = function (checkBox, value)
				self:change(value)
			end,
		})
		self.label = self:createFontString({
			offset = {nil, 0, 0, 0},
			width = self.labelWidth,
			text = self.label, 
			justifyH = 'LEFT',
		})
		self.label:SetPoint('LEFT', self.control.frame, 'RIGHT', 2, 0)
	end,
	update = function (self)
		self.control.value = self.value
		self.control:update()
	end,
})


-- local test = O3:module({
-- 	config = {
-- 		enabled = true,
-- 		test = true,
-- 		string = 'Oz',
-- 		statusbar = nil,
-- 	},
-- 	VARIABLES_LOADED = function (self)
-- 		UI.Option:factory({
-- 			optionType = 'Toggle',
-- 			-- value = true,
-- 			token = 'test',
-- 			offset = {400, nil, 284, nil},
-- 			label = 'Toggle',
-- 		}, self, UIParent)

-- 		UI.Option:factory({
-- 			optionType = 'String',
-- 			token = 'string',
-- 			offset = {400, nil, 200, nil},
-- 			label = 'Test',
-- 		}, self, UIParent)


-- 		local dd = UI.Option:factory({
-- 			optionType = 'StatusBarDropDown',
-- 			token = 'statusbar',
-- 			offset = {400, nil, 221, nil},
-- 			label = 'Test',
-- 			avalues = {
-- 				{value = '1', label = 'Test 1'},
-- 				{value = '2', label = 'Test 2'},
-- 				{value = '3', label = 'Test 3'},
-- 				{value = '4', label = 'Test 4'},
-- 				{value = '5', label = 'Test 5'},
-- 				{value = '6', label = 'Test 6'},
-- 				{value = '7', label = 'Test 7'},
-- 				{value = '8', label = 'Test 8'},
-- 				{value = '9', label = 'Test 9'},
-- 				{value = '10', label = 'Test 10'},
-- 				{value = '11', label = 'Test 11'},
-- 				{value = '12', label = 'Test 12'},
-- 				{value = '13', label = 'Test 13'},
-- 				{value = '14', label = 'Test 14'},
-- 				{value = '15', label = 'Test 15'},
-- 			}
-- 		}, self, UIParent)
-- 		dd.control:remove('12')

-- 		UI.Option:factory({
-- 			optionType = 'Button',
-- 			token = 'test',
-- 			offset = {400, nil, 242, nil},
-- 			label = 'Test Button',
-- 		}, self, UIParent)

-- 		UI.Option:factory({
-- 			optionType = 'Title',
-- 			token = 'test',
-- 			offset = {400, nil, 263, nil},
-- 			label = 'Title',
-- 		}, self, UIParent)

-- 	end,
-- 	name = 'Test',
-- })


