function onCreate()
    -- 1. 맨 뒤 배경 (ForestWall)
    makeLuaSprite('wall', 'BGforest/ForestWall', -600, -300)
    setScrollFactor('wall', 0.2, 0.2)
    addLuaSprite('wall', false)

    -- 2. 바닥 (ForestFloor)
    makeLuaSprite('floor', 'BGforest/ForestFloor',-1000, 500)
	setProperty('floor.angle', -3.5)
    setScrollFactor('floor', 1.0, 1.0)
    addLuaSprite('floor', false)

    -- 3. 수풀 1 (ForestBush)
    makeLuaSprite('bush1', 'BGforest/ForestBush', -600, -100)
	setProperty('bush1.scale.x', 2)
    setProperty('bush1.scale.y', 2)
    updateHitbox('bush1')
    setScrollFactor('bush1', 0.9, 0.9)
    addLuaSprite('bush1', false)

    -- 4. 수풀 2 (ForestBush2)
    makeLuaSprite('bush2', 'BGforest/ForestBush2', 1500, -100)
	setProperty('bush2.scale.x', 2)
	setProperty('bush2.scale.y', 2)
	updateHitbox('bush2')
    setScrollFactor('bush2', 0.9, 0.9)
    addLuaSprite('bush2', false)

    -- 5. 움직이는 수풀 (ForestBush3)
    makeLuaSprite('bush3', 'BGforest/ForestBush3', 400, 400)
    setScrollFactor('bush3', 1.3, 1.3)
    addLuaSprite('bush3', true) -- 캐릭터 앞에 배치
	
	-- 레이어
    makeLuaSprite('l', 'BGforest/LAYER', -600, -300)
	setProperty('l.scale.x', 2)
	setProperty('l.scale.y', 2)
	updateHitbox('l')
    setScrollFactor('l', 0.2, 0.2)
    addLuaSprite('l', true)
end

function onUpdate(elapsed)
    local songPos = getSongPosition()
    -- Bush3는 원래 계획대로 흔들기
    setProperty('bush3.angle', math.sin(songPos / 1000) * 10)
    
    -- 나머지 수풀들도 아주 미세하게(2~3도)만 따로 흔들어보세요
    setProperty('bush1.angle', math.sin(songPos / 1200) * 5)
    setProperty('bush2.angle', math.sin(songPos / 800) * -4)
end