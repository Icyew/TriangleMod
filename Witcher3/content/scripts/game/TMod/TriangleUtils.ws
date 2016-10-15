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

// Triangle frenzy
function TUtil_CanFrenzy(player : CR4Player) : bool
{
    var witcherPlayer : W3PlayerWitcher;
    var mutagenArr : array<W3Mutagen_Effect>;
    var potionArr : array<CBaseGameplayEffect>;
    witcherPlayer = (W3PlayerWitcher)player;
    mutagenArr = witcherPlayer.GetMutagenBuffs();
    potionArr = witcherPlayer.GetPotionBuffs();
    return witcherPlayer && witcherPlayer.CanUseSkill(S_Alchemy_s16) && mutagenArr.Size() < potionArr.Size();
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
