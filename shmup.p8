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
	manageship()
	fire()
	fly_blt()
	rmv_blt()
	
	rmv_foes()
	add_foes()
	update_foes()
	
	check_foe_collision()
end

function _draw()
	cls(0)
	drawship()
	fire_flash()
	draw_blt()
	show_heat()
	show_life()
	
	draw_foes()
end

-->8
--functions

--init the ship
function makeship()
light=0
ship={
x=60,
y=110,
sx=0,
sy=0,
sp=2,--sprite
blt={},
heat=0,
overheat=false,
life=3,
hbox={
	x1=1,
	x2=6,
	y1=0,
	y2=7
 },
inv=0
}
end

--draws ship
function drawship()
 if(ship.inv>0and ship.inv%3==0)then
 	
 else
		spr(ship.sp,ship.x,ship.y)
	end
end

--handles ships ctrl
function manageship()
 if(ship.inv>0)then
  ship.inv-=1
 end
	ship.sp=2
	
	--diag=2*0.707
	ship.sx=0
	ship.sy=0
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
			light=6
		 if(ship.heat==10)then 
		 	ship.overheat=true 
		 end
		end		
	end
end

--fire animate
function fire_flash()
if(light>0)then
			circfill(ship.x+3,ship.y-5,light,7)
			light-=1
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
	rect(106,10,118,13,9)
	if(not ship.overheat)then
		rectfill(107,11,107+ship.heat,12,8)
	else
		rectfill(107,11,117,12,8)
	end
	if(ship.overheat)then
		print("overheat!",89,17,8)
	end
	print(ship.inv,89,26,8)
end

--show life
function show_life()
	n=ship.life
	for i=1, 3do
		if(ship.life>=i)then
		 spr(4,90+(9*i),1)
		else
			spr(5,90+(9*i),1)
		end
	end
end
	
-->8
--enemy functions
function make_foes()
	foes={}
end

--add enemy
function add_foes()
	if(#foes<10)then --there to f nb
		foe={
			x=8+rnd(110),
			y=-10-rnd(120),
			spd=1+rnd(3),
			sprite=11,
			hbox={
				x1=1,
				x2=6,
				y1=1,
				y2=7
			}
		}
		add(foes,foe)
	end
end

--update enemies
function update_foes()
	if(#foes>0)then
		for e in all(foes) do
			e.y+=e.spd
			if(e.sprite==13)then
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
-->8
--helper functions
function collision(s,e)
	if(s.hbox.y1+s.y<=e.hbox.y2+e.y
	 and s.hbox.y2+s.y>=e.hbox.y1+e.y
	 and s.hbox.x1+s.x<=e.hbox.x2+e.x
	 and s.hbox.x2+s.x>=e.hbox.x1+e.x)then
  return true
 else
  return false
 end
end

function check_foe_collision()
	for e in all(foes) do
			if(collision(ship,e)
			and ship.inv==0)then
				ship.life-=1
				ship.inv=60
			end
		end
end
	 
__gfx__
00000000003b3000003bb3000003b300000000000000000000000000000000000000000000000000000000000000000000000000000cc000000cc000005aa500
0000000000bbb30003bbbb30003bbb000aa0099005500550000000000000000000000000000000000000000000000000000cc00000cccc0000cccc0008855880
0070070003dddb303bddd5b303bddd30a999999950055005000000000000000000000000000000000000000000cccc00006cc600006cc600006cc60002876820
000770000377db303bd775b303bd7730a9999999500000050000000000000000000000000000000000000000006cc600006cc600006cc6000066660002855820
000770000376db303bd765b303bd7630a99999995000000500000000000000000000000000000000000000000666666007666670006666000076670002855820
007007000355db303bd555b303bd55300a9999900500005000000000000000000000000000000000000000000776677007766770007667000077770000288200
000000000005b00000b55b00000b500000a999000050050000000000000000000000000000000000000000000777777000777700007777000007700000288200
00000000000990000009900000099000000990000005500000000000000000000000000000000000000000000077770000077000000770000007700000288200
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

