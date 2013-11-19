clients = {}
clients.__index = clients

function clients_new()
	local a = {}
	setmetatable(a, clients)
	a.tab_perso = {}
	a.main_client=1
	a.sync = 0
	a.sync_dt=0.2
	return a
end

function clients:add(data)
	local nb = table.getn(data)
	print(nb)
	--print(json.encode(data))
	table.insert(self.tab_perso,perso_new("/textures/"..resolution.."/skin"..data[nb].skin ..".png",resolution,resolution))
end

function clients:set_main_client(nb)
	self.main_client = nb
end

function clients:receive(data,msg)
	--print("receive : port="..port.." ; cmd="..json.decode(data).cmd)
	local tab = json.decode(data)
	if tab.cmd == "new_player" then
		self:add(tab.data)
	elseif tab.cmd == "update" then
		
	end

end

function clients:draw()
	for k,v in pairs(self.tab_perso) do
		v:draw() 				-- afficher perso
	end
end

function clients:update(dt)
	if self.sync > self.sync_dt then
		print("send")
		local send = {	cmd = "pos_update",
						map = self:main():getmapnb(),
						data = { posX=self:main().posX,
								 posY=self:main().posY,
								 dir=self:main().direction}
					 }
		udp:send(json.encode(send))
		self.sync = 0
	end
	for k,v in pairs(self.tab_perso) do
		v:update(dt) -- update perso
	end
	self.sync = self.sync +dt
end

function clients:main()
	return self.tab_perso[self.main_client]
end