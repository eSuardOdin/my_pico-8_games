pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--my shmup
--by esuard
function _init()
	makeship()
	make_foes()
end

function _update()
	moveship()
	fire()
	fly_blt()
	rmv_blt()
	
	rmv_foes()
	add_foes()
	update_foes()
end

function _draw()
	cls(0)
	drawship()
	draw_blt()
	show_heat()
	
	draw_foes()
end

-->8
--functions

--init the ship
function makeship()
ship={
x=60,
y=110,
sx=0,
sy=0,
sp=2,--sprite
blt={},
heat=0,
overheat=false
}
end

--draws ship
function drawship()
	spr(ship.sp,ship.x,ship.y)
end

--handles ships ctrl
function moveship()
	ship.sp=2
	
	--diag=2*0.707
	ship.sx=0
	ship.sy=0
	--if diagonal
	--[[if(btn(0)and btn(2))then
		ship.sx-=diag
		ship.sy-=diag
		ship.sp=1
	elseif(btn(0)and btn(3))then
		ship.sx-=diag
		ship.sy+=diag
		ship.sp=1
	elseif(btn(1) and btn(2))then
		ship.sx+=diag
		ship.sy-=diag
		ship.sp=3
	elseif(btn(1)and btn(3))then
		ship.sx+=diag
		ship.sy+=diag
		ship.sp=3]]
	--if mono direction
	if(btn(0))then
		ship.sx-=2
		ship.sp=1
	end
	if(btn(1))then 
		ship.sx+=2
		ship.sp=3
	end
	if(btn(2))then
		ship.sy-=2
	end
	if(btn(3))then
		ship.sy+=2
	end
	
	--change pos
	ship.x+=ship.sx
	ship.y+=ship.sy
	
	--lock screen
	if(ship.x<0)ship.x=0
	if(ship.x>120)ship.x=120
	if(ship.y<0)ship.y=0
	if(ship.y>120)ship.y=120
end

--handle fire logic
function fire()
	if(ship.heat<10)then
		if(btnp(5)and ship.overheat==false) then
			blt={}
			blt.x=ship.x
			blt.y=ship.y+3
			sfx(0)
			add(ship.blt,blt)
			ship.heat+=2
			if(ship.heat==10)then ship.overheat=true end
		end
	end
end

--handle bullet mvmt
function fly_blt()
	if(#ship.blt!=0) then
		for b in all(ship.blt)do
			b.y-=4
		end
	end
end

--remove bullets from array
function rmv_blt()
	if(#ship.blt!=0) then
		for b in all(ship.blt)do
			--remove offscreen blt
			if(b.y<-8)then
				del(ship.blt,b)
				ship.heat-=2
				--remove overheat status
				if(ship.overheat and #ship.blt==0)then
					ship.overheat=false
				end
			end
		end
	end
end

--draw bullets
function draw_blt()
	if(#ship.blt!=0) then
		for b in all(ship.blt)do
			spr(16, b.x, b.y)
		end
	end
end

--show heat bar
function show_heat()
	rect(99,2,111,5,9)
	if(not ship.overheat)then
		lenght=100+ship.heat
		rectfill(100,3,100+ship.heat,4,8)
	else
		rectfill(100,3,110,4,8)
	end
	if(ship.overheat)then
		print("overheat!",89,10,8)
	end
end
	
-->8
--enemy functions
function make_foes()
	foes={}
end

--add enemy
function add_foes()
	if(#foes<10)then
		foe={
			x=8+rnd(110),
			y=-10-rnd(120),
			spd=1+rnd(3),
			sprite=11,
		}
		add(foes,foe)
	end
end

--update enemies
function update_foes()
	if(#foes>0)then
		for e in all(foes) do
			e.y+=e.spd
			if(e.sprite==14)then
				e.sprite=11
			else
				e.sprite+=1
			end
		end
	end
end

--remove enemies
function rmv_foes()
	if(#foes>0)then
		for e in all(foes) do
			if(e.y>136)then 
				del(foes,e)
			end
		end
	end
end

--draw enemies
function draw_foes()
	if(#foes>0)then
		for e in all(foes) do
			spr(e.sprite,e.x,e.y)
		end
	end
end
__gfx__
00000000003b3000003bb3000003b3000000000000000000000000000000000000000000000000000000000000000000000000000007700000077000005aa500
0000000000bbb30003bbbb30003bbb00000000000000000000000000000000000000000000000000000000000000000000077000007777000077770008855880
0070070003dddb303bddd5b303bddd30000000000000000000000000000000000000000000000000000000000077770000677600006776000067760002876820
000770000377db303bd775b303bd7730000000000000000000000000000000000000000000000000000000000067760000677600006776000066660002855820
000770000376db303bd765b303bd763000000000000000000000000000000000000000000000000000000000066666600c6666c00066660000c66c0002855820
007007000355db303bd555b303bd5530000000000000000000000000000000000000000000000000000000000cc66cc00cc66cc000c66c0000cccc0000288200
000000000005b00000b55b00000b5000000000000000000000000000000000000000000000000000000000000cccccc000cccc0000cccc00000cc00000288200
000000000009900000099000000990000000000000000000000000000000000000000000000000000000000000cccc00000cc000000cc000000cc00000288200
00999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
099aa990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99aaaa99000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aa77aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aa77aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99aaaa99000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
099aa990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003b550365502c55024550205501c55018550135500f5500c5500a550085500655005550045500455006550075500a5500d550105500f05000050000500000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00170020070500705007050070500c0500c0500c0500c0500d0500d0500d0500d0500c0500c0500c0500c050070500705007050070500c0500c0500c0500c0500d0500d0500d0500d0500c0500c0500c0500c050
__music__
00 03434344

