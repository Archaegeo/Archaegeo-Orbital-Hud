function userOnStart(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1)
    local core,unit,system,databank = c,u,s,dbHud_1
    -- Support Functions
        function Waypoint(x,y,z, radius, name, subId)
            local sqrt,ceil,floor,max=math.sqrt,math.ceil,math.floor,math.max
            local function round(value, precision)
                local value = value/precision
                local value = value >= 0 and floor(value+0.5) or ceil(value-0.5)
                return value * precision
            end
            
            local getCWorldPos,getCMass = core.getConstructWorldPos,core.getConstructMass
            
            local keyframe = 0
            local self = {
                radius = radius,
                x = x,
                y = y,
                z = z,
                name = name,
                subId = subId,
                keyframe = keyframe
            }
            
            function self.getWaypointInfo()
                local tons = getCMass() / 1000
                local cPos = getCWorldPos()
                local px,py,pz = self.x-cPos[1], self.y-cPos[2], self.z-cPos[3]
                local distance = sqrt(px*px + py*py + pz*pz)
                local warpCost = max(floor(tons*floor(((distance/1000)/200))*0.00024), 1)
                local name = self.name
                
                return name, round((distance/1000)/200, 0.01), warpCost,round((distance/1000), 0.01),round(distance, 0.01)
            end
            return self
        end
        
        function getManager()
            local self = {}
            --- Core-based function calls
        
            local function matrixToQuat(m11,m21,m31,m12,m22,m32,m13,m23,m33)
                local t=m11+m22+m33
                if t>0 then
                    local s=0.5/(t+1)^(0.5)
                    return (m32-m23)*s,(m13-m31)*s,(m21-m12)*s,0.25/s
                elseif m11>m22 and m11>m33 then
                    local s = 1/(2*(1+m11-m22-m33)^(0.5))
                    return 0.25/s,(m12+m21)*s,(m13+m31)*s,(m32-m23)*s
                elseif m22>m33 then
                    local s=1/(2*(1+m22-m11-m33)^(0.5))
                    return (m12+m21)*s,0.25/s,(m23+m32)*s,(m13-m31)*s
                else
                    local s=1/(2*(1+m33-m11- m22)^(0.5))
                    return (m13+m31)*s,(m23+m32)*s,0.25/s,(m21-m12)*s
                end
            end
            
            function self.rotMatrixToQuat(rM1,rM2,rM3)
                if rM2 and rM3 then
                    return matrixToQuat(rM1[1],rM1[2],rM1[3],rM2[1],rM2[2],rM2[3],rM3[1],rM3[2],rM3[3])
                else
                    return matrixToQuat(rM1[1],rM1[5],rM1[9],rM1[2],rM1[6],rM1[10],rM1[3],rM1[7],rM1[11])
                end
            end
            self.matrixToQuat = matrixToQuat
            return self
        end
        
        CameraTypes={
            fixed={
                fLocal={
                    name="fLocal",
                    id = 0
                },
                fGlobal={
                    name="fGlobal",
                    id = 1
                }
            },
            player={
                name="player",
                id = 2
            }
        }
        
        function Camera(camType, position, orientation)
            
            local rad=math.rad
            local ori = orientation or {0,0,0}
            local self = {
                cType = camType or CameraTypes.player,
                position = (position or {0,0,0}), 
                orientation = ori
            }
            
            function self.rotateHeading(heading) self.orientation[2]=self.orientation[2]+rad(heading) end
            function self.rotatePitch(pitch) self.orientation[1]=self.orientation[1]+rad(pitch) end
            function self.rotateRoll(roll) self.orientation[3]=self.orientation[3]+rad(roll) end
            function self.setAlignmentType(alignmentType) self.cType = alignmentType end
            function self.setPosition(pos) self.position={pos[1],pos[2],pos[3]} end
        
            return self
        end
        
        positionTypes = {
            globalP=1,
            localP=2
        }
        orientationTypes = {
            globalO=1,
            localO=2 
        }
        
        local print = system.print
        
        local TEXT_ARRAY = {
            [10] = {{}, 16,'',10},--new line
            [32] = {{}, 10,'',32}, -- space
            [33] = {{4, 0, 3, 2, 5, 2, 4, 4, 4, 12}, 10, 'M%g %gL%g %gL%g %gZ M%g %gL%g %g',33}, -- !
            [34] = {{2, 10, 2, 6, 6, 10, 6, 6}, 6,'M%g %gL%g %g M%g %gL%g %g',34}, -- "
            [35] = {{0, 4, 8, 4, 6, 2, 6, 10, 8, 8, 0, 8, 2, 10, 2, 2},  10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',35}, -- #
            [36] = {{6, 2, 2, 6, 6, 10, 4, 12, 4, 0}, 6,'M%g %gL%g %gL%g %g M%g %gL%g %g',36}, --$
            [37] = {{0, 0, 8, 12, 2, 10, 2, 8, 6, 4, 6, 2}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',37}, -- %
            [38] = {{8, 0, 4, 12, 8, 8, 0, 4, 4, 0, 8, 4}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',38}, --&
            [39] = {{0, 8, 0, 12}, 2,'M%g %gL%g %g',39}, --'
            
            [40] = {{6, 0, 2, 4, 2, 8, 6, 12}, 8,'M%g %gL%g %gL%g %gL%g %g',40}, --(
            [41] = {{2, 0, 6, 4, 6, 8, 2, 12}, 8,'M%g %gL%g %gL%g %gL%g %g',41}, --)
            [42] = {{0, 0, 4, 12, 8, 0, 0, 8, 8, 8, 0, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',42}, --*
            [43] = {{1, 6, 7, 6, 4, 9, 4, 3}, 10,'M%g %gL%g %gM%g %gL%g %g',43}, -- +
            [44] = {{-1, -2, 1, 1}, 4,'M%g %gL%g %g',44}, -- ,
            [45] = {{2, 6, 6, 6}, 10,'M%g %gL%g %g',45}, -- -
            [46] = {{0, 0, 1, 0}, 3,'M%g %gL%g %g',46}, -- .
            [47] = {{0, 0, 8, 12}, 10,'M%g %gL%g %g',47}, -- /
            [48] = {{0, 0, 8, 0, 8, 12, 0, 12, 0, 0, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',48}, -- 0
            [49] = {{5, 0, 5, 12, 3, 10}, 10,'M%g %gL%g %gL%g %g',49}, -- 1
        
            
            [50] = {{0, 12, 8, 12, 8, 7, 0, 5, 0, 0, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',50}, -- 2
            [51] = {{0, 12, 8, 12, 8, 0, 0, 0, 0, 6, 8, 6}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',51}, -- 3
            [52] = {{0, 12, 0, 6, 8, 6, 8, 12, 8, 0}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',52}, -- 4
            [53] = {{0, 0, 8, 0, 8, 6, 0, 7, 0, 12, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',53}, -- 5
            [54] = {{0, 12, 0, 0, 8, 0, 8, 5, 0, 7}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',54}, -- 6
            [55] = {{0, 12, 8, 12, 8, 6, 4, 0}, 10,'M%g %gL%g %gL%g %gL%g %g',55}, -- 7
            [56] = {{0, 0, 8, 0, 8, 12, 0, 12, 0, 6, 8, 6}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',56}, -- 8
            [57] = {{8, 0, 8, 12, 0, 12, 0, 7, 8, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',57}, -- 9
            [58] = {{4, 9, 4, 7, 4, 5, 4, 3}, 2,'M%g %gL%g %g M%g %gL%g %g',58}, -- :
            [59] = {{4, 9, 4, 7, 4, 5, 1, 2}, 5,'M%g %gL%g %g M%g %gL%g %g',59}, -- ;
            
            [60] = {{6, 0, 2, 6, 6, 12}, 6,'M%g %gL%g %gL%g %g',60}, -- <
            [61] = {{1, 4, 7, 4, 1, 8, 7, 8}, 8,'M%g %gL%g %g M%g %gL%g %g',61}, -- =
            [62] = {{2, 0, 6, 6, 2, 12}, 6,'M%g %gL%g %gL%g %g',62}, -- >
            [63] = {{0, 8, 4, 12, 8, 8, 4, 4, 4, 1, 4, 0}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',63}, -- ?
            [64] = {{8, 4, 4, 0, 0, 4, 0, 8, 4, 12, 8, 8, 4, 4, 3, 6}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',64}, -- @
            [65] = {{0, 0, 0, 8, 4, 12, 8, 8, 8, 0, 0, 4, 8, 4}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',65}, -- A
            [66] = {{0, 0, 0, 12, 4, 12, 8, 10, 4, 6, 8, 2, 4, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %gZ',66}, --B
            [67] = {{8, 0, 0, 0, 0, 12, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %g',67}, -- C
            [68] = {{0, 0, 0, 12, 4, 12, 8, 8, 8, 4, 4, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gZ',68}, -- D 
            [69] = {{8, 0, 0, 0, 0, 12, 8, 12, 0, 6, 6, 6}, 10, 'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',69}, -- E
            
            
            [70] = {{0, 0, 0, 12, 8, 12, 0, 6, 6, 6}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',70}, -- F
            [71] = {{6, 6, 8, 4, 8, 0, 0, 0, 0, 12, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',71}, -- G
            [72] = {{0, 0, 0, 12, 0, 6, 8, 6, 8, 12, 8, 0}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',72}, -- H
            [73] = {{0, 0, 8, 0, 4, 0, 4, 12, 0, 12, 8, 12}, 10,'M%g %gL%g %g M%g %gL%g %g M%g %gL%g %g',73}, -- I
            [74] = {{0, 4, 4, 0, 8, 0, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %g',74}, -- J
            [75] = {{0, 0, 0, 12, 8, 12, 0, 6, 6, 0}, 10,'M%g %gL%g %g M%g %gL%g %gL%g %g',75}, -- K
            [76] = {{8, 0, 0, 0, 0, 12}, 10,'M%g %gL%g %gL%g %g',76}, -- L
            [77] = {{0, 0, 0, 12, 4, 8, 8, 12, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',77}, -- M
            [78] = {{0, 0, 0, 12, 8, 0, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %g',78}, -- N
            [79] = {{0, 0, 0, 12, 8, 12, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gZ',79}, -- O
            
            [80] = {{0, 0, 0, 12, 8, 12, 8, 6, 0, 5}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',80}, -- P
            [81] = {{0, 0, 0, 12, 8, 12, 8, 4, 4, 4, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gZ M%g %gL%g %g',81}, -- Q
            [82] = {{0, 0, 0, 12, 8, 12, 8, 6, 0, 5, 4, 5, 8, 0}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',82}, -- R
            [83] = {{0, 2, 2, 0, 8, 0, 8, 5, 0, 7, 0, 12, 6, 12, 8, 10}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %gL%g %g',83}, -- S
            [84] = {{0, 12, 8, 12, 4, 12, 4, 0}, 10,'M%g %gL%g %g M%g %gL%g %g',84}, -- T
            [85] = {{0, 12, 0, 2, 4, 0, 8, 2, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',85}, -- U
            [86] = {{0, 12, 4, 0, 8, 12}, 10,'M%g %gL%g %gL%g %g',86}, -- V
            [87] = {{0, 12, 2, 0, 4, 4, 6, 0, 8, 12}, 10,'M%g %gL%g %gL%g %gL%g %gL%g %g',87}, -- W
            [88] = {{0, 0, 8, 12, 0, 12, 8, 0}, 10,'M%g %gL%g %g M%g %gL%g %g',88}, -- X
            [89] = {{0, 12, 4, 6, 8, 12, 4, 6, 4, 0}, 10,'M%g %gL%g %gL%g %g M%g %gL%g %g',89}, -- Y
            
            [90] = {{0, 12, 8, 12, 0, 0, 8, 0, 2, 6, 6, 6}, 10,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',90}, -- Z
            [91] = {{6, 0, 2, 0, 2, 12, 6, 12}, 6,'M%g %gL%g %gL%g %gL%g %g',91}, -- [
            [92] = {{0, 12, 8, 0}, 10,'M%g %gL%g %g',92}, -- \
            [93] = {{2, 0, 6, 0, 6, 12, 2, 12}, 6,'M%g %gL%g %gL%g %gL%g %g',93}, -- ]
            [94] = {{2, 6, 4, 12, 6, 6}, 6,'M%g %gL%g %gL%g %g',94}, -- ^
            [95] = {{0, 0, 8, 0}, 10,'M%g %gL%g %g',95}, -- _
            [96] = {{2, 12, 6, 8}, 6,'M%g %gL%g %g',96}, -- `
            
            [123] = {{6, 0, 4, 2, 4, 10, 6, 12, 2, 6, 4, 6}, 6,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',123}, -- {
            [124] = {{4, 0, 4, 5, 4, 6, 4, 12}, 6,'M%g %gL%g %g M%g %gL%g %g',124}, -- |
            [125] = {{4, 0, 6, 2, 6, 10, 4, 12, 6, 6, 8, 6}, 6,'M%g %gL%g %gL%g %gL%g %g M%g %gL%g %g',125}, -- }
            [126] = {{0, 4, 2, 8, 6, 4, 8, 8}, 10,'M%g %gL%g %gL%g %gL%g %g',126}, -- ~
        }
        
        function ObjectGroup(objects, transX, transY)
            local objects=objects or {}
            local self={style='',gStyle='',objects=objects,transX=transX,transY=transY,enabled=true,glow=false,gRad=10,scale = false}
            function self.addObject(object, id)
                local id=id or #objects+1
                objects[id]=object
                return id
            end
            function self.setStyle(style) self.style = style end
            function self.removeObject(id) objects[id] = {} end
            function self.hide() self.enabled = false end
            function self.show() self.enabled = true end
            function self.isEnabled() return self.enabled end
            function self.setGlowStyle(gStyle) self.gStyle = gStyle end
            function self.setGlow(enable,radius,scale) self.glow = enable; self.gRad = radius or self.gRad; self.scale = scale or false end 
            return self
        end
        
        local function RotationHandler(rotArray,resultantPos)
            
            --====================--
            --Local Math Functions--
            --====================--
            local manager,rad,sin,cos,rand = getManager(),math.rad,math.sin,math.cos,math.random
            local rotMatrixToQuat = manager.rotMatrixToQuat
            local function getQuaternion(x,y,z,w)
                if type(x) == 'number' then
                    if w == nil then
                        if x == x and y == y and z == z then
                            x = -rad(x * 0.5)
                            y = rad(y * 0.5)
                            z = -rad(z * 0.5)
                            local s,c=sin,cos
                            local sP,sH,sR=s(x),s(y),s(z)
                            local cP,cH,cR=c(x),c(y),c(z)
                            return (sP*cH*cR-cP*sH*sR),(cP*sH*cR+sP*cH*sR),(cP*cH*sR-sP*sH*cR),(cP*cH*cR+sP*sH*sR)
                        else
                            return 0,0,0,1
                        end
                    else
                        return x,y,z,w
                    end
                elseif type(x) == 'table' then
                    if #x == 3 then
                        return rotMatrixToQuat(x, y, z)
                    elseif #x == 4 then
                        return x[1],x[2],x[3],x[4]
                    else
                        system.print('Unsupported Rotation!')
                    end
                end
            end
            local function multiply(ax,ay,az,aw,bx,by,bz,bw)
                return ax*bw+aw*bx+ay*bz-az*by,
                    ay*bw+aw*by+az*bx-ax*bz,
                    az*bw+aw*bz+ax*by-ay*bx,
                    aw*bw-ax*bx-ay*by-az*bz
            end
            local function rotatePoint(ax,ay,az,aw,oX,oY,oZ,wX,wY,wZ)
                local axax,ayay,azaz,awaw=ax*ax,ay*ay,az*az,aw*aw
                return 
                2*(oY*(ax*ay-aw*az)+oZ*(ax*az+aw*ay))+oX*(awaw+axax-ayay-azaz)+wX,
                2*(oX*(aw*az+ax*ay)+oZ*(ay*az-aw*ax))+oY*(awaw-axax+ayay-azaz)+wY,
                2*(oX*(ax*az-aw*ay)+oY*(ax*aw+ay*az))+oZ*(awaw-axax-ayay+azaz)+wZ    
            end
            local superManager,needsUpdate = nil,false
            
            --=================--
            --Positional Values--
            --=================--
            local pX,pY,pZ = resultantPos[1],resultantPos[2],resultantPos[3] -- These are original values, for relative to super rotation
            local offX,offY,offZ = 0,0,0
            local wXYZ = resultantPos
            --==================--
            --Orientation Values--
            --==================--
            local tix,tiy,tiz,tiw = 0,0,0,1 -- temp intermediate rotation values
            local tdx,tdy,tdz,tdw = 0,0,0,1 -- temp default intermediate rotation values
            
            local ix,iy,iz,iw = 0,0,0,1 -- intermediate rotation values
            local dx,dy,dz,dw = 0,0,0,1 -- default intermediate rotation values
            
            local out_rotation = rotArray
            local subRotations = {}
            
            --==============--
            --Function Array--
            --==============--
            local out = {}
            
            --============================--
            --Primary Processing Functions--
            --============================--
            local function process(wx,wy,wz,ww,lX,lY,lZ,lTX,lTY,lTZ,n)
                local timeStart = system.getTime()
                
                n = n or 1
                wx,wy,wz,ww = wx or 0, wy or 0, wz or 0, ww or 1
                lX,lY,lZ = lX or pX, lY or pY, lZ or pZ
                lTX,lTY,lTZ = lTX or pX, lTY or pY, lTZ or pZ
                
                local dX,dY,dZ = pX - lX, pY - lY, pZ - lZ
        
                if ww ~= 1 and ww ~= -1 then
                    if dX ~= 0 or dY ~= 0 or dZ ~= 0 then
                        wXYZ[1],wXYZ[2],wXYZ[3] = rotatePoint(wx,wy,wz,ww,dX,dY,dZ,lTX,lTY,lTZ)
                else
                        wXYZ[1],wXYZ[2],wXYZ[3] = lTX,lTY,lTZ
                    end
                    if dw ~= 1 then
                        wx,wy,wz,ww = multiply(wx,wy,wz,ww,dx,dy,dz,dw)
                    end
                    if iw ~= 1 then
                        wx,wy,wz,ww = multiply(wx,wy,wz,ww,ix,iy,iz,iw)
                    end
                else
                    local nX,nY,nZ = lTX+dX,lTY+dY,lTZ+dZ
                    wXYZ[1],wXYZ[2],wXYZ[3] = nX,nY,nZ
                    if dw ~= 1 then
                        if iw ~= 1 then
                            wx,wy,wz,ww = multiply(dx,dy,dz,dw,ix,iy,iz,iw)
                        else
                            wx,wy,wz,ww = dx,dy,dz,dw
                        end
                    else
                        if iw ~= 1 then
                            wx,wy,wz,ww = ix,iy,iz,iw
                        end
                    end
                end
                out_rotation[1],out_rotation[2],out_rotation[3],out_rotation[4] = wx,wy,wz,ww
                for i=1, #subRotations do
                    subRotations[i].update(wx,wy,wz,ww,pX,pY,pZ,wXYZ[1],wXYZ[2],wXYZ[3],n+1)
            end
                local endTime = system.getTime()
                needsUpdate = false
            end
            local function validate()
                if not superManager then
                    process()
                else
                    superManager.bubble()
                end
            end
            local function rotate(isDefault)
                if isDefault then
                    dx,dy,dz,dw = getQuaternion(tdx,tdy,tdz,tdw)
                else
                    ix,iy,iz,iw = getQuaternion(tix,tiy,tiz,tiw)
                end
                validate()
            end
            
            out.update = process
            
            function out.setSuperManager(rotManager)
                superManager = rotManager
            end
            
            function out.addSubRotation(rotManager)
                rotManager.setSuperManager(out)
                subRotations[#subRotations + 1] = rotManager
                process()
            end
            function out.getPosition()
                return pX,pY,pZ
            end
            function out.setPosition(tx,ty,tz)
                
                if not (tx ~= tx or ty ~= ty or tz ~= tz)  then
                    
                    pX,pY,pZ = tx,ty+rand()*0.00001,tz
                    out.bubble()
                end
            end
            function out.bubble()
                if superManager then
                    superManager.bubble()
                else
                    needsUpdate = true
                end
            end
            function out.checkUpdate()
                if needsUpdate then
                    local startTime = system.getTime()
                    process()
                    --logRotation.addValue(system.getTime() - startTime)
                end
                return needsUpdate
            end
            
            function out.rotateXYZ(rotX,rotY,rotZ,rotW)
                if rotX and rotY and rotZ then
                    tix,tiy,tiz,tiw = rotX,rotY,rotZ,rotW
                    rotate(false)
                else
                    if type(rotX) == 'table' then
                        if #rotX == 3 then
                            tix,tiy,tiz,tiw = rotX[1],rotX[2],rotX[3],nil
                            goto valid  
                        end
                    end
                    print('Invalid format. Must be three angles, or right, forward and up vectors, or a quaternion. Use radians if angles.')
                    ::valid::
                end
            end
            
            function out.rotateX(rotX) tix = rotX; tiw = nil; rotate(false) end
            function out.rotateY(rotY) tiy = rotY; tiw = nil; rotate(false) end
            function out.rotateZ(rotZ) tiz = rotZ; tiw = nil; rotate(false) end
            
            function out.rotateDefaultXYZ(rotX,rotY,rotZ,rotW)
                if rotX and rotY and rotZ then
                    tdx,tdy,tdz,tdw = rotX,rotY,rotZ,rotW
                    rotate(true)
                else
                    if type(rotX) == 'table' then
                        if #rotX == 3 then
                            tdx,tdy,tdz,tdw = rotX[1],rotX[2],rotX[3],nil
                            goto valid  
                        end
                    end
                    print('Invalid format. Must be three angles, or right, forward and up vectors, or a quaternion. Use radians if angles.')
                    ::valid::
                end
            end
            
            function out.rotateDefaultX(rotX) tdx = rotX; tdw = nil; rotate(true) end
            function out.rotateDefaultY(rotY) tdy = rotY; tdw = nil; rotate(true) end
            function out.rotateDefaultZ(rotZ) tdz = rotZ; tdw = nil; rotate(true) end
            return out
        end
        
        function Object(style, position, offset, orientation, positionType, orientationType, transX, transY)
            
            
            
            local rad,print,rand=math.rad,system.print,math.random
            
            local position=position
            local positionOffset=offset
            
            local style=style
            local customGroups,uiGroups,subObjects={},{},{}
            local positionType=positionType
            local orientationType=orientationType
            local ori = {0,0,0,1}
            local objRotationHandler = RotationHandler(ori,position)
            objRotationHandler.rotateXYZ(orientation)
            
            local defs = {}
            local self = {
                false,false,false,customGroups,false,uiGroups,subObjects,
                positionType, --8
                orientationType, --9
                ori,
                style,
                position,
                offset,
                transX,
                transY,
                defs
            }
            function self.addDef(string)
                defs[#defs + 1] = string
            end
            function self.resetDefs()
                defs = {}
            end
        
            function self.setCustomSVGs(groupId,style,scale)
                local multiPoint={}
                local singlePoint={}
                local group={style,multiPoint,singlePoint}
                local scale=scale or 1
                local mC,sC=1,1
                self[4][groupId]=group
                local offset=positionOffset
                local offsetX,offsetY,offsetZ=offset[1],offset[2],offset[3]
                local self={}
                function self.addMultiPointSVG()
                    local points={}
                    local data=nil
                    local drawFunction=nil
                    local self={}
                    local pC=1
                    function self.addPoint(point)
                        local point=point
                        points[pC]={point[1]/scale+offsetX,point[2]/scale-offsetY,point[3]/scale-offsetZ}
                        pC=pC+1
                        return self
                    end
                    function self.bulkSetPoints(bulk)
                        points=bulk
                        pC=#points+1
                        return self
                    end
                    function self.setData(dat)
                        data=dat
                        return self
                    end
                    function self.setDrawFunction(draw)
                        drawFunction=draw
                        return self
                    end
                    function self.build()
                        if pC > 1 then
                            if drawFunction ~= nil then
                                multiPoint[mC]={points, drawFunction, data}
                                mC=mC+1
                                return points
                            else print("WARNING! Malformed multi-point build operation, no draw function specified. Ignoring.")
                            end
                        else print("WARNING! Malformed multi-point build operation, no points specified. Ignoring.")
                        end
                    end
                    return self
                end
                function self.addSinglePointSVG()
                    local self={}
                    local outArr = {false,false,false,false,false,false}
                    singlePoint[sC] = outArr
                    sC=sC+1
                    function self.setPosition(position)
                        outArr[2],outArr[3],outArr[4]=position[1]/scale+offsetX,position[2]/scale-offsetY,position[3]/scale-offsetZ
                        return self
                    end
                    function self.setDrawFunction(draw)
                        outArr[5] = draw
                        return self
                    end
                    function self.setData(dat)
                        outArr[6] = dat
                        return self
                    end
                    function self.setEnabled(enabled)
                        outArr[1] = enabled
                        return self
                    end
                    function self.build()
                        outArr[1] = true
                        return self
                    end
                    return self
                end
                return self
            end
            function self.setUIElements(style, groupId)
                groupId = groupId or 1
                local sqrt, s, c,remove = math.sqrt, math.sin, math.cos, table.remove
        
                local function createNormal(points, rx, ry, rz, rw)
                    if #points < 6 then
                        print("Invalid Point Set!")
                        do
                            return
                        end
                    end
                    return 2*(rx*ry-rz*rw),1-2*(rx*rx+rz*rz),2*(ry*rz+rx*rw)
                end
                local function createBounds(points)
                    local bounds = {}
                    local size = #points
                    if size >= 60 then
                        return false
                    end
                    local delta = 1
                    for i = 1, size, 2 do
                        bounds[delta] = {points[i],points[i+1]}
                        delta = delta + 1
                    end
                    return bounds
                end
                
                local elements = {}
                local modelElements = {}
                local elementClasses = {}
                local selectedElement = false
                
                local group = {style, elements, selectedElement,modelElements}
        
                self[6][groupId] = group
        
                local self = {}
                local pC, eC = 0, 0
        
                local function createUITemplate(x,y,z)
                    
                    local user = {}
                    local raw = {}
                    
                    local huge = math.huge
                    local maxX,minX,maxY,minY = -huge,huge,-huge,huge
                    
                    local pointSet = {}
                    local actions = {false,false,false,false,false,false,false}
                    local mainRotation = {0,0,0,1}
                    local resultantPos = {x,y+rand()*0.000001,z}
                    local mRot = RotationHandler(mainRotation,resultantPos)
                    
                    --system.print(string.format('UI Create {%.2f,%.2f,%.2f}', resultantPos[1],resultantPos[2],resultantPos[3]))
                    local elementData = {false, false, false, actions, false, true, false, false, pointSet, resultantPos, false,false,false,false, mainRotation,mRot}
                    local subElements = {}
                    local elementIndex = eC + 1
                    elements[elementIndex] = elementData
                    eC = elementIndex
                
                    function user.addSubElement(element)
                        local index = #subElements + 1
                        if element then
                            subElements[index] = element
                            mRot.addSubRotation(element.getRotationManager())
                        end
                        return index
                    end
                    function user.removeSubElement(index)
                        remove(subElements, index)
                    end
                    function user.getId()
                        return elementIndex
                    end
                    function elementData.getId()
                        return elementIndex
                    end
                    local function handleBound(x,y)
                        if x > maxX then
                            maxX = x
                        end
                        if x < minX then
                            minX = x
                        end
                        if y > maxY then
                            maxY = y
                        end
                        if y < minY then
                            minY = y
                        end
                    end
                    function user.addPoint(x,y)
                        local pC = #pointSet
                        if x and y then
                            handleBound(x,y)
                            pointSet[pC+1] = x
                            pointSet[pC+2] = y
                        else
                            if type(x) == 'table' and #x > 0 then
                                local x,y = x[1], x[2]
                                handleBound(x,y)
                                pointSet[pC+1] = x
                                pointSet[pC+2] = y
                            else
                                print('Invalid format for point.')
                            end
                        end
                    end
                    function user.addPoints(points)
                        local pnts = elementData[9]
                        pointSet = pnts
                        if points then
                            local pointCount = #points
                            if pointCount > 0 then
                                local pType = type(points[1])
                                if pType == 'number' then
                                    local startIndex = #pnts
                                    for i = 1, pointCount,2 do
                                        local index = startIndex + i
                                        
                                        local x,y = points[i],points[i+1]
                                        handleBound(x,y)
                                        
                                        pnts[index] = x
                                        pnts[index+1] = y
                                    end
                                elseif pType == 'table' then
                                    
                                    local startIndex = #pnts
                                    local interval = 1
                                    for i = 1, pointCount do
                                        local index = startIndex + interval
                                        
                                        local point = points[i]
                                        local x,y = point[1],point[2]
                                        handleBound(x,y)
                                        
                                        pnts[index] = x
                                        pnts[index + 1] = y
                                        interval=interval+2
                                    end
                                else
                                    print('No compatible format found.')
                                end
                            end
                        end
                    end
                        
                    function user.getRotationManager()
                        return mRot
                    end
                    
                    local function updateNormal()
                        if elementData[14] then
                            user.setNormal(createNormal(pointSet, mainRotation[1],mainRotation[2],mainRotation[3],mainRotation[4]))
                        end
                    end
                    
                    function user.rotateDefaultXYZ(rX,rY,rZ,rW) mRot.rotateDefaultXYZ(rX,rY,rZ,rW); updateNormal() end
                    function user.rotateDefaultX(rX) mRot.rotateDefaultX(rX); updateNormal() end
                    function user.rotateDefaultY(rY) mRot.rotateDefaultY(rY); updateNormal() end
                    function user.rotateDefaultZ(rZ) mRot.rotateDefaultZ(rZ); updateNormal() end
                    
                    function user.rotateXYZ(rX,rY,rZ,rW) mRot.rotateXYZ(rX,rY,rZ,rW); updateNormal() end
                    function user.rotateX(rX) mRot.rotateX(rX); updateNormal() end
                    function user.rotateY(rY) mRot.rotateY(rY); updateNormal() end
                    function user.rotateZ(rZ) mRot.rotateZ(rZ); updateNormal() end
                    
        
                    local function drawChecks()
                        local defaultDraw = elementData[2]
                        if defaultDraw then
                            if not elementData[3] then
                                elementData[3] = elementData[2]
                            end
                            if not elementData[1] then
                                elementData[1] = elementData[2]
                            end
                        end
                    end
                    local function actionCheck()
                        actions[7] = true
                    end
                    
                    function user.setHoverDraw(hDraw) elementData[1] = hDraw; drawChecks() end
                    function user.setDefaultDraw(dDraw) elementData[2] = dDraw; drawChecks() end
                    function user.setClickDraw(cDraw) elementData[3] = cDraw; drawChecks() end
                    
                    function user.setClickAction(action) actions[1] = action; actionCheck() end
                    function user.setHoldAction(action) actions[2] = action; actionCheck() end
                    function user.setEnterAction(action) actions[3] = action; actionCheck() end
                    function user.setLeaveAction(action) actions[4] = action; actionCheck() end
                    function user.setHoverAction(action) actions[5] = action; actionCheck() end
                    function user.setIdentifier(identifier) actions[6] = identifier; end
                    
                    function user.setScale(scale) 
                        elementData[5] = scale
                    end
                    
                    function user.getMaxValues()
                        return maxX,minX,maxY,minY
                    end
                    
                    function user.hide() elementData[6] = false end
                    function user.show() elementData[6] = true end
                    function user.isShown() return elementData[6] end  
                    
                    function user.remove() 
                        remove(elements,elementIndex)
                        remove(elementClasses,elementIndex)
                        for i = elementIndex, eC do
                            elementClasses[i].setElementIndex(i)
                        end
                    end
                    local psX,psY = 0,0
                    function user.move(sx,sy,indices,updateHitbox)
                        if not indices then
                            for i = 1, #pointSet, 2 do
                                pointSet[i] = pointSet[i] - psX + sx
                                pointSet[i+1] = pointSet[i+1] - psY + sy
                            end
                            maxX,minX,maxY,minY = maxX+sx,minX+sx,maxY+sy,minY+sy
                        else
                            for i=1,#indices do
                                local index = indices[i]*2-1
                                pointSet[index] = pointSet[index] - psX + sx
                                pointSet[index+1] = pointSet[index+1] - psY + sy
                            end
                            -- TODO: Check min-max values and update accordingly
                        end
                        psX = sx
                        psY = sy
                        
                        if updateHitbox then
                            user.setBounds(createBounds(pointSet))
                        end
                    end
                    local ogPointSet = nil
                    function user.moveTo(sx,sy,indices,updateHitbox,useOG)
                        if not indices then
                            print('ERROR: No indices specified!')
                        else
                            if not ogPointSet then
                                ogPointSet = {table.unpack(pointSet)}
                            end
                            for i=1,#indices do
                                local index = indices[i]*2-1
                                if not useOG then
                                    pointSet[index] = sx
                                    pointSet[index+1] = sy
                                else
                                    pointSet[index] = ogPointSet[index] + sx
                                    pointSet[index+1] = ogPointSet[index+1] + sy
                                end
                            end
                            -- TODO: Check min-max values and update accordingly
                        end
                        if updateHitbox then
                            user.setBounds(createBounds(pointSet))
                        end
                    end
                    
                    function user.setDrawOrder(indices)
                        local drawOrder = {}
                        for i=1, #indices do
                            local index = indices[i]
                            
                            local order = drawOrder[index*2-1]
                            if not order then
                                order = {}
                                drawOrder[index*2-1] = order
                            end
                            order[#order+1] = i*2-1
                        end
                        elementData[7] = drawOrder
                    end
                    
                    function user.setDrawData(drawData) elementData[8] = drawData end
                    function user.getDrawData() return elementData[8] end
                    function user.setSizes(sizes) 
                        if not elementData[8] then
                            elementData[8] = {['sizes'] = sizes}
                        else
                            elementData[8].sizes = sizes
                        end
                    end
                    function user.getDrawOrder() return elementData[7] end
                    
                    function user.getPoints() return elementData[9] end
                    
                    function user.setDrawOrder(drawOrder) elementData[7] = drawOrder end
                    function user.setDrawData(drawData) elementData[8] = drawData end
                    
                    function user.setPoints(points) pointSet = points; elementData[9] = pointSet end
                    
                    function user.setElementIndex(eI) elementIndex = eI end
                    function user.getElementIndex(eI) return elementIndex end
                    
                    function user.setPosition(sx,sy,sz)
                        mRot.setPosition(sx,sy,sz)
                    end
                    
                    function user.setNormal(nx,ny,nz)
                        elementData[11] = nx
                        elementData[12] = ny
                        elementData[13] = nz
                    end
                    
                    function user.setBounds(bounds)
                        elementData[14] = bounds
                    end
                    function user.getPosition() return mRot.getPosition() end
                    
                    function user.build(force, hasBounds)
                        
                        local nx, ny, nz = createNormal(pointSet, mainRotation[1],mainRotation[2],mainRotation[3],mainRotation[4])
                        if nx then
                            if elementData[2] then
                                user.setNormal(nx,ny,nz)
                                if not force then
                                    if hasBounds or hasBounds == nil then
                                        user.setBounds(createBounds(pointSet))
                                    else
                                        user.setBounds(false)
                                    end
                                end
                            else
                                print("Element Malformed: No default draw.")
                            end
                        else
                            print("Element Malformed: Insufficient points.")
                        end
                    end
                    return user, elementData
                end
        
                function self.createText(tx, ty, tz)
                    local concat,byte,upper = table.concat,string.byte,string.upper
                    
                    local userFunc, text = createUITemplate(tx, ty, tz)
                    local textCache,offsetCacheX,offsetCacheY,txt = {},{},0,''
                    local drawData = {['sizes']={0.08333333333},'white',1}
                    local alignmentX,alignmentY = 'middle','middle'
                    local wScale = 1
                    local mx,my = 0,0
                    local maxX,minX,maxY,minY = userFunc.getMaxValues()
                    
                    userFunc.setDrawData(drawData)
                    
                    function userFunc.getMaxValues()
                        return maxX,minX,maxY,minY
                    end
                    function userFunc.getText()
                        return txt
                    end
                    local function buildTextCache(text)
                        txt = text
                        local result = {byte(upper(text), 1, #text)}
                        textCache = {}
                        for k = 1, #result do
                            local charCode = result[k]
                            textCache[k] = TEXT_ARRAY[charCode]
                        end
                    end
                    local function buildOffsetCache()
                        offsetCacheX = {0}
                        local offsetXCounter = 1
                        local tmpX,tmpY = 0,0
                        local fontSize = drawData.sizes[1] / wScale
                        
                        for k = 1, #textCache do
                            local char = textCache[k]
                            if char[4] == 10 then
                                tmpY = tmpY + char[2] * fontSize
                                if alignmentX == "middle" then
                                    tmpX = -tmpX * 0.5
                                elseif alignmentX == "end" then
                                    tmpX = -tmpX
                                elseif alignmentX == "start" then
                                    tmpX = 0
                                end
                                offsetCacheX[offsetXCounter] = tmpX
                                offsetXCounter = offsetXCounter + 1
                                tmpX = 0
                            else
                                tmpX = tmpX + char[2] * fontSize
                            end
                        end
                        if alignmentX == "middle" then
                            tmpX = -tmpX * 0.5
                        elseif alignmentX == "end" then
                            tmpX = -tmpX
                        elseif alignmentX == "start" then
                            tmpX = 0
                        end
                        if alignmentY == 'middle' then
                            tmpY = tmpY + 12 * fontSize
                            offsetCacheY = -tmpY * 0.5
                        elseif alignmentY == 'top' then
                            tmpY = tmpY + 12 * fontSize
                            offsetCacheY = -tmpY
                        elseif alignmentY == 'bottom' then
                            offsetCacheY = 0
                        end
                        offsetCacheX[offsetXCounter] = tmpX
                    end
                    
                    local function handleBound(x,y)
                        if x > maxX then
                            maxX = x
                        end
                        if x < minX then
                            minX = x
                        end
                        if y > maxY then
                            maxY = y
                        end
                        if y < minY then
                            minY = y
                        end
                    end
                    
                    local function buildPoints()
                        local offsetY = offsetCacheY
                        local woffsetX,offsetXCounter = offsetCacheX[1],1
                        local fontSize = drawData.sizes[1] / wScale
        
                        local points,drawStrings = {},{'<path stroke-width="%gpx" stroke="%s" stroke-opacity="%g" fill="none" d="'}
                        local count = 1
                        
                        local textCacheSize = #textCache
                        
                        for k = 1, textCacheSize do
                            local char = textCache[k]
                            drawStrings[k + 1] = char[3]
                            
                            local charPoints, charSize = char[1], char[2]
                            for m = 1, #charPoints, 2 do
                                local x,y = charPoints[m] * fontSize + woffsetX + mx, charPoints[m + 1] * fontSize + offsetY + my
                                
                                handleBound(x,y)
                                
                                points[count] = x
                                points[count + 1] = y
                                count = count + 2
                            end
                            woffsetX = woffsetX + charSize * fontSize
                            if char[4] == 10 then
                                offsetXCounter = offsetXCounter + 1
                                woffsetX = offsetCacheX[offsetXCounter]
                                offsetY = offsetY - charSize * fontSize
                            end
                        end
        
                        drawStrings[textCacheSize+2] = '"/>'
                        
                        userFunc.setDefaultDraw(concat(drawStrings))
                        userFunc.setPoints(points)
                    end
                    
                    function userFunc.setText(text)
                        buildTextCache(text)
                        buildOffsetCache()
                        
                        buildPoints()
                    end
                    
                    function userFunc.setWeight(scale)
                        local sizes = drawData.sizes
                        sizes[1] = sizes[1] / wScale
                        wScale = scale or wScale
                        sizes[1] = sizes[1] * wScale
                        if #textCache > 0 then
                            buildPoints()
                        end
                    end
                    local oldUserFunc = userFunc.move
                    function userFunc.move(x,y)
                        mx = mx + x
                        my = my + y
                        oldUserFunc(x,y)
                    end
                    function userFunc.setFontSize(size)
                        local sizes = drawData.sizes
                        sizes[1] = size * 0.08333333333
                        if #textCache > 0 then
                            buildOffsetCache()
                            buildPoints()
                        end
                    end
                    function userFunc.setAlignmentX(alignX)
                        alignmentX = alignX
                        if #textCache > 0 then
                            buildOffsetCache()
                            buildPoints()
                        end
                    end
                    function userFunc.setAlignmentY(alignY)
                        alignmentY = alignY
                        if #textCache > 0 then
                            buildOffsetCache()
                            buildPoints()
                        end
                    end
                    function userFunc.setFontColor(color)
                        drawData[1] = color
                    end
                    function userFunc.setOpacity(opacity)
                        drawData[2] = opacity
                    end
                    
                    return userFunc,textTemplate
                end
        
                function self.createButton(bx, by, bz)
                    local userFunc,button = createUITemplate(bx, by, bz)
                    local txtFuncs
                    function userFunc.setText(text,rx, ry, rz)
                        rx,ry,rz = rx or 0, ry or -0.01, rz or 0
                        if not txtFuncs then
                            txtFuncs = self.createText(bx+rx, by+ry, bz+rz)
                            userFunc.addSubElement(txtFuncs)
                        else
                            txtFuncs.setPosition(bx+rx, by+ry, bz+rz)
                        end
                        local maxX,minX,maxY,minY = userFunc.getMaxValues()
                        local cheight = maxY-minY
                        local cwidth = maxX-minX
                        txtFuncs.setText(text)
                        
                        local tMaxX,tMinX,tMaxY,tMinY = txtFuncs.getMaxValues()
                        local theight = tMaxY-tMinY
                        local twidth = tMaxX-tMinX
                        local r1,r2 = theight/cheight,twidth/cwidth
                        if r1 < r2 then
                            local size = theight/r2
                            txtFuncs.setFontSize((size)*0.75)
                        else
                            local size = theight/r1
                            txtFuncs.setFontSize((size)*0.75)
                        end
                        return txtFuncs
                    end
                    return userFunc
                end
                
                function self.createProgressBar(ex, ey, ez)
                    
                    local userFuncOut,outline = createUITemplate(ex, ey, ez)
                    local userFuncFill,fill = createUITemplate(ex, ey, ez, 1)
        
                    userFuncOut.addSubElement(userFuncFill)
        
                    local sPointIndices = {}
                    local ePointIndices = {}
                    local intervals = {}
                    local progress = 100
                    
                    function userFuncOut.getIntervals()
                        return intervals
                    end
                    
                    function userFuncOut.getProgress(pX)
                        local points = userFuncFill.getPoints()
                        if pX then
                            local c = intervals[1]
                            local xC = c[1]
                            
                            local prog = (pX - points[sPointIndices[1]])/xC
                            if prog < 0 then 
                                return 0.001 
                            elseif prog > 100 then 
                                return 100 
                            else 
                                return prog 
                            end
                        end
                        return progress
                    end
                    
                    local function makeIntervals()
                        
                        local sPCount = #sPointIndices
                        local ePCount = #ePointIndices
                        
                        local points = userFuncFill.getPoints()
                        if #points > 0 then
                            if sPCount == ePCount and sPCount > 0 then
                                for i=1, sPCount do
                                    local sPI = sPointIndices[i]
                                    local ePI = ePointIndices[i]
                                    
                                    local xChangePercent = (points[ePI]-points[sPI]) * 0.01
                                    local yChangePercent = (points[ePI+1]-points[sPI+1]) * 0.01
                                    intervals[i] = {xChangePercent,yChangePercent}
                                end
                            end
                        end
                    end
                    
                    function userFuncOut.setStartIndices(indices)
                        for i=1, #indices do
                            local index = indices[i]*2-1
                            sPointIndices[i]=index
                        end
                        makeIntervals()
                    end
                    
                    function userFuncOut.setEndIndices(indices)
                        for i=1, #indices do
                            local index = indices[i]*2-1
                            ePointIndices[i]=index
                        end
                        makeIntervals()
                    end
                    
                    local addPointsOld = userFuncOut.addPoints
                    function userFuncOut.addPoints(points) 
                        addPointsOld(points)
                        makeIntervals()
                    end
                    
                    function userFuncOut.setProgress(prog)
                        progress = prog or 0
                        if progress < 0 then
                            progress = 0
                        end
                        if progress > 100 then
                            progress = 100
                        end
                        local points = userFuncOut.getPoints()
                        
                        for i=1, #ePointIndices do
                            local c = intervals[i]
                            local xC,yC = c[1],c[2]
                            local sPI = sPointIndices[i]
                            local ePI = ePointIndices[i]
                            
                            points[ePI] = points[sPI] + xC * progress
                            points[ePI+1] = points[sPI+1] + yC * progress
                            
                        end
                    end
                    function userFuncOut.setFillPoints(points)
                        userFuncFill.addPoints(points)
                    end
                    function userFuncOut.getFillDrawData()
                    return userFuncFill.getDrawData() 
                    end
                    function userFuncOut.setFillDrawData(drawData)
                        userFuncFill.setDrawData(drawData)
                    end
                    function userFuncOut.setFillDraw(draw)
                        userFuncFill.setDefaultDraw(draw)
                    end
                    function userFuncOut.setFillOffsetPosition(tx,ty,tz)
                        userFuncFill.setOffsetPosition(tx,ty,tz)
                    end
                    
                    return userFuncOut
                end
                function self.createCustomDraw(x,y,z)
                    return createUITemplate(x,y,z)
                end
                local mElementIndex = 0
                function self.create3DObject(x,y,z)
                    local userFunc = {}
                    local pointSet = {{},{},{},{}}
                    local drawStrings = {}
                    local faces = {}
                    
                    local actions = {false,false,false,false,false,false}
                    local elementData = {is3D = true, false, false, false, actions, false, true, false, false, pointSet, x, y, z,faces}
                    local eC = mElementIndex + 1
                    mElementIndex = eC
                    local mElementIndex = eC
                    modelElements[eC] = elementData
                    
                    function userFunc.addPoints(points,ref)
                        local pntX,pntY,pntZ,rotation = pointSet[1],pointSet[2],pointSet[3],pointSet[4]
                        local s1,s2 = #pntX, #points
                        local total = s1+s2
                        pntX[total] = false
                        pntY[total] = false
                        pntZ[total] = false
                        
                        for i=s1+1, total do
                            local pnt = points[i]
                            pntX[i] = pnt[1]
                            pntY[i] = pnt[2]
                            pntZ[i] = pnt[3]
                        end
                    end
                    
                    
                    function userFunc.setFaces(newFaces,r,g,b)
                        local concat,remove = table.concat,table.remove
                        local pntX,pntY,pntZ = pointSet[1],pointSet[2],pointSet[3]
                        
                        local function getData(pointIndices)
                            local pntCount = #pointIndices
                            if pntCount > 2 then
                                local p1i,p2i,p3i = pointIndices[1],pointIndices[2],pointIndices[3]
                                local p1x,p1y,p1z,p2x,p2y,p2z,p3x,p3y,p3z = pntX[p1i],pntY[p1i],pntZ[p1i],pntX[p2i],pntY[p2i],pntZ[p2i],pntX[p3i],pntY[p3i],pntZ[p3i]
                                
                                local v1x,v1y,v1z = p2x-p1x,p2y-p1y,p2z-p1z
                                local v2x,v2y,v2z = p3x-p1x,p3y-p1y,p3z-p1z
                                local nx,ny,nz = v1y*v2z-v1z*v2y,v1z*v2x-v1x*v2z,v1x*v2y-v2x*v1y
                                local mag = (nx*nx+ny*ny+nz*nz)^(0.5)
                                nx,ny,nz = nx/mag,ny/mag,nz/mag
                                local pX,pY,pZ = p1x+p2x+p3x,p1y+p2y+p3y,p1z+p2z+p3z
                                local oData = nil
                                if pntCount == 4 then
                                    local tmpOData = getData({pointIndices[4],pointIndices[1],pointIndices[3]})
                                    if not (tmpOData[4] == nx and tmpOData[5] == ny and tmpOData[6] == nz) then
                                        remove(pointIndices,4)
                                        oData = tmpOData
                                    end
                
                                end
                                local count = 3
                                local string = {'<path color=rgb(%.f,%.f,%.f) d="M%.1f %.1fL%.1f %.1f %.1f %.1f'}
                                local sCount = 2
                                for i=4, #pointIndices do
                                    local pi = pointIndices[i]
                                    pX,pY,pZ = pX + pntX[pi],pY+ pntY[pi],pZ+ pntZ[pi] 
                                    count = count + 1
                                    string[sCount] = ' %.1f %.1f'
                                    sCount = sCount + 1
                                end
                                string[sCount] = 'Z"/>'
                                --local pn1 = pointIndices[1]
                                
                                return {pX/count,pY/count,pZ/count,nx,ny,nz,pointIndices,r,g,b,concat(string)},oData
                            end
                        end
                        local m = 1
                        for i=1, #newFaces do
                            local data,oData = getData(newFaces[i])
                            faces[m] = data
                            m=m+1
                            if oData then
                                faces[m] = oData
                                m=m+1
                            end
                        end
                    end
                    
                    function userFunc.setScale()
                    end
                    function userFunc.setDrawData(drawData) elementData[8] = drawData end
                    
                    return userFunc
                end
                function self.createSlider(uiElement, center)
                    local self = {}
                    return self
                end
                return self
            end
            
            function self.setPosition(posX, posY, posZ) self[11] = {posX, posY, posZ} end
            
            function self.rotateDefaultXYZ(rX,rY,rZ,rW) objRotationHandler.rotateDefaultXYZ(rX,rY,rZ,rW); end
            function self.rotateDefaultX(rX) objRotationHandler.rotateDefaultX(rX); end
            function self.rotateDefaultY(rY) objRotationHandler.rotateDefaultY(rY); end
            function self.rotateDefaultZ(rZ) objRotationHandler.rotateDefaultZ(rZ); end
                    
            function self.rotateXYZ(rX,rY,rZ,rW) objRotationHandler.rotateXYZ(rX,rY,rZ,rW); end
            function self.rotateX(rX) objRotationHandler.rotateX(rX); end
            function self.rotateY(rY) objRotationHandler.rotateY(rY); end
            function self.rotateZ(rZ) objRotationHandler.rotateZ(rZ); end
            
            function self.addSubObject(object, id)
                local id=id or #self[6]+1
                self[6][id]=object
                return id
            end
            function self.removeSubObject(id)
                self[6][id]={}
            end
            
            function self.setSubObjects()
                local self={}
                local c=1
                function self.addSubObject(object)
                    self[6][c]=object
                    c=c+1
                    return self
                end
                return self
            end
            
            return self
        end
        
        function ObjectBuilderLinear()
            local self={}
            function self.setStyle(style)
                local self={}
                local style=style
                function self.setPosition(pos)
                    local self={}
                    local pos=pos
                    function self.setOffset(offset)
                        local self={}
                        local offset=offset
                        function self.setOrientation(orientation)
                            local self={}
                            local orientation=orientation
                            function self.setPositionType(positionType)
                                local self={}
                                local positionType=positionType
                                function self.setOrientationType(orientationType)
                                    local self={}
                                    local orientationType = orientationType
                                    local transX,transY=nil,nil
                                    function self.setTranslation(translateX,translateY)
                                        transX,transY=translateX,translateY
                                        return self
                                    end
                                    function self.build()
                                        return Object(style,pos,offset,orientation,positionType,orientationType,transX,transY)
                                    end
                                    return self
                                end
                                return self
                            end
                            return self
                        end
                        return self
                    end
                    return self
                end
                return self
            end
            return self
        end
        
        function Projector(camera)
            -- Localize frequently accessed data
            --local utils = require("cpml.utils")
        
            --local library=library
            local core, system, manager = core, system, getManager()
        
            -- Localize frequently accessed functions
            --- System-based function calls
            local getWidth, getHeight, getFov, getMouseDeltaX, getMouseDeltaY, print =
                system.getScreenWidth,
                system.getScreenHeight,
                system.getFov,
                system.getMouseDeltaX,
                system.getMouseDeltaY,
                system.print
        
            --- Core-based function calls
            local getCWorldR, getCWorldF, getCWorldU, getCWorldPos =
                core.getConstructWorldRight,
                core.getConstructWorldForward,
                core.getConstructWorldUp,
                core.getConstructWorldPos
        
            --- Camera-based function calls
            local getCameraLocalPos = system.getCameraPos
            local getCamLocalFwd, getCamLocalRight, getCamLocalUp =
                system.getCameraForward,
                system.getCameraRight,
                system.getCameraUp
        
            --- Manager-based function calls
            ---- Quaternion operations
            local matrixToQuat = manager.matrixToQuat
        
            -- Localize Math functions
            local maths = math
            local sin, cos, tan, rad ,atan =
                maths.sin,
                maths.cos,
                maths.tan,
                maths.rad,
                maths.atan
            --local rnd = utils.round
            -- Projection infomation
        
            --- FOV Paramters
            local vertFov = system.getCameraVerticalFov
            local horizontalFov = system.getCameraHorizontalFov
        
            local fnearDivAspect = 0
        
            local objectGroups = {}
        
            local self = {objectGroups = objectGroups}
            local oldSelected = false
            function self.getSize(size, zDepth, max, min)
                local pSize = atan(size, zDepth) * (fnearDivAspect)
                local max = max or pSize
                local min = min or pSize
                if pSize >= max then
                    return max
                elseif pSize <= min then
                    return min
                else
                    return pSize
                end
            end
        
            function self.addObjectGroup(objectGroup, id)
                local index = id or #objectGroups + 1
                objectGroups[index] = objectGroup
                return index
            end
        
            function self.removeObjectGroup(id)
                objectGroups[id] = {}
            end
        
            function self.getModelMatrix(mObject)
                local s, c = sin, cos
                local modelMatrices = {}
        
                -- Localize Object values.
                local objOri, objPos = mObject[10], mObject[12]
                local objPosX, objPosY, objPosZ = objPos[1], objPos[2], objPos[3]
        
                local cU, cF, cR = getCWorldU(), getCWorldF(), getCWorldR()
                local cRX, cRY, cRZ, cFX, cFY, cFZ, cUX, cUY, cUZ = cR[1], cR[2], cR[3], cF[1], cF[2], cF[3], cU[1], cU[2], cU[3]
                
                local wwx, wwy, wwz, www = objOri[1], objOri[2], objOri[3], objOri[4]
        
                local wx, wy, wz, ww = wwx, wwy, wwz, www
                if mObject[9] == 1 then
                    local sx,sy,sz,sw = matrixToQuat(cRX, cRY, cRZ, cFX, cFY, cFZ, cUX, cUY, cUZ)
                    local mx, my, mz, mw =
                        wx*sw + ww*sx + wy*sz - wz*sy,
                        wy*sw + ww*sy + wz*sx - wx*sz,
                        wz*sw + ww*sz + wx*sy - wy*sx,
                        ww*sw - wx*sx - wy*sy - wz*sz
                    wx, wy, wz, ww = mx, my, mz, mw
                end
                if mObject[8] == 2 then -- If Local
                    return wx, wy, wz, ww, 
                    objPosX, -- Convert this to 
                    objPosY, 
                    objPosZ
                else
                    local cWorldPos = getCWorldPos()
                    local oPX, oPY, oPZ = objPosX - cWorldPos[1], objPosY - cWorldPos[2], objPosZ - cWorldPos[3]
                    return wx, wy, wz, ww, 
                    cRX * oPX + cRY * oPY + cRZ * oPZ, 
                    cFX * oPX + cFY * oPY + cFZ * oPZ, 
                    cUX * oPX + cUY * oPY + cUZ * oPZ
                end
            end
        
            function self.getViewMatrix()
                local id = camera.cType.id
                local fG, fL = id == 0, id == 1
        
                if fG or fL then -- To do and fix (VERY broken now)
                    local s, c = sin, cos
                    local cOrientation = camera.orientation
                    local pitch, heading, roll = cOrientation[1] * 0.5, -cOrientation[2] * 0.5, cOrientation[3] * 0.5
                    local sP, sR, sH = s(pitch), s(heading), s(roll)
                    local cP, cR, cH = c(pitch), c(heading), c(roll)
        
                    local cx, cy, cz, cw = sP * cR, sP * sR, cP * sR, cP * cR
                    if fG then
                        wx, wy, wz, ww = cx, cy, cz, cw
                    else
                        local mx, my, mz, mw =
                            sx * cw + sw * cx + sy * cz - sz * cy,
                            sy * cw + sw * cy + sz * cx - sx * cz,
                            sz * cw + sw * cz + sx * cy - sy * cx,
                            sw * cw - sx * cx - sy * cy - sz * cz
                        wx, wy, wz, ww = mx, my, mz, mw
                    end
                else
                    local lEye = getCameraLocalPos()
                    local lEyeX, lEyeY, lEyeZ = lEye[1], lEye[2], lEye[3]
                    local lf, lr, lu =
                        getCamLocalFwd(),
                        getCamLocalRight(),
                        getCamLocalUp()
                    
                    local lrx, lry, lrz = lr[1], lr[2], lr[3]
                    local lfx, lfy, lfz = lf[1], lf[2], lf[3]
                    local lux, luy, luz = lu[1], lu[2], lu[3]
                    
                    return lrx, lry, lrz, 
                        lfx, lfy, lfz, 
                        lux, luy, luz, 
                        -(lrx * lEyeX + lry * lEyeY + lrz * lEyeZ), 
                        -(lfx * lEyeX + lfy * lEyeY + lfz * lEyeZ), 
                        -(lux * lEyeX + luy * lEyeY + luz * lEyeZ), 
                        lEyeX, lEyeY, lEyeZ
                end
            end
        
            function self.getSVG(isvg, fc)
                local isClicked = false
                if clicked then
                    clicked = false
                    isClicked = true
                end
                local isHolding = isHolding
                
                local fullSVG = isvg or {}
                local fc = fc or 1
        
                local vx1, vy1, vz1, vx2, vy2, vz2, vx3, vy3, vz3, vw1, vw2, vw3, lCX, lCY, lCZ =
                    self.getViewMatrix()
                local vx, vy, vz, vw = matrixToQuat(vx1, vy1, vz1, vx2, vy2, vz2, vx3, vy3, vz3)
        
                local atan, sort, format, unpack, concat, getModelMatrix =
                    atan,
                    table.sort,
                    string.format,
                    table.unpack,
                    table.concat,
                    self.getModelMatrix
                local width,height = getWidth()*0.5, getHeight()*0.5
                local aspect = width/height
                local tanFov = tan(rad(horizontalFov() * 0.5))
                local function zSort(t1, t2)
                    return t1[1] > t2[1]
                end
                --- Matrix Subprocessing
                local nearDivAspect = width / tanFov
                fnearDivAspect = nearDivAspect
                
                -- Localize projection matrix values
                local px1 = 1 / tanFov
                local pz3 = px1 * aspect
        
                local pxw = px1 * width
                local pzw = -pz3 * height
                -- Localize screen info
                local objectGroups = objectGroups
                local svgBuffer = {}
                local alpha = 1
                for i = 1, #objectGroups do
                    local objectGroup = objectGroups[i]
                    if objectGroup.enabled == false then
                        goto not_enabled
                    end
        
                    local objGTransX = objectGroup.transX or width
                    local objGTransY = objectGroup.transY or height
                    local objects = objectGroup.objects
        
                    local avgZ, avgZC = 0, 0
                    local zBuffer,zSorter, aBuffer,aSorter, aBC, zBC = {},{},{},{}, 0, 0
                    local unpackData, drawStringData, uC, dU = {},{}, 1, 1
                    local notIntersected = true
                    for m = 1, #objects do
                        local obj = objects[m]
                        if obj[12] == nil then
                            goto is_nil
                        end
        
                        local mx, my, mz, mw, mw1, mw2, mw3 = getModelMatrix(obj)
        
                        local objStyle = obj[11]
                        local vMX, vMY, vMZ, vMW =
                            mx * vw + mw * vx + my * vz - mz * vy,
                            my * vw + mw * vy + mz * vx - mx * vz,
                            mz * vw + mw * vz + mx * vy - my * vx,
                            mw * vw - mx * vx - my * vy - mz * vz
        
                        local vMXvMX, vMYvMY, vMZvMZ = vMX * vMX, vMY * vMY, vMZ * vMZ
        
                        local mXX, mXY, mXZ, mXW =
                            (1 - 2 * (vMYvMY + vMZvMZ)) * pxw,
                            2 * (vMX * vMY + vMZ * vMW) * pxw,
                            2 * (vMX * vMZ - vMY * vMW) * pxw,
                            (vw1 + vx1 * mw1 + vy1 * mw2 + vz1 * mw3) * pxw
        
                        local mYX, mYY, mYZ, mYW =
                            2 * (vMX * vMY - vMZ * vMW),
                            1 - 2 * (vMXvMX + vMZvMZ),
                            2 * (vMY * vMZ + vMX * vMW),
                            (vw2 + vx2 * mw1 + vy2 * mw2 + vz2 * mw3)
        
                        local mZX, mZY, mZZ, mZW =
                            2 * (vMX * vMZ + vMY * vMW) * pzw,
                            2 * (vMY * vMZ - vMX * vMW) * pzw,
                            (1 - 2 * (vMXvMX + vMYvMY)) * pzw,
                            (vw3 + vx3 * mw1 + vy3 * mw2 + vz3 * mw3) * pzw
        
                        avgZ = avgZ + mYW
                        avgZC = avgZC + 1
                        local P0XD, P0YD, P0ZD = lCX - mw1, lCY - mw2, lCZ - mw3
        
                        local customGroups, uiGroups = obj[4], obj[6]
                        for cG = 1, #customGroups do
                            local customGroup = customGroups[cG]
                            local multiGroups = customGroup[2]
                            local singleGroups = customGroup[3]
                            for mGC = 1, #multiGroups do
                                local multiGroup = multiGroups[mGC]
                                local pts = multiGroup[1]
                                local tPoints = {}
                                local ct = 1
                                local mGAvg = 0
                                for pC = 1, #pts do
                                    local p = pts[pC]
                                    local x, y, z = p[1], p[2], p[3]
                                    local pz = mYX * x + mYY * y + mYZ * z + mYW
                                    if pz < 0 then
                                        goto behindMG
                                    end
        
                                    tPoints[ct] = {
                                        (mXX * x + mXY * y + mXZ * z + mXW) / pz,
                                        (mZX * x + mZY * y + mZZ * z + mZW) / pz,
                                        pz
                                    }
                                    mGAvg = mGAvg + pz
                                    ct = ct + 1
                                    ::behindMG::
                                end
                                if ct ~= 1 then
                                    local drawFunction = multiGroup[2]
                                    local data = multiGroup[3]
                                    zBC = zBC + 1
                                    local depth = mGAvg/(ct-1)
                                    zSorter[zBC] = depth
                                    zBuffer[depth] = {
                                        depth,
                                        tPoints,
                                        data,
                                        drawFunction
                                    }
                                end
                            end
                            for sGC = 1, #singleGroups do
                                local singleGroup = singleGroups[sGC]
                                if not singleGroup[1] then goto behindSingle end
                                local x, y, z = singleGroup[2], singleGroup[3], singleGroup[4]
                                local pz = mYX * x + mYY * y + mYZ * z + mYW
                                if pz < 0 then
                                    goto behindSingle
                                end
        
                                local drawFunction = singleGroup[5]
                                local data = singleGroup[6]
                                zBC = zBC + 1
                                zSorter[zBC] = pz
                                zBuffer[pz] = {
                                    (mXX * x + mXY * y + mXZ * z + mXW) / pz,
                                    (mZX * x + mZY * y + mZZ * z + mZW) / pz,
                                    data,
                                    drawFunction,
                                    isCustomSingle = true
                                }
                                ::behindSingle::
                            end
                        end
                        for uiC = 1, #uiGroups do
                            local uiGroup = uiGroups[uiC]
        
                            local elements = uiGroup[2]
                            local modelElements = uiGroup[4]
        
                            for eC = 1, #modelElements do
                                local mod = modelElements[eC]
                                local mXO, mYO, mZO = mod[10], mod[11], mod[12]
        
                                local pointsInfo = mod[9]
                                local pointsX, pointsY, pointsZ = pointsInfo[1], pointsInfo[2], pointsInfo[3]
                                local tPointsX, tPointsY = {}, {}
                                local size = #pointsX
                                tPointsX[size] = false
                                tPointsY[size] = false
        
                                local xwAdd = mXX * mXO + mXY * mYO + mXZ * mZO + mXW
                                local ywAdd = mYX * mXO + mYY * mYO + mYZ * mZO + mYW
                                local zwAdd = mZX * mXO + mZY * mYO + mZZ * mZO + mZW
        
                                for index = 1, size do
                                    local x, y, z = pointsX[index], pointsY[index], pointsZ[index]
                                    local pz = mYX * x + mYY * y + mYZ * z + ywAdd
                                    if pz > 0 then
                                        tPointsX[index] = (mXX * x + mXY * y + mXZ * z + xwAdd) / pz
                                        tPointsY[index] = (mZX * x + mZY * y + mZZ * z + zwAdd) / pz
                                    end
                                end
        
                                local lX, lY, lZ = 0.26726, 0.80178, 0.53452
                                local ambience = 0.3
                                local planes = mod[13]
                                local planeNumber = #planes
                                zSorter[zBC + planeNumber] = false
                                for p = 1, planeNumber do
                                    local plane = planes[p]
                                    local eXO, eYO, eZO = plane[1] + mXO, plane[2] + mYO, plane[3] + mZO
                                    local eCZ = mYX * eXO + mYY * eYO + mYZ * eZO + mYW
                                    if eCZ < 0 then
                                        goto behindElement
                                    end
                                    local p0X, p0Y, p0Z = P0XD - eXO, P0YD - eYO, P0ZD - eZO
        
                                    local NX, NY, NZ = plane[4], plane[5], plane[6]
                                    local dotValue = p0X * NX + p0Y * NY + p0Z * NZ
        
                                    if dotValue < 0 then
                                        goto behindElement
                                    end
        
                                    local brightness = (lX * NX + lY * NY + lZ * NZ)
                                    if brightness < 0 then
                                        brightness = (brightness * 0.1) * (1 - ambience) + ambience
                                    else
                                        brightness = (brightness) * (1 - ambience) + ambience
                                    end
                                    local r, g, b = plane[8] * brightness, plane[9] * brightness, plane[10] * brightness
        
                                    local indices = plane[7]
                                    local data = {r, g, b}
                                    local m = 4
                                    local indexSize = #indices
                                    data[m + indexSize * 2 - 1] = false
        
                                    for i = 1, indexSize do
                                        local index = indices[i]
                                        local pntX = tPointsX[index]
                                        if not pntX then
                                            goto behindElement
                                        end
        
                                        data[m] = pntX
                                        data[m + 1] = tPointsY[index]
                                        m = m + 2
                                    end
                                    zBC = zBC + 1
                                    zSorter[zBC] = eCZ
                                    zBuffer[eCZ] = {
                                        plane[11],
                                        data,
                                        is3D = true
                                    }
        
                                    ::behindElement::
                                end
                            end
                            for eC = 1, #elements do
                                local el = elements[eC]
                                if not el[6] then
                                    goto behindElement
                                end
                                el[16].checkUpdate()
                                local eO = el[10]
                                local eXO, eYO, eZO = eO[1], eO[2], eO[3]
                                
                                local eCZ = mYX * eXO + mYY * eYO + mYZ * eZO + mYW
                                if eCZ < 0 then
                                    goto behindElement
                                end
                                
                                local eCX = mXX * eXO + mXY * eYO + mXZ * eZO + mXW
                                local eCY = mZX * eXO + mZY * eYO + mZZ * eZO + mZW
        
                                local actions = el[4]
                                local oRM = el[15]
                                local fw = -oRM[4]
                                local xxMult, xzMult, yxMult, yzMult, zxMult, zzMult
        
                                if fw ~= -1 then
                                    local fx, fy, fz = oRM[1], oRM[2], oRM[3]
                                    local rx, ry, rz, rw =
                                        fx * vMW + fw * vMX + fy * vMZ - fz * vMY,
                                        fy * vMW + fw * vMY + fz * vMX - fx * vMZ,
                                        fz * vMW + fw * vMZ + fx * vMY - fy * vMX,
                                        fw * vMW - fx * vMX - fy * vMY - fz * vMZ
        
                                    local rxrx, ryry, rzrz = rx * rx, ry * ry, rz * rz
                                    xxMult, xzMult = (1 - 2 * (ryry + rzrz)) * pxw, 2 * (rx * rz - ry * rw) * pxw
                                    yxMult, yzMult = 2 * (rx * ry - rz * rw), 2 * (ry * rz + rx * rw)
                                    zxMult, zzMult = 2 * (rx * rz + ry * rw) * pzw, (1 - 2 * (rxrx + ryry)) * pzw
                                else
                                    xxMult, xzMult = mXX, mXZ
                                    yxMult, yzMult = mYX, mYZ
                                    zxMult, zzMult = mZX, mZZ
                                end
        
                                zBC = zBC + 1
                                if el[14] and actions[7] then
                                    aBC = aBC + 1
                                    local p0X, p0Y, p0Z = P0XD - eXO, P0YD - eYO, P0ZD - eZO
        
                                    local NX, NY, NZ = el[11], el[12], el[13]
                                    local t = -(p0X * NX + p0Y * NY + p0Z * NZ) / (vx2 * NX + vy2 * NY + vz2 * NZ)
                                    local px, py, pz = p0X + t * vx2, p0Y + t * vy2, p0Z + t * vz2
        
                                    local oRM = el[15]
                                    local ox, oy, oz, ow = oRM[1], oRM[2], oRM[3], oRM[4]
                                    local oyoy = oy * oy
                                    zSorter[zBC] = eCZ
                                    zBuffer[eCZ] = {
                                        el,
                                        false,
                                        eCX,
                                        eCY,
                                        xxMult, 
                                        xzMult, 
                                        yxMult, 
                                        yzMult, 
                                        zxMult, 
                                        zzMult,
                                        isUI = true
                                    }
                                    aSorter[aBC] = eCZ
                                    aBuffer[eCZ] = {
                                        el,
                                        2 * ((0.5 - oyoy - oz * oz) * px + (ox * oy + oz * ow) * py + (ox * oz - oy * ow) * pz),
                                        2 * ((ox * oz + oy * ow) * px + (oy * oz - ox * ow) * py + (0.5 - ox * ox - oyoy) * pz),
                                        actions
                                    }
                                else
                                    zSorter[zBC] = eCZ
                                    zBuffer[eCZ] = {
                                        el,
                                        el[2],
                                        eCX,
                                        eCY,
                                        xxMult, 
                                        xzMult, 
                                        yxMult, 
                                        yzMult, 
                                        zxMult, 
                                        zzMult,
                                        isUI = true
                                    }
                                end
        
                                ::behindElement::
                            end
                        end
                        ::is_nil::
                    end
                    if aBC > 0 then
                        if hoveringOverUIElement then
                            hoveringOverUIElement = false
                        end
                        local newSelected = false
                        sort(aSorter)
                        for aC = 1, aBC do
                            local zDepth = aSorter[aC]
                            local uiElmt = aBuffer[zDepth]
        
                            local el = uiElmt[1]
        
                            local hoverDraw, defaultDraw, clickDraw = el[1], el[2], el[3]
                            local drawForm = defaultDraw
                            local actions = el[4]
        
                            if notIntersected then
                                local eBounds = el[14]
                                if eBounds and actions[7] then
                                    local pX, pZ = uiElmt[2], uiElmt[3]
                                    local inside = false
                                    if type(eBounds) == "function" then
                                        inside = eBounds(pX, pZ, zDepth)
                                    else
                                        local N = #eBounds + 1
                                        local p1 = eBounds[1]
                                        local p1x, p1y = p1[1], p1[2]
                                        local offset = 0
                                        for eb = 2, N do
                                            local mod = eb % N
                                            if mod == 0 then
                                                offset = 1
                                            end
                                            local p2 = eBounds[mod + offset]
                                            p1x, p1y = p1[1], p1[2]
                                            local p2x, p2y = p2[1], p2[2]
                                            local minY, maxY
                                            if p1y < p2y then
                                                minY, maxY = p1y, p2y
                                            else
                                                minY, maxY = p2y, p1y
                                            end
        
                                            if pZ > minY and pZ <= maxY then
                                                local maxX = p1x > p2x and p1x or p2x
                                                if pX <= maxX then
                                                    if p1y ~= p2y then
                                                        if p1x == p2x or pX <= (pZ - p1y) * (p2x - p1x) / (p2y - p1y) + p1x then
                                                            inside = not inside
                                                        end
                                                    end
                                                end
                                            end
                                            p1 = p2
                                        end
                                    end
                                    if not inside then
                                        goto broke
                                    end
                                    notIntersected = false
                                    drawForm = hoverDraw
                                    newSelected = uiElmt
                                    local eO = el[10]
                                    local identifier = actions[6]
                                    if oldSelected == false then
                                        local enter = actions[3]
                                        if enter then
                                            enter(identifier, pX, pZ)
                                        end
                                        --oldSelected = newSelected
                                    elseif newSelected[6] == oldSelected[6] then
                                        if isClicked then
                                            local clickAction = actions[1]
                                            if clickAction then
                                                clickAction(identifier, pX, pZ, eO[1], eO[2], eO[3])
                                                isClicked = false
                                            end
                                            drawForm = clickDraw
                                        elseif isHolding then
                                            local holdAction = actions[2]
                                            if holdAction then
                                                hovered = true
                                                holdAction(identifier, pX, pZ, eO[1], eO[2], eO[3])
                                            end
                                            drawForm = clickDraw
                                        else
                                            local hoverAction = actions[5]
                                            
                                            if hoverAction then
                                                hoveringOverUIElement = true
                                                hovered = true
                                                hoverAction(identifier, pX, pZ, eO[1], eO[2], eO[3])
                                            end
                                            drawForm = hoverDraw
                                        end
                                    else
                                        local enter = actions[3]
                                        if enter then
                                            enter(identifier, pX, pY)
                                        end
                                        local leave = oldSelected[4][4]
                                        if leave then
                                            leave(identifier, pX, pY)
                                        end
                                        
                                    end
                                    ::broke::
                                end
                            end
                            zBuffer[zDepth][2] = drawForm
                        end
                        if newSelected == false and oldSelected then
                            local leave = oldSelected[4][4]
                            if leave then
                                leave()
                            end
                            
                        end
                        oldSelected = newSelected
                    end
                    sort(zSorter)
                    for zC = zBC, 1,-1 do
                        local distance = zSorter[zC]
                        local uiElmt = zBuffer[distance]
                        if uiElmt.isUI then
                            local el = uiElmt[2]
                            local el,drawForm,xwAdd,zwAdd,xxMult,xzMult,yxMult,yzMult,zxMult,zzMult=unpack(uiElmt)
                            local ywAdd = distance
                            local count = 1
        
                            local scale = el[5] or 1
                            local drawOrder = el[7]
                            local drawData = el[8]
                            local points = el[9]
        
                            local oUC = uC
                            if drawData then
                                local sizes = drawData["sizes"]
                                if sizes then
                                    uC = uC + #sizes
                                end
                                uC = uC + #drawData
                            end
        
                            local broken = false
                            if not drawOrder then
                                for ePC = 1, #points, 2 do
                                    local ex, ez = points[ePC] * scale, points[ePC + 1] * scale
        
                                    local pz = yxMult * ex + yzMult * ez + ywAdd
                                    if pz < 0 then
                                        broken = true
                                        break
                                    end
        
                                    distance = distance + pz
                                    count = count + 1
        
                                    unpackData[uC] = (xxMult * ex + xzMult * ez + xwAdd) / pz
                                    unpackData[uC + 1] = (zxMult * ex + zzMult * ez + zwAdd) / pz
                                    uC = uC + 2
                                end
                            else
                                for ePC = 1, #points, 2 do
                                    local ex, ez = points[ePC] * scale, points[ePC + 1] * scale
        
                                    local pz = yxMult * ex + yzMult * ez + ywAdd
                                    if pz < 0 then
                                        broken = true
                                        break
                                    end
        
                                    distance = distance + pz
                                    count = count + 1
        
                                    local px = (xxMult * ex + xzMult * ez + xwAdd) / pz
                                    local py = (zxMult * ex + zzMult * ez + zwAdd) / pz
        
                                    local indexList = drawOrder[ePC] or {}
                                    for i = 1, #indexList do
                                        local index = indexList[i] + (uC - 1)
                                        unpackData[index] = px
                                        unpackData[index + 1] = py
                                    end
                                end
                            end
                            mUC = uC
                            uC = oUC
                            if not broken and drawForm then
                                local depthFactor = distance / count
                                if drawData then
                                    local drawDatCount = #drawData
                                    local sizes = drawData["sizes"]
                                    if sizes then
                                        for i = 1, #sizes do
                                            local size = sizes[i]
                                            local tSW = type(size)
                                            if tSW == "number" then
                                                unpackData[uC] = atan(size, depthFactor) * nearDivAspect
                                            elseif tSW == "function" then
                                                unpackData[uC] = size(depthFactor, nearDivAspect)
                                            end
                                            uC = uC + 1
                                        end
                                    end
                                    for dDC = 1, drawDatCount do
                                        unpackData[uC] = drawData[dDC]
                                        uC = uC + 1
                                    end
                                end
                                drawStringData[dU] = drawForm
                                dU = dU + 1
                                uC = mUC
                            end
                        elseif uiElmt.is3D then
                            local data = uiElmt[2]
                            for alm = 1, #data do
                                unpackData[uC] = data[alm]
                                uC = uC + 1
                            end
                            drawStringData[dU] = uiElmt[1]
                            dU = dU + 1
                        elseif uiElmt.isCustomSingle then
                            local x,y,data,drawFunction = uiElmt[1],uiElmt[2],uiElmt[3],uiElmt[4]
                            local unpackSize = #unpackData
                            drawStringData[dU] = drawFunction(x,y,distance,data,unpackData,uC) or '<text x=0 y=0>Error: N-CS</text>'
                            dU = dU + 1
                            local newUnpackSize = #unpackData
                            if unpackSize ~= newUnpackSize then
                                uC = newUnpackSize + 1
                            end
                        else
                            local points,data,drawFunction = uiElmt[1],uiElmt[2],uiElmt[3]
                            local unpackSize = #unpackData
                            drawStringData[dU] = drawFunction(points,data,unpackData,uC)
                            dU = dU + 1
                            local newUnpackSize = #unpackData
                            if unpackSize ~= newUnpackSize then
                                uC = newUnpackSize + 1
                            end
                        end
                    end
                    local svg = {
                        format(
                            '<svg viewbox="-%g -%g %g %g">',
                            objGTransX,
                            objGTransY,
                            width * 2,
                            height * 2
                        ),
                        format(
                            '<style> svg{width:%gpx;height:%gpx;position:absolute;top:0px;left:0px;} %s </style>',
                            width * 2,
                            height * 2,
                            objectGroup.style
                        ),
                        format(concat(drawStringData), unpack(unpackData)),
                        '</svg>'
                    }
                    if avgZC > 0 then
                        local dpth = avgZ / avgZC
                        svgBuffer[alpha] = {dpth, concat(svg)}
                        alpha = alpha + 1
                        if objectGroup.glow then
                            local size
                            if objectGroup.scale then
                                size = atan(objectGroup.gRad, dpth) * nearDivAspect
                            else
                                size = objectGroup.gRad
                            end
                            svg[1] =
                                format(
                                '<svg viewbox="-%g -%g %g %g" class="blur">',
                                objGTransX,
                                objGTransY,
                                width * 2,
                                height * 2
                            )
                            svg[2] =
                                [[
                                <style> 
                                    .blur {
                                        filter: blur(]] .. size .. [[px) 
                                                brightness(60%)
                                                saturate(3);
                                        ]] .. objectGroup.gStyle .. [[
                                    }
                                </style>]]
                            svgBuffer[alpha] = {dpth + 0.1, concat(svg)}
                            alpha = alpha + 1
                        end
                    end
                    ::not_enabled::
                end
                sort(svgBuffer, zSort)
                local svgBufferSize = #svgBuffer
                if svgBufferSize > 0 then
                    fc = fc - 1
                    for dm = 1, svgBufferSize do
                        fullSVG[fc + dm] = svgBuffer[dm][2]
                    end
                end
                return fullSVG, fc + svgBufferSize + 1
            end
            return self
        end


    --Startup stuff would go here, called at end of normal startup
    local sqrt, len, max, print = math.sqrt, string.len, math.max, system.print

    local highPerformanceMode = false --export: Disables glow effect which can improve FPS significantly in some cases.
    local glowRadius = 5 --export: Setting the pixel size of the glow effect.
    local loadWaypoints = true --export: Enable to load waypoints from Archaegeo's HUD's DB.
    local displayWarpCells = true --export: To display warp cells or not.
    local archHudWaypointSize = 0.01 --export: The size in meters of an ArchHud waypoint
    local archHudWPRender = 400 --export: The size in kilometers at which point ArchHud Waypoints do not render.
    local maxWaypointSize = 800 --export: The Max Size of a waypoint in pixels.
    local minWaypointSize = 15 --export: The min size of a waypoint in pixels.
    local infoHighlight = 200 --export: The number of pixels within info is displayed.
    local fontsize = 20 --export: font size
    local colorWarp = "#ADD8E6" --export: Colour of warpable waypoints
    local nonWarp = "#FFA500" --export: Colour of non-warpable waypoints

    waypoint = false
    local waypointInfo = {
    {name = "Madis", center = {17465536,22665536,-34464}, radius=44300},
    {name = "Alioth", center = {-8,-8,-126303}, radius=126068},
    {name = "Thades", center = {29165536,10865536,65536}, radius=49000},
    {name = "Talemai", center = {-13234464,55765536,465536}, radius=57450},
    {name = "Feli", center = {-43534464,22565536,-48934464}, radius=60000},
    {name = "Sicari", center = {52765536,27165538,52065535}, radius=51100},
    {name = "Sinnen", center = {58665538,29665535,58165535}, radius=54950},
    {name = "Teoma", center = {80865538,54665536,-934463.94}, radius=62000},
    {name = "Jago", center = {-94134462,12765534,-3634464}, radius=61590},
    {name = "Lacobus", center = {98865536,-13534464,-934461.99}, radius=55650},
    {name = "Symeon", center = {14165536,-85634465,-934464.3}, radius=49050},
    {name = "Symeon", center = {14165536,-85634465,-934464.3}, radius=49050},
    {name = "Ion", center = {2865536.7,-99034464,-934462.02}, radius=44950}
    }

    local function bTW(bool)
        if bool then
            return "enabled"
        else
            return "disabled"
        end
    end

    print("=======================")
    print("DU AR Waypoint System")
    print("=======================")
    print("Concept: Archaegeo")
    print("Coder  : EasternGamer")
    print("=======================")
    print("Settings")
    print("=======================")
    print("Freelook        : " .. bTW(freelook))
    print("Disp. Warp Cells: " .. bTW(displayWarpCells))
    print("Load saved WP   : " .. bTW(loadWaypoints))
    print("Font Size       : " .. fontsize .. "px")
    print("Max WP Render   : " .. archHudWPRender .. "km")
    print("Max WP Size     : " .. maxWaypointSize .. "px")
    print("Min WP Size     : " .. minWaypointSize .. "px")
    print("ArchHUD WP Size : " .. archHudWaypointSize .. "m")
    print("Info HL Distance: " .. infoHighlight .. "px")
    print("=======================")

    if loadWaypoints then
        if databank ~= nil then
            local getString = databank.getStringValue
            if getString ~= nil then
                local dbInfo = json.decode(getString("SavedLocations"))
                if dbInfo ~= nil then
                    local size = #waypointInfo
                    local dbInfoSize = #dbInfo
                    local c = 0
                    print("Found " .. dbInfoSize .. " waypoints in databank.")
                    for i=1, #dbInfo do
                        local dbEntry = dbInfo[i]
                        local pos=dbEntry.position
                        waypointInfo[size+c+1] = {name=dbEntry.name, center={pos.x, pos.y, pos.z}, radius=archHudWaypointSize}
                        c=c+1
                    end
                    print("Loaded " .. c .. " waypoints.")
                else
                    print('ERROR! No data to read.')
                end
            else
                print('ERROR! Incorrect slot used for databank.')
            end
        else
            print("ERROR! No slot connected to databank slot.")
        end
    end

    local position = {0,0,0}
    local offsetPos = {0,0,0}
    local orientation = {0,0,0}
    local width = system.getScreenWidth() / 2
    local height = system.getScreenHeight() / 2
    local objectBuilder = ObjectBuilderLinear()

    camera = Camera(CameraTypes.player)

    --camera.setViewLock(not freelook)
    projector = Projector(camera)

    waypoints = {}

    local waypointObjectGroup = ObjectGroup()
    projector.addObjectGroup(waypointObjectGroup)

    local css = [[
    svg { 
        stroke-width: 3; 
        vertical-align:middle; 
        text-anchor:start; 
        fill: white; 
        font-family: Refrigerator; 
        font-size: ]] .. fontsize .. [[;
    }]]

    waypointObjectGroup.setStyle(css)
    if not highPerformanceMode then
        waypointObjectGroup.setGlow(true, glowRadius)
    end
    local function drawText(content,x, y, text, opacity,uD,c,c2,stroke)
        uD[c],uD[c+1],uD[c+2],uD[c+3],uD[c+4],uD[c+5] = x,y,opacity,opacity,stroke,text
        content[c2] = '<text x="%g" y="%g" fill-opacity="%g" stroke-opacity="%g" stroke="%s">%s</text>'
        return c+6,c2+1
    end
    local function drawHorizontalLine(content,x, y, length, thickness,dU,c,c2,stroke)
        dU[c],dU[c+1],dU[c+2],dU[c+3],dU[c+4]=thickness,stroke,x,y,length
        content[c2] = '<path fill="none" stroke-width="%g" stroke="%s" d="M%g %gh%g"/>'
        return c+5,c2+1
    end
    local maxD = sqrt(width*width + height*height)
    local function drawInfo(content,tx, ty, data,dU,c,c1,stroke,distanceToMouse)
        local font = fontsize
        local name,distance,warpCost,disKM,disM = data.getWaypointInfo()
        local keyframe = data.keyframe
        
        c,c1 = drawHorizontalLine(content, tx, ty + 3, len(name)*(font*0.6), 2,dU,c,c1,stroke)
        c,c1 = drawText(content, tx, ty, name, 1,dU,c,c1,stroke)
        
        if distanceToMouse <= infoHighlight then
            if keyframe < 6 then
                data.keyframe = keyframe + 1
            end
        else
            if keyframe ~= 0 then
                data.keyframe = keyframe - 1
            end
        end
        local opacity = keyframe/6
        if distanceToMouse < 25 and waypoint then
            system.setWaypoint('::pos{0,0,' .. data.x ..',' .. data.y .. ',' .. data.z ..'}')
            waypoint = false
        end
        if keyframe > 0 then
            local disText = ''
            if disM <=1000 then
                disText = disM .. ' M'
            elseif disKM <= 200 then
                disText = disKM .. ' KM'
            else
                disText = distance .. ' SU'
            end
            c,c1 = drawText(content, tx + 60 - keyframe*10, ty+font+5, disText, opacity,dU,c,c1,stroke)
            if displayWarpCells then
                c,c1 = drawText(content, tx + 60 - keyframe*10, ty+(font+5)*2, warpCost .. ' Warp Cells', opacity,dU,c,c1,stroke)
            end
        end
        --system.print(table.concat(content))
    end
    local concat = table.concat
    local function draw(tx,ty,tz,data,dU,c)
        local content,c1 = {},1
        local distanceToMouse = sqrt(tx*tx + ty*ty)
        local r = data.radius
        local off = (((tz/1000)/200))/100
        local size = max(projector.getSize(r, tz, 100000000, minWaypointSize) - off, 5)
        if size >= maxWaypointSize or distanceToMouse > maxD or (r==archHudWaypointSize*1.25 and tz>archHudWPRender*1000) then -- Don't display
            return ''
        end
        local stroke = colorWarp
        local _,distance = data.getWaypointInfo()
        if distance > 500 then
            stroke = nonWarp
        end
        content[c1] = '<circle cx="%g" cy="%g" r="%g" fill="%s" stroke="%s"/>'
        dU[c],dU[c+1] = tx,ty
        c=c+2
        if r==archHudWaypointSize*1.25 then
            size = size /2
            dU[c] = size
            dU[c+1] = colorWarp
        else
            dU[c] = size
            dU[c+1] = 'none'
        end
        dU[c+2] = stroke
        c=c+3
        drawInfo(content, tx + size + 5, ty - size + 5, data,dU,c,c1+1,stroke,distanceToMouse)
        return concat(content)
    end
    local solarWaypoints = objectBuilder
                    .setStyle('test')
                    .setPosition({0,0,0})
                    .setOffset({0,0,0})
                    .setOrientation({0,0,0})
                    .setPositionType(positionTypes.globalP)
                    .setOrientationType(orientationTypes.globalO)
                    .build()
    waypointObjectGroup.addObject(solarWaypoints)
    local builder = solarWaypoints.setCustomSVGs(1, 'Test')
    for ii = 1, #waypointInfo do
        local wDat = waypointInfo[ii]
        local wCenter = wDat.center
        local wName = wDat.name
        local wRadius = wDat.radius
        
        local waypointObject = Waypoint(wCenter[1],wCenter[2],wCenter[3], wRadius * 1.25, wName, subId)
        local customSVG = builder.addSinglePointSVG()
        waypoints[ii] = {wCenter, waypoint}
        customSVG.setPosition({wCenter[1], wCenter[2], wCenter[3]})
                .setData(waypointObject)
                .setDrawFunction(draw)
                .build()
    end

    unit.setTimer("update", hudTickRate) -- The timer to update the screen
end

function userOnFlush(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1)
    --Flush code goes here, called at end of normal flush - Remember only flight physics stuff should go in OnFlush.
end

function userOnUpdate(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1)
    -- Update code goes here, called at end of normal update. - Remember onUpdate executes 60 times per second or your FPS rate, whichever is lower.
end

function userOnStop(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1)
    -- on Stop code goes here, called at end of normal onStop
end

function userControlStart(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, action)
    -- Control start event, called when a user key is pressed, action is the key. - This will NOT override but will support addition action for a key.
end

function userControlLoop(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, action)
    -- Control start event, called when a user key is held down, action is the key - This will NOT override but will support addition action for a key
end

function userControlStop(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, action)
    -- Control stop event, called when a user key is released, action is the key - This will NOT override but will support addition action for a key
end

function userControlInput(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, text)
    -- Control Input event, called when user types in lua chat, text is the typed input
end

function userRadarEnter(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, id)
    -- Called if active radar gets an OnEnter event (something detected), id is the passed detection
end

function userRadarLeave(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, id)
    -- Called if active radar gets an OnLeave event (something detected), id is the passed detection
end

function userOnTick(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, timerId)
    -- Called when a tick that has been set up (unit.setTimer("tickName", ticktime)) fires, timerId is the tick name
    -- example:  if timerId == "myTickName" then do things end
    if timerId == "update" then
        local svg, index = projector.getSVG()
        userScreen = table.concat(svg)
    end
end

