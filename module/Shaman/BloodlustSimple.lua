-- ============================================================================
-- 模块：嗜血/英勇提示 (BloodlustSimple)
-- ============================================================================
-- 职责：
--   1. 监控玩家身上的嗜血/英勇等加速光环，获得时弹出屏幕提示并播放语音；
--   2. 10 秒内防止重复播放；
--   3. 提供 /void testalert 等调试命令入口。
--
-- 数据依赖：MzxShamanData.Bloodlust（位于 module/Shaman/Data/ShamanData.lua）
-- 数据持久化：无（运行时状态）
-- 注意：语音文件路径由用户明确保留，此处仅做数据分离，未改动路径
-- ============================================================================

local bloodlust_data = MzxShamanData.Bloodlust   -- 数据层快捷引用

-- 运行时状态（不持久化，仅在当前会话有效）
local bloodlust_state = {
    hasBloodlust = false,
    lastPlayTime = 0,
}

-- ----------------------------------------------------------------------------
-- 监控嗜血buff：遍历数据层的法术 ID 表，发现有效光环则触发提示
-- ----------------------------------------------------------------------------
function MzxToolFrame:CheckBloodlust()
    local foundBuff = false
    local buffName = ""
    local spellIdFound = 0

    for bloodlustId, _ in pairs(bloodlust_data.spell_ids) do
        local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", bloodlustId)
        if auraData then
            foundBuff = true
            buffName = auraData.name
            spellIdFound = auraData.spellId
            break
        end
    end

    -- 处理buff状态变化
    if foundBuff and not bloodlust_state.hasBloodlust then
        self:OnBloodlustGained(buffName, spellIdFound, "ogg")
        bloodlust_state.hasBloodlust = true
    elseif not foundBuff and bloodlust_state.hasBloodlust then
        bloodlust_state.hasBloodlust = false
    end
end

-- ----------------------------------------------------------------------------
-- 嗜血获得时的处理：聊天框提示、播放语音、屏幕警报
-- @param buffName 光环名称
-- @param spellId  法术 ID
-- @param ogg      语音标识（"ogg" 或其他）
-- ----------------------------------------------------------------------------
function MzxToolFrame:OnBloodlustGained(buffName, spellId, ogg)
    local currentTime = GetTime()

    -- 防止重复播放（冷却秒数）
    if currentTime - bloodlust_state.lastPlayTime < bloodlust_data.cooldown_sec then
        return
    end

    bloodlust_state.lastPlayTime = currentTime

    -- 在聊天框显示
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000※ 你获得了 " .. buffName .. " (ID:" .. spellId .. ")！|r")

    -- 播放语音
    self:PlayBloodlustVoice(ogg)

    -- 屏幕提示
    self:ShowSimpleAlert(buffName)
end

-- ----------------------------------------------------------------------------
-- 播放外部语音文件
-- @param ogg 语音标识（"ogg" 使用 ogg 路径，其他使用 wav 路径）
-- ----------------------------------------------------------------------------
function MzxToolFrame:PlayBloodlustVoice(ogg)
    if PlaySoundFile then
        if ogg == "ogg" then
            PlaySoundFile(bloodlust_data.voice_ogg, "Master")
        else
            PlaySoundFile(bloodlust_data.voice_wav, "Master")
        end
    else
        -- 备选：使用游戏内置音效
        PlaySound(569200, "Master") -- 嗜血音效
    end
end

-- ----------------------------------------------------------------------------
-- 屏幕中央警报提示（大字淡出）
-- @param buffName 提示文本
-- ----------------------------------------------------------------------------
function MzxToolFrame:ShowSimpleAlert(buffName)
    -- 屏幕中央错误提示
    UIErrorsFrame:AddMessage("※ " .. buffName .. "！", 1.0, 1.0, 0.0, 1.0)

    -- 创建大文字提示
    if not self.alertText then
        self.alertText = UIParent:CreateFontString(nil, "OVERLAY", MzxShamanData.Font.huge)
        self.alertText:SetPoint("CENTER", 0, 100)
        self.alertText:SetTextColor(1, 0, 0, 1)
        self.alertText:SetShadowColor(0, 0, 0, 1)
        self.alertText:SetShadowOffset(2, -2)
    end

    self.alertText:SetText("※ " .. buffName .. "！")
    self.alertText:SetAlpha(1)

    -- 淡出动画
    self.alertText.fadeInfo = {}
    self.alertText.fadeInfo.mode = "OUT"
    self.alertText.fadeInfo.timeToFade = 3
    self.alertText.fadeInfo.startAlpha = 1
    self.alertText.fadeInfo.endAlpha = 0
    UIFrameFade(self.alertText, self.alertText.fadeInfo)
end

-- ----------------------------------------------------------------------------
-- 调试：检测所有嗜血Buff状态（任意职业，需组队有嗜血职业）
-- ----------------------------------------------------------------------------
function MzxToolFrame:DebugBuffs()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00=== 嗜血Buff检测 ===|r")
    for bloodlustId, bloodlustName in pairs(bloodlust_data.spell_ids) do
        local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", bloodlustId)
        if auraData then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00已激活|r" .. bloodlustName:sub(1, 10) .. (auraData.name or "未知") .. " (ID: " .. (auraData.spellId or "?") .. ")|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000未找到|r" .. bloodlustName)
        end
    end

    -- 显示当前嗜血状态
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00当前嗜血状态: " .. (bloodlust_state.hasBloodlust and "|cFF00FF00已激活|r" or "|cFFFF0000未激活|r"))
end

-- ----------------------------------------------------------------------------
-- 调试：检测萨满三种元素护盾（萨满职业时使用）
-- ----------------------------------------------------------------------------
function MzxToolFrame:DebugEleBuff()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00护盾Buff检测|r")
    for spellId, spellName in pairs(bloodlust_data.shield_spell_ids) do
        local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", spellId)
        if auraData then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF888888" .. (auraData.name or "未知") .. " (ID: " .. (auraData.spellId or "?") .. ")|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000未找到" .. spellName .. "护盾|r")
        end
    end
end

-- ----------------------------------------------------------------------------
-- 调试：嗜血提示测试
-- @param ogg 语音标识
-- ----------------------------------------------------------------------------
function MzxToolFrame:TestAlert(ogg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00测试嗜血提示...|r")
    self:OnBloodlustGained("嗜血测试", 2825, ogg)
end
