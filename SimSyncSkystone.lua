--[[
	OBS Lua script
    Syncs FTC Sim Skystone game states with OBS text sources (for up to 4 independent servers)
    By Nicholas Bottone
--]]


local obs = obslua
local servers, simData1, simData2, simData3, simData4, interval -- OBS settings
local activeId = 0 -- active timer id


function safetyRead(f)
    local line = f:read()
    if ( line ) then
        return line
    end
    return "-"
end


local function checkFile(id)
	-- Purge old/outdated timers (happens when script is reloaded)
	if id < activeId then
		obs.remove_current_callback()
		return
	end

    for i = 1,servers,1
    do
        local sourceStr = " "..i
        local dataDirectory = simData1

        if ( i == 1 ) then
            sourceStr = ""
        end
        if ( i == 2 ) then
            dataDirectory = simData2
        end
        if ( i == 3 ) then
            dataDirectory = simData3
        end
        if ( i == 4 ) then
            dataDirectory = simData4
        end

        -- MATCH TIMER
        local f = io.open(dataDirectory.."/Timer.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Match Timer"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- RED SCORE
        local f = io.open(dataDirectory.."/ScoreR.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Red Score"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- BLUE SCORE
        local f = io.open(dataDirectory.."/ScoreB.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Blue Score"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Skybridge Red
        local f = io.open(dataDirectory.."/RSky.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Red Skybridge Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Skybridge Blue
        local f = io.open(dataDirectory.."/BSky.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Blue Skybridge Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Foundation Red
        local f = io.open(dataDirectory.."/RFound.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Red Foundation Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Foundation Blue
        local f = io.open(dataDirectory.."/BFound.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Blue Foundation Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Level Red
        local f = io.open(dataDirectory.."/RLevel.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Red Level Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Level Blue
        local f = io.open(dataDirectory.."/BLevel.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Blue Level Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Penalty Red
        local f = io.open(dataDirectory.."/PenR.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Red Penalty Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Penalty Blue
        local f = io.open(dataDirectory.."/PenB.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Blue Penalty Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

    end

end


local function init()
	-- Increment timer ID - old timers will be cancelled
	activeId = activeId + 1

	-- Starts the timer
	local id = activeId
	obs.timer_add(function() checkFile(id) end, interval)
end


-- Called when scripted is loaded/started
function script_load(settings)
end


-- Called on script is unloaded
function script_unload()
end


-- Called when OBS script settings changed
function script_update(settings)
    servers = obs.obs_data_get_int(settings, "servers")
	simData1 = obs.obs_data_get_string(settings, "simData1")
	simData2 = obs.obs_data_get_string(settings, "simData2")
	simData3 = obs.obs_data_get_string(settings, "simData3")
	simData4 = obs.obs_data_get_string(settings, "simData4")
	interval = obs.obs_data_get_int(settings, "interval")
	init()
end


-- The script description shown in OBS
function script_description()
	return "Syncs FTC sim game state to OBS text sources"
end


-- The config properties that can be changed inside OBS
function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_int(props, "servers", "Number of Servers", 1, 4, 1)
	obs.obs_properties_add_path(props, "simData1", "Sim Data 1", obs.OBS_PATH_DIRECTORY, "", nil)
	obs.obs_properties_add_path(props, "simData2", "Sim Data 2", obs.OBS_PATH_DIRECTORY, "", nil)
	obs.obs_properties_add_path(props, "simData3", "Sim Data 3", obs.OBS_PATH_DIRECTORY, "", nil)
	obs.obs_properties_add_path(props, "simData4", "Sim Data 4", obs.OBS_PATH_DIRECTORY, "", nil)
	obs.obs_properties_add_int(props, "interval", "Interval (ms)", 100, 2000, 100)
	return props
end


-- Default values for the above mentioned config properties
function script_defaults(settings)
    obs.obs_data_set_default_int(settings, "servers", 2)
	obs.obs_data_set_default_string(settings, "simData1", "")
	obs.obs_data_set_default_string(settings, "simData2", "")
	obs.obs_data_set_default_string(settings, "simData3", "")
	obs.obs_data_set_default_string(settings, "simData4", "")
	obs.obs_data_set_default_int(settings, "interval", 200)
end


-- Save additional data not set by user
function script_save(settings)
end