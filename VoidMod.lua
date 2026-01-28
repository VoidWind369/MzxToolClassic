-- 创建主框架
VoidFrame = CreateFrame("Frame", "VoidModFrame", UIParent)
VoidFrame:RegisterEvent("PLAYER_LOGIN")
VoidFrame:RegisterEvent("UNIT_AURA")
VoidFrame:RegisterEvent("CHAT_MSG_WHISPER")
VoidFrame:RegisterEvent("PARTY_INVITE_REQUEST")
VoidFrame:RegisterEvent("UNIT_COMBAT")
VoidFrame:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
VoidFrame:RegisterEvent("GROUP_INVITE_CONFIRMATION")
VoidFrame:RegisterEvent("LFG_ROLE_CHECK_SHOW")
VoidFrame:RegisterEvent("UNIT_RESISTANCES")
VoidFrame:RegisterEvent("SKILL_LINES_CHANGED")

VoidFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        self:Initialize()
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            self:CheckBloodlust()
            self:UpdateTotemWeaponStacks()
        end
        self:Void_UpdatePlayerInfo()
    elseif event == "UNIT_RESISTANCES" then
        self:Void_UpdatePlayerInfo()
    elseif event == "CHAT_MSG_WHISPER" then
        self:MessageStart(...)
    elseif event == "PARTY_INVITE_REQUEST" or event == "GROUP_INVITE_CONFIRMATION" then
        local unit = ...
        if unit ~= nil then
            self:PartyStart(...)
        end
    elseif event == "UNIT_COMBAT" then
        self:Void_UpdatePlayerInfo()
    elseif event == "SKILL_LINES_CHANGED" then
        self:Void_UpdateSkillLineInfoDisplay()
    end
end)

VoidFrame:SetScript("OnUpdate", function(self, delta)
    VoidFrame:Void_UpdateTotemInfoDisplay()
end)

function VoidFrame:Initialize()
    -- 加载数据库
    VoidModClassicDB = VoidModClassicDB or {}
    VoidModClassicCharacterDB = VoidModClassicCharacterDB or {}

    self:GetSkillLineInfo()

    -- 调试打印区域
    local className, classFilename, classId = UnitClass("player")
    print("|cFF33937FVoidMod|r |cFF69CCF0Player|r |cFF00FF00Info:|r \n » Name: " ..
        className .. "\n » FileName: " .. classFilename .. "\n » Id: " .. classId)

    for index = 1, 4 do
        local arg1, totemName, startTime, duration, icon = GetTotemInfo(index)
        local est_dur = startTime + duration - GetTime()
        print(totemName .. "  " .. est_dur)
    end

    -- WOW客户端信息
    self:ClientInfo()

    -- 创建漩涡武器框架
    self:CreateDotProgress()


    -- 创建属性显示框架
    self:Void_CreatePlayerInfo()
    self:Void_CreateSkillLineInfo()
    self:Void_CreateTotemInfo()

    -- 注册斜杠命令
    SLASH_VOID_MOD1 = "/void"
    SlashCmdList["VOID_MOD"] = function(msg)
        self:HandleSlashCommand(msg)
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000恶！龙！咆！哮！|r|cFF00FF00启动！|r")
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
    elseif command == "twm test" then
        self:TestDisplay()
    elseif command == "twm show" then
        self.dotFrame:Show()
    elseif command == "twm hide" then
        self.dotFrame:Hide()
    elseif command == "pi show" then
        self.voidPlayerInfo_UP:Show()
        self.voidPlayerInfo_DOWN:Show()
    elseif command == "pi hide" then
        self.voidPlayerInfo_UP:Hide()
        self.voidPlayerInfo_DOWN:Hide()
    elseif command == "sli show" then
        self.voidSkillLineInfo:Show()
    elseif command == "sli hide" then
        self.voidSkillLineInfo:Hide()
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
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00恶龙咆哮:|r")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void twm show|r - 显示萨满护盾监控")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void twm hide|r - 关闭萨满护盾监控")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void pi show|r - 显示角色属性面板")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void pi hide|r - 关闭角色属性面板")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void sli show|r - 显示武器熟练度面板")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void sli hide|r - 关闭武器熟练度面板")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void|r - 显示帮助")
end
