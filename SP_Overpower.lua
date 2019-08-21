
function SP_OP_Split(s,t)
	local l = {n=0}
	local f = function (s)
		l.n = l.n + 1
		l[l.n] = s
	end
	local p = "%s*(.-)%s*"..t.."%s*"
	s = string.gsub(s,"^%s+","")
	s = string.gsub(s,"%s+$","")
	s = string.gsub(s,p,f)
	l.n = l.n + 1
	l[l.n] = string.gsub(s,"(%s%s*)$","")
	return l
end


SP_OP_TimeLeft = 0.0
SP_OP_CDTime = 0.0
SP_OP_Name = nil


function SP_OP_Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("[OP] "..msg, 0.7, 0.4, 1)
end

function SP_OP_GetSpellID(name)
	local spellID = 1
	local spellName = nil
	while 1 do
		spellName = GetSpellBookItemName(spellID, BOOKTYPE_SPELL)
		if spellName == name then
			return spellID
		end
		if spellName == nil then
			return nil
		end
		spellID = spellID + 1
	end
end

function SP_OP_Handler(msg)

	local vars = SP_OP_Split(msg, " ")
	local cmd, arg = vars[1], vars[2]

	if (cmd == "") then
		cmd = nil
	end
	if (arg == "") then
		arg = nil
	end

	if (cmd == nil and arg == nil) then
		SP_OP_Print("Chat commands: x, y, reset, show")
		SP_OP_Print("    Example: /op show")
		SP_OP_Print("    Example: /op y -150")
	elseif (cmd == "x") then
		if (arg ~= nil) then
			SP_OP_GS["x"] = arg
			SP_OP_SetPosition()
			SP_OP_Print("X set: "..arg)
		else
			SP_OP_Print("Current x: "..SP_OP_GS["x"]..". To change x say: /op x [number]")
		end
	elseif (cmd == "y") then
		if (arg ~= nil) then
			SP_OP_GS["y"] = arg
			SP_OP_SetPosition()
			SP_OP_Print("Y set: "..arg)
		else
			SP_OP_Print("Current y: "..SP_OP_GS["y"]..". To change y say: /op y [number]")
		end
	elseif (cmd == "reset") then
		SP_OP_ResetPosition()
	elseif (cmd == "show") then
		SP_OP_Reset("Target Name")
	end
end

function SP_OP_ResetPosition()
	SP_OP_GS["x"] = 0
	SP_OP_GS["y"] = -115
	SP_OP_SetPosition()
end
function SP_OP_SetPosition()
	SP_OP_Frame:SetPoint("CENTER", UIParent, "CENTER", SP_OP_GS["x"], SP_OP_GS["y"])
end

function SP_OP_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("COMBAT_LOG_EVENT")
	-- SP_OP_Frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
	-- SP_OP_Frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")

	SLASH_SPOVERPOWER1 = "/op"
	SLASH_SPOVERPOWER2 = "/spop"
	SlashCmdList["SPOVERPOWER"] = SP_OP_Handler
end

StaticPopupDialogs["SP_OP_Install"] = {
	text = "Thank you for installing SP_Overpower 1.3! Use the chat command /op to change the position of the timer bar.",
	button1 = "Yes",
	timeout = 0,
	hideOnEscape = 1,
};

function SP_OP_OnEvent(self, event, arg1)
	print(event, arg1)
	if (event == "ADDON_LOADED") then
		if (string.lower(arg1) == "sp_overpower") then

			if (SP_OP_GS == nil) then
				StaticPopup_Show("SP_OP_Install")
				SP_OP_GS = {
					["x"] = 0,
					["y"] = -115,
				}
			end

			SP_OP_SetPosition()
			SP_OP_UpdateDisplay()
			SP_OP_Frame:SetAlpha(0)

			SP_OP_Print("SP_Overpower 1.3 loaded. Options: /op")
		end

	elseif (event == "COMBAT_LOG_EVENT") then
		local timestamp = arg1
		local evt = arg2
		if not (evt == "SWING_MISSED") then
			return
		end
		local hideCaster = arg3
		local sourceGUID = arg4
		local sourceName = arg5
		local sourceFlags = arg6
		local sourceRaidFlags = arg7
		local destGUID = arg8
		local destName = arg9
		local destFlags = arg10
		local destRaidFlags = arg11
		local missType = arg12
		if missType == "DODGE" then
			SP_OP_Reset()
		end

	-- elseif (event == "CHAT_MSG_SPELL_SELF_DAMAGE") then

	-- 	--SP_OP_Print(arg1)
	-- 	local a,b,str = string.find(arg1, " was dodged by (.+).")

	-- 	if a then
	-- 		SP_OP_Reset(str)
	-- 	else
	-- 		a,b,str = string.find(arg1, "Your (.+) hits")
	-- 		if not str then a,b,str = string.find(arg1, "Your (.+) crits") end
	-- 		if not str then a,b,str = string.find(arg1, "Your (.+) is") end
	-- 		if not str then a,b,str = string.find(arg1, "Your (.+) misses") end
	-- 		if str == "Overpower" then
	-- 			SP_OP_TimeLeft = 0
	-- 			SP_OP_UpdateDisplay()
	-- 		end
	-- 	end
	end
end

function SP_OP_OnUpdate(self, delta)
	if (SP_OP_TimeLeft > 0) then

		SP_OP_TimeLeft = SP_OP_TimeLeft - delta
		if (SP_OP_TimeLeft < 0) then
			SP_OP_TimeLeft = 0
		end

		SP_OP_UpdateDisplay()
	end
end

function SP_OP_Reset()
	local op_spellID = SP_OP_GetSpellID("Overpower")
	if op_spellID == nil then
--[[
/tad SP_OP_Frame
/script SP_OP_FrameTime:SetColorTexture(1, 0, 0, 1)
/script SP_OP_FrameTime:SetColorTexture(1, 0, 0)
/script SP_OP_FrameShadowTime:SetTexture(1, 0, 0, 1)
/script SP_OP_Frame.tex = SP_OP_Frame:CreateTexture(nil, "OVERLAY")
/script SP_OP_Frame.tex:Show()
/script SP_OP_Frame.tex:SetColorTexture(1, 0, 0)
/script SP_OP_Frame.tex:SetPoint("TOPLEFT", SP_OP_Frame, "TOPLEFT")
/script SP_OP_Frame.tex:SetPoint("BOTTOMRIGHT", SP_OP_Frame, "BOTTOMRIGHT")
/dump SP_OP_Frame.tex:IsShown()
/dump SP_OP_Frame.tex:IsVisible()
/dump SP_OP_Frame.tex:SetParent(UIParent)
/dump SP_OP_Frame.tex:SetParent(SP_OP_Frame)
/dump UIParent.tex:IsShown()
/dump UIParent.tex:IsVisible()
/script UIParent.tex = UIParent:CreateTexture(nil, "OVERLAY")
/script UIParent.tex:Show()
/script UIParent.tex:SetColorTexture(1, 0, 0, 1)
/script UIParent.tex:SetPoint("TOPLEFT", UIParent, "TOPLEFT")
/script UIParent.tex:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -100, 100)
/script UIParent.tex:ClearAllPoints()
/script UIParent.tex:Hide()
/dump SP_OP_FrameTime:SetParent(UIParent)
/dump SP_OP_FrameTime:Hide()
/dump SP_OP_FrameTime:Show()
/dump SP_OP_FrameShadowTime:SetParent(UIParent)
/dump SP_OP_Frame.tex:GetSize()
/dump SP_OP_Frame:GetSize()
/dump SP_OP_Frame:SetPoint("CENTER")
/script SP_OP_FrameTime.bla = "bla"
/script SP_OP_FrameTime:Show()
/dump SP_OP_FrameShadowTime:GetFrameType()
/dump SP_OP_Frame

isvisible
frametype

/script SP_OP_FrameTime:SetColorTexture(r, g, b)
		self["pixel"..x..","..y] = self:CreateTexture(nil, "OVERLAY")
/dump SP_OP_FrameTime:IsVisible()
--]]
		return
	end

	local op_start, op_dur = GetSpellCooldown(op_spellID, BOOKTYPE_SPELL)
	if op_start > 0 then
		SP_OP_CDTime = op_dur - (GetTime() - op_start)
	else
		SP_OP_CDTime = 0
	end

	if SP_OP_CDTime < 4 then
		SP_OP_TimeLeft = 4
		SP_OP_Name = name
		SP_OP_FrameTargetName:SetText(name)

		-- PlaySoundFile("Sound\\Interface\\AuctionWindowClose.wav")
		print("TODO sound file")
	end
	--[[

	/script PlaySoundFile("Sound\\SPELLS\\Strike.wav")
	/script PlaySoundFile("Sound\\SPELLS\\Screech.wav")
	/script PlaySoundFile("Sound\\SPELLS\\Purge.wav")
	/script PlaySoundFile("Sound\\SPELLS\\PathFinding.wav")
	/script PlaySoundFile("Sound\\SPELLS\\KnockDown.wav")
	/script PlaySoundFile("Sound\\SPELLS\\HolyWard.wav")
	/script PlaySoundFile("Sound\\SPELLS\\GhostlyStrikeImpact.wav")
	/script PlaySoundFile("Sound\\SPELLS\\Exorcism.wav")
	/script PlaySoundFile("Sound\\SPELLS\\ColdBlood.wav")
	/script PlaySoundFile("Sound\\Interface\\AuctionWindowClose.wav")
	/script PlaySoundFile("Sound\\Interface\\AuctionWindowOpen.wav")

	]]--
end
function SP_OP_Display(msg)
	SP_OP_FrameText:SetText(msg)
end
function SP_OP_UpdateDisplay()
	if (SP_OP_TimeLeft <= 0) then
		SP_OP_FrameTime:Hide()
		SP_OP_Frame:SetAlpha(0)
	else
		local w = (math.min(SP_OP_TimeLeft, 4 - SP_OP_CDTime) / 4 ) * 500
		local w2 = (SP_OP_TimeLeft / 4) * 500
		if w > 0 then
			SP_OP_FrameTime:SetWidth(w)
			SP_OP_FrameTime:Show()
		else
			-- SP_OP_FrameTime:Hide()
		end
		SP_OP_FrameShadowTime:SetWidth(w2)
		SP_OP_FrameShadowTime:Show()

		SP_OP_Display(string.sub(SP_OP_TimeLeft, 1, 3))

		SP_OP_Frame:SetAlpha(1)
	end
end




