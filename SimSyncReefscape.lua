--[[
    OBS Lua script
    Syncs FRC Sim game states with OBS text sources (for up to 4 independent servers)
    Designed for FRC 2025 Reefscape
    By Nicholas Bottone
--]]

--[[
uto_B.txt        BlueADJ.txt       MinFouls_B.txt    Tele_l2_B.txt
Auto_l1_B.txt     End_B.txt         MinFouls_R.txt    Tele_l2_R.txt
Auto_l1_R.txt     End_deep_B.txt    NetFPS.txt        Tele_l3_B.txt
Auto_l2_B.txt     End_deep_R.txt    OPR.txt           Tele_l3_R.txt
Auto_l2_R.txt     End_park_B.txt    RedADJ.txt        Tele_l4_B.txt
Auto_l3_B.txt     End_park_R.txt    Resets_B.txt      Tele_l4_R.txt
Auto_l3_R.txt     End_R.txt         Resets_R.txt      Tele_net_B.txt
Auto_l4_B.txt     End_shallow_B.txt Score_B.txt       Tele_net_R.txt
Auto_l4_R.txt     End_shallow_R.txt Score_R.txt       Tele_proc_B.txt
Auto_leave_B.txt  GameState.txt     Tele_B.txt        Tele_proc_R.txt
Auto_leave_R.txt  MajFouls_B.txt    Tele_l1_B.txt     Tele_R.txt
Auto_R.txt        MajFouls_R.txt    Tele_l1_R.txt     Timer.txt
--]]

local AUTO_RP_CORAL_SCORED = 6
local AUTO_RP_LEAVE_ROBOTS = 3
local CORAL_RP_CORAL_PER_LEVEL = 9
local BARGE_RP_BARGE_POINTS = 24

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
            source = obs.obs_get_source_by_name("Blue Score"..sourceStr)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
            f:close()
        end

        -- Auto Red
        local redAutoCoral = 0
        local redCoralPoints = 0
        local redCoralL1 = 0
        local redCoralL2 = 0
        local redCoralL3 = 0
        local redCoralL4 = 0
        local f = io.open(dataDirectory.."/Auto_l1_R.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            redAutoCoral = redAutoCoral + coral
            redCoralPoints = redCoralPoints + (coral * 3)
            redCoralL1 = coral
            f:close()
        end
        f = io.open(dataDirectory.."/Auto_l2_R.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            redAutoCoral = redAutoCoral + coral
            redCoralPoints = redCoralPoints + (coral * 4)
            redCoralL2 = coral
            f:close()
        end
        f = io.open(dataDirectory.."/Auto_l3_R.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            redAutoCoral = redAutoCoral + coral
            redCoralPoints = redCoralPoints + (coral * 6)
            redCoralL3 = coral
            f:close()
        end
        f = io.open(dataDirectory.."/Auto_l4_R.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            redAutoCoral = redAutoCoral + coral
            redCoralPoints = redCoralPoints + (coral * 7)
            redCoralL4 = coral
            f:close()
        end

        -- Auto Blue
        local blueAutoCoral = 0
        local blueCoralPoints = 0
        local blueCoralL1 = 0
        local blueCoralL2 = 0
        local blueCoralL3 = 0
        local blueCoralL4 = 0
        local f = io.open(dataDirectory.."/Auto_l1_B.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            blueAutoCoral = blueAutoCoral + coral
            blueCoralPoints = blueCoralPoints + (coral * 3)
            blueCoralL1 = coral
            f:close()
        end
        f = io.open(dataDirectory.."/Auto_l2_B.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            blueAutoCoral = blueAutoCoral + coral
            blueCoralPoints = blueCoralPoints + (coral * 4)
            blueCoralL2 = coral
            f:close()
        end
        f = io.open(dataDirectory.."/Auto_l3_B.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            blueAutoCoral = blueAutoCoral + coral
            blueCoralPoints = blueCoralPoints + (coral * 6)
            blueCoralL3 = coral
            f:close()
        end
        f = io.open(dataDirectory.."/Auto_l4_B.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            blueAutoCoral = blueAutoCoral + coral
            blueCoralPoints = blueCoralPoints + (coral * 7)
            blueCoralL4 = coral
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

        -- Penalty Red
        local redPenalty = 0
        local f = io.open(dataDirectory.."/MajFouls_R.txt", "rb")
        if f then
            redPenalty = redPenalty + (tonumber(safetyRead(f)) * 6)
            f:close()
        end
        f = io.open(dataDirectory.."/MinFouls_R.txt", "rb")
        if f then
            redPenalty = redPenalty + (tonumber(safetyRead(f)) * 2)
            f:close()
        end
        f = io.open(dataDirectory.."/Resets_R.txt", "rb")
        if f then
            redPenalty = redPenalty + (tonumber(safetyRead(f)) * 6)
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(redPenalty))
        source = obs.obs_get_source_by_name("Red Penalty Points"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Penalty Blue
        local bluePenalty = 0
        local f = io.open(dataDirectory.."/MajFouls_B.txt", "rb")
        if f then
            bluePenalty = bluePenalty + (tonumber(safetyRead(f)) * 6)
            f:close()
        end
        f = io.open(dataDirectory.."/MinFouls_B.txt", "rb")
        if f then
            bluePenalty = bluePenalty + (tonumber(safetyRead(f)) * 2)
            f:close()
        end
        f = io.open(dataDirectory.."/Resets_B.txt", "rb")
        if f then
            bluePenalty = bluePenalty + (tonumber(safetyRead(f)) * 6)
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(bluePenalty))
        source = obs.obs_get_source_by_name("Blue Penalty Points"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

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

        -- Leave Red
        local redLeave = 0
        local f = io.open(dataDirectory.."/Auto_leave_R.txt", "rb")
        if f then
            redLeave = tonumber(safetyRead(f))
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(redLeave))
        source = obs.obs_get_source_by_name("Red Leave"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Leave Blue
        local blueLeave = 0
        local f = io.open(dataDirectory.."/Auto_leave_B.txt", "rb")
        if f then
            blueLeave = tonumber(safetyRead(f))
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(blueLeave))
        source = obs.obs_get_source_by_name("Blue Leave"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Coral Count Red
        local redTeleCoral = 0
        local f = io.open(dataDirectory.."/Tele_l1_R.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            redTeleCoral = redTeleCoral + coral
            redCoralPoints = redCoralPoints + (coral * 2)
            redCoralL1 = redCoralL1 + coral
            f:close()
        end
        f = io.open(dataDirectory.."/Tele_l2_R.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            redTeleCoral = redTeleCoral + coral
            redCoralPoints = redCoralPoints + (coral * 3)
            redCoralL2 = redCoralL2 + coral
            f:close()
        end
        f = io.open(dataDirectory.."/Tele_l3_R.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            redTeleCoral = redTeleCoral + coral
            redCoralPoints = redCoralPoints + (coral * 4)
            redCoralL3 = redCoralL3 + coral
            f:close()
        end
        f = io.open(dataDirectory.."/Tele_l4_R.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            redTeleCoral = redTeleCoral + coral
            redCoralPoints = redCoralPoints + (coral * 5)
            redCoralL4 = redCoralL4 + coral
            f:close()
        end
        local totalRedCoral = redAutoCoral + redTeleCoral

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(totalRedCoral))
        source = obs.obs_get_source_by_name("Red Coral Count"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Coral Points Red
        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(redCoralPoints))
        source = obs.obs_get_source_by_name("Red Coral Points"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Coral Levels Red
        local redCoralLevels = 0
        if redCoralL1 >= CORAL_RP_CORAL_PER_LEVEL then
            redCoralLevels = redCoralLevels + 1
        end
        if redCoralL2 >= CORAL_RP_CORAL_PER_LEVEL then
            redCoralLevels = redCoralLevels + 1
        end
        if redCoralL3 >= CORAL_RP_CORAL_PER_LEVEL then
            redCoralLevels = redCoralLevels + 1
        end
        if redCoralL4 >= CORAL_RP_CORAL_PER_LEVEL then
            redCoralLevels = redCoralLevels + 1
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(redCoralLevels))
        source = obs.obs_get_source_by_name("Red Coral Levels"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Coral Count Blue
        local blueTeleCoral = 0
        local f = io.open(dataDirectory.."/Tele_l1_B.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            blueTeleCoral = blueTeleCoral + coral
            blueCoralPoints = blueCoralPoints + (coral * 2)
            blueCoralL1 = blueCoralL1 + coral
            f:close()
        end
        f = io.open(dataDirectory.."/Tele_l2_B.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            blueTeleCoral = blueTeleCoral + coral
            blueCoralPoints = blueCoralPoints + (coral * 3)
            blueCoralL2 = blueCoralL2 + coral
            f:close()
        end
        f = io.open(dataDirectory.."/Tele_l3_B.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            blueTeleCoral = blueTeleCoral + coral
            blueCoralPoints = blueCoralPoints + (coral * 4)
            blueCoralL3 = blueCoralL3 + coral
            f:close()
        end
        f = io.open(dataDirectory.."/Tele_l4_B.txt", "rb")
        if f then
            local coral = tonumber(safetyRead(f))
            blueTeleCoral = blueTeleCoral + coral
            blueCoralPoints = blueCoralPoints + (coral * 5)
            blueCoralL4 = blueCoralL4 + coral
            f:close()
        end
        local totalBlueCoral = blueAutoCoral + blueTeleCoral
        
        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(totalBlueCoral))
        source = obs.obs_get_source_by_name("Blue Coral Count"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Coral Points Blue
        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(blueCoralPoints))
        source = obs.obs_get_source_by_name("Blue Coral Points"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Coral Levels Blue
        local blueCoralLevels = 0
        if blueCoralL1 >= CORAL_RP_CORAL_PER_LEVEL then
            blueCoralLevels = blueCoralLevels + 1
        end
        if blueCoralL2 >= CORAL_RP_CORAL_PER_LEVEL then
            blueCoralLevels = blueCoralLevels + 1
        end
        if blueCoralL3 >= CORAL_RP_CORAL_PER_LEVEL then
            blueCoralLevels = blueCoralLevels + 1
        end
        if blueCoralL4 >= CORAL_RP_CORAL_PER_LEVEL then
            blueCoralLevels = blueCoralLevels + 1
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(blueCoralLevels))
        source = obs.obs_get_source_by_name("Blue Coral Levels"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)
        
        -- Algae Count Red
        local redAlgaeCount = 0
        local redAlgaePoints = 0
        local f = io.open(dataDirectory.."/Tele_net_R.txt", "rb")
        if f then
            redAlgaeCount = tonumber(safetyRead(f))
            redAlgaePoints = (redAlgaeCount * 4)
            f:close()
        end
        f = io.open(dataDirectory.."/Tele_proc_R.txt", "rb")
        if f then
            local algae = tonumber(safetyRead(f))
            redAlgaeCount = redAlgaeCount + algae
            redAlgaePoints = redAlgaePoints + (algae * 6)
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(redAlgaeCount))
        source = obs.obs_get_source_by_name("Red Algae Count"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Algae Points Red
        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(redAlgaePoints))
        source = obs.obs_get_source_by_name("Red Algae Points"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Algae Blue
        local blueAlgaeCount = 0
        local blueAlgaePoints = 0
        local f = io.open(dataDirectory.."/Tele_net_B.txt", "rb")
        if f then
            blueAlgaeCount = tonumber(safetyRead(f))
            blueAlgaePoints = (blueAlgaeCount * 4)
            f:close()
        end
        f = io.open(dataDirectory.."/Tele_proc_B.txt", "rb")
        if f then
            local algae = tonumber(safetyRead(f))
            blueAlgaeCount = blueAlgaeCount + algae
            blueAlgaePoints = blueAlgaePoints + (algae * 6)
            f:close()
        end

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(blueAlgaeCount))
        source = obs.obs_get_source_by_name("Blue Algae Count"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Algae Points Blue
        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(blueAlgaePoints))
        source = obs.obs_get_source_by_name("Blue Algae Points"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Create RP List with emojis
        local redRPList = ""
        local blueRPList = ""
        local redRP = 0
        local blueRP = 0
        local redBonusRP = 0
        local blueBonusRP = 0

        -- Win RP (3 trophies for win, 1 for tie)
        if (tonumber(redScore) > tonumber(blueScore)) then
            -- Red Wins
            redRPList = redRPList .. "🏆🏆🏆"
            redRP = redRP + 3

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
        elseif (tonumber(redScore) < tonumber(blueScore)) then
            -- Blue Wins
            blueRPList = blueRPList .. "🏆🏆🏆"
            blueRP = blueRP + 3

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
        else
            -- Tie
            redRPList = redRPList .. "🏆"
            redRP = redRP + 1
            blueRPList = blueRPList .. "🏆"
            blueRP = blueRP + 1

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
        end

        -- Auto RP (robot emoji)
        if (redLeave == AUTO_RP_LEAVE_ROBOTS and redAutoCoral >= AUTO_RP_CORAL_SCORED) then
            redRPList = redRPList .. "🤖"
            redRP = redRP + 1
            redBonusRP = redBonusRP + 1
        end
        if (blueLeave == AUTO_RP_LEAVE_ROBOTS and blueAutoCoral >= AUTO_RP_CORAL_SCORED) then
            blueRPList = blueRPList .. "🤖"
            blueRP = blueRP + 1
            blueBonusRP = blueBonusRP + 1
        end

        -- Coral RP (reef emoji)
        if redCoralLevels >= 4 then
            redRPList = redRPList .. "🪸"
            redRP = redRP + 1
            redBonusRP = redBonusRP + 1
        end
        if blueCoralLevels >= 4 then
            blueRPList = blueRPList .. "🪸"
            blueRP = blueRP + 1
            blueBonusRP = blueBonusRP + 1
        end

        -- Barge RP (boat emoji)
        if (endRed >= BARGE_RP_BARGE_POINTS) then
            redRPList = redRPList .. "🚢"
            redRP = redRP + 1
            redBonusRP = redBonusRP + 1
        end
        if (endBlue >= BARGE_RP_BARGE_POINTS) then
            blueRPList = blueRPList .. "🚢"
            blueRP = blueRP + 1
            blueBonusRP = blueBonusRP + 1
        end

        -- Update RP List text sources
        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", redRPList)
        source = obs.obs_get_source_by_name("Red RP List"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", blueRPList)
        source = obs.obs_get_source_by_name("Blue RP List"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

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

        -- Bonus RP Red
        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(redBonusRP))
        source = obs.obs_get_source_by_name("Red Bonus RP"..sourceStr)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)

        -- Bonus RP Blue
        settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", tostring(blueBonusRP))
        source = obs.obs_get_source_by_name("Blue Bonus RP"..sourceStr)
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
    return "Syncs xRC Sim Reefscape game state to OBS text sources"
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
