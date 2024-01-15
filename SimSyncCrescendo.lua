--[[
    OBS Lua script
    Syncs FRC Sim game states with OBS text sources (for up to 4 independent servers)
    Designed for FRC 2024 Crescendo
    By Nicholas Bottone
--]]

local MELODY_BONUS_RP = 18
local ENSEMBLE_BONUS_RP = 10

local obs = obslua
local servers, simData1, simData2, simData3, simData4, interval -- OBS settings
local activeId = 0 -- active timer id

function isempty(s)
    return s == nil or s == ''
end

function safetyRead(f)
    local line = f:read()
    if ( line ) then
        return line
    end
    return ""
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
        local f = io.open(dataDirectory.."/Score_R.txt", "rb")
        local redScore = "0"
        if f then
            settings = obs.obs_data_create()
            redScore = safetyRead(f)
            obs.obs_data_set_string(settings, "text", redScore)
            source = obs.obs_get_source_by_name("Red Score"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- BLUE SCORE
        local f = io.open(dataDirectory.."/Score_B.txt", "rb")
        local blueScore = "0"
        if f then
            settings = obs.obs_data_create()
            blueScore = safetyRead(f)
            obs.obs_data_set_string(settings, "text", blueScore)
            source = obs.obs_get_source_by_name("Blue Score"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Auto Red
        local f = io.open(dataDirectory.."/Auto_R.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Red Auto Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Auto Blue
        local f = io.open(dataDirectory.."/Auto_B.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Blue Auto Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Tele Red
        local f = io.open(dataDirectory.."/Tele_R.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Red Teleop Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Tele Blue
        local f = io.open(dataDirectory.."/Tele_B.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Blue Teleop Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- End Red
        local f = io.open(dataDirectory.."/End_R.txt", "rb")
        local endRed = 0
        if f then
            endRed = tonumber(safetyRead(f))
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", tostring(endRed))
            source = obs.obs_get_source_by_name("Red Endgame Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- End Blue
        local f = io.open(dataDirectory.."/End_B.txt", "rb")
        local endBlue = 0
        if f then
            endBlue = tonumber(safetyRead(f))
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", tostring(endBlue))
            source = obs.obs_get_source_by_name("Blue Endgame Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Notes Red
        local notesRed = 0
        local f = io.open(dataDirectory.."/Aamp_R.txt", "rb") -- Auto Amp
        if f then
            notesRed = notesRed + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/Aspeaker_R.txt", "rb") -- Auto Speaker
        if f then
            notesRed = notesRed + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/Tamp_R.txt", "rb") -- Teleop Amp
        if f then
            notesRed = notesRed + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/Tspeaker_R.txt", "rb") -- Teleop Speaker
        if f then
            notesRed = notesRed + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/Tspeakeramp_R.txt", "rb") -- Teleop Speaker Amplified
        if f then
            notesRed = notesRed + tonumber(safetyRead(f))
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(notesRed))
        source = obs.obs_get_source_by_name("Red Notes"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Notes Blue
        local notesBlue = 0
        local f = io.open(dataDirectory.."/Aamp_B.txt", "rb") -- Auto Amp
        if f then
            notesBlue = notesBlue + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/Aspeaker_B.txt", "rb") -- Auto Speaker
        if f then
            notesBlue = notesBlue + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/Tamp_B.txt", "rb") -- Teleop Amp
        if f then
            notesBlue = notesBlue + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/Tspeaker_B.txt", "rb") -- Teleop Speaker
        if f then
            notesBlue = notesBlue + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/Tspeakeramp_B.txt", "rb") -- Teleop Speaker Amplified
        if f then
            notesBlue = notesBlue + tonumber(safetyRead(f))
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(notesBlue))
        source = obs.obs_get_source_by_name("Blue Notes"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Penalty Red
        local f = io.open(dataDirectory.."/Fouls_R.txt", "rb")
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
        local f = io.open(dataDirectory.."/Fouls_B.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f))
            source = obs.obs_get_source_by_name("Blue Penalty Points"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- OPR Red
        local f = io.open(dataDirectory.."/OPR.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f).."\n"..safetyRead(f).."\n"..safetyRead(f))
            source = obs.obs_get_source_by_name("OPR-Red"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- OPR Blue
        local f = io.open(dataDirectory.."/OPR.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            safetyRead(f)
            safetyRead(f)
            safetyRead(f)
            obs.obs_data_set_string(settings, "text", safetyRead(f).."\n"..safetyRead(f).."\n"..safetyRead(f))
            source = obs.obs_get_source_by_name("OPR-Blue"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- OPR All
        local f = io.open(dataDirectory.."/OPR.txt", "rb")
        if f then
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", safetyRead(f).."\n"..safetyRead(f).."\n"..safetyRead(f).."\n"..safetyRead(f).."\n"..safetyRead(f).."\n"..safetyRead(f))
            source = obs.obs_get_source_by_name("OPR"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        if isempty(redScore) then
            redScore = "0"
        end
        if isempty(blueScore) then
            blueScore = "0"
        end

        -- Calculate Ranking Points
        local redRP = 0
        if (notesRed >= MELODY_BONUS_RP) then
            redRP = redRP + 1
        end
        if (endRed >= ENSEMBLE_BONUS_RP) then
            redRP = redRP + 1
        end
        
        local blueRP = 0
        if (notesBlue >= MELODY_BONUS_RP) then
            blueRP = blueRP + 1
        end
        if (endBlue >= ENSEMBLE_BONUS_RP) then
            blueRP = blueRP + 1
        end

        -- Win/Loss
        if (tonumber(redScore) > tonumber(blueScore)) then
            -- Red Wins
            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", "WIN")
            source = obs.obs_get_source_by_name("Red Result"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)

            settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", "LOSS")
            source = obs.obs_get_source_by_name("Blue Result"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)

            redRP = redRP + 2
        else
            if (tonumber(redScore) < tonumber(blueScore)) then
                -- Blue Wins
                settings = obs.obs_data_create()
                obs.obs_data_set_string(settings, "text", "WIN")
                source = obs.obs_get_source_by_name("Blue Result"..sourceStr)
                obs.obs_source_update(source, settings)
                obs.obs_data_release(settings)
                obs.obs_source_release(source)

                settings = obs.obs_data_create()
                obs.obs_data_set_string(settings, "text", "LOSS")
                source = obs.obs_get_source_by_name("Red Result"..sourceStr)
                obs.obs_source_update(source, settings)
                obs.obs_data_release(settings)
                obs.obs_source_release(source)

                blueRP = blueRP + 2
            else
                -- Tie
                settings = obs.obs_data_create()
                obs.obs_data_set_string(settings, "text", "TIE")
                source = obs.obs_get_source_by_name("Red Result"..sourceStr)
                obs.obs_source_update(source, settings)
                obs.obs_data_release(settings)
                obs.obs_source_release(source)

                settings = obs.obs_data_create()
                obs.obs_data_set_string(settings, "text", "TIE")
                source = obs.obs_get_source_by_name("Blue Result"..sourceStr)
                obs.obs_source_update(source, settings)
                obs.obs_data_release(settings)
                obs.obs_source_release(source)

                redRP = redRP + 1
                blueRP = blueRP + 1
            end
        end

        -- RP Red
        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(redRP))
        source = obs.obs_get_source_by_name("Red RP"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- RP Blue
        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(blueRP))
        source = obs.obs_get_source_by_name("Blue RP"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

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
    return "Syncs FRC Sim Crescendo game state to OBS text sources"
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
