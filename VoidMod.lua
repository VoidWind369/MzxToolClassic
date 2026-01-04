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

VoidFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        self:Initialize()
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            self:CheckBloodlust()
            self:UpdateTotemWeaponStacks()
        end
        self:Void_UpdatePlayerInfoDisplay()
    elseif event == "UNIT_RESISTANCES" then
        self:Void_UpdatePlayerInfoDisplay()
    elseif event == "CHAT_MSG_WHISPER" then
        self:MessageStart(...)
    elseif event == "PARTY_INVITE_REQUEST" or event == "GROUP_INVITE_CONFIRMATION" then
        local unit = ...
        if unit ~= nil then
            self:PartyStart(...)
        end
    elseif event == "UNIT_COMBAT" then
        self:Void_UpdatePlayerInfoDisplay()
    elseif event == "LFG_ROLE_CHECK_SHOW" then
        print("排本")
        C_Timer.After(0.1, function() LFDRoleCheckPopupAcceptButton:Click() end)
    end
end)

function VoidFrame:Initialize()
    -- 加载数据库
    VoidModClassicDB = VoidModClassicDB or {}
    VoidModClassicCharacterDB = VoidModClassicCharacterDB or {}

    -- 调试打印区域
    local className, classFilename, classId = UnitClass("player")
    print("|cFF33937FVoidMod|r |cFF69CCF0Player|r |cFF00FF00Info:|r \n » Name: " .. className .. "\n » FileName: " .. classFilename .. "\n » Id: " .. classId)

    -- WOW客户端信息
    self:ClientInfo()

    -- 创建漩涡武器框架
    self:CreateDotProgress()


    -- 创建属性显示框架
    self:Void_CreatePlayerInfoDisplay()

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
    elseif command == "twm move" then
        self:ToggleMoveMode()
    elseif command == "twm reset" then
        self:ResetPosition()
    elseif command == "twm scale" then
        self:ToggleScale()
    elseif command == "info" then
        self:Void_PlayerInfo()
    else
        self:ClientInfo()
        self:PrintHelp()
    end
end

function VoidFrame:ClientInfo()
    local version, build, date, toc_version = GetBuildInfo()
    print("|cFF33937FVoidMod|r |cFF69CCF0Client|r |cFF00FF00Info:|r \n » Version: " .. version .. "\n » Build: " .. build .. "\n » Date: " .. date .. "\n » TocVersion: " .. toc_version)
end

function VoidFrame:PrintHelp()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00恶龙咆哮:|r")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void bls test|r - 测试提示效果")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void bls debug|r - 显示当前所有buff和ID")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void bls ele|r - 显示萨满激活护盾")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void twm test|r - 测试显示效果")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void twm move|r - 切换移动模式")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void twm scale|r - 切换大小")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void twm reset|r - 重置位置和大小")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void|r - 显示帮助")
end