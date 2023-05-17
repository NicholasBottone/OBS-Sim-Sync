--[[
	OBS Lua script
    Syncs FRC Sim game states with OBS text sources (for up to 4 independent servers)
    Designed for FRC 2023 Charged Up
    By Nicholas Bottone
--]]

local SUSTAINABILITY_BONUS_RP = 9
local ACTIVATION_BONUS_RP = 32

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
        local endRed = 0
        local f = io.open(dataDirectory.."/TParkC_R.txt", "rb")
        if f then
            endRed = endRed + (tonumber(safetyRead(f)) * 2)
            f:close()
        end
        f = io.open(dataDirectory.."/TDockC_R.txt", "rb")
        if f then
            endRed = endRed + (tonumber(safetyRead(f)) * 6)
            f:close()
        end
        f = io.open(dataDirectory.."/TEngC_R.txt", "rb")
        if f then
            endRed = endRed + (tonumber(safetyRead(f)) * 10)
            f:close()
        end
        
        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(endRed))
        source = obs.obs_get_source_by_name("Red Endgame Points"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- End Blue
        local endBlue = 0
        local f = io.open(dataDirectory.."/TParkC_B.txt", "rb")
        if f then
            endBlue = endBlue + (tonumber(safetyRead(f)) * 2)
            f:close()
        end
        f = io.open(dataDirectory.."/TDockC_B.txt", "rb")
        if f then
            endBlue = endBlue + (tonumber(safetyRead(f)) * 6)
            f:close()
        end
        f = io.open(dataDirectory.."/TEngC_B.txt", "rb")
        if f then
            endBlue = endBlue + (tonumber(safetyRead(f)) * 10)
            f:close()
        end
        
        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(endBlue))
        source = obs.obs_get_source_by_name("Blue Endgame Points"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Game Pieces Red
        local gamePiecesRed = 0
        local f = io.open(dataDirectory.."/ABotC_R.txt", "rb") -- Auto Bottom
        if f then
            gamePiecesRed = gamePiecesRed + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/AMidC_R.txt", "rb") -- Auto Middle
        if f then
            gamePiecesRed = gamePiecesRed + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/ATopC_R.txt", "rb") -- Auto Top
        if f then
            gamePiecesRed = gamePiecesRed + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/TBotC_R.txt", "rb") -- Teleop Bottom
        if f then
            gamePiecesRed = gamePiecesRed + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/TMidC_R.txt", "rb") -- Teleop Middle
        if f then
            gamePiecesRed = gamePiecesRed + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/TTopC_R.txt", "rb") -- Teleop Top
        if f then
            gamePiecesRed = gamePiecesRed + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/TSuperC_R.txt", "rb") -- Teleop Super
        if f then
            gamePiecesRed = gamePiecesRed + tonumber(safetyRead(f))
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(gamePiecesRed))
        source = obs.obs_get_source_by_name("Red Game Pieces"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Game Pieces Blue
        local gamePiecesBlue = 0
        local f = io.open(dataDirectory.."/ABotC_B.txt", "rb") -- Auto Bottom
        if f then
            gamePiecesBlue = gamePiecesBlue + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/AMidC_B.txt", "rb") -- Auto Middle
        if f then
            gamePiecesBlue = gamePiecesBlue + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/ATopC_B.txt", "rb") -- Auto Top
        if f then
            gamePiecesBlue = gamePiecesBlue + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/TBotC_B.txt", "rb") -- Teleop Bottom
        if f then
            gamePiecesBlue = gamePiecesBlue + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/TMidC_B.txt", "rb") -- Teleop Middle
        if f then
            gamePiecesBlue = gamePiecesBlue + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/TTopC_B.txt", "rb") -- Teleop Top
        if f then
            gamePiecesBlue = gamePiecesBlue + tonumber(safetyRead(f))
            f:close()
        end
        f = io.open(dataDirectory.."/TSuperC_B.txt", "rb") -- Teleop Super
        if f then
            gamePiecesBlue = gamePiecesBlue + tonumber(safetyRead(f))
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(gamePiecesBlue))
        source = obs.obs_get_source_by_name("Blue Game Pieces"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Charge Station Red
        local chargeStationRed = endRed
        local f = io.open(dataDirectory.."/ADockC_R.txt", "rb")
        if f then
            chargeStationRed = chargeStationRed + (tonumber(safetyRead(f)) * 8)
            f:close()
        end
        f = io.open(dataDirectory.."/AEngC_R.txt", "rb")
        if f then
            chargeStationRed = chargeStationRed + (tonumber(safetyRead(f)) * 12)
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(chargeStationRed))
        source = obs.obs_get_source_by_name("Red Charge Station Points"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Charge Station Blue
        local chargeStationBlue = endBlue
        local f = io.open(dataDirectory.."/ADockC_B.txt", "rb")
        if f then
            chargeStationBlue = chargeStationBlue + (tonumber(safetyRead(f)) * 8)
            f:close()
        end
        f = io.open(dataDirectory.."/AEngC_B.txt", "rb")
        if f then
            chargeStationBlue = chargeStationBlue + (tonumber(safetyRead(f)) * 12)
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(chargeStationBlue))
        source = obs.obs_get_source_by_name("Blue Charge Station Points"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Links Red
        local linksRed = 0
        local f = io.open(dataDirectory.."/TLinkC_R.txt", "rb")
        if f then
            linksRed = linksRed + tonumber(safetyRead(f))
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(linksRed))
        source = obs.obs_get_source_by_name("Red Links"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Links Blue
        local linksBlue = 0
        local f = io.open(dataDirectory.."/TLinkC_B.txt", "rb")
        if f then
            linksBlue = linksBlue + tonumber(safetyRead(f))
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(linksBlue))
        source = obs.obs_get_source_by_name("Blue Links"..sourceStr)
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
        if (linksRed >= SUSTAINABILITY_BONUS_RP) then
            redRP = redRP + 1
        end
        if (chargeStationRed >= ACTIVATION_BONUS_RP) then
            redRP = redRP + 1
        end
        
        local blueRP = 0
        if (linksBlue >= SUSTAINABILITY_BONUS_RP) then
            blueRP = blueRP + 1
        end
        if (chargeStationBlue >= ACTIVATION_BONUS_RP) then
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
	return "Syncs FRC Sim Charged Up game state to OBS text sources"
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
