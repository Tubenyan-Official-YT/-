package options;

import states.MainMenuState;
import backend.StageData;

class OptionsState extends MusicBeatState
{
	// 외부 파일들이 전역 상태를 확인할 수 있도록 정적 변수 유지
	public static var onPlayState:Bool = false;

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end

		// 1. 투명한 배경을 가진 옵션 서브스테이트를 메인 위에 즉시 오픈
		var optionsSub:options.OptionsSubState = new options.OptionsSubState();
		
		// 주입용 변수가 있다면 동기화 (PlayState 상태 공유)
		options.OptionsSubState.onPlayState = onPlayState; 
		
		openSubState(optionsSub);

		// 2. 만약 서브스테이트가 닫히면(close) 실행할 수명 주기 정의
		optionsSub.closeCallback = function() {
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else 
			{
				MusicBeatState.switchState(new MainMenuState());
			}
		};

		super.create();
	}
}
