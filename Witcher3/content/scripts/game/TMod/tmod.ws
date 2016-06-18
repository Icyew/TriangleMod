class TModOptions
{   
	
	// ---- Combat Begin ---- //
	
	public function GetAltArmorStaminaMod() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'AltArmorStaminaMod');
	}

	public function GetArmorStaminaMod(armorType : EArmorType, armorSlot : EEquipmentSlots, action : EStaminaActionType) : float
	{
		var weight : float;
		var isBig, isAttack : bool;

		if (armorType == EAT_Light)
			weight = 1;
		else if (armorType == EAT_Medium)
			weight = 2;
		else if (armorType == EAT_Heavy)
			weight = 3;
		else
			weight = 0;

		isBig = (armorSlot == EES_Armor || armorSlot == EES_Pants || false);
		isAttack = (action == ESAT_LightAttack || action == ESAT_HeavyAttack || false);

		if (isBig && isAttack)
			return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'ChestPantsAttackCost') ) * weight;
		else if (isBig && !isAttack)
			return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'ChestPantsEvasionCost') ) * weight;
		else if (!isBig && isAttack)
			return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'GlovesBootsAttackCost') ) * weight;
		else if (!isBig && !isAttack)
			return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'GlovesBootsEvasionCost') ) * weight;
		else
			return 0;
	}

	public function GetHeavyAttackDamageMod() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'HeavyAttackDmgMod' ) );
	}

	public function GetStaminaRegenMult() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'StaminaRegenMult' ) );
	}

	public function GetStaminaRegenBonus() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'StaminaRegenBonus' ) );
	}

	public function GetLightAttackComboDecay() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'LightAttackComboDecay' ) ); 
	}

	public function GetHeavyAttackComboDecay() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'HeavyAttackComboDecay' ) ); 
	}
	// ---- Combat End ---- //

	// ---- Signs Begin ---- //

	public function GetQuenStaminaRegenMult() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'QuenStaminaRegenMult' ) );
	}

	public function GetQuenDamageRatio() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'QuenDamageRatio' ) );
	}

	// ---- Signs End ---- //

	// ---- Leveling Begin ---- //
	public function AreLevelOptionsEnabled() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'AreLevelOptionsEnabled' );
	}

	public function IsUpscalingOn() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'LinearUpscaling' );
	}

	public function IsDownscalingOn() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'LinearDownscaling' );
	}

	public function ShouldScaleAnimals() : bool
	{
		return !theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'DontScaleAnimals' );
	}

	public function GetUpscalingFactor() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'UpscalingFactor' ) );
	}

	public function GetDownscalingFactor() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'DownscalingFactor' ) );
	}
	
	public function GetFlatLevelBonus() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'LevelBonus' ) );
	}

	public function GetLevelJitter() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'LevelJitter' ) );
	}
	// ---- Leveling End ---- //
}