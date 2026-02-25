-- 创建主框架
VoidFrame = CreateFrame("Frame", "VoidModFrame", UIParent)
VoidFrame:RegisterEvent("PLAYER_LOGIN")                --用户登录
VoidFrame:RegisterEvent("UNIT_AURA")                   --获得或消失的增益、减益、状态或物品加成
VoidFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")    -- 当法术成功施放时触发
VoidFrame:RegisterEvent("CHAT_MSG_WHISPER")            --收到其他玩家的低语
VoidFrame:RegisterEvent("PARTY_INVITE_REQUEST")        --排本邀请
VoidFrame:RegisterEvent("GROUP_INVITE_CONFIRMATION")   --队伍邀请
VoidFrame:RegisterEvent("UNIT_COMBAT")                 --当 NPC 或玩家参与战斗并受到伤害时触发
VoidFrame:RegisterEvent("UNIT_RESISTANCES")            --当单位抗性发生变化时
VoidFrame:RegisterEvent("SKILL_LINES_CHANGED")         --当玩家技能列表内容发生变化时(武器熟练度)
VoidFrame:RegisterEvent("PLAYER_TOTEM_UPDATE")         --当图腾施放或被摧毁（召回或击杀）时
VoidFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") --战斗日志

VoidFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        self:Initialize()
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            self:CheckBloodlust()
            self:UpdateShieldInfo()
        end
        -- self:Void_UpdatePlayerInfo()
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

VoidFrame:SetScript("OnUpdate", function(self, delta)
    self:Void_UpdateTotemTimeLeft()
    self:UpdateWeaponEnchant()
    -- self:Void_UpdateSkillLineInfo()
    self:Void_UpdateTotemDance()
    self:Void_UpdatePlayerInfo()
end)

function VoidFrame:Initialize()
    -- 加载数据库
    InitDatabase()

    -- 调试打印区域
    local className, classFilename, classId = UnitClass("player")
    print("|cFF33937FVoidMod|r |cFF69CCF0Player|r |cFF00FF00Info:|r \n » Name: " ..
        className .. "\n » FileName: " .. classFilename .. "\n » Id: " .. classId)

    -- WOW客户端信息
    self:ClientInfo()

    -- 创建属性显示框架
    if VoidModClassicCharacterDB.status.PlayerInfo == true then
        self:Void_CreatePlayerInfo()
    end
    if VoidModClassicCharacterDB.status.SkillLine == true then
        self:Void_CreateSkillLineInfo()
    end

    -- 职业框架
    local _, _, class_id = UnitClass("player")

    -- 萨满
    if class_id == 7 then
        if VoidModClassicCharacterDB.status.ShieldInfo == true then
            self:Void_CreateShieldInfo()
        end
        if VoidModClassicCharacterDB.status.TotemInfo == true then
            self:Void_CreateTotemInfo()
            self:Void_CreateTotemDance()
            self:Void_CreateTotemTool()
        end
    end

    -- 注册斜杠命令
    SLASH_VOID_MOD1 = "/void"
    SlashCmdList["VOID_MOD"] = function(msg)
        self:HandleSlashCommand(msg)
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000恶！龙！咆！哮！|r|cFF00FF00启动！|r")
    DEFAULT_CHAT_FRAME:AddMessage("周年服 |cFFFF69B4月溪晓月|r 公会")
end

function VoidFrame:HandleSlashCommand(msg)
    local command = strlower(strtrim(msg))

    if command == "bls test" then
        self:TestAlert("ogg")
    elseif command == "bls wav" then
        self:TestAlert("wav")
    elseif command == "bls debug" then
        self:DebugBuffs()
    elseif command == "bls ele" then
        self:DebugEleBuff()
    elseif command == "si test" then
        self:TestDisplay()
    elseif string.find(command, "show") then
        for index, value in ipairs(strsplittable(" ", command)) do
            if value == "shield" then
                VoidModClassicCharacterDB.status.ShieldInfo = true
            elseif value == "player" then
                VoidModClassicCharacterDB.status.PlayerInfo = true
            elseif value == "skillline" then
                VoidModClassicCharacterDB.status.SkillLineInfo = true
            elseif value == "totem" then
                VoidModClassicCharacterDB.status.TotemInfo = true
            end
        end
        ReloadUI()
    elseif string.find(command, "hide") then
        for index, value in ipairs(strsplittable(" ", command)) do
            if value == "shield" then
                VoidModClassicCharacterDB.status.Shield = false
            elseif value == "player" then
                VoidModClassicCharacterDB.status.PlayerInfo = false
            elseif value == "skillline" then
                VoidModClassicCharacterDB.status.SkillLineInfo = false
            elseif value == "totem" then
                VoidModClassicCharacterDB.status.TotemInfo = false
            end
        end
        ReloadUI()
    elseif command == "info" then
        self:Void_PlayerInfo()
    elseif command == "test" then
        self:GetGroupBuffs()
    else
        self:ClientInfo()
        self:PrintHelp()
    end
end

function VoidFrame:ClientInfo()
    local version, build, date, toc_version = GetBuildInfo()
    print("|cFF33937FVoidMod|r |cFF69CCF0Client|r |cFF00FF00Info:|r \n » Version: " ..
        version .. "\n » Build: " .. build .. "\n » Date: " .. date .. "\n » TocVersion: " .. toc_version)
    print("|cFF00FF00VersionDate|r 202602061930")
end

function VoidFrame:PrintHelp()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00恶龙咆哮菜单:|r")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 /void show|r |cFA500FF0module1 module2|r - 开启模块")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 /void hide|r |cFA500FF0module1 module2|r - 关闭模块")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 /void|r - 显示帮助")
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00可选module:|r")
    DEFAULT_CHAT_FRAME:AddMessage("|cFA500FF0 shield|r - 萨满护盾监控")
    DEFAULT_CHAT_FRAME:AddMessage("|cFA500FF0 player|r - 角色属性面板")
    DEFAULT_CHAT_FRAME:AddMessage("|cFA500FF0 skillline|r - 武器熟练度面板")
    DEFAULT_CHAT_FRAME:AddMessage("|cFA500FF0 totem|r - 萨满图腾监控")
end
