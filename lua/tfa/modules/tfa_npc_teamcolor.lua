
-- Copyright (c) 2018-2022 TFA Base Devs

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local ENTMETA = FindMetaTable("Entity")
local PLYMETA = FindMetaTable("Player")
local NPCMETA = FindMetaTable("NPC")

local IsValid = ENTMETA.IsValid

local Alive = PLYMETA.Alive
local GetActiveWeapon = PLYMETA.GetActiveWeapon
local GetAimVector = PLYMETA.GetAimVector
local GetShootPos = PLYMETA.GetShootPos

local Disposition = NPCMETA.Disposition

local util_TraceLine = util.TraceLine
local MASK_SHOT = MASK_SHOT

if SERVER then
	util.AddNetworkString("TFA_NPC_DISP")

	local NPCDispCacheSV = {}
	local function PlayerPostThink(ply)
		if not Alive(ply) then return end

		local wep = GetActiveWeapon(ply)
		if not IsValid(wep) or not wep.IsTFAWeapon then return end

		if not NPCDispCacheSV[ply] then
			NPCDispCacheSV[ply] = {}
		end

		local tr = {}
		tr.start = GetShootPos(ply)
		tr.endpos = tr.start + GetAimVector(ply) * 0xffff
		tr.filter = ply
		tr.mask = MASK_SHOT
		local targent = util_TraceLine(tr).Entity

		if IsValid(targent) and type(targent) == "NPC" then
			local disp = Disposition(targent, ply)

			if not NPCDispCacheSV[ply][targent] or NPCDispCacheSV[ply][targent] ~= disp then
				NPCDispCacheSV[ply][targent] = disp

				net.Start("TFA_NPC_DISP")
				net.WriteEntity(targent)
				net.WriteUInt(disp, 3)
				net.Send(ply)
			end
		end
	end

	hook.Add("PlayerPostThink", "TFA_NPCDispositionSync", PlayerPostThink)
else
	local NPCDispCacheSV = {}
	net.Receive("TFA_NPC_DISP", function()
		local ent = net.ReadEntity()
		local disp = net.ReadUInt(3)

		NPCDispCacheSV[ent] = disp
	end)

	function TFA.GetNPCDisposition(ent)
		return NPCDispCacheSV[ent]
	end
end