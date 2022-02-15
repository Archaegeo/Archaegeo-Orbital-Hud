-- NOTE: If userScreen is set, it is added to the svg displayed by the main hud's setScreen call.


function userOnStart(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1)
    --Startup stuff would go here, called at end of normal startup
end

function userOnFlush(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1)
    --Flush code goes here, called at end of normal flush - Remember only flight physics stuff should go in OnFlush.
end

function userOnUpdate(Nav, c, u, s, atlas, radar_1, radar_2, vBooster,  antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1)
    -- Update code goes here, called at end of normal update. - Remember onUpdate executes 60 times per second or your FPS rate, whichever is lower.
end

function userOnStop(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1)
    -- on Stop code goes here, called at end of normal onStop
end

function userControlStart(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, action)
    -- Control start event, called when a user key is pressed, action is the key. - This will NOT override but will support addition action for a key.
end

function userControlLoop(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, action)
    -- Control start event, called when a user key is held down, action is the key - This will NOT override but will support addition action for a key
end

function userControlStop(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, action)
    -- Control stop event, called when a user key is released, action is the key - This will NOT override but will support addition action for a key
end

function userControlInput(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, text)
    -- Control Input event, called when user types in lua chat, text is the typed input
end

function userRadarEnter(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, id)
    -- Called if active radar gets an OnEnter event (something detected), id is the passed detection
end

function userRadarLeave(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, id)
    -- Called if active radar gets an OnLeave event (something detected), id is the passed detection
end

function userOnTick(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, timerId)
    -- Called when a tick that has been set up (unit.setTimer("tickName", ticktime)) fires, timerId is the tick name
    -- example:  if timerId == "myTickName" then do things end
end
