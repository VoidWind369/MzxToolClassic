-- 创建主框架
VoidFrame = CreateFrame("Frame", "VoidModFrame", UIParent)
VoidFrame:RegisterEvent("PLAYER_LOGIN")                -- 用户登录
VoidFrame:RegisterEvent("UNIT_AURA")                   -- 获得或消失的增益、减益、状态或物品加成
VoidFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")    -- 当法术成功施放时触发
VoidFrame:RegisterEvent("CHAT_MSG_WHISPER")            -- 收到其他玩家的低语
VoidFrame:RegisterEvent("PARTY_INVITE_REQUEST")        -- 排本邀请
VoidFrame:RegisterEvent("GROUP_INVITE_CONFIRMATION")   -- 队伍邀请
VoidFrame:RegisterEvent("UNIT_COMBAT")                 -- 当 NPC 或玩家参与战斗并受到伤害时触发
VoidFrame:RegisterEvent("UNIT_RESISTANCES")            -- 当单位抗性发生变化时
VoidFrame:RegisterEvent("SKILL_LINES_CHANGED")         -- 当玩家技能列表内容发生变化时(武器熟练度)
VoidFrame:RegisterEvent("PLAYER_TOTEM_UPDATE")         -- 当图腾施放或被摧毁（召回或击杀）时
VoidFrame:RegisterEvent("PLAYER_REGEN_DISABLED")       -- 进入战斗（脱离恢复状态）
VoidFrame:RegisterEvent("PLAYER_REGEN_ENABLED")        -- 脱离战斗（进入恢复状态）
VoidFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- 战斗日志

VoidFrame:SetScript("OnEvent", function(self, event, ...)
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

    -- 玩家信息
    local className, classFilename, classId = UnitClass("player")

    -- 调试打印区域
    if VoidModClassicCharacterDB.status.Debug then
        print("|cFF33937FMzxToolbox|r |cFF69CCF0Player|r |cFF00FF00Info:|r \n » Name: " ..
            className .. "\n » FileName: " .. classFilename .. "\n » Id: " .. classId)

        -- WOW客户端信息
        self:ClientInfo()
    end

    -- 创建属性显示框架
    if VoidModClassicCharacterDB.status.PlayerInfo == true then
        self:Void_CreatePlayerInfo()
    end
    if VoidModClassicCharacterDB.status.SkillLine == true then
        self:Void_CreateSkillLineInfo()
    end

    -- 萨满
    if classId == 7 then
        if VoidModClassicCharacterDB.status.ShieldInfo == true then
            self:Void_CreateShieldInfo()
        end
        if VoidModClassicCharacterDB.status.TotemInfo == true then
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
function VoidFrame:InitializeWorld()
    -- 职业框架
    -- 玩家信息
    local className, classFilename, classId = UnitClass("player")

    -- 萨满
    if classId == 7 then
        if VoidModClassicCharacterDB.status.TotemTool == true then
            self:Void_CreateTotemTool()
        end
    end
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
    elseif command == "new" then
        NewDatabase()
    elseif string.find(command, "show") then
        for index, value in ipairs(strsplittable(" ", command)) do
            if value == "1" then
                VoidModClassicCharacterDB.status.ShieldInfo = true
            elseif value == "2" then
                VoidModClassicCharacterDB.status.PlayerInfo = true
            elseif value == "3" then
                VoidModClassicCharacterDB.status.SkillLine = true
            elseif value == "4" then
                VoidModClassicCharacterDB.status.TotemInfo = true
            elseif value == "5" then
                VoidModClassicCharacterDB.status.TotemTool = true
            else
                VoidModClassicCharacterDB.status = {
                    ShieldInfo = true,
                    PlayerInfo = true,
                    SkillLine = true,
                    TotemInfo = true,
                    TotemTool = true
                }
            end
        end
        ReloadUI()
    elseif string.find(command, "hide") then
        for index, value in ipairs(strsplittable(" ", command)) do
            if value == "1" then
                VoidModClassicCharacterDB.status.Shield = false
            elseif value == "2" then
                VoidModClassicCharacterDB.status.PlayerInfo = false
            elseif value == "3" then
                VoidModClassicCharacterDB.status.SkillLine = false
            elseif value == "4" then
                VoidModClassicCharacterDB.status.TotemInfo = false
            elseif value == "5" then
                VoidModClassicCharacterDB.status.TotemTool = false
            else
                VoidModClassicCharacterDB.status = {
                    ShieldInfo = false,
                    PlayerInfo = false,
                    SkillLine = false,
                    TotemInfo = false,
                    TotemTool = false
                }
            end
        end
        ReloadUI()
    elseif command == "debug on" then
        VoidModClassicCharacterDB.status.Debug = true
        ReloadUI()
    elseif command == "debug off" then
        VoidModClassicCharacterDB.status.Debug = false
        ReloadUI()
    elseif command == "info" then
        self:Void_PlayerInfo()
    elseif command == "test" then
        self:GetPowerWordShield()
    else
        self:ClientInfo()
        self:PrintHelp()
    end
end

function VoidFrame:ClientInfo()
    local version, build, date, toc_version = GetBuildInfo()
    print("|cFF33937FWoW|r |cFF69CCF0Client|r |cFF00FF00Info:|r \n » Version: " ..
        version .. "\n » Build: " .. build .. "\n » Date: " .. date .. "\n » TocVersion: " .. toc_version)
    print("|cFF00FF00VersionDate|r 202603281301")
end

function VoidFrame:PrintHelp()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00恶龙咆哮菜单:|r")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 /mzx new|r - 初始化设置")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 /mzx show|r |cFF00CCFF[module编号]|r - 开启模块")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 /mzx hide|r |cFF00CCFF[module编号]|r - 关闭模块")
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 可选|cFF00CCFFmodule编号|r:|r")
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 |cFF00CCFFmodule编号|r可多选，空格隔开即可，不选任何编号即全部加载或关闭:|r")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00CCFF 1|r - 萨满护盾监控")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00CCFF 2|r - 角色属性面板")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00CCFF 3|r - 武器熟练度面板")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00CCFF 4|r - 萨满图腾监控")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00CCFF 5|r - 萨满图腾收纳")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 /mzx|r - 显示帮助")
end
