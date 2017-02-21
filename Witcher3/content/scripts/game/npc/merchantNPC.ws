/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
struct MerchantNPCEmbeddedScenes
{
	editable var voiceTag        : name;
	editable var storyScene		 : CStoryScene;
	editable var input			 : name;
	editable var conditions : array<MerchantNPCEmbeddedScenesConditions>;
}

struct MerchantNPCEmbeddedScenesConditions
{
	editable var applyToTag    : name;
	editable var requiredFact  : string;
	editable var forbiddenFact : string;	
}


class W3MerchantNPC extends CNewNPC
{
	private editable var        embeddedScenes : array<MerchantNPCEmbeddedScenes>;			
	private	saved var lastDayOfInteraction : int;
	public saved var questBonus : bool;
	editable var cacheMerchantMappin : bool;
	editable saved var craftingDisabled : bool;
	
	default cacheMerchantMappin = true;
	
	var invComp : CInventoryComponent;

	default questBonus = false;
	
	//modSigns: balisse fruit temp fix
	function BalisseFruitTempFix()
	{
		var l_merchantComponent : W3MerchantComponent;
		
		l_merchantComponent = (W3MerchantComponent)GetComponentByClassName('W3MerchantComponent');
		invComp = GetInventory();
		if(invComp && l_merchantComponent && l_merchantComponent.GetMapPinType() == 'Herbalist')
		{
			if(!invComp.HasItem('Balisse fruit'))
				invComp.AddAnItem('Balisse fruit', 10);
		}
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var tags : array< name >;
		var ids : array< SItemUniqueId >;
		var i : int;
		
		super.OnSpawned( spawnData );
		
		// WMK
		// The generic merchants are not always spawned with the required tags. Because of this the dialog scene may use a
		// wrong model and ShowMeGoods function (from scene_functions.ws) doesn't find the merchant and is not possible to view its
		// inventory. Also the NPC is not seen as a merchant when opening the map (there's no pin). The following code fixes all
		// these issues. Note that the required tag(s) must be the first one(s). Patch 1.12 notes contain "Fixes rare issue whereby Shop
		// screen would not open correctly for traveling merchants", but is not a rare issue and the bug was not
		// fixed. Or maybe it was fixed only for generic wandering merchants...
		if (embeddedScenes.Size() > 0) {
			if (StrBeginsWith(embeddedScenes[0].storyScene.GetPath(), "living_world\dialogue\generic_merchants\shop_generic_merchant")) {
				// I have no idea what GetRequiredPositionTags does, but it seems to return the required
				// tag(s) for generic merchants. Probably the name should be GetRequiredSceneTags or something like this.
				tags = embeddedScenes[0].storyScene.GetRequiredPositionTags();
				ArrayOfNamesAppendUnique(tags, GetTags());
				SetTags(tags);
			}
		}
		// WMK
		
		if ( theGame.IsActive() )
		{
			if ( !HasTag( 'ShopkeeperEntity' ) )
			{
				tags = GetTags();
				tags.PushBack( 'ShopkeeperEntity' );
				SetTags( tags );
			}
		}

		invComp = GetInventory();
		if ( invComp )
		{
			if ( spawnData.restored == true )
			{
				invComp.ClearTHmaps();
				invComp.ClearGwintCards();
				invComp.ClearKnownRecipes();
				if ( questBonus == true )
				{
					invComp.ActivateQuestBonus();
				}
			}
			else
			{
				invComp.SetupFunds();
				lastDayOfInteraction = GameTimeDays( theGame.GetGameTime() );
			}
			if ( invComp.GetMoney() < 100 ) //modSigns
			{
				invComp.SetupFunds();
			}
			invComp.GetAllItems(ids);
			for(i=0; i<ids.Size(); i+=1)
			{
				
				if ( invComp.GetItemModifierInt(ids[i], 'ItemQualityModified') <= 0 )
					invComp.AddRandomEnhancementToItem(ids[i], invComp.GetItemLevel(ids[i])); //modSigns
			}
			BalisseFruitTempFix(); //modSigns
		}
		else
		{
			Log( "<<< ERROR - W3MERCHANTNPC ATTEMPTED TO USE INVALID INVENTORY COMPONENT >>>" );
		}
	}

	public function ActivateQuestBonus()
	{
		var invComp : CInventoryComponent;
		invComp = GetInventory();

		if ( invComp )
		{
			invComp.ActivateQuestBonus();
		}
		questBonus = true;
	}

	public function HasEmbeddedScenes() : bool
	{
		if( embeddedScenes.Size() > 0)
			return true;
		else
			return false;
	}
	
	function GetEmbeddedSceneBlocked( conditions : array<MerchantNPCEmbeddedScenesConditions> ) : bool
	{
		var size : int;
		var i : int;
		
		size = conditions.Size();
		
		if( size == 0 )return false;
		
		for( i=0; i < size; i+= 1)
		{
			if( this.HasTag( conditions[i].applyToTag ) || conditions[i].applyToTag == '' )
			{
				if(  (conditions[i].requiredFact != "" && FactsQuerySum( conditions[i].requiredFact ) == 0 ) || ( FactsQuerySum( conditions[i].forbiddenFact ) >= 1 ) )
					return true;
			}
		}
		
		return false;
	}
	
	function StartEmbeddedScene() : bool
	{
		var voiceTag : name;
		var i : int;
		
		voiceTag = GetVoicetag();
		
		if( voiceTag )
		{
			for( i = 0; i < embeddedScenes.Size(); i+=1 )
			{
				if( embeddedScenes[i].voiceTag == voiceTag )
				{
					if( GetEmbeddedSceneBlocked( embeddedScenes[i].conditions ) )
					{
						return false;
					}
					else
					{
						theGame.GetStorySceneSystem().PlayScene( embeddedScenes[i].storyScene, embeddedScenes[i].input );
						return true;
					}
				}
			}
		}
		
		return false;
	}
	
	function HasValidEmbeddedScene() : bool
	{
		var voiceTag : name;
		var i : int;
		
		voiceTag = GetVoicetag();
		
		if( embeddedScenes.Size() <= 0 )
			return false;
		
		if( voiceTag )
		{
			for( i = 0; i < embeddedScenes.Size(); i+=1 )
			{
				if( embeddedScenes[i].voiceTag == voiceTag )
				{
					if( GetEmbeddedSceneBlocked( embeddedScenes[i].conditions ) )
						return false;
					else
						return true;
				}
			}
		}
		
		return false;
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{	
		var ciriEntity  		: W3ReplacerCiri;
		var	isPlayingChatScene	: bool;
		var timeElapsed : int;
		var gameTimeDay : int;
		
		//debug
		//theGame.witcherLog.AddMessage("template: " + GetReadableName());
		LogChannel( 'DialogueTest', "Event Interaction Used" );
		if ( actionName == "Talk" )
		{
			invComp = GetInventory();
			if ( invComp )
			{
				gameTimeDay = GameTimeDays( theGame.GetGameTime() );
				timeElapsed = gameTimeDay - lastDayOfInteraction;

				if ( timeElapsed >= invComp.GetDaysToIncreaseFunds() || timeElapsed < 0 )
				{
					BalisseFruitTempFix(); //modSigns
					invComp.ClearLowLevelWeapons(); //modSigns
					invComp.IncreaseFunds();
					lastDayOfInteraction = gameTimeDay;
				}
			}
			else
			{
				Log( "<<< ERROR - W3MERCHANTNPC ATTEMPTED TO USE INVALID INVENTORY COMPONENT >>>" );
			}

			LogChannel( 'DialogueTest', "Activating TALK Interaction - PLAY DIALOGUE" );
			isPlayingChatScene = IsPlayingChatScene();
			
			
			if ( HasEmbeddedScenes() )
			{
				if ( !isPlayingChatScene )
				{
				
					if ( !PlayDialog() )
					{
						
						ciriEntity = (W3ReplacerCiri)thePlayer;
						if ( ciriEntity )
						{
							EnableDynamicLookAt( thePlayer, 5 );
						}
						else
						{
							
							if ( !StartEmbeddedScene() )
							{
								super.OnInteraction( actionName, activator);
							}
						}
					}
				}
			}
			else
			{
				super.OnInteraction( actionName, activator);
			}
		}
	}

	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if( HasEmbeddedScenes() && interactionComponentName == "talk" )
		{
			if( activator == thePlayer && ( thePlayer.CanStartTalk() || HasValidEmbeddedScene() ) && !wasInTalkInteraction )
			{
				return true;
			}
		}
		
		return super.OnInteractionActivationTest( interactionComponentName, activator );
	}
	
	public function IsCraftingDisabled() : bool
	{
		return craftingDisabled;
	}
	
	public function SetCraftingEnabled( enable : bool )
	{
		craftingDisabled = !enable;
	}
}
