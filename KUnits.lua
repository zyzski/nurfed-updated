-------------------------------------------------
-- Kollektiv Unit Frames
-- Credits: Tivoli, Tuller
-------------------------------------------------

KUnitsDB = KUnitsDB or {}

-------------------------------------------------
-- Local Variables
-------------------------------------------------
local _G = _G
local date = date
local unpack = unpack
local select = select
local format = format
local strsub = strsub
local strfind = strfind
local strsplit = strsplit
local gsub = gsub
local MAX_RAID_MEMBERS = MAX_RAID_MEMBERS
local dead = "Dead"
local offline = "Offline"
local ghost = "Ghost"
local GetUnitName = GetUnitName
local GetTime = GetTime
local UnitGUID = UnitGUID
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitMana = UnitMana
local UnitName = UnitName
local UnitManaMax = UnitManaMax
local UnitDebuff = UnitDebuff
local UnitBuff = UnitBuff
local UnitIsFriend = UnitIsFriend
local UnitLevel = UnitLevel
local UnitClassification = UnitClassification
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll  
local UnitFactionGroup = UnitFactionGroup 
local UnitIsPlayer = UnitIsPlayer
local UnitCreatureType = UnitCreatureType
local UnitCreatureFamily = UnitCreatureFamily
local UnitIsPlusMob = UnitIsPlusMob
local UnitReaction = UnitReaction
local UnitIsEnemy = UnitIsEnemy
local UnitClass = UnitClass
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitPowerType = UnitPowerType
local UnitPower = UnitPower
local UnitAffectingCombat = UnitAffectingCombat
local GetNumRaidMembers = GetNumRaidMembers
local GetPartyLeaderIndex = GetPartyLeaderIndex
local GetComboPoints = GetComboPoints
local GetNumPartyMembers = GetNumPartyMembers
local GetPetHappiness = GetPetHappiness
local GetRaidRosterInfo = GetRaidRosterInfo
local PlaySound = PlaySound
local CloseDropDownMenus = CloseDropDownMenus
local GetGuildInfo = GetGuildInfo
local GetLootMethod = GetLootMethod
local HasPetUI = HasPetUI
local UnitCanAttack = UnitCanAttack
local GetQuestDifficultyColor = GetQuestDifficultyColor
local SpellIsTargeting = SpellIsTargeting
local SpellCanTargetUnit = SpellCanTargetUnit
local SetCursor = SetCursor
local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local DebuffTypeColor = DebuffTypeColor
local IsPartyLeader = IsPartyLeader
local IsSpellInRange = IsSpellInRange
local PlayerName = UnitName("player")

-------------------------------------------------
-- Local Frame References
-------------------------------------------------

local statusref = CreateFrame("StatusBar")
local	statusref_SetMinMaxValues = statusref.SetMinMaxValues
local	statusref_SetStatusBarColor = statusref.SetStatusBarColor
local	statusref_SetValue = statusref.SetValue

local playermodelref = CreateFrame("PlayerModel")
local playermodelref_SetUnit = playermodelref.SetUnit
local playermodelref_RefreshUnit = playermodelref.RefreshUnit
local playermodelref_SetCamera = playermodelref.SetCamera

local frameref = CreateFrame("Frame",nil,UIParent)
local frameref_GetParent = frameref.GetParent
local frameref_SetAllPoints = frameref.SetAllPoints
local frameref_ClearAllPoints = frameref.ClearAllPoints
local frameref_SetPoint = frameref.SetPoint
local frameref_SetWidth = frameref.SetWidth
local frameref_GetWidth = frameref.GetWidth
local frameref_SetHeight = frameref.SetHeight
local frameref_Hide = frameref.Hide
local frameref_Show = frameref.Show
local frameref_GetName = frameref.GetName
local frameref_SetScale = frameref.SetScale
local frameref_GetID = frameref.GetID

local textureref = frameref:CreateTexture()
local textureref_SetVertexColor = textureref.SetVertexColor
local textureref_SetTexture = textureref.SetTexture
local textureref_SetTexCoord = textureref.SetTexCoord
local textureref_Show = textureref.Show
local textureref_Hide = textureref.Hide

local fontstringref = frameref:CreateFontString()
local fontstringref_SetText = fontstringref.SetText
local fontstringref_SetFormattedText = fontstringref.SetFormattedText
local fontstringref_SetFontObject = fontstringref.SetFontObject
local fontstringref_SetJustifyH = fontstringref.SetJustifyH
local fontstringref_SetTextColor = fontstringref.SetTextColor
local fontstringref_Show = fontstringref.Show
local fontstringref_Hide = fontstringref.Hide

local GameTooltip = GameTooltip

-------------------------------------------------
-- Local Tables
-------------------------------------------------

local print = function(text)
	ChatFrame1:AddMessage(text.."")
end	

local predict = {}

function showpredictunits()
	for i,v in ipairs(predict) do
		ChatFrame1:AddMessage(v.unit)
	end
end

local function rgbhex(r, g, b)
	return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

local classification = {
	["rareelite"] = ITEM_QUALITY3_DESC.."-"..ELITE,
	["rare"] = ITEM_QUALITY3_DESC,
	["elite"] = ELITE,
}

local UnitReactionColor = {
	{ r = 1.0, g = 0.0, b = 0.0 },
	{ r = 1.0, g = 0.0, b = 0.0 },
	{ r = 1.0, g = 0.5, b = 0.0 },
	{ r = 1.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
}

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
for k,v in pairs(RAID_CLASS_COLORS) do
	v.hex = rgbhex(v.r, v.g, v.b)
end


for _, val in ipairs(UnitReactionColor) do
	val.hex = rgbhex(val.r, val.g, val.b)
end

local ManaBarColor = {
	[0] = { [1] = 0.00, [2] = 1.00, [3] = 1.00 },
	[1] = { [1] = 1.00, [2] = 0.00, [3] = 0.00 },
	[2] = { [1] = 1.00, [2] = 0.50, [3] = 0.25 },
	[3] = { [1] = 1.00, [2] = 1.00, [3] = 0.00 },
	[4] = { [1] = 0.00, [2] = 1.00, [3] = 1.00 },
	[5] = { [1] = 0.50, [2] = 0.50, [3] = 0.50 },
	[6] = { [1] = 0.00, [2] = 0.82, [3] = 1.00 },
}

local class = {
	["WARRIOR"]	= {0, 0.25, 0, 0.25},
	["MAGE"]	= {0.25, 0.49609375, 0, 0.25},
	["ROGUE"]	= {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"]	= {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"]	= {0, 0.25, 0.25, 0.5},
	["SHAMAN"]	= {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"]	= {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"]	= {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"]	= {0, 0.25, 0.5, 0.75},
	["DEATHKNIGHT"] = { 0.25, 0.49609375, 0.5, 0.75},
	["PETS"]	= {0, 1, 0, 1},
}

-------------------------------------------------
-- Helper Functions
-------------------------------------------------

-- Credit to Bongos for this function
local function DisableBlizzFrames() 
	PlayerFrame:UnregisterAllEvents()
	PlayerFrameHealthBar:UnregisterAllEvents()
	PlayerFrameManaBar:UnregisterAllEvents()
	PlayerFrame:Hide()
	TargetFrame:UnregisterAllEvents()
	TargetFrameHealthBar:UnregisterAllEvents()
	TargetFrameManaBar:UnregisterAllEvents()
	TargetFrame:Hide()
	if MobHealthFrame and type(MobHealthFrame) == "table" then
		MobHealthFrame:Hide()
	end
	ComboFrame:UnregisterAllEvents()
	ComboFrame:Hide()
	ShowPartyFrame = function() return end
	for i = 1, MAX_PARTY_MEMBERS do
		_G[format("PartyMemberFrame%d", i)]:UnregisterAllEvents()
		_G[format("PartyMemberFrame%dHealthBar", i)]:UnregisterAllEvents()
		_G[format("PartyMemberFrame%dManaBar", i)]:UnregisterAllEvents()
	end
	HidePartyFrame()
	PetFrame:UnregisterAllEvents()
	PetFrameHealthBar:UnregisterAllEvents()
	PetFrameManaBar:UnregisterAllEvents()
	PetFrame:Hide()
	FocusFrame:UnregisterAllEvents()
	FocusFrameHealthBar:UnregisterAllEvents()
	FocusFrameManaBar:UnregisterAllEvents()
	FocusFrame:Hide()
end


local function getclassicon(unit, isclass)
	local coords, texture, none, eclass
	return function(unit, isclass)
		texture = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
		if isclass then
			coords = class[unit]
		else
			if UnitIsPlayer(unit) or UnitCreatureType(unit) == "Humanoid" then
				none, eclass = UnitClass(unit)
				coords = class[eclass]
			else
				coords = class["PETS"]
				texture = "Interface\\RaidFrame\\UI-RaidFrame-Pets"
			end
		end
		return texture, coords
	end
end

getclassicon = getclassicon()

local function getlevel()
	local level, classification, r, g, b, color
	return function(self)
		level = UnitLevel(self.unit)
		classification = UnitClassification(self.unit)
		if level > 0 then
			color = GetQuestDifficultyColor(level)
			r = color.r
			g = color.g
			b = color.b
		end
		if classification == "rareelite" or classification == "elite" or classification == "rare" then
			level = level.."+"
		elseif level == 0 then
			level = ""
		elseif level < 0 then
			level = "??"
			r, g, b = 1, 0, 0
		end
		if classification == "worldboss" then
			level = BOSS
			r, g, b = 1, 0, 0
		end
		return rgbhex(r or 0, g or 0, b or 0)..level.."|r"
	end
end

getlevel = getlevel()

local function getclass()
	local class, eclass, color, unitclass
	return function(self)
		class, eclass = UnitClass(self.unit)
		if UnitIsPlayer(self.unit) then
			if RAID_CLASS_COLORS[eclass] then
				color = RAID_CLASS_COLORS[eclass].hex or "|cffffffff"
				class = color..class.."|r"
			end
		else
			unitclass = UnitClassification(self.unit)
			if UnitCreatureType(self.unit) == "Humanoid" and UnitIsFriend("player", self.unit) then
				class = "NPC"
			elseif UnitCreatureType(self.unit) == "Beast" and UnitCreatureFamily(self.unit) then
				class = UnitCreatureFamily(self.unit)
			else
				class = UnitCreatureType(self.unit)
			end
			if classification[unitclass] then
				class = classification[unitclass].." "..class
			end
		end
		return class or ""
	end
end

getclass = getclass()

local function getname(self)
	local name, color, eclass, reaction
	return function(self)
		name = UnitName(self.unit) or ""
		if UnitIsPlayer(self.unit) then
			eclass = select(2, UnitClass(self.unit))
			if eclass then
				color = RAID_CLASS_COLORS[eclass].hex
			end
		else
			if UnitIsTapped(self.unit) and not UnitIsTappedByPlayer(self.unit) then
				color = "|cff7f7f7f"
			else
				reaction = UnitReaction(self.unit, "player")
				if reaction then
					color = UnitReactionColor[reaction].hex
				end
			end
		end
		return (color or "|cffffffff")..name.."|r"
	end
end

getname = getname()

local function getguild(self)
	local guild, pguild, color
	return function(self)
		guild = GetGuildInfo(self.unit)
		if guild then
			pguild = GetGuildInfo("player")
			color = "|cff00bfff"
			if guild == pguild then
				color = "|cffff00ff"
			end
			guild = color..guild.."|r"
		end
		return guild or ""
	end
end

getguild = getguild()

local function getstatus(unit)
	if not UnitIsConnected(unit) then
		return offline
	elseif UnitIsGhost(unit) then	
		return ghost
	elseif UnitIsDead(unit) or UnitIsCorpse(unit) then
		return dead
	else
		return false
	end
end

-------------------------------------------------
-- Health Bar
-------------------------------------------------

local function KUnitsHealthBar_Update()
	local currValue, maxValue, perc, r, g, b, status
	return function(healthbar, unit)
		if not healthbar then
			return
		end
		if unit == healthbar.unit then
			currValue = UnitHealth(unit)
			maxValue = UnitHealthMax(unit)
			if maxValue == 0 then
				maxValue = 1
			end
			perc = currValue / maxValue
			
			statusref_SetMinMaxValues(healthbar,0, maxValue)
			if not UnitIsConnected(unit) then
				currValue = 0
				_G["KUnits_"..unit].disconnected = true
			else
				_G["KUnits_"..unit].disconnected = nil
			end
			if perc > 0.5 then
				r = (1.0 - perc) * 2
				g = 1.0
			else
				r = 1.0
				g = perc * 2
			end
			b = 0.0
			statusref_SetStatusBarColor(healthbar,r,g,b)
			statusref_SetValue(healthbar,currValue)
			status = getstatus(unit)
			if healthbar.text then
				if status then
					fontstringref_SetText(healthbar.text,status)
				else
					fontstringref_SetFormattedText(healthbar.text,"%d(%d)",currValue,maxValue)
				end
				if healthbar.text2 then
					if status then
						fontstringref_SetText(healthbar.text2,status)
					else
						fontstringref_SetFormattedText(healthbar.text2,"%d",(-1 * (maxValue - currValue)))
					end
				end
			end
			if healthbar.perc then
				if status then
					fontstringref_SetText(healthbar.perc,status)
				else
					fontstringref_SetFormattedText(healthbar.perc,"%d%%", perc * 100)
				end
			end
		end
	end
end

KUnitsHealthBar_Update = KUnitsHealthBar_Update()

local function KUnitsHealthBar_Initialize(unit, healthbar, healthtext, healthtext2, healthbg, healthperc)
	if not healthbar then
		return
	end
	healthbar.unit = unit
	healthbar.text = healthtext
	healthbar.text2 = healthtext2
	healthbar.perc = healthperc
	textureref_SetVertexColor(healthbg,1,0,0,0.25)
end

-------------------------------------------------
-- Mana Bar
-------------------------------------------------

local function KUnits_UpdateManaType()
	local info,r,g,b
	return function(self)
		if not self.manabar then
			return
		end
		info = ManaBarColor[UnitPowerType(self.unit)]
		self.manabar.powerType = UnitPowerType(self.unit)
		r,g,b = unpack(info)
		statusref_SetStatusBarColor(self.manabar,r,g,b)
		textureref_SetVertexColor(self.manabar.bg,r,g,b,0.25)
	end
end

KUnits_UpdateManaType = KUnits_UpdateManaType()

local function KUnitsManaBar_Update()
	local maxValue, currValue
	return function(manabar, unit)
		if not manabar then
			return
		end
		if unit == manabar.unit then
			KUnits_UpdateManaType(frameref_GetParent(manabar))
			maxValue = UnitManaMax(unit)
			statusref_SetMinMaxValues(manabar,0,maxValue)
			if not UnitIsConnected(unit) then
				currValue = 0
				statusref_SetValue(manabar,0)
			else
				currValue = UnitPower(unit,manabar.powerType)
				statusref_SetValue(manabar,currValue)
			end
			fontstringref_SetFormattedText(manabar.text,"%d(%d)",currValue,maxValue)
		end
	end
end

KUnitsManaBar_Update = KUnitsManaBar_Update()

local function KUnitsManaBar_Initialize(unit, manabar, manatext, manabg)
	if (not manabar) then
		return
	end
	manabar.unit = unit
	manabar.text = manatext
	manabar.bg = manabg
end

-------------------------------------------------
-- Generic
-------------------------------------------------

local function KUnits_setborder(button, border)
	frameref_ClearAllPoints(border)
	frameref_SetAllPoints(border)
end

local function KUnits_setcount(button, count)
	fontstringref_SetFontObject(count,KUnits_UnitFontOutline)
	frameref_ClearAllPoints(count)
	frameref_SetPoint(count,"BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	frameref_SetWidth(count,frameref_GetWidth(button))
	fontstringref_SetJustifyH(count,"RIGHT")
	frameref_SetHeight(count,0)
end

local function KUnits_seticon(button, icon)
	frameref_ClearAllPoints(icon)
	frameref_SetAllPoints(icon,button)
end

local function KUnits_CountBuffs(name)
	local num = 1
	local count = 0
	while _G[name.."buff"..num] do
		_G[name.."buff"..num.."Border"]:Hide()
		KUnits_setcount(_G[name.."buff"..num],_G[name.."buff"..num.."Count"])
		KUnits_seticon(_G[name.."buff"..num],_G[name.."buff"..num.."Icon"])
		count = count + 1
		num = num + 1
	end
	return count
end

local function KUnits_CountDebuffs(name)
	local num = 1
	local count = 0
	while _G[name.."debuff"..num] do
		_G[name.."debuff"..num].isDebuff = 1
		KUnits_setborder(_G[name.."debuff"..num], _G[name.."debuff"..num.."Border"])
		KUnits_setcount(_G[name.."debuff"..num], _G[name.."debuff"..num.."Count"])
		KUnits_seticon(_G[name.."debuff"..num], _G[name.."debuff"..num.."Icon"])
		count = count + 1
		num = num + 1
	end
	return count
end

local function KUnits_UpdateTooltip(self)
	local r, g, b
	return function(self)
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		if GameTooltip:SetUnit(self.unit) then
			self.UpdateTooltip = KUnits_UpdateTooltip
		else
			self.UpdateTooltip = nil;
		end
		r, g, b = GameTooltip_UnitColor(self.unit)
		fontstringref_SetTextColor(GameTooltipTextLeft1,r, g, b)
	end
end
 
local KUnits_UpdateTooltip = KUnits_UpdateTooltip()

local function KUnits_OnEnter(self)
	if SpellIsTargeting() then
		if SpellCanTargetUnit(self.unit) then
			SetCursor("CAST_CURSOR");
		else
			SetCursor("CAST_ERROR_CURSOR");
		end
	end
	
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	KUnits_UpdateTooltip(self)
end

local function KUnits_OnLeave(self)
	if SpellIsTargeting() then
		SetCursor("CAST_ERROR_CURSOR");
	end
	frameref_Hide(GameTooltip)
end

local function KUnits_SetName(self)
	if self.guild then
		fontstringref_SetText(self.name,getname(self).." "..getguild(self))
	elseif UnitExists(self.unit) and self.unit ~= "target" then 
		fontstringref_SetText(self.name,getname(self))
	end
end

local function KUnits_Update(self)
	KUnits_SetName(self)
	KUnitsHealthBar_Update(self.healthbar, self.unit)
	KUnitsManaBar_Update(self.manabar, self.unit)
end

function KUnits_Initialize(self, unit, name, healthbar, healthtext, healthtext2, healthbg, manabar, manatext, manabg, level, healthperc, dontPredict)
	if (not ClickCastFrames) then
		ClickCastFrames = {}
	end
  ClickCastFrames[self] = true
	self.unit = unit
	self.name = name
	self.healthbar = healthbar
	self.manabar = manabar
	self.level = level
	
	if not dontPredict then table.insert(predict,self) end
	
	KUnitsHealthBar_Initialize(unit, healthbar, healthtext, healthtext2, healthbg, healthperc)
	KUnitsManaBar_Initialize(unit, manabar, manatext, manabg)
	KUnits_Update(self)
end

-------------------------------------------------
-- Buffs/Debuffs
-------------------------------------------------

local print = function(a1) if a1 then ChatFrame1:AddMessage(""..a1) end end

local function KUnits_AuraUpdate(self)
	local unit, buttonname, framenamedebuff, framenamebuff
	local button, name, rank, texture, app, duration, expirationTime, debuffType, color, total, width, fwidth, scale, border, isMine, isStealable
	return function(self)
		unit = self.unit
		total = 0
		framenamedebuff = frameref_GetName(self).."debuff"
		if self.buffs then
			framenamebuff = frameref_GetName(self).."buff"
			for i = 1, self.buffs do
				button = _G[framenamebuff..i]
				buttonname = frameref_GetName(button)
				name, rank, texture, app, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff(unit, i)
				if name then
					textureref_SetTexture(_G[buttonname.."Icon"],texture)
					count = _G[buttonname.."Count"]
					border = _G[framenamebuff..i.."Border"]
					if app > 1 then
						fontstringref_SetText(count,app)
						fontstringref_Show(count)
					else
						fontstringref_Hide(count)
					end
					frameref_Show(button)
					total = total + 1
					if duration and duration > 0 and isMine then
						CooldownFrame_SetTimer(_G[buttonname.."Cooldown"], expirationTime - duration, duration, 1)
					else
						frameref_Hide(_G[buttonname.."Cooldown"])
					end
				else
					frameref_Hide(button)
				end
				if self.buffwidth then
					width = frameref_GetWidth(button)
					fwidth = total * width
					scale = self.buffwidth / fwidth
					if scale > 1 then
						scale = 1
					end
					for i = 1, total do
						frameref_SetScale(_G[framenamebuff..i],scale)
					end
				end
			end
		end
		total = 0
		if self.debuffs then
			framenamedebuff = frameref_GetName(self).."debuff"
			for i = 1, self.debuffs do
				button = _G[framenamedebuff..i]
				buttonname = frameref_GetName(button)
				name, rank, texture, app, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff(unit, i)
				if name then
					textureref_SetTexture(_G[buttonname.."Icon"],texture)
					count = _G[buttonname.."Count"]
					border = _G[buttonname.."Border"]
					if app > 1 then
						fontstringref_SetText(count,app)
						fontstringref_Show(count)
					else	
						fontstringref_Hide(count)
					end
					if debuffType then
						color = DebuffTypeColor[debuffType]
					else
						color = DebuffTypeColor["none"]
					end
					textureref_SetVertexColor(border,color.r, color.g, color.b)
					frameref_Show(button)
					total = total + 1
					if duration and duration > 0 and isMine then
						CooldownFrame_SetTimer(_G[buttonname.."Cooldown"], expirationTime - duration, duration, 1)		
					else
						frameref_Hide(_G[buttonname.."Cooldown"])
					end
				else
					frameref_Hide(button)
				end
				if self.debuffwidth then
					width = frameref_GetWidth(button)
					fwidth = total * width
					scale = self.debuffwidth / fwidth
					if scale > 1 then
						scale = 1
					end
					for i = 1, total do
						frameref_SetScale(_G[framenamedebuff..i],scale)
					end
				end
			end
		end
	end
end

KUnits_AuraUpdate = KUnits_AuraUpdate()

-------------------------------------------------
-- Player
-------------------------------------------------

function KUnits_player_OnLoad(self)
	self:Show()
	self:ClearAllPoints()
	self:SetPoint("BOTTOM",UIParent,"BOTTOM",-150,129)
	self:SetScale(KUnitsDB.playerscale or 1.11)
	self.status = KUnits_playerstatus
	self.status:SetTexCoord(0.5, 1.0, 0, 0.5)
	self.group  = KUnits_playergroup
	self.master = KUnits_playermaster
	self.leader = KUnits_playerleader
	KUnits_SetName(self)
	self:SetScript("OnEnter", KUnits_OnEnter)
	self:SetScript("OnLeave", KUnits_OnLeave)
	self:SetScript("OnMouseDown", 
		function(self, button)
			if button == "LeftButton" and IsShiftKeyDown() then
				self:StartMoving()
			end 
	end)
	self:SetScript("OnMouseUp", 
		function(self, button)
			if button == "LeftButton" then
				self:StopMovingOrSizing()
			end
	end)
	
	local showmenu = function()
		ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "cursor");
	end
	SecureUnitButton_OnLoad(self, "player", showmenu);
	RegisterUnitWatch(self, true)
end

local function KUnits_player_UpdatePartyLeader()
	local lootMethod, lootMaster
	return function(self)
		if IsPartyLeader() then
			textureref_Show(self.leader)
		else
			textureref_Hide(self.leader)
		end
		lootMethod, lootMaster = GetLootMethod()
		if lootMaster == 0 and ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) then
			textureref_Show(self.master)
		else
			textureref_Hide(self.master)
		end
	end
end

KUnits_player_UpdatePartyLeader = KUnits_player_UpdatePartyLeader()

local function KUnits_player_UpdateStatus(self)
	if UnitAffectingCombat("player") then
		textureref_Show(self.status)
	else
		textureref_Hide(self.status)
	end
end

local function KUnits_player_Update(self)
	if UnitExists("player") then
		fontstringref_SetText(self.level,UnitLevel("player"))
		KUnits_player_UpdatePartyLeader(self)
		KUnits_player_UpdateStatus(self)
	end
end

local function KUnits_player_UpdateGroupIndicator()
	local name,rank,subgroup,numRaidMembers
	return function(group)
		numRaidMembers = GetNumRaidMembers()
		if numRaidMembers == 0 then
			fontstringref_SetText(group,nil)
			return
		end
		for i=1, MAX_RAID_MEMBERS do
			if i <= numRaidMembers then
				name, rank, subgroup = GetRaidRosterInfo(i)
				if name == PlayerName then
					fontstringref_SetText(group,"Group: "..subgroup)
					break
				end
			else
				break
			end
		end
	end
end

KUnits_player_UpdateGroupIndicator = KUnits_player_UpdateGroupIndicator()

-------------------------------------------------
-- Focus
-------------------------------------------------

local function KUnits_focus_CheckLevel(self)
	fontstringref_SetText(self.name,getlevel(self).." "..getname(self))
end

local function KUnits_focus_Update(self)
	if UnitExists("focus") then
		KUnits_Update(self)
		KUnits_focus_CheckLevel(self)
		KUnits_AuraUpdate(self)
	end
end

function KUnits_focus_OnLoad(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOM",UIParent,"BOTTOM",-294,182)
	self:SetScale(KUnitsDB.focusscale or 1.18)
	self.buffs = KUnits_CountBuffs(self:GetName())
	self.debuffs = KUnits_CountDebuffs(self:GetName())
	self.buffwidth = 160
	self.debuffwidth = 160
	self.name = KUnits_focusname

	self:SetScript("OnEnter", KUnits_OnEnter)
	self:SetScript("OnLeave", KUnits_OnLeave)
	self:SetScript("OnMouseDown", 
		function(self, button)
			if button == "LeftButton" and IsShiftKeyDown() then
				self:StartMoving()
			end
	end)
	self:SetScript("OnMouseUp", 
		function(self, button)
			if button == "LeftButton" then
				self:StopMovingOrSizing()
			end 
	end)
	KUnits_focus_Update(self)
	SecureUnitButton_OnLoad(KUnits_focustarget, "focustarget")
	RegisterUnitWatch(KUnits_focustarget)
	SecureUnitButton_OnLoad(KUnits_focustargettarget,"focustargettarget")
	RegisterUnitWatch(KUnits_focustargettarget)
	SecureUnitButton_OnLoad(self, "focus")
	RegisterUnitWatch(self)
end

-------------------------------------------------
-- Target
-------------------------------------------------

local function KUnits_target_CheckLevel(self)
	self.level:SetText(getlevel(self).." "..getclass(self))
end

local function KUnits_target_CheckFaction(self)
	if self.pvp then
		local factionGroup = UnitFactionGroup("target");
		if UnitIsPVPFreeForAll("target") then
			textureref_SetTexture(self.pvp,"Interface\\TargetingFrame\\UI-PVP-FFA");
			textureref_Show(self.pvp)
		elseif factionGroup then
			textureref_SetTexture(self.pvp,"Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
			textureref_Show(self.pvp)
		else
			textureref_Hide(self.pvp)
		end
	end
end

local function KUnits_target_UpdateCombo(self)
	local comboPoints = GetComboPoints("player","target")
	if comboPoints > 0 then
		fontstringref_SetText(self.combo,comboPoints)
		if comboPoints < 5 then
			fontstringref_SetTextColor(self.combo,1, 1, 0)
		else
			fontstringref_SetTextColor(self.combo,1, 0, 0)
		end
		fontstringref_Show(self.combo)
	else
		fontstringref_Hide(self.combo)
	end
end

local function KUnits_target_Update(self)
	if UnitExists("target") then
		playermodelref_SetUnit(self.model,"target")
		playermodelref_SetCamera(self.model,0)
		KUnits_Update(self)
		KUnits_AuraUpdate(self)
		KUnits_target_CheckLevel(self)
		KUnits_target_CheckFaction(self)
		KUnits_target_UpdateCombo(self)
	end
end

local function KUnits_target_OnHide()
	PlaySound("INTERFACESOUND_LOSTTARGETUNIT")
	CloseDropDownMenus()
end
	
function KUnits_target_OnLoad(self)
	self:RegisterForClicks("AnyUp")
	self:ClearAllPoints()
	self:SetPoint("BOTTOM",UIParent,"BOTTOM",152,129)
	self:SetScale(KUnitsDB.targetscale or 1.11)
	self.level = KUnits_targetlevel
	self.pvp = KUnits_targetpvp
	self.model = KUnits_targetmodel
	self.combo = KUnits_targetcombo
	self.buffs = KUnits_CountBuffs(self:GetName())
	self.debuffs = KUnits_CountDebuffs(self:GetName())
	self.buffwidth = 175
	--self.debuffwidth = 175
	self.guild = 1
	
	self:SetScript("OnEnter", KUnits_OnEnter)
	self:SetScript("OnLeave", KUnits_OnLeave)
	self:SetScript("OnMouseDown", 
		function(self, button)
			if button == "LeftButton" and IsShiftKeyDown() then
				self:StartMoving()
			end 
	end)
	self:SetScript("OnMouseUp", 
		function(self, button)
			if button == "LeftButton" then
				self:StopMovingOrSizing()
			end
	end)
	self:SetScript("OnShow", 
		function(self) 
			self.model:SetUnit("target")
			self.model:SetCamera(0)
	end)
	self:SetScript("OnHide", KUnits_target_OnHide)
	
	KUnits_target_Update(self)
	
	local showmenu = function()
		ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor");
	end
	SecureUnitButton_OnLoad(self, "target", showmenu)
	RegisterUnitWatch(KUnits_target)
	SecureUnitButton_OnLoad(KUnits_targettarget,"targettarget")
	RegisterUnitWatch(KUnits_targettarget)
	SecureUnitButton_OnLoad(KUnits_targettargettarget,"targettargettarget")
	RegisterUnitWatch(KUnits_targettargettarget)
end


-------------------------------------------------
-- PartyBG
-------------------------------------------------

local bgheights = {41,113,166,219} 

local function KUnits_partyBG_Update(self)
	local num = GetNumPartyMembers()
	if num > 0 then
		frameref_SetHeight(self,bgheights[num])
		frameref_Show(self)
	else
		frameref_Hide(self)
	end
end

function KUnits_partyBG_OnLoad(self)
	self:SetWidth(180)
	self:SetScale(KUnitsDB.partyscale or 1.18)
end

-------------------------------------------------
-- Party
-------------------------------------------------

local function KUnits_party_UpdateClassIcon()
	local icon, texture, coords
	return function(self)
		icon = self.icon
		texture, coords = getclassicon(self.unit)
		if coords then
			textureref_SetTexture(icon,texture)
			textureref_SetTexCoord(icon,unpack(coords))
		end
	end
end

KUnits_party_UpdateClassIcon = KUnits_party_UpdateClassIcon()

local function KUnits_party_UpdateHighlight(self)
	if UnitExists("target") and UnitName("target") == UnitName(self.unit) then
		textureref_Show(self.highlight)
	else
		textureref_Hide(self.highlight)
	end
end

local function KUnits_party_UpdateLeader(self, id)
	if GetPartyLeaderIndex() == id then
		textureref_Show(self.leader)
	else
		textureref_Hide(self.leader)
	end
end

local function KUnits_party_Update(self)
	if HIDE_PARTY_INTERFACE == "1" and GetNumRaidMembers() > 0 then
		KUnits_PartyParent:Hide()
		return
	elseif not InCombatLockdown() then
		KUnits_PartyParent:Show()
	end
	if UnitExists(self.unit) then
		KUnits_Update(self)
		local lootMethod, lootMaster = GetLootMethod()
		if frameref_GetID(self) == lootMaster then
			textureref_Show(self.master)
		else
			textureref_Hide(self.master)
		end
		KUnits_party_UpdateClassIcon(self)
		KUnits_party_UpdateHighlight(self)
		KUnits_party_UpdateLeader(self,frameref_GetID(self))
		KUnits_AuraUpdate(self)
	end
end

local function KUnits_CheckLootMethod(self)
	local lootMethod, lootMaster = GetLootMethod()
	if frameref_GetID(self) == lootMaster then
		textureref_Show(self.master)
	else
		textureref_Hide(self.master)
	end
end

function KUnits_party_Initialize(self)
	local unit = strsub(self:GetName(),8)
	KUnits_Initialize(self, unit, _G["KUnits_"..unit.."name"],
									 				_G["KUnits_"..unit.."hp"], _G["KUnits_"..unit.."hptext"], 
									 				_G["KUnits_"..unit.."hptext2"], _G["KUnits_"..unit.."hpbg"],
									 				_G["KUnits_"..unit.."mp"], _G["KUnits_"..unit.."mptext"],
									 				_G["KUnits_"..unit.."mpbg"], _G["KUnits_"..unit.."level"], 
									 				_G["KUnits_"..unit.."hpperc"])
end

function KUnits_party_OnLoad(self)
	local id = self:GetID()
	self:SetScale(KUnitsDB.partyscale or 1.18)
	self.pet = _G["KUnits_partypet"..id]
	self.pet:SetScale(1.15)
	self.mini = _G["KUnits_party"..id.."target"]
	self.classicon = _G["KUnits_party"..id.."classicon"]
	self.leader = _G["KUnits_party"..id.."leader"]
	self.master = _G["KUnits_party"..id.."master"]
	self.icon = _G["KUnits_party"..id.."classicon"]
	self.highlight = _G["KUnits_party"..id.."highlight"]
	self.buffs = KUnits_CountBuffs(self:GetName())
	self.debuffs = KUnits_CountDebuffs(self:GetName())
	self.buffwidth = 173
	self.debuffwidth = 105
	
	self:SetScript("OnEnter", KUnits_OnEnter)
	self:SetScript("OnLeave", KUnits_OnLeave)
	
	KUnits_party_Update(self)
	KUnits_party_UpdateLeader(self)

	local mini = _G["KUnits_party"..id.."target"]
	local miniunit = strsub(mini:GetName(),8)
	SecureUnitButton_OnLoad(mini, miniunit)
  RegisterUnitWatch(mini)
  
  local showmenu = function()
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..id.."DropDown"],"cursor");
	end
	SecureUnitButton_OnLoad(self, self.unit, showmenu)
	
	RegisterUnitWatch(self)
	SecureUnitButton_OnLoad(self.pet, self.pet.unit)
	RegisterUnitWatch(self.pet)
end

-------------------------------------------------
-- Pet
-------------------------------------------------

local function KUnits_pet_SetHappiness(self)
	local happiness, damagePercentage = GetPetHappiness()
	local hasPetUI, isHunterPet = HasPetUI()
	if happiness or isHunterPet then
		local display
		local text = self.name
		local icon = self.happiness
		if text then display = "["..UnitLevel("pet").."] "..UnitName("pet") end
		if icon then icon:Show() end
		if happiness == 1 then
			if text then text:SetTextColor(1, 0.5, 0) end
			if icon then icon:SetTexCoord(0.375, 0.5625, 0, 0.359375) end
		elseif happiness == 2 then
			if text then text:SetTextColor(1, 1, 0) end
			if icon then icon:SetTexCoord(0.1875, 0.375, 0, 0.359375) end
		elseif happiness == 3 then
			if text then text:SetTextColor(0, 1, 0) end
			if icon then icon:SetTexCoord(0, 0.1875, 0, 0.359375) end
		end
		if text then
			text:SetText(display)
		end
	end
end

local function KUnits_pet_Update(self)
	if UnitExists("pet") then
		KUnits_Update(self)
		KUnits_pet_SetHappiness(self)
		KUnits_AuraUpdate(self)
	end
end

function KUnits_pet_OnLoad(self)
	self:ClearAllPoints()
	self:SetScale(KUnitsDB.petscale or 1.0)
	self:SetPoint("CENTER",UIParent,"CENTER")
	self.buffs = KUnits_CountBuffs(self:GetName())
	self.debuffs = KUnits_CountDebuffs(self:GetName())
	self.happiness = KUnits_pethappiness
	self.debuffwidth = 160
	self.buffwidth = 160
	self:SetScript("OnEnter", KUnits_OnEnter)
	self:SetScript("OnLeave", KUnits_OnLeave)
	self:SetScript("OnMouseDown", 
		function(self, button)
			if button == "LeftButton" and IsShiftKeyDown() then
				self:StartMoving()
			end
	end)
	self:SetScript("OnMouseUp", 
		function(self, button)
			if button == "LeftButton" then
				self:StopMovingOrSizing()
			end
	end)
	
	KUnits_pet_Update(self)
	
	local showmenu = function()
		ToggleDropDownMenu(1, nil, PetFrameDropDown,"cursor");
	end
	SecureUnitButton_OnLoad(self, self.unit,showmenu)
	RegisterUnitWatch(self)
end

-------------------------------------------------
-- Model
-------------------------------------------------

function KUnits_model_OnLoad(self)
	local unit = strsub(self:GetParent():GetName(),8)
	self.unit = unit
	local pmtime = 0
	self:RegisterEvent("DISPLAY_SIZE_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_MODEL_CHANGED")
	self:SetScript("OnEvent",function(self,event)
		self:SetUnit(self.unit)
		self:RefreshUnit() 
		self:SetCamera(0)
	end)
	self:SetScript("OnUpdate",
		function(self, elapsed)
			pmtime = pmtime + elapsed
			if pmtime > 0.5 then
				self:SetCamera(0)
				pmtime = 0
			end
		end)
end

-------------------------------------------------
-- Mini
-------------------------------------------------

local function KUnits_UpdateMiniName(self)
	fontstringref_SetText(self.name,getname(self))
end

local function KUnits_UpdateMiniHealth()
	local minir,minig,minib,minicurrValue,minimaxValue,ministatus,miniperc
	return function (healthbar, unit)
		minicurrValue, minimaxValue, ministatus = UnitHealth(unit), UnitHealthMax(unit), getstatus(unit)
		if healthbar.currValue == minicurrValue then return end
		healthbar.currValue = minicurrValue
		
		miniperc = minicurrValue / minimaxValue
		healthbar:SetMinMaxValues(0, minimaxValue)
		if miniperc > 0.5 then
			minir = (1.0 - miniperc) * 2
			minig = 1.0
		else
			minir = 1.0
			minig = miniperc * 2
		end
		minib = 0.0
		statusref_SetStatusBarColor(healthbar,minir,minig,minib)
		statusref_SetValue(healthbar,minicurrValue)
		if miniperc > 1 or miniperc < 0 then
			miniperc = 0
		end
		if ministatus then
			fontstringref_SetText(healthbar.perc,status)
		else
			fontstringref_SetFormattedText(healthbar.perc,"%d%%", miniperc * 100)
		end
	end
end

KUnits_UpdateMiniHealth = KUnits_UpdateMiniHealth()

local function KUnits_UpdateMini(self)
	KUnits_UpdateMiniHealth(self.healthbar, self.unit)
	KUnits_UpdateMiniName(self)
end

function KUnits_miniUpdater_OnLoad(self)
	local minis = {
		KUnits_targettarget,
		KUnits_targettargettarget,
		KUnits_party1target,
		KUnits_party2target,
		KUnits_party3target,
		KUnits_party4target,
		KUnits_focustargettarget,
		KUnits_focustarget,
	}
	local mini_IsVisible = KUnits_targettarget.IsVisible
	local time = 0
	self:SetScript("OnUpdate", 
		function (self, elapsed) 
			time = time + elapsed
			if time > 0.15 then
				for _,mini in ipairs(minis) do
					if mini_IsVisible(mini) then
						KUnits_UpdateMini(mini)
					end
				end
			time = 0
		end
	end)
end

local callback = false

function KUnits_mini_Initialize(self) 
	local unit = strsub(self:GetName(),8)
	local healthbar = _G[self:GetName().."hp"]
  local name = _G[self:GetName().."name"]
  local healthperc, healthbg = healthbar:GetRegions()
	KUnits_Initialize(self, unit, name, healthbar, nil, nil, healthbg, nil, nil, nil, nil, healthperc, true)
	self:SetScript("OnEnter", KUnits_OnEnter)
	self:SetScript("OnLeave", KUnits_OnLeave)
	self:SetScript("OnShow", KUnits_UpdateMini)
end

-- Health Events

function KUnits_healthevents_OnLoad(self)
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UNIT_MAXHEALTH")
	
	local KUnits_playerhp, KUnits_party1hp, KUnits_party2hp, KUnits_party3hp, KUnits_party4hp, KUnits_targethp, KUnits_focushp, KUnits_pethp, KUnits_partypet1hp, KUnits_partypet2hp, KUnits_partypet3hp, KUnits_partypet4hp 
			= KUnits_playerhp, KUnits_party1hp, KUnits_party2hp, KUnits_party3hp, KUnits_party4hp, KUnits_targethp, KUnits_focushp, KUnits_pethp, KUnits_partypet1hp, KUnits_partypet2hp, KUnits_partypet3hp, KUnits_partypet4hp
	
	local KUnits_partypet1, KUnits_partypet2, KUnits_partypet3, KUnits_partypet4 =
				KUnits_partypet1, KUnits_partypet2, KUnits_partypet3, KUnits_partypet4
	
	local healthevents = {
		player = 		function () KUnitsHealthBar_Update(KUnits_playerhp,'player') end,
		party1 = 		function () KUnitsHealthBar_Update(KUnits_party1hp,'party1') end,
		party2 = 		function () KUnitsHealthBar_Update(KUnits_party2hp,'party2') end,
		party3 = 		function () KUnitsHealthBar_Update(KUnits_party3hp,'party3') end,
		party4 = 		function () KUnitsHealthBar_Update(KUnits_party4hp,'party4') end,
		target = 		function () KUnitsHealthBar_Update(KUnits_targethp,'target') end,
		focus = 		function () KUnitsHealthBar_Update(KUnits_focushp,'focus') end,
		pet =			  function () KUnitsHealthBar_Update(KUnits_pethp,'pet') end,
		partypet1 = function () KUnits_UpdateMini(KUnits_partypet1) end,
		partypet2 = function () KUnits_UpdateMini(KUnits_partypet2) end,
		partypet3 = function () KUnits_UpdateMini(KUnits_partypet3) end,
		partypet4 = function () KUnits_UpdateMini(KUnits_partypet4) end,
	}
	
	self:SetScript("OnEvent", 
		function(self, event, unit, msg, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, msg1, msg2, msg3, msg4)
			if event == "COMBAT_LOG_EVENT_UNFILTERED" then
				instanthealth(msg, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, msg1, msg2, msg3, msg4)
			else
				callback = healthevents[unit]
				if callback then
					callback()
				end
				callback = false
			end
		end)
end

-- Mana Events

local manaevents = {}

function KUnits_manaevents_OnLoad(self)
	self:RegisterEvent("UNIT_MANA")
	self:RegisterEvent("UNIT_RAGE")
	self:RegisterEvent("UNIT_FOCUS")
	self:RegisterEvent("UNIT_ENERGY")
	self:RegisterEvent("UNIT_HAPPINESS")
	self:RegisterEvent("UNIT_MAXMANA")
	self:RegisterEvent("UNIT_MAXRAGE")
	self:RegisterEvent("UNIT_MAXFOCUS")
	self:RegisterEvent("UNIT_MAXENERGY")
	self:RegisterEvent("UNIT_MAXHAPPINESS")
	self:RegisterEvent("UNIT_DISPLAYPOWER")
	
	local KUnits_playermp, KUnits_party1mp, KUnits_party2mp, KUnits_party3mp, KUnits_party4mp, KUnits_targetmp, KUnits_focusmp, KUnits_petmp = 
				KUnits_playermp, KUnits_party1mp, KUnits_party2mp, KUnits_party3mp, KUnits_party4mp, KUnits_targetmp, KUnits_focusmp, KUnits_petmp
	
	manaevents = {
		player = 		function() KUnitsManaBar_Update(KUnits_playermp,'player') end,
		party1 = 		function() KUnitsManaBar_Update(KUnits_party1mp,'party1') end,
		party2 = 		function() KUnitsManaBar_Update(KUnits_party2mp,'party2') end,
		party3 = 		function() KUnitsManaBar_Update(KUnits_party3mp,'party3') end,
		party4 = 		function() KUnitsManaBar_Update(KUnits_party4mp,'party4') end,
		target = 		function() KUnitsManaBar_Update(KUnits_targetmp,'target') end,
		focus = 		function() KUnitsManaBar_Update(KUnits_focusmp,'focus') end,
		pet =				function() KUnitsManaBar_Update(KUnits_petmp,'pet') end,
	}
	
	self:SetScript("OnEvent", 
		function(self, event, unit)
			callback = manaevents[unit]
			if callback then
				callback()
			end
			callback = false
		end)
end

-- Basic Events

local function KUnits_basicevents_Update(self, event)
	if event == "UNIT_NAME_UPDATE" then
		fontstringref_SetText(self.name,getname(self))
	elseif event == "UNIT_DISPLAYPOWER" then
		KUnits_UpdateManaType(self);
	end
end

function KUnits_basicevents_OnLoad(self)
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterEvent("UNIT_DISPLAYPOWER")
	
	local KUnits_player, KUnits_party1, KUnits_party2, KUnits_party3, KUnits_party4, KUnits_target, KUnits_focus, KUnits_pet, KUnits_partypet1, KUnits_partypet2, KUnits_partypet3, KUnits_partypet4 =
				KUnits_player, KUnits_party1, KUnits_party2, KUnits_party3, KUnits_party4, KUnits_target, KUnits_focus, KUnits_pet, KUnits_partypet1, KUnits_partypet2, KUnits_partypet3, KUnits_partypet4
	local basicevents = {
		player = 		function (event) KUnits_basicevents_Update(KUnits_player,event) end,
		party1 = 		function (event) KUnits_basicevents_Update(KUnits_party1,event) end,
		party2 = 		function (event) KUnits_basicevents_Update(KUnits_party2,event) end,
		party3 = 		function (event) KUnits_basicevents_Update(KUnits_party3,event) end,
		party4 = 		function (event) KUnits_basicevents_Update(KUnits_party4,event) end,
		target = 		function (event) KUnits_basicevents_Update(KUnits_target,event) end,
		focus = 		function (event) KUnits_basicevents_Update(KUnits_focus,event) end,
		pet =			  function (event) KUnits_basicevents_Update(KUnits_pet,event) end,
		partypet1 = function (event) KUnits_basicevents_Update(KUnits_partypet1,event) end,
		partypet2 = function (event) KUnits_basicevents_Update(KUnits_partypet2,event) end,
		partypet3 = function (event) KUnits_basicevents_Update(KUnits_partypet3,event) end,
		partypet4 = function (event) KUnits_basicevents_Update(KUnits_partypet4,event) end,			
	}
	
	self:SetScript("OnEvent", function(self, event, unitid)
		callback = basicevents[unitid]
		if callback then
			callback(event)
		end
		callback = false
	end)
end

-- Specific Events

function KUnits_specificevents_OnLoad(self)
	local KUnits_player, KUnits_target, KUnits_focus, KUnits_pet, KUnits_party1, KUnits_party2, KUnits_party3, KUnits_party4, KUnits_partyBG =
				KUnits_player, KUnits_target, KUnits_focus, KUnits_pet, KUnits_party1, KUnits_party2, KUnits_party3, KUnits_party4, KUnits_partyBG
	
	local KUnits_partypet1, KUnits_partypet2, KUnits_partypet3, KUnits_partypet4 =
				KUnits_partypet1, KUnits_partypet2, KUnits_partypet3, KUnits_partypet4
	
	local gmatch = string.gmatch
				
	local specificevents_UNIT_AURA = {
		party1 = function() KUnits_AuraUpdate(KUnits_party1) end,
		party2 = function() KUnits_AuraUpdate(KUnits_party2) end,
		party3 = function() KUnits_AuraUpdate(KUnits_party3) end,
		party4 = function() KUnits_AuraUpdate(KUnits_party4) end,
		target = function() KUnits_AuraUpdate(KUnits_target) end,
		focus =  function() KUnits_AuraUpdate(KUnits_focus) end,
		pet =    function() KUnits_AuraUpdate(KUnits_pet) end, 
	}			
	
	local specificevents_UNIT_LEVEL = {
		player = function() fontstringref_SetText(KUnits_player.level,UnitLevel("player")) end,
		target = function() KUnits_target_CheckLevel(KUnits_target) end,
		focus = function() KUnits_focus_CheckLevel(KUnits_focus) end,
	}
	
	local specificevents = {
		["UNIT_LEVEL"] = function (unit)
			callback = specificevents_UNIT_LEVEL[unit]
			if callback then
				callback()
			end
			callback = false
		end, 
		["PLAYER_ENTERING_WORLD"] = function ()
			KUnits_Update(KUnits_player)
			KUnits_player_Update(KUnits_player)
			KUnits_player_UpdateStatus(KUnits_player)
			KUnits_party_Update(KUnits_party1)
			KUnits_party_Update(KUnits_party2)
			KUnits_party_Update(KUnits_party3)
			KUnits_party_Update(KUnits_party4)
			KUnits_target_Update(KUnits_target)
			KUnits_partyBG_Update(KUnits_partyBG)
			KUnits_UpdateMini(KUnits_partypet1)
			KUnits_UpdateMini(KUnits_partypet2)
			KUnits_UpdateMini(KUnits_partypet3)
		  KUnits_UpdateMini(KUnits_partypet4)
		end, 
		["PLAYER_REGEN_DISABLED"] = function ()
			KUnits_player_UpdateStatus(KUnits_player)
		
		end,
		["PLAYER_REGEN_ENABLED"] = function ()
			KUnits_player_UpdateStatus(KUnits_player)
		
		end,
		["PARTY_MEMBERS_CHANGED"] = function ()
			KUnits_player_UpdateGroupIndicator(KUnits_player.group)
			KUnits_player_UpdatePartyLeader(KUnits_player)
			KUnits_target_CheckFaction(KUnits_target.level)
			KUnits_party_Update(KUnits_party1)
			KUnits_party_Update(KUnits_party2)
			KUnits_party_Update(KUnits_party3)
			KUnits_party_Update(KUnits_party4)
			KUnits_partyBG_Update(KUnits_partyBG)
			KUnits_UpdateMini(KUnits_partypet1)
			KUnits_UpdateMini(KUnits_partypet2)
			KUnits_UpdateMini(KUnits_partypet3)
		  KUnits_UpdateMini(KUnits_partypet4)		
		end,
		["PARTY_LEADER_CHANGED"] = function ()
			KUnits_player_UpdateGroupIndicator(KUnits_player.group)
			KUnits_player_UpdatePartyLeader(KUnits_player)
			KUnits_party_UpdateLeader(KUnits_party1, 1)
			KUnits_party_UpdateLeader(KUnits_party2, 2)
			KUnits_party_UpdateLeader(KUnits_party3, 3)
			KUnits_party_UpdateLeader(KUnits_party4, 4)
		end,
		["PARTY_LOOT_METHOD_CHANGED"] = function ()
			local lootMethod, lootMaster = GetLootMethod()
			if lootMaster == 0 and ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) then
				textureref_Show(KUnits_player.master)
			else
				textureref_Hide(KUnits_player.master)
			end
		end, 
		["RAID_ROSTER_UPDATE"] = function ()
			KUnits_player_UpdateGroupIndicator(KUnits_player.group)
			KUnits_player_UpdatePartyLeader(KUnits_player)
		end,
		["PLAYER_FOCUS_CHANGED"] = function ()
			KUnits_focus_Update(KUnits_focus)
		end,
		["UNIT_AURA"] = function (unit)
			callback = specificevents_UNIT_AURA[unit]
			if callback then
				callback()
			end
			callback = false
		end,
		["PLAYER_TARGET_CHANGED"] = function ()
			KUnits_target_Update(KUnits_target)
			CloseDropDownMenus() 
			if UnitExists("target") then 
				if UnitIsEnemy("target", "player") then
					PlaySound("igCreatureAggroSelect")
				elseif UnitIsFriend("player", "target") then
					PlaySound("igCharacterNPCSelect")
				else
					PlaySound("igCreatureNeutralSelect")
				end
			end
			KUnits_party_UpdateHighlight(KUnits_party1)
			KUnits_party_UpdateHighlight(KUnits_party2)
			KUnits_party_UpdateHighlight(KUnits_party3)
			KUnits_party_UpdateHighlight(KUnits_party4)
		end,
		["UNIT_FACTION"] = function (unit)
			if unit == "target" or unit == "player" then
				KUnits_target_CheckFaction(KUnits_target.pvp)
				KUnits_target_CheckLevel(KUnits_target)
			end
		end,
		["UNIT_CLASSIFICATION_CHANGED"] = function(unit)
			if unit == "target" then
				KUnits_target_CheckLevel(KUnits_target)
			end
		end, 
		["UNIT_COMBO_POINTS"] = function (unit)
			if unit == "player" then
				KUnits_target_UpdateCombo(KUnits_target)
			end
		end,
		["PLAYER_LOGIN"] = function()
			KUnits_party_Update(KUnits_party1)
			KUnits_party_Update(KUnits_party2)
			KUnits_party_Update(KUnits_party3)
			KUnits_party_Update(KUnits_party4)
			KUnits_partyBG_Update(KUnits_partyBG)
			KUnits_UpdateMini(KUnits_partypet1)
			KUnits_UpdateMini(KUnits_partypet2)
			KUnits_UpdateMini(KUnits_partypet3)
		  KUnits_UpdateMini(KUnits_partypet4)
		end,
		["UNIT_PET"] = function(unit)
			if unit == "player" then
				KUnits_pet_Update(KUnits_pet)
			end
			for v in gmatch(unit,"partypet[1-4]") do
				KUnits_UpdateMini(_G["KUnits_"..v])
			end
		end,
		["UNIT_HAPPINESS"] = function()
			KUnits_pet_SetHappiness(KUnits_pet)
		end,
		["PARTY_LOOT_METHOD_CHANGED"] = function()
			KUnits_CheckLootMethod(KUnits_party1)
			KUnits_CheckLootMethod(KUnits_party2)
			KUnits_CheckLootMethod(KUnits_party3)
			KUnits_CheckLootMethod(KUnits_party4)
		end,
		["CVAR_UPDATE"] = function(cvar)
			if cvar == "HIDE_PARTY_INTERFACE_TEXT" then
				KUnits_party_Update(KUnits_party1)
			end
		end,
	}
	
	self:RegisterEvent("UNIT_HAPPINESS")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_LEVEL")
	self:RegisterEvent("UNIT_AURA") 
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
	self:RegisterEvent("UNIT_FACTION") 
	self:RegisterEvent("UNIT_COMBO_POINTS")
	self:RegisterEvent("PLAYER_ENTERING_WORLD") 
	self:RegisterEvent("PLAYER_REGEN_DISABLED")  
	self:RegisterEvent("PLAYER_REGEN_ENABLED") 
	self:RegisterEvent("PLAYER_TARGET_CHANGED") 
	self:RegisterEvent("PLAYER_FOCUS_CHANGED") 
	self:RegisterEvent("PARTY_MEMBERS_CHANGED") 
	self:RegisterEvent("PARTY_LEADER_CHANGED") 
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("CVAR_UPDATE")

	self:SetScript("OnEvent", function(self, event, unit)
		callback = specificevents[event]
		if callback then
			callback(unit)
		end
		callback = false
	end)
end

local spellfriendly
local spellenemy

function KUnits_UnitRange_OnLoad(self)
	local framerefs = {
		["target"] = KUnits_target,
		["party1"] = KUnits_party1,
		["party2"] = KUnits_party2,
		["party3"] = KUnits_party3,
		["party4"] = KUnits_party4,
	}
	local spell = ""
	local time = 0
	self:SetScript("OnUpdate", 
		function(self,elapsed)
			time = time + elapsed
			if time > 0.15 then
				if spellfriendly and spellenemy then
					for unit,frame in pairs(framerefs) do
						if UnitExists(unit) then
							if UnitIsFriend("player", unit) == 1 then
								spell = spellfriendly
							else	
								spell = spellenemy
							end
							if IsSpellInRange(spell, unit) == 1 then
								frame:SetAlpha(1)
							else
								frame:SetAlpha(0.5)
							end
						end
					end
					time = 0
				end
			end		
		end)
end



local cmdfuncs = {
	spellfriendly = function(v) KUnitsDB.spellfriendly = v; spellfriendly = v end,
	spellenemy = function(v) KUnitsDB.spellenemy = v; spellenemy = v end,
	playerscale = function(v) KUnitsDB.playerscale = v; KUnits_player:SetScale(v) end,
	targetscale = function(v) KUnitsDB.targetscale = v; KUnits_target:SetScale(v) end,
	partyscale = function(v) KUnitsDB.partyscale = v; KUnits_party1:SetScale(v); KUnits_party2:SetScale(v); KUnits_party3:SetScale(v); KUnits_party4:SetScale(v); KUnits_partyBG:SetScale(v) end,
	focusscale = function(v) KUnitsDB.focusscale = v; KUnits_focus:SetScale(v) end,
	petscale = function(v) KUnitsDB.petscale = v; KUnits_pet:SetScale(v) end,
}

local cmdtbl = {}
function KUnits_Command(cmd)
	for k in ipairs(cmdtbl) do
		cmdtbl[k] = nil
	end
	for v in gmatch(cmd, "[^ ]+") do
  	tinsert(cmdtbl, v)
  end
  local cb = cmdfuncs[cmdtbl[1]]
  if cb then
  	local s = table.concat(cmdtbl," ",2,#cmdtbl)
  	cb(s)
  else
  	ChatFrame1:AddMessage("Kollektiv Unit Frame Options | /kunits <option>",0,1,0)
  	ChatFrame1:AddMessage("----Range Checking-----",0,1,0)
  	ChatFrame1:AddMessage("spellfriendly <spellname> | value: " .. (KUnitsDB.spellfriendly or "none"),0,1,0)
  	ChatFrame1:AddMessage("spellenemy <spellname> | value: " .. (KUnitsDB.spellenemy or "none"),0,1,0)
  	ChatFrame1:AddMessage("Both above options have to be set so that range checking works",0,1,0)
  	ChatFrame1:AddMessage("----Scaling------------",0,1,0)
  	ChatFrame1:AddMessage("playerscale <number> " .. (KUnitsDB.playerscale or 1.11),0,1,0)
  	ChatFrame1:AddMessage("targetscale <number> " .. (KUnitsDB.targetscale or 1.11),0,1,0)
  	ChatFrame1:AddMessage("partyscale <number> " .. (KUnitsDB.partyscale or 1.18),0,1,0)
  	ChatFrame1:AddMessage("focusscale <number> " .. (KUnitsDB.focusscale or 1.18),0,1,0)
  	ChatFrame1:AddMessage("petscale <number> " .. (KUnitsDB.petscale or 1.0),0,1,0)
  	ChatFrame1:AddMessage("-----------------------",0,1,0)
  end
end

local function KUnits_Options_AddTotemBar()
	for i=1, MAX_TOTEMS do
		local _, child2 = _G["TotemFrameTotem"..i]:GetChildren()
		child2:Hide()
		_G["TotemFrameTotem"..i.."Background"]:Hide()
		_G["TotemFrameTotem"..i.."Icon"]:SetHeight(30)
		_G["TotemFrameTotem"..i.."Icon"]:SetWidth(30)
		_G["TotemFrameTotem"..i.."IconCooldown"].noomnicc = true
		_G["TotemFrameTotem"..i.."IconCooldown"].noCooldownCount = true
	end

	TotemFrame:SetParent(UIParent)
	TotemFrame:Show()
	TotemFrame:ClearAllPoints()
	TotemFrame:SetPoint("TOP",KUnits_player,"BOTTOM")
end

local KEST

local function KEST_OnEvent(self, event, timestamp, eventtype, srcGUID, _, _, dstGUID, dstName, _, spellID)
		if not self.pguid then self.pguid = UnitGUID("player") end
		if event == "PLAYER_ENTERING_WORLD" then self.active = false; self:Hide(); end
		local isES = self.esids[tostring(spellID)]
		local isDstGUID = self.tguid == dstGUID
		if self.pguid ~= srcGUID or not isES then return end
    if eventtype == "SPELL_CAST_SUCCESS" then
    		self.charges = self.maxcharges
        self.active = true
        self.castedtime = timestamp
    		
        self.cooldown:Show()
        CooldownFrame_SetTimer(self.cooldown, GetTime(), 600, 1)
        self.text:SetText(dstName)
        self.text2:SetText(self.charges)
        self.esbar:SetValue(self.charges)
        self.tguid = dstGUID
    elseif eventtype == "SPELL_AURA_REMOVED" and isDstGUID and self.castedtime and self.castedtime + 1 < timestamp then
        self.charges = 0;  
				self.cooldown:Hide()  
 				self.active = false;
    elseif eventtype == "SPELL_HEAL" and isDstGUID and self.charges > 0 then
        self.charges = self.charges - 1
        self.esbar:SetValue(self.charges)
        if self.charges == 1 then self.text2:SetText("") else self.text2:SetText(self.charges) end
    end
   if self.active then self:Show() else self:Hide() end
end

local function KUnits_Options_CreateESTracker(self)	
	self.charges = 0
	self.maxcharges = 8
	self.active = false
	
	self.esids = {
		["974"] = true,		-- ES Rank 1
	
		["32593"] = true, -- ES Rank 2
	
		["32594"] = true, -- ES Rank 3
		["379"] = true, 	-- ES Rank 3 Heal
	
		["49283"] = true, -- ES Rank 4
	
		["49284"] = true, -- ES Rank 5
	}
	
	self:SetWidth(153)
	self:SetHeight(18)
	self:SetPoint("BOTTOM",KUnits_player,"TOP",15,-3)
	self:SetBackdrop({bgFile = nil, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 8, insets = { left = 2, right = 2, top = 2, bottom = 2 }})
	
	local icon = self:CreateTexture(nil,"BACKGROUND")
	icon:SetWidth(15)
	icon:SetHeight(15)
	icon:SetTexture("Interface\\Icons\\Spell_Nature_SkinofEarth")
	icon:SetPoint("RIGHT",self,"LEFT",1,0)
	
	local cooldown = CreateFrame("Cooldown",nil,self)
	cooldown.noomnicc = true
	cooldown:SetReverse(true)
	cooldown:SetFrameStrata("HIGH")
	cooldown:SetWidth(15)
	cooldown:SetHeight(15)
	cooldown:SetPoint("CENTER",icon,"CENTER")
	self.cooldown = cooldown
	
	local esbar = CreateFrame("StatusBar","KUnits_esbar",self,"KUnits_Unit_hp")
	esbar:SetStatusBarTexture("Interface\\Addons\\KUnits\\Images\\statusbar2")
	esbar:SetWidth(150)
	esbar:SetHeight(12)
	esbar:SetPoint("BOTTOM",KUnits_player,"TOP",15,0)
	esbar:SetMinMaxValues(0,8)
	esbar:SetStatusBarColor(1,1,0,.8)
	_G["KUnits_esbarbg"]:SetVertexColor(1,1,0,.25)
	self.esbar = esbar
	self.text = _G["KUnits_esbartext"]
	self.text2 = _G["KUnits_esbartext2"]
	self.text2:SetVertexColor(1,1,1,1)

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent",KEST_OnEvent)
end


local function KUnits_Options_AddRuneBar()
	RuneFrame:SetParent(UIParent)
	RuneFrame:Show()
	RuneFrame:ClearAllPoints()
	RuneFrame:SetPoint("TOP",KUnits_player,"BOTTOM")
end

local function KUnits_PredictHealth(self,elapsed)
	for _,f in ipairs(predict) do
		if not f.disconnected then
			local currValue
			currValue = UnitPower(f.unit, f.manabar.powerType)
			if currValue ~= f.powerCurrValue then
				f.powerCurrValue = currValue
				KUnitsManaBar_Update(f.manabar,f.unit)
			end
			currValue = UnitHealth(f.unit)
			if currValue ~= f.healthbar.healthCurrValue then
				f.healthCurrValue = currValue
				KUnitsHealthBar_Update(f.healthbar,f.unit)
			end
		end
	end
end

local function KUnits_Options_VariablesLoaded(self)
	SlashCmdList["KUnits"] = KUnits_Command
 	SLASH_KUnits1 = "/kunits"
 	spellenemy = KUnitsDB.spellenemy
 	spellfriendly = KUnitsDB.spellfriendly
	DisableBlizzFrames()
	cmdfuncs.playerscale(KUnitsDB.playerscale or 1.11)
	cmdfuncs.targetscale(KUnitsDB.targetscale or 1.11)
	cmdfuncs.partyscale(KUnitsDB.partyscale or 1.18)
	cmdfuncs.focusscale(KUnitsDB.focusscale or 1.18)
	cmdfuncs.petscale(KUnitsDB.petscale or 1.0)
	
	self:SetScript("OnUpdate",KUnits_PredictHealth)
	
	local _,lclass = UnitClass("player")
	if lclass == "SHAMAN" then KUnits_Options_AddTotemBar(); KEST = CreateFrame("Frame","KEST",UIParent); KUnits_Options_CreateESTracker(KEST) end
	if lclass == "DEATHKNIGHT" then KUnits_Options_AddRuneBar() end
end


local KUnits_Options = CreateFrame("Frame")
KUnits_Options:SetScript("OnEvent", KUnits_Options_VariablesLoaded)
KUnits_Options:RegisterEvent("VARIABLES_LOADED")
