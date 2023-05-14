-- -------------------------------------------------------------- --
--       APC20 LED Feedback - GrandMA3 LUA Script by Niyada       --
-- -------------------------------------------------------------- --
--                                                                --
-- This script will turn on the LEDs of the APC20, depending on   --
-- the assigned Objects of the executors.                         --
--                                                                --
-- This was inspired by GLAD's MidiFeedbackLoop from 2016 for     --
-- GrandMA2.                                                      --
--                                                                --
-- -------------------------------------------------------------- --
-- See my GitHub for more information:                            --
-- https://github.com/Niyada                                      --
-- -------------------------------------------------------------- --


-- -------------------------------------------------------------- --
--                      Configuration                             --
-- -------------------------------------------------------------- --

-- row variables for quicker configuration, change/remove as needed
local execRow10x       = 48
local execRow20x       = 49
local execRow20xActive = 50
local execRow30x       = 54
local execRow401       = 53
local execRow416       = 55
local execRow316       = 56
local execRow431       = 57

-- mapping of midi notes for leds to turn on
-- when a fader executor (101 Through 10x) is active
-- Syntax: [ExecID] = {MidiChannel, MidiNote}
local execMapping = {
    [101] = {1, execRow10x},
    [102] = {2, execRow10x},
    [103] = {3, execRow10x},
    [104] = {4, execRow10x},
    [105] = {5, execRow10x},
    [106] = {6, execRow10x},
    [107] = {7, execRow10x},
    [108] = {8, execRow10x},

    [201] = {1,execRow20x},
    [202] = {2,execRow20x},
    [203] = {3,execRow20x},
    [204] = {4,execRow20x},
    [205] = {5,execRow20x},
    [206] = {6,execRow20x},
    [207] = {7,execRow20x},
    [208] = {8,execRow20x},
    
    [302] = {2, execRow30x},
    [301] = {1, execRow30x},
    [303] = {3, execRow30x},
    [304] = {4, execRow30x},
    [305] = {5, execRow30x},
    [306] = {6, execRow30x},
    [307] = {7, execRow30x},
    [308] = {8, execRow30x},

    [401] = {1, execRow401},
    [402] = {2, execRow401},
    [403] = {3, execRow401},
    [404] = {4, execRow401},
    [405] = {5, execRow401},
    [406] = {6, execRow401},
    [407] = {7, execRow401},
    [408] = {8, execRow401},

    [416] = {1, execRow416},
    [417] = {2, execRow416},
    [418] = {3, execRow416},
    [419] = {4, execRow416},
    [420] = {5, execRow416},
    [421] = {6, execRow416},
    [422] = {7, execRow416},
    [423] = {8, execRow416},

    [316] = {1, execRow316},
    [317] = {2, execRow316},
    [318] = {3, execRow316},
    [319] = {4, execRow316},
    [320] = {5, execRow316},
    [321] = {6, execRow316},
    [322] = {7, execRow316},
    [323] = {8, execRow316},

    [431] = {1, execRow431},
    [432] = {2, execRow431},
    [433] = {3, execRow431},
    [434] = {4, execRow431},
    [435] = {5, execRow431},
    [436] = {6, execRow431},
    [437] = {7, execRow431},
    [438] = {8, execRow431},
}

-- mapping of midi notes for leds to turn on
-- when a fader executor (201 Through 20x) is active
local faderExecActiveLedMapping = {
    [201] = {1, execRow20xActive},
    [202] = {2, execRow20xActive},
    [203] = {3, execRow20xActive},
    [204] = {4, execRow20xActive},
    [205] = {5, execRow20xActive},
    [206] = {6, execRow20xActive},
    [207] = {7, execRow20xActive},
    [208] = {8, execRow20xActive},
}

-- delay between each main loop execution
-- IMPORTANT: setting this too low may cause performance issues
--            running your lights is more important than a fast LED feedback
local delay = 0.0

-- -------------------------------------------------------------- --
--                           constants                            --
-- -------------------------------------------------------------- --

local velocity = {
    OFF          = 0,
    GREEN        = 1,
    GREEN_FLASH  = 2,
    RED          = 3,
    RED_FLASH    = 4,
    ORANGE       = 5,
    ORANGE_FLASH = 6,
}



-- -------------------------------------------------------------- --
--                         helper functions                       --
-- -------------------------------------------------------------- --

-- custom function to map an executor's attributes to a midi velocity
local assObjType2Velocity = function( curExec )
    local isSequence = curExec.assObj == "Sequence"
    local isFlash    = curExec.obj.key == "Flash"
    local isActive   = curExec.active

    if isSequence then
        if isFlash then
            return isActive and velocity.RED or velocity.ORANGE
        else
            return isActive and velocity.ORANGE_FLASH or velocity.ORANGE
        end
    else
        if isFlash then
            return isActive and velocity.RED or velocity.GREEN
        else
            return isActive and velocity.GREEN_FLASH or velocity.GREEN
        end
    end
end


-- custom function to check if an executor is a fader
isFader = function( exec )
    return exec >= 201 and exec <= 208
end

-- custom function to send midi messages
setNoteLed = function( c, n, v)
	Cmd( "SendMIDI \"Note\" " .. c .. "/" .. n .. " " .. v )
end

-- custom function to compare two executor objects
execsAreEqual = function( exec1, exec2 )
    if exec1 == nil or exec2 == nil then
        return false
    end
    return exec1.id == exec2.id
       and exec1.obj == exec2.obj
       and exec1.class == exec2.class
       and exec1.active == exec2.active
       and exec1.assObj == exec2.assObj
end



-- -------------------------------------------------------------- --
--                   main execution loop                          --
-- -------------------------------------------------------------- --


start = function ()
    -- create a cache table, to only send midi messages when
    -- the executor or its playback state has changed
    cache = {}

    -- start the main loop
	while true do
        -- update the exutor faders leds
		checkForUpdates()
		
        -- wait for a while
		coroutine.yield(delay)
	end
end


checkForUpdates = function()

    -- loop over all mapped executors
	for exec, midiAdr in pairs(execMapping) do
        
        -- get all relevant data of the executor we're currently looking at 
        local curExecObj      = GetExecutor( exec )
        local curExecIsActive = curExecObj ~= nil and curExecObj:GetAssignedObj():HasActivePlayback() or false
        local curExecAssObj   = curExecObj        and curExecObj:GetAssignedObj():GetClass()          or nil


        -- build a table with all relevant data of the current executor
        local curExec = {
            id      = exec,              -- Executor ID, e.g. 101, 201, 301, 401
            obj     = curExecObj,        -- Executor handle
            active  = curExecIsActive,   -- true, false
            assObj  = curExecAssObj,     -- Preset, Sequence, Master
            fader   = isFader( exec ),   -- true, false
            midiAdr = midiAdr            -- Midi Channel and Note
        }

        -- check if any of the executor's attributes has changed
        if execsAreEqual( curExec, cache[exec] ) == false then

            -- update the cache
            cache[exec] = curExec
            
            -- update the led
            updateLED( curExec )
        end
	end
end



updateLED = function( curExec )
    if curExec.obj == nil then
        -- executor is empty, turn of led
        setNoteLed( curExec.midiAdr[1], curExec.midiAdr[2], velocity.OFF )
        if curExec.fader then
            setNoteLed( faderExecActiveLedMapping[curExec.id][1], faderExecActiveLedMapping[curExec.id][2], velocity.OFF )
        end
    else
        -- current executor has an object assigned

        if curExec.active then
            setNoteLed( curExec.midiAdr[1], curExec.midiAdr[2], assObjType2Velocity( curExec ) )
            if curExec.fader then
                setNoteLed( faderExecActiveLedMapping[curExec.id][1], faderExecActiveLedMapping[curExec.id][2], velocity.RED )
            end
        else
            setNoteLed( curExec.midiAdr[1], curExec.midiAdr[2], assObjType2Velocity( curExec ) )
            if curExec.fader then
                setNoteLed( faderExecActiveLedMapping[curExec.id][1], faderExecActiveLedMapping[curExec.id][2], velocity.OFF )
            end

        end
    end 
end

return start