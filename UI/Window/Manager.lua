local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI


UI.Window.Manager = O3.Class:instance({
	managedWindows = {},
	_cache = {},
	init = function (self)
	end,
	add = function (self, window)
		self.managedWindows[window] = true
		window:clearAllPoints()
		self:reposition()
	end,
	remove = function (self, window)
		self.managedWindows[window] = nil
		window:clearAllPoints()
		self:reposition()
	end,
	reposition = function (self)
		table.wipe(self._cache)
		for window, foo in pairs(self.managedWindows) do
			if (window:visible()) then
				table.insert(self._cache, window)
			end
		end
		table.sort(self._cache, function (a, b)
			return a._weight > b._weight
		end)
		local lastWindow = nil
		for i = 1, #self._cache do
			local window = self._cache[i]
			if (lastWindow) then
				window:point('TOPRIGHT', lastWindow, 'TOPLEFT', -4, 0)
			else
				window:point('TOPRIGHT', UIParent, 'TOPRIGHT', -4, -240)
			end
			lastWindow = window.frame
		end
	end,
})