function onCreated()
    makeLuaSprite('newBG', 'menuStory', 0, 0);
    addLuaSprite('newBG', false);
    setObjectCamera('newBG', 'other'); -- 가장 앞쪽 카메라에 배치
end