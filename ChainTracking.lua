local offset = 0x56450E
local offset2 = 0x56454E

local continue = 0x29F8C80 - offset2

local canExecute = false
local prevBlack = 0
local prevContinue = 0
local acquired_pages = 0
local current_pages = 0
local used_pages = 0

bool_to_number={ [true]=1, [false]=0 }

function has_valor()
    return bool_to_number[ReadByte(Save+0x36C0) & 0x02 > 0]
end

function has_wisdom()
    return bool_to_number[ReadByte(Save+0x36C0) & 0x04 > 0]
end

function has_limit()
    return bool_to_number[ReadByte(Save+0x36CA) & 0x08 > 0]
end

function has_master()
    return bool_to_number[ReadByte(Save+0x36C0) & 0x40 > 0]
end

function has_final()
    return bool_to_number[ReadByte(Save+0x36C0) & 0x10 > 0]
end

function proof_count()
    return ReadByte(Save+0x36B2) + ReadByte(Save+0x36B3) + ReadByte(Save+0x36B4)
end

function visit_lock_count()
    return ReadByte(Save+0x35B3) + ReadByte(Save+0x35B4) + ReadByte(Save+0x35B5) + ReadByte(Save+0x35B6) + ReadByte(Save+0x35AE) + ReadByte(Save+0x35AF) + ReadByte(Save+0x35C0) + ReadByte(Save+0x35C2) + ReadByte(Save+0x3643) + ReadByte(Save+0x3649) + ReadByte(Save+0x364A)
end

function page_count()
    return current_pages + used_pages-- current pages + used pages
end


function Events(M,B,E) --Check for Map, Btl, and Evt
    return ((Map == M or not M) and (Btl == B or not B) and (Evt == E or not E))
    end

function _OnInit()
	if GAME_ID == 0x431219CC and ENGINE_TYPE == "BACKEND" then
		canExecute = true
		Save = 0x09A7070 - offset
        Now = 0x0714DB8 - 0x56454E
	else
		ConsolePrint("KH2 not detected, not running script")
	end
end

function _OnFrame()
	World  = ReadByte(Now+0x00)
	Room   = ReadByte(Now+0x01)
	Place  = ReadShort(Now+0x00)
	Door   = ReadShort(Now+0x02)
	Map    = ReadShort(Now+0x04)
	Btl    = ReadShort(Now+0x06)
	Evt    = ReadShort(Now+0x08)
    if Place == 0x2002 and Events(0x01,Null,0x01) then --Station of Serenity Weapons
        local f = io.open("used_pages.txt", "w")
        f:write(0)
        f:close()
        current_pages = ReadByte(Save+0x3598)
        used_pages = 0
        acquired_pages = current_pages
    end
	if canExecute then
		if ReadInt(continue+0xC) ~= prevContinue and ReadByte(0x711438-offset2) == 0 then
            if ReadByte(Save+0x3598) ~= current_pages then-- we either got a new page, or consumed one
                if current_pages < ReadByte(Save+0x3598) then -- got new page, save it
                    acquired_pages = acquired_pages + 1
                    current_pages = ReadByte(Save+0x3598)
                else -- used a page, account it
                    current_pages = ReadByte(Save+0x3598)
                    used_pages = used_pages + 1
                    local f = io.open("used_pages.txt", "w")
                    f:write(used_pages)
                    f:close()
                end
            end
			local f = io.open("chain_count.txt", "w")
			f:write(has_valor()+has_wisdom()+has_limit()+has_master()+has_final()+proof_count()+visit_lock_count()+page_count())
			f:close()
		end
		prevContinue = ReadInt(continue+0xC)
	end
end
