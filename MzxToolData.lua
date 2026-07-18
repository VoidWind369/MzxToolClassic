function InitDatabase()
    MzxToolClassicDB = MzxToolClassicDB or {}
    MzxToolClassicCharacterDB = MzxToolClassicCharacterDB or {
        point = {}
    }
    MzxToolClassicCharacterDB.status = MzxToolClassicCharacterDB.status or {
        PlayerInfo = false,
        SkillLine = false,
        ShieldInfo = true,
        TotemInfo = true,
        TotemTool = true,
        TotemDance = true,
        TeleportTool = true,
        Debug = false
    }
    MzxToolClassicCharacterDB.totem = MzxToolClassicCharacterDB.totem or {}
    MzxToolClassicCharacterDB.teleport = MzxToolClassicCharacterDB.teleport or {}
end

function NewDatabase()
    MzxToolClassicDB = {}
    MzxToolClassicCharacterDB = {
        point = {}
    }
    MzxToolClassicCharacterDB.status = {
        PlayerInfo = false,
        SkillLine = false,
        ShieldInfo = true,
        TotemInfo = true,
        TotemTool = true,
        TotemDance = true,
        TeleportTool = true,
        Debug = false
    }
    MzxToolClassicCharacterDB.totem = {}
    MzxToolClassicCharacterDB.teleport = {}
    ReloadUI()
end
