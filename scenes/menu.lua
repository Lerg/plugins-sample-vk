local composer = require('composer')
local widget = require('widget')
local json = require('json')
local vk = require('plugin.vk')

local _W = display.contentWidth
local _H = display.contentHeight
local _CX, _CY = _W * 0.5, _H * 0.5

local _T, _L = display.screenOriginY, display.screenOriginX -- Top, Left
local _R, _B = display.viewableContentWidth - _L, display.viewableContentHeight - _T -- Right, Bottom
local _SW, _SH = _R - _L, _B - _T -- Screen width and height in virtual coordinate system

local function alert(text)
	native.showAlert('VK App', text or 'nil', {'OK'})
end

local scene = composer.newScene()

function scene:create()
	local group = self.view

	local background = display.newRect(_CX, _CY, _SW, _SH)
	background:setFillColor(vk.getMainColor())
	group:insert(background)

	local spacing = 80
	local w, h = 140, 40

	local shape = 'roundedRect'
	local cornerRadius = 2
	local fillColor = {default={1}, over={0.75}}

	local button = widget.newButton{
		x = _CX - spacing, y = _CY - spacing * 2,
		width = w, height = h,
		label = 'Login',
		shape = shape,
		cornerRadius = cornerRadius,
		fillColor = fillColor,
		onRelease = function()
			vk.login{
				--inApp = true,
				userInitiated = true,
				listener = function(event)
					print('Corona Login Listener')
					print(json.prettify(event))
				end
			}
		end}
	group:insert(button)

	button = widget.newButton{
		x = _CX + spacing, y = _CY - spacing * 2,
		width = w, height = h,
		label = 'Logout',
		shape = shape,
		cornerRadius = cornerRadius,
		fillColor = fillColor,
		onRelease = function()
			vk.logout()
		end}
	group:insert(button)

	local function getFriends(mode)
		local listType = (mode == 'invite') and 'invite' or 'request'
		vk.request('apps.getFriendsList', {extended = 1, count = 500, fields = 'photo_100', type = listType}, function(event)
			if not event.isError then
				if event.response then
					local response = json.decode(event.response)
					composer.gotoScene('scenes.friends', {effect = 'slideLeft', time = 400, params = {
						mode = mode,
						friends = response.response.items
					}})
				end
			else
				print('Error', event.errorMessage)
			end
		end)
	end

	button = widget.newButton{
		x = _CX - spacing, y = _CY - spacing,
		width = w, height = h,
		label = 'Invite Friends',
		shape = shape,
		cornerRadius = cornerRadius,
		fillColor = fillColor,
		onRelease = function()
			getFriends('invite')
		end}
	group:insert(button)

	button = widget.newButton{
		x = _CX + spacing, y = _CY - spacing,
		width = w, height = h,
		label = 'App Friends',
		shape = shape,
		cornerRadius = cornerRadius,
		fillColor = fillColor,
		onRelease = function()
			getFriends('app_friends')
		end}
	group:insert(button)

	button = widget.newButton{
		x = _CX - spacing, y = _CY,
		width = w, height = h,
		label = 'Get Photo',
		shape = shape,
		cornerRadius = cornerRadius,
		fillColor = fillColor,
		onRelease = function()
			local function callback(event)
				if not event.isError then
					local image = event.target
					group:insert(image)
					image.x, image.y = _CX, _CY
					function image:touch(touchEvent)
						if touchEvent.phase == 'began' then
							self:removeSelf()
						end
						return true
					end
					image:addEventListener('touch')
				end
			end
			vk.getPhoto{listener = function(url)
				display.loadRemoteImage(url, 'GET', callback, 'avatar.jpg', system.CachesDirectory, 50, 50)
			end}
		end}
	group:insert(button)

	button = widget.newButton{
		x = _CX + spacing, y = _CY,
		width = w, height = h,
		label = 'Wall post',
		shape = shape,
		cornerRadius = cornerRadius,
		fillColor = fillColor,
		onRelease = function()
			vk.request('wall.post', {
					message = 'Spiral Code Studio website! http://spiralcodestudio.com',
					attachments = 'photo-48491658_316942391'
				},
				function(event)
					if not event.isError then
						alert('Отправлено!')
					else
						print('Error', event.errorMessage)
					end
				end)
		end}
	group:insert(button)

	button = widget.newButton{
		x = _CX + spacing, y = _CY + spacing,
		width = w, height = h,
		label = 'Share dialog',
		shape = shape,
		cornerRadius = cornerRadius,
		fillColor = fillColor,
		onRelease = function()
			vk.showShareDialog{
				text = 'Sharing Message',
				linkTitle = 'Click This Link',
				link = 'http://spiralcodestudio.com',
				imageId = '-48491658_431178351',
				image = {
					filename = 'images/share.png',
					--baseDir = system.DocumentsDirectory
				},
				listener = function(event)
					print('Share dialog event:', json.prettify(event))
				end
			}
		end}
	group:insert(button)

	button = widget.newButton{
		x = _CX - spacing, y = _CY + spacing,
		width = w, height = h,
		label = 'Logged In?',
		shape = shape,
		cornerRadius = cornerRadius,
		fillColor = fillColor,
		onRelease = function()
			local result = vk.isLoggedIn() and 'Yes' or 'No'
			alert(result)
		end}
	group:insert(button)

	button = widget.newButton{
		x = _CX - spacing, y = _CY + spacing * 2,
		width = w, height = h,
		label = 'Get User Id',
		shape = shape,
		cornerRadius = cornerRadius,
		fillColor = fillColor,
		onRelease = function()
			alert(vk.getUserId())
		end}
	group:insert(button)

	button = widget.newButton{
		x = _CX + spacing, y = _CY + spacing * 2,
		width = w, height = h,
		label = 'Access Token',
		shape = shape,
		cornerRadius = cornerRadius,
		fillColor = fillColor,
		onRelease = function()
			print(json.prettify(vk.getAccessToken()))
		end}
	group:insert(button)
end

function scene:hide(event)
	if event.phase == 'did' then
		local previous_scene = composer.getSceneName('previous')
		if previous_scene then
			composer.removeScene(previous_scene)
		end
	end
end

scene:addEventListener('hide')
scene:addEventListener('create')
return scene
