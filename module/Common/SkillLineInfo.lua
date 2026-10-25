-- ============================================================================
-- 模块：武器熟练度面板 (SkillLineInfo) —— 通用
-- ============================================================================
-- 职责：
--   1. 扫描玩家武器技能，显示已学会的武器熟练度等级；
--   2. 支持匕首/单手斧/单手锤/单手剑/双手斧/双手锤/双手剑/长柄武器/徒手/法杖/防御/弩/魔杖。
--
-- 数据依赖：MzxCommonData.SkillLineInfo（位于 module/Common/Data.lua）
-- UI 封装：MzxUIStyle（位于 commend/UIStyle.lua）
-- 数据持久化：MzxToolClassicCharacterDB.point.skill_line
-- ============================================================================

local ui = MzxUIStyle       -- UI 封装层快捷引用
local dt = MzxCommonData.SkillLineInfo   -- 数据层快捷引用

local skill_line = {
    names = { "匕首", "单手斧", "单手锤", "单手剑", "双手斧", "双手锤", "双手剑", "长柄武器", "徒手战斗", "法杖", "防御", "弩", "魔杖" },
}

-- ----------------------------------------------------------------------------
-- 获取武器熟练度信息
-- 返回：skill_table[{name, rank}, ...]
-- ----------------------------------------------------------------------------
function MzxToolFrame.GetSkillLineInfo()
    local skill_table = {}
    local num = 0
    for i = 1, GetNumSkillLines() do
        local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription =
            GetSkillLineInfo(i)
        for _, value in ipairs(skill_line.names) do
            if value == skillName then
                num = num + 1
                skill_table[num] = {
                    name = string.format("|cFFFFCC00%s|r", skillName),
                    rank = string.format("%d/%d", skillRank, skillMaxRank)
                }
            end
        end
    end
    return skill_table
end

-- ----------------------------------------------------------------------------
-- 创建武器熟练度框体（统一样式）
-- @param skill_table GetSkillLineInfo() 返回的表
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_CreateSkillLineInfoFrame(skill_table)
    MzxToolClassicCharacterDB.point.skill_line = MzxToolClassicCharacterDB.point.skill_line or {
        p = dt.up.p,
        x = dt.up.x,
        y = dt.up.y,
    }

    -- 主框体：统一面板样式
    self.voidSkillLineInfo = ui.CreatePanel(
        UIParent,
        dt.panel_w,
        #skill_table * dt.row_h + dt.label_padding * 2,
        MzxToolClassicCharacterDB.point.skill_line.p,
        MzxToolClassicCharacterDB.point.skill_line.x,
        MzxToolClassicCharacterDB.point.skill_line.y
    )

    self.voidSkillLineInfoText = {}
    for index, value in ipairs(skill_table) do
        -- 从下往上排列，第一行在最底部
        local y = dt.label_padding + dt.row_h * (#skill_table - index)

        local nameText = ui.CreateLabel(
            self.voidSkillLineInfo,
            value.name,
            ui.Font.tooltip,
            "LEFT", 6, y
        )
        local valueText = ui.CreateLabel(
            self.voidSkillLineInfo,
            value.rank,
            ui.Font.tooltip,
            "RIGHT", -5, y
        )
        self.voidSkillLineInfoText[index] = { nameText, valueText }
    end
end

-- ----------------------------------------------------------------------------
-- 模块入口：创建武器熟练度界面
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_CreateSkillLineInfo()
    self:Void_CreateSkillLineInfoFrame(MzxToolFrame:GetSkillLineInfo())

    MovableDisplay(self.voidSkillLineInfo)
    MovableFrameStop(self.voidSkillLineInfo, MzxToolClassicCharacterDB.point.skill_line, dt.up)
end

-- ----------------------------------------------------------------------------
-- 刷新武器熟练度信息框体
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_UpdateSkillLineInfo()
    if self.voidSkillLineInfo then
        local skill_table = MzxToolFrame:GetSkillLineInfo()
        self.voidSkillLineInfo:SetSize(dt.panel_w, #skill_table * dt.row_h + dt.label_padding * 2)
        if self.voidSkillLineInfoText then
            for index, value in ipairs(skill_table) do
                self.voidSkillLineInfoText[index][1]:SetText(value.name)
                self.voidSkillLineInfoText[index][2]:SetText(value.rank)
            end
        end
    end
end
