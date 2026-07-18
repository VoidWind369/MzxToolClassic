-- ============================================
-- 插件主文件: core.lua
-- ============================================

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local MzxToolAddon = LibStub("AceAddon-3.0"):NewAddon("MzxToolAddon", "AceConsole-3.0")

-- ============================================
-- 1. 初始化
-- ============================================
function MzxToolAddon:OnInitialize()
    -- 调用你的数据库初始化
    InitDatabase()

    -- 将全局表关联到插件对象（方便后续调用）
    self.db = MzxToolClassicDB
    self.charDB = MzxToolClassicCharacterDB

    -- 注册选项表
    AceConfig:RegisterOptionsTable("MzxToolAddon", self.options)

    -- 添加到游戏设置面板
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("MzxToolAddon", "MzxTool 设置")

    -- 注册聊天命令
    self:RegisterChatCommand("mzx", "ShowConfig")
    self:RegisterChatCommand("mzxtool", "ShowConfig")
    self:RegisterChatCommand("mzxtoolbox", "ShowConfig")
    self:RegisterChatCommand("voidmod", "ShowConfig")
    self:RegisterChatCommand("void", "ShowConfig")
    self:RegisterChatCommand("moon", "ShowConfig")
    self:RegisterChatCommand("mt", "ShowConfig")
    self:RegisterChatCommand("vm", "ShowConfig")

    print("|cFF33FF99MzxToolAddon|r 已加载，输入 /mzx 打开设置")
end

-- ============================================
-- 2. 打开配置窗口
-- ============================================
function MzxToolAddon:ShowConfig(input)
    -- 如果输入为空或空格，打开设置面板
    MzxToolFrame:HandleSlashCommand(input)
end

-- ============================================
-- 3. 选项表定义
-- ============================================
MzxToolAddon.options = {
    type = "group",
    name = "MzxTool 设置",
    desc = "MzxTool 插件配置",
    args = {
        -- ===== 状态开关组 =====
        statusGroup = {
            type = "group",
            name = "功能开关",
            desc = "开启或关闭各项功能",
            order = 1,
            inline = true,
            args = {
                PlayerInfo = {
                    type = "toggle",
                    name = "玩家属性面板",
                    desc = "显示玩家详细信息",
                    order = 1,
                    get = function() return MzxToolClassicCharacterDB.status.PlayerInfo end,
                    set = function(info, value)
                        MzxToolClassicCharacterDB.status.PlayerInfo = value
                    end,
                },
                SkillLine = {
                    type = "toggle",
                    name = "武器技能信息",
                    desc = "显示技能条信息",
                    order = 2,
                    get = function() return MzxToolClassicCharacterDB.status.SkillLine end,
                    set = function(info, value)
                        MzxToolClassicCharacterDB.status.SkillLine = value
                    end,
                },
                ShieldInfo = {
                    type = "toggle",
                    name = "萨满元素护盾监控",
                    desc = "显示萨满元素护盾状态",
                    order = 3,
                    get = function() return MzxToolClassicCharacterDB.status.ShieldInfo end,
                    set = function(info, value)
                        MzxToolClassicCharacterDB.status.ShieldInfo = value
                    end,
                },
                TotemInfo = {
                    type = "toggle",
                    name = "萨满图腾信息",
                    desc = "显示图腾状态信息",
                    order = 4,
                    get = function() return MzxToolClassicCharacterDB.status.TotemInfo end,
                    set = function(info, value)
                        MzxToolClassicCharacterDB.status.TotemInfo = value
                    end,
                },
                TotemTool = {
                    type = "toggle",
                    name = "萨满图腾工具",
                    desc = "显示图腾辅助工具",
                    order = 5,
                    get = function() return MzxToolClassicCharacterDB.status.TotemTool end,
                    set = function(info, value)
                        MzxToolClassicCharacterDB.status.TotemTool = value
                    end,
                },
                TotemDance = {
                    type = "toggle",
                    name = "萨满图腾舞辅助",
                    desc = "萨满图腾舞辅助计时工具",
                    order = 5,
                    get = function() return MzxToolClassicCharacterDB.status.TotemDance end,
                    set = function(info, value)
                        MzxToolClassicCharacterDB.status.TotemDance = value
                    end,
                },
                TeleportTool = {
                    type = "toggle",
                    name = "法师传送工具",
                    desc = "显示传送辅助工具",
                    order = 6,
                    get = function() return MzxToolClassicCharacterDB.status.TeleportTool end,
                    set = function(info, value)
                        MzxToolClassicCharacterDB.status.TeleportTool = value
                    end,
                },
                Debug = {
                    type = "toggle",
                    name = "调试模式",
                    desc = "开启调试信息输出",
                    order = 7,
                    get = function() return MzxToolClassicCharacterDB.status.Debug end,
                    set = function(info, value)
                        MzxToolClassicCharacterDB.status.Debug = value
                        if value then
                            print("|CFFFFAA00调试模式已开启|r")
                        else
                            print("调试模式已关闭")
                        end
                    end,
                },
            }
        },

        -- ===== 全选/重置操作 =====
        actionGroup = {
            type = "group",
            name = "快捷操作",
            order = 2,
            inline = true,
            args = {
                enableAll = {
                    type = "execute",
                    name = "全部开启",
                    desc = "开启所有功能",
                    order = 1,
                    width = "0.5",
                    func = function()
                        for key, _ in pairs(MzxToolClassicCharacterDB.status) do
                            MzxToolClassicCharacterDB.status[key] = true
                        end
                        print("|CFF00FF00所有功能已开启|r")
                        -- 刷新配置面板显示
                        if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["MzxToolAddon"] then
                            AceConfigDialog:Close("MzxToolAddon")
                            AceConfigDialog:Open("MzxToolAddon")
                        end
                    end,
                },
                disableAll = {
                    type = "execute",
                    name = "全部关闭",
                    desc = "关闭所有功能",
                    order = 2,
                    width = "0.5",
                    func = function()
                        for key, _ in pairs(MzxToolClassicCharacterDB.status) do
                            MzxToolClassicCharacterDB.status[key] = false
                        end
                        print("|CFFFF0000所有功能已关闭|r")
                        if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["MzxToolAddon"] then
                            AceConfigDialog:Close("MzxToolAddon")
                            AceConfigDialog:Open("MzxToolAddon")
                        end
                    end,
                },
                resetBtn = {
                    type = "execute",
                    name = "重置默认值",
                    desc = "恢复所有设置为默认状态",
                    order = 3,
                    width = "0.5",
                    func = function()
                        NewDatabase()
                        print("|CFFFFAA00设置已重置为默认值|r")
                        if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["MzxToolAddon"] then
                            AceConfigDialog:Close("MzxToolAddon")
                            AceConfigDialog:Open("MzxToolAddon")
                        end
                        ReloadUI()
                    end,
                },
            }
        },

        -- ===== ElvUI 相关 =====
        elvuiGroup = {
            type = "group",
            name = "ElvUI 集成",
            order = 4,
            inline = true,
            args = {
                elvuiStatus = {
                    type = "description",
                    name = function()
                        if ElvUI then
                            return "|CFF00FF00 ElvUI 已安装并检测到|r\n材质可通过 LibSharedMedia 调用"
                        else
                            return "|CFFFFAA00⚠ ElvUI 未安装|r\n将使用默认材质"
                        end
                    end,
                    order = 1,
                },
                texturePreview = {
                    type = "description",
                    name = function()
                        if ElvUI then
                            local LSM = LibStub("LibSharedMedia-3.0")
                            local texture = LSM:Fetch("statusbar", "ElvUI Norm")
                            if texture then
                                return "|CFF00FF00 ElvUI 标准材质可用|r\n路径: " .. texture
                            else
                                return "|CFFFF0000 无法获取 ElvUI 材质|r"
                            end
                        else
                            return "需要 ElvUI 才能使用此功能"
                        end
                    end,
                    order = 2,
                },
            }
        },
        reloadBtn = {
            type = "execute",
            name = "保存并重载",
            desc = "保存当前设置并重载界面",
            order = 4,
            width = "full", -- 独占一行更醒目
            func = function()
                -- 先保存（其实 AceDB 已经自动保存了，这里主要是给用户一个反馈）
                print("|CFF00FF00设置已保存，正在重载界面...|r")
                -- 延迟0.5秒重载，让打印信息能显示出来
                ReloadUI()
            end,
        },
    }
}

-- ============================================
-- 命令菜单
-- ============================================
function MzxToolFrame:HandleSlashCommand(msg)
    local command = strlower(strtrim(msg))

    if command == "new" then
        NewDatabase()
    elseif string.find(command, "show") then
        MzxDebug(command)
        for index, value in ipairs(strsplittable(" ", command)) do
            if value == "show" then
                MzxDebug("Off")
            elseif value == "1" then
                MzxDebug("Shield on")
                MzxToolClassicCharacterDB.status.ShieldInfo = true
            elseif value == "2" then
                MzxDebug("PlayerInfo on")
                MzxToolClassicCharacterDB.status.PlayerInfo = true
            elseif value == "3" then
                MzxDebug("SkillLine on")
                MzxToolClassicCharacterDB.status.SkillLine = true
            elseif value == "4" then
                MzxDebug("TotemInfo on")
                MzxToolClassicCharacterDB.status.TotemInfo = true
            elseif value == "5" then
                MzxDebug("TotemTool on")
                MzxToolClassicCharacterDB.status.TotemTool = true
            else
                MzxDebug("All on")
                MzxToolClassicCharacterDB.status = {
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
        MzxDebug(command)
        for index, value in ipairs(strsplittable(" ", command)) do
            if value == "hide" then
                MzxDebug("On")
            elseif value == "1" then
                MzxDebug("Shield off")
                MzxToolClassicCharacterDB.status.ShieldInfo = false
            elseif value == "2" then
                MzxDebug("PlayerInfo off")
                MzxToolClassicCharacterDB.status.PlayerInfo = false
            elseif value == "3" then
                MzxDebug("SkillLine off")
                MzxToolClassicCharacterDB.status.SkillLine = false
            elseif value == "4" then
                MzxDebug("TotemInfo off")
                MzxToolClassicCharacterDB.status.TotemInfo = false
            elseif value == "5" then
                MzxDebug("TotemTool off")
                MzxToolClassicCharacterDB.status.TotemTool = false
            else
                MzxDebug("All off")
                MzxToolClassicCharacterDB.status = {
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
        MzxToolClassicCharacterDB.status.Debug = true
        ReloadUI()
    elseif command == "debug off" then
        MzxToolClassicCharacterDB.status.Debug = false
        ReloadUI()
    elseif command == "info" then
        self:Void_PlayerInfo()
    elseif command == "test" then
        self:GetPowerWordShield()
    elseif command == "help" then
        self:ClientInfo()
        self:PrintHelp()
    else
        if AceConfigDialog.OpenFrames["MzxToolAddon"] then
            AceConfigDialog:Close("MzxToolAddon")
        else
            AceConfigDialog:Open("MzxToolAddon")
        end
    end
end

function MzxToolFrame:ClientInfo()
    local version, build, date, toc_version = GetBuildInfo()
    print("|cFF33937FWoW|r |cFF69CCF0Client|r |cFF00FF00Info:|r \n » Version: " ..
        version .. "\n » Build: " .. build .. "\n » Date: " .. date .. "\n » TocVersion: " .. toc_version)
    print("|cFF00FF00VersionDate|r 202603281301")
end

function MzxToolFrame:PrintHelp()
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
