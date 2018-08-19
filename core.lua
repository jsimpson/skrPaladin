-- buff id
local inquisitionId = 84963
local retributionId = 3

local _, class = UnitClass('PLAYER')
if class ~= 'PALADIN' or GetSpecialization() ~= retributionId or IsPlayerSpell(inquisitionId) == false then return end

-- config
local alpha = 0.4
local size = 34
local position = {'BOTTOM', UIParent, 'BOTTOM', -249, 116}

-- textures
local tex = [[Interface\ICONS\inv_inscription_parchmentvar02]]
local inquisitionTex = [[Interface\ICONS\Spell_paladin_inquisition]]

-- base frame
local f = CreateFrame('Frame', 'skrPaladin', UIParent)
f:SetSize(size, size)
f:SetPoint(unpack(position))
f:SetAlpha(alpha)

-- events
f:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
f:RegisterEvent('PLAYER_REGEN_ENABLED')
f:RegisterEvent('PLAYER_REGEN_DISABLED')

-- icon
local i = f:CreateTexture(nil, 'OVERLAY')
i:SetTexture(tex)
i:SetTexCoord(.08, .92, .08, .92)
i:SetAllPoints(f)
f.icon = i

-- border
f:CreateBeautyBorder(13)
f:SetBeautyBorderPadding(2)

-- background
local bg = f:CreateTexture(nil, 'BACKGROUND', nil, -8)
bg:SetTexture('Interface\\AddOns\\nMainbar\\Media\\textureBackground')
bg:SetPoint('TOPRIGHT', f, 14, 12)
bg:SetPoint('BOTTOMLEFT', f, -14, -16)

-- duration
local duration = f:CreateFontString(nil, "OVERLAY")
duration:SetAllPoints(f)
duration:SetFont(STANDARD_TEXT_FONT, 18, 'OUTLINE')
duration:SetShadowOffset(0, 0)
duration:SetDrawLayer('OVERLAY')

-- event handler
local active = false
local OnEventHandler = function(self, event)
	if event == 'PLAYER_REGEN_DISABLED' then
		f:SetAlpha(1)
	elseif event == 'PLAYER_REGEN_ENABLED' then
		f:SetAlpha(alpha)
	elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		local _, message, _, sourceGUID, _, _, _, _, _, _, _, spellId = CombatLogGetCurrentEventInfo()
		if sourceGUID == UnitGUID('PLAYER') and spellId ~= nil and spellId == inquisitionId then
			if message == 'SPELL_AURA_REMOVED' then
				active = false

				f.icon:SetTexture(tex)
				duration:SetText()
			elseif message == 'SPELL_AURA_APPLIED' then
				active = true

				f.icon:SetTexture(inquisitionTex)
				duration:SetFormattedText("%d", remainingTime())
			elseif message == 'SPELL_AURA_REFRESH' then
				active = true

				duration:SetFormattedText("%d", remainingTime())
			end
		end
	end
end

-- update handler
local timeSinceLastUpdate = 0
local OnUpdate = function(self, elapsed)
	timeSinceLastUpdate = timeSinceLastUpdate + elapsed
	if timeSinceLastUpdate > 1.0 then
		timeSinceLastUpdate = 0

		if active then
			duration:SetFormattedText("%d", remainingTime())
		end
	end
end

-- remaining time on the buff
function remainingTime()
	for i=1,40 do
		local name, _, _, _, _, expirationTime, _, _, _, spellId = UnitBuff('PLAYER', i)
		if spellId == inquisitionId then
			if expirationTime then
				return expirationTime - GetTime()
			else
				return 0
			end
		end
	end
	return 0
end

-- connect the event and update handlers
f:SetScript('OnEvent', OnEventHandler)
f:SetScript("OnUpdate", OnUpdate)
