--@name Mesh Loader
--@author GRONUERS
--@include Mesh_Default_Settings.txt
--@shared 

local Settings = require("Mesh_Default_Settings.txt")

if SERVER then

elseif CLIENT then

    setName( Settings.Name )
    local meshDelay = Settings.Delay
    local meshCount = 0
    local meshMaxCount = #Settings.URL
    local timestart = timer.realtime()
    local total = 0
    local lastColor = Color(0,0,0)
    local lastMaterial = ""
    local untilIdx = {}
    local endIdx = {}
    local Holo = { ["Holograms"] = {} }
    local c = 1
    local m = 1
    local color = ""
    local mtl = ""
    
    local function finished(index, total, meshCount)
        local ctime = timer.realtime()
        local times = ctime - timestart
        local minm = math.floor((meshDelay*index)/60)
        local mint = math.floor(times/60)
        print("All of meshes loaded successfully!")
        
        if meshDelay*index > minm*60 then
            print("Expected loading time is "..minm.." minutes, "..meshDelay*index-minm*60 .." seconds")
            print("Took "..mint.." minutes, "..math.round(times,2)-mint*60 .." seconds!")
        elseif meshDelay*index < minm*60 then
            print("Expected loading time is "..minm.." minutes, "..meshDelay*index-(minm-1)*60 .." seconds")
            print("Took "..mint.." minutes, "..math.round(times,2)-(mint-1)*60 .." seconds!")
        end
        
        print("Total uses of triangles is "..total)
        print("Total meshes count is "..meshCount)
        return true
    end
    
    local baseFont = render.createFont( "Roboto", 22, 400, true )
    
    hook.add("drawhud","load Mesh HUD",function()
        local x, y = render.getGameResolution()
        
        render.setFont(baseFont)
        render.drawText(x-225,y-50,meshMaxCount-meshCount.." meshes left to load",0)
        
        if meshCount > meshMaxCount - 1 then hook.remove("drawhud","load Mesh HUD") end
    end)
    
    if Settings.HudStatus == true then
        if player() == owner() then enableHud( nil, true ) end
    end
    
    local mymesh
    local Scale = Settings.Scale
    
    local Parent = { 
        ["Holo"] = {
        } 
    }
    
    for i = 1, meshMaxCount do
        timer.simple( meshDelay*(i-1), function()
            color = string.explode(" ",Settings.Color[c])
        end)
        
        timer.simple( meshDelay*(i-1), function() 
            local URL = Settings.URL[i]
            local URL = string.replace(URL,"www","dl")
            local URL = string.replace(URL,"?dl=0","")
            
            local Index1 = string.explode("/",URL)[6]
            local Index2 = string.explode(".",Index1)[1]
            local Name = string.replace(Index2,"%20"," ")
            
            if Settings.Parent[i] ~= nil and Settings.Parent[i][1] == Name then
                if Settings.Parent[i][2] ~= nil then
                    Holo.Holograms[Name] = holograms.create(Parent.Holo[Settings.Parent[i][2]]:localToWorld(Vector(0,0,0)), Parent.Holo[Settings.Parent[i][2]]:getAngles(), "models/sprops/rectangles/size_1_5/rect_6x6x3.mdl")
                    Holo.Holograms[Name]:setParent(Parent.Holo[Settings.Parent[i][2]])
                elseif Settings.Parent[i][2] == nil then
                    Holo.Holograms[Name] = holograms.create(chip():localToWorld(Vector(0,0,0)), chip():getAngles()+Angle(0,90,90), "models/sprops/rectangles/size_1_5/rect_6x6x3.mdl")
                    Holo.Holograms[Name]:setParent(chip())
                end
            elseif Settings.Parent[i] == nil or Settings.Parent[i][1] ~= Name then
                Holo.Holograms[Name] = holograms.create(chip():localToWorld(Vector(0,0,0)), chip():getAngles()+Angle(0,90,90), "models/sprops/rectangles/size_1_5/rect_6x6x3.mdl")
                Holo.Holograms[Name]:setParent(chip())
            end
            
            if (#color >= 3) == true then 
                c = c + 1
                lastColor = Color(tonumber(color[1]),tonumber(color[2]),tonumber(color[3]),tonumber(color[4]))
                Holo.Holograms[Name]:setColor(Color(tonumber(color[1]),tonumber(color[2]),tonumber(color[3]),tonumber(color[4]))) 
            end
            
            if (#color >= 3) == false then
                if untilIdx[1] == nil and endIdx[1] == nil then
                    table.insert(untilIdx,i)
                    table.insert(endIdx,untilIdx[1] + tonumber(color[1]))
                end
            end
            
            if untilIdx[1] ~= nil and endIdx[1] ~= nil then
                for j = untilIdx[1], endIdx[1] do
                    if i == j then Holo.Holograms[Name]:setColor(lastColor) end
                end
            end

            if untilIdx ~= nil and endIdx[1] ~= nil and i == endIdx[1] - 1 then
                c = c + 1
                table.remove(untilIdx)
                table.remove(endIdx)
            end
            
            if string.explode(" ",Settings.Material[i])[1] ~= "custom" then 
                if Settings.Material[i] ~= -1 then 
                    lastMaterial = Settings.Material[i]
                    Holo.Holograms[Name]:setMaterial(Settings.Material[i]) 
                elseif Settings.Material[i] == -1 then
                    Holo.Holograms[Name]:setMaterial(lastMaterial)
                end
            end
            
            http.get( URL,function(objdata)
                local triangles = mesh.trianglesLeft()
    
                local function doneLoadingMesh()
                    print("Used "..(triangles - mesh.trianglesLeft()).." triangles to load "..Name)
                    if string.explode(" ",Settings.Material[i])[1] == "custom" then
                        local CMS = string.explode(" ",Settings.Material[i])[2]
                        local CMS = string.replace(CMS,"www","dl")
                        local CMS = string.replace(CMS,"?dl=0","")
                        
                        local customMaterial = material.create("VertexLitGeneric")
                        customMaterial:setTextureURL("$basetexture",CMS)
                        Holo.Holograms[Name]:setMeshMaterial(customMaterial) 
                    end
                    Holo.Holograms[Name]:setMesh(mymesh)
                    Holo.Holograms[Name]:setScale(Vector(Scale))
                    Holo.Holograms[Name]:setRenderBounds(Vector(-200),Vector(200))
                    total = total + (triangles - mesh.trianglesLeft())
                    meshCount = meshCount + 1
                    if i == meshMaxCount then finished(i-1, total, meshCount) end
                    i = i + 1
                end
    
                local loadmesh = coroutine.wrap(function() mymesh = mesh.createFromObj(objdata, true, true).Draw return true end)
                hook.add("think","loadingMesh",function()
                    while quotaAverage()<quotaMax()/(math.clamp(Settings.Speed,4,50)) do
                        if loadmesh() then
                            doneLoadingMesh()
                            hook.remove("think","loadingMesh")
                            return
                        end
                    end
                end)
            end)
        end)
    end
    
    
    hook.add("net","",function(name)
    
    end)  
    
    hook.add("think","",function()

    end)
end