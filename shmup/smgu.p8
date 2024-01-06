pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--shoot my game up
--by esuard

function _init()
	_upd = upd_menu
	_drw = drw_menu
	
	set_menu()
end

function _update()
	_upd()
end

function _draw()
	_drw()
end
-->8
--update functions

function upd_menu()
	--title animation--
	if t_y<50 then
		t_y+=1
	end
	if t_blink<8 then
		t_blink+=1
	else
		t_blink=0
	end
	
	--launching game--
	if btnp(❎)then
		_upd=upd_game
		_drw=drw_game
		set_menu() --reset
		set_game()
	end
end

--update game--
function upd_game()
	upd_player()
	upd_stage()
	upd_enemies()
	upd_hits()
	upd_stars()
end

--update player state and actions--
function upd_player()
	
	--if player dead
	if p_pv==0 then
		_upd=upd_over
	end
	
	--handle invicibility
	if(p_inv>0)then
  p_inv-=1
 end
 
 --reset sprite and speed
 p_sprite=2
 p_sx=0
 p_sy=0
 
 --handle move
 if(btn(⬅️))then
		p_sx-=2
		p_sprite=1
	end
	if(btn(➡️))then 
		p_sx+=2
		p_sprite=3
	end
	if(btn(⬆️))then
		p_sy-=2
	end
	if(btn(⬇️))then
		p_sy+=2
	end
	
	--change pos
	p_x+=p_sx
	p_y+=p_sy
	
	--lock screen
	if(p_x<0)p_x=0
	if(p_x>120)p_x=120
	if(p_y<0)p_y=0
	if(p_y>120)p_y=120
	
	--reload
	if(p_load<wpn.rate)then
		p_load+=1
	end
	
	--firing logic
	if(btnp(❎)and
	p_load==wpn.rate and
(wpn.mun!=0or wpn.mun==-1)) then
		blt={
			x=p_x,
			y=p_y+3,
			last_y=p_y+3,
			dmg=wpn.dmg,
			hbox={
			x1=1,
			x2=7,
			y1=1,
			y2=7
			}
		}
		sfx(0)
		add(p_blt,blt)
		if(wpn.mun!=-1)then
			wpn.mun-=1
		end
		p_flash=6
		p_load=0
	end
	
	--move bullets
	if(#p_blt!=0) then
		for b in all(p_blt)do
			b.last_y=b.y
			b.y-=wpn.spd
		end
	end
	
	--remove offscreen bullets
	if#p_blt!=0then
		for b in all(p_blt)do
			if(b.y<-8)then
				del(p_blt,b)
			end
		end
	end
	
	--handle touching bullets
	if#e_table!=0and#p_blt!=0 then
		for e in all(e_table)do
		for b in all(p_blt)do
			
			if collide(e,b) then
				--add hit--
				_hit={
					x=b.x+4,
					y=b.y+4,
					cross=8, --flash impact
					prt={}
				}
				add(hits,_hit)
				e.pv-=b.dmg
				if(e.pv==0)then
					del(e_table,e)
				end
				del(p_blt,b)
			end
		end
		end
	end
end

--update hits--
function upd_hits()
	if#hits!=0then
		for _h in all(hits)do
			if(_h.cross!=0)then
				_h.cross-=4
			else
				del(hits,_h)														
			end
		end
	end
end

--update stage--
function upd_stage()
	if time_left==0then
		stage+=1
		--time_left=90
		time_left=3600
	else
		time_left-=1
	end
	if stage==5then
		_upd=upd_over
	end
end

--update enemies--
function upd_enemies()
	local e_nb
	if (stage==0)then
	 e_nb=3
	elseif(stage==1)then
	 e_nb=4
	elseif(stage==2)then
	 e_nb=5
	elseif(stage==3)then
		e_nb=6
	else 
		e_nb=8
	end

	--adding enemies	
	for i=#e_table, e_nb do
		add(e_table,spawn_e())
	end
	--moving enemies
	if(#e_table!=0)then
		for e in all(e_table)do
			e.y+=e.spd
			--deleting oob enemies
			if e.y > 134 then
				del(e_table,e)
			end
		end
	end
end

--return new enemy--
function spawn_e()
	
	local e_type=flr(rnd(3))
	local i_rate
	local i_spd
	local i_sprite
	local i_pv
	_e = {
		x=8+rnd(110),
		y=-10-rnd(120),
		hbox={
				x1=1,
				x2=7,
				y1=1,
				y2=7
			},
		rate=0,
		init_rate=0,
		spd=0,
		sprite=0,
		pv=0,
	}
	if(e_type==0)then--rookie
		i_rate=150
		i_spd=0.5
		i_sprite=47
		i_pv=2
	elseif(e_type==1)then--med
		i_rate=120
		i_spd=0.8
		i_sprite=31
		i_pv=1
	elseif(e_type==2)then--med+
		i_rate=105
		i_spd=1
		i_sprite=15
		i_pv=3
--	else	--hard
	end
	
	--all enemies--
	
	_e.rate=i_rate
	_e.init_rate=i_rate
	_e.spd=i_spd
	_e.sprite=i_sprite
	_e.pv=i_pv
	--todo : atk as a pointer to function
	return _e
end

--update stars--
function upd_stars()
	if#stars<150then
		gen_stars(true)
	end
	if#stars!=0then
	--move or del
		for st in all(stars)do
			st.y+=st.spd
			if(st.y>129)then
				del(stars,st)
			end
		end
	end
end




--update game over--
function upd_over()
	_drw=drw_over
	if btnp(❎)then
		_upd=upd_menu
		_drw=drw_menu
	end
end
-->8
--draw functions

--drawn main menu--
function drw_menu()
	cls(0)
	cprint("shoot my game up",
	t_y,7)
	if t_y==50 and t_blink<5 then
		cprint("press ❎ to get started",
	t_y+10,7)
	end	
end

--draw game--
function drw_game()
	cls(0)
	--print(#e_table,64,64,7)
	drw_stars()
	drw_player()
	drw_gui()
	drw_enemies()
	drw_hits()
end

--drawing player
function drw_player()
	--show player
	if not(p_inv>0and p_inv%3==0)then
		spr(p_sprite,p_x,p_y)
	end
	--show flash
	if p_flash>0 then
		circfill(p_x+3,p_y-5,p_flash,7)
		p_flash-=1
	end
	--show bullets
	if#p_blt!=0then
		for b in all(p_blt)do
		 --stop()
			spr(16, b.x, b.y)
		end
	end
end

--draw hits--
function drw_hits()
	if#hits!=0then
		for _h in all(hits)do
			rectfill(_h.x-_h.cross,
													_h.y,
													_h.x+_h.cross,
													_h.y,7)
			rectfill(_h.x,
													_h.y-_h.cross,
													_h.x,
													_h.y+_h.cross,7)
		end
	end
end

--drawing gui
function drw_gui()
	--life
	for i=1, 3do
		if(p_pv>=i)then
		 spr(4,90+(9*i),1)
		else
			spr(5,90+(9*i),1)
		end
	end
	
	--loadbar
	local pct = (p_load*10)/wpn.rate
	rect(106,10,118,13,9)
	rectfill(107,11,107+pct,12,8)
	
	--munitions
	if(wpn.mun!=-1)then
		print(wpn.mun.."/"..wpn.i_mun,
		106,15,9)
	end
	--stage
	print("stage "..stage,2,2,7)
 print(flr(time_left/30),60,2,7)	
	--score
	print("score:"..p_score,2,10,9)
end


--draw enemies--
function drw_enemies()
	if(#e_table!=0)then
		--local _n = 0
		for e in all(e_table)do
			spr(e.sprite,e.x,e.y)
			--print(e.x.." "..e.y,64,64+_n)
			--_n+=8
			--drw_hb(e)
		end
	end
end


--draw stars--
function drw_stars()
	if(#stars!=0)then
		for st in all(stars)do
			circ(st.x,st.y,0,st.col)
		end
	end
end

--draw gameover--
function drw_over()
	cls(2)
	
end
-->8
--init functions
function set_menu()
	t_y=-16
	t_blink=0
end

function set_game()
--global--
	stage=0
	stars={}
	hits={}
	while#stars<80do
		gen_stars(false)
	end
	--time_left=90--120sec *30 frames
 time_left=3600
--player variables--
	p_x=60
	p_sx=0
	p_y=110
	p_sy=0
	p_sprite=2
	p_pv=3
	p_inv=0
	p_load=0
	p_hbox={
		x1=1,
		x2=6,
		y1=0,
		y2=7
	 }
	p_blt={}
	p_flash=0
	p_score=0
	
--weapon--
	wpn={
		rate=20,
		spd=4,
		dmg=1,
		sp=16,
		mun=-1,
		i_mun=-1,
		}
	
--enemy variables--
	e_table={}
	e_blt={}
	
--debug pointer to func--
	_drw_dbg=nil
end
-->8
--helper functions

--print to center--
function cprint(_t,_y,c)
	print(_t,64-#_t*2,_y,c)
end

--check if 2 hitboxes collide--
function collide(a,b)
	if(a.hbox.y1+a.y<=b.hbox.y2+b.y
	 and a.hbox.y2+a.y>=b.hbox.y1+b.y
	 and a.hbox.x1+a.x<=b.hbox.x2+b.x
	 and a.hbox.x2+a.x>=b.hbox.x1+b.x)then
  return true
 else
  return false
 end
end

function drw_hb(e)
	rect(e.x,
	e.y,
	e.hbox.x2+e.x,
	e.hbox.y2+e.y,12)
end

function print_dbg(txt)
	print(txt,15,115,15)
end

function gen_stars(out)
	local _type = rnd(10)
	if out then
		_y=0-rnd(128)
	else
		_y=rnd(128)
	end
	_s=
	{
		y=_y,
		x=rnd(128),
		spd=0,
		col=0,
	}
	if _type>5then
		_spd=2
		_col=7
	elseif _type>3then
		_spd=0.6
		_col=1
	else
		_spd=0.3
		_col=5
	end
	_s.spd=_spd
	_s.col=_col
	add(stars,_s)
end
__gfx__
00000000003b3000003bb3000003b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888
0000000000bbb30003bbbb30003bbb000aa009900550055000000000000000000000000000000000000000000000000000000000000000000000000088088088
0070070003dddb303bddd5b303bddd30a99999995005500500000000000000000000000000000000000000000000000000000000000000000000000088888888
000770000377db303bd775b303bd7730a99999995000000500000000000000000000000000000000000000000000000000000000000000000000000088888888
000770000376db303bd765b303bd7630a99999995000000500000000000000000000000000000000000000000000000000000000000000000000000088888888
007007000355db303bd555b303bd55300a9999900500005000000000000000000000000000000000000000000000000000000000000000000000000088888888
000000000005b00000b55b00000b500000a999000050050000000000000000000000000000000000000000000000000000000000000000000000000088888888
00000000000990000009900000099000000990000005500000000000000000000000000000000000000000000000000000000000000000000000000088888888
00999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222
099aa990000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022022022
99aaaa99002332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222
9aa77aa9023bb3200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222
9aa77aa9023bb3200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222
99aaaa99002332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222
099aa990000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222
00999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
000000000000000000077000007aa70000a99a000090090000000000000000000000000000000000000000000000000000000000000000000000000033033033
0000000000777000007aa70007a99a700a9009a00900009000000000000000000000000000000000000000000000000000000000000000000000000033333333
00077000007aa70007a99a700a9009a0090000900000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
0000000000077700007aa70007a99a700a9009a00900009000000000000000000000000000000000000000000000000000000000000000000000000033333333
000000000000000000077000007aa70000a99a000090090000000000000000000000000000000000000000000000000000000000000000000000000033333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
__map__
0000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000037550325502a550245501e5501955014550115500e5500b550095500755005550045500455003550025500255002550025500355005550075500e5500f55000000000000000000000000000000000000
