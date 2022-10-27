CreateConVar("mwinfo_chatts", 0, FCVAR_ARCHIVE, "Enables Chat TTS display at the top left")
CreateConVar("mwinfo_chatts_locale", 0, FCVAR_ARCHIVE, "Enables Chat TTS locale display at the top left")

hook.Add("mwinfo-init", "mwinfo-chatts", function(typetable)
    local i = #typetable + 1
    
    typetable[i] = {}
    
    typetable[i].ConVar = "mwinfo_chatts"
    typetable[i].Name = "Chat TTS"
    typetable[i].Info = function()
        return GetConVar(typetable[i].ConVar):GetBool() and "Enabled" or "Disabled"
    end

    local n = #typetable + 1
    
    typetable[n] = {}
    
    typetable[n].ConVar = "mwinfo_chatts_locale"
    typetable[n].Name = "Chat TTS Locale"
    typetable[n].Info = function()
        return languages[LocalPlayer():GetNWString("chatts-locale")]
    end
end)

