function onCreate()
    -- 배경 설정
    makeLuaSprite('nyanko', 'nyanko_bg', -1200, -700)
    addLuaSprite('nyanko', false)
end

function onStartCountdown()
    -- [수정] 전체 속도가 아니라 카운트다운 사이의 간격(초 단위)만 조절합니다.
    -- 이 숫자를 키우면 음악 속도는 그대로인데 3... 2... 1... 만 느려집니다.
    -- 나팔 소리 길이에 맞춰서 1.0, 1.2, 1.5 등으로 조절해 보세요.
    setProperty('countdownTimer.time', 1.0) 
end

function onCountdownTick(tick)
    if tick == 0 then
        -- 3 타이밍에 나팔 소리 재생
        playSound('Intro3', 1)
    end
end