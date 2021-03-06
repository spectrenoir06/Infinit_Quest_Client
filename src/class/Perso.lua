local class = require 'lib.kikito.middleclass'

local Entity = require "class.Entity"
local Sprite = require "lib.spectre.Sprite"

local Perso = class('Perso',Entity) 

Perso.static.LX = 64
Perso.static.LY = 64

function Perso:initialize(x, y, spriteFile, map)

    Entity.initialize(self, x, y, Perso.LX, Perso.LY, map)

    self.sprite 	 = Sprite:new(spriteFile,self.lx,self.ly)
    self.vie 		   = 100
	
	  self.sprite:addAnimation({9,10,11})
    self.sprite:addAnimation({0,1,2})
    self.sprite:addAnimation({3,4,5})
    self.sprite:addAnimation({6,7,8})

    self.speed 	    = 4 * resolution
    self.direction  = 1
    self.dx 		    = 0
    self.dy 		    = 0

end

function Perso:update(dt)
	Entity.update(self)
  self.sprite:update(dt)
	
	local grid = resolution/4
	
	if self.dx~=0 or self.dy ~=0 then 										     -- si mouvement
		self.sprite:play()
		if self.dx~=0 and (self.Y1 % (grid))~=0 then 						 -- si mouvement sur X mais Y pas sur le grid
			--print(self.y % grid /grid)
			if ((self.Y1 % (grid)/grid)<=0.5) then 							   -- realignement en -y
				if (((self.Y1 - dt*self.speed)%grid)/grid)>0.5 then
					self:setY1(math.floor(self.Y1/grid)*grid)
				else
					self:setY1(self.Y1 -(dt*self.speed))
				end
			else
				if (((self.Y1 +(dt*self.speed))%grid)<0.5) then 			-- realignement en +y
					self:setY1(math.ceil(self.Y1/grid)*grid)
				else
					self:setY1(self.Y1 +(dt*self.speed))
				end
			end
		elseif self.dy~=0 and (self.X1 % (grid))~=0 then 					-- si mouvement sur Y mais X pas sur le grid
			--print(self.X1 % grid /grid)
			if ((self.X1 % (grid)/grid)<=0.5) then
				if (((self.X1 - dt*self.speed)%grid)/grid)>0.5 then 		-- realignement en -x
					self:setX1(math.floor(self.X1/grid)*grid)
				else
					self:setX1(self.X1 -(dt*self.speed))
				end
			else
				if (((self.X1 +(dt*self.speed))%grid)<0.5) then 			-- realignement en +y
					self:setX1(math.ceil(self.X1/grid)*grid)
				else
					self:setX1(self.X1 +(dt*self.speed))
				end
			end
		elseif not self:colision(dt) then 					             -- si aligner sur l'axe perpendiculaire au mouvement ( si +x alors y%grid = 0 ) et pas de colision
			self:setX1( self.X1 +(dt*self.dx*self.speed) )         -- mouvement sur X
			self:setY1( self.Y1 +(dt*self.dy*self.speed) ) 	       -- mouvement sur Y
			--self.sprite:play()
		else
			if self.dx<0 then
				self:setX1(math.ceil((self.X1 +(dt*self.dx*self.speed))/resolution)*resolution) 	-- si colision en -x position arrondie au tile a gauche
			elseif self.dx>0 then
				self:setX1(math.floor((self.X1 +(dt*self.dx*self.speed))/resolution)*resolution) 	-- si colision en + position arrondie au tile e droite 
			end
			if self.dy<0 then
				self:setY1(math.ceil((self.Y1 +(dt*self.dy*self.speed))/resolution)*resolution) 	-- si colision en -y position arrondie au tile au dessus
				-- print(math.ceil(self.y +(dt*self.dy*self.speed)/64))
			elseif self.dy>0 then
				self:setY1(math.floor((self.Y1 +(dt*self.dy*self.speed))/resolution)*resolution) 	-- si colision en +y position arrondie au tile au dessous
			end
			--print("stop")
		end
	else
		self.sprite:stop()
    end

	self.dy = 0
	self.dx = 0
	
	if (self.x < 0) or (self.x>self.map.map.LX*resolution) then -- si Perso sort de la map local
	--	print("------------------")
	--	print("globalPosX = "..self.globalPosX)
	--	print("globalPosY = "..self.globalPosY)
	--	print(""                )
	--	print("scan map:")
		for k,v in ipairs(data.map) do
		--	print("map "..k)
		--	print(" X = "..v.X)
			--print(" Y = "..v.Y)
			--print(" lx = "..v.map.lx)
			--print(" ly = "..v.map.ly)
			if (v.X<(self.globalPosX/resolution)) and (v.Y<(self.globalPosX/resolution)) then
				if ((self.globalPosX-v.X*resolution) < v.map.lx*resolution) and ((self.globalPosY-v.Y*resolution) < v.map.ly*resolution) then
					--print("------------------")
					--print("= goto map "..k)
					--print("------------------")
					self.map = data.map[k]
					self:setPosX(self.globalPosX - v.X * resolution)
					self:setPosY(self.globalPosY - v.Y * resolution)
					self.mapnb = k
					if localgame.multi then
					  print("send changemap()",k)
					  localgame:changeMap()
					end
					break
				end
			end
		end
	end
	
end

-------------------------------------------------------------------------------------------------------------------------------
function Perso:draw()
    self.sprite:draw(math.floor(self.x-32),math.floor(self.y-32)) 
end

function Perso:getvie()
    return self.vie
end

function Perso:changevie(dx)
    self.vie  = self.vie + dx
end

function Perso:setvie(x)
    self.vie  = x
end

function Perso:colision(dt) -- return true si Perso en colision au coordoner
	return self:scancol(math.floor((self.X1+dt*self.dx*self.speed)/resolution),math.floor((self.Y1+dt*self.dy*self.speed)/resolution))
		or self:scancol(math.floor(((self.X2+dt*self.dx*self.speed)-1)/resolution),math.floor((self.Y1+dt*self.dy*self.speed)/resolution))
		or self:scancol(math.floor((self.X1+dt*self.dx*self.speed)/resolution),math.floor(((self.Y2+dt*self.dy*self.speed)-1)/resolution))
		or self:scancol(math.floor(((self.X2+dt*self.dx*self.speed)-1)/resolution),math.floor(((self.Y2+dt*self.dy*self.speed)-1)/resolution))
				
				
		-- if self:scancol(math.floor((self.X1+dt*self.dx*self.speed)/resolution),math.floor((self.Y1+dt*self.dy*self.speed)/resolution)) then
			-- print("x1,y1=true")
			-- return true
		-- end
		-- if self:scancol(math.floor(((self.X2+dt*self.dx*self.speed)-1)/resolution),math.floor((self.Y1+dt*self.dy*self.speed)/resolution)) then
			-- print("x2,y1=true")
			-- return true
			
		-- end
		-- if self:scancol(math.floor((self.X1+dt*self.dx*self.speed)/resolution),math.floor(((self.Y2+dt*self.dy*self.speed)-1)/resolution)) then
			-- print("x1,y2=true")
			-- return true
		-- end
		-- if self:scancol(math.floor(((self.X2+dt*self.dx*self.speed)-1)/resolution),math.floor(((self.Y2+dt*self.dy*self.speed)-1)/resolution)) then
			-- print("x2,y2=true")
			-- print("X2="..self.X2/64 .."   Y2="..self.Y2/64)
			-- print(math.floor((self.X2+dt*self.dx*self.speed)/resolution),math.floor((self.Y2+dt*self.dy*self.speed)/resolution))
			-- return true
		-- end
end

function Perso:scancol(tilex,tiley) -- return true si colision
	local block = self.map:getblock(tilex,tiley)
		--print(idsol,idblock)
	local blockDataSol   = data.tab[block.idsol]
	local blockDataBlock = data.tab[block.idblock]
	if block.idblock==nil or block.idsol==nil then
		return false
	else
		return not blockDataSol.pass or not blockDataBlock.pass or block.pnj
	end
end

function Perso:setdirection(direction)
    self.direction=direction
    self.sprite:setAnim(direction)
end

function Perso:getdirection()
    return self.direction
end


function Perso:getblock(tileX,tileY)

    local idSol, idBlock, idDeco = self.map:gettile(tileX,tileY)
    local pnj = self.map:getPnj(tileX,tileY)
    local obj = self.map:getObj(tileX,tileY)
    
    return      { pnj   = pnj,
                  idSol = idSol,
                  idBlock = idBlock,
                  idDeco = idDeco,
                  obj = obj,
                  pnj = pnj,
                  tileX=tileX,
                  tileY=tileY
                }
end


function Perso:use()
	local posX , posY , X1 , Y1 , X2 ,Y2 = self:getPos()
	local x,y = 0,0
	
	if self:getdirection()==1 then
		x,y = math.floor(X1/resolution) , math.floor(Y1/resolution)-1
    elseif	self:getdirection()==2 then
		x,y = math.floor(X1/resolution),math.floor(Y1/resolution)+1
	elseif self:getdirection()==3 then
		x,y = math.floor(X1/resolution)-1,math.floor(Y1/resolution)
	elseif self:getdirection()==4 then
		x,y = math.floor(X1/resolution)+1,math.floor(Y1/resolution)
	end
	
	local block = self:getblock(x,y)
	
    if data.tab[block.idblock].use then
		data.tab[block.idblock].use(block.tileX,block.tiley)
	elseif data.tab[block.idsol].use then
		data.tab[block.idsol].use(block.tileX,block.tiley)
    elseif block.pnj then
		if block.pnj.data.talk then
			block.pnj.data.talk()
		end
	end
	
	--if blockdata.use then
                -- blockdata.use(x,y)
            -- elseif pnj then
                -- if pnj.data.talk then
                    -- pnj.data.talk()
                -- end
	
    -- local main = data.tab[self:getslot()]
    -- if main.type == "block" then
        -- if idblock==0 and not pnj then
            --self:place()
        -- else
            -- if blockdata.use then
                -- blockdata.use(x,y)
            -- elseif pnj then
                -- if pnj.data.talk then
                    -- pnj.data.talk()
                -- end
            -- end
        -- end
    -- elseif main.type == "item" then
        -- if blockdata.use then
                -- blockdata.use(x,y)
        -- elseif main.use then
            -- main.use(x,y)
        -- end
    -- end 
end

function Perso:isOn()
    local block = self:getblock(math.floor(self:getX()/resolution),math.floor(self:getY()/resolution))
    if block.idblock  == nil then
        error("Id non valide")
    else
        blockdata = data.tab[idblock]
        if data.tab[block.idsol].isOn then
            data.tab[block.idsol].isOn(block.tilex,block.tiley)
        elseif block.obj then
            if block.obj.data.isOn then
                block.obj.data.isOn()
            end
        end
    end
end

-----------------------------------

function Perso:setslot(nb)
    self.slot=nb
end

function Perso:getnbslot()
    return self.slot
end


function Perso:getslot(slot)
    if slot== nil then
        return self.inv["slot"..self.slot]["id"] , self.inv["slot"..self.slot]["nb"]
    else
        return self.inv["slot"..slot]["id"] , self.inv["slot"..slot]["nb"]
    end
end

function Perso:getslotid(slot)
    return self.inv["slot"..slot]["id"]
end

function Perso:getslotnb(slot)
    return self.inv["slot"..slot]["nb"]
end

function Perso:additem(id,nb)
    fini=false
    for i=1,9 do
        Sid , Snb = self:getslot(i)
        if Sid == id then
            self.inv["slot"..i]["nb"]=Snb+nb
            fini=true
            break
        end
    end
    if fini==false then
       for i=1,9 do
            Sid , Snb = self:getslot(i)
            if Sid==0 then
                self.inv["slot"..i]["id"]=id
                self.inv["slot"..i]["nb"]=nb
                break
            end
        end
    end
end

function Perso:removeitem(slot,nb)
    self.inv["slot"..slot]["nb"]=self.inv["slot"..slot]["nb"]-nb
    if self.inv["slot"..slot]["nb"]<=0 then
        self.inv["slot"..slot]["id"]=0
        self.inv["slot"..slot]["nb"]=1
    end
end

--[[function Perso:drawinv(x,y,img)
    love.graphics.print("V",x+(self.slot-1)*32+15,y-15)
    love.graphics.draw(img, x-4, y-4)
    for i=0,8 do
        if self:getslotid(i+1)~= 0 then
            inventaire:draw(x+i*32,y,self:getslotid(i+1))
            love.graphics.print(self:getslotnb(i+1),x+i*32,y+15)
        end
        --love.graphics.rectangle("line", x+i*32,y,32,32)
    end
end]]

function Perso:dig()
    idsol,idblock,x,y = self:getblock()
    if idblock then
        blockData = data.tab[idblock]
        if blockData.dig then
            blockData.dig(x,y)
        end
    end
end

function Perso:place()
    idsol,idblock,x,y = self:getblock()
    if idblock == 0 then
        if self:getslot()~=0 then
            self.map:settile(x,y,self:getslot(),2)
            self:removeitem(self.slot,1)
            return true
        else
            return false
        end
    end
end

function Perso:scanMap()
	

end

function Perso:GoUp()
	self:setdirection(1)
    self.dy = -1
    self.dx = 0
end

function Perso:GoDown()
	self:setdirection(2)
    self.dy = 1
    self.dx = 0
end

function Perso:GoLeft()
	self:setdirection(3)
  self.dy = 0
  self.dx = -1
end

function Perso:GoRight()
	self:setdirection(4)
    self.dy = 0
    self.dx = 1
end

return Perso