// Some utility functions for mod I didn't feel like putting elsewhere

function TUtil_PowerSkillForSignType(sign : ESignType) : ESkill
{
    var associatedSkill : ESkill;

    if (sign == ST_Aard)
        associatedSkill = S_Magic_s12;
    else if(sign == ST_Igni)
        associatedSkill = S_Magic_s07;
    else if(sign == ST_Yrden)
        associatedSkill = S_Magic_s16;
    else if(sign == ST_Quen)
        associatedSkill = S_Magic_s15;
    else if(sign == ST_Axii)
        associatedSkill = S_Magic_s18;
    else
        associatedSkill = S_SUndefined;
    return associatedSkill;
}

function TUtil_DmgTypeForPowerSkill(skill : ESkill) : name
{
    if (skill == S_Magic_s12)
        return theGame.params.DAMAGE_NAME_FORCE;
    else if (skill == S_Magic_s07)
        return theGame.params.DAMAGE_NAME_FIRE;
    else if (skill == S_Magic_s16)
        return theGame.params.DAMAGE_NAME_SHOCK;
    else if (skill == S_Magic_s15)
        return theGame.params.DAMAGE_NAME_FORCE;
    else if (skill == S_Magic_s18)
        return theGame.params.DAMAGE_NAME_WILL;
    return '';
}

function TUtil_LogMessage(message : string)
{
    LogChannel('TMod', message);
}

function TUtil_StaminaCostToFocusCost(cost : float) : float
{
    return cost / thePlayer.GetStatMax(BCS_Stamina) * TOpts_FocusPerMaxStamina();
}

// Triangle enemy mutations
enum TEMutation
{
    TEM_Undefined,
    TEM_Tough,
    TEM_Quick,
    TEM_Huge,
    TEM_Resilient,
    TEM_Electric,
    TEM_Venomous,
    TEM_Vampiric,
    TEM_Flaming,
    TEM_Draining,
    TEM_Haunted,
    TEM_Explosive,
    TEM_Freezing,
    TEM_Hypnotic,
    TEM_Inspiring,
    TEM_Inspired,
    TEM_TOTAL_COUNT
}

// Triangle enemy mutations
function TUtil_TEMutationNameToEnum(val : name) : TEMutation
{
    switch (val) {
        case 'TEM_Tough':
            return TEM_Tough;
        case 'TEM_Quick':
            return TEM_Quick;
        case 'TEM_Huge':
            return TEM_Huge;
        case 'TEM_Resilient':
            return TEM_Resilient;
        case 'TEM_Electric':
            return TEM_Electric;
        case 'TEM_Venomous':
            return TEM_Venomous;
        case 'TEM_Vampiric':
            return TEM_Vampiric;
        case 'TEM_Flaming':
            return TEM_Flaming;
        case 'TEM_Draining':
            return TEM_Draining;
        case 'TEM_Haunted':
            return TEM_Haunted;
        case 'TEM_Explosive':
            return TEM_Explosive;
        case 'TEM_Freezing':
            return TEM_Freezing;
        case 'TEM_Hypnotic':
            return TEM_Hypnotic;
        case 'TEM_Inspiring':
            return TEM_Inspiring;
        case 'TEM_Inspired':
            return TEM_Inspired;
        default:
            return TEM_Undefined;
    }
}

// Triangle enemy mutations
function TUtil_TEMutationEnumToName(val : TEMutation) : name
{
    switch (val) {
        case TEM_Tough:
            return 'TEM_Tough';
        case TEM_Quick:
            return 'TEM_Quick';
        case TEM_Huge:
            return 'TEM_Huge';
        case TEM_Resilient:
            return 'TEM_Resilient';
        case TEM_Electric:
            return 'TEM_Electric';
        case TEM_Venomous:
            return 'TEM_Venomous';
        case TEM_Vampiric:
            return 'TEM_Vampiric';
        case TEM_Flaming:
            return 'TEM_Flaming';
        case TEM_Draining:
            return 'TEM_Draining';
        case TEM_Haunted:
            return 'TEM_Haunted';
        case TEM_Explosive:
            return 'TEM_Explosive';
        case TEM_Freezing:
            return 'TEM_Freezing';
        case TEM_Hypnotic:
            return 'TEM_Hypnotic';
        case TEM_Inspiring:
            return 'TEM_Inspiring';
        case TEM_Inspired:
            return 'TEM_Inspired';
        default:
            return '';
    }
}

// Triangle enemy mutations
function TUtil_TEMutationEnumToDesc(val : TEMutation) : string
{
    switch (val) {
        case TEM_Tough:
            return "Tough";
        case TEM_Quick:
            return "Quick";
        case TEM_Huge:
            return "Huge";
        case TEM_Resilient:
            return "Resilient";
        case TEM_Electric:
            return "Electric";
        case TEM_Venomous:
            return "Venomous";
        case TEM_Vampiric:
            return "Vampiric";
        case TEM_Flaming:
            return "Flaming";
        case TEM_Draining:
            return "Draining";
        case TEM_Haunted:
            return "Haunted";
        case TEM_Explosive:
            return "Explosive";
        case TEM_Freezing:
            return "Freezing";
        case TEM_Hypnotic:
            return "Hypnotic";
        case TEM_Inspiring:
            return "Inspiring";
        case TEM_Inspired:
            return "Inspired";
        default:
            return "";
    }
}

// Triangle enemy mutations
function TUtil_TEMutationEnumToEffectType(val : TEMutation) : EEffectType
{
    switch (val) {
        case TEM_Flaming:
            return EET_TFireAura;
        case TEM_Freezing:
            return EET_TFreezingAura;
        case TEM_Hypnotic:
            return EET_THypnoAura;
        case TEM_Inspiring:
            return EET_TInspiringAura;
        case TEM_Inspired:
            return EET_TInspired;
        default:
            return EET_Undefined;
    }
}

// Triangle enemy mutations
function TUtil_GetMutatedPrefix(actor : CActor) : string
{
    var prefix : string;
    var stats : CCharacterStats;
    var mutation : TEMutation;
    var mutationName : name;
    var i, timeRemaining : int;
    stats = actor.GetCharacterStats();
    prefix = "";

    for (i = 1; i < TEM_TOTAL_COUNT; i += 1) {
        mutation = (TEMutation)i;
        mutationName = TUtil_TEMutationEnumToName(mutation);
        if (stats.HasAbility(mutationName)) {
            prefix += TUtil_TEMutationEnumToDesc(mutation) + " ";
        } else if (actor.IsAbilityBlocked(mutationName)) {
            timeRemaining = CeilF(actor.GetBlockedAbilityTimeRemaining(mutationName));
            if (timeRemaining < 0)
                prefix += "- ";
            else if (timeRemaining > 0)
                prefix += timeRemaining + " ";
        }
    }
    return prefix;
}

// Triangle enemy mutations
function TUtil_IsPhysicalDamage(dmgType : name) : bool
{
    return ( dmgType == theGame.params.DAMAGE_NAME_PHYSICAL || 
            dmgType == theGame.params.DAMAGE_NAME_SLASHING || 
            dmgType == theGame.params.DAMAGE_NAME_PIERCING || 
            dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING || 
            dmgType == theGame.params.DAMAGE_NAME_RENDING || 
            dmgType == theGame.params.DAMAGE_NAME_SILVER );
}

// Triangle enemy mutations
function TUtil_GetHealthType(actor : CActor) : EBaseCharacterStats
{
    if (actor.UsesEssence())
        return BCS_Essence;
    return BCS_Vitality;
}

// Triangle frenzy, killing spree
function TUtil_NonZeroToxOrActivePotion() : bool
{
    return (TOpts_ActivePotsInsteadOfTox() && GetWitcherPlayer().GetNonMutagenPotionBuffsCount() > 0) ||
        (!TOpts_ActivePotsInsteadOfTox() && thePlayer.GetStat(BCS_Toxicity) > 0);
}

// Triangle frenzy
function TUtil_CanFrenzy(player : CR4Player) : bool
{
    var witcherPlayer : W3PlayerWitcher;
    witcherPlayer = (W3PlayerWitcher)player;
    return witcherPlayer && witcherPlayer.CanUseSkill(S_Alchemy_s16) && TUtil_NonZeroToxOrActivePotion();
}

// Triangle everything
function TUtil_RoundTo(f : float, decimal : int) : float
{
    var i, digit : int;
    var ret : float;
    var isNeg : bool;

    if(decimal < 0)
        decimal = 0;

    ret = FloorF(AbsF(f));
    isNeg = false;
    if(f<0)
    {
        isNeg = true;       
        f *= -1;
    }
    f -= ret;
    
    for(i=0; i<decimal; i+=1)
    {
        f *= 10;
        digit = RoundMath(f);
        ret += digit / PowF(10,i+1);
        f -= digit;
    }
    
    if(isNeg)
        ret *= -1;
        
    return ret;
}

// Triangle adaptation
function TUtil_GetAdaptationDiscount(player : W3PlayerWitcher) : float
{
    return MinF(TOpts_AdaptationDiscountPerLevel() * player.GetSkillLevel(S_Alchemy_s14) * player.GetMutagenBuffsCount(), TOpts_AdaptationMaxDiscount());
}

// Triangle armor scaling
function TUtil_AreAnyArmorOptionsActive() : bool
{
    return (TOpts_FlatArmorPerLevel() > 0 || TOpts_ArmorPerLevelHuman() > 0 || TOpts_ArmorPerLevelMonster() > 0 || TOpts_ArmorPerScaledLevelMonster() > 0);
}

// Triangle whirl rend
function TUtil_IsAltSpecialAttackPressedAndEnabled() : bool
{
    return TOpts_AltSpecialAttackInput() && (theInput.IsActionPressed('LockAndGuard') || theInput.IsActionPressed('Focus'));
}

// Triangle spell sword
function TUtil_IsAltSignPowerPressedAndUsable(signType : ESignType) : bool
{
    return thePlayer.CanUseSkill(TUtil_PowerSkillForSignType(signType)) && (theInput.IsActionPressed('LockAndGuard') || theInput.IsActionPressed('Focus'));
}

// Triangle synergy mutagens
function TUtil_AddMutagenBonuses(color : ESkillColor, level : int, count : float) : float
{
    var bonus : float;
    var bonusName : name;
    var bonusMod : float;
    var finalBonus : int;

    switch (color) {
        case SC_Red:
            bonusName = 'T_mutagen_attackpower';
            bonus = TOpts_MinRedBonus();
            break;
        case SC_Green:
            if (TOpts_GreenGivesToxicity())
                bonusName = 'T_mutagen_toxicity';
            else
                bonusName = 'T_mutagen_vitality';
            bonus = TOpts_MinGreenBonus();
            break;
        case SC_Blue:
            bonusName = 'T_mutagen_spellpower';
            bonus = TOpts_MinBlueBonus();
            break;
        default:
            return 0;
    }

    bonusMod = 1 + 0.5 * (level - 1);

    finalBonus = FloorF(count * FloorF(bonus * bonusMod));
    if (finalBonus > 0) {
        thePlayer.AddAbilityMultiple(bonusName, finalBonus);
    }
    return finalBonus;
}

// Triangle synergy mutagens
function TUtil_NullifyMutagen(mutagen : name, color : ESkillColor)
{
    var attrVal, max : SAbilityAttributeValue;
    var count : int;
    var dm : CDefinitionsManagerAccessor;
    count = thePlayer.GetAbilityCount(mutagen);
    dm = theGame.GetDefinitionsManager();
    if (count == 0)
        return;
    if (color == SC_Green) {
        dm.GetAbilityAttributeValue(mutagen, 'vitality', attrVal, max);
        thePlayer.RemoveAbilityAll('T_mutagen_vitality_negative');
        count = RoundMath(attrVal.valueBase * count);
        thePlayer.AddAbilityMultiple('T_mutagen_vitality_negative', count);
    } else if (color == SC_Blue) {
        dm.GetAbilityAttributeValue(mutagen, 'spell_power', attrVal, max);
        thePlayer.RemoveAbilityAll('T_mutagen_spellpower_negative');
        count = RoundMath(attrVal.valueMultiplicative * 100 * count);
        thePlayer.AddAbilityMultiple('T_mutagen_spellpower_negative', count);
    } else {
        dm.GetAbilityAttributeValue(mutagen, 'attack_power', attrVal, max);
        thePlayer.RemoveAbilityAll('T_mutagen_attackpower_negative');
        count = RoundMath(attrVal.valueMultiplicative * 100 * count);
        thePlayer.AddAbilityMultiple('T_mutagen_attackpower_negative', count);
    }
}

// Triangle aard (NOT USED, kept for posterity)
function TUtil_IsEffectFromAard(effectType : EEffectType, actorVictim : CActor) : bool
{
    var buff : CBaseGameplayEffect;
    if (actorVictim && actorVictim.HasBuff(effectType)) {
        buff = actorVictim.GetBuff(effectType);
        if (buff.GetSourceName() == NameToString('_sign')) {
            return true;
        }
    }
    return false;
}

// Triangle attack combos
function TUtil_AreAttackCombosEnabled(isHeavy : bool) : bool
{
    if (isHeavy) {
        return TOpts_LightAttackComboDecay() > 0;
    } else {
        return TOpts_HeavyAttackComboDecay() > 0;
    }
}

// Triangle everything
function TUtil_IsCustomSkillEnabled(skill : ESkill) : bool
{
    switch (skill) {
        case S_Sword_s04:
            if (!TUtil_AreAttackCombosEnabled(true))
                return false;
            else
            return TOpts_HeavyAttackComboMultBonus() > 0 ||
                    TOpts_HeavyAttackComboCritDmgBonus() > 0 ||
                    TOpts_HeavyAttackComboCritBonus() > 0 ||
                    TOpts_HeavyAttackComboDmgBonus() > 0;
        case S_Sword_s21:
            if (!TUtil_AreAttackCombosEnabled(false))
                return false;
            else
            return TOpts_LightAttackComboCritBonus() > 0 ||
                    TOpts_LightAttackComboSpeedBonus() > 0 ||
                    TOpts_LightAttackComboCritDmgBonus() > 0 ||
                    TOpts_LightAttackComboDmgBonus() > 0;
        case S_Sword_s08:
            if (!TUtil_AreAttackCombosEnabled(true))
                return false;
            else
            return TOpts_CrushingBlowsBonusPerFocusPnt() > 0 ||
                    TOpts_CrushingBlowsCritDmgBonus() > 0;
        case S_Sword_s16:
            return TOpts_ResolvePenaltyReduction() > 0;
        case S_Sword_s17:
            if (!TUtil_AreAttackCombosEnabled(false))
                return false;
            else
            return TOpts_PreciseBlowsBonusPerFocusPnt() > 0 ||
                    TOpts_PreciseBlowsCritChanceBonus() > 0;
        case S_Sword_s07:
            return TOpts_AnatomicalKnowledgeDuration() > 0;
        case S_Magic_s12:
            return TOpts_AardPowerFrostDuration() > 0;
        case S_Magic_s07:
            return TOpts_IgniPowerScorchFraction() > 0;
        case S_Magic_s16:
            return TOpts_YrdenPowerRadius() > 0;
        case S_Magic_s15:
            return TOpts_QuenPowerHealRatio() > 0;
        case S_Magic_s18:
            return TOpts_AxiiPowerWeaknessDuration() > 0;
        case S_Alchemy_s03:
            return TOpts_DelayedRecoverySlowFactor() > 0;
        case S_Alchemy_s12:
            return TOpts_PoisonedBladesCritBonus() > 0;
        case S_Alchemy_s05:
            return TOpts_ProtectiveCoatingDuration() > 0;
        case S_Alchemy_s07:
            return TOpts_HunterInstinctCritChance() > 0;
        case S_Alchemy_s16:
            return TOpts_CustomFrenzy();
        default:
            return false;
    }
}

// Triangle attack combos
function TUtil_ShouldAttackCombo(player : CR4Player, isHeavy : bool) : bool
{
    var witcher : W3PlayerWitcher;
    witcher = (W3PlayerWitcher)player;
    if (!witcher)
        return false;
    if (isHeavy && TUtil_AreAttackCombosEnabled(isHeavy)) {
        return (witcher.CanUseSkill(S_Sword_s04) && TUtil_IsCustomSkillEnabled(S_Sword_s04)) ||
                (witcher.CanUseSkill(S_Sword_s08) && TUtil_IsCustomSkillEnabled(S_Sword_s08));
    } else if (TUtil_AreAttackCombosEnabled(isHeavy)) {
        return (witcher.CanUseSkill(S_Sword_s21) && TUtil_IsCustomSkillEnabled(S_Sword_s21)) ||
                (witcher.CanUseSkill(S_Sword_s17) && TUtil_IsCustomSkillEnabled(S_Sword_s17));
    } else {
        return false;
    }
}

// Triangle everything
function TUtil_ValueForLevel(skill : ESkill, maxValue : float) : float
{
    return TUtil_InterpolateLevelValue(maxValue, GetWitcherPlayer().GetSkillMaxLevel(skill), thePlayer.GetSkillLevel(skill));
}

// Triangle everything
function TUtil_InterpolateLevelValue(maxValue : float, maxLevel : int, level : float) : float
{
    return (level / maxLevel) * maxValue;
}

// Triangle modSigns resists
function TUtil_GetLvlResistanceAbilityNames(out dmgArr : array<name>, out magicArr : array<name>)
{
    dmgArr.PushBack('TModResistanceLvlBonus_Physical');
    dmgArr.PushBack('TModResistanceLvlBonus_Slashing');
    dmgArr.PushBack('TModResistanceLvlBonus_Piercing');
    dmgArr.PushBack('TModResistanceLvlBonus_Bludgeoning');
    dmgArr.PushBack('TModResistanceLvlBonus_Rending');
    dmgArr.PushBack('TModResistanceLvlBonus_Elemental');

    magicArr.PushBack('TModResistanceLvlBonus_Force');
    magicArr.PushBack('TModResistanceLvlBonus_Shock');
    magicArr.PushBack('TModResistanceLvlBonus_Will');
    magicArr.PushBack('TModResistanceLvlBonus_Fire');
    magicArr.PushBack('TModResistanceLvlBonus_Frost');
}
