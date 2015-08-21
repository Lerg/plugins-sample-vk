local composer = require('composer')
local widget = require('widget')
local json = require('json')
local vk = require('lib.vk')

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

function scene:create(event)
    local group = self.view

    local mode = event.params.mode
    local friends = event.params.friends
    local invitationList = {}

    local background = display.newRect(_CX, _CY, _SW, _SH)
    background:setFillColor(vk.getMainColor())
    group:insert(background)

    local title = display.newText{
        parent = group,
        text = 'Мои друзья',
        x = _CX,
        y = 20,
        font = native.systemFontBold,
        fontSize = 14}

    local button = widget.newButton{
        x = 45, y = 20,
        width = 80, height = 32,
        label = 'Отмена',
        fontSize = 10,
        shape = 'roundedRect',
        cornerRadius = 2,
        fillColor = {default={1}, over={0.75}},
        onRelease = function()
            composer.gotoScene('scenes.menu', {effect = 'slideRight', time = 400})
        end}
    group:insert(button)

    if mode == 'invite' then
        local button = widget.newButton{
            x = _W - 45, y = 20,
            width = 80, height = 32,
            label = 'Пригласить',
            fontSize = 10,
            shape = 'roundedRect',
            cornerRadius = 2,
            fillColor = {default={1}, over={0.75}},
            onRelease = function()
                native.showAlert('VK App', 'Как приглашать?', {'Отмена', 'Стена', 'Сообщение'}, function(event)
                    local message = 'Приглашаю тебя в эту крутую игру! http://spiralcodestudio.com';
                    if event.action == 'clicked' then
                        if event.index == 2 then
                            -- Wall post
                            for id, v in pairs(invitationList) do
                                vk.request('wall.post', {owner_id = tonumber(id), message = message}, function(event)
                                    if not event.isError then
                                        if event.response then
                                            print('Invite Success')
                                        end
                                    else
                                        print('Error', event.errorMessage)
                                    end
                                end)
                            end
                            composer.gotoScene('scenes.menu', {effect = 'slideRight', time = 400})
                        elseif event.index == 3 then
                            -- Message
                            for id, v in pairs(invitationList) do
                                vk.request('messages.send', {user_id = tonumber(id), message = message}, function(event)
                                    if not event.isError then
                                        if event.response then
                                            print('Invite Success')
                                        end
                                    else
                                        print('Error', event.errorMessage)
                                    end
                                end)
                            end
                            composer.gotoScene('scenes.menu', {effect = 'slideRight', time = 400})
                        end
                    end
                end)
            end}
        group:insert(button)
    end

    local defaultColor = {1, 1, 1}
    local selectedColor = {0.5, 0.75, 1}

    local function onRowTouch(event)
        local row = event.row
        if event.phase == 'tap' then
            local id = event.row.params.id
            if not invitationList[id] then
                invitationList[id] = true
                row.bg:setFillColor(unpack(selectedColor))
            else
                invitationList[id] = nil
                row.bg:setFillColor(unpack(defaultColor))
            end
        end
    end

    local function onRowRender(event)
        local row = event.row
        local friend = event.row.params

        local rowWidth = row.contentWidth
        local rowHeight = row.contentHeight

        local bg = display.newRect(rowWidth * 0.5, rowHeight * 0.5, rowWidth, rowHeight)
        bg:setFillColor(unpack(defaultColor))
        row:insert(bg)
        row.bg = bg

        local name = display.newText{
            parent = row,
            text = friend.first_name .. ' ' .. friend.last_name,
            font = native.systemFont,
            fontSize = 14}
        name:setFillColor(0)
        name.anchorX = 0
        name.x, name.y = 60, rowHeight * 0.5

        if mode == 'invite' then
            local invite = display.newText{
                parent = row,
                text = 'Выбрать',
                font = native.systemFont,
                fontSize = 14}
            invite:setFillColor(0, 0.5, 0.5)
            invite.anchorX = 0
            invite.x, invite.y = rowWidth - 90, rowHeight * 0.5
        end

        local function callback(event)
            if not event.isError then
                local image = event.target
                if row.insert then
                    image:scale(0.4, 0.4)
                    row:insert(image)
                    image.x, image.y = 25, rowHeight * 0.5
                else
                    display.remove(image)
                end
            end
        end
        display.loadRemoteImage(friend.photo_100, 'GET', callback, friend.id .. '.jpg', system.CachesDirectory)
    end

    local tableView = widget.newTableView{
        x = _CX, y = _CY + 30,
        height = _H - 30,
        width = _W,
        onRowRender = onRowRender,
        onRowTouch = (mode == 'invite') and onRowTouch or nil}

    for i = 1, #friends do
        tableView:insertRow{
            rowColor = {default = {1, 1, 1}, over = {1, 0.5, 0, 0.2}},
            lineColor = {0.5, 0.5, 0.5},
            rowHeight = 60,
            params = friends[i]}
    end

    group:insert(tableView)
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