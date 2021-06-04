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
        if name == "Inputs" then
            sdb = net.readVector()
            hs  = net.readVector()
            ldg = net.readVector()
            rdt = net.readVector()
            rsr = net.readVector()
            lrt = net.readVector()
        end
    end)  
    
    
    local FLDRLColor, FRDRLColor, RLDRLColor, RRDRLColor, LSIGColor, RSIGColor = Color(), Color(), Color(), Color(), Color(), Color()
    local FLDRLColors, FRDRLColors, RLDRLColors, RRDRLColors = Color(), Color(), Color(), Color()
    local BrakeColor, RevColor, BrakeColors, RevColors = Color(), Color(), Color(), Color()
    
    local HoodAngle, HoodAngles, TrunkAngle, TrunkAngles = 0, 0, 0, 0
    local FLDAngle, FRDAngle, RLDAngle, RRDAngle, FLDAngles, FRDAngles, RLDAngles, RRDAngles, SteeringAngle = 0, 0, 0, 0, 0, 0, 0, 0, 0
    
    hook.add("think","",function()
        
        if hs.x == 1 then HoodAngle = HoodAngle + 0.25
        elseif hs.x == 0 then HoodAngle = HoodAngle - 0.25 end
        
        HoodAngle = math.clamp(HoodAngle,0,70)
        HoodAngles = HoodAngles + (HoodAngle-HoodAngles)*0.05
        
        Parent.Holo["HB"]:setAngles(chip():localToWorldAngles(Angle(0,90,90+HoodAngles)))
        
        if rdt.z == 1 then TrunkAngle = TrunkAngle + 0.25
        elseif rdt.z == 0 then TrunkAngle = TrunkAngle - 0.25 end
        
        TrunkAngle = math.clamp(TrunkAngle,0,75)
        TrunkAngles = TrunkAngles + (TrunkAngle-TrunkAngles)*0.05
        
        Parent.Holo["TB"]:setPos(chip():localToWorld(Vector(100-TrunkAngles/40,0,12.3+TrunkAngles/6.5)))
        Parent.Holo["TB"]:setAngles(chip():localToWorldAngles(Angle(0,90,90-TrunkAngles)))
        
        if ldg.x == 1 then FLDAngle = FLDAngle + 0.5
        elseif ldg.x == 0 then FLDAngle = FLDAngle - 0.5 end
        FLDAngle = math.clamp(FLDAngle,0,70)
        FLDAngles = FLDAngles + (FLDAngle-FLDAngles)*0.05
        
        if rdt.x == 1  then FRDAngle = FRDAngle + 0.5
        elseif rdt.x == 0 then FRDAngle = FRDAngle - 0.5 end
        FRDAngle = math.clamp(FRDAngle,0,70)
        FRDAngles = FRDAngles + (FRDAngle-FRDAngles)*0.05
        
        if ldg.y == 1 then RLDAngle = RLDAngle + 0.5
        elseif ldg.y == 0 then RLDAngle = RLDAngle - 0.5 end
        RLDAngle = math.clamp(RLDAngle,0,70)
        RLDAngles = RLDAngles + (RLDAngle-RLDAngles)*0.05
        
        if rdt.y == 1 then RRDAngle = RRDAngle + 0.5
        elseif rdt.y == 0 then RRDAngle = RRDAngle - 0.5 end
        RRDAngle = math.clamp(RRDAngle,0,70)
        RRDAngles = RRDAngles + (RRDAngle-RRDAngles)*0.05
        
        Parent.Holo["FLD"]:setAngles(chip():localToWorldAngles(Angle(0,90-FLDAngles,90)))
        Parent.Holo["FRD"]:setAngles(chip():localToWorldAngles(Angle(0,90+FRDAngles,90)))
        Parent.Holo["RLD"]:setAngles(chip():localToWorldAngles(Angle(0,90-RLDAngles,90)))
        Parent.Holo["RRD"]:setAngles(chip():localToWorldAngles(Angle(0,90+RRDAngles,90)))
        
        if sdb.y == 1 then 
            --Left Signal
            if hs.y == 0 and lrt.x == 0 and lrt.y == 0 and lrt.z == 0 then
                FLDRLColor = Color(255,255,255)
            elseif hs.y == 1 then
                FLDRLColor = Color(255,191,0)
            elseif hs.y == 0 and lrt.x == 1 or lrt.z == 1 then
                FLDRLColor = Color(0,0,0)
            elseif lrt.y == 1 or lrt.z == 1 and hs.z == 0 then
                FLDRLColor = Color(85,85,85)
            end
            
            --Right Signal
            if hs.z == 0 and lrt.x == 0 and lrt.y == 0 and lrt.z == 0 then
                FRDRLColor = Color(255,255,255)
            elseif hs.z == 1 then
                FRDRLColor = Color(255,191,0)
            elseif hs.z == 0 and lrt.y == 1 or lrt.z == 1 then
                FRDRLColor = Color(0,0,0)
            elseif lrt.x == 1 or lrt.z == 1 and hs.y == 0 then
                FRDRLColor = Color(85,85,85)
            end
            
        elseif sdb.y == 0 then 
            --Left Signal
            if hs.y == 0 then
                FLDRLColor = Color(0,0,0)
            elseif hs.y == 1 then
                FLDRLColor = Color(255,191,0)
            end
            
            --Right Signal
            if hs.z == 0 then
                FRDRLColor = Color(0,0,0)
            elseif hs.z == 1 then
                FRDRLColor = Color(255,191,0)
            end
        end
        
        if hs.y == 1 then LSIGColor = Color(255,191,0)
        elseif hs.y == 0 then LSIGColor = Color(0,0,0) end
        
        if hs.z == 1 then RSIGColor = Color(255,191,0)
        elseif hs.z == 0 then RSIGColor = Color(0,0,0) end
        
        FLDRLColors = FLDRLColors + (FLDRLColor - FLDRLColors)*0.05
        FRDRLColors = FRDRLColors + (FRDRLColor - FRDRLColors)*0.05
        
        if sdb.z == 1 then BrakeColor = Color(255,0,0)
        elseif sdb.z == 0 then BrakeColor = Color(0,0,0) end
        
        BrakeColors = BrakeColors + (BrakeColor-BrakeColors)*0.08
        
        if ldg.z == -1 then RevColor = Color(255)
        else RevColor = Color(0,0,0) end
        
        RevColors = RevColors + (RevColor-RevColors)*0.05
        
        if sdb.y == 0 then
            if sdb.z == 1 and hs.y == 0 then
                RLDRLColor = Color(255,0,0)
            elseif hs.y == 1 then
                RLDRLColor = Color(255,191,0)
            elseif sdb.z == 0 and hs.y == 0 then
                RLDRLColor = Color(0,0,0)
            end
            
            if sdb.z == 1 and hs.z == 0 then
                RRDRLColor = Color(255,0,0)
            elseif hs.z == 1 then
                RRDRLColor = Color(255,191,0)
            elseif sdb.z == 0 and hs.z == 0 then
                RRDRLColor = Color(0,0,0)
            end
        elseif sdb.y == 1 then
            if sdb.z == 1 and hs.y == 0 then
                RLDRLColor = Color(255,0,0)
            elseif hs.y == 1 then
                RLDRLColor = Color(255,191,0)
            elseif sdb.z == 0 and hs.y == 0 then
                RLDRLColor = Color(50,0,0)
            end
            
            if sdb.z == 1 and hs.z == 0 then
                RRDRLColor = Color(255,0,0)
            elseif hs.z == 1 then
                RRDRLColor = Color(255,191,0)
            elseif sdb.z == 0 and hs.z == 0 then
                RRDRLColor = Color(50,0,0)
            end
        end
        
        RLDRLColors = RLDRLColors + (RLDRLColor-RLDRLColors)*0.08
        RRDRLColors = RRDRLColors + (RRDRLColor-RRDRLColors)*0.08
        
        if Holo.Holograms["Front Left DRL"] ~= nil then
            Holo.Holograms["Front Left DRL"]:setColor(FLDRLColors)
        end
        
        if Holo.Holograms["Front Right DRL"] ~= nil then
            Holo.Holograms["Front Right DRL"]:setColor(FRDRLColors)
        end
        
        if Holo.Holograms["FLD Signal"] ~= nil then
            Holo.Holograms["FLD Signal"]:setColor(LSIGColor)
        end
        
        if Holo.Holograms["FRD Signal"] ~= nil then
            Holo.Holograms["FRD Signal"]:setColor(RSIGColor)
        end
        
        if Holo.Holograms["Brake"] ~= nil then 
            Holo.Holograms["Brake"]:setColor(BrakeColors)
        end
        
        if Holo.Holograms["Reverse Light"] ~= nil then
            Holo.Holograms["Reverse Light"]:setColor(RevColors)
        end
        
        if Holo.Holograms["Rear Left DRL"] ~= nil then 
            Holo.Holograms["Rear Left DRL"]:setColor(RLDRLColors)
        end
        
        if Holo.Holograms["Rear Right DRL"] ~= nil then
            Holo.Holograms["Rear Right DRL"]:setColor(RRDRLColors)
        end
        
        SteeringAngle = SteeringAngle + ((sdb.x * 6)-SteeringAngle)*0.1
        
        Parent.Holo["STR"]:setAngles(SteeringBase:localToWorldAngles(Angle(0,-SteeringAngle,0)))
    end)
    
end