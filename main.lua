local storyboard = require('storyboard')
local widget = require('widget')
local vk = require('lib.vk')

widget.setTheme('widget_theme_ios')

local launchArgs = ...
-- VK App ID, array of permissions and Launch Arguments
vk.init('4789591', {'messages', 'friends', 'wall'}, launchArgs)

-- Available permissions
-- notify, friends, photos, audio, video, docs, notes,
-- pages, status, wall, groups, messages, notifications,
-- stats, ads, offline, nohttps, direct, email

local r, g, b = vk.getMainColor()
display.setDefault('background', r, g, b)
storyboard.gotoScene('scenes.menu')