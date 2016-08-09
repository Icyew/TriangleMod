/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


// Triangle parry
class W3Effect_TParryCooldown extends CBaseGameplayEffect
{
	default effectType = EET_TParryCooldown;
	private var currentStacks : float;

	event OnUpdate(dt : float)
	{
		currentStacks += dt / theGame.GetTModOptions().GetParryCooldown();
		currentStacks = MinF(currentStacks, GetMaxStacks());
		SetShowOnHUD(currentStacks != GetMaxStacks());
		super.OnUpdate(dt);
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		currentStacks = GetMaxStacks();
		super.OnEffectAdded(customParams);
	}

	function DrainStacks(value : int)
	{
		if (value > 0) {
			// Discard partially regenerated stack
			currentStacks = MaxF(0, FloorF(currentStacks) - value);
		}
	}

	public final function GetStacks() : int
	{
		return FloorF(currentStacks);
	}

	public final function GetMaxStacks() : int
	{
		return theGame.GetTModOptions().GetMaxParries();
	}
}
