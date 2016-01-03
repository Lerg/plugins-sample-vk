-- VK plugin library

-- Load plugin
local vk = require('plugin.vk')

-- Available permissions
-- notify, friends, photos, audio, video, docs, notes,
-- pages, status, wall, groups, messages, notifications,
-- stats, ads, offline, direct, email

--[[
==== Plugin API ====

vk.init(app_id, permissions)
  app_id      - VK App Id
  permissions - array of string permissions

  Must be called first

vk.login(listener, options)
  listener             - called on finish of the request
  options              - dictionary of string elements (optional)
  options.inApp        - if true, don't use Safari, false by default

  Performs authorization

vk.logout()

  Logs current user out

vk.isLoggedIn() boolean

  Returns true if currently logged in

vk.getUserId() string

  Returns VK User Id of the current user

vk.showShareDialog(options)
  options            - dictionary of string elemets
  options.text       - main text
  options.link_title - link text
  options.link       - link URL
  options.image_id   - VK Image ID, for example '7840938_319411365'

  Shows VK Share dialog

vk.request(method, params, [httpMethod], listener)
  method     - VK API method string
  params     - method params, array of strings
  listener   - called on finish of the request

  Performs arbitrary VK API method call

vk.processOpenURL(url, sourceApplication)
  url               - received url string
  sourceApplication - sender app name string

  Used to authenticate with VK App or Safari

==== Extend plugin with Corona functions ====

vk.getMainColor()

  Returns RGB code for the VK blue color

vk.init(app_id, permissions, launchArgs)
  launchArgs - Launch Arguments for custom URL Scheme processing

  vk.init() wrapper

vk.getPhoto(params)
  params - dictionary
  params.id       - VK User Id string, current user by default
  params.listener - called on finish of the request

  Gets a user's avatar URL, 200x200px

 --]]

 function vk.getMainColor()
     -- #567ca4
     return 0.33, 0.48, 0.64
 end

local function processOpenURL(url)
    if url:sub(1, 2) == 'vk' then
        vk.processOpenURL(url, 'com.vk.vkclient')
    end
end

-- Wrapper to include Launch Arguments support
local _init = vk.init
function vk.init(app_id, permissions, launchArgs)
    _init(app_id, permissions)
    if launchArgs and launchArgs.url then
        processOpenURL(launchArgs.url)
    end
end

local json = require('json')

local hostname = 'https://api.vk.com/method/'

function vk.getPhoto(params)
    local id = params.id or vk.getUserId()
    if not id then
        return
    end
    local listener = params.listener
    local url = 'users.get?uids=' .. id .. '&fields=photo_200'
    network.request(hostname .. url , 'GET', function (event)
        if not event.isError then
            local response = json.decode(event.response)
            if response and response.response and response.response[1] then
                response = response.response[1]
                listener(response.photo_200)
            end
        end
    end)
end

local function onSystemEvent(event)
    if event.type == 'applicationOpen' and event.url then
        processOpenURL(event.url)
    end
end

Runtime:addEventListener('system', onSystemEvent)

return vk