local composer = require('composer')
local widget = require('widget')
local json = require('json')
local vk = require('plugin.vk')
widget.setTheme('widget_theme_ios')

-- Add a couple additional functions
-- VK's blue color
function vk.getMainColor()
	-- #567ca4
	return 0.33, 0.48, 0.64
end

-- Load profile image
function vk.getPhoto(params)
	local id = params.id or vk.getUserId()
	if not id then
		return
	end
	local listener = params.listener
	local url = 'users.get?uids=' .. id .. '&fields=photo_200'
	network.request('https://api.vk.com/method/' .. url , 'GET', function (event)
		if not event.isError then
			local response = json.decode(event.response)
			if response and response.response and response.response[1] then
				response = response.response[1]
				listener(response.photo_200)
			end
		end
	end)
end

-- Print additional debug information
--vk.enableDebug()

-- VK App ID and array of permissions
vk.init('4789591', {'messages', 'friends', 'wall', 'photos'})

-- Silently attempt to log in user, will be successful if the user has logged in before.
vk.login{
	--userInitiated = true, -- if false/nil, user won't be prompted with a login window
	listener = function(event)
		print('Corona Login Listener')
		print(json.prettify(event))
	end
}

local r, g, b = vk.getMainColor()
display.setDefault('background', r, g, b)
composer.gotoScene('scenes.menu')
