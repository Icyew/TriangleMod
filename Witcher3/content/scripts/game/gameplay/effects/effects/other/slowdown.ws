/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/






class W3Effect_Slowdown extends CBaseGameplayEffect
{
	private saved var slowdownCauserId : int;
	private saved var decayPerSec : float;			
	private saved var decayDelay : float;			
	private saved var delayTimer : float;			
	private saved var slowdown : float;				

	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_Slowdown;
	default attributeName = 'slowdown';
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var dm : CDefinitionsManagerAccessor;
		var min, max : SAbilityAttributeValue;
		var prc, pts, raw : float; //modSigns
		
		super.OnEffectAdded(customParams);
		
		dm = theGame.GetDefinitionsManager();
		
		dm.GetAbilityAttributeValue(abilityName, 'decay_per_sec', min, max);
		decayPerSec = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		dm.GetAbilityAttributeValue(abilityName, 'decay_delay', min, max);
		decayDelay = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		//modSigns: calc final slowdown
		//prcs are not clamped to make negative resistance possible
		//points added (divided by 100 as slowdown factor < 1)
		raw = CalculateAttributeValue(effectValue);
		target.GetResistValue(CDS_ShockRes, pts, prc);
		slowdown = MaxF(0, raw - pts/100) * (1 - prc);
		//final slowdown factor is clamped to 10-90%
		slowdown = ClampF(slowdown, 0.1, 0.9);
		
		//debug log
		/*theGame.witcherLog.AddMessage("Slowdown effect:");
		theGame.witcherLog.AddMessage("Raw slowdown prc: " + raw);
		theGame.witcherLog.AddMessage("Shock resist pts: " + pts);
		theGame.witcherLog.AddMessage("Shock resist prc: " + prc);
		theGame.witcherLog.AddMessage("Slowdown prc: " + slowdown * 100);*/
		
		slowdownCauserId = target.SetAnimationSpeedMultiplier( 1 - slowdown );
		delayTimer = 0;
	}
	
	
	event OnUpdate(dt : float)
	{
		if(decayDelay >= 0 && decayPerSec > 0)
		{
			if(delayTimer >= decayDelay)
			{
				target.ResetAnimationSpeedMultiplier(slowdownCauserId);
				slowdown -= decayPerSec * dt;
				
				if(slowdown > 0)
					slowdownCauserId = target.SetAnimationSpeedMultiplier( 1 - slowdown );
				else
					isActive = false;
			}
			else
			{
				delayTimer += dt;
			}
		}
		
		super.OnUpdate(dt);
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		delayTimer = 0;
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();		
		target.ResetAnimationSpeedMultiplier(slowdownCauserId);
	}
	
	event OnEffectAddedPost()
	{
		if( IsAddedByPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) && target != thePlayer )
		{
			GetWitcherPlayer().AddMutation12Decoction();
		}
		
		super.OnEffectAddedPost();
	}
}