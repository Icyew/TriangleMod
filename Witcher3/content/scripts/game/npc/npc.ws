/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



enum EConverserType
{
	CT_General,
	CT_Nobleman,
	CT_Guard,
	CT_Mage,
	CT_Bandit,
	CT_Scoiatael,
	CT_Peasant,
	CT_Poor,
	CT_Child
};

// Triangle spell sword, protective coating
struct ExtPrefixEntry
{
	var prefix : string;
	var sourceName : string;
}
// Triangle end

statemachine import class CNewNPC extends CActor
{
	
	// Triangle level scaling used to check if you need to re-apply or remove jitter to a creature
	saved var prevJitterOption	  : int;			  default prevJitterOption = 0;
	saved var cachedJitter		  : int;			  default cachedJitter = 0;
	// Triangle spell sword, protective coating
	var extPrefixes				  : array<ExtPrefixEntry>;
	// Triangle whirl
	var stunLocked				  : bool;
	// Triangle end
	
	
	
	editable var isImmortal 		: bool;				
	editable var isInvulnerable 	: bool;				
	editable var willBeUnconscious 	: bool;				
	editable var minUnconsciousTime : float;    		default minUnconsciousTime = 20.f;
	
	editable var unstoppable		: bool;				hint unstoppable = "won't play hit reaction nor critical state reaction";
	
	editable var RemainsTags 		: array<name>;		hint RemainsTags="If set then the NPC's remains will be tagged with given tags";
	editable var level 				: int;				default level = 1;
	var currentLevel		: int;
	var originalLevel		: int; // Triangle level scaling
	editable saved var levelFakeAddon     : int;				default levelFakeAddon = 0;
	private	 saved var newGamePlusFakeLevelAddon : bool;		default newGamePlusFakeLevelAddon = false;
	private	 saved var xmlLevel		: SAbilityAttributeValue;
	private  var isXmlLevelSet 		: bool; 					default isXmlLevelSet = false;
	editable var isMiniBossLevel    : bool;						default isMiniBossLevel = false;
	import var suppressBroadcastingReactions		: bool;
	editable saved var dontUseReactionOneLiners		: bool;		default dontUseReactionOneLiners = false;
	editable saved var disableConstrainLookat		: bool;		default disableConstrainLookat = false;
	
	editable var isMonsterType_Group   : bool;  				default isMonsterType_Group = false;
	
	editable var useSoundValue		: bool;						default useSoundValue = false;
	editable var soundValue			: int;	
	
	
	editable var clearInvOnDeath			: bool;	
	default clearInvOnDeath = false;
	
	editable var noAdaptiveBalance : bool;
	default noAdaptiveBalance = false;
	
	editable var grantNoExperienceAfterKill : bool;
	default grantNoExperienceAfterKill = false;
	
	editable var abilityBuffStackedOnEnemyHitName : name;
	
	
	private var levelBonusesComputedAtPlayerLevel : int; 		default levelBonusesComputedAtPlayerLevel = -1;
	
	hint abilityBuffStackedOnEnemyHitName = "Stackable ability added on hitting enemies. Mainly for damage scaling of followers.";
	hint disableConstrainLookat = "It will disable lookats form reactions and from QuestLookat block";
	hint useSoundValue = "If true it will add the SoundValue to the threat Rating used for combat music control";
	hint soundValue = "This value will be added or subtracted from sound system to achieve final threat Rating";
	
	
	
	import private saved var npcGroupType 		: ENPCGroupType;	default npcGroupType = ENGT_Enemy;
	
	
	private optional autobind 	horseComponent 		: W3HorseComponent = single;
	private var 		isHorse 			: bool;
	private saved var 	canFlee				: bool; 	default 	canFlee	= true;
	private var 		isFallingFromHorse 	: bool; 	default 	isFallingFromHorse = false;
	
	private var		immortalityInitialized	: bool;
	
	
	private var 	canBeFollowed 			: bool;		default 		canBeFollowed = false;

	
	private var 	bAgony					: bool;		default 		bAgony 	= false;
	private var		bFinisher 				: bool;		default 		bFinisher = false;
	private var		bPlayDeathAnim 			: bool;		default			bPlayDeathAnim = true;
	private var		bAgonyDisabled			: bool;		default			bAgonyDisabled = false;
	private var		bFinisherInterrupted	: bool;
	
	private var		bIsInHitAnim : bool;
	
	
	private var		threatLevel					: int;				default			threatLevel = 10;
	private var 	counterWindowStartTime 		: EngineTime;		
	private var		bIsCountering				: bool;
	private var		allowBehGraphChange			: bool;				default			allowBehGraphChange = true;
	private var		aardedFlight				: bool;				
	public var		lastMeleeHitTime			: EngineTime;		
	
	private saved var preferedCombatStyle : EBehaviorGraph;
	
	
	private var		previousStance				: ENpcStance;		default			previousStance	= NS_Normal;
	private var		regularStance				: ENpcStance;		default			regularStance	= NS_Normal;
	
	
	private var 	currentFightStage			: ENPCFightStage;
	
	
	private var 	currentState 				: CName;			default 		autoState = 'NewIdle';

	private var 	behaviorGraphEventListened	: array<name>;
	
	
	private var 	isTemporaryOffGround		: bool;
	
	
	private var 	npc_health_bar 				: float;
	
	
	private var		isUnderwater 				: bool;		default isUnderwater = false;
	
	
	private var isTranslationScaled 			: bool; 
	
	
	private var tauntedToAttackTimeStamp 		: float;
	
	
	
	
	
	public var isTeleporting 					: bool;			default isTeleporting = false;
	
	
	
	
	
	
	
	public var itemToEquip 						: SItemUniqueId;
	
	
	private saved var wasBleedingBurningPoisoned 	: bool;		default wasBleedingBurningPoisoned = false;
	
	
	public 	var wasInTalkInteraction				: bool;
	private var wasInCutscene						: bool;
	public 	var shieldDebris 						: CItemEntity;
	public 	var lastMealTime						: float;	default lastMealTime = -1;
	public 	var packName							: name;		
	public 	var isPackLeader						: bool;		
	private var mac 								: CMovingPhysicalAgentComponent;
	private var parentEncounter						: CEncounter; 
	private var npcLevelToUpscaledLevelDifference	: int; 		
	
	
	private saved  var isTalkDisabled				: bool; default isTalkDisabled = false;
	private   	   var isTalkDisabledTemporary		: bool; default isTalkDisabledTemporary = false;
	
	
	private var wasNGPlusLevelAdded					: bool; default wasNGPlusLevelAdded = false;
	
	private var deathTimestamp : float;
	
	private saved var savedRandomLevel				: int; default savedRandomLevel = -1; //modSigns: for random scaling
	
	event OnGameDifficultyChanged( previousDifficulty : int, currentDifficulty : int )
	{
		if ( HasAbility('difficulty_CommonEasy') ) RemoveAbility('difficulty_CommonEasy');
		if ( HasAbility('difficulty_CommonMedium') )  RemoveAbility('difficulty_CommonMedium');
		if ( HasAbility('difficulty_CommonHard') )  RemoveAbility('difficulty_CommonHard');
		if ( HasAbility('difficulty_CommonHardcore') )  RemoveAbility('difficulty_CommonHardcore');
		
		switch ( theGame.GetSpawnDifficultyMode() )
		{
		case EDM_Easy:
			AddAbility('difficulty_CommonEasy');
			break;
		case EDM_Medium:
			AddAbility('difficulty_CommonMedium');
			break;
		case EDM_Hard:
			AddAbility('difficulty_CommonHard');
			break;
		case EDM_Hardcore:
			AddAbility('difficulty_CommonHardcore');
			break;
		}	
		
		levelBonusesComputedAtPlayerLevel = -1;
		AddTimer('AddLevelBonuses', 0.1, true, false, , true);
	}
	
	event OnLevelUpscalingChanged() //modSigns: remove vanilla upscaling
	{
		/*levelBonusesComputedAtPlayerLevel = -1; 
		AddTimer('AddLevelBonuses', RandRangeF(0.05,0.2), true, false, , true);*/
	}
	
	timer function ResetTalkInteractionFlag( td : float , id : int)
	{
		if ( !IsSpeaking() )
		{
			wasInTalkInteraction = false;
			RemoveTimer('ResetTalkInteractionFlag');
		}
	}
		
	protected function OnCombatModeSet( toggle : bool )
	{
		super.OnCombatModeSet( toggle );
		
		if( toggle )
		{
			SetCombatStartTime();
			SetCombatPartStartTime();
			
			
			
			
			RecalcLevel();
		}
		else
		{
			ResetCombatStartTime();
			ResetCombatPartStartTime();
		}		
	}
	
	public function SetImmortalityInitialized(){ immortalityInitialized = true; }
	
	public function SetNPCType( type : ENPCGroupType ) { npcGroupType = type; }
	public function GetNPCType() : ENPCGroupType { return npcGroupType; }
	
	public function GetBloodType() : EBloodType
	{
		var tmpName : name;
		var tmpBool : bool;
		var mc : EMonsterCategory;
		var blood : EBloodType;
		
		theGame.GetMonsterParamsForActor(this, mc, tmpName, tmpBool, tmpBool, tmpBool);
		
		switch( mc )
		{
			case MC_Specter :
			case MC_Vampire :
			case MC_Magicals :
				blood = BT_Black;
				break;
				
			case MC_Cursed :
				blood = BT_Yellow;
				break;
				
			case MC_Insectoid :
				blood = BT_Green;
				break;
				
			case MC_Troll :
			case MC_Human :
			case MC_Animal :
			case MC_Necrophage :
			case MC_Hybrid :
			case MC_Relic :
			case MC_Beast :
			case MC_Draconide :
			default :
				blood = BT_Red;
		}
		
		return blood;
	}
	
	public function SetCanBeFollowed( val : bool ) { canBeFollowed = val; }
	public function CanBeFollowed() : bool { return canBeFollowed; }
	
	event OnPreAttackEvent(animEventName : name, animEventType : EAnimationEventType, data : CPreAttackEventData, animInfo : SAnimationEventAnimInfo )
	{
		var witcher : W3PlayerWitcher;
		var levelDiff : int;
	
		super.OnPreAttackEvent(animEventName, animEventType, data, animInfo);
		
		if(animEventType == AET_DurationStart )
		{
			
			
			witcher = GetWitcherPlayer();
			
			
			
			if(GetTarget() == witcher )
			{
				levelDiff = GetLevel() - witcher.GetLevel();
				
				if ( levelDiff < theGame.params.LEVEL_DIFF_DEADLY )
					this.SetDodgeFeedback( true );
			}
			
			if ( IsCountering() )
			{
				
				if(GetTarget() == witcher && ( thePlayer.IsActionAllowed(EIAB_Dodge) || thePlayer.IsActionAllowed(EIAB_Roll) ) && TUtil_CanFrenzy(witcher)) // Triangle frenzy
					witcher.StartFrenzy();
			}
		}
		else if(animEventType == AET_DurationEnd )
		{
			witcher = GetWitcherPlayer();
			
			if(GetTarget() == witcher )
			{		
				this.SetDodgeFeedback( false );
			}
		}
	}
	
	public function SetDodgeFeedback( flag : bool )
	{
		
		if ( flag )
		{
			thePlayer.SetDodgeFeedbackTarget( this );
		}
		else
		{
			thePlayer.SetDodgeFeedbackTarget( NULL );
		}
	}
	
	event OnBlockingSceneEnded( optional output : CStorySceneOutput)
	{
		super.OnBlockingSceneEnded( output );
		wasInCutscene = true;
	}
	
	public function WasInCutscene() : bool
	{
		return wasInCutscene;
	}
	
	
	public function IsVIP() : bool
	{
		var tags : array<name>;
		var i : int;
		
		
		tags = GetTags();
		for ( i = 0; i < tags.Size(); i+=1 )
		{
			if ( tags[i] == 'vip' )
			{
				return true;
			}
		}
		
		return false;
	}
	
	
	
	
	
	
	saved var hasRolledForMutations : bool; default hasRolledForMutations = false; // Triangle enemy mutations
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		var lvlDiff, playerLevel: int;
		var heading 		: float;
		var remainingDuration : float;
		var oldLevel : int;
		// Triangle enemy mutations
		var emutations : array < name >;
		var i : int;
		var tmpName : name;
		var tmpBool : bool;
		var monsterCategory : EMonsterCategory;
		// Triangle end
		
		currentLevel = level;
		originalLevel = currentLevel; // Triangle level scaling
		levelBonusesComputedAtPlayerLevel = -1;
		
		super.OnSpawned(spawnData);
		
		
		SetThreatLevel();
		
		
		GotoStateAuto();		
		

		// Triangle enemy mutations
		theGame.GetMonsterParamsForActor(this, monsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
		if (npcGroupType == ENGT_Enemy && monsterCategory != MC_Animal && (UsesEssence() || TOpts_CanVitalityMutate()) && !hasRolledForMutations) {
			TOpts_RandomEnemyMutations(emutations);
			for (i = 0; i < emutations.Size(); i += 1) {
				AddAbility(emutations[i]);
			}
			hasRolledForMutations = true;
		}
		// Triangle
		
		isTalkDisabledTemporary = false;
		
		
		if ( HasTag( 'fergus_graem' ) )
		{
			if ( !isTalkDisabled )
			{
				GetComponent( 'talk' ).SetEnabled( true );
			}
		}
		
		
		if(!spawnData.restored )
		{
			if( !isXmlLevelSet )
			{
				xmlLevel = GetAttributeValue( 'level',,true );
				isXmlLevelSet = true;
			}
			if ( !immortalityInitialized )
			{
				SetCanPlayHitAnim( true );
				
				if(isInvulnerable)
				{
					SetImmortalityMode(AIM_Invulnerable, AIC_Default);
				}
				else if(isImmortal)
				{
					SetImmortalityMode(AIM_Immortal, AIC_Default);
				}
				else if( willBeUnconscious )
				{
					SetImmortalityMode(AIM_Unconscious, AIC_Default);
					SignalGameplayEventParamFloat('ChangeUnconsciousDuration',minUnconsciousTime);
				}
				else if ( npcGroupType == ENGT_Commoner || npcGroupType == ENGT_Guard || npcGroupType == ENGT_Quest )
				{
					SetImmortalityMode(AIM_Unconscious, AIC_Default);	
				}
			}
		}
		
		
		if( npcGroupType == ENGT_Guard )
		{
			SetOriginalInteractionPriority( IP_Prio_5 );
			RestoreOriginalInteractionPriority();
		}
		else if( npcGroupType == ENGT_Quest )
		{
			SetOriginalInteractionPriority( IP_Max_Unpushable );
			RestoreOriginalInteractionPriority();
		}
		
		
		
		mac = (CMovingPhysicalAgentComponent)GetMovingAgentComponent();
		if(mac && IsFlying() )
			mac.SetAnimatedMovement( true );
		
		
		RegisterCollisionEventsListener();		
		
		
		if (focusModeSoundEffectType == FMSET_None)
			SetFocusModeSoundEffectType( FMSET_Gray );
		
		heading	= AngleNormalize( GetHeading() );
		
		SetBehaviorVariable( 'requestedFacingDirection', heading );
		
		if ( disableConstrainLookat )
			SetBehaviorVariable( 'disableConstraintLookat', 1.f);
			
		
		SoundSwitch( "vo_3d", 'vo_3d_long', 'head' );
		
		AddAnimEventCallback('EquipItemL' ,							'OnAnimEvent_EquipItemL');
		AddAnimEventCallback('HideItemL' ,							'OnAnimEvent_HideItemL');
		AddAnimEventCallback('HideWeapons' ,						'OnAnimEvent_HideWeapons');
		AddAnimEventCallback('TemporaryOffGround' ,					'OnAnimEvent_TemporaryOffGround');
		AddAnimEventCallback('NullifyBurning' ,						'OnAnimEvent_NullifyBurning');
		AddAnimEventCallback('setVisible' ,							'OnAnimEvent_setVisible');
		AddAnimEventCallback('extensionWalk' ,						'OnAnimEvent_extensionWalk');
		AddAnimEventCallback('extensionWalkNormalSpeed' ,			'OnAnimEvent_extensionWalkNormalSpeed');
		AddAnimEventCallback('extensionWalkRightHandOnly' ,			'OnAnimEvent_extensionWalkRightHandOnly');
		AddAnimEventCallback('extensionWalkStartStopNormalSpeed' ,	'OnAnimEvent_extensionWalkStartStopNormalSpeed');
		AddAnimEventCallback('weaponSoundType' ,					'OnAnimEvent_weaponSoundType');
		AddAnimEventCallback('disableCrowdOverride' ,				'OnAnimEvent_disableCrowdOverride');
		
		if ( IsAnimal() )
		{
			AddAnimEventCallback('OwlSwitchOpen' ,					'OnAnimEvent_OwlSwitchOpen');
			AddAnimEventCallback('OwlSwitchClose' ,					'OnAnimEvent_OwlSwitchClose');
			AddAnimEventCallback('Goose01OpenWings' ,				'OnAnimEvent_Goose01OpenWings');
			AddAnimEventCallback('Goose01CloseWings' ,				'OnAnimEvent_Goose01CloseWings');
			AddAnimEventCallback('Goose02OpenWings' ,				'OnAnimEvent_Goose02OpenWings');
			AddAnimEventCallback('Goose02CloseWings' ,				'OnAnimEvent_Goose02CloseWings');
		}
		
		if( HasTag( 'olgierd_gpl' ) )
		{ 
			AddAnimEventCallback('IdleDown' ,						'OnAnimEvent_IdleDown');
			AddAnimEventCallback('IdleForward' ,					'OnAnimEvent_IdleForward');
			AddAnimEventCallback('IdleCombat' ,						'OnAnimEvent_IdleCombat');
			AddAnimEventCallback('WeakenedState' ,					'OnAnimEvent_WeakenedState');
			AddAnimEventCallback('WeakenedStateOff' ,				'OnAnimEvent_WeakenedStateOff');
			AddAnimEventCallback('SlideAway' ,						'OnAnimEvent_SlideAway');
			AddAnimEventCallback('SlideForward' ,					'OnAnimEvent_SlideForward');
			AddAnimEventCallback('SlideTowards' ,					'OnAnimEvent_SlideTowards');
			AddAnimEventCallback('OpenHitWindow' ,					'OnAnimEvent_WindowManager');
			AddAnimEventCallback('CloseHitWindow' ,					'OnAnimEvent_WindowManager');
			AddAnimEventCallback('OpenCounterWindow' ,				'OnAnimEvent_WindowManager');
			AddAnimEventCallback('BC_Weakened' ,					'OnAnimEvent_PlayBattlecry');
			AddAnimEventCallback('BC_Attack' ,						'OnAnimEvent_PlayBattlecry');
			AddAnimEventCallback('BC_Parry' ,						'OnAnimEvent_PlayBattlecry');
			AddAnimEventCallback('BC_Sign' ,						'OnAnimEvent_PlayBattlecry');
			AddAnimEventCallback('BC_Taunt' ,						'OnAnimEvent_PlayBattlecry');
		}
		else if( HasTag( 'scolopendromorph' ) || HasTag( 'archespor' ) )
		{
			AddAnimEventCallback('SetIsUnderground' ,			'OnAnimEvent_ToggleIsOverground');
			AddAnimEventCallback('SetIsOverground' ,			'OnAnimEvent_ToggleIsOverground');
			AddAnimEventCallback('IdleDown' ,					'OnAnimEvent_IdleDown');
			AddAnimEventCallback('IdleForward' ,				'OnAnimEvent_IdleForward');
			AddAnimEventCallback('CannotBeAttacked' ,			'OnAnimEvent_CannotBeAttacked');
			
			if( HasTag( 'scolopendromorph' ) )
			{
				ToggleIsOverground( false );
			}
		}
		else if( HasTag( 'dettlaff_vampire' ) )
		{
			AddAnimEventCallback('OpenHitWindow' ,					'OnAnimEvent_WindowManager');
			AddAnimEventCallback('CloseHitWindow' ,					'OnAnimEvent_WindowManager');
			AddAnimEventCallback('OpenCounterWindow' ,				'OnAnimEvent_WindowManager');
			AddAnimEventCallback('SlideAway' ,						'OnAnimEvent_SlideAway');
			AddAnimEventCallback('SlideForward' ,					'OnAnimEvent_SlideForward');
			AddAnimEventCallback('WeakenedState' ,					'OnAnimEvent_WeakenedState');
			AddAnimEventCallback('WeakenedStateOff' ,				'OnAnimEvent_WeakenedStateOff');
		}
		else if( HasTag( 'fairytale_witch' ) )
		{
			AddAnimEventCallback('CauldronDropped' ,				'OnAnimEvent_CauldronDropped');
			AddAnimEventCallback('OpenHitWindow' ,					'OnAnimEvent_WindowManager');
			AddAnimEventCallback('CloseHitWindow' ,					'OnAnimEvent_WindowManager');
		}
		else if( HasTag( 'fairytaleWitchBroom' ) )
		{
			AddAnimEventCallback('BroomDeath' ,						'OnAnimEvent_BroomDeath');
		}
		else if( HasTag( 'q703_ofir_mage' ) )
		{
			AddAnimEventCallback('ActivateSide' ,					'OnAnimEvent_ActivateSide');
			AddAnimEventCallback('ActivateUp' ,						'OnAnimEvent_ActivateUp');
		}
		else if ( HasTag( 'q703_dolphin' ) )
		{
			AddAnimEventCallback('DeactivateSide' ,					'OnAnimEvent_DeactivateSide');
			AddAnimEventCallback('DeactivateUp' ,					'OnAnimEvent_DeactivateUp');
		}
		else if ( HasAbility( 'mon_vampiress_base' ) )
		{
			AddAnimEventCallback('bruxa_jump_failsafe' , 			'OnAnimEvent_BruxaJumpFailsafe' );
		}
		else if ( HasAbility( 'mon_werewolf_base' ) )
		{
			AddAnimEventCallback('ResetOneTimeSpawnActivation' , 	'OnAnimEvent_ResetOneTimeSpawnActivation' );
		}
		
		if( HasAbility( 'NoShadows' ) )
		{
			SetGroupShadows( false );
		}
		
		if(HasAbility('_canBeFollower') && theGame.GetDifficultyMode() != EDM_Hardcore) 
			RemoveAbility('_canBeFollower');
		
		
		//modSigns: fake levels are removed, no more dancing around fake bonuses is needed
		//do nod add NG+ level for Ciri
		if( !HasAbility('NoAdaptBalance') && !((W3ReplacerCiri)thePlayer) )
		{
			if( theGame.IsActive() )
			{
				if( ( ( FactsQuerySum("NewGamePlus") > 0 ) && !HasTag('animal') ) ) //all but animals
				{
					//modSigns: NGP upscale
					if( !HasAbility('NPCDoNotGainBoost') )
					{
						currentLevel += theGame.params.GetNewGamePlusLevel();
					}
				}
			}	
		}		
		//modSigns: just in case
		levelFakeAddon = 0;
		newGamePlusFakeLevelAddon = false;
	}
	
	protected function SetAbilityManager()
	{
		if(npcGroupType != ENGT_Commoner)
			abilityManager = new W3NonPlayerAbilityManager in this;		
	}
	
	protected function SetEffectManager()
	{
		if(npcGroupType != ENGT_Commoner)
			super.SetEffectManager();
	}
	
	public function  SetLevel ( _level : int )
	{
		currentLevel = _level;
		levelBonusesComputedAtPlayerLevel = -1;
		AddTimer('AddLevelBonuses', 0.1, true, false, , true);
	}
	
	private function SetThreatLevel()
	{
		var temp : float;
		
		temp = CalculateAttributeValue(GetAttributeValue('threat_level'));
		if ( temp >= 0.f )
		{
			threatLevel = (int)temp;
		}
		else
		{
			LogAssert(false,"No threat_level attribute set. Threat level set to 0");
			threatLevel = 0;
		}
	}
	public function ChangeThreatLevel( newValue : int )
	{
		threatLevel = newValue;
	}
	
	
	public function SetNpcHealthBar()
	{
		npc_health_bar = GetHealthPercents();
		SoundParameter( 'npc_health_bar', npc_health_bar, 'all' );
	}
	
	public function GetNpcHealthBar() : float
	{
		return npc_health_bar;
	}
	
	 public function GetHorseUser() : CActor
	{
		if( horseComponent )
		{
			return horseComponent.GetCurrentUser();
		}
		
		return NULL;
	}
	


	
	
	
	
	public function GetPreferedCombatStyle() : EBehaviorGraph
	{
		return preferedCombatStyle;
	}
	
	public function SetPreferedCombatStyle( _preferedCombatStyle : EBehaviorGraph )
	{
		preferedCombatStyle = _preferedCombatStyle;
	}
	
	
	timer function WeatherBonusCheck(dt : float, id : int)
	{
		var curGameTime : GameTime;
		var dayPart : EDayPart;
		var bonusName : name;
		var curEffect : CBaseGameplayEffect;
		var moonState : EMoonState;
		var weather : EWeatherEffect;
		var params : SCustomEffectParams;
		
		if ( !IsAlive() )
		{
			return;
		}
		
		moonState = GetCurMoonState();
		
		curGameTime = GameTimeCreate();
		dayPart = GetDayPart(curGameTime);
		
		weather = GetCurWeather();
		
		bonusName = ((W3NonPlayerAbilityManager)abilityManager).GetWeatherBonus(dayPart, weather, moonState);
		
		curEffect = GetBuff(EET_WeatherBonus);
		if (curEffect)
		{
			if ( curEffect.GetAbilityName() == bonusName )
			{
				return;
			}
			else
			{
				RemoveBuff(EET_WeatherBonus);
			}
		}
		
		if (bonusName != 'None')
		{
			params.effectType = EET_WeatherBonus;
			params.creator = this;
			params.sourceName = "WeatherBonus";
			params.customAbilityName = bonusName;
			AddEffectCustom(params);
		}
	}
	
	public function IsFlying() : bool
	{
		var result : bool;
		result = ( this.GetCurrentStance() == NS_Fly );
		return result;
	}
	
	public function IsRanged() : bool
	{
		var weapon : SItemUniqueId;
		var weapon2 : SItemUniqueId;
		
		if( HasAbility( 'Ranged' ) )
		{
			return true;
		}
		
		weapon = this.GetInventory().GetItemFromSlot( 'l_weapon' );
		weapon2 = this.GetInventory().GetItemFromSlot( 'r_weapon' );
		
		return ( this.GetInventory().GetItemCategory( weapon ) == 'bow' || this.GetInventory().GetItemCategory( weapon2 ) == 'crossbow' );
		
	}
	
	
	
	public function IsVisuallyOffGround() : bool
	{
		if( isTemporaryOffGround ) 
			return true;
		if( IsFlying() ) 
			return true;
			
		return false;
	}

	public function SetIsHorse()
	{
		if ( horseComponent )
			isHorse = true;
	}
	
	public function IsHorse() : bool
	{
		return isHorse;
	}
	
	public function GetHorseComponent() : W3HorseComponent
	{
		if ( isHorse )
			return horseComponent;
		else
			return NULL;
	}
	
	public function HideHorseAfter( time : float )
	{
		if( !isHorse )
			return;
		
		SetVisibility( false );
		SetGameplayVisibility( false );
		
		AddTimer( 'HideHorse', time );
	}
	
	private timer function HideHorse( delta : float , id : int )
	{
		Teleport( thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1000.0 );
		
		SetVisibility( true );
		SetGameplayVisibility( true );
	}
	
	public function KillHorseAfter( time : float )
	{
		if( !isHorse )
			return;
		AddTimer( 'KillHorse', time );
	}
	
	private timer function KillHorse( delta : float , id : int )
	{
		SetKinematic( false );
		Kill( 'KillHorse', true );
		SetAlive( false );
		GetComponentByClassName( 'CInteractionComponent' ).SetEnabled( false );
		PlayEffect( 'hit_ground' );
	}
	
	public timer function RemoveAxiiFromHorse( delta : float , id : int )
	{
		RemoveAbility( 'HorseAxiiBuff' );
	}
	
	public function ToggleCanFlee( val : bool ) { canFlee = val; }
	public function GetCanFlee() : bool 		{ return canFlee; }
	
	public function SetIsFallingFromHorse( val : bool ) 		
	{ 
		if( val )
		{
			AddBuffImmunity( EET_HeavyKnockdown, 'SetIsFallingFromHorse', true );
			isFallingFromHorse = true;
		}
		else
		{
			RemoveBuffImmunity( EET_HeavyKnockdown, 'SetIsFallingFromHorse' );
			isFallingFromHorse = false;
		}
	}
	public function GetIsFallingFromHorse() : bool 				{ return isFallingFromHorse; }
	
	public function SetCounterWindowStartTime(time : EngineTime)	{counterWindowStartTime = time;}
	public function GetCounterWindowStartTime() : EngineTime		{return counterWindowStartTime;}
	
	
	function GetThreatLevel() : int
	{
		return threatLevel;
	}
	
	function GetSoundValue() : int
	{
		return soundValue;
	}
		
	public function WasTauntedToAttack()
	{
		tauntedToAttackTimeStamp = theGame.GetEngineTimeAsSeconds();
	}
	
	
	
	timer function MaintainSpeedTimer( d : float , id : int)
	{
		this.SetBehaviorVariable( 'Editor_MovementSpeed', 0 );
	}
	timer function MaintainFlySpeedTimer( d : float , id : int)
	{
		this.SetBehaviorVariable( 'Editor_FlySpeed', 0 );
	}
	
	
	
	
	public function SetIsInHitAnim( toggle : bool )
	{
		bIsInHitAnim = toggle;
		if ( !toggle )
			this.SignalGameplayEvent('WasHit');
	}
	
	public function IsInHitAnim() : bool
	{
		return bIsInHitAnim;
	}
	
	public function CanChangeBehGraph() : bool
	{
		return allowBehGraphChange;
	}
	
	public function WeaponSoundType() : CItemEntity
	{
		var weapon : SItemUniqueId;
		weapon = GetInventory().GetItemFromSlot( 'r_weapon' );
		
		return GetInventory().GetItemEntityUnsafe(weapon);
	}

	
	
	
	function EnableCounterParryFor( time : float )
	{
		bCanPerformCounter = true;
		AddTimer('DisableCounterParry',time,false);
	}
	
	timer function DisableCounterParry( td : float , id : int)
	{
		bCanPerformCounter = false;
	}
	
	var combatStorage : CBaseAICombatStorage;
	
	public final function IsAttacking() : bool
	{
		if ( !combatStorage )
			combatStorage = (CBaseAICombatStorage)GetScriptStorageObject('CombatData');
			
		if(combatStorage)
		{
			return combatStorage.GetIsAttacking();
		}
		
		return false;
	}
		
	public final function RecalcLevel()
	{
		if(!IsAlive())
			return;
			
		AddLevelBonuses(0, 0);
	}
	
	
	protected function PerformCounterCheck(parryInfo: SParryInfo) : bool
	{
		return false;
	}
	
	
	protected function PerformParryCheck(parryInfo : SParryInfo) : bool
	{
		var mult : float;
		var isHeavy : bool;
		var npcTarget : CNewNPC;
		var fistFightParry : bool;
		
		if ( !parryInfo.canBeParried )
			return false;
		
		if( this.IsHuman() && ((CHumanAICombatStorage)this.GetScriptStorageObject('CombatData')).IsProtectedByQuen() )
			return false;
		if( !CanParryAttack() )
			return false;
		if( !FistFightCheck(parryInfo.target, parryInfo.attacker, fistFightParry) )
			return false;
		if( IsInHitAnim() && HasTag( 'imlerith' ) )
			return false;	
		
		npcTarget = (CNewNPC)parryInfo.target;
		
		if( npcTarget.IsShielded(parryInfo.attacker) || ( !npcTarget.HasShieldedAbility() && parryInfo.targetToAttackerAngleAbs < 90 ) || (  npcTarget.HasTag( 'olgierd_gpl' ) && parryInfo.targetToAttackerAngleAbs < 120 ) )
		{	
			isHeavy = IsHeavyAttack(parryInfo.attackActionName);
						
			
			if( HasStaminaToParry( parryInfo.attackActionName ) && ( HasAbility( 'ablParryHeavyAttacks' ) || !isHeavy ) )
			{
				
				SetBehaviorVariable( 'parryAttackType', (int)PAT_Light );
				
				if( isHeavy )
					SignalGameplayEventParamInt( 'ParryPerform', 1 );
				else
					SignalGameplayEventParamInt( 'ParryPerform', 0 );
			}
			else
			{
				
				SetBehaviorVariable( 'parryAttackType', (int)PAT_Heavy );
			
				if( isHeavy )
					SignalGameplayEventParamInt( 'ParryStagger', 1 );
				else
					SignalGameplayEventParamInt( 'ParryStagger', 0 );
			}
			
			if( parryInfo.attacker == thePlayer && parryInfo.attacker.IsWeaponHeld( 'fist' ) && !parryInfo.target.IsWeaponHeld( 'fist' ) )
			{
				parryInfo.attacker.SetBehaviorVariable( 'reflectAnim', 1.f );
				parryInfo.attacker.ReactToReflectedAttack(this);				
			}
			else 
			{
				if( isHeavy )
				{
					ToggleEffectOnShield( 'heavy_block', true );
				}
				else
				{
					ToggleEffectOnShield( 'light_block', true );
				}
			}
			
			return true;
		}		
		
		return false;
	}
		
	public function GetTotalSignSpellPower(signSkill : ESkill) : SAbilityAttributeValue
	{		
		return GetPowerStatValue(CPS_SpellPower);
	}
	
	 event OnProcessActionPost(action : W3DamageAction)
	{
		var actorVictim : CActor;
		var time, maxTox, toxToAdd : float;
		var gameplayEffect : CBaseGameplayEffect;
		var template : CEntityTemplate;
		var fxEnt : CEntity;
		var toxicity : SAbilityAttributeValue;
		
		super.OnProcessActionPost(action);
		
		
		actorVictim = (CActor)action.victim;
		if(HasBuff(EET_AxiiGuardMe) && (GetWitcherPlayer().HasGlyphwordActive('Glyphword 14 _Stats') || GetWitcherPlayer().HasGlyphwordActive('Glyphword 18 _Stats')) && action.DealtDamage()) //modSigns
		{
			time = CalculateAttributeValue(thePlayer.GetAttributeValue('increas_duration'));
			gameplayEffect = GetBuff(EET_AxiiGuardMe);
			gameplayEffect.SetTimeLeft( gameplayEffect.GetTimeLeft() + time );
			
			template = (CEntityTemplate)LoadResource('glyphword_10_18');
			
			if(GetBoneIndex('head') != -1)
			{				
				fxEnt = theGame.CreateEntity(template, GetBoneWorldPosition('head'), GetWorldRotation(), , , true);
				fxEnt.CreateAttachmentAtBoneWS(this, 'head', GetBoneWorldPosition('head'), GetWorldRotation());
			}
			else
			{
				fxEnt = theGame.CreateEntity(template, GetBoneWorldPosition('k_head_g'), GetWorldRotation(), , , true);
				fxEnt.CreateAttachmentAtBoneWS(this, 'k_head_g', GetBoneWorldPosition('k_head_g'), GetWorldRotation());
				
			}
			
			fxEnt.PlayEffect('axii_extra_time');
			fxEnt.DestroyAfter(5);
		}
		
		
		if( action.victim && action.victim == GetWitcherPlayer() && action.DealtDamage() )
		{
			toxicity = GetAttributeValue( 'toxicity_increase_on_hit' );
			if( toxicity.valueAdditive > 0.f || toxicity.valueMultiplicative > 0.f )
			{
				maxTox = GetWitcherPlayer().GetStatMax( BCS_Toxicity );
				toxToAdd = maxTox * toxicity.valueMultiplicative + toxicity.valueAdditive;
				GetWitcherPlayer().GainStat( BCS_Toxicity, toxToAdd );
			}
		}
	}
	
	protected function PrepareAttackAction( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity, out attackAction : W3Action_Attack) : bool
	{
		var containedAbs, abs, tmp : array< name >;
		var i : int;
		var ret : bool;
		var effectType : EEffectType;
		var customAbilityName : name;
		
		ret = super.PrepareAttackAction( hitTarget, animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime, weaponEntity, attackAction );
		
		
		GetCharacterStats().GetAbilities( abs, false );
		for( i=0; i<abs.Size(); i+=1 )
		{
			theGame.GetDefinitionsManager().GetContainedAbilities( abs[i], tmp );
			ArrayOfNamesAppendUnique( containedAbs, tmp );
			tmp.Clear();
		}		
		
		for( i=0; i<containedAbs.Size(); i+=1 )
		{
			EffectNameToType( containedAbs[i], effectType, customAbilityName );
			
			if( effectType == EET_ToxicityVenom )
			{
				attackAction.AddEffectInfo( effectType, , GetAttributeValue( 'toxicityVenom' ) );
				break;
			}
		}
		
		return ret;
	}
	
	// Triangle modSigns resists
	function RemoveLevelResistances()
	{
		var dmgNames : array<name>;
		var magicNames : array<name>;
		var i : int;
		TUtil_GetLvlResistanceAbilityNames(dmgNames, magicNames);
		for (i = 0; i < dmgNames.Size(); i += 1) {
			RemoveAbilityAll(dmgNames[i]);
		}
		for (i = 0; i < magicNames.Size(); i += 1) {
			RemoveAbilityAll(magicNames[i]);
		}
	}

	// Triangle modSigns resists
	function AddLevelResistances(lvl : int, enemyBonusType : name)
	{
		var dmgNames, magicNames : array<name>;
		var dmgResist, magicResist : float;
		var dmgCount, magicCount, i : int;
		TOpts_GetLvlResistances(enemyBonusType, dmgResist, magicResist);
		dmgCount = RoundMath(dmgResist * 4);
		magicCount = RoundMath(magicResist * 4);
		TUtil_GetLvlResistanceAbilityNames(dmgNames, magicNames);
		for (i = 0; i < dmgNames.Size(); i += 1) {
			AddAbilityMultiple(dmgNames[i], dmgCount * lvl);
		}
		for (i = 0; i < magicNames.Size(); i += 1) {
			AddAbilityMultiple(magicNames[i], magicCount * lvl);
		}
	}
	
	//modSigns: remove level bonuses
	function RemoveAllLevelBonuses()
	{
		var savedHealthPerc : float;
		
		//modSigns specific
		savedHealthPerc = GetHealthPercents();
		RemoveAbilityAll('ModSignsAdditionalEssence');
		RemoveAbilityAll('ModSignsAdditionalVitality');
		RemoveAbilityAll('ModSignsAdditionalEssenceNegative');
		RemoveAbilityAll('ModSignsAdditionalVitalityNegative');
		RemoveAbilityAll('ModSignsMaxHealthNegative');
		if(GetStat( BCS_Vitality, true ) > 0)
		{
			UpdateStatMax(BCS_Vitality);
			ForceSetStat(BCS_Vitality, MaxF(1, GetStatMax(BCS_Vitality)*savedHealthPerc));
		}
		else
		{
			UpdateStatMax(BCS_Essence);
			ForceSetStat(BCS_Essence, MaxF(1, GetStatMax(BCS_Essence)*savedHealthPerc));
		}
		//level up specific
		if ( HasAbility(theGame.params.ENEMY_BONUS_DEADLY) )
		{
			RemoveAbility(theGame.params.ENEMY_BONUS_DEADLY);
			RemoveBuffImmunity(EET_Blindness, 'DeadlyEnemy');
			RemoveBuffImmunity(EET_WraithBlindness, 'DeadlyEnemy');
		}
		if ( HasAbility(theGame.params.ENEMY_BONUS_HIGH) )
		{
			RemoveAbility(theGame.params.ENEMY_BONUS_HIGH);
		}
		if ( HasAbility(theGame.params.ENEMY_BONUS_LOW) )
		{
			RemoveAbility(theGame.params.ENEMY_BONUS_LOW);
		}
		if ( HasAbility(theGame.params.MONSTER_BONUS_DEADLY) )
		{
			RemoveAbility(theGame.params.MONSTER_BONUS_DEADLY);
			RemoveBuffImmunity(EET_Blindness, 'DeadlyEnemy');
			RemoveBuffImmunity(EET_WraithBlindness, 'DeadlyEnemy');
		}
		if ( HasAbility(theGame.params.MONSTER_BONUS_HIGH) )
		{
			RemoveAbility(theGame.params.MONSTER_BONUS_HIGH);
		}
		if ( HasAbility(theGame.params.MONSTER_BONUS_LOW) )
		{
			RemoveAbility(theGame.params.MONSTER_BONUS_LOW);
		}
		RemoveAbilityAll(theGame.params.ENEMY_BONUS_PER_LEVEL);
		RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED);
		RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED);
		RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP);
		RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL);
		//Ciri specific
		if ( HasAbility('CiriHardcoreDebuffHuman') )
		{
			RemoveAbility('CiriHardcoreDebuffHuman');
		}
		if ( HasAbility('CiriHardcoreDebuffMonster') )
		{
			RemoveAbility('CiriHardcoreDebuffMonster');
		}
		RemoveLevelResistances(); // Triangle modSigns resists
	}
	
	function CheckConstitutionAbility() //modSigns: fix multiple constitution abilities
	{
		if( HasAbility('ConAthletic') && HasAbility('ConDefault') )
		{
			RemoveAbility('ConDefault');
		}
	}
	
	function ModSignsAddBonuses() //modSigns: additional menu configurable bonuses
	{
		var ablNum : int;
		var savedHealthPerc : float;
		
		savedHealthPerc = GetHealthPercents();
		//add more health based on menu settings
		if(theGame.params.GetEnemyHealthMult() > 0)
		{
			ablNum = RoundMath(theGame.params.GetEnemyHealthMult() * 10);
			if(GetStat( BCS_Vitality, true ) > 0)
				AddAbilityMultiple('ModSignsAdditionalVitality', ablNum);
			else
				AddAbilityMultiple('ModSignsAdditionalEssence', ablNum);
		}
		else if(theGame.params.GetEnemyHealthMult() < 0)
		{
			ablNum = RoundMath(-1 * theGame.params.GetEnemyHealthMult() * 10);
			if(ablNum > 9)
				AddAbility('ModSignsMaxHealthNegative');
			else if(GetStat( BCS_Vitality, true ) > 0)
				AddAbilityMultiple('ModSignsAdditionalVitalityNegative', ablNum);
			else
				AddAbilityMultiple('ModSignsAdditionalEssenceNegative', ablNum);
		}
		if(GetStat( BCS_Vitality, true ) > 0)
		{
			UpdateStatMax(BCS_Vitality);
			ForceSetStat(BCS_Vitality, MaxF(1, GetStatMax(BCS_Vitality)*savedHealthPerc));
		}
		else
		{
			UpdateStatMax(BCS_Essence);
			ForceSetStat(BCS_Essence, MaxF(1, GetStatMax(BCS_Essence)*savedHealthPerc));
		}
	}
	
	var fistFightForcedFromQuest : bool; 
	
	// Triangle whirl
	public function StunLocked() : bool
	{
		return stunLocked;
	}

	// Triangle whirl
	public function StunLock(seconds : float, optional speedMod : float)
	{
		stunLocked = true;
		if (speedMod > 0) {
			PushBaseAnimationMultiplierCauser(speedMod,, 'stunlock');
		}
		AddTimer('StunUnlock', seconds,,,,,true);
	}

	// Triangle whirl
	timer function StunUnlock(delta : float, id : int)
	{
		ResetBaseAnimationMultiplierCauserBySrc('stunlock');
		stunLocked = false;
	}

	// Triangle level scaling
	public function LinearInterpolate ( playerLevel : int, opponentLevel : int, t : float) : float
	{
		return t * playerLevel + (1 - t) * opponentLevel;
	}

	// Triangle level scaling recalculate enemy level with scaling options. Called when level is set via SetLevel only!
	public function CalculateLevel () : int
	{
		var newLevel, playerLevel, opponentLevel, levelJitter : int;

		playerLevel = thePlayer.GetLevel();
		opponentLevel = originalLevel;
		newLevel = opponentLevel;

		// Just in case!
		if (!TOpts_AreLevelOptionsEnabled())
			return newLevel;

		if (thePlayer.IsCiri())
			return newLevel;

		if (TOpts_DontScaleAnimals() && ( GetSfxTag() == 'sfx_wolf' || HasAbility('mon_boar_base') || IsAnimal() ))
			return newLevel;

		// Moved guard stuff from addlevelbonuses for consistency elsewhere, and so we can scale them
		// Disabling this for now since it looks like it was removed in a patch
		// if (GetNPCType() == ENGT_Guard)
		// {
		// 	opponentLevel = thePlayer.GetLevel() + 13;
		// 	newLevel = opponentLevel;
		// }

		if (TOpts_IsUpscalingOn() && opponentLevel < playerLevel)
		{
			newLevel = (int)RoundMath(LinearInterpolate(playerLevel, opponentLevel, TOpts_UpscalingFactor()));
		}
		else if (TOpts_IsDownscalingOn() && opponentLevel > playerLevel)
		{
			newLevel = (int)RoundMath(LinearInterpolate(playerLevel, opponentLevel, TOpts_DownscalingFactor()));
		}

		newLevel += TOpts_FlatLevelBonus();

		levelJitter = TOpts_LevelJitter();
		if (levelJitter != prevJitterOption)
		{
			if (levelJitter > 0)
				cachedJitter = RandRange(levelJitter*2) - levelJitter;
			else
				cachedJitter = 0;

			prevJitterOption = levelJitter;
		}
		newLevel += cachedJitter;

		return newLevel;
	}

	// Triangle enemy mutations armor scaling
	public function GetTotalArmor() : SAbilityAttributeValue
	{
		var totalArmor : SAbilityAttributeValue;
		var stats : CCharacterStats;
		stats = GetCharacterStats();
		totalArmor = super.GetTotalArmor();
		// NOTE I use valueBase so that melt armor and other multiplier based armor reducers work as expected
		// Triangle armor scaling
		if (UsesVitality())
			totalArmor.valueBase *= 1 + TOpts_ArmorPerLevelHuman() * GetLevel();
		else if (UsesEssence()) {
			totalArmor.valueBase *= 1 + TOpts_ArmorPerLevelMonster() * GetLevel();
			totalArmor.valueBase *= 1 + TOpts_ArmorPerScaledLevelMonster() * (GetLevel() - GetLevelFromLocalVar());
		}
		if (totalArmor.valueBase > 0) {
			totalArmor.valueBase += TOpts_FlatArmorPerLevel() * GetLevel();
		}
		// Triangle enemy mutations
		// Note that this will make non-armored type enemies look like armored types in some parts of the code. use super class' method for those bits
		if (stats.HasAbility(TUtil_TEMutationEnumToName(TEM_Tough))) {
			totalArmor.valueBase += TOpts_ToughArmorPerLevel() * GetLevel();
		}
		// Triangle end
		return totalArmor;
	}

	// Triangle level scaling Not currently using this anymore. I know I should delete dead code, but eeehh
	private function AddRemoveAbilityMultiple(abilityName : name, count : int)
	{
		if (count > 0)
			AddAbilityMultiple(abilityName, count);
		else if (count < 0)
			RemoveAbilityMultiple(abilityName, count);
	}

	// Triangle enemy mutations
	public function GetMutatedDisplayName() : string
	{
		return GetExtPrefixString() + TUtil_GetMutatedPrefix(this) + GetDisplayName();
	}

	// Triangle spell sword, protective coating
	public function AddPrefix(prefix : string, sourceName : string) {
		var prefEntry : ExtPrefixEntry;
		prefEntry.prefix = prefix;
		prefEntry.sourceName = sourceName;
		extPrefixes.PushBack(prefEntry);
	}

	// Triangle spell sword, protective coating
	public function RemovePrefix(sourceName : string, optional prefix : string) {
		var i : int;
		for (i = extPrefixes.Size() - 1; i >= 0; i -= 1) {
			if (extPrefixes[i].sourceName == sourceName && (!prefix || extPrefixes[i].prefix == prefix)) {
				extPrefixes.Erase(i);
				break;
			}
		}
	}

	// Triangle spell sword
	public function GetExtPrefixString() : string
	{
		var i : int;
		var prefix : string;
		prefix = "";
		for (i = 0; i < extPrefixes.Size(); i += 1) {
			prefix += extPrefixes[i].prefix + " ";
		}
		return prefix;
	}

	// Triangle enemy mutations
	timer function PlayElectricity(delta : float, id : int)
	{
		PlayEffect('yrden_shock');
		AddTimer('PlayElectricity', 0.5 + RandF());
	}

	// Triangle enemy mutations
	timer function FlameOn(delta : float, id : int)
	{
		var params : SCustomEffectParams;
		var specificParams : W3TFireAuraCustomParams;
		if (IsAlive() && !HasBuff(EET_TFireAura)) {
			params.effectType = EET_TFireAura;
			params.creator = this;
			params.sourceName = TUtil_TEMutationEnumToName(TEM_Flaming);
			params.duration = -1; // Will fail if you don't set this! Pretty dumb
			specificParams = new W3TFireAuraCustomParams in theGame;
			specificParams.range = TOpts_FlamingRange();
			specificParams.burningDuration = 1;
			params.buffSpecificParams = specificParams;
			AddEffectCustom(params);
		}
	}

	// Triangle enemy mutations
	timer function FreezeOn(delta : float, id : int)
	{
		var params : SCustomEffectParams;
		var specificParams : W3TFreezingAuraCustomParams;
		if (IsAlive() && !HasBuff(EET_TFreezingAura)) {
			params.effectType = EET_TFreezingAura;
			params.creator = this;
			params.sourceName = TUtil_TEMutationEnumToName(TEM_Freezing);
			params.duration = -1; // Will fail if you don't set this! Pretty dumb
			specificParams = new W3TFreezingAuraCustomParams in theGame;
			specificParams.range = TOpts_FreezingRange();
			specificParams.freezingDuration = 1;
			params.buffSpecificParams = specificParams;
			AddEffectCustom(params);
		}
	}

	// Triangle enemy mutations
	timer function HypnoOn(delta : float, id : int)
	{
		var params : SCustomEffectParams;
		var specificParams : W3THypnoAuraCustomParams;
		if (IsAlive() && !HasBuff(EET_THypnoAura)) {
			params.effectType = EET_THypnoAura;
			params.creator = this;
			params.sourceName = TUtil_TEMutationEnumToName(TEM_Hypnotic);
			params.duration = -1; // Will fail if you don't set this! Pretty dumb
			specificParams = new W3THypnoAuraCustomParams in theGame;
			specificParams.range = TOpts_HypnoticRange();
			specificParams.hypnoDuration = 0.25;
			params.buffSpecificParams = specificParams;
			AddEffectCustom(params);
		}
	}

	// Triangle enemy mutations
	timer function InspireOn(delta : float, id : int)
	{
		if (IsAlive() && !HasBuff(EET_TInspiringAura)) {
			AddEffectDefault(EET_TInspiringAura, this, TUtil_TEMutationEnumToName(TEM_Inspiring));
		}
	}

	// Triangle enemy mutations
	function StartResilientRegen()
	{
		var stats : CCharacterStats;
		stats = GetCharacterStats();
		stats.RemoveAbilityAll(TUtil_TEMutationEnumToName(TEM_Resilient));
		// This might be woefully inefficient but I haven't noticed any problems yet
		stats.AddAbilityMultiple(TUtil_TEMutationEnumToName(TEM_Resilient), TOpts_ResilientRegenPerLevel() * GetLevel());
		AddTimer('EndResilientRegen', TOpts_ResilientDuration());
	}

	// Triangle enemy mutations
	function EndResilientRegen(delta : float, id : int)
	{
		GetCharacterStats().RemoveAbilityAll(TUtil_TEMutationEnumToName(TEM_Resilient));
	}
	
	// Triangle enemy mutations
	var explosionMutationTriggered : bool; default explosionMutationTriggered = false;
	timer function ExplodeMutation(dt : float, id : int)
	{
		var targets : array< CGameplayEntity >;
		var ent : CEntity;
		var i : int;
		var returnedAction : W3DamageAction;
		var damage : float;
		var powerMod : SAbilityAttributeValue;

		StopEffect('critical_burning');
		if (IsAlive()) {
			AddTimer('AardDismemberForce',0);
			SoundEvent('monster_rotfiend_explode');
			ent = theGame.CreateEntity((CEntityTemplate)LoadResource('rotfiend_explode'), GetWorldPosition(), GetWorldRotation());
			ent.DestroyAfter(5);
			FindGameplayEntitiesInSphere(targets, GetWorldPosition() + Vector(0,0,0.1f), TOpts_ExplosiveRange(), 1000, '', FLAG_TestLineOfSight);
			for(i = 0; i < targets.Size(); i += 1) {
				if (this != targets[i] && IsRequiredAttitudeBetween(this, targets[i], true, true, true)) {
					returnedAction = new W3DamageAction in this;
					returnedAction.Initialize( this, targets[i], NULL, 'TEM_Explode', EHRT_None, CPS_AttackPower, true, false, false, false );
					returnedAction.SetCannotReturnDamage( true );
					returnedAction.AddEffectInfo(EET_LongStagger);
					returnedAction.SetProcessBuffsIfNoDamage(true);
					
					// NOTE: Damage bonus from levels are in base attack power. It will get added again later (since this uses attack power), but only after
					// processing difficulty multiplier (fun fact, it's not actually a 'final' damage multiplier), so I double count it here.
					powerMod = GetPowerStatValue(CPS_AttackPower,,true);
					damage = TOpts_ExplosiveBaseDamage() + powerMod.valueBase;

					if (UsesEssence()) {
						returnedAction.AddDamage(theGame.params.DAMAGE_NAME_RENDING, damage);
					} else {
						returnedAction.AddDamage(theGame.params.DAMAGE_NAME_BLUDGEONING, damage);
					}
					
					theGame.damageMgr.ProcessAction(returnedAction);
					delete returnedAction;
				}
			}
			Kill('TEM_Explode', false, thePlayer);
		}
	}

	// Triangle enemy mutations
	saved var isHuge : bool; default isHuge = false; // For ragdoll stuff
	function ProcessHugeMutationSize()
	{
		var animComp : CComponent;
		var scaleFactor : float;
		if (!isHuge)
			return;
		animComp = ((CEntity)this).GetComponentByClassName('CAnimatedComponent');
		if (animComp) {
			scaleFactor = TOpts_HugeScaleFactor();
			animComp.SetScale(Vector(scaleFactor, scaleFactor, scaleFactor, 1));
		}
	}

	// Triangle enemy mutations
	public function ProcessMutations()
	{
		var animComp : CComponent;
		var scaleFactor, healthPerc : float;
		var stats : CCharacterStats;
		var effectParams : SCustomEffectParams;

		stats = GetCharacterStats();

		if (stats.HasAbility(TUtil_TEMutationEnumToName(TEM_Huge))) {
			isHuge = true;
			ProcessHugeMutationSize();
			healthPerc = GetHealthPercents();
			scaleFactor = TOpts_HugeScaleFactor();
			abilityManager.UpdateStatMaxWrapper(TUtil_GetHealthType(this));
			SetHealthPerc(healthPerc);
			stats.AddAbility('mon_type_huge');
		}
		if (stats.HasAbility(TUtil_TEMutationEnumToName(TEM_Quick))) {
			PushBaseAnimationMultiplierCauser(1 + TOpts_QuickSpeedBonus(),, TUtil_TEMutationEnumToName(TEM_Quick));
		}
		if (stats.HasAbility(TUtil_TEMutationEnumToName(TEM_Flaming))) {
			AddTimer('FlameOn', 0);
		}
		if (stats.HasAbility(TUtil_TEMutationEnumToName(TEM_Freezing))) {
			AddTimer('FreezeOn', 0);
		}
		if (stats.HasAbility(TUtil_TEMutationEnumToName(TEM_Hypnotic))) {
			AddTimer('HypnoOn',0);
		}
		if (stats.HasAbility(TUtil_TEMutationEnumToName(TEM_Inspiring))) {
			AddTimer('InspireOn',0);
		}
	}

	// Triangle hp mods
	function HPModifier() : float
	{
		var modifier : float;
		var healthType : EBaseCharacterStats;
		var stats : CCharacterStats;
		stats = GetCharacterStats();
		healthType = TUtil_GetHealthType(this);
		if ((stats.HasAbilityWithTag('T_questmonster') || stats.HasAbilityWithTag('Boss') || HasAbility('Boss') || HasAbility('SkillBoss')) && TOpts_QuestBossHealthMod() > 0) {
			modifier = TOpts_QuestBossHealthMod();
		} else if (healthType == BCS_Essence) {
			modifier = TOpts_EssenceHealthMod();
		} else {
			modifier = TOpts_VitalityHealthMod();
		}
		if (stats.HasAbility(TUtil_TEMutationEnumToName(TEM_Huge))) {
			modifier *= TOpts_HugeScaleFactor() * TOpts_HugeScaleFactor();
		}
		if (modifier <= 0)
			modifier = 1;
		return modifier;
	}

	// Triangle hp mods
	function ProcessHPOptions()
	{
		var healthPerc : float;
		healthPerc = GetHealthPercents();
		abilityManager.UpdateStatMaxWrapper(TUtil_GetHealthType(this));
		SetHealthPerc(healthPerc);
	}

	// Triangle level scaling add level bonuses with TMod options
	timer function AddLevelBonuses (dt : float, id : int)
	{
		var ciriEntity  		: W3ReplacerCiri;
		var ignoreLowLevelCheck : bool;
		var lvlDiff 			: int;
		var npcLevel 			: int;
		var ngpLevel 			: int;
		var i 					: int;
		var playerLevel			: int;
		var stats				: CCharacterStats;
		var npcGroupType		: ENPCGroupType;
		
		RemoveTimer( 'AddLevelBonuses' );
		
		//modSigns: dlc7 nekker warrior level fix
		if( HasTag('sq107_monster_heavy') ) currentLevel = 8;
		
		RemoveAllLevelBonuses(); //remove all previously added bonuses

		//debug
		//theGame.witcherLog.AddMessage( GetDisplayName() + " cur lvl = " + currentLevel );
		//theGame.witcherLog.AddMessage( GetDisplayName() + " abl lvl = " + ((int)CalculateAttributeValue(GetAttributeValue('level',,true))) );
		//theGame.witcherLog.AddMessage( "IsHuman() = " + (int)IsHuman() );
		//theGame.witcherLog.AddMessage( "GetStat( BCS_Vitality, true ) = " + GetStat( BCS_Vitality, true ) );
		//theGame.witcherLog.AddMessage( "GetStat( BCS_Essence, true ) = " + GetStat( BCS_Essence, true ) );
		
		CheckConstitutionAbility(); //check for duplicated constitution ability

		// ModSignsAddBonuses(); //health/damage modifiers // Triangle use TMod option instead
		
		if ( HasAbility('NPCDoNotGainBoost') )
		{
			return;
		}
		
		ciriEntity = (W3ReplacerCiri)thePlayer;
		playerLevel = thePlayer.GetLevel();
		// Triangle level scaling
		if (TOpts_AreLevelOptionsEnabled()) {
			npcLevel = CalculateLevel();
		} else {
			npcLevel = currentLevel;
		}
		// Triangle end
		//just in case
		currentLevel = Max(1, npcLevel); // Triangle level scaling use scaled level!
		//upscale guards
		if( GetNPCType() == ENGT_Guard ) currentLevel = playerLevel + theGame.params.LEVEL_DIFF_DEADLY + 1;
		//lvl 1 enemies have no additional abilities
		if( currentLevel < 2 )
		{
			return;
		}
		//debug
		//theGame.witcherLog.AddMessage( GetDisplayName() + " cur lvl = " + currentLevel );
		//theGame.witcherLog.AddMessage( GetDisplayName() + " abl lvl = " + ((int)CalculateAttributeValue(GetAttributeValue('level',,true))) );
		//add level up abilities
		if ( (IsHuman() && GetStat( BCS_Essence, true ) <= 0) || (!IsHuman() && GetStat( BCS_Vitality, true ) > 0) ) //humans and vitality based monsters
		{
			//debug
			//theGame.witcherLog.AddMessage( GetDisplayName() + " uses vitality." );
			
			AddAbilityMultiple(theGame.params.ENEMY_BONUS_PER_LEVEL, currentLevel-1);
			AddLevelResistances(currentLevel-1, theGame.params.ENEMY_BONUS_PER_LEVEL);
			if ( ciriEntity )
			{
				if(theGame.GetDifficultyMode() == EDM_Hardcore) AddAbility('CiriHardcoreDebuffHuman');
			}
			else if ( GetAttitudeBetween(this, thePlayer) == AIA_Hostile ) //add level diff abilities
			{
				//theGame.witcherLog.AddMessage( GetDisplayName() + " is hostile." ); //modSigns: debug
				lvlDiff = currentLevel - thePlayer.GetLevel();
				if( lvlDiff >= theGame.params.LEVEL_DIFF_DEADLY ) // deadly enemies
				{
					AddAbility(theGame.params.ENEMY_BONUS_DEADLY, true);
					AddBuffImmunity(EET_Blindness, 'DeadlyEnemy', true);
					AddBuffImmunity(EET_WraithBlindness, 'DeadlyEnemy', true);
				}	
				else if( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH ) // high level enemies
				{
					AddAbility(theGame.params.ENEMY_BONUS_HIGH, true);
				}
				else if( lvlDiff > -theGame.params.LEVEL_DIFF_HIGH ) // normal enemies
				{
				}
				else // low level enemies
				{
					AddAbility(theGame.params.ENEMY_BONUS_LOW, true);
				}
			}
		}
		else //essence based monsters
		{
			//debug
			//theGame.witcherLog.AddMessage( GetDisplayName() + " uses essence." );

			if ( CalculateAttributeValue(super.GetTotalArmor()) > 0.f ) //armored monsters // Triangle enemy mutations
			{
				if ( GetIsMonsterTypeGroup() )
				{
					AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED, currentLevel-1);
					AddLevelResistances(currentLevel-1, theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED);
				}
				else
				{
					AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED, currentLevel-1);
					AddLevelResistances(currentLevel-1, theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED);
				}
			}
			else //unarmored monsters
			{
				if ( GetIsMonsterTypeGroup() )
				{
					AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP, currentLevel-1);
					AddLevelResistances(currentLevel-1, theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP);
				}
				else
				{
					AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL, currentLevel-1);
					AddLevelResistances(currentLevel-1, theGame.params.MONSTER_BONUS_PER_LEVEL);
				}
			}
			if ( ciriEntity )
			{
				if ( theGame.GetDifficultyMode() == EDM_Hardcore ) AddAbility('CiriHardcoreDebuffMonster');
			}
			else if ( GetAttitudeBetween(this, thePlayer) == AIA_Hostile ) //add level diff abilities
			{
				//theGame.witcherLog.AddMessage( GetDisplayName() + " is hostile." ); //modSigns: debug
				lvlDiff = currentLevel - thePlayer.GetLevel();
				if( lvlDiff >= theGame.params.LEVEL_DIFF_DEADLY ) // deadly enemies
				{
					AddAbility(theGame.params.MONSTER_BONUS_DEADLY, true);
					AddBuffImmunity(EET_Blindness, 'DeadlyEnemy', true);
					AddBuffImmunity(EET_WraithBlindness, 'DeadlyEnemy', true);
				}	
				else if( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH ) // high level enemies
				{
					AddAbility(theGame.params.MONSTER_BONUS_HIGH, true);
				}
				else if( lvlDiff > -theGame.params.LEVEL_DIFF_HIGH ) // normal enemies
				{
				}
				else // low level enemies
				{
					AddAbility(theGame.params.MONSTER_BONUS_LOW, true);
				}
			}
		}
		ProcessMutations(); // Triangle enemy mutations
		ProcessHPOptions(); // Triangle hp mods
		//debug
		//theGame.witcherLog.AddMessage( GetDisplayName() + " cur lvl = " + currentLevel );
		//theGame.witcherLog.AddMessage( GetDisplayName() + " abl lvl = " + ((int)CalculateAttributeValue(GetAttributeValue('level',,true))) );
	}
	
	public function SetParentEncounter( encounter : CEncounter )
	{
		parentEncounter = encounter;
	}
	
	public function GetParentEncounter() : CEncounter
	{
		return parentEncounter;
	}
	
	public function GainStat( stat : EBaseCharacterStats, amount : float )
	{
		
		if(stat == BCS_Panic && IsHorse() && thePlayer.GetUsedVehicle() == this && thePlayer.HasBuff(EET_Mutagen25))
		{
			return;
		}
		
		super.GainStat(stat, amount);
	}
	
	public function ForceSetStat(stat : EBaseCharacterStats, val : float)
	{
		
		if(stat == BCS_Panic && IsHorse() && thePlayer.GetUsedVehicle() == this && thePlayer.HasBuff(EET_Mutagen25) && val >= GetStat(BCS_Panic))
		{
			return;
		}
		
		super.ForceSetStat(stat, val);
	}
	
	
	
	
	
	timer function FundamentalsAchFailTimer(dt : float, id : int)
	{
		RemoveTag('failedFundamentalsAchievement');
	}
	
	
	
	
	
	event OnCriticalStateAnimStop()
	{
		isRecoveringFromKnockdown = false;
	}
	
	protected function CriticalBuffInformBehavior(buff : CBaseGameplayEffect)
	{
		SignalGameplayEventParamInt('CriticalState',(int)GetBuffCriticalType(buff));
	}
	
	
	public function StartCSAnim(buff : CBaseGameplayEffect) : bool
	{
		if(super.StartCSAnim(buff))
		{
			CriticalBuffInformBehavior(buff);
			return true;
		}
		 
		return false;
	}
	
	public function CSAnimStarted(buff : CBaseGameplayEffect) : bool
	{
		return super.StartCSAnim(buff);
	}
	
	function SetCanPlayHitAnim( flag : bool )
	{
		if( !flag && this.IsHuman() && this.GetAttitude( thePlayer ) != AIA_Friendly )
		{
			super.SetCanPlayHitAnim( flag );
		}
		else
		{
			super.SetCanPlayHitAnim( flag );
		}
	}

	
	
	event OnStartFistfightMinigame()
	{
		super.OnStartFistfightMinigame();
		
		thePlayer.ProcessLockTarget( this );
		SignalGameplayEventParamInt('ChangePreferedCombatStyle',(int)EBG_Combat_Fists );
		SetTemporaryAttitudeGroup( 'fistfight_opponent', AGP_Fistfight );
		ForceVulnerableImmortalityMode();
		if ( !thePlayer.IsFistFightMinigameToTheDeath() )
			SetImmortalityMode(AIM_Unconscious, AIC_Fistfight);
		ValidateFistfighterAbilities(); //modSigns: fix multiple abilities bug
		FistFightHealthSetup();
		//modSigns: remove level bonuses
		RemoveFistFightLevelDiff();
		RemoveAllLevelBonuses();
	}
	
	//modSigns: fix multiple abilities bug
	function ValidateFistfighterAbilities()
	{
		if( HasAbility( 'SkillFistsEasy' ) )
		{
			RemoveAbilityAll( 'SkillFistsMedium' );
			RemoveAbilityAll( 'SkillFistsHard' );
		}
		else if( HasAbility( 'SkillFistsMedium' ) )
		{
			RemoveAbilityAll( 'SkillFistsHard' );
		}
		
		if( HasAbility( 'StatsFistsTutorial' ) )
		{
			RemoveAbilityAll( 'StatsFistsEasy' );
			RemoveAbilityAll( 'StatsFistsMedium' );
			RemoveAbilityAll( 'StatsFistsHard' );
		}
		else if( HasAbility( 'StatsFistsEasy' ) )
		{
			RemoveAbilityAll( 'StatsFistsMedium' );
			RemoveAbilityAll( 'StatsFistsHard' );
		}
		else if( HasAbility( 'StatsFistsMedium' ) )
		{
			RemoveAbilityAll( 'StatsFistsHard' );
		}
	}
	
	event OnEndFistfightMinigame()
	{	
		SignalGameplayEvent('ResetPreferedCombatStyle');
		ResetTemporaryAttitudeGroup( AGP_Fistfight );
		RestoreImmortalityMode();
		LowerGuard();
		if ( IsKnockedUnconscious() )
		{
			SignalGameplayEvent('ForceStopUnconscious');
		}
		if ( !IsAlive() )
		{
			Revive();
		}
		FistFightHealthSetup();
		RecalcLevel(); //modSigns: restore level bonuses
		
		super.OnEndFistfightMinigame();
	}
		
	private function FistFightHealthSetup()
	{
		
		if ( HasAbility( 'fistfight_minigame' ) )
		{
			FistFightersHealthDiff();
		}
		else return;

	}
	
	private function FistFightersHealthDiff()
	{
		var vitality 		: float;
		var stats : CCharacterStats;
		stats = GetCharacterStats();
		
		if ( stats.HasAbility( 'StatsFistsTutorial' ) )
		{
			stats.AddAbility( 'HealthFistFightTutorial', false );
		}
		else if ( stats.HasAbility( 'StatsFistsEasy' ) )
		{
			stats.AddAbility( 'HealthFistFightEasy', false );
		}
		else if ( stats.HasAbility( 'StatsFistsMedium' ) )
		{
			stats.AddAbility( 'HealthFistFightMedium', false );
		}
		else if ( stats.HasAbility( 'StatsFistsHard' ) )
		{
			stats.AddAbility( 'HealthFistFightHard', false );
		}
		vitality = abilityManager.GetStatMax( BCS_Vitality );
		SetHealthPerc( 100 );
	}
	
	/*private function FistFightNewGamePlusSetup() //modSigns: remove NGP/fake levels dancing around
	{
		if ( HasAbility( 'NPCLevelBonus' ) )
		{
			RemoveAbilityMultiple( 'NPCLevelBonus', theGame.params.GetNewGamePlusLevel() );
			newGamePlusFakeLevelAddon = true;
			currentLevel -= theGame.params.GetNewGamePlusLevel();
			RecalcLevel(); 
		}
	}*/
	
	/*private function ApplyFistFightLevelDiff() //modSigns: remove level diff debuff/buff
	{
		var lvlDiff 	: int;
		var i 			: int;
		var attribute 	: SAbilityAttributeValue; 
		var min, max	: SAbilityAttributeValue;
		var ffHP, ffAP	: SAbilityAttributeValue;
		var dm 			: CDefinitionsManagerAccessor; 
		
		lvlDiff = (int)CalculateAttributeValue(GetAttributeValue('level',,true)) - thePlayer.GetLevel();
		
		if ( !HasAbility('NPC fists _Stats') )
		{
			dm = theGame.GetDefinitionsManager();
			dm.GetAbilityAttributeValue('NPC fists _Stats', 'vitality', min, max);
			ffHP = GetAttributeRandomizedValue(min, max);
			dm.GetAbilityAttributeValue('NPC fists _Stats', 'attack_power', min, max);
			ffAP = GetAttributeRandomizedValue(min, max);
		}
		
   		if ( lvlDiff < -theGame.params.LEVEL_DIFF_HIGH )
		{
			for (i=0; i < 5; i+=1)
			{
				AddAbility(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW, true);
				attribute = GetAttributeValue('vitality');
				attribute += ffHP;
				if (attribute.valueMultiplicative <= 0)
				{
					RemoveAbility(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW);
					return;
				}
				attribute = GetAttributeValue('attack_power');
				attribute += ffAP;
				if (attribute.valueMultiplicative <= 0)
				{
					RemoveAbility(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW);
					return;
				}
			}
		}
		else if ( lvlDiff < 0 )
		{
			for (i=0; i < -lvlDiff; i+=1)
			{
				AddAbility(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW, true);
				attribute = GetAttributeValue('vitality');
				if (attribute.valueMultiplicative <= 0)
				{
					RemoveAbility(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW);
					return;
				}
				attribute = GetAttributeValue('attack_power');
				if (attribute.valueMultiplicative <= 0)
				{
					RemoveAbility(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW);
					return;
				}
			}
		}
		else if ( lvlDiff > theGame.params.LEVEL_DIFF_HIGH )
			AddAbilityMultiple(theGame.params.ENEMY_BONUS_FISTFIGHT_HIGH, 5);
		else if ( lvlDiff > 0  )
			AddAbilityMultiple(theGame.params.ENEMY_BONUS_FISTFIGHT_HIGH, lvlDiff);
	}*/
	
	private function RemoveFistFightLevelDiff()
	{
		RemoveAbilityMultiple(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW, 5);
		RemoveAbilityMultiple(theGame.params.ENEMY_BONUS_FISTFIGHT_HIGH, 5);
	}

	
	
	
	
	private function IsThisStanceRegular( Stance : ENpcStance ) : bool
	{
		if( Stance == NS_Normal || 
			Stance == NS_Strafe ||
			Stance == NS_Retreat )
		{
			return true;
		}
		
		return false;
	}
	
	private function IsThisStanceDefensive( Stance : ENpcStance ) : bool
	{
		if( Stance == NS_Guarded || 
			Stance == NS_Guarded )
		{
			return true;
		}
		
		return false;
	}
	
	function GetCurrentStance() : ENpcStance
	{
		var l_currentStance : int;
		l_currentStance = (int)this.GetBehaviorVariable( 'npcStance');
		return l_currentStance;
	}
	
	function GetRegularStance() : ENpcStance
	{
		return this.regularStance;
	}
	
	function ReturnToRegularStance()
	{
		this.SetBehaviorVariable( 'npcStance',(int)this.regularStance);
	}
	
	function IsInRegularStance() : bool
	{
		if(	GetCurrentStance() == GetRegularStance() )
		{
			return true;
		}
		
		return false;
	}
	
	function ChangeStance( newStance : ENpcStance ) : bool
	{
		if ( IsThisStanceDefensive( newStance ) )
		{
			LogChannel('NPC ChangeStance', "You shouldn't use this function to change to this stance - " + newStance );
		}
		else if ( IsThisStanceRegular( newStance ) )
		{
			if ( this.SetBehaviorVariable( 'npcStance',(int)newStance) )
			{
				this.regularStance = newStance;
				return true;
			}
		}
		else
		{
			return this.SetBehaviorVariable( 'npcStance',(int)newStance);
		}
		return false;
	}
	
	function RaiseGuard() : bool
	{
		SetGuarded( true );
		return true;
	}
	
	function LowerGuard() : bool
	{
		SetGuarded( false );
		return true;
	}
	
	
	
	
	
	function IsInAgony() : bool
	{
		return bAgony;
	}
	
	function EnterAgony()
	{
		bAgony = true;
	}
	
	function EndAgony()
	{
		bAgony = false;
	}
	
	function EnableDeathAndAgony()
	{
		bPlayDeathAnim = true;
		bAgonyDisabled = false;
	}
	
	function EnableDeath()
	{
		bPlayDeathAnim = true;
	}
	
	function EnableAgony()
	{
		bAgonyDisabled = false;
	}
	
	function DisableDeathAndAgony()
	{
		bPlayDeathAnim = false;
		bAgonyDisabled = true;
	}
	function DisableAgony()
	{
		bAgonyDisabled = true;
	}
	
	function IsAgonyDisabled() : bool
	{
		return bAgonyDisabled;
	}
	
	function IsInFinisherAnim() : bool
	{
		return bFinisher;
	} 
	
	function FinisherAnimStart()
	{
		bPlayDeathAnim = false;		
		bFinisher = true;
		SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)GMM_Death );
	}
	
	function FinisherAnimInterrupted()
	{
		bPlayDeathAnim 			= true;		
		bFinisher 				= false;
		bFinisherInterrupted 	= true;
	}
	
	function ResetFinisherAnimInterruptionState()
	{
		bFinisherInterrupted = false;
	}
	
	function WasFinisherAnimInterrupted() : bool
	{
		return bFinisherInterrupted;
	}
	
	function FinisherAnimEnd()
	{
		bFinisher = false;
	}
	
	function ShouldPlayDeathAnim() : bool
	{
		return bPlayDeathAnim;
	}
	
	function NPCGetAgonyAnim() : CName
	{
		var agonyType : float;
		agonyType = GetBehaviorVariable( 'AgonyType');
		
		if (agonyType == (int)AT_ThroatCut)
		{
			return 'man_throat_cut_start';
		}
		else if(agonyType == (int)AT_Knockdown)
		{
			return 'man_wounded_crawl_killed';
		}
		else
			return '';
	}
	
	function GeraltGetAgonyAnim() : CName
	{
		var agonyType : float;
		agonyType = GetBehaviorVariable( 'AgonyType');
		
		if (agonyType == (int)AT_ThroatCut)
		{
			return 'man_ger_throat_cut_attack_01';
		}
		else if(agonyType == (int)AT_Knockdown)
		{
			return 'man_ger_crawl_finish';
		}
		else
			return '';
	}
	
	
	
	
	
	protected function PlayHitAnimation(damageAction : W3DamageAction, animType : EHitReactionType)
	{
		var node : CNode;
		
		SetBehaviorVariable( 'HitReactionWeapon', ProcessSwordOrFistHitReaction( this, (CActor)damageAction.attacker ) );
		SetBehaviorVariable( 'HitReactionType',(int)animType);
		
		if ( damageAction.attacker )
		{
			super.PlayHitAnimation( damageAction, animType );
			node = (CNode)damageAction.causer;
			if (node)
			{
				SetHitReactionDirection(node);
			}
			else
			{
				SetHitReactionDirection(damageAction.attacker);
			}
			SetDetailedHitReaction(damageAction.GetSwingType(), damageAction.GetSwingDirection());
		}
		
		if ( this.customHits )
		{
			damageAction.customHitReactionRequested = true;
		}
		else
		{
			damageAction.hitReactionAnimRequested = true;
		}
	}
	
	public function GetAbilityBuffStackedOnEnemyHitName() : name
	{
		return abilityBuffStackedOnEnemyHitName;
	}
	
	public function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool
	{
		var ret 							: bool;
		var percentageLoss					: float;
		var totalHealth						: float;
		var damaveValue						: float;
		var healthLossToForceLand_perc		: SAbilityAttributeValue;
		var witcher							: W3PlayerWitcher;
		var node							: CNode;
		var boltCauser						: W3ArrowProjectile;
		var yrdenCauser 					: W3YrdenEntityStateYrdenShock;
		var attackAction					: W3Action_Attack;
		
		damaveValue 				 = damageAction.GetDamageDealt();
		totalHealth 				 = GetMaxHealth();
		percentageLoss 			 	= damaveValue / totalHealth;
		healthLossToForceLand_perc 	 = GetAttributeValue( 'healthLossToForceLand_perc' );
		
		
		//modSigns
		if( !((CBaseGameplayEffect)damageAction.causer) && IsFlying() && percentageLoss >= CalculateAttributeValue(healthLossToForceLand_perc) )
		//if( percentageLoss >= healthLossToForceLand_perc.valueBase && ( GetCurrentStance() == NS_Fly || ( !IsUsingVehicle() && GetCurrentStance() != NS_Swim && !((CMovingPhysicalAgentComponent) GetMovingAgentComponent()).IsOnGround()) ) && !(damageAction.IsDoTDamage() && !damageAction.DealsAnyDamage()) )
		{
			
			//if( !((CBaseGameplayEffect) damageAction.causer ) )
			//{
				//theGame.witcherLog.AddMessage("NPC force landing");
				damageAction.AddEffectInfo(	EET_KnockdownTypeApplicator ); //modSigns
			//}
		}
		
		
		boltCauser = (W3ArrowProjectile)( damageAction.causer );
		yrdenCauser = (W3YrdenEntityStateYrdenShock)( damageAction.causer );
		if( boltCauser || yrdenCauser )
		{
			if( HasAbility( 'AdditiveHits' ) )
			{
				SetUseAdditiveHit( true, GetCriticalCancelAdditiveHit(), true );
				ret = super.ReactToBeingHit(damageAction, buffNotApplied);
				
				if( ret || damageAction.DealsAnyDamage())
					SignalGameplayDamageEvent('BeingHit', damageAction );
			}
			else if( HasAbility( 'mon_wild_hunt_default' ) )
			{
				ret = false;
			}
			else if( !boltCauser.HasTag( 'bodkinbolt' ) || this.IsUsingHorse() || RandRange(100) < 75.f ) 
			{
				ret = super.ReactToBeingHit(damageAction, buffNotApplied);
				
				if( ret || damageAction.DealsAnyDamage())
					SignalGameplayDamageEvent('BeingHit', damageAction );
			}
			else
			{
				ret = false;
			}
		}
		else
		{
			ret = super.ReactToBeingHit(damageAction, buffNotApplied);
			
			if( ret || damageAction.DealsAnyDamage() )
				SignalGameplayDamageEvent('BeingHit', damageAction );
		}
		
		if( damageAction.additiveHitReactionAnimRequested == true )
		{
			node = (CNode)damageAction.causer;
			if (node)
			{
				SetHitReactionDirection(node);
			}
			else
			{
				SetHitReactionDirection(damageAction.attacker);
			}
		}
		
		if(((CPlayer)damageAction.attacker || !((CNewNPC)damageAction.attacker)) && damageAction.DealsAnyDamage())
			theTelemetry.LogWithLabelAndValue( TE_FIGHT_ENEMY_GETS_HIT, damageAction.victim.ToString(), (int)damageAction.processedDmg.vitalityDamage + (int)damageAction.processedDmg.essenceDamage );
		
		
		witcher = GetWitcherPlayer();
		if ( damageAction.attacker == witcher && HasBuff( EET_AxiiGuardMe ) )
		{
			
			if(!witcher.CanUseSkill(S_Magic_s05) || witcher.GetSkillLevel(S_Magic_s05) < 3)
				RemoveBuff(EET_AxiiGuardMe, true);
		}
		
		if(damageAction.attacker == thePlayer && damageAction.DealsAnyDamage() && !damageAction.IsDoTDamage())
		{
			attackAction = (W3Action_Attack) damageAction;
			
			
			
			
			if(attackAction && attackAction.UsedZeroStaminaPerk())
			{
				ForceSetStat(BCS_Stamina, 0.f);
			}
		}
		
		return ret;
	}
	
	
	
	
	
	function Kill( source : name, optional ignoreImmortalityMode : bool, optional attacker : CGameplayEntity )
	{
		var action : W3DamageAction;
		
		if ( theGame.CanLog() )
		{		
			LogDMHits( "CActor.Kill: called for actor <<" + this + ">> with source <<" + source + ">>" );
		}
		
		action = GetKillAction( source, ignoreImmortalityMode, attacker );
		
		if ( this.IsKnockedUnconscious() )
		{
			DisableDeathAndAgony();
			OnDeath(action);
		}
		else if ( !abilityManager )
		{
			OnDeath(action);
		}
		else
		{
			if ( ignoreImmortalityMode )
				this.immortalityFlags = 0;
				
			theGame.damageMgr.ProcessAction(action);
		}
		
		delete action;
	}
	
	public final function GetLevel() : int
	{
		return (int)CalculateAttributeValue(GetAttributeValue('level',,true));
	}
	
	public final function GetLevelFromLocalVar() : int
	{
		return currentLevel;
	}
	
	function GetExperienceDifferenceLevelName( out strLevel : string ) : string
	{
		var lvlDiff : int;
		var currentLevel : int;
		var ciriEntity  : W3ReplacerCiri;
		
		currentLevel = GetLevel(); //modSigns: fake levels removed
		
		if ( currentLevel > ( theGame.params.GetPlayerMaxLevel() + 5 ) ) 
		{
			currentLevel = theGame.params.GetPlayerMaxLevel() + 5;
		}		
		lvlDiff = currentLevel - thePlayer.GetLevel();
			
		if( GetAttitude( thePlayer ) != AIA_Hostile )
		{
			if( ( GetAttitudeGroup() != 'npc_charmed' ) )
			{
				strLevel = "";
				return "none";
			}
		}
		
		ciriEntity = (W3ReplacerCiri)thePlayer;
		if ( ciriEntity )
		{
			strLevel = "<font color=\"#66FF66\">" + currentLevel + "</font>"; 
			return "normalLevel";
		}

		
		 if ( lvlDiff >= theGame.params.LEVEL_DIFF_DEADLY )
		{
			strLevel = "";
			return "deadlyLevel";
		}	
		else if ( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH )
		{
			strLevel = "<font color=\"#FF1919\">" + currentLevel + "</font>"; 
			return "highLevel";
		}
		else if ( lvlDiff > -theGame.params.LEVEL_DIFF_HIGH )
		{
			strLevel = "<font color=\"#66FF66\">" + currentLevel + "</font>"; 
			return "normalLevel";
		}
		else
		{
			strLevel = "<font color=\"#E6E6E6\">" + currentLevel + "</font>"; 
			return "lowLevel";
		}
		return "none";
	}
	
	
	private function ShouldGiveExp(attacker : CGameplayEntity) : bool
	{
		var actor : CActor;
		var npc : CNewNPC;
		var victimAt : EAIAttitude;
		var giveExp : bool;
		
		victimAt = GetAttitudeBetween(thePlayer, this);
		giveExp = false;
		
		
		if(victimAt == AIA_Hostile)
		{
			if(attacker == thePlayer && !((W3PlayerWitcher)thePlayer) )
			{
				
				giveExp = false;
			}
			else if(attacker == thePlayer)
			{
				
				giveExp = true;
			}
			
			else if(VecDistance(thePlayer.GetWorldPosition(), GetWorldPosition()) <= 20)
			{
				npc = (CNewNPC)attacker;
				if(!npc || npc.npcGroupType != ENGT_Guard)	
				{
					actor = (CActor)attacker;
					if(!actor)
					{
						
						giveExp = true;
					}
					else if(actor.HasTag(theGame.params.TAG_NPC_IN_PARTY) || actor.HasBuff(EET_AxiiGuardMe))
					{
						
						giveExp = true;
					}							
				}
			}
		}
		
		return giveExp;
	}
	
	function AddBestiaryKnowledge()
	{
		var manager : CWitcherJournalManager;
		var resource : CJournalResource;
		var entryBase : CJournalBase;
		
		manager = theGame.GetJournalManager();
		
		if ( AddBestiaryKnowledgeEP2() ) return;
		
		if ( HasAbility( 'NoJournalEntry' )) return; else
		if ( GetSfxTag() == 'sfx_arachas' && HasAbility('mon_arachas_armored') )	activateBaseBestiaryEntryWithAlias("BestiaryArmoredArachas", manager); else
		if ( GetSfxTag() == 'sfx_arachas' && HasAbility('mon_poison_arachas')  )	activateBaseBestiaryEntryWithAlias("BestiaryPoisonousArachas", manager); else
		if ( GetSfxTag() == 'sfx_bear' )											activateBaseBestiaryEntryWithAlias("BestiaryBear", manager); else
		if ( GetSfxTag() == 'sfx_alghoul' )											activateBaseBestiaryEntryWithAlias("BestiaryAlghoul", manager); else
		if ( HasAbility('mon_greater_miscreant') )									activateBaseBestiaryEntryWithAlias("BestiaryMiscreant", manager); else
		if ( HasAbility('mon_basilisk') )											activateBaseBestiaryEntryWithAlias("BestiaryBasilisk", manager); else
		if ( HasAbility('mon_boar_base') )											
		{
			resource = (CJournalResource)LoadResource( "BestiaryBoarEP2" );
			if ( resource )
			{
				entryBase = resource.GetEntry();
				if ( entryBase )
				{
					if ( manager.GetEntryStatus( entryBase ) == JS_Inactive )
					{
						activateBaseBestiaryEntryWithAlias("BestiaryBoar", manager);
					}
				}
			}
		} else
		if ( HasAbility('mon_black_spider_base') )
		{
			resource = (CJournalResource)LoadResource( "BestiarySpiderEP2" );
			if ( resource )
			{
				entryBase = resource.GetEntry();
				if ( entryBase )
				{
					if ( manager.GetEntryStatus( entryBase ) == JS_Inactive )
					{
						activateBaseBestiaryEntryWithAlias("BestiarySpider", manager); 
					}
				}
			}
		} else
		if ( HasAbility('mon_toad_base') )											activateBaseBestiaryEntryWithAlias("BestiaryToad", manager); else
		if ( HasAbility('q604_caretaker') )											activateBaseBestiaryEntryWithAlias("Bestiarycaretaker", manager); else
		if ( HasAbility('mon_nightwraith_iris') )									activateBaseBestiaryEntryWithAlias("BestiaryIris", manager); else
		if ( GetSfxTag() == 'sfx_cockatrice' )										activateBaseBestiaryEntryWithAlias("BestiaryCockatrice", manager); else
		if ( GetSfxTag() == 'sfx_arachas' && !HasAbility('mon_arachas_armored') && !HasAbility('mon_poison_arachas') ) activateBaseBestiaryEntryWithAlias("BestiaryCrabSpider", manager); else
		if ( GetSfxTag() == 'sfx_katakan' && HasAbility('mon_ekimma') )				activateBaseBestiaryEntryWithAlias("BestiaryEkkima", manager); else
		if ( GetSfxTag() == 'sfx_elemental_dao' )									activateBaseBestiaryEntryWithAlias("BestiaryElemental", manager); else
		if ( GetSfxTag() == 'sfx_endriaga' && HasAbility('mon_endriaga_soldier_tailed') ) activateBaseBestiaryEntryWithAlias("BestiaryEndriaga", manager); else
		if ( GetSfxTag() == 'sfx_endriaga' && HasAbility('mon_endriaga_worker') )	activateBaseBestiaryEntryWithAlias("BestiaryEndriagaWorker", manager); else
		if ( GetSfxTag() == 'sfx_endriaga' && HasAbility('mon_endriaga_soldier_spikey') ) activateBaseBestiaryEntryWithAlias("BestiaryEndriagaTruten", manager); else
		if ( HasAbility('mon_forktail_young') || HasAbility('mon_forktail') || HasAbility('mon_forktail_mh') ) activateBaseBestiaryEntryWithAlias("BestiaryForktail", manager); else
		if ( GetSfxTag() == 'sfx_ghoul' )										activateBaseBestiaryEntryWithAlias("BestiaryGhoul", manager); else
		if ( GetSfxTag() == 'sfx_golem' )										activateBaseBestiaryEntryWithAlias("BestiaryGolem", manager); else
		if ( GetSfxTag() == 'sfx_katakan' && !HasAbility('mon_ekimma') )		activateBaseBestiaryEntryWithAlias("BestiaryKatakan", manager); else
		if ( GetSfxTag() == 'sfx_ghoul' && HasAbility('mon_greater_miscreant') )	activateBaseBestiaryEntryWithAlias("BestiaryMiscreant", manager); else
		if ( HasAbility('mon_nightwraith')|| HasAbility('mon_nightwraith_mh') )	activateBaseBestiaryEntryWithAlias("BestiaryMoonwright", manager); else
		if ( HasAbility('mon_noonwraith') && !HasAbility('mon_noonwraith_doppelganger') )	activateBaseBestiaryEntryWithAlias("BestiaryNoonwright", manager); else
		if ( HasAbility('mon_lycanthrope') )									activateBaseBestiaryEntryWithAlias("BestiaryLycanthrope", manager); else
		if ( GetSfxTag() == 'sfx_werewolf' )									activateBaseBestiaryEntryWithAlias("BestiaryWerewolf", manager); else
		if ( GetSfxTag() == 'sfx_wyvern' )										activateBaseBestiaryEntryWithAlias("BestiaryWyvern", manager); else
		if ( HasAbility('mon_czart') )											activateBaseBestiaryEntryWithAlias("BestiaryCzart", manager); else
		if ( GetSfxTag() == 'sfx_bies' )										activateBaseBestiaryEntryWithAlias("BestiaryBies", manager); else
		if ( GetSfxTag() == 'sfx_wild_dog' )									activateBaseBestiaryEntryWithAlias("BestiaryDog", manager); else
		if ( GetSfxTag() == 'sfx_drowner' )										activateBaseBestiaryEntryWithAlias("BestiaryDrowner", manager);  else
		if ( GetSfxTag() == 'sfx_elemental_ifryt' )								activateBaseBestiaryEntryWithAlias("BestiaryFireElemental", manager); else
		if ( GetSfxTag() == 'sfx_fogling' )										activateBaseBestiaryEntryWithAlias("BestiaryFogling", manager); else
		if ( GetSfxTag() == 'sfx_gravehag' )									activateBaseBestiaryEntryWithAlias("BestiaryGraveHag", manager); else
		if ( GetSfxTag() == 'sfx_gryphon' )										activateBaseBestiaryEntryWithAlias("BestiaryGriffin", manager); else
		if ( HasAbility('mon_erynia') )											activateBaseBestiaryEntryWithAlias("BestiaryErynia", manager); else
		if ( GetSfxTag() == 'sfx_harpy' )										activateBaseBestiaryEntryWithAlias("BestiaryHarpy", manager); else
		if ( GetSfxTag() == 'sfx_ice_giant' )									activateBaseBestiaryEntryWithAlias("BestiaryIceGiant", manager); else
		if ( GetSfxTag() == 'sfx_lessog' )										activateBaseBestiaryEntryWithAlias("BestiaryLeshy", manager); else
		if ( GetSfxTag() == 'sfx_nekker' )										activateBaseBestiaryEntryWithAlias("BestiaryNekker", manager); else
		if ( GetSfxTag() == 'sfx_siren' )										activateBaseBestiaryEntryWithAlias("BestiarySiren", manager); else
		if ( HasTag('ice_troll') )												activateBaseBestiaryEntryWithAlias("BestiaryIceTroll", manager); else
		if ( GetSfxTag() == 'sfx_troll_cave' )									activateBaseBestiaryEntryWithAlias("BestiaryCaveTroll", manager); else
		if ( GetSfxTag() == 'sfx_waterhag' )									activateBaseBestiaryEntryWithAlias("BestiaryWaterHag", manager); else
		if ( GetSfxTag() == 'sfx_wildhunt_minion' )								activateBaseBestiaryEntryWithAlias("BestiaryWhMinion", manager); else
		if ( GetSfxTag() == 'sfx_wolf' )										activateBaseBestiaryEntryWithAlias("BestiaryWolf", manager); else
		if ( GetSfxTag() == 'sfx_wraith' )										activateBaseBestiaryEntryWithAlias("BestiaryWraith", manager); else
		if ( HasAbility('mon_cyclops') ) 										activateBaseBestiaryEntryWithAlias("BestiaryCyclop", manager); else
		if ( HasAbility('mon_ice_golem') )										activateBaseBestiaryEntryWithAlias("BestiaryIceGolem", manager); else
		if ( HasAbility('mon_gargoyle') )										activateBaseBestiaryEntryWithAlias("BestiaryGargoyle", manager); else
		if ( HasAbility('mon_rotfiend') || HasAbility('mon_rotfiend_large')) 	activateBaseBestiaryEntryWithAlias("BestiaryGreaterRotFiend", manager); else
		if ( HasAbility('mon_gravier') )										activateJournalBestiaryEntryWithAlias("BestiaryGraveir", manager);
	}
	
	function AddBestiaryKnowledgeEP2() : bool
	{
		var manager : CWitcherJournalManager;
		var resource : CJournalResource;
		var entryBase : CJournalBase;
		manager = theGame.GetJournalManager();
		
		if ( HasAbility('mon_mq7010_dracolizard') )										{ activateBaseBestiaryEntryWithAlias("BestiaryDracolizardMatriarch", manager); return true; } else
		if ( HasAbility('mon_draco_base') )												{ activateBaseBestiaryEntryWithAlias("BestiaryDracolizard", manager); return true; } else
		if ( HasAbility('mon_sprigan') )												{ activateBaseBestiaryEntryWithAlias("BestiarySpriggan", manager); return true; } else
		if ( HasAbility('mon_garkain') )												{ activateBaseBestiaryEntryWithAlias("BestiaryGarkain", manager); return true; } else
		if ( HasAbility('mon_panther_base') && !HasAbility('mon_panther_ghost') )		{ activateBaseBestiaryEntryWithAlias("BestiaryPanther", manager); return true; } else
		if ( HasAbility('mon_sharley_base') )											{ activateBaseBestiaryEntryWithAlias("BestiarySharley", manager); return true; } else
		if ( HasAbility('mon_barghest_base') )											{ activateBaseBestiaryEntryWithAlias("BestiaryBarghest", manager); return true; } else
		if ( HasAbility('mon_bruxa') )													{ activateBaseBestiaryEntryWithAlias("BestiaryBruxa", manager); return true; } else
		if ( HasAbility('mon_fleder') )													{ activateBaseBestiaryEntryWithAlias("BestiaryFleder", manager); return true; } else
		if ( HasAbility('q704_mon_protofleder') )										{ activateBaseBestiaryEntryWithAlias("BestiaryProtofleder", manager); return true; } else
		if ( HasAbility('mon_alp') )													{ activateBaseBestiaryEntryWithAlias("BestiaryAlp", manager); return true; } else
		if ( HasTag('mq7023_pale_widow') )												{ activateBaseBestiaryEntryWithAlias("BestiaryPaleWidow", manager); return true; } else
		if ( HasAbility('mon_scolopendromorph_base') )									{ activateBaseBestiaryEntryWithAlias("BestiaryScolopendromorph", manager); return true; } else
		if ( HasAbility('mon_kikimora_warrior') )										{ activateBaseBestiaryEntryWithAlias("BestiaryKikimoraWarrior", manager); return true; } else
		if ( HasAbility('mon_kikimora_worker') )										{ activateBaseBestiaryEntryWithAlias("BestiaryKikimoraWorker", manager); return true; } else
		if ( HasAbility('mon_archespor_base') )											{ activateBaseBestiaryEntryWithAlias("BestiaryArchespore", manager); return true; } else
		if ( HasAbility('mon_dark_pixie_base') || HasAbility('mon_q704_ft_pixies') )	{ activateBaseBestiaryEntryWithAlias("BestiaryDarkPixie", manager); return true; } else
		if ( HasAbility('mon_graveir') )												{ activateBaseBestiaryEntryWithAlias("BestiaryDarkPixie", manager); return true; } else
		if ( HasAbility('mon_wight') )													{ activateBaseBestiaryEntryWithAlias("BestiaryWicht", manager); return true; } else
		if ( HasAbility('mon_knight_giant') )											{ activateBaseBestiaryEntryWithAlias("BestiaryDagonet", manager); return true; } else
		if ( HasAbility('mon_q704_ft_wilk') )											{ activateBaseBestiaryEntryWithAlias("BestiaryBigBadWolf", manager); return true; } else
		if ( HasAbility('mon_q704_ft_pigs_evil') )										{ activateBaseBestiaryEntryWithAlias("BestiaryPigsEvil", manager); return true; } else
		if ( HasAbility('mon_mq7018_basilisk') )										{ activateBaseBestiaryEntryWithAlias("BestiaryLastBasilisk", manager); return true; } else
		if ( HasAbility('mon_fairytale_witch') )										{ activateBaseBestiaryEntryWithAlias("BestiaryFairtaleWitch", manager); return true; } else
		if ( HasAbility('banshee_rapunzel') )											{ activateBaseBestiaryEntryWithAlias("BestiaryRapunzel", manager); return true; } else
		if ( HasAbility('mon_nightwraith_banshee') )									{ activateBaseBestiaryEntryWithAlias("BestiaryBeanshie", manager); return true; } else
		if ( HasAbility('mon_black_spider_ep2_base') )									
		{ 
			resource = (CJournalResource)LoadResource( "BestiarySpider" );
			if ( resource )
			{
				entryBase = resource.GetEntry();
				if ( entryBase )
				{
					if ( manager.GetEntryStatus( entryBase ) == JS_Inactive )
					{
						activateBaseBestiaryEntryWithAlias("BestiarySpiderEP2", manager); 
						return true; 
					}
				}
			}
		} else
		if ( HasAbility('mon_boar_ep2_base') )											
		{ 
			resource = (CJournalResource)LoadResource( "BestiaryBoar" );
			if ( resource )
			{
				entryBase = resource.GetEntry();
				if ( entryBase )
				{
					if ( manager.GetEntryStatus( entryBase ) == JS_Inactive )
					{
						activateBaseBestiaryEntryWithAlias("BestiaryBoarEP2", manager); 
						return true; 
					}
				}
			}
		} else
		if ( HasAbility('mon_cloud_giant') )											{ activateBaseBestiaryEntryWithAlias("BestiaryCloudGiant", manager); return true; }
		
		return false;
		
	}
	
	//modSigns: reworked
	public function CalculateExperiencePoints(optional skipLog : bool) : int
	{
		var finalExp				: int;
		var exp, expModifier		: float;
		var lvlDiff, playerLevel	: int;
		var enemyType				: EEnemyType;
		
		if(grantNoExperienceAfterKill || HasAbility('Zero_XP'))
			return 0;
		
		if(GetNPCType() == ENGT_Guard)
		{
			GetWitcherPlayer().IncKills(EENT_HUMAN);
			return 0;
		}

		enemyType = GetEnemyTypeByAbility(this);
		exp = (float)GetExpByEnemyType(enemyType);
		
		//exp for monster hunt monsters
		if((W3MonsterHuntNPC)this)
			exp = 15;
		
		expModifier = 1.0f;
		playerLevel = thePlayer.GetLevel();
		if(FactsQuerySum("NewGamePlus") > 0)
		{
			playerLevel -= theGame.params.GetNewGamePlusLevel();
			currentLevel -= theGame.params.GetNewGamePlusLevel();
		}
		if(theGame.params.GetFixedExp() == false)
		{
			lvlDiff = currentLevel - thePlayer.GetLevel();
			expModifier = 1 + lvlDiff * theGame.params.LEVEL_DIFF_XP_MOD;
			expModifier = ClampF(expModifier, 0, theGame.params.MAX_XP_MOD);
			expModifier *= GetWitcherPlayer().GetExpModifierByEnemyType(enemyType);
		}
		
		finalExp = RoundF( exp * expModifier );
		//always get at least 1 exp
		finalExp = Max(1, finalExp);
		
		GetWitcherPlayer().IncKills(enemyType);
		
		return finalExp;
	}
	
	
	timer function StopMutation6FX( dt : float, id : int )
	{
		StopEffect( 'critical_frozen' );
	}
	
	event OnDeath( damageAction : W3DamageAction  )
	{		
		var inWater, fists, tmpBool, addAbility, isFinisher : bool;		
		var expPoints, npcLevel, lvlDiff, i, j 				: int;
		var abilityName, tmpName 							: name;
		var abilityCount, maxStack, minDist					: float;
		var itemExpBonus, radius							: float;
		
		var allItems 										: array<SItemUniqueId>;
		var damages 										: array<SRawDamage>;
		var atts 											: array<name>;
		var entities  										: array< CGameplayEntity >;
		
		var params											: SCustomEffectParams;
		var dmg 											: SRawDamage;
		var weaponID 										: SItemUniqueId;
		var min, max, bonusExp 								: SAbilityAttributeValue;

		var monsterCategory 								: EMonsterCategory;
		var attitudeToPlayer 								: EAIAttitude;
		
		var actor , targetEntity							: CActor;
		var gameplayEffect 									: CBaseGameplayEffect;
		var fxEnt 											: CEntity;
		
		var attackAction 									: W3Action_Attack;	
		var ciriEntity  									: W3ReplacerCiri;
		var witcher											: W3PlayerWitcher;
		var blizzard 										: W3Potion_Blizzard;
		var act 											: W3DamageAction;
		var burningCauser 									: W3Effect_Burning;
		var vfxEnt 											: W3VisualFx;
		var aerondight										: W3Effect_Aerondight;
		var arrInt											: array<int>; //modSigns
		// Triangle enemy mutations
		var ent												: CEntity;
		var template										: CEntityTemplate;
		var stats											: CCharacterStats;

		GetCharacterStats().RemoveAbility(TUtil_TEMutationEnumToName(TEM_Electric));

		stats = GetCharacterStats();
		if (stats.HasAbility(TUtil_TEMutationEnumToName(TEM_Haunted))) {
			template = (CEntityTemplate)LoadResource('wraith');
			ent = theGame.CreateEntity(template, GetWorldPosition(), GetWorldRotation());
			((CActor)ent).SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
			((CNewNPC)ent).SetLevel(GetLevel());
		}
		// Triangle end


		ciriEntity = (W3ReplacerCiri)thePlayer;
		witcher = GetWitcherPlayer();
		
		deathTimestamp = theGame.GetEngineTimeAsSeconds();
		
		
		if( damageAction.GetBuffSourceName() == "Mutation 6" )
		{
			PlayEffect( 'critical_frozen' );
			AddTimer( 'StopMutation6FX', 3.f );
		}
		
		if ( (GetWitcherPlayer().HasGlyphwordActive('Glyphword 10 _Stats') || GetWitcherPlayer().HasGlyphwordActive('Glyphword 18 _Stats')) && (HasBuff(EET_AxiiGuardMe) || HasBuff(EET_Confusion)) ) //modSigns
		{
			if(GetWitcherPlayer().HasGlyphwordActive('Glyphword 10 _Stats')) //modSigns
				abilityName = 'Glyphword 10 _Stats';
			else
				abilityName = 'Glyphword 18 _Stats';
				
			min = thePlayer.GetAbilityAttributeValue(abilityName, 'glyphword_range');
			FindGameplayEntitiesInRange(entities, this, CalculateAttributeValue(min), 10,, FLAG_OnlyAliveActors + FLAG_ExcludeTarget, this); 	
			
			minDist = 10000;
			for (i = 0; i < entities.Size(); i += 1)
			{
				if ( entities[i] == thePlayer.GetHorseWithInventory() || entities[i] == thePlayer || !IsRequiredAttitudeBetween(thePlayer, entities[i], true) )
					continue;
					
				if ( VecDistance2D(this.GetWorldPosition(), entities[i].GetWorldPosition()) < minDist)
				{
					minDist = VecDistance2D(this.GetWorldPosition(), entities[i].GetWorldPosition());
					targetEntity = (CActor)entities[i];
				}
			}
			
			if ( targetEntity )
			{
				if ( HasBuff(EET_AxiiGuardMe) )
					gameplayEffect = GetBuff(EET_AxiiGuardMe);
				else if ( HasBuff(EET_Confusion) )
					gameplayEffect = GetBuff(EET_Confusion);
				
				params.effectType 				= gameplayEffect.GetEffectType();
				params.creator 					= gameplayEffect.GetCreator();
				params.sourceName 				= gameplayEffect.GetSourceName();
				params.duration 				= gameplayEffect.GetDurationLeft();
				if ( params.duration < 5.0f ) 	params.duration = 5.0f;
				params.effectValue 				= gameplayEffect.GetEffectValue();
				params.customAbilityName 		= gameplayEffect.GetAbilityName();
				params.customFXName 			= gameplayEffect.GetTargetEffectName();
				params.isSignEffect 			= gameplayEffect.IsSignEffect();
				params.customPowerStatValue 	= gameplayEffect.GetCreatorPowerStat();
				params.vibratePadLowFreq 		= gameplayEffect.GetVibratePadLowFreq();
				params.vibratePadHighFreq		= gameplayEffect.GetVibratePadHighFreq();
				
				targetEntity.AddEffectCustom(params);
				gameplayEffect = targetEntity.GetBuff(params.effectType);
				gameplayEffect.SetTimeLeft(params.duration);
				
				fxEnt = CreateFXEntityAtPelvis( 'glyphword_10_18', true );
				fxEnt.PlayEffect('out');
				fxEnt.DestroyAfter(5);
				
				fxEnt = targetEntity.CreateFXEntityAtPelvis( 'glyphword_10_18', true );
				fxEnt.PlayEffect('in');
				fxEnt.DestroyAfter(5);
			}
		}
		
		super.OnDeath( damageAction );
		
		if (!IsHuman() && damageAction.attacker == thePlayer && !ciriEntity && !HasTag('NoBestiaryEntry') ) AddBestiaryKnowledge();
		
		if ( !WillBeUnconscious() && !HasTag( 'NoHitFx' ) )
		{
			if ( theGame.GetWorld().GetWaterDepth( this.GetWorldPosition() ) > 0 )
			{
				if ( this.HasEffect( 'water_death' ) ) this.PlayEffectSingle( 'water_death' );
			}
			else
			{
				if ( this.HasEffect( 'blood_spill' ) && !HasAbility ( 'NoBloodSpill' ) ) this.PlayEffectSingle( 'blood_spill' );
			}
		}
		
		
		if ( ( ( CMovingPhysicalAgentComponent ) this.GetMovingAgentComponent() ).HasRagdoll() )
		{
			SetBehaviorVariable('HasRagdoll', 1 );
		}
		
		
		if ( (W3AardProjectile)( damageAction.causer ) )
		{
			DropItemFromSlot( 'r_weapon' );
			DropItemFromSlot( 'l_weapon' );
			this.BreakAttachment();
		}
		
		SignalGameplayEventParamObject( 'OnDeath', damageAction );
		theGame.GetBehTreeReactionManager().CreateReactionEvent( this, 'BattlecryGroupDeath', 1.0f, 20.0f, -1.0f, 1 );
		
		attackAction = (W3Action_Attack)damageAction;
		
		
		if ( ((CMovingPhysicalAgentComponent)GetMovingAgentComponent()).GetSubmergeDepth() < 0 )
		{
			inWater = true;
			DisableAgony();
		}
		
		
		if( IsUsingHorse() )
		{
			SoundEvent( "cmb_play_hit_heavy" );
			SoundEvent( "grunt_vo_death" );
		}
						
		if(damageAction.attacker == thePlayer && ((W3PlayerWitcher)thePlayer) && TUtil_NonZeroToxOrActivePotion() && thePlayer.CanUseSkill(S_Alchemy_s17)) // Triangle killing spree
		{
			thePlayer.AddAbilityMultiple( SkillEnumToName(S_Alchemy_s17), thePlayer.GetSkillLevel(S_Alchemy_s17) );
		}
		
		OnChangeDyingInteractionPriorityIfNeeded();
		
		actor = (CActor)damageAction.attacker;
		
		
		if(ShouldGiveExp(damageAction.attacker))
		{
			npcLevel = (int)CalculateAttributeValue(GetAttributeValue('level',,true));
			lvlDiff = npcLevel - witcher.GetLevel();
			expPoints = CalculateExperiencePoints();
			
			
			if(expPoints > 0)
			{				
				theGame.GetMonsterParamsForActor(this, monsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
				if(MonsterCategoryIsMonster(monsterCategory))
				{
					bonusExp = thePlayer.GetAttributeValue('nonhuman_exp_bonus_when_fatal');
				}
				else
				{
					bonusExp = thePlayer.GetAttributeValue('human_exp_bonus_when_fatal');
				}				
				
				//modSigns
				expPoints = RoundMath( expPoints * (1 + CalculateAttributeValue(bonusExp)) * theGame.expGlobalMod_kills );
				expPoints = Max(1, expPoints);
				//modSigns: final exp modifier
				if( theGame.params.GetMonsterExpModifier() != 0 )
					expPoints = RoundMath(expPoints * (1 + theGame.params.GetMonsterExpModifier()));
				GetWitcherPlayer().AddPoints(EExperiencePoint, expPoints, false );
				//modSigns: show exp given
				arrInt.PushBack(expPoints);
				theGame.witcherLog.AddMessage( GetLocStringByKeyExtWithParams("hud_combat_log_gained_experience", arrInt) );
			}			
		}
				
		
		attitudeToPlayer = GetAttitudeBetween(this, thePlayer);
		
		if(attitudeToPlayer == AIA_Hostile && !HasTag('AchievementKillDontCount'))
		{
			
			if(actor && actor.HasBuff(EET_AxiiGuardMe))
			{
				theGame.GetGamerProfile().IncStat(ES_CharmedNPCKills);
				FactsAdd("statistics_cerberus_sign");
			}
			
			
			if( aardedFlight && damageAction.GetBuffSourceName() == "FallingDamage" )
			{
				theGame.GetGamerProfile().IncStat(ES_AardFallKills);
			}
				
			
			if(damageAction.IsActionEnvironment())
			{
				theGame.GetGamerProfile().IncStat(ES_EnvironmentKills);
				FactsAdd("statistics_cerberus_environment");
			}
		}
		
		
		if(HasTag('cow'))
		{
			if( (damageAction.attacker == thePlayer) ||
				((W3SignEntity)damageAction.attacker && ((W3SignEntity)damageAction.attacker).GetOwner() == thePlayer) ||
				((W3SignProjectile)damageAction.attacker && ((W3SignProjectile)damageAction.attacker).GetCaster() == thePlayer) ||
				( (W3Petard)damageAction.attacker && ((W3Petard)damageAction.attacker).GetOwner() == thePlayer)
			){
				theGame.GetGamerProfile().IncStat(ES_KilledCows);
			}
		}
		
		
		if ( damageAction.attacker == thePlayer )
		{
			theGame.GetMonsterParamsForActor(this, monsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
			
			
			if(thePlayer.HasBuff(EET_Mutagen18))
			{
				
				
				if(monsterCategory != MC_Animal || IsRequiredAttitudeBetween(this, thePlayer, true))
				{			
					abilityName = thePlayer.GetBuff(EET_Mutagen18).GetAbilityName();
					abilityCount = thePlayer.GetAbilityCount(abilityName);
					
					if(abilityCount == 0)
					{
						addAbility = true;
					}
					else
					{
						theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen18_max_stack', min, max);
						maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
						
						if(maxStack >= 0)
						{
							addAbility = (abilityCount < maxStack);
						}
						else
						{
							addAbility = true;
						}
					}
					
					if(addAbility)
					{
						thePlayer.AddAbility(abilityName, true);
					}
				}
			}
			
			
			if (thePlayer.HasBuff(EET_Mutagen06))
			{
				
				if(monsterCategory != MC_Animal || IsRequiredAttitudeBetween(this, thePlayer, true))
				{	
					gameplayEffect = thePlayer.GetBuff(EET_Mutagen06);
					thePlayer.AddAbility( gameplayEffect.GetAbilityName(), true);
				}
			}
			
			
			if(IsRequiredAttitudeBetween(this, thePlayer, true))
			{
				blizzard = (W3Potion_Blizzard)thePlayer.GetBuff(EET_Blizzard);
				if(blizzard)
					blizzard.KilledEnemy();
			}
			
			
			if( witcher.IsSetBonusActive( EISB_Vampire ) && !witcher.IsInFistFight() && !WillBeUnconscious() )
			{
				witcher.VampiricSetAbilityRegeneration();
			}
			
			if(!HasTag('AchievementKillDontCount'))
			{
				if (damageAction.GetIsHeadShot() && monsterCategory == MC_Human )		
					theGame.GetGamerProfile().IncStat(ES_HeadShotKills);
					
				
				if( (W3SignEntity)damageAction.causer || (W3SignProjectile)damageAction.causer)
				{
					FactsAdd("statistics_cerberus_sign");
				}
				else if( (CBaseGameplayEffect)damageAction.causer && ((CBaseGameplayEffect)damageAction.causer).IsSignEffect())
				{
					FactsAdd("statistics_cerberus_sign");
				}
				else if( (W3Petard)damageAction.causer )
				{
					FactsAdd("statistics_cerberus_petard");
				}
				else if( (W3BoltProjectile)damageAction.causer )
				{
					FactsAdd("statistics_cerberus_bolt");
				}				
				else
				{
					if(!attackAction)
						attackAction = (W3Action_Attack)damageAction;
						
					fists = false;
					if(attackAction)
					{
						weaponID = attackAction.GetWeaponId();
						if(damageAction.attacker.GetInventory().IsItemFists(weaponID))
						{
							FactsAdd("statistics_cerberus_fists");
							fists = true;
						}						
					}
					
					if(!fists && damageAction.IsActionMelee())
					{
						FactsAdd("statistics_cerberus_melee");
					}
				}
			}
			
			
			if( expPoints > 0 && !HasTag( 'AchievementKillDontCount' ) && thePlayer.inv.HasItem( 'q705_tissue_extractor' ) )
			{
				thePlayer.TissueExtractorIncCharge();
			}
			
			
			if( (W3BoltProjectile)damageAction.causer && damageAction.GetWasFrozen() && !WillBeUnconscious() )
			{
				theGame.GetGamerProfile().AddAchievement( EA_HastaLaVista );
				thePlayer.PlayVoiceset( 100, "HastaLaVista", true );
			}
						
			
			
		}
		
		
		if( damageAction.attacker == thePlayer || !((CNewNPC)damageAction.attacker) )
		{
			theTelemetry.LogWithLabelAndValue(TE_FIGHT_ENEMY_DIES, this.ToString(), GetLevel());
		}
		
		
		if(damageAction.attacker == thePlayer && !HasTag('AchievementKillDontCount'))
		{
			if ( attitudeToPlayer == AIA_Hostile )
			{
				
				if(!HasTag('AchievementSwankDontCount'))
				{
					if(FactsQuerySum("statistic_killed_in_10_sec") >= 4)
						theGame.GetGamerProfile().AddAchievement(EA_Swank);
					else
						FactsAdd("statistic_killed_in_10_sec", 1, 10);
				}
				
				
				if( witcher && !thePlayer.ReceivedDamageInCombat() && !witcher.UsedQuenInCombat())
				{
					theGame.GetGamerProfile().IncStat(ES_FinesseKills);
				}
			}
			
			
			if((W3PlayerWitcher)thePlayer)
			{
				if(!thePlayer.DidFailFundamentalsFirstAchievementCondition() && HasTag(theGame.params.MONSTER_HUNT_ACTOR_TAG) && !HasTag('failedFundamentalsAchievement'))
				{
					theGame.GetGamerProfile().IncStat(ES_FundamentalsFirstKills);
				}
			}
		}
					
		
		if(!inWater && (W3IgniProjectile)damageAction.causer)
		{
			
			if(RandF() < 0.3 && !WillBeUnconscious() )
			{
				AddEffectDefault(EET_Burning, this, 'IgniKill', true);
				EnableAgony();
				SignalGameplayEvent('ForceAgony');			
			}
		}
		
		
		OnDeathMutation2( damageAction );		
		
		
		if(damageAction.attacker == thePlayer && GetWitcherPlayer().HasGlyphwordActive('Glyphword 20 _Stats') && damageAction.GetBuffSourceName() != "Glyphword 20") //modSigns
		{
			burningCauser = (W3Effect_Burning)damageAction.causer;			
			
			if(IsRequiredAttitudeBetween(thePlayer, damageAction.victim, true, false, false) && ((burningCauser && burningCauser.IsSignEffect()) || (W3IgniProjectile)damageAction.causer))
			{
				damageAction.SetForceExplosionDismemberment();
				
				
				radius = CalculateAttributeValue(thePlayer.GetAbilityAttributeValue('Glyphword 20 _Stats', 'radius'));
				
				
				theGame.GetDefinitionsManager().GetAbilityAttributes('Glyphword 20 _Stats', atts);
				for(i=0; i<atts.Size(); i+=1)
				{
					if(IsDamageTypeNameValid(atts[i]))
					{
						dmg.dmgType = atts[i];
						dmg.dmgVal = CalculateAttributeValue(thePlayer.GetAbilityAttributeValue('Glyphword 20 _Stats', dmg.dmgType));
						damages.PushBack(dmg);
					}
				}
				
				
				FindGameplayEntitiesInSphere(entities, GetWorldPosition(), radius, 1000, , FLAG_OnlyAliveActors);
				
				
				for(i=0; i<entities.Size(); i+=1)
				{
					if(IsRequiredAttitudeBetween(thePlayer, entities[i], true, false, false))
					{
						act = new W3DamageAction in this;
						act.Initialize(thePlayer, entities[i], damageAction.causer, "Glyphword 20", EHRT_Heavy, CPS_SpellPower, false, false, true, false);
						
						for(j=0; j<damages.Size(); j+=1)
						{
							act.AddDamage(damages[j].dmgType, damages[j].dmgVal);
						}
						
						act.AddEffectInfo(EET_Burning);//, , , , , 0.5f); //modSigns - 100% burning chance
						
						theGame.damageMgr.ProcessAction(act);
						delete act;
					}
				}
				
				CreateFXEntityAtPelvis( 'glyphword_20_explosion', false );				
			}
		}
		
		
		if(attackAction && IsWeaponHeld('fist') && damageAction.attacker == thePlayer && !thePlayer.ReceivedDamageInCombat() && !HasTag('AchievementKillDontCount'))
		{
			weaponID = attackAction.GetWeaponId();
			if(thePlayer.inv.IsItemFists(weaponID))
				theGame.GetGamerProfile().AddAchievement(EA_FistOfTheSouthStar);
		}
		
		
		if(damageAction.IsActionRanged() && damageAction.IsBouncedArrow())
		{
			theGame.GetGamerProfile().IncStat(ES_SelfArrowKills);
		}
		
		
		isFinisher = ( damageAction.GetBuffSourceName() == "Finisher" || damageAction.GetBuffSourceName() == "AutoFinisher" );
		if( damageAction.attacker == thePlayer && ( damageAction.IsActionMelee() || isFinisher ) )
		{			
			weaponID = attackAction.GetWeaponId();
			
			if( isFinisher && !thePlayer.inv.IsIdValid( weaponID ) )
			{
				weaponID = thePlayer.inv.GetCurrentlyHeldSword();
			}
			
			if( damageAction.attacker.GetInventory().ItemHasTag( weaponID, 'Aerondight' ) )
			{
				aerondight = (W3Effect_Aerondight)thePlayer.GetBuff( EET_Aerondight );
				
				if( aerondight )				
				{
					if( aerondight.IsFullyCharged() )
					{
						if( aerondight.DischargeAerondight() )
						{
							PlayEffect( 'hit_electric_quen' );
						}
					}
					else if( isFinisher )
					{
						aerondight.IncreaseAerondightCharges( theGame.params.ATTACK_NAME_LIGHT );
					}
				}
			}
		}		
		ProcessHugeMutationSize(); // Triangle enemy mutations This maybe does something
	}
	
	
	private final function OnDeathMutation2( out damageAction : W3DamageAction )
	{
		var burning : W3Effect_Burning;
		var vfxEnt : W3VisualFx;
		var fxName : name;
		
		
		if( !damageAction.IsMutation2PotentialKill() )
		{
			return;
		}
		
		
		burning = ( W3Effect_Burning ) damageAction.causer;		
		if( burning && burning.IsFromMutation2() )
		{				
			damageAction.SetSignSkill( S_Magic_2 );
		}
		
		
		damageAction.SetForceExplosionDismemberment();
		vfxEnt = ( W3VisualFx ) CreateFXEntityAtPelvis( 'mutation_2_explode', false );
		if( vfxEnt )
		{
			if ( (W3IgniProjectile)damageAction.causer )
			{
				fxName = 'mutation_2_igni';
			}
			else if ( (W3YrdenEntityStateYrdenShock)damageAction.causer )
			{
				fxName = 'mutation_2_yrden';
			}
			else if ( (W3QuenEntity)damageAction.causer )
			{
				fxName = 'mutation_2_quen';
			}
			else if ( (W3AardProjectile)damageAction.causer )
			{
				fxName = 'mutation_2_aard';
			}
			
			vfxEnt.PlayEffect( fxName );
			vfxEnt.DestroyOnFxEnd( fxName );
		}
	}
	
	event OnChangeDyingInteractionPriorityIfNeeded()
	{
		if ( WillBeUnconscious() )
			return true;
		if ( HasTag('animal') )
		{
			return true;
		}
			
		
		this.SetInteractionPriority(IP_Max_Unpushable);
	}
	
	
	
	public final function IsImmuneToMutation8Finisher() : bool
	{
		var min, max : SAbilityAttributeValue;
		var str : string;
		
		if( !IsHuman() || !IsAlive() || !IsRequiredAttitudeBetween( thePlayer, this, true ) )
		{
			return true;
		}
		
		if( HasAbility( 'SkillBoss' ) )
		{
			return true;
		}
		if( HasAbility( 'Boss' ) )
		{
			return true;
		}
		if( HasAbility( 'InstantKillImmune' ) )
		{
			return true;
		}
		if( HasTag( 'olgierd_gpl' ) )
		{
			return true;
		}
		if( HasAbility( 'DisableFinishers' ) )
		{
			return true;
		}
		if( HasTag( 'Mutation8CounterImmune' ) )
		{
			return true;
		}
		
		if( WillBeUnconscious() )
		{
			return true;
		}
		
		str = GetName();
		if( StrStartsWith( str, "rosa_var_attre" ) )
		{
			return true;
		}
				
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation8', 'hp_perc_trigger', min, max );
		if( GetHealthPercents() > min.valueMultiplicative )
		{
			return true;
		}
		
		return false;
	}
	
	event OnFireHit(source : CGameplayEntity)
	{	
		super.OnFireHit(source);
		
		if ( HasTag('animal') )
		{
			Kill( 'Animal hit by fire', source );
		}
		
		if ( !IsAlive() && IsInAgony() )
		{
			
			SignalGameplayEvent('AbandonAgony');
			
			SetKinematic(false);
		}
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		//var staminaDrainPerc : float;		//modSigns
		
		SignalGameplayEvent( 'AardHitReceived' );
		
		aardedFlight = true;
		
		// Triangle enemy mutations
		BlockAbility(TUtil_TEMutationEnumToName(TEM_Flaming), true, TOpts_ElectricCooldown());
		// Triangle far reaching aard
		if (TOpts_AardStaminaDelay() > 0 && sign.GetOwner().GetPlayer() && sign.GetOwner().GetPlayer().CanUseSkill(S_Magic_s20))
			DrainStamina(ESAT_FixedValue, GetStatMax(BCS_Stamina), TOpts_AardStaminaDelay() * (sign.GetOwner().GetPlayer().GetSkillLevel(S_Magic_s20) / 3));
		// Triangle end
		
		if( !sign.GetOwner().GetPlayer() || !GetWitcherPlayer().IsMutationActive( EPMT_Mutation6 ) )
		{
			RemoveAllBuffsOfType(EET_Frozen);
		}
		
		
		
		
		super.OnAardHit(sign);
		
		if ( HasTag('small_animal') )
		{
			Kill( 'Small Animal Aard Hit' );
		}
		if ( IsShielded(sign.GetCaster()) )
		{
			ToggleEffectOnShield('aard_cone_hit', true);
		}
		else if ( HasAbility('ablIgnoreSigns') )
		{
			this.SignalGameplayEvent( 'IgnoreSigns' );
			this.SetBehaviorVariable( 'bIgnoreSigns',1.f );
			AddTimer('IgnoreSignsTimeOut',0.2,false);
		}
		
		
		/*staminaDrainPerc = sign.GetStaminaDrainPerc(); //modSigns: moved to sign projectile
		if(IsAlive() && staminaDrainPerc > 0.f && IsRequiredAttitudeBetween(this, sign.GetCaster(), true))
		{
			DrainStamina(ESAT_FixedValue, staminaDrainPerc * GetStatMax(BCS_Stamina), 1); //modSigns: delay added
			//modSigns: debug
			//theGame.witcherLog.AddMessage("Stamina drained = " + GetStat(BCS_Stamina));
		}*/
		
		if ( !IsAlive() && deathTimestamp + 0.2 < theGame.GetEngineTimeAsSeconds() )
		{
			
			SignalGameplayEvent('AbandonAgony');
			
			
			
			if( !HasAbility( 'mon_bear_base' )
				&& !HasAbility( 'mon_golem_base' )
				&& !HasAbility( 'mon_endriaga_base' )
				&& !HasAbility( 'mon_gryphon_base' )
				&& !HasAbility( 'q604_shades' )
				&& !IsAnimal()	)
			{			
				
				SetKinematic( false );
			}
		}
	}

	event OnAxiiHit( sign : W3AxiiProjectile )
	{
		super.OnAxiiHit(sign);

		// Triangle enemy mutations
		BlockAbility(TUtil_TEMutationEnumToName(TEM_Hypnotic), true, TOpts_ElectricCooldown());
		// Triangle end
		
		if ( HasAbility('ablIgnoreSigns') )
		{
			this.SignalGameplayEvent( 'IgnoreSigns' );
			this.SetBehaviorVariable( 'bIgnoreSigns',1.f );
			AddTimer('IgnoreSignsTimeOut',0.2,false);
		}
	}
	
	private const var SHIELD_BURN_TIMER : float;
	default SHIELD_BURN_TIMER = 1.0;
	
	private var beingHitByIgni : bool;
	private var firstIgniTick, lastIgniTick : float;
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		var horseComponent : W3HorseComponent;
		super.OnIgniHit( sign );

		// Triangle enemy mutations
		BlockAbility(TUtil_TEMutationEnumToName(TEM_Freezing), true, TOpts_ElectricCooldown());
		// Triangle end

		
		SignalGameplayEvent( 'IgniHitReceived' );
		
		if ( HasAbility( 'ablIgnoreSigns') )
		{
			this.SignalGameplayEvent( 'IgnoreSigns' );
			this.SetBehaviorVariable('bIgnoreSigns',1.f);
			AddTimer('IgnoreSignsTimeOut',0.2,false);
		}
		
		if ( HasAbility( 'IceArmor') )
		{
			this.RemoveAbility( 'IceArmor' );
			this.StopEffect( 'ice_armor' );
			this.PlayEffect( 'ice_armor_hit' );
		}
		
		if( IsShielded( sign.GetCaster() ) )
		{
			if( sign.IsProjectileFromChannelMode() )
			{
				SignalGameplayEvent( 'BeingHitByIgni' );
				
				if( !beingHitByIgni )
				{
					beingHitByIgni = true;
					firstIgniTick = theGame.GetEngineTimeAsSeconds();
					ToggleEffectOnShield( 'burn', true );
					RaiseShield();
				}
				
				if( firstIgniTick + SHIELD_BURN_TIMER < theGame.GetEngineTimeAsSeconds() )
				{
					ProcessShieldDestruction();
					return false;
				}

				AddTimer( 'IgniCleanup', 0.2, false );
			}
			else
			{
				ToggleEffectOnShield( 'igni_cone_hit', true );
			}
		}
		
		horseComponent = GetHorseComponent();
		if ( horseComponent )
			horseComponent.OnIgniHit(sign);
		else
		{
			horseComponent = GetUsedHorseComponent();
			if ( horseComponent )
				horseComponent.OnIgniHit(sign);
		}
	}
	
	public function IsBeingHitByIgni() : bool
	{
		return beingHitByIgni;
	}
	
	function ToggleEffectOnShield(effectName : name, toggle : bool)
	{
		var itemID : SItemUniqueId;
		var inv : CInventoryComponent;
		
		inv = GetInventory();
		itemID = inv.GetItemFromSlot('l_weapon');
		if ( toggle )
			inv.PlayItemEffect(itemID,effectName);
		else
			inv.StopItemEffect(itemID,effectName);
	}
	
	timer function IgniCleanup( dt : float , id : int)
	{
		if( beingHitByIgni )
		{
			ToggleEffectOnShield( 'burn', false );
			AddTimer( 'LowerShield', 0.5 );
			beingHitByIgni = false;
		}
	}
	
	timer function IgnoreSignsTimeOut( dt : float , id : int)
	{
		this.SignalGameplayEvent( 'IgnoreSignsEnd' );
		this.SetBehaviorVariable( 'bIgnoreSigns',0.f);
	}
	
		
	
	function SetIsTeleporting( b : bool )
	{
		isTeleporting = b;
	}
	
	function IsTeleporting() : bool
	{
		return isTeleporting;
	}

	final function SetUnstoppable( toggle : bool )
	{
		unstoppable = toggle;
	}
	
	final function IsUnstoppable() : bool
	{
		return unstoppable;
	}
	
	final function SetIsCountering( toggle : bool )
	{
		bIsCountering = toggle;
	}
	
	final function IsCountering() : bool
	{
		return bIsCountering;
	}
	
	
	timer function Tick(deltaTime : float, id : int)
	{
		
		
	}
	
	private function UpdateBumpCollision()
	{
		var npc				: CNewNPC;
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var i				: int;
		
		
		
		
		
		if( mac )
		{
			
			collisionNum	= mac.GetCollisionCharacterDataCount();
			for( i = 0; i < collisionNum; i += 1 )
			{
				collisionData	= mac.GetCollisionCharacterData( i );
				npc	= ( CNewNPC ) collisionData.entity;
				if( npc ) 
				{
					this.SignalGameplayEvent( 'AI_GetOutOfTheWay' ); 					
					this.SignalGameplayEventParamObject( 'CollideWithPlayer', npc );	
					theGame.GetBehTreeReactionManager().CreateReactionEvent( this, 'BumpAction', 1, 1, 1, 1, false );
					
					
					break;
				}
			}
		}
	}


	public function SetIsTranslationScaled(b : bool)						{isTranslationScaled = b;}
	public function GetIsTranslationScaled() : bool						{return isTranslationScaled;}	
	
	
	import final function GetActiveActionPoint() : SActionPointId;


	
	
	

	
	
	
	import final function IsInInterior() : bool;	
	
	
	import final function IsInDanger() : bool;
	
	
	import final function IsSeeingNonFriendlyNPC() : bool;

	
	import final function IsAIEnabled() : bool;
	
	
	import final function FindActionPoint( out apID : SActionPointId, out category : name );
			
	
	import final function GetDefaultDespawnPoint( out spawnPoint : Vector ) : bool;
	

	
	import final function NoticeActor( actor : CActor );
	
	
	import final function ForgetActor( actor : CActor );
	
	
	import final function ForgetAllActors();
	
	
	import final function GetNoticedObject( index : int) : CActor;
	
	

	import final function GetPerceptionRange() : float;
		
	
	
	import final function PlayDialog( optional forceSpawnedActors : bool ) : bool;
 
	
	
	
	import final function GetReactionScript( index : int ) : CReactionScript;
	
	import final function IfCanSeePlayer() : bool;
	
	import final function GetGuardArea() : CAreaComponent;
	import final function SetGuardArea( areaComponent : CAreaComponent );
	import final function DeriveGuardArea( ncp : CNewNPC ) : bool;
	
	import final function IsConsciousAtWork() : bool;
	import final function GetCurrentJTType() : int;
	import final function IsInLeaveAction() : bool;
	import final function IsSittingAtWork() : bool;
	import final function IsAtWork() : bool;
	import final function IsPlayingChatScene() : bool;
	import final function CanUseChatInCurrentAP() : bool;
	
	
	import final function NoticeActorInGuardArea( actor : CActor );
	
	
	
	
	event OnAnimEvent_EquipItemL( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		GetInventory().MountItem( itemToEquip, true );
	}
	event OnAnimEvent_HideItemL( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		GetInventory().UnmountItem( itemToEquip, true );
	}
	event OnAnimEvent_HideWeapons( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var inventory 	: CInventoryComponent = GetInventory();
		var ids 		: array<SItemUniqueId>;
		var i 			: int;
		
		ids = inventory.GetAllWeapons();
		for( i = 0; i < ids.Size() ; i += 1 )
		{
			if( inventory.IsItemHeld( ids[i] ) || inventory.IsItemMounted( ids[i] ) )
				inventory.UnmountItem( ids[i], true );
		}
	}
	
	event OnAnimEvent_TemporaryOffGround( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventType == AET_DurationEnd )
		{
			isTemporaryOffGround = false;
		}
		else
		{
			isTemporaryOffGround = true;
		}
	}
	event OnAnimEvent_weaponSoundType( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		WeaponSoundType().SetupDrawHolsterSounds();
	}
	
	event OnAnimEvent_IdleDown( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'idleType', 0.0 );
	}
	
	event OnAnimEvent_IdleForward( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'idleType', 1.0 );
	}
	
	event OnAnimEvent_IdleCombat( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'idleType', 2.0 );
	}
	
	event OnAnimEvent_WeakenedState( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetWeakenedState( true );
	}
	
	event OnAnimEvent_WeakenedStateOff( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetWeakenedState( false );
	}
	
	public function SetWeakenedState( val : bool )
	{
		if( val )
		{
			if( HasTag( 'olgierd_gpl' ) )
			{
				AddAbility( 'WeakenedState', false );
				SetBehaviorVariable( 'weakenedState', 1.0 );
				PlayEffect( 'olgierd_energy_blast' );
				
				if( HasTag( 'ethereal' ) && !HasAbility( 'EtherealSkill_4' ) )
				{
					AddAbility( 'EtherealMashingFixBeforeSkill4' );
				}
			}
			else if( HasTag( 'dettlaff_vampire' ) )
			{
				AddAbility( 'DettlaffWeakenedState', false );
				StopEffect( 'shadowdash' );
				PlayEffect( 'weakened' );
				SetHitWindowOpened( false );
			}
			
			AddTimer( 'ResetHitCounter', 0.0, false );
		}
		else
		{
			if( HasTag( 'olgierd_gpl' ) )
			{
				RemoveAbility( 'WeakenedState' );
				SetBehaviorVariable( 'weakenedState', 0.0 );
				StopEffect( 'olgierd_energy_blast' );
				
				if( HasTag( 'ethereal' ) && !HasAbility( 'EtherealSkill_4' ) )
				{
					RemoveAbility( 'EtherealMashingFixBeforeSkill4' );
				}
			}
			else if( HasTag( 'dettlaff_vampire' ) )
			{
				RemoveAbility( 'DettlaffWeakenedState' );
				StopEffect( 'weakened' );
			}
		}
	}
	
	public function SetHitWindowOpened( val : bool )
	{
		if( val )
		{
			AddAbility( 'HitWindowOpened', false );
			SetBehaviorVariable( 'hitWindowOpened', 1.0 );
			
			if( HasTag( 'fairytale_witch' ) )
			{
				SetImmortalityMode( AIM_None, AIC_Combat );
			}
			
			if( HasTag( 'dettlaff_vampire' ) )
			{
				AddBuffImmunity( EET_Burning, 'SetHitWindowOpened', true );
			}
		}
		else
		{
			RemoveAbility( 'HitWindowOpened' );
			SetBehaviorVariable( 'hitWindowOpened', 0.0 );
			
			if( HasTag( 'fairytale_witch' ) )
			{
				SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
			}
			
			if( HasTag( 'dettlaff_vampire' ) )
			{
				RemoveBuffImmunity( EET_Burning, 'SetHitWindowOpened' );
			}
		}
	}

	event OnAnimEvent_WindowManager( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName == 'OpenHitWindow' )
		{
			SetHitWindowOpened( true );
		}
		else if( animEventName == 'CloseHitWindow' )
		{
			SetHitWindowOpened( false );
		}
		else if( animEventName == 'OpenCounterWindow' )
		{
			SetBehaviorVariable( 'counterHitType', 1.0 );
			AddTimer( 'CloseHitWindowAfter', 0.75 );
		}
	}
	
	event OnAnimEvent_CauldronDropped( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		DropItemFromSlot( 'l_weapon', true );
		SetBehaviorVariable( 'cauldronDropped', 1.0 );
	}
	
	event OnAnimEvent_BroomDeath( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var witch : CNewNPC;
		
		witch = theGame.GetNPCByTag( 'fairytale_witch' );
		if( witch )
		{
			witch.SetBehaviorVariable( 'canDropCauldron', 1.0 );
		}
	}
	
	event OnAnimEvent_ToggleIsOverground( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName == 'SetIsUnderground' )
		{
			ToggleIsOverground( false );
		}
		else if( animEventName == 'SetIsOverground' )
		{
			ToggleIsOverground( true );
		}
	}
	
	public function ToggleIsOverground( val : bool )
	{
		if( val )
		{
			SetBehaviorVariable( 'isOverground', 1.0 );
			EnableCollisions( true );
			EnableCharacterCollisions( true );
			SetGameplayVisibility( true );
			SetImmortalityMode( AIM_None, AIC_Combat );
			SetUnstoppable( false );
			RemoveTag( 'isHiddenUnderground' );
			RemoveBuffImmunity( EET_Frozen, 'ToggleIsOverground' );
		}
		else
		{
			SetBehaviorVariable( 'isOverground', 0.0 );
			EnableCollisions( false );
			EnableCharacterCollisions( false );
			SetGameplayVisibility( false );
			SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
			SetUnstoppable( true );
			AddTag( 'isHiddenUnderground' );
			AddBuffImmunity( EET_Frozen, 'ToggleIsOverground', true );
		}
	}
	
	event OnAnimEvent_CannotBeAttacked( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		AddAbility( 'CannotBeAttackedFromAllSides', false );
	}

	event OnAnimEvent_SlideAway( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		var slidePos 			: Vector;
		var slideDuration		: float;
		
		movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.CancelByName( 'SlideAway' );
		
		ticket = movementAdjustor.CreateNewRequest( 'SlideAway' );
		slidePos = GetWorldPosition() + ( VecNormalize2D( GetWorldPosition() - thePlayer.GetWorldPosition() ) * 0.75 );
		
		if( theGame.GetWorld().NavigationLineTest( GetWorldPosition(), slidePos, GetRadius(), false, true ) ) 
		{
			slideDuration = VecDistance2D( GetWorldPosition(), slidePos ) / 35;
			
			movementAdjustor.Continuous( ticket );
			movementAdjustor.AdjustmentDuration( ticket, slideDuration );
			movementAdjustor.AdjustLocationVertically( ticket, true );
			movementAdjustor.BlendIn( ticket, 0.25 );
			movementAdjustor.SlideTo( ticket, slidePos );
			movementAdjustor.RotateTowards( ticket, GetTarget() );
		}

		return true;	
	}
	
	event OnAnimEvent_SlideForward( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		var slidePos 			: Vector;
		var slideDuration		: float;
		
		movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.CancelByName( 'SlideForward' );
		
		ticket = movementAdjustor.CreateNewRequest( 'SlideForward' );
		slidePos = GetWorldPosition() + ( VecNormalize2D( GetWorldPosition() - thePlayer.GetWorldPosition() ) * 0.75 );
		
		if( theGame.GetWorld().NavigationLineTest( GetWorldPosition(), slidePos, GetRadius(), false, true ) ) 
		{
			slideDuration = VecDistance2D( GetWorldPosition(), slidePos ) / 35;
			
			movementAdjustor.Continuous( ticket );
			movementAdjustor.AdjustmentDuration( ticket, slideDuration );
			movementAdjustor.AdjustLocationVertically( ticket, true );
			movementAdjustor.BlendIn( ticket, 0.25 );
			movementAdjustor.SlideTo( ticket, slidePos );
		}

		return true;	
	}
	
	event OnAnimEvent_SlideTowards( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		
		movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.CancelByName( 'SlideTowards' );
		
		ticket = movementAdjustor.CreateNewRequest( 'SlideTowards' );

		movementAdjustor.AdjustLocationVertically( ticket, true );
		movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
		movementAdjustor.MaxLocationAdjustmentSpeed( ticket, 4 );
		movementAdjustor.ScaleAnimation( ticket );
		movementAdjustor.SlideTowards( ticket, thePlayer, 1.0, 1.25 );
		movementAdjustor.RotateTowards( ticket, GetTarget() );

		return true;	
	}
	
	event OnAnimEvent_PlayBattlecry( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName == 'BC_Sign' )
		{
			PlayVoiceset( 100, "q601_olgierd_taunt_sign" );
		}
		else if( animEventName == 'BC_Taunt' )
		{
			PlayVoiceset( 100, "q601_olgierd_taunt" );
		}
		else
		{
			if( RandRange( 100 ) < 75 )
			{
				if( animEventName == 'BC_Weakened' )
				{
					PlayVoiceset( 100, "q601_olgierd_weakened" );
				}
				else if( animEventName == 'BC_Attack' )
				{
					PlayVoiceset( 100, "q601_olgierd_fast_attack" );
				}
				else if( animEventName == 'BC_Parry' )
				{
					PlayVoiceset( 100, "q601_olgierd_taunt_parry" );
				}
				else
				{
					return false;
				}
			}
		}
	}
	
	
	event OnAnimEvent_OwlSwitchOpen( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAppearance('owl_01');
	}
	
	event OnAnimEvent_OwlSwitchClose( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAppearance('owl_02');
	}
	
	event OnAnimEvent_Goose01OpenWings( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAppearance('goose_01_wings');
	}
	
	event OnAnimEvent_Goose01CloseWings( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAppearance('goose_01');
	}
	
	event OnAnimEvent_Goose02OpenWings( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAppearance('goose_02_wings');
	}
	
	event OnAnimEvent_Goose02CloseWings( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAppearance('goose_02');
	}

	event OnAnimEvent_NullifyBurning( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		RemoveAllBuffsOfType(EET_Burning);
	}

	event OnAnimEvent_setVisible( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetVisibility( true );
		SetGameplayVisibility( true );
	}
	
	event OnAnimEvent_extensionWalk( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'UsesExtension', 1 );
		SetBehaviorVariable( 'WalkExtensionAnimSpeed', 0.1 );
		SetBehaviorVariable( 'WalkTransitionAnimSpeed', 0.5 );
	}
	
	event OnAnimEvent_extensionWalkNormalSpeed( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'UsesExtension', 1 );
		SetBehaviorVariable( 'WalkExtensionAnimSpeed', 1.0 );
		SetBehaviorVariable( 'WalkTransitionAnimSpeed', 0.5 );
	}
	
	event OnAnimEvent_extensionWalkRightHandOnly( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'UsesExtension', 2 );
		SetBehaviorVariable( 'WalkExtensionAnimSpeed', 0.1 );
	}
	
	event OnAnimEvent_extensionWalkStartStopNormalSpeed( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'UsesExtension', 3 );
		SetBehaviorVariable( 'WalkExtensionAnimSpeed', 1.0 );
		SetBehaviorVariable( 'WalkTransitionAnimSpeed', 0.5 );
	}
	
	event OnAnimEvent_disableCrowdOverride( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'disableCrowdOverride', 1 );
	}
	
	event OnAnimEvent_ActivateSide( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var template 	: CEntityTemplate;
		var entity 		: CEntity;
		var spawnPos 	: Vector;
		var spawnRot 	: EulerAngles;
		
		template = ( CEntityTemplate )LoadResource( 'dolphin' );
		
		
		spawnRot = GetWorldRotation();
		spawnRot.Yaw += 180;
		spawnPos = GetWorldPosition() - 1.5 * VecNormalize( VecFromHeading( spawnRot.Yaw + 180 )) + 1 * VecNormalize( VecFromHeading( spawnRot.Yaw + 90 ));
		entity = theGame.CreateEntity( template, spawnPos, spawnRot );
		entity.SetBehaviorVariable( 'side', 1 );
		entity.SetBehaviorVariable( 'alternate', 0 );
		
		
		
		spawnPos = GetWorldPosition() + 1.5 * VecNormalize( VecFromHeading( spawnRot.Yaw + 180 )) + 1 * VecNormalize( VecFromHeading( spawnRot.Yaw + 90 ));
		entity = theGame.CreateEntity( template, spawnPos, spawnRot );
		entity.SetBehaviorVariable( 'side', 1 );
		entity.SetBehaviorVariable( 'alternate', 1 );
		
	}
	
	event OnAnimEvent_ActivateUp( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var template 	: CEntityTemplate;
		var entity 		: CEntity;
		var spawnPos 	: Vector;
		var spawnRot 	: EulerAngles;
		
		template = ( CEntityTemplate )LoadResource( 'dolphin' );
		
		
		spawnRot = GetWorldRotation();
		spawnRot.Yaw += 180;
		spawnPos = GetWorldPosition() + 0.0 * VecNormalize( VecFromHeading( spawnRot.Yaw + 180 )) - 8 * VecNormalize( VecFromHeading( spawnRot.Yaw + 90 ));
		entity = theGame.CreateEntity( template, spawnPos, spawnRot );
		entity.SetBehaviorVariable( 'up', 1 );
		entity.SetBehaviorVariable( 'alternate', 0 );
		
		
		
		spawnPos = GetWorldPosition() + 0.0 * VecNormalize( VecFromHeading( spawnRot.Yaw + 180 )) + 8 * VecNormalize( VecFromHeading( spawnRot.Yaw + 90 ));
		entity = theGame.CreateEntity( template, spawnPos, spawnRot );
		entity.SetBehaviorVariable( 'up', 1 );
		entity.SetBehaviorVariable( 'alternate', 1 );
		
	}
	
	event OnAnimEvent_DeactivateSide( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'up', 0 );
		SetBehaviorVariable( 'side', 0 );
		DestroyAfter( 5.0 );
		SetVisibility( false ); 
		
	}
	
	event OnAnimEvent_DeactivateUp( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'up', 0 );
		SetBehaviorVariable( 'side', 0 );
		DestroyAfter( 5.0 );
		SetVisibility( false ); 
		
	}
	
	event OnAnimEvent_BruxaJumpFailsafe( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		PlayEffect( 'appear' );
		SignalGameplayEvent( 'appeared' );
		SetBehaviorVariable( 'inAir', 0, true );
		SetBehaviorVariable( 'vanished', 0, true );
		SetBehaviorVariable( 'invisible', 0, true );
		SetGameplayVisibility( true );
	}
	
	event OnAnimEvent_ResetOneTimeSpawnActivation( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SignalGameplayEvent( 'ResetOneTimeSpawnActivation' );
	}
	
	
	
	event OnEquippedItem( category : name, slotName : name )
	{
		if ( slotName == 'r_weapon' )
		{
			switch( category )
			{			
				case 'axe1h':
				case 'axe2h':
					SetBehaviorVariable( 'EquippedItemR', (int) RIT_Axe );
					break;		
				case 'halberd2h':
					SetBehaviorVariable( 'EquippedItemR', (int) RIT_Halberd );
					break;
				case 'steelsword' :
				case 'silversword' :
					SetBehaviorVariable( 'EquippedItemR', (int) RIT_Sword );
					break;
				case 'crossbow' :
					SetBehaviorVariable( 'EquippedItemR', (int) RIT_Crossbow );
					break;
				default:
					SetBehaviorVariable( 'EquippedItemR', (int) RIT_None );
					break;
			}
		}
		else if ( slotName == 'l_weapon' )
		{
			switch( category )
			{
				case 'shield' :
					SetBehaviorVariable( 'EquippedItemL', (int) LIT_Shield );
					break;
				case 'bow' :
					SetBehaviorVariable( 'EquippedItemL', (int) LIT_Bow );
					break;
				case 'usable' :
					SetBehaviorVariable( 'EquippedItemL', (int) LIT_Torch );
					break;
				default:
					SetBehaviorVariable( 'EquippedItemL', (int) LIT_None );
					break;
			}
		}
		
		if ( category != 'fist' && category != 'work' && category != 'usable' && IsInCombat() && GetTarget() == thePlayer && thePlayer.GetTarget() == this )
			thePlayer.OnTargetWeaponDrawn();
	}
	
	event OnHolsteredItem( category : name, slotName : name )
	{
		if ( slotName == 'r_weapon' )
		{
			SetBehaviorVariable( 'EquippedItemR', (int) RIT_None );
		}
		else if ( slotName == 'l_weapon' )
		{
			SetBehaviorVariable( 'EquippedItemL', (int) LIT_None );
		}
	}
	
	function IsTalkDisabled () : bool
	{
		return isTalkDisabled || isTalkDisabledTemporary;
	}
	
	public function DisableTalking( disable : bool, optional temporary : bool )
	{		
		if ( temporary )
		{
			isTalkDisabledTemporary = disable;
		}
		else
		{
			isTalkDisabled = disable;
		}
	}

	public function CanStartTalk() : bool
	{
		
		if( IsAtWork() && !IsConsciousAtWork() || IsTalkDisabled () )
			return false;
			
		if(HasBuff(EET_AxiiGuardMe) || HasBuff(EET_Confusion))
			return false;
			
		return !IsFrozen() && CanTalk( true );
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var horseComponent		: W3HorseComponent;
		var ciriEntity  		: W3ReplacerCiri;
		var isAtWork			: bool;
		var isConciousAtWork 	: bool;
		
		LogChannel( 'DialogueTest', "Event Interaction Used" );
		if ( actionName == "Talk" )
		{	
			LogChannel( 'DialogueTest', "Activating TALK Interaction - PLAY DIALOGUE" );
			
			if ( !PlayDialog() )
			{
				
				
				EnableDynamicLookAt( thePlayer, 5 );
				ciriEntity = (W3ReplacerCiri)thePlayer;
				if ( ciriEntity )
				{
				}
				else
				{
					
					if( !IsAtWork() || IsConsciousAtWork() )
					{
						PlayVoiceset(100, "greeting_geralt" );
					}
					else
						PlayVoiceset(100, "sleeping" );
					
					wasInTalkInteraction = true;
					AddTimer( 'ResetTalkInteractionFlag', 1.0, true, , , true);
				}
			}
		}
		if ( actionName == "Finish" )
		{
			
		}
		else if( actionName == "AxiiCalmHorse" )
		{
			SignalGameplayEvent( 'HorseAxiiCalmDownStart' );
		}
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		var stateName : name;
		var horseComp : W3HorseComponent;
		
		if( interactionComponentName == "talk" )
		{
			if( activator == thePlayer && thePlayer.CanStartTalk() && CanStartTalk() )
			{	
				return true;
			}
		}
		else if( interactionComponentName == "Finish" && activator == thePlayer )
		{
			stateName = thePlayer.GetCurrentStateName();
			if( stateName == 'CombatSteel' || stateName == 'CombatSilver' )
				return true;
		}
		else if( interactionComponentName == "horseMount" && activator == thePlayer )
		{
			if( !thePlayer.IsActionAllowed( EIAB_MountVehicle ) || thePlayer.IsInAir() )
				return false;
			if ( horseComponent.IsInHorseAction() || !IsAlive() )
				return false;
			if ( GetAttitudeBetween(this,thePlayer) == AIA_Hostile && !( HasBuff(EET_Confusion) || HasBuff(EET_AxiiGuardMe) ) )
				return false;
			
			if( mac.IsOnNavigableSpace() )
			{
				if( theGame.GetWorld().NavigationLineTest( activator.GetWorldPosition(), this.GetWorldPosition(), 0.05, false, true ) ) 
				{
					
					if( theGame.TestNoCreaturesOnLine( activator.GetWorldPosition(), this.GetWorldPosition(), 0.4, (CActor)activator, this, true ) ) 
					{
						return true;
					}
					
					return false;
				}
			}
			else
			{
				horseComp = this.GetHorseComponent();
				
				if( horseComp )
				{
					horseComp.mountTestPlayerPos = activator.GetWorldPosition();
					horseComp.mountTestPlayerPos.Z += 0.5;
					horseComp.mountTestHorsePos = this.GetWorldPosition();
					horseComp.mountTestHorsePos.Z += 0.5;
					
					if( !theGame.GetWorld().StaticTrace( horseComp.mountTestPlayerPos, horseComp.mountTestHorsePos, horseComp.mountTestEndPos, horseComp.mountTestNormal, horseComp.mountTestCollisionGroups ) )
					{
						return true;
					}
				}
				
				return false;
			}
		}
		
		
		
		return false;	
	}
	
	event OnInteractionTalkTest()
	{
		return CanStartTalk();		
	}

	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		
		
		
		
		
		
	}
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		
		
		
		
	}

	
	
	
	
	
		
		
		
	
	
	event OnBehaviorGraphNotification( notificationName : name, stateName : name )
	{
		var i: int;		
		for ( i = 0; i < behaviorGraphEventListened.Size(); i += 1 )
		{
			if( behaviorGraphEventListened[i] == notificationName )
			{
				SignalGameplayEventParamCName( notificationName, stateName );
			}
		}
		super.OnBehaviorGraphNotification( notificationName, stateName );
	}
	
	public function ActivateSignalBehaviorGraphNotification( notificationName : name )
	{
		if( !behaviorGraphEventListened.Contains( notificationName ) )
		{
			behaviorGraphEventListened.PushBack( notificationName );
		}
	}
	
	public function DeactivateSignalBehaviorGraphNotification( notificationName : name )
	{
		behaviorGraphEventListened.Remove( notificationName );
	}
	
	
	
	
	
	timer function RemoveMutation4BloodDebuff( dt : float, id : int )
	{
		RemoveAbility( 'Mutation4BloodDebuff' );
	}
	
	function IsShielded( target : CNode ) : bool
	{
		var targetToSourceAngle	: float;
		var protectionAngleLeft, protectionAngleRight : float;
		
		if( target )
		{
			if( HasShieldedAbility() && IsGuarded() )
			{
				targetToSourceAngle = NodeToNodeAngleDistance(target, this);
				protectionAngleLeft = CalculateAttributeValue( this.GetAttributeValue( 'protection_angle_left' ) );
				protectionAngleRight = CalculateAttributeValue( this.GetAttributeValue( 'protection_angle_right' ) );
				
				
				if( targetToSourceAngle < protectionAngleRight && targetToSourceAngle > protectionAngleLeft )
				{
					return true;
				}
			}
			return false;
		}
		else
			return HasShieldedAbility() && IsGuarded();
	}
	
	function HasShieldedAbility() : bool
	{
		var attval : float;
		attval = CalculateAttributeValue( this.GetAttributeValue( 'shielded' ) );
		if( attval >= 1.f )
			return true;
		else
			return false;
	}
	
	function RaiseShield()
	{
		SetBehaviorVariable( 'bShieldUp', 1.f );
	}
	
	timer function LowerShield( td : float , id : int)
	{
		SetBehaviorVariable( 'bShieldUp', 0.f );
	}
		
	public function ProcessShieldDestruction()
	{	
		var shield : CEntity;
		
		if( HasTag( 'imlerith' ) )
			return;
			
		SetBehaviorVariable( 'bShieldbreak', 1.0 );
		AddEffectDefault( EET_Stagger, thePlayer, "ParryStagger" );
		shield = GetInventory().GetItemEntityUnsafe( GetInventory().GetItemFromSlot( 'l_weapon' ) );
		ToggleEffectOnShield( 'heavy_block', true );
		DropItemFromSlot( 'l_weapon', true );
	}

	event OnIncomingProjectile( isBomb : bool ) 
	{
		if( IsShielded( thePlayer ) )
		{
			RaiseShield();
			AddTimer( 'LowerShield', 3.0 );
		}
	}
	
	function ShouldAttackImmidiately() : bool
	{
		return  tauntedToAttackTimeStamp > 0 && ( tauntedToAttackTimeStamp + 10 > theGame.GetEngineTimeAsSeconds() );
	}
	
	function CanAttackKnockeddownTarget() : bool
	{
		var attval : float;
		attval = CalculateAttributeValue(this.GetAttributeValue('attackKnockeddownTarget'));
		if ( attval >= 1.f )
			return true;
		else
			return false;
	}
	
	event OnProcessRequiredItemsFinish()
	{
		var inv : CInventoryComponent = this.GetInventory();
		var heldItems, heldItemsNames, mountedItems : array<name>;
		
		if ( thePlayer.GetTarget() == this )
			thePlayer.OnTargetWeaponDrawn();
		
		
		SetBehaviorVariable( 'bIsGuarded', (int)IsGuarded() );
		
		inv.GetAllHeldAndMountedItemsCategories(heldItems, mountedItems);
				
		
		if ( this.HasShieldedAbility() )
		{
			RaiseGuard();
		}
		
		inv.GetAllHeldItemsNames( heldItemsNames );
		
		if ( heldItemsNames.Contains('fists_lightning') || heldItemsNames.Contains('fists_fire') )
		{
			this.PlayEffect('hand_fx');
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( this, 'FireDanger', -1, 5.0f, 1, -1, true, true );
		}
		else
		{
			this.StopEffect('hand_fx');
			theGame.GetBehTreeReactionManager().RemoveReactionEvent( this, 'FireDanger' );
		}
		
		if ( mountedItems.Contains('shield') )
		{
			this.AddAbility('CannotBeAttackedFromBehind', false);
			LowerGuard();
		}
		else
		{
			this.RemoveAbility('CannotBeAttackedFromBehind');
		}
	}
	
	public function ProcessSpearDestruction() : bool 
	{
		var appearanceName : name;
		var shouldDrop : bool;
		var spear : CEntity;
		
		appearanceName = 'broken';
		spear = GetInventory().GetItemEntityUnsafe( GetInventory().GetItemFromSlot( 'r_weapon' ) );
		spear.ApplyAppearance( appearanceName );
		DropItemFromSlot('r_weapon', true);
		return true;
		
	}	
	
	
	
	
	
	function PlayVitalSpotAmbientSound( soundEvent : string )
	{
		SoundEvent( soundEvent, 'pelvis' );
	}
	
	function StopVitalSpotAmbientSound( soundEvent : string)
	{
		SoundEvent( soundEvent, 'pelvis' );
	}
	
	event OnScriptReloaded()
	{
		
	}
		

	
	
	
	
	
	public function ChangeFightStage( fightStage : ENPCFightStage )
	{
		currentFightStage =  fightStage;
		SetCurrentFightStage();
	}
	
	public function SetCurrentFightStage()
	{
		SetBehaviorVariable( 'npcFightStage', (float)(int)currentFightStage, true );
	}
	
	public function GetCurrentFightStage() : ENPCFightStage
	{
		return currentFightStage;
	}
	
	
	public function SetBleedBurnPoison()
	{
		wasBleedingBurningPoisoned = true;
	}
	
	public function WasBurnedBleedingPoisoned() : bool
	{
		return wasBleedingBurningPoisoned;
	}
	
	
	public function HasAlternateQuen() : bool
	{
		var npcStorage : CHumanAICombatStorage;
		
		npcStorage = (CHumanAICombatStorage)GetScriptStorageObject('CombatData');
		if(npcStorage && npcStorage.IsProtectedByQuen() )
		{
			return true;
		}		
		
		return false;
	}
	
	
	public function GetIsMonsterTypeGroup() : bool	{ return isMonsterType_Group; }

	timer function AardDismemberForce( dt : float, id : int )
	{
		var ent : CEntity;
		var template : CEntityTemplate;
		var pos, toPlayerVec : Vector;
		
		
		template = (CEntityTemplate) LoadResource( "explosion_dismember_force" );
		toPlayerVec = GetWorldPosition() - thePlayer.GetWorldPosition();
		pos = GetWorldPosition() + toPlayerVec / VecDistance2D( GetWorldPosition(), thePlayer.GetWorldPosition() * 3 );
		ent = theGame.CreateEntity( template, pos, , , , true );
		ent.DestroyAfter( 5.f );
	}

	
	
	
	function UpdateAIVisualDebug()
	{	
	}

	
	event OnAllowBehGraphChange()
	{
		allowBehGraphChange = true;
	}
	
	event OnDisallowBehGraphChange()
	{
		allowBehGraphChange = false;
	}

	event OnObstacleCollision( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var  ent : CEntity;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		
		if ( (CActor)ent != this )
		{
			
			this.SignalGameplayEventParamObject('CollisionWithObstacle',ent);
		}
	}
	
	event OnObstacleCollisionProbe( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var  ent : CEntity;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		if ( (CActor)ent != this )
		{
			this.SignalGameplayEventParamObject('CollisionWithObstacleProbe',ent);
		}
	}
	
	event OnProjectileCustomCollision( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var  ent : CEntity;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		if ( (CActor)ent != this )
		{
			this.SignalGameplayEventParamObject('CollisionWithProjectileCustom',ent);
		}
	}
	
	
	event OnActorCollision( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var  ent : CEntity;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		if ( ent != this )
		{
			this.SignalGameplayEventParamObject('CollisionWithActor', ent );
			
			
			if( horseComponent )
			{
				horseComponent.OnCharacterCollision( ent );
			}
		}
	}
	
	event OnActorSideCollision( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var  ent : CEntity;
		var horseComp : W3HorseComponent;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		if ( ent != this )
		{
			this.SignalGameplayEventParamObject('CollisionWithActor', ent );
			
			
			if( horseComponent )
			{
				horseComponent.OnCharacterSideCollision( ent );
			}
		}
	}
	
	event OnStaticCollision( component : CComponent )
	{
		SignalGameplayEventParamObject('CollisionWithStatic',component);
	}
	
	event OnBoatCollision( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var  ent : CEntity;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		if ( ent != this )
		{
			this.SignalGameplayEventParamObject('CollisionWithBoat', ent );
		}
	}
	
	
	
	
	
	public function IsUnderwater() : bool { return isUnderwater; }
	public function ToggleIsUnderwater ( toggle : bool ) { isUnderwater = toggle; }
	
	event OnOceanTriggerEnter()
	{
		SignalGameplayEvent('EnterWater');
	}
	
	event OnOceanTriggerLeave()
	{
		SignalGameplayEvent('LeaveWater');
	}
	
	
	
	
		
	var isRagdollOn : bool; default isRagdollOn = false;
	
	event OnInAirStarted()
	{		
		
	}
	
	event OnRagdollOnGround()
	{		
		var params : SCustomEffectParams;
		
		if( GetIsFallingFromHorse() )
		{
			params.effectType = EET_Ragdoll;
			params.creator = this;
			params.sourceName = "ragdoll_dismount";
			params.duration = 0.5;
			AddEffectCustom( params );
			SignalGameplayEvent( 'RagdollFromHorse' ); 
			SetIsFallingFromHorse( false );
		}
		else if( IsInAir() )
		{
			SetIsInAir(false);
		}
		ProcessHugeMutationSize(); // Triangle enemy mutations this maybe does something
	}
	
	var m_storedInteractionPri : EInteractionPriority;
	default	m_storedInteractionPri = IP_NotSet;
	
	event OnRagdollStart()
	{
		var currentPri : EInteractionPriority;
	
		
		currentPri = GetInteractionPriority();
		if ( currentPri != IP_Max_Unpushable && IsAlive() )
		{
			m_storedInteractionPri = currentPri;
			SetInteractionPriority( IP_Max_Unpushable );
		}
		ProcessHugeMutationSize(); // Triangle enemy mutations this maybe does something
	}
	
	event OnNoLongerInRagdoll()
	{
		aardedFlight = false;
		
		
		if ( m_storedInteractionPri != IP_NotSet && IsAlive() )
		{
			SetInteractionPriority( m_storedInteractionPri );
			m_storedInteractionPri = IP_NotSet;
		}
		ProcessHugeMutationSize(); // Triangle enemy mutations this maybe does something
	}
	
	timer function DelayRagdollSwitch( td : float , id : int)
	{
		var params : SCustomEffectParams;
	
		if( IsInAir() )
		{
			isRagdollOn = true;
			params.effectType = EET_Ragdoll;
			params.duration = 5;
			
			AddEffectCustom(params);
		}
		ProcessHugeMutationSize(); // Triangle enemy mutations this maybe does something
	}

	event OnRagdollIsAwayFromCapsule( ragdollPosition : Vector, entityPosition : Vector )
	{
	}
	
	event OnRagdollCloseToCapsule( ragdollPosition : Vector, entityPosition : Vector )
	{
	}
	
	event OnTakeDamage( action : W3DamageAction )
	{
		var i : int;
		var abilityName : name;
		var abilityCount, maxStack : float;
		var min, max : SAbilityAttributeValue;
		var addAbility : bool;
		var witcher : W3PlayerWitcher;
		var attackAction : W3Action_Attack;
		var gameplayEffects : array<CBaseGameplayEffect>;
		var template : CEntityTemplate;
		var hud : CR4ScriptedHud;
		var ent : CEntity;
		var weaponId : SItemUniqueId;
		// Triangle enemy mutations
		var stats : CCharacterStats;
		var healthType : EBaseCharacterStats;
		var params : SCustomEffectParams;
		stats = GetCharacterStats();

		healthType = TUtil_GetHealthType(this);
		if (!explosionMutationTriggered && stats.HasAbility(TUtil_TEMutationEnumToName(TEM_Explosive)) && action.DealsAnyDamage()
			&& ((healthType == BCS_Essence && action.processedDmg.essenceDamage >= GetStat(healthType))
				|| (healthType == BCS_Vitality && action.processedDmg.vitalityDamage >= GetStat(healthType)))) {
			ForceSetStat(healthType, GetStatMax(healthType));
			action.SetAllProcessedDamageAs(1);
			explosionMutationTriggered = true;
			PlayEffect('critical_burning');
			AddTimer('ExplodeMutation', TOpts_ExplosiveDelay());
			params.effectType = EET_Immobilized;
			params.creator = this;
			params.sourceName = TUtil_TEMutationEnumToName(TEM_Explosive);
			params.duration = TOpts_ExplosiveDelay() + 1;
			AddEffectCustom(params);
		}
		// Triangle end

		super.OnTakeDamage(action);
		
		
		// Triangle enemy mutations
		if (action.DealsAnyDamage() && !action.IsDoTDamage() && stats.HasAbility(TUtil_TEMutationEnumToName(TEM_Resilient))) {
			StartResilientRegen();
		}
		// Triangle end

		if(action.IsActionMelee() && action.DealsAnyDamage())
		{
			witcher = (W3PlayerWitcher)action.attacker;
			if(witcher && witcher.HasBuff(EET_Mutagen10))
			{
				abilityName = thePlayer.GetBuff(EET_Mutagen10).GetAbilityName();
				abilityCount = thePlayer.GetAbilityCount(abilityName);
				
				if(abilityCount == 0)
				{
					addAbility = true;
				}
				else
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen10_max_stack', min, max);
					maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
					
					if(maxStack >= 0)
					{
						addAbility = (abilityCount < maxStack);
					}
					else
					{
						addAbility = true;
					}
				}
				
				if(addAbility)
				{
					thePlayer.AddAbility(abilityName, true);
				}
			}
			
			attackAction = (W3Action_Attack)action;

			if ( witcher && attackAction && attackAction.attacker == witcher )
			{
				if ( !attackAction.IsParried() && !attackAction.IsCountered() )
				{
					if ( witcher.HasRunewordActive('Runeword 11 _Stats') ) //modSigns
					{
						gameplayEffects = witcher.GetPotionBuffs();
						theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 11 _Stats', 'duration', min, max );
						
						for ( i = 0; i < gameplayEffects.Size(); i+=1 )
						{
							gameplayEffects[i].SetTimeLeft( gameplayEffects[i].GetTimeLeft() + min.valueAdditive );
							
							hud = (CR4ScriptedHud)theGame.GetHud();
							if (hud)
							{
								hud.ShowBuffUpdate();
							}
						}
					}
				}
			}
		}
		
		if(action.IsActionMelee())
			lastMeleeHitTime = theGame.GetEngineTime();
		
		
		if( (W3PlayerWitcher)action.attacker && action.IsActionRanged() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) )
		{
			attackAction = (W3Action_Attack)action;
			if( attackAction )
			{
				weaponId = attackAction.GetWeaponId();
				if( thePlayer.inv.IsItemCrossbow( weaponId ) || thePlayer.inv.IsItemBolt( weaponId ) )
				{
					theGame.MutationHUDFeedback( MFT_PlayOnce );
				}
			}
		}
	}
	
	public function GetInteractionData( out actionName : name, out text : string ) : bool
	{
		if ( CanStartTalk() && !IsInCombat() && !HasTag( 'no_talk' ) )
		{
			actionName	= 'Talk';
			text		= "panel_button_common_talk";
			return true;
		}
		return false;
	}
	
	public function IsAtWorkDependentOnFireSource() : bool
	{
		if ( IsAPValid(GetActiveActionPoint()) )
		{
			return theGame.GetAPManager().IsFireSourceDependent( GetActiveActionPoint() );
		}
		
		return false;
	}
	
	public function FinishQuen( skipVisuals : bool, optional forceNoBearSetBonus : bool )
	{
		SignalGameplayEvent('FinishQuen');
	}

	public function IsAxiied() : Bool
	{
		return HasBuff( EET_AxiiGuardMe ) || HasBuff( EET_Confusion );
	}
	
	private timer function CloseHitWindowAfter( dt : float, id : int )
	{
		SetBehaviorVariable( 'counterHitType', 0.0 );
	}
	
	
	
	
	
	
	
	public timer function SetShowAllHorseItems( dt : float, id : int )
	{
		var hiddenItems : bool;
		
		hiddenItems = TryToHideAllHorseItems();
		
		
		if( !hiddenItems )
		{
			AddTimer( 'SetShowAllHorseItems', 0.1f, true );
		}
		else
		{
			RemoveTimer( 'SetShowAllHorseItems' );
		}
	}
	
	
	
	
	public final function TryToHideAllHorseItems() : bool
	{
		var items : array< SItemUniqueId >;
		var itemEntity : CItemEntity;
		var i, k : int;
		var drawableComp : CDrawableComponent;
		var drawableComps : array<CComponent>;
		var inv : CInventoryComponent;
		var itemVisibility : bool;
		var foundTail, foundReins, foundHair : bool;
		var itemName : name;
		
		inv = GetInventory();
		inv.GetAllItems( items );
		itemVisibility = !GetWitcherPlayer().GetHorseManager().GetShouldHideAllItems();
		
		foundTail	= false;
		foundReins	= false;
		foundHair	= false;
		
		for( i=0; i<items.Size(); i+=1 )
		{
			itemName = inv.GetItemName( items[ i ] );
			itemEntity = inv.GetItemEntityUnsafe( items[ i ] );
			if( itemEntity )
			{
				if( inv.ItemHasTag( items[i], 'HorseTail' ) )
				{
					foundTail = true;
				}
				else if( inv.ItemHasTag( items[i], 'HorseReins' ) )
				{
					foundReins = true;
				}
				else if( inv.GetItemCategory( items[i] ) == 'horse_hair' )
				{
					foundHair = true;
				}
				
				drawableComps = itemEntity.GetComponentsByClassName( 'CDrawableComponent' );
				
				for( k = 0; k < drawableComps.Size(); k += 1 )
				{
					drawableComp = ( CDrawableComponent )drawableComps[ k ];
					if( drawableComp )
					{
						drawableComp.SetVisible( itemVisibility );
					}
				}
			}
		}
		
		
		return items.Size() == 0 || ( foundTail && foundReins && foundHair );
	}
	
	timer function SetUnconsciousFinisher( time : float , id : int )
	{
		SetBehaviorVariable( 'unconsciousFinisher', 1.0 );
		SetBehaviorVariable( 'prepareForUnconsciousFinisher', 0.0f );
	}
	
	timer function EvadeFinisherTimer( dt : float, id : int )
	{
		var ticketS, ticketR 	: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		
		PlayEffectSingle( 'disappear' );
		
		movementAdjustor = this.GetMovingAgentComponent().GetMovementAdjustor();
		
		ticketS = movementAdjustor.CreateNewRequest( 'FinisherSlide' );
		movementAdjustor.MaxLocationAdjustmentSpeed( ticketS, 9999 );
		movementAdjustor.AdjustLocationVertically( ticketS, true );
		movementAdjustor.AdjustmentDuration( ticketS, 0.6 );
		movementAdjustor.BlendIn( ticketS, 0.25 );
		movementAdjustor.SlideTowards( ticketS, GetTarget(), 5, 7 );
		
		ticketR = movementAdjustor.CreateNewRequest( 'FinisherRotate' );
		movementAdjustor.MaxLocationAdjustmentSpeed( ticketR, 9999 );
		movementAdjustor.AdjustmentDuration( ticketR, 0.1 );
		movementAdjustor.RotateTowards( ticketR, GetTarget() );
		
		this.AddTimer( 'EvadeFinisherTimerStop', 0.6, false );
	}
	
	timer function EvadeFinisherTimerStop( dt : float, id : int )
	{
		PlayEffectSingle( 'appear' );
	}
}

exec function IsFireSource( tag : name )
{
	var npc : CNewNPC;

	npc = ( CNewNPC )theGame.GetEntityByTag( tag );	
	
	LogChannel('SD', "" + npc.IsAtWorkDependentOnFireSource() );
}	

