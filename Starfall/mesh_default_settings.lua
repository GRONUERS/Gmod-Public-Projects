--@name Mesh_Default_Settings
--@shared

if CLIENT then

    local name = ""
    local meshdelay = 4
    local meshSpeed = 7
    
    local settings = { ["HudStatus"] = true,
                       ["Scale"] = 0.5,
                       ["Delay"] = meshdelay,
                       ["Speed"] = meshSpeed,
                       ["Name"] = name,
                       ["URL"] = {
                       },
                       ["Color"] = {
                       },
                       ["Material"] = {
                       },
                       ["Parent"] = {
                       }
                     }
    
    return settings
    
end