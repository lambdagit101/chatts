languages = {
    ["en"] = "English",
    ["ru"] = "Russian",
    ["ro"] = "Romanian",
    ["ja"] = "Japanese",
    ["zh-CN"] = "Simplified Chinese",
    ["zh-TW"] = "Traditional Chinese",
    ["es"] = "Spanish",
    ["de"] = "German",
    ["fr"] = "French",
    ["hu"] = "Hungarian",
    ["ko"] = "Korean",
    ["pt"] = "Portuguese",
    ["ar"] = "Arabic",
    ["it"] = "Italian",
    ["la"] = "Latin",
    ["sv"] = "Swedish",
    ["pl"] = "Polish",
    ["sq"] = "Albanian",
    ["bs"] = "Bosnian",
    ["sr"] = "Serbian",
    ["nl"] = "Dutch",
}
locales = table.GetKeys(languages)

if SERVER then
    hook.Add("PlayerInitialSpawn", "chatts-language", function(ply)
        ply:SetNWString("chatts-locale", locales[math.random(#locales)])
    end)

    concommand.Add("chatts_setlocale", function(ply, cmd, args)
        if ply.ChattsCooldown == nil then
            ply.ChattsCooldown = 0
        end
        if ply.ChattsCooldown > CurTime() and (not game.SinglePlayer() and game.IsDedicated()) then
            ply:ChatPrint("Please wait " .. math.ceil(ply.ChattsCooldown - CurTime()) .. " seconds before changing your locale.")
            return
        end

        ply.ChattsCooldown = CurTime() + 1
        local locale = string.lower(tostring(args[1]))
        if languages[locale] then
            ply:SetNWString("chatts-locale", locale)
            ply:ChatPrint("Your language has been changed to " .. languages[locale] .. " (" .. locale .. ")")
        else
            ply:ChatPrint("This language does not exist!")
        end
    end, nil, "Changes the player's locale. Has a 5 second delay.")
end

function char_to_hex(c)
    return string.format("%%%02X", string.byte(c))
end
  
function urlencode(url)
    if url == nil then
      return
    end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w ])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
end
  
function hex_to_char(x)
    return string.char(tonumber(x, 16))
end
  
function urldecode(url)
    if url == nil then
        return
    end
    url = url:gsub("+", " ")
    url = url:gsub("%%(%x%x)", hex_to_char)
    return url
end

if CLIENT then
    CreateConVar("chatts_enable", 1, {FCVAR_ARCHIVE}, "Enables chat TTS", 0, 1)
    CreateConVar("chatts_team_enable", 1, {FCVAR_ARCHIVE}, "Enables team chat TTS", 0, 1)

    concommand.Add("chatts_alllocales", function(ply, cmd, args)
        PrintTable(languages)
    end)

    hook.Add("OnPlayerChat", "chatts-ensure", function(ply, chatmsg, pteam, isdead)
        if isdead or not GetConVar("chatts_enable"):GetBool() then return end

        print("Transmitting chatter of player " .. ply:Nick() .. " in " .. ply:GetNWString("chatts-locale", "en"))
        sound.PlayURL("http://translate.google.com/translate_tts?ie=Unicode&client=tw-ob&q=" .. urlencode(chatmsg) .. "&tl=" .. ply:GetNWString("chatts-locale", "en"), (pteam and GetConVar("chatts_team_enable"):GetBool() and "mono") or "3d", function(soundchannel, errorID, errorName)
            if IsValid(soundchannel) then
                if not (pteam and GetConVar("chatts_team_enable"):GetBool()) then
                    soundchannel:SetPos(ply:GetPos())
                end

                soundchannel:Play()

                g_soundchannel = soundchannel
            else
                print("Could not play sound from " .. ply:Nick() .. "! (error ID " .. errorID .. "): " .. errorName)
            end
        end)
    end)
end