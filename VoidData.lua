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

function NewDatabase()
    VoidModClassicDB = {}
    VoidModClassicCharacterDB = {
        point = {}
    }
    VoidModClassicCharacterDB.status = {
        PlayerInfo = false,
        SkillLine = false,
        ShieldInfo = true,
        TotemInfo = true,
        TotemTool = true,
        Debug = false
    }
    VoidModClassicCharacterDB.totem = {}
    ReloadUI()
end
