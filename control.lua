local regexes = {} -- strings that will be replaced for numeric values | must be bettween { }
local base_name = "" -- base name informed by user
local entities = {} -- table of all entities on the selected area
local starting_index = {} -- int of the starting index of every string regex; this is informed in the gui
local index_txtfields_refs = {} -- references to the index textfields

local gui_frame -- reference to the gui

local function check_has_train_stops(event)
    for _, entity in pairs(event.entities) do
        if entity.type == "train-stop" and entity.supports_backer_name() then
            return true
        end
    end
    return false
end

local function setup_regexes()
    regexes = {}; -- reset regexes

    for word in string.gmatch(base_name, "%{(.-)%}") do
        if (string.len(word) == 0) then goto continue end
        if regexes[word] == nil then regexes[word] = 0 end
        ::continue::
    end
end

local function get_new_station_name()
    local new_station_name = base_name

    for word, value in pairs(regexes) do
        if value == 0 then
            -- first iteration
           value = starting_index[word]
        end
        -- replace regex for number
        new_station_name = string.gsub(new_station_name, "%{(" .. word .. ")%}",
                                       tostring(value))
        -- increment
        regexes[word] = value + 1 
    end
    return new_station_name
end

local function open_gui_for_name(event)
    if event.item ~= "station-group-nominator" then return end

    local player = game.get_player(event.player_index)
    if (player.gui.center["gui-frame"] ~= nil) then
        player.gui.center["gui-frame"].destroy()
    end

    if (event.entities == nil) then return end
    if (check_has_train_stops(event) == false) then return end

    entities = event.entities
    gui_frame = player.gui.center.add({
        type = "frame",
        direction = "vertical",
        name = "gui-frame",
        caption = "Name for stations"
    })
     gui_frame.add({
        type = "label",
        caption = "Text between braces will be replaced  by incremental numbers.\n example: '#{y} Iron Ore pick up {x}')"
    })

    gui_frame.add({type = "textfield", name = "gui_station_name_textfield"})
    local flow2 = gui_frame.add({
        type = "flow"
    })
    flow2.add({type = "button", name = "gui-ok-name-button", caption = "OK"})
    flow2.add({
        type = "button",
        name = "gui-cancel-button",
        caption = "Cancel"
    })

end

local function set_new_stations_name()
    for k, entity in pairs(entities) do
        if entity.type == "train-stop" and entity.supports_backer_name() then
            entity.backer_name = get_new_station_name();
        end
    end
    base_name = "" -- reset base_name
    entities = {} -- reset entities
end

local function open_gui_regex_index(event)
    setup_regexes()
    -- if no index needed, apply name and leave  
    if next(regexes) == nil then
        set_new_stations_name()
        return
    end

    local player = game.get_player(event.player_index)
    if (player.gui.center["gui-frame"] ~= nil) then
        player.gui.center["gui-frame"].destroy()
    end

    gui_frame = player.gui.center.add({
        type = "frame",
        direction = "vertical",
        name = "gui-frame",
        caption = "Confirm starting numbers"
    })

    for word, _ in pairs(regexes) do
        local flow = gui_frame.add({type = "flow"})
        flow.add({type = "label", caption = word})
        local txtf = flow.add({
            type = "textfield",
            text = "1",
            numeric = true
        })
        index_txtfields_refs[word] = txtf
    end
    flow_buttons = gui_frame.add({type = "flow"})

    flow_buttons.add({
        type = "button",
        name = "gui-ok-index-button",
        caption = "OK"
    })
    flow_buttons.add({
        type = "button",
        name = "gui-cancel-button",
        caption = "Cancel"
    })

end

local function check_gui_action(event)
    if event.element.name == "gui-cancel-button" then
        gui_frame.destroy()
        return
    end
    if event.element.name == "gui-ok-name-button" then

        -- get text from textfield
        for _, element in pairs(gui_frame.children) do
            if element.name == "gui_station_name_textfield" then
                base_name = element.text
            end
        end
        -- exit if no name was provided
        if (string.len(base_name) == 0) then return end

        -- close the gui 
        gui_frame.destroy()
        -- init next gui for index
        open_gui_regex_index(event)
        return
    end
    if event.element.name == "gui-ok-index-button" then

        for word, _ in pairs(regexes) do
            starting_index[word] = tonumber(index_txtfields_refs[word].text)
        end
        set_new_stations_name()

         -- close the gui 
         gui_frame.destroy()
    end
end

script.on_event(defines.events.on_player_selected_area, open_gui_for_name)
script.on_event(defines.events.on_gui_click, check_gui_action)
