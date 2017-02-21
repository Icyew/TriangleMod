/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_YrdenHealthDrain extends W3DamageOverTimeEffect
{
	//private var hitFxDelay : float;
	
	default effectType = EET_YrdenHealthDrain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		//modSigns: since this effect last for 0.2 sec fx is never played. Moved it to Yrden entity.
		//hitFxDelay = 0.9 + RandF() / 5;	//0.9-1.1
		//hitFxDelay = 0;
		
		SetEffectValue();
	}
	
	
	protected function SetEffectValue()
	{
		//effectValue = thePlayer.GetSkillAttributeValue(S_Magic_s11, 'direct_damage_per_sec', false, true) * thePlayer.GetSkillLevel(S_Magic_s11);
		//modSigns: effect value is calculated in yrden entity, now we only need to apply resistance
		var prc, pts : float;
		target.GetResistValue(CDS_ShockRes, pts, prc);
		effectValue.valueMultiplicative *= (1 - prc); //not counting pts in as it is DoT damage
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		//modSigns: since this effect last for 0.2 sec fx is never played. Moved it to Yrden entity.
		/*hitFxDelay -= dt;
		if(hitFxDelay <= 0)
		{
			hitFxDelay = 0.9 + RandF() / 5;	//0.9-1.1
			target.PlayEffect('yrden_shock');
		}*/
	}
}