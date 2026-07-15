local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfig = LibStub("AceConfig-3.0")

-- ============================================
-- 插件主文件: core.lua
-- ============================================

local MzxToolAddon = LibStub("AceAddon-3.0"):NewAddon("MzxToolAddon", "AceConsole-3.0")

-- ============================================
-- 1. 使用你原有的数据库初始化函数
-- ============================================
function InitDatabase()
    VoidModClassicDB = VoidModClassicDB or {}
    VoidModClassicCharacterDB = VoidModClassicCharacterDB or {
        point = {}
    }
    VoidModClassicCharacterDB.status = VoidModClassicCharacterDB.status or {
        PlayerInfo = false,
        SkillLine = false,
        ShieldInfo = true,
        TotemInfo = true,
        TotemTool = true,
        Debug = false
    }
    VoidModClassicCharacterDB.totem = VoidModClassicCharacterDB.totem or {}
end

-- ============================================
-- 2. 初始化
-- ============================================
function MzxToolAddon:OnInitialize()
    -- 调用你的数据库初始化
    InitDatabase()

    -- 将全局表关联到插件对象（方便后续调用）
    self.db = VoidModClassicDB
    self.charDB = VoidModClassicCharacterDB

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
-- 3. 打开配置窗口
-- ============================================
function MzxToolAddon:ShowConfig()
    if AceConfigDialog.OpenFrames["MzxToolAddon"] then
        AceConfigDialog:Close("MzxToolAddon")
    else
        AceConfigDialog:Open("MzxToolAddon")
    end
end

-- ============================================
-- 4. 选项表定义
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
                    get = function() return VoidModClassicCharacterDB.status.PlayerInfo end,
                    set = function(info, value)
                        VoidModClassicCharacterDB.status.PlayerInfo = value
                    end,
                },
                SkillLine = {
                    type = "toggle",
                    name = "武器技能信息",
                    desc = "显示技能条信息",
                    order = 2,
                    get = function() return VoidModClassicCharacterDB.status.SkillLine end,
                    set = function(info, value)
                        VoidModClassicCharacterDB.status.SkillLine = value
                    end,
                },
                ShieldInfo = {
                    type = "toggle",
                    name = "萨满元素护盾监控",
                    desc = "显示萨满元素护盾状态",
                    order = 3,
                    get = function() return VoidModClassicCharacterDB.status.ShieldInfo end,
                    set = function(info, value)
                        VoidModClassicCharacterDB.status.ShieldInfo = value
                    end,
                },
                TotemInfo = {
                    type = "toggle",
                    name = "萨满图腾信息",
                    desc = "显示图腾状态信息",
                    order = 4,
                    get = function() return VoidModClassicCharacterDB.status.TotemInfo end,
                    set = function(info, value)
                        VoidModClassicCharacterDB.status.TotemInfo = value
                    end,
                },
                TotemTool = {
                    type = "toggle",
                    name = "萨满图腾工具",
                    desc = "显示图腾辅助工具",
                    order = 5,
                    get = function() return VoidModClassicCharacterDB.status.TotemTool end,
                    set = function(info, value)
                        VoidModClassicCharacterDB.status.TotemTool = value
                    end,
                },
                Debug = {
                    type = "toggle",
                    name = "调试模式",
                    desc = "开启调试信息输出",
                    order = 6,
                    get = function() return VoidModClassicCharacterDB.status.Debug end,
                    set = function(info, value)
                        VoidModClassicCharacterDB.status.Debug = value
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
                        for key, _ in pairs(VoidModClassicCharacterDB.status) do
                            VoidModClassicCharacterDB.status[key] = true
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
                        for key, _ in pairs(VoidModClassicCharacterDB.status) do
                            VoidModClassicCharacterDB.status[key] = false
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

        -- ===== 当前状态显示 =====
        statusDisplay = {
            type = "group",
            name = "当前状态",
            order = 3,
            inline = true,
            args = {
                desc = {
                    type = "description",
                    name = function()
                        local status = VoidModClassicCharacterDB.status
                        return string.format(
                            "|cFF88CCFF当前配置状态|r\n" ..
                            "玩家信息: %s\n" ..
                            "技能条: %s\n" ..
                            "护盾信息: %s\n" ..
                            "图腾信息: %s\n" ..
                            "图腾工具: %s\n" ..
                            "调试模式: %s",
                            status.PlayerInfo and "|CFF00FF00 开启|r" or "|CFFFF0000 关闭|r",
                            status.SkillLine and "|CFF00FF00 开启|r" or "|CFFFF0000 关闭|r",
                            status.ShieldInfo and "|CFF00FF00 开启|r" or "|CFFFF0000 关闭|r",
                            status.TotemInfo and "|CFF00FF00 开启|r" or "|CFFFF0000 关闭|r",
                            status.TotemTool and "|CFF00FF00 开启|r" or "|CFFFF0000 关闭|r",
                            status.Debug and "|CFF00FF00 开启|r" or "|CFFFF0000 关闭|r"
                        )
                    end,
                    order = 1,
                },
                refreshBtn = {
                    type = "execute",
                    name = "刷新状态显示",
                    desc = "刷新当前状态文本",
                    order = 2,
                    width = "full",
                    func = function()
                        if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["MzxToolAddon"] then
                            AceConfigDialog:Close("MzxToolAddon")
                            AceConfigDialog:Open("MzxToolAddon")
                        end
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
            width = "full",         -- 独占一行更醒目
            func = function()
                -- 先保存（其实 AceDB 已经自动保存了，这里主要是给用户一个反馈）
                print("|CFF00FF00设置已保存，正在重载界面...|r")
                -- 延迟0.5秒重载，让打印信息能显示出来
                ReloadUI()
            end,
        },
    }
}
