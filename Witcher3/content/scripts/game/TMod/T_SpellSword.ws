/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


// Triangle spell sword
class W3TSpellSwordCustomParams extends W3BuffCustomParams
{
	var signType : ESignType; default signType = ST_None;
	var initialStacks : float; default initialStacks = 0;
}

class W3Effect_TSpellSword extends CBaseGameplayEffect
{
	default effectType = EET_TSpellSword;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	private var currentStacks : float;
	private var currentSign : ESignType;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3TSpellSwordCustomParams;
		super.OnEffectAdded(customParams);
		params = (W3TSpellSwordCustomParams)customParams;
		if (params) {
			currentStacks = params.initialStacks;
			SetSign(params.signType);
		} else {
			TUtil_LogMessage("WARNING: created spellsword effect without a sign type");
		}
	}

	private function StopVisualEffects(weaponEnt : CEntity)
	{
		if (weaponEnt) {
			weaponEnt.StopEffect('runeword_aard');
			weaponEnt.StopEffect('runeword_axii');
			weaponEnt.StopEffect('runeword_igni');
			weaponEnt.StopEffect('runeword_quen');
			weaponEnt.StopEffect('runeword_yrden');
		}
	}

	private function StartVisualEffects(weaponEnt : CEntity, signType : ESignType)
	{
		var fxName : name;
		if (weaponEnt) {
			if(signType == ST_Aard)
				fxName = 'runeword_aard';
			else if(signType == ST_Axii)
				fxName = 'runeword_axii';
			else if(signType == ST_Igni)
				fxName = 'runeword_igni';
			else if(signType == ST_Quen)
				fxName = 'runeword_quen';
			else if(signType == ST_Yrden)
				fxName = 'runeword_yrden';
			else fxName = '';
				
			if (StrLen(fxName) > 0)
				weaponEnt.PlayEffect(fxName);
		}
	}

	private function GetWeapon() : CEntity
	{
		var items : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var witcher : W3PlayerWitcher;
		var weaponEnt : CEntity;

		witcher = GetWitcherPlayer();	
		inv = witcher.GetInventory();
		items = inv.GetHeldWeapons();
		if (items.Size() > 0)
			weaponEnt = inv.GetItemEntityUnsafe(items[0]);
		return weaponEnt;
	}

	event OnEffectRemoved()
	{
		StopVisualEffects(GetWeapon());
		super.OnEffectRemoved();
	}

	private function SetSign(signType : ESignType)
	{
		var weaponEnt : CEntity;
		var witcher : W3PlayerWitcher;

		if (signType == ST_None) {
			TUtil_LogMessage("ERROR: Tried to set W3Effect_TSpellSword to ST_None. Should remove effect instead!");
			return;
		}

		weaponEnt = GetWeapon();
		if(weaponEnt)
		{
			currentSign = signType;
			iconPath = theGame.effectMgr.GetPathForEffectIconTypeName(SignTypeToIconName(signType));
			StopVisualEffects(weaponEnt);
			if (GetStacks() == GetMaxStacks())
				StartVisualEffects(weaponEnt, signType);
		}
	}

	private function SignTypeToIconName(signType : ESignType) : name
	{
		switch (signType) {
			case ST_Aard:
				return 'AardPower';
			case ST_Igni:
				return 'IgniPower';
			case ST_Yrden:
				return 'YrdenPower';
			case ST_Quen:
				return 'QuenPower';
			case ST_Axii:
				return 'AxiiPower';
			default:
				return '';
		}
	}

	function GetSign() : ESignType
	{
		return currentSign;
	}

	function DrainStacks()
	{
		StopVisualEffects(GetWeapon());
		currentStacks -= GetMaxStacks();
	}

	function AddStacks(value : float)
	{
		if (value > 0 && currentStacks < GetMaxStacks()) {
			currentStacks += value;
			if (GetStacks() == GetMaxStacks())
				StartVisualEffects(GetWeapon(), currentSign);
		}
	}

	public final function GetStacks() : int
	{
		return Min(FloorF(currentStacks), GetMaxStacks());
	}

	public final function GetMaxStacks() : int
	{
		return 100;
	}
}
