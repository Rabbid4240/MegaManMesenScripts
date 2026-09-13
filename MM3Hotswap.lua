-- Quick Weapon Switching for Mega Man 3
-- From MM3 onward, unlocked weaopns are no longer determined by a binary reading
-- But instead if the 7th bit in a certain address is 1 (if the byte is above 80)
-- MM3 is CHR-RAM so straight up replacing the gfx in PPU won't work, instead just change which bank it uses

-- A0 = Weapon Equipped
-- A2 = Mega Buster Ammo (00 is locked, 80-9C is unlocked)
-- A3 = Gemini Laser Ammo
-- A4 = Needle Cannon Ammo
-- A5 = Hard Knuckle Ammo
-- A6 = Magnet Missile Ammo
-- A7 = Top Spin Ammo
-- A8 = Search Snake Ammo
-- A9 = Rush Coin Ammo
-- AA = Spark Shock Ammo
-- AB = Rush Marine Ammo
-- AC = Shadow Blade Ammo
-- AD = Rush Jet Ammo

timer = 0

NEAmmo = 0
MAAmmo = 0
GEAmmo = 0
HAAmmo = 0
TOAmmo = 0
SNAmmo = 0
SPAmmo = 0
SHAmmo = 0
RCAmmo = 0
RJAmmo = 0
RMAmmo = 0

pause = 0

weapon = 0
-- 0 = Mega Buster
-- 1 = Gemini Laser
-- 2 = Needle Cannon
-- 3 = Hard Knuckle
-- 4 = Magnet Missile
-- 5 = Top Spin
-- 6 = Search Snake
-- 7 = Rush Coil
-- 8 = Spark Shock
-- 9 = Rush Marine
-- 10 = Shadow Blade
-- 11 = Rush Jet

spriteFlag1 = 0
spriteFlag2 = 0
spriteFlag3 = 0
playerAnim = 0 -- actually the sprite ID byte but thankfully all of mega's animations are under 23
isActive = 0
refilling = 0
paused = 0
IRQ = 0

function updateInfo()
	NEAmmo = emu.read(0xA4, emu.memType.nesInternalRam, true)
	MAAmmo = emu.read(0xA6, emu.memType.nesInternalRam, true)
	GEAmmo = emu.read(0xA3, emu.memType.nesInternalRam, true)
	HAAmmo = emu.read(0xA5, emu.memType.nesInternalRam, true)
	TOAmmo = emu.read(0xA7, emu.memType.nesInternalRam, true)
	SNAmmo = emu.read(0xA8, emu.memType.nesInternalRam, true)
	SPAmmo = emu.read(0xAA, emu.memType.nesInternalRam, true)
	SHAmmo = emu.read(0xAC, emu.memType.nesInternalRam, true)
	RCAmmo = emu.read(0xA9, emu.memType.nesInternalRam, true)
	RJAmmo = emu.read(0xAD, emu.memType.nesInternalRam, true)
	RMAmmo = emu.read(0xAB, emu.memType.nesInternalRam, true)
	weapon = emu.read(0xA0, emu.memType.nesInternalRam, true)
	pause = emu.read(0x78, emu.memType.nesInternalRam, true)
	spriteFlag0 = emu.read(0x301, emu.memType.nesInternalRam, true)
	spriteFlag1 = emu.read(0x302, emu.memType.nesInternalRam, true)
	spriteFlag2 = emu.read(0x303, emu.memType.nesInternalRam, true)
	playerAnim = emu.read(0x5C0, emu.memType.nesInternalRam, true)
	isActive = emu.read(0x65, emu.memType.nesInternalRam, true)
	refilling = emu.read(0x58, emu.memType.nesInternalRam, true)
	IRQ = emu.read(0xF8, emu.memType.nesInternalRam, true)
	emu.drawString(0, 0, weapon)
	emu.drawString(0, 10, timer)
	emu.drawString(0, 20, playerAnim)
	emu.drawString(0, 30, isActive)
	emu.drawString(0, 40, refilling)
	emu.drawString(0, 50, IRQ)
	if pause == 0 then
		if weapon == 1 then
			emu.drawString(18, 83, "GE")
		end
		if weapon == 2 then
			emu.drawString(18, 83, "NE")
		end
		if weapon == 3 then
			emu.drawString(18, 83, "HA")
		end
		if weapon == 4 then
			emu.drawString(18, 83, "MA")
		end
		if weapon == 5 then
			emu.drawString(18, 83, "TO")
		end
		if weapon == 6 then
			emu.drawString(18, 83, "SN")
		end
		if weapon == 7 then
			emu.drawString(18, 83, "RC")
		end
		if weapon == 8 then
			emu.drawString(18, 83, "SP")
		end
		if weapon == 9 then
			emu.drawString(18, 83, "RM")
		end
		if weapon == 10 then
			emu.drawString(18, 83, "SH")
		end
		if weapon == 11 then
			emu.drawString(18, 83, "RJ")
		end
	end
end

function input()
	timer = timer - 1
	if timer < 0 then
		timer = 0
	end
	if emu.isKeyPressed("S") and timer == 0 and spriteFlag0 == 0 and spriteFlag1 == 0 and spriteFlag2 == 0 and playerAnim < 23 and isActive == 60 and refilling == 0 and IRQ == 0 then
		timer = 10
		swapRight()
		checkLockedRight()
		emu.write(0xA0, weapon, emu.memType.nesInternalRam)
		changeGFX()
		emu.write(0x18, 1, emu.memType.nesInternalRam) -- update pallete
		emu.write(0x1B, 1, emu.memType.nesInternalRam) -- update CHR
	end
	if emu.isKeyPressed("A") and timer == 0 and spriteFlag0 == 0 and spriteFlag1 == 0 and spriteFlag2 == 0 and playerAnim < 23 and isActive == 60 and refilling == 0 and IRQ == 0 then
		timer = 10
		swapLeft()
		checkLockedLeft()
		emu.write(0xA0, weapon, emu.memType.nesInternalRam)
		changeGFX()
		emu.write(0x18, 1, emu.memType.nesInternalRam)
		emu.write(0x1B, 1, emu.memType.nesInternalRam)
	end
end

function checkLockedRight()
	if weapon == 2 and NEAmmo == 0 then
		weapon = 4
	end
	if weapon == 4 and MAAmmo == 0 then
		weapon = 1
	end
	if weapon == 1 and GEAmmo == 0 then
		weapon = 3
	end
	if weapon == 3 and HAAmmo == 0 then
		weapon = 5
	end
	if weapon == 5 and TOAmmo == 0 then
		weapon = 6
	end
	if weapon == 6 and SNAmmo == 0 then
		weapon = 8
	end
	if weapon == 8 and SPAmmo == 0 then
		weapon = 10
	end
	if weapon == 10 and SHAmmo == 0 then
		weapon = 7
	end
	if weapon == 7 and RCAmmo == 0 then
		weapon = 9
	end
	if weapon == 9 and RMAmmo == 0 then
		weapon = 11
	end
	if weapon == 11 and RJAmmo == 0 then
		weapon = 0
	end
end

function checkLockedLeft()
	if weapon == 11 and RJAmmo == 0 then
		weapon = 9
	end
	if weapon == 9 and RMAmmo == 0 then
		weapon = 7
	end
	if weapon == 7 and RCAmmo == 0 then
		weapon = 10
	end
	if weapon == 10 and SHAmmo == 0 then
		weapon = 8
	end
	if weapon == 8 and SPAmmo == 0 then
		weapon = 6
	end
	if weapon == 6 and SNAmmo == 0 then
		weapon = 5
	end
	if weapon == 5 and TOAmmo == 0 then
		weapon = 3
	end
	if weapon == 3 and HAAmmo == 0 then
		weapon = 1
	end
	if weapon == 1 and GEAmmo == 0 then
		weapon = 4
	end
	if weapon == 4 and MAAmmo == 0 then
		weapon = 2
	end
	if weapon == 2 and NEAmmo == 0 then
		weapon = 0
	end
end

function swapRight()
	if weapon == 0 then
		weapon = 2
	elseif weapon == 2 then
		weapon = 4
	elseif weapon == 4 then
		weapon = 1
	elseif weapon == 1 then
		weapon = 3
	elseif weapon == 3 then
		weapon = 5
	elseif weapon == 5 then
		weapon = 6
	elseif weapon == 6 then
		weapon = 8
	elseif weapon == 8 then
		weapon = 10
	elseif weapon == 10 then
		weapon = 7
	elseif weapon == 7 then
		weapon = 9
	elseif weapon == 9 then
		weapon = 11
	elseif weapon == 11 then
		weapon = 0
	end
end

function swapLeft()
	if weapon == 0 then
		weapon = 11
	elseif weapon == 11 then
		weapon = 9
	elseif weapon == 9 then
		weapon = 7
	elseif weapon == 7 then
		weapon = 10
	elseif weapon == 10 then
		weapon = 8
	elseif weapon == 8 then
		weapon = 6
	elseif weapon == 6 then
		weapon = 5
	elseif weapon == 5 then
		weapon = 3
	elseif weapon == 3 then
		weapon = 1
	elseif weapon == 1 then
		weapon = 4
	elseif weapon == 4 then
		weapon = 2
	elseif weapon == 2 then
		weapon = 0
	end
end

function changeGFX()
	if weapon == 0 then
		emu.write(0x612, 0x2C, emu.memType.nesInternalRam)
		emu.write(0x613, 0x11, emu.memType.nesInternalRam)
		emu.write(0xA1, 0x00, emu.memType.nesInternalRam) -- set weapon menu selected slot
		emu.write(0xB1, 0x00, emu.memType.nesInternalRam) -- set weapon gauge
		emu.write(0xB4, 0x00, emu.memType.nesInternalRam) -- set weapon menu page 
		emu.write(0xB5, 0x00, emu.memType.nesInternalRam) -- resets shots until wep decrease
		emu.write(0xEB, 0x01, emu.memType.nesInternalRam) -- update CHR graphics
	elseif weapon == 1 then
		emu.write(0x612, 0x30, emu.memType.nesInternalRam)
		emu.write(0x613, 0x21, emu.memType.nesInternalRam)
		emu.write(0xA1, 0x01, emu.memType.nesInternalRam)
		emu.write(0xB1, 0x81, emu.memType.nesInternalRam)
		emu.write(0xB4, 0x00, emu.memType.nesInternalRam)
		emu.write(0xB5, 0x00, emu.memType.nesInternalRam)
		emu.write(0xEB, 0x02, emu.memType.nesInternalRam)
	elseif weapon == 2 then
		emu.write(0x612, 0x30, emu.memType.nesInternalRam)
		emu.write(0x613, 0x17, emu.memType.nesInternalRam)
		emu.write(0xA1, 0x02, emu.memType.nesInternalRam)
		emu.write(0xB1, 0x82, emu.memType.nesInternalRam)
		emu.write(0xB4, 0x00, emu.memType.nesInternalRam)
		emu.write(0xB5, 0x00, emu.memType.nesInternalRam)
		emu.write(0xEB, 0x07, emu.memType.nesInternalRam)
	elseif weapon == 3 then
		emu.write(0x612, 0x10, emu.memType.nesInternalRam)
		emu.write(0x613, 0x01, emu.memType.nesInternalRam)
		emu.write(0xA1, 0x03, emu.memType.nesInternalRam)
		emu.write(0xB1, 0x83, emu.memType.nesInternalRam)
		emu.write(0xB4, 0x00, emu.memType.nesInternalRam)
		emu.write(0xB5, 0x00, emu.memType.nesInternalRam)
		emu.write(0xEB, 0x03, emu.memType.nesInternalRam)
	elseif weapon == 4 then
		emu.write(0x612, 0x10, emu.memType.nesInternalRam)
		emu.write(0x613, 0x16, emu.memType.nesInternalRam)
		emu.write(0xA1, 0x04, emu.memType.nesInternalRam)
		emu.write(0xB1, 0x84, emu.memType.nesInternalRam)
		emu.write(0xB4, 0x00, emu.memType.nesInternalRam)
		emu.write(0xB5, 0x00, emu.memType.nesInternalRam)
		emu.write(0xEB, 0x01, emu.memType.nesInternalRam)
	elseif weapon == 5 then
		emu.write(0x612, 0x36, emu.memType.nesInternalRam)
		emu.write(0x613, 0x00, emu.memType.nesInternalRam)
		emu.write(0xA1, 0x05, emu.memType.nesInternalRam)
		emu.write(0xB1, 0x85, emu.memType.nesInternalRam)
		emu.write(0xB4, 0x00, emu.memType.nesInternalRam)
		emu.write(0xB5, 0x00, emu.memType.nesInternalRam)
		emu.write(0xEB, 0x07, emu.memType.nesInternalRam)
	elseif weapon == 6 then
		emu.write(0x612, 0x30, emu.memType.nesInternalRam)
		emu.write(0x613, 0x19, emu.memType.nesInternalRam)
		emu.write(0xA1, 0x00, emu.memType.nesInternalRam)
		emu.write(0xB1, 0x86, emu.memType.nesInternalRam)
		emu.write(0xB4, 0x06, emu.memType.nesInternalRam)
		emu.write(0xB5, 0x00, emu.memType.nesInternalRam)
		emu.write(0xEB, 0x01, emu.memType.nesInternalRam)
	elseif weapon == 7 then
		emu.write(0x612, 0x30, emu.memType.nesInternalRam)
		emu.write(0x613, 0x15, emu.memType.nesInternalRam)
		emu.write(0xA1, 0x01, emu.memType.nesInternalRam)
		emu.write(0xB1, 0x87, emu.memType.nesInternalRam)
		emu.write(0xB4, 0x06, emu.memType.nesInternalRam)
		emu.write(0xB5, 0x00, emu.memType.nesInternalRam)
		emu.write(0xEB, 0x04, emu.memType.nesInternalRam)
	elseif weapon == 8 then
		emu.write(0x612, 0x30, emu.memType.nesInternalRam)
		emu.write(0x613, 0x26, emu.memType.nesInternalRam)
		emu.write(0xA1, 0x02, emu.memType.nesInternalRam)
		emu.write(0xB1, 0x88, emu.memType.nesInternalRam)
		emu.write(0xB4, 0x06, emu.memType.nesInternalRam)
		emu.write(0xB5, 0x00, emu.memType.nesInternalRam)
		emu.write(0xEB, 0x06, emu.memType.nesInternalRam)
	elseif weapon == 9 then
		emu.write(0x612, 0x30, emu.memType.nesInternalRam)
		emu.write(0x613, 0x15, emu.memType.nesInternalRam)
		emu.write(0xA1, 0x03, emu.memType.nesInternalRam)
		emu.write(0xB1, 0x89, emu.memType.nesInternalRam)
		emu.write(0xB4, 0x06, emu.memType.nesInternalRam)
		emu.write(0xB5, 0x00, emu.memType.nesInternalRam)
		emu.write(0xEB, 0x02, emu.memType.nesInternalRam)
	elseif weapon == 10 then
		emu.write(0x612, 0x34, emu.memType.nesInternalRam)
		emu.write(0x613, 0x14, emu.memType.nesInternalRam)
		emu.write(0xA1, 0x04, emu.memType.nesInternalRam)
		emu.write(0xB1, 0x8A, emu.memType.nesInternalRam)
		emu.write(0xB4, 0x06, emu.memType.nesInternalRam)
		emu.write(0xB5, 0x00, emu.memType.nesInternalRam)
		emu.write(0xEB, 0x06, emu.memType.nesInternalRam)
	elseif weapon == 11 then
		emu.write(0x612, 0x30, emu.memType.nesInternalRam)
		emu.write(0x613, 0x15, emu.memType.nesInternalRam)
		emu.write(0xA1, 0x05, emu.memType.nesInternalRam)
		emu.write(0xB1, 0x8B, emu.memType.nesInternalRam)
		emu.write(0xB4, 0x06, emu.memType.nesInternalRam)
		emu.write(0xB5, 0x00, emu.memType.nesInternalRam)
		emu.write(0xEB, 0x03, emu.memType.nesInternalRam)
	end
end

emu.addEventCallback(input, emu.eventType.inputPolled);
emu.addEventCallback(updateInfo, emu.eventType.endFrame);