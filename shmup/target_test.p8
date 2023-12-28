pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
	make_entities()
end

function _update()
	mv_player()
	update_foe()
	update_bullets()
end

function _draw()
	cls(6)
	draw_entities()
	draw_bullets()
end

-->8
function make_entities()
	foe={
	 x=61,
	 y=61,
	 sprite=2,
	 rate=30,
	 bullet={
	 	
	 }
	}
	player={
		x=105,
		y=105,
		sx=0,
		sy=0,
		sprite=1
		}
end

function draw_entities()
	spr(foe.sprite,
	 foe.x,
	 foe.y)
	spr(player.sprite,
	 player.x,
	 player.y)
	 
	print(player.x,1,1,8)
	print(player.y,1,8,8)
	print(atan2(player.x,
	            player.y),
	            1,16,8)
end

function mv_player()
	if(btn(0))then
		player.sx-=2
	end
	if(btn(1))then 
		player.sx+=2
	end
	if(btn(2))then
		player.sy-=2
	end
	if(btn(3))then
		player.sy+=2
	end
	player.x+=player.sx
	player.y+=player.sy
	player.sx=0
	player.sy=0
end

function update_foe()
	if(foe.rate==0)then
		fire()
		foe.rate=30
	else
		foe.rate-=1
	end
end

function fire()
	dirx=player.x-foe.x
	diry=player.y-foe.y
	b={
		x=foe.x,
		y=foe.y,
		spd=4,
		--these are to change 
		--depending on player pos
		ang=atan2(dirx,diry),
	}
	add(foe.bullet,b)
end

function update_bullets()
	if(#foe.bullet!=0)then
		for b in all(foe.bullet)do
			b.x+=cos(b.ang)*b.spd
			b.y+=sin(b.ang)*b.spd
			if(b.x<-8or b.x>136or
				b.y<-8or b.y>136)then
				del(foe.bullet,b)
			end
		end
	end
end

function draw_bullets()
	if(#foe.bullet!=0)then
		for b in all(foe.bullet)do
			spr(3,b.x,b.y)
		end
	end
end
__gfx__
00000000cccccccc8888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccc8888888800055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700cccccccc8888888800533500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000cccccccc88888888053bb350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000cccccccc88888888053bb350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700cccccccc8888888800533500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccc8888888800055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccc8888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
