/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Potion_TawnyOwl extends W3RegenEffect
{
	default effectType = EET_TawnyOwl;
	private var timeLeftDisabled : float; default timeLeftDisabled = 0; // Triangle delayed recovery Triangle tawny owl
	private var superiorEffectActive : bool; default superiorEffectActive = false; // Triangle tawny owl
	private var initialEffectValue : SAbilityAttributeValue; // Triangle tawny owl Triangle delayed recovery

	public function OnTimeUpdated(deltaTime : float)
	{
		// Triangle delayed recovery
		// Triangle tawny owl
		// Triangle TODO this change disabled. Need to slow down tox degen a lot first, so it's actually important and white honey is useful. Keep this around just in case
		// if (theGame.GetTModOptions().GetAltTawnyOwlDuration() > 0) {
		// 	if (shouldEnableSuperiorEffect()) {
		// 		if (!superiorEffectActive) {
		// 			duration *= 2;
		// 			timeLeft *= 2;
		// 			superiorEffectActive = true;
		// 		}
		// 	} else if (superiorEffectActive) {
		// 		duration = duration / 2;
		// 		timeLeft = timeLeft / 2;
		// 		superiorEffectActive = false;
		// 	}
		// } else
		if (shouldEnableSuperiorEffect()) {
			duration = -1;
			superiorEffectActive = true;
		} else {
			duration = initialDuration;
			superiorEffectActive = false;
		}
		super.OnTimeUpdated(deltaTime);
		// var currentHour, level : int;
		// var toxicityThreshold : float;
		
		// if( isActive && pauseCounters.Size() == 0)
		// {
		// 	timeActive += deltaTime;	
		// 	if( duration != -1 )
		// 	{
				
		// 		level = GetBuffLevel();				
		// 		currentHour = GameTimeHours(theGame.GetGameTime());
		// 		if(level < 3 || (currentHour > GetHourForDayPart(EDP_Dawn) && currentHour < GetHourForDayPart(EDP_Dusk)) )
		// 			timeLeft -= deltaTime;
					
		// 		if( timeLeft <= 0 )
		// 		{
		// 			if ( thePlayer.CanUseSkill(S_Alchemy_s03) )
		// 			{
		// 				toxicityThreshold = thePlayer.GetStatMax(BCS_Toxicity);
		// 				toxicityThreshold *= 1 - CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Alchemy_s03, 'toxicity_threshold', false, true) ) * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s03);
		// 			}
		// 			if(isPotionEffect && target == thePlayer && thePlayer.CanUseSkill(S_Alchemy_s03) && thePlayer.GetStat(BCS_Toxicity, true) > toxicityThreshold)
		// 			{
						
		// 			}
		// 			else
		// 			{
		// 				isActive = false;		
		// 			}
		// 		}
		// 	}
		// 	OnUpdate(deltaTime);	
		// }
		// Triangle end
	}

	//Triangle tawny owl
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var skillPassiveMod : float;
		var witcher : W3PlayerWitcher;
		if (theGame.GetTModOptions().GetAltTawnyOwlDuration() > 0) {
			duration = theGame.GetTModOptions().GetAltTawnyOwlDuration();
			witcher = GetWitcherPlayer();
			skillPassiveMod = CalculateAttributeValue(witcher.GetAttributeValue('potion_duration'));
		
			duration *= 1 + skillPassiveMod;
			timeLeft = MinF(duration, timeLeft);
		}
		super.CalculateDuration(setInitialDuration);
	}

	// Triangle tawny owl
	private function shouldEnableSuperiorEffect() : bool
	{
		var currentHour, level : int;

		level = GetBuffLevel();
		currentHour = GameTimeHours(theGame.GetGameTime());
		return level == 3 && (currentHour <= GetHourForDayPart(EDP_Dawn) || currentHour >= GetHourForDayPart(EDP_Dusk));
	}

	// Triangle tawny owl
	// Triangle delayed recovery
	protected function calculateRegenPoints(dt : float) : float
	{
		var TMod : TModOptions;

		TMod = theGame.GetTModOptions();
		if (timeLeftDisabled > 0) {
			effectValue.valueMultiplicative = MinF(TMod.GetAltTawnyOwlBase() / 100, initialEffectValue.valueMultiplicative);
			timeLeftDisabled -= dt;
			if (timeLeftDisabled <= 0) {
				EnableRegen();
			}
		}
		return super.calculateRegenPoints(dt);
	}

	// Triangle delayed recovery
	public function DisableRegen(disableDuration : float)
	{
		initialEffectValue = effectValue;
		timeLeftDisabled = MaxF(disableDuration, timeLeftDisabled);
	}

	// Triangle delayed recovery
	public function EnableRegen() {
		effectValue = initialEffectValue;
		timeLeftDisabled = 0;
	}
}