package backend;

import flixel.FlxG;

class EnergySystem
{
    public static var saveData:Dynamic = FlxG.save.data;

    // 통솔력 기본 설정
    public static var maxEnergy:Int = 100;
    public static var addEnergy:Int = 5;
    public static var currentEnergy:Int = 100;
    public static var givingSec:Float = 300;
    public static var lastSaveTime:Float = 0;

    public static function init():Void
    {
        load();
        calculateEnergy(); // 접속 시 미정산 회복량 즉시 정산

        // 이벤트 신호 등록
        FlxG.signals.postUpdate.add(function() update(FlxG.elapsed));
        FlxG.signals.focusGained.add(function() {
            load();
            calculateEnergy();
        });
        FlxG.signals.focusLost.add(save);
    }

    public static function calculateEnergy():Void // 에너지를 계산하기
    {
        var now = Date.now().getTime() / 1000;
        var elapsed = now - lastSaveTime;

        // 회복 주기 미만으로 지났으면 정산하지 않음
        if (elapsed < givingSec) return;

        // 지나간 주기 횟수 계산(추가할 횟수임)
        var cycles:Int = Std.int(elapsed / givingSec);

        currentEnergy += cycles * addEnergy; // 현재에너지에다가 추가량 * 추가횟수를 추가하
        if (currentEnergy > maxEnergy) // 최대에너지 시스템
        {
            currentEnergy = maxEnergy;
        }

        // 사용한 회복 주기 시간만큼만 기준 시간 추가 (자투리 시간 자동 보존)
        lastSaveTime += cycles * givingSec;
        save();
    }

    public static function load():Void // 변수에 데이터를 로드하기
    {
        if (saveData.maxEnergy != null) maxEnergy = saveData.maxEnergy;
        if (saveData.addEnergy != null) addEnergy = saveData.addEnergy;
        if (saveData.currentEnergy != null) currentEnergy = saveData.currentEnergy;
        if (saveData.givingSec != null) givingSec = saveData.givingSec;
        
        // 저장된 시각이 없으면 현재 시각을 기본값으로 지정
        if (saveData.lastSaveTime != null) lastSaveTime = saveData.lastSaveTime;
        else lastSaveTime = Date.now().getTime() / 1000;
    }

    public static function save():Void // 데이터를 다 저장하기
    {
        saveData.maxEnergy = maxEnergy;
        saveData.addEnergy = addEnergy;
        saveData.currentEnergy = currentEnergy;
        saveData.givingSec = givingSec;
        saveData.lastSaveTime = lastSaveTime;
        FlxG.save.flush();
    }

    public static function update(elapsed:Float):Void
    {
        // 실시간 UI 타이머 텍스트 갱신 로직 작성
    }
}
