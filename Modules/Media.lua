local addon, ns = ...
local O3 = ns.O3
local tInsert = table.insert


O3:module({
	name = 'Media',
	config = {
		enabled = true,
		mediaPath = [[Interface\Addons\O3\Media\]],
		soundsPath = 'a',
	},
	fontStyles = {
		{ label = 'None', value = ''},
		{ label = 'Thin', value = 'THINOUTLINE'},
		{ label = 'Outline', value = 'OUTLINE'},
		{ label = 'Thick', value = 'THICKOUTLINE'},
		{ label = 'Monochrome ', value = 'MONOCHROME'}
	},
	internal = true,
	fonts = { },
	borders = { },
	sounds = { },
	textures = { },
	statusBars = { },
	fontRegistry = { },
	borderRegistry = { },
	soundRegistry = { },
	textureRegistry = { },
	statusBarRegistry = { },
	addOptions = function (self)
		self:addOption('_1', {
			type = 'Title',
			label = 'Paths',
		})
		self:addOption('mediaPath', {
			type = 'String',
			label = 'Texture path',
		})
		self:addOption('_2', {
			type = 'Title',
			label = 'Texture path ',
		})
		self:addOption('soundsPath', {
			type = 'String',
			label = 'Sound path',
		})
	end,
	-------------------------------------------------------------------------------------
	-- Registers some default fonts
	-------------------------------------------------------------------------------------
	init = function (self, O3)
		-- self.fonts.Thin = self.config.mediaPath.."Fonts\\eurof55.ttf"
		-- self.fonts.Normal = self.config.mediaPath.."Fonts\\eurof75.ttf"
		-- self.fonts.Bold = self.config.mediaPath.."Fonts\\eurof75.ttf"

		-- self:registerFont('Comfortaa Light', self.config.mediaPath.."Fonts\\Comfortaa-Light.ttf")
		-- self:registerFont('Comfortaa Regular', self.config.mediaPath.."Fonts\\Comfortaa-Regular.ttf")
		-- self:registerFont('Comfortaa Bold', self.config.mediaPath.."Fonts\\Comfortaa-Bold.ttf")
		-- -- self:registerFont('Expressway', self.config.mediaPath.."Fonts\\Expressway.ttf")
		-- -- self:registerFont('Expressway Bold', self.config.mediaPath.."Fonts\\Expressway_Bold.ttf")
		-- -- self:registerFont('Ambrosia', self.config.mediaPath.."Fonts\\Ambrosia.ttf")
		-- self:registerFont('Coalition', self.config.mediaPath.."Fonts\\Coalition.ttf")

		self:registerFont('Normal', self.config.mediaPath.."Fonts\\ClearSans-Medium.ttf")
		self:registerFont('Normal', self.config.mediaPath.."Fonts\\Calibri-Bold.ttf")
		self:registerFont('Bold', self.config.mediaPath.."Fonts\\ClearSans-Bold.ttf")
		self:registerFont('Thin', self.config.mediaPath.."Fonts\\ClearSans-Regular.ttf")
		self:registerFont('Glyph', self.config.mediaPath.."Fonts\\FontAwesome.ttf", true)

		self:registerBorder('Solid', self.config.mediaPath.."Textures\\Solid")
		self:registerBorder('Shadow', self.config.mediaPath.."Borders\\Shadow")
		self:registerBorder('Shadow1', self.config.mediaPath.."Borders\\Shadow1")
		self:registerBorder('ShadowNoDist', self.config.mediaPath.."Borders\\ShadowNoDist")
		
		self:registerTexture('Default', self.config.mediaPath.."Textures\\Default")
		self:registerTexture('Solid', self.config.mediaPath.."Textures\\Solid")

		self:registerStatusBar('Default', self.config.mediaPath.."Statusbars\\Default")
		self:registerStatusBar('Stone', self.config.mediaPath.."Statusbars\\Stone")
		self:registerStatusBar('Rock', self.config.mediaPath.."Statusbars\\Rock")

	end,
	-------------------------------------------------------------------------------------
	-- Returns the path to a registered font
	-- 
	-- @param fontName Name of the font 
	--
	-- @return string Path to the font
	-------------------------------------------------------------------------------------
	font = function (self, fontName)
		return self.fonts[fontName] or self.config.mediaPath.."Fonts\\"..fontName..".ttf"
	end,
	-------------------------------------------------------------------------------------
	-- Returns the path to a registered border
	-- 
	-- @param borderName Name of the border 
	--
	-- @return string Path to the border
	-------------------------------------------------------------------------------------
	border = function (self, borderName)
		return self.borders[borderName] or self.config.mediaPath.."Borders\\"..borderName
	end,
	-------------------------------------------------------------------------------------
	-- Returns the path to a registered sound
	-- 
	-- @param soundName Name of the sound 
	--
	-- @return string Path to the sound
	-------------------------------------------------------------------------------------
	sound = function (self, soundName)
		return self.sounds[soundName] or self.config.mediaPath.."Sounds\\"..soundName..".mp3"
	end,
	-------------------------------------------------------------------------------------
	-- Returns the path to a registered texture
	-- 
	-- @param textureName Name of the texture 
	--
	-- @return string Path to the texture
	-------------------------------------------------------------------------------------
	texture = function (self, textureName)
		return self.textures[textureName] or self.config.mediaPath.."Textures\\"..textureName
	end,
	-------------------------------------------------------------------------------------
	-- Returns the path to a registered texture
	-- 
	-- @param textureName Name of the texture 
	--
	-- @return string Path to the texture
	-------------------------------------------------------------------------------------
	statusBar = function (self, textureName)
		return self.statusBars[textureName] or self.config.mediaPath.."Statusbars\\"..textureName
	end,    
	-------------------------------------------------------------------------------------
	-- Registers a font for later lookup, this is here for other addons to add their
	-- resources
	--
	-- @param fontName Name of the font
	-- @param fontFile Path to the font
	-------------------------------------------------------------------------------------
	registerFont = function (self, fontName, fontFile, skipRegistry)
		self.fonts[fontName]  = fontFile
		if not skipRegistry then
			tInsert(self.fontRegistry, {label = fontName, value = fontFile})
		end
	end,
	-------------------------------------------------------------------------------------
	-- Registers a border for later lookup, this is here for other addons to add their
	-- resources
	--
	-- @param borderName Name of the border
	-- @param borderFile Path to the border
	-------------------------------------------------------------------------------------
	registerBorder = function (self, borderName, borderFile)
		self.borders[borderName] = borderFile
		tInsert(self.borderRegistry, {label = borderName, value = borderFile})
	end,
	-------------------------------------------------------------------------------------
	-- Registers a sound for later lookup, this is here for other addons to add their
	-- resources
	--
	-- @param soundName Name of the sound
	-- @param soundFile Path to the sound
	-------------------------------------------------------------------------------------
	registerSound = function (self, soundName, soundFile)
		self.sounds[soundName] = soundFile
		tInsert(self.soundRegistry, {label = soundName, value = soundFile})
	end,
	-------------------------------------------------------------------------------------
	-- Registers a texture for later lookup, this is here for other addons to add their
	-- resources
	--
	-- @param textureName Name of the texture
	-- @param textureFile Path to the texture
	-------------------------------------------------------------------------------------
	registerTexture = function (self, textureName, textureFile)
		self.textures[textureName] = textureFile
		tInsert(self.textureRegistry, {label = textureName, value = textureFile})
	end,
	registerStatusBar = function (self, statusBarName, textureFile)
		self.statusBars[statusBarName] = textureFile
		tInsert(self.statusBarRegistry, {label = statusBarName, value = textureFile})
	end,
	-------------------------------------------------------------------------------------
	-- Plays a sound from the media lib
	-- 
	-- @param soundName Name of the sound 
	-------------------------------------------------------------------------------------    
	play = function (self, soundName)
		PlaySoundFile(self:sound(soundName), "master")
	end,

	-- texturePathSet = function (self)
	-- 	print(self.name, 'Texture Path set')
	-- end,
	-- applyOptions = function (self)
	-- 	print(self.name, 'Applying options')
	-- end,
})
