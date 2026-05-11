function InitDatabase()
    VoidModClassicDB = VoidModClassicDB or {}
    VoidModClassicCharacterDB = VoidModClassicCharacterDB or {
        point = {}
    }
    VoidModClassicCharacterDB.status = VoidModClassicCharacterDB.status or {
        PlayerInfo = true,
        SkillLine = true,
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
        PlayerInfo = true,
        SkillLine = true,
        ShieldInfo = true,
        TotemInfo = true,
        TotemTool = true,
        Debug = false
    }
    VoidModClassicCharacterDB.totem = {}
    ReloadUI()
end
