function onEvent(name, value1, value2)
    if name == 'FlashScreen' then
        -- Value 1: 지속시간 설정 (숫자가 아니면 0.5초)
        local duration = tonumber(value1)
        if duration == nil then duration = 0.5 end
        
        -- Value 2: 색상 설정 (비어있으면 흰색)
        local color = value2
        if color == nil or color == '' then color = 'FFFFFF' end
        
        -- 'game' 레이어에 플래시 실행 (강제 실행 옵션 true)
        cameraFlash('game', color, duration, true)
    end
end