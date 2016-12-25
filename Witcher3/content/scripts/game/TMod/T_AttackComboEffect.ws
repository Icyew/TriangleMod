/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_TAttackCombo extends W3Effect_TMutableDuration
{
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	protected var comboCount : int; default comboCount = 0;
	protected var maxDuration : float;
	protected var decayTime : float;
	protected var maxCombo : int;

	event OnUpdate(dt : float)
	{
		SetShowOnHUD(comboCount > 0);
		super.OnUpdate(dt);
	}

	public function IncCombo()
	{
		if (ComboLength() < maxCombo) {
			comboCount = comboCount + 1;
		}
	}

	public function DecCombo()
	{
		comboCount = Max(comboCount - 1, 0);
	}

	public function IncTime(optional fixedTime : float)
	{
		if (duration  < 0) {
			SetTimeLeft(0);
			duration = maxDuration;
		}
		if (fixedTime > 0)
			AddTimeLeft(fixedTime, true);
		else
			AddTimeLeft(decayTime, true);
	}

	public function ComboCount() : int
	{
		return comboCount;
	}

	public function ComboLength() : int
	{
		return Max(0, ComboCount() - 1);
	}
}
