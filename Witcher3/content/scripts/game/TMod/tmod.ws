class TModOptions
{   
	
	// ---- Combat Begin ---- //

	public function GetHeavyAttackDamageMod() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'HeavyAttackDmgMod' ) );
	}

	public function GetLightAttackComboBonus() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'LightAttackComboBonus' ) );
	}

	public function GetHeavyAttackComboBonus() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'HeavyAttackComboBonus' ) );
	}

	public function GetLightAttackComboDecay() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'LightAttackComboDecay' ) );
	}

	public function GetHeavyAttackComboDecay() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'HeavyAttackComboDecay' ) );
	}

	public function GetRendChargeBonus() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'RendChargeBonus' ) );
	}

	// ---- Combat End ---- //

	// ---- Stamina Begin ---- //

	public function GetAltArmorStaminaMod() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'AltArmorStaminaMod');
	}

	public function GetBaseStaminaCost(action : EStaminaActionType, optional abilityName : name) : float
	{
		switch (action) {
			case ESAT_Dodge:
				return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'BaseDodgeCost') );
			case ESAT_Roll:
				return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'BaseRollCost') );
			case ESAT_LightAttack:
				return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'BaseLightAttackCost') );
			case ESAT_HeavyAttack:
				return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'BaseHeavyAttackCost') );
			case ESAT_Ability:
				if (SkillNameToEnum(abilityName) == S_Sword_s02) {
					return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'BaseHeavyAttackCost') ) * 2; // for now, rend has 2x base stamina cost
				} else if (SkillNameToEnum(abilityName) == S_Sword_s01) { // Triangle TODO draining stamina for whirl might not be necessary, since drain per sec already active
					return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'BaseLightAttackCost') );
				}
				break;
		}
		return 0;
	}

	public function GetArmorStaminaMod(armorType : EArmorType, armorSlot : EEquipmentSlots, action : EStaminaActionType, optional abilityName : name) : float
	{
		var weight : float;
		var isBig, isAttack, isEvade : bool;

		if (armorType == EAT_Light)
			weight = 1;
		else if (armorType == EAT_Medium)
			weight = 2;
		else if (armorType == EAT_Heavy)
			weight = 3;
		else
			weight = 0;

		isBig = (armorSlot == EES_Armor || armorSlot == EES_Pants || false);
		isAttack = (action == ESAT_LightAttack || action == ESAT_HeavyAttack ||
			(action == ESAT_Ability && SkillNameToEnum(abilityName) == S_Sword_s02) ||
			(action == ESAT_Ability && SkillNameToEnum(abilityName) == S_Sword_s01) || false);
		isEvade = (action == ESAT_Dodge || action == ESAT_Roll || action == ESAT_Evade || action == ESAT_Jump || false);

		if (isBig) {
			if (isAttack)
				return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'ChestPantsAttackCost') ) * weight;
			if (isEvade)
				return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'ChestPantsEvasionCost') ) * weight;
		} else {
			if (isAttack)
				return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'GlovesBootsAttackCost') ) * weight;
			if (isEvade)
				return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'GlovesBootsEvasionCost') ) * weight;
		}
		return 0;
	}

	// triangle TODO dead code for now
	public function GetArmorSpeedBonus(inventory : CInventoryComponent, action : EBufferActionType) : float
	{
		var speedBonus, speedPenalty, tempMod : float;
		var tempItem : SItemUniqueId;
		var armorEq, glovesEq, pantsEq, bootsEq : bool;

		if (action != EBAT_Dodge && action != EBAT_Roll) {
			return 1.0;
		}

		speedBonus = 1.0;
		speedPenalty = 1.0;
		if (inventory.GetItemEquippedOnSlot(EES_Armor, tempItem) && inventory.GetArmorType(tempItem) != EAT_Medium) {
			tempMod = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'ChestEvasionMod') ) / 100;
			if (inventory.GetArmorType(tempItem) == EAT_Heavy)
				speedPenalty += tempMod;
			else
				speedBonus += tempMod;
		}

		if (inventory.GetItemEquippedOnSlot(EES_Pants, tempItem) && inventory.GetArmorType(tempItem) != EAT_Medium) {
			tempMod = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'PantsEvasionMod') ) / 100;
			if (inventory.GetArmorType(tempItem) == EAT_Heavy)
				speedPenalty += tempMod;
			else
				speedBonus += tempMod;
		}

		if (inventory.GetItemEquippedOnSlot(EES_Gloves, tempItem) && inventory.GetArmorType(tempItem) != EAT_Medium) {
			tempMod = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'GlovesBootsEvasionMod') ) / 100;
			if (inventory.GetArmorType(tempItem) == EAT_Heavy)
				speedPenalty += tempMod;
			else
				speedBonus += tempMod;
		}

		if (inventory.GetItemEquippedOnSlot(EES_Boots, tempItem) && inventory.GetArmorType(tempItem) != EAT_Medium) {
			tempMod = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'GlovesBootsEvasionMod') ) / 100;
			if (inventory.GetArmorType(tempItem) == EAT_Heavy)
				speedPenalty += tempMod;
			else
				speedBonus += tempMod;
		}

		speedPenalty = 1 / speedPenalty;
		return speedBonus * speedPenalty;
	}

	public function GetStaminaRegenMult() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'StaminaRegenMult' ) );
	}

	public function GetStaminaRegenBonus() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'StaminaRegenBonus' ) );
	}

	public function GetFocusPerMaxStamina() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'FocusPerMaxStamina' ) );
	}

	public function GetWeakDamageMod() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'WeakDamageMod' ) );
	}

	// ---- Stamina End --- //

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