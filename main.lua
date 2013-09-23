   	require "/fonction/json"
	require "/fonction/map"
    require "/fonction/sprite"
    require "/fonction/perso"
    require "/fonction/dispinfo"  
    require "/fonction/Button" 
    require "/fonction/camera"
    require "/fonction/data"  
    require "/map/mapinfo"
    require "/fonction/Itemsprite"  
    require "/fonction/datapnj"
    require "/fonction/dataobj"
    require "/fonction/pnj"
    gamestate = require "/lib/hump/gamestate"
	game = {}
	pause = {}
	main_menu = {}
  
function love.load()
	
	gamestate.registerEvents()
	gamestate.switch(game)
end

-- function love.update(dt)
      -- Timer.update(dt)
-- end

function game:init()
	--G_port = "4321"
	--G_host = "192.168.10.8"
	--require "/android/android"

    if love.keyboard.isDown( "up" ) and love.keyboard.isDown( "down" ) then
        mobile=true
    end
    resolution = 64
    icone=( love.graphics.newImage( "icone.png" ) )
    love.graphics.setIcon(icone)
    loadmaps()
    --love.graphics.setMode( 16*resolution, 9*resolution)
    info=true
    up,down,left,right=0,0,0,0
    move=false
    cursor_x=0
    cursor_y=0
    
    
    steve = perso_new("/textures/"..resolution.."/sprite.png",resolution,resolution) --,data.map[1]["map"])
    
    if mobile then
        scale=1
    elseif resolution == 64 then
        love.graphics.setMode( 20*resolution, 11.25*resolution)
        scale=1
    elseif resolution== 32 then
        love.graphics.setMode( 25*resolution, 15*resolution,false, true, 0 )
        scale=1.25
    elseif resolution== 40 then
        love.graphics.setMode( 20*resolution, 12*resolution,false, true, 0 )
        scale=1
    end
        
        
    steve.sprite:addAnimation({9,10,11})
    steve.sprite:addAnimation({0,1,2})
    steve.sprite:addAnimation({3,4,5})
    steve.sprite:addAnimation({6,7,8})
    
    
    
    inventaire = invsprite_new("/textures/"..resolution.."/tileset.png",resolution,resolution)
    map = steve:getmap()
    
    cache = love.graphics.newImage("/textures/"..resolution.."/cache.png")
    
    --love.audio.play(steve.map.music)
    invent = inv_new(5.375*resolution,10*resolution,"/textures/"..resolution.."/inv.png")
    --touchemobil = button_new(432*(resolution/32),16*(resolution/32),"/textures/mobil"..resolution..".png")
    A_key = button_new(16*resolution,9*resolution,"/textures/"..resolution.."/A.png")
    keypad = keypad_new(0.30*resolution,8*resolution,"/textures/"..resolution.."/key.png")
    touche=0
    mouse_x=0
    mouse_y=0
    click=0
   
end


---------


function game:draw()
    love.graphics.setIcon(icone)
    love.graphics.scale(scale,scale)
    steve:getmap():draw(0,0)
    steve:draw()
	steve:getmap():drawdeco(0,0)
	
	camera:setPosition(steve:getX()-9*resolution, steve:getY()-5.5*resolution)
    if camera.x<0 then
        camera.x = 0
    elseif camera.x>steve:getmap():getLX()*resolution-(20*resolution) then
        camera.x = steve:getmap():getLX()*resolution-(20*resolution)
    end
    if camera.y<0 then
        camera.y = 0
    elseif camera.y>steve:getmap():getLY()*resolution-(11.25*resolution) then
        camera.y = steve:getmap():getLY()*resolution-(11.25*resolution)
    end
	
    if info then
        dispinfo(640,0)
    end
    --invent:draw(steve)
    --touchemobil:draw()
    if mobile then
        A_key:draw()
        keypad:draw()
    end
end

function game:update(dt)
    --map = steve:getmap()
    steve:update(dt)
    click = love.mouse.isDown( "l" )
 
    if invent:get(love.mouse.getX( )/scale,love.mouse.getY( )/scale,click) then
        steve:setslot(invent:get(love.mouse.getX( )/scale,love.mouse.getY( )/scale,click))
    end   
    if mobile then
        --if touchemobil:isPress(love.mouse.getX( )*scale,love.mouse.getY( )*scale,click) then
        --    mobile=false
        --    love.timer.sleep( 0.5 )
        --end
        touche = keypad:get(love.mouse.getX( )/scale,love.mouse.getY( )/scale,click)
        if touche==1 or not love.keyboard.isDown( "up" ) then
            up=1
        else
            up=0
        end
        if touche == 2 or not love.keyboard.isDown( "down" ) then
            down=1
        else
            down=0
        end
        if touche==3 or not love.keyboard.isDown( "left" ) then
            left=1
        else
            left=0
        end
        if touche==4 or not love.keyboard.isDown( "right" ) then
            right=1
        else
            right=0
        end
        if A_key:isPress(love.mouse.getX( )/scale,love.mouse.getY( )/scale,click) then
            key_a=1
        else
            key_a=0
        end
    else
        --if touchemobil:isPress(love.mouse.getX( )*scale,love.mouse.getY( )*scale,click) then
         --   mobile=true
         --   love.timer.sleep( 0.5 )
       -- end
        if love.keyboard.isDown( "up" ) then
            up=1
        else
            up=0
        end
        if love.keyboard.isDown( "down" ) then
            down=1
        else
            down=0
        end
        if love.keyboard.isDown( "left" ) then
            left=1
        else
            left=0
        end
        if love.keyboard.isDown( "right" ) then
            right=1
        else
            right=0
        end
        if love.keyboard.isDown( " " ) then
            key_a=1
        else
            key_a=0
        end
    end 
end


function game:mousepressed(x, y, button)
    cursor_x=(x+camera.x)--/scale
    cursor_y=(y+camera.y)--/scale
end
    
function game:keypressed(key)
    if key == "kp+" then
        if steve:getnbslot()<9 then
            steve:setslot(steve:getnbslot()+1)
        end
    elseif key == "kp-" then
        if steve:getnbslot()>1 then
            steve:setslot(steve:getnbslot()-1)
        end
    elseif key == "i" then
        if info then
            info=false
        else
            info=true
        end
	elseif key == "p" then
		gamestate.push(pause)
    end
end