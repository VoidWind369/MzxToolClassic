-- 创建主框架
VoidFrame = CreateFrame("Frame", "VoidModFrame", UIParent)
VoidFrame:RegisterEvent("PLAYER_LOGIN")              --用户登录
VoidFrame:RegisterEvent("UNIT_AURA")                 --获得或消失的增益、减益、状态或物品加成
VoidFrame:RegisterEvent("CHAT_MSG_WHISPER")          --收到其他玩家的低语
VoidFrame:RegisterEvent("PARTY_INVITE_REQUEST")      --排本邀请
VoidFrame:RegisterEvent("GROUP_INVITE_CONFIRMATION") --队伍邀请
VoidFrame:RegisterEvent("UNIT_COMBAT")               --当 NPC 或玩家参与战斗并受到伤害时触发
VoidFrame:RegisterEvent("UNIT_RESISTANCES")          --当单位抗性发生变化时
VoidFrame:RegisterEvent("SKILL_LINES_CHANGED")       --当玩家技能列表内容发生变化时(武器熟练度)

VoidFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        self:Initialize()
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            self:CheckBloodlust()
            self:UpdateShieldInfo()
        end
        self:Void_UpdatePlayerInfo()
    elseif event == "UNIT_RESISTANCES" or "UNIT_COMBAT" then
        self:Void_UpdatePlayerInfo()
    elseif event == "CHAT_MSG_WHISPER" then
        self:MessageStart(...)
    elseif event == "PARTY_INVITE_REQUEST" or event == "GROUP_INVITE_CONFIRMATION" then
        local unit = ...
        if unit ~= nil then
            self:PartyStart(...)
        end
        -- elseif event == "SKILL_LINES_CHANGED" then
        --     self:Void_UpdateSkillLineInfo()
    end
end)

VoidFrame:SetScript("OnUpdate", function(self, delta)
    self:Void_UpdateTotemInfo()
    self:UpdateWeaponEnchant()
    self:Void_UpdateSkillLineInfo()
end)

function VoidFrame:Initialize()
    -- 加载数据库
    InitDatabase()

    -- 调试打印区域
    local className, classFilename, classId = UnitClass("player")
    print("|cFF33937FVoidMod|r |cFF69CCF0Player|r |cFF00FF00Info:|r \n » Name: " ..
        className .. "\n » FileName: " .. classFilename .. "\n » Id: " .. classId)
    -- local hand_info = self:Void_GetWeaponEnchantInfo()
    -- local illusion_info = C_TransmogCollection.GetIllusionInfo(hand_info.main.enchant_id)
    -- print(hand_info.main.enchant_id, illusion_info.visualID, illusion_info.sourceID)

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
    else
        self:ClientInfo()
        self:PrintHelp()
    end
end

function VoidFrame:ClientInfo()
    local version, build, date, toc_version = GetBuildInfo()
    print("|cFF33937FVoidMod|r |cFF69CCF0Client|r |cFF00FF00Info:|r \n » Version: " ..
        version .. "\n » Build: " .. build .. "\n » Date: " .. date .. "\n » TocVersion: " .. toc_version)
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
