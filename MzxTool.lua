-- 创建主框架
MzxToolFrame = CreateFrame("Frame", "VoidModFrame", UIParent)
MzxToolFrame:RegisterEvent("PLAYER_LOGIN")                -- 用户登录
MzxToolFrame:RegisterEvent("UNIT_AURA")                   -- 获得或消失的增益、减益、状态或物品加成
MzxToolFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")    -- 当法术成功施放时触发
MzxToolFrame:RegisterEvent("CHAT_MSG_WHISPER")            -- 收到其他玩家的低语
MzxToolFrame:RegisterEvent("PARTY_INVITE_REQUEST")        -- 排本邀请
MzxToolFrame:RegisterEvent("GROUP_INVITE_CONFIRMATION")   -- 队伍邀请
MzxToolFrame:RegisterEvent("UNIT_COMBAT")                 -- 当 NPC 或玩家参与战斗并受到伤害时触发
MzxToolFrame:RegisterEvent("UNIT_RESISTANCES")            -- 当单位抗性发生变化时
MzxToolFrame:RegisterEvent("SKILL_LINES_CHANGED")         -- 当玩家技能列表内容发生变化时(武器熟练度)
MzxToolFrame:RegisterEvent("PLAYER_TOTEM_UPDATE")         -- 当图腾施放或被摧毁（召回或击杀）时
MzxToolFrame:RegisterEvent("PLAYER_REGEN_DISABLED")       -- 进入战斗（脱离恢复状态）
MzxToolFrame:RegisterEvent("PLAYER_REGEN_ENABLED")        -- 脱离战斗（进入恢复状态）
MzxToolFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- 战斗日志

MzxToolFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        self:Initialize()
        C_Timer.After(0, function()
            self:InitializeWorld() -- 你的扫描函数
        end)
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            self:CheckBloodlust()
            self:UpdateShieldInfo()
        end
        -- self:Void_UpdatePlayerInfo()
    end

    if event == "PLAYER_REGEN_DISABLED" then
        -- 玩家信息
        local className, classFilename, classId = UnitClass("player")
        if classId == 7 then
            self:TotemRegenDisabled()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- 玩家信息
        local className, classFilename, classId = UnitClass("player")
        if classId == 7 then
            self:TotemRegenEnabled()
        end
    end

    if event == "UNIT_RESISTANCES" or event == "UNIT_COMBAT" or event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- self:Void_UpdatePlayerInfo()
    end

    if event == "CHAT_MSG_WHISPER" then
        self:MessageStart(...)
    end

    if event == "PARTY_INVITE_REQUEST" or event == "GROUP_INVITE_CONFIRMATION" then
        local unit = ...
        if unit ~= nil then
            self:PartyStart(...)
        end
    end

    if event == "PLAYER_TOTEM_UPDATE" then
        self:Void_UpdateTotemInfo()
    end

    if event == "SKILL_LINES_CHANGED" then
        self:Void_UpdateSkillLineInfo()
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:GetGroupBuffs()
    end
end)

MzxToolFrame:SetScript("OnUpdate", function(self, delta)
    self:Void_UpdateTotemTimeLeft()
    self:UpdateWeaponEnchant()
    -- self:Void_UpdateSkillLineInfo()
    self:Void_UpdateTotemDance()
    self:Void_UpdatePlayerInfo()
end)

function MzxToolFrame:Initialize()
    -- 加载数据库
    InitDatabase()

    -- 玩家信息
    local className, classFilename, classId = UnitClass("player")

    -- 调试打印区域
    if MzxToolClassicCharacterDB.status.Debug then
        print("|cFF33937FMzxToolbox|r |cFF69CCF0Player|r |cFF00FF00Info:|r \n » Name: " ..
            className .. "\n » FileName: " .. classFilename .. "\n » Id: " .. classId)

        -- WOW客户端信息
        self:ClientInfo()
    end

    -- 创建属性显示框架
    if MzxToolClassicCharacterDB.status.PlayerInfo == true then
        self:Void_CreatePlayerInfo()
    end
    if MzxToolClassicCharacterDB.status.SkillLine == true then
        self:Void_CreateSkillLineInfo()
    end

    -- 萨满
    if classId == 7 then
        if MzxToolClassicCharacterDB.status.ShieldInfo == true then
            self:Void_CreateShieldInfo()
        end
        if MzxToolClassicCharacterDB.status.TotemInfo == true then
            self:Void_CreateTotemInfo()
            self:Void_CreateTotemDance()
        end
    end

    -- 注册斜杠命令
    SLASH_VOID_MOD1 = "/mzxtoolbox"
    SLASH_VOID_MOD2 = "/voidmod"
    SLASH_VOID_MOD3 = "/void"
    SLASH_VOID_MOD4 = "/moon"
    SLASH_VOID_MOD5 = "/mzx"
    SLASH_VOID_MOD6 = "/mt"
    SLASH_VOID_MOD7 = "/vm"
    SlashCmdList["VOID_MOD"] = function(msg)
        self:HandleSlashCommand(msg)
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000恶！龙！咆！哮！|r|cFF00FF00启动！|r")
    DEFAULT_CHAT_FRAME:AddMessage("周年服 |cFFFF69B4月溪晓月|r 公会")
end

-- 延后加载
function MzxToolFrame:InitializeWorld()
    -- 职业框架
    -- 玩家信息
    local className, classFilename, classId = UnitClass("player")

    -- 萨满
    if classId == 7 then
        if MzxToolClassicCharacterDB.status.TotemTool == true then
            self:Void_CreateTotemTool()
        end
    end

    -- 法师
    if classId == 8 then
        if MzxToolClassicCharacterDB.status.TeleportTool == true then
            self:Void_CreateTeleportTool()
        end
    end
end
