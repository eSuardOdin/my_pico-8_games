pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--shoot my game up
--by esuard
function _init()
	make_bg()
	make_ship()
	make_wpn()
	make_foes()
	
	menu()
end

function _update()
	if(state=="game")then
		update_stars()
		manage_ship()
		fire()
		fly_blt()
		rmv_blt()
		
		rmv_foes()
		add_foes()
		update_foes()
		update_blts()
		
		check_foe_collision()
	
	elseif(state=="gameover")then
	
	else
		update_menu()
	end
end

function _draw()
	if(state=="game")then
		cls(1)
		draw_stars()
		draw_ship()
		fire_flash()
		draw_blt()
		animate_hits()
		
		draw_status()
		
		draw_foes()
	elseif(state=="menu")then
		cls(5)
		draw_menu()	
	end
end

-->8
--init functions

--init the ship
function make_ship()
score=0
--garbage variables for animation
light=0
hits={}
ship={
	--pos
	x=60,
	y=110,
	sx=0,
	sy=0,
	--hitbox life n invicibility
	hbox={
		x1=1,
		x2=6,
		y1=0,
		y2=7
	 },
	 life=3,
	 inv=0,
	--sprite
	sp=2,
	--blt
	blt={},
	--load status
	ld=0
}
end

--create base wpn with
--base stats
function make_wpn()
	wpn={
		rate=20,
		spd=4,
		dmg=1,--useless now
		sp=16,
		}
end


function make_foes()
	foes={}
	blts={}
end

--draws ship
function draw_ship()
 if(ship.inv>0and ship.inv%3==0)then
 	
 else
		spr(ship.sp,ship.x,ship.y)
	end
end

--fire animate
function fire_flash()
if(light>0)then
			circfill(ship.x+3,ship.y-5,light,7)
			light-=1
	end
end

	

--menu init updt and draw
function menu()
	title="shoot my game up"
	title_pos=0
	flick=0
	state="menu"
end

function update_menu()
	if(title_pos!=52)then
		title_pos+=2
	end
	if(flick==10)then
		flick=0
	else
		flick+=1
	end
	
	if(btn(❎))then
		state="game"
	end
end

function draw_menu()
	cprint("shoot my game up",
						title_pos,8)
	if(flick<8and title_pos==52)then
		cprint("push x button",
						title_pos+8,7)
	end	
--	print("push x button",
--	40,64,7)

end
-->8
--update functions

	
--handles ships ctrl
function manage_ship()

	if(ship.life==0)then
		state="gameover"
	end
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
	--reload
	if(ship.ld<wpn.rate)then
		ship.ld+=1
	end
	--fire
	if(btnp(5)and
	ship.ld==wpn.rate) then
		blt={
			x=ship.x,
			y=ship.y+3,
			hbox={
			x1=1,
			x2=7,
			y1=1,
			y2=7
			}
		}
		sfx(0)
		add(ship.blt,blt)
		light=6
		ship.ld=0
	end
end


--add enemy
function add_foes()
	if(#foes<3)then--there to f nb
		foe={
			x=8+rnd(110),
			y=-10-rnd(120),
			spd=1+rnd(0.8),
			sprite=15,
			r=50,
			init_r=0,
			hbox={
				x1=1,
				x2=7,
				y1=1,
				y2=7
			}
		}
		foe.init_r=foe.r
		add(foes,foe)
	end
end

--update enemies
function update_foes()
	if(#foes>0)then
		for e in all(foes) do
			e.y+=e.spd
			if(e.r<=0)then 
				--fire logic
				nx=ship.x-e.x
				ny=ship.y-e.y
				b={
				 x=e.x+4,
				 y=e.y+4,
				 v=1.5,
				 ang=atan2(nx,ny),
				 hbox={
							x1=1,
							x2=7,
							y1=1,
							y2=7
						},
					sp=17,
				}
				add(blts,b)
				e.r=e.init_r
			else
			--stop()
				e.r-=1 --load shoot
			end
		end
	end
end


--update bullets loc
function update_blts()
	if(#foes!=0)then
		for f in all(foes)do
			if(#blts!=0)then
				for b in all(blts)do
					if(b.x<-8or b.x>136
						  or b.y<-8 or b.y>136)
					then
					 del(blts,b)
					else
					 b.x+=cos(b.ang)*b.v
					 b.y+=sin(b.ang)*b.v
					end
				end
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

--updt star pos
function update_stars()
	for s in all(bg)do
		s.y+=0.8
		if(s.y>128)then del(bg,s)end
	end
	for i=#bg,20do
		add(bg,gen_star(true))
	end
end

--handle bullet mvmt
function fly_blt()
	if(#ship.blt!=0) then
		for b in all(ship.blt)do
			b.y-=wpn.spd
		end
	end
end


--add an hit to animate
function add_hit(xpos,ypos)
	hit={
		x=xpos,
		y=ypos,
		state=0
		}
		add(hits,hit)
end

--remove bullets from array
--and foes if hit
function rmv_blt()
	if(#ship.blt!=0) then
		for b in all(ship.blt)do
			--remove offscreen blt
			if(b.y<-8)then
				del(ship.blt,b)
			end
			
			--check hit collision
			for e in all(foes)do
				if(collision(b,e))then
				 sfx(1)
					add_hit(b.x+4,b.y)
					del(ship.blt,b)
					del(foes,e)
					--add score
					score+=25
				end
			end
		end
	end
end

--detect collision
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
	if(#foes!=0)then
		for e in all(foes) do
			if(collision(ship,e)
			and ship.inv==0)then
				ship.life-=1
				ship.inv=60
			end
		end
	end
--bullet col
	if(#blts!=0)then
		for b in all(blts)do
			if(collision(ship,b)
				and ship.inv==0)then
						ship.life-=1
						ship.inv=60
			end
		end
	end
end
-->8
--draw functions



--animate all hits
function animate_hits()
 --stop()
	if(#hits!=0)then
		for h in all(hits)do
			if(h.state==6)then
				del(hits,h)
			else
				spr(32+h.state,h.x,h.y)
				h.state+=1
			end
		end
	end
end

--generate a star	 
function gen_star(outside)
	st={}
	if(not outside)then
		st.x=rnd(127)
		st.y=rnd(127)
	else
		st.x=rnd(127)
		st.y=0-rnd(127)
	end
	return st
end

--create background
function make_bg()
	bg={}
	for a=1,20do
		add(bg,gen_star(false))
	end
end



function draw_stars()
	for s in all(bg)do
		circfill(s.x,s.y,0,7)
	end
end

--draw enemies
function draw_foes()
	if(#foes>0)then
		for e in all(foes) do
			spr(e.sprite,e.x,e.y)
			if(#blts!=0)then
				for b in all(blts)do
					spr(b.sp,b.x,b.y)
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

--show life
function draw_status()
	--life
	n=ship.life
	for i=1, 3do
		if(ship.life>=i)then
		 spr(4,90+(9*i),1)
		else
			spr(5,90+(9*i),1)
		end
	end
	
	--loadbar
	local pct = (ship.ld*10)/wpn.rate
	rect(106,10,118,13,9)
	rectfill(107,11,107+pct,12,8)
	
	--score
	print("score:"..score,2,2,9)
end



-->8
--helper functions
function cprint(t,y,c)
	x=64-(#t*2)
	print(t,x,y,c)
end
__gfx__
00000000003b3000003bb3000003b300000000000000000000000000000000000000000000000000000000000000000000000000000cc000000cc000005aa500
0000000000bbb30003bbbb30003bbb000aa0099005500550000000000000000000000000000000000000000000000000000cc00000cccc0000cccc0028855882
0070070003dddb303bddd5b303bddd30a999999950055005000000000000000000000000000000000000000000cccc00006cc600006cc600006cc60028876882
000770000377db303bd775b303bd7730a9999999500000050000000000000000000000000000000000000000006cc600006cc600006cc6000066660028855882
000770000376db303bd765b303bd7630a99999995000000500000000000000000000000000000000000000000666666007666670006666000076670028855882
007007000355db303bd555b303bd55300a9999900500005000000000000000000000000000000000000000000776677007766770007667000077770002888820
000000000005b00000b55b00000b500000a999000050050000000000000000000000000000000000000000000777777000777700007777000007700002888820
00000000000990000009900000099000000990000005500000000000000000000000000000000000000000000077770000077000000770000007700000288200
00999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
099aa990000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99aaaa99002332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aa77aa9023bb3200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aa77aa9023bb3200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99aaaa99002332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
099aa990000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000077000007aa70000a99a000090090000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000777000007aa70007a99a700a9009a00900009000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007aa70007a99a700a9009a0090000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000077700007aa70007a99a700a9009a00900009000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000077000007aa70000a99a000090090000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888777777888eeeeee888eeeeee888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88778877788ee888ee88ee888ee88888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8777787778eeeee8ee8eeeee8ee88888e88888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8777787778eee888ee8eeee88ee8888eee8888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee8777787778eee8eeee8eeeee8ee88888e88888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
888eee888ee8777888778eee888ee8eee888ee888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8777777778eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
111111111616166611111ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161611161777111c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616661111111c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111616111777111c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616661111111c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111177111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111117711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111117111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111177117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161116661666166611111ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116111161161116111777111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111611116116611661111111cc111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116111161161116111777111c117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616661611166611111ccc171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116661661161611111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111611616161617771c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111611616161611111c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111611616166617771c1c1171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116661616116111111ccc1711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111dd1ddd1ddd1ddd1ddd1ddd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d111d1d1d1d11d111d11d1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ddd1ddd1ddd1ddd1dd111d111d11dd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111d1d111d1d11d111d11d1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111dd11d111d1d1ddd11d11ddd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111166166611111ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111161116161777111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666166611111ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111116161117771c11117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111661161111111ccc171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111ddd1d111ddd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1d1111d111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ddd1ddd1dd11d1111d111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1d1111d111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111ddd1ddd11d111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666161116661111117717711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616161111611777117111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111661161111611111177111771111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616161111611777117111711171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666166611611111117717711711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1111dd1ddd1dd1111111dd1ddd1ddd1ddd1d1d11dd111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d111d1d1d1d1d1d11111d1111d11d1d11d11d1d1d11111111111111111111111111111111111111111111111111111111111111111111111111
11111ddd1ddd1d111d1d1ddd1d1d11111ddd11d11ddd11d11d1d1ddd111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d111d1d1d1d1d1d1111111d11d11d1d11d11d1d111d111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111ddd1dd11d1d1ddd11111dd111d11d1d11d111dd1dd1111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111611166111111ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111611161617771c1c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111611161611111c1c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111611161617771c1c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666166611111ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
17711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11771111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11711111111111111111111111111111111111111111111111111111111111111111111171111111111111111111111111111111111111111111111111111111
17711111111111111111111111111111111111111111111111111111111111111111111177111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111177711111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111177771111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111177111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111711111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111dd1ddd1ddd1ddd1ddd1ddd11111ddd1ddd11dd1ddd11111d1d1ddd1dd111111d1d1ddd1ddd1d1d1111111111111111111111111111111111111111
111111111d111d1d1d111d1d11d11d1111111d1d1d1d1d111d1111111d1d1d1d1d1d11111d1d11d111d11d1d1111111111111111111111111111111111111111
1ddd1ddd1d111dd11dd11ddd11d11dd111111dd11ddd1ddd1dd111111d1d1ddd1d1d11111d1d11d111d11ddd1111111111111111111111111111111111111111
111111111d111d1d1d111d1d11d11d1111111d1d1d1d111d1d1111111ddd1d111d1d11111ddd11d111d11d1d1111111111111111111111111111111111111111
1111111111dd1d1d1ddd1d1d11d11ddd11111ddd1d1d1dd11ddd11111ddd1d111d1d11111ddd1ddd11d11d1d1111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ddd1ddd11dd1ddd111111dd1ddd1ddd1ddd11dd11111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111d1d1d1d1d111d1111111d1111d11d1d11d11d1111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ddd1ddd1dd11ddd1ddd1dd111111ddd11d11ddd11d11ddd11111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111d1d1d1d111d1d111111111d11d11d1d11d1111d11111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ddd1d1d1dd11ddd11111dd111d11d1d11d11dd111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116661666161616661111161616661661117111711111111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116661616161616111111161616161616171111171111111111111111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116161666166116611111161616661616171111171111111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616111111166616111616171111171111111111111111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116161616161616661666166616111616117111711111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616166616611111117711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616161616161777117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616166616161111177111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666161116161777117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666161116161111117711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616661666166611111ccc1ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116161616116116111777111c1c1c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166116661161166111111ccc1c1c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616161161161117771c111c1c11711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616161161166611111ccc1ccc17111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116611666116611111cc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616661611177711c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616161611111111c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161616161616177711c11171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116661616166611111ccc1711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822282228882822882228222888888888888888888888888888888888888888888888222828882228882822282288222822288866688
82888828828282888888888282888828882888828882888888888888888888888888888888888888888888888882828882828828828288288282888288888888
82888828828282288888882282228828882888828222888888888888888888888888888888888888888888888882822282228828822288288222822288822288
82888828828282888888888288828828882888828288888888888888888888888888888888888888888888888882828288828828828288288882828888888888
82228222828282228888822282228288822288828222888888888888888888888888888888888888888888888882822288828288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__map__
0000000000000000000000003800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003b550365502c55024550205501c55018550135500f5500c5500a550085500655005550045500455006550075500a5500d550105500f05000050000500000000000000000000000000000000000000000
000100000165002650076500b6501065012650186501c650206502f65022600143001630017300183001b30000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00170020070500705007050070500c0500c0500c0500c0500d0500d0500d0500d0500c0500c0500c0500c050070500705007050070500c0500c0500c0500c0500d0500d0500d0500d0500c0500c0500c0500c050
__music__
00 03434344

