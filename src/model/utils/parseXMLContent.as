package model.utils
{
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectProxy;

	public class parseXMLContent
	{
		public static var parser:parseXMLContent;
		private var profession:Object = {WARLOCK:'術士',WARRIOR:'戰士',HUNTER:'獵人',PALADIN:'聖騎士',MAGE:'法師'
										,SHAMAN:'薩滿',ROGUE:'盜賊',DRUID:'德魯伊',PRIEST:'牧師',DEATHKNIGHT:'死亡騎士'};
		private var item:XMLList;
		private var playerInfo:ArrayCollection;
		private var lootInfo:ArrayCollection;
		private var changePlayerContent:Boolean = false;
		private var changeLootContent:Boolean = false;
		public static function getInstances():parseXMLContent{
			if(parser==null){
				parser = new parseXMLContent();
			}
			return parser;
		}
		public function setParseXML(xml:XMLList):void{
			item = xml;
			changePlayerContent = true;
			changeLootContent = true;
		}
		public function getPlayerInfo():ArrayCollection{
			if(changePlayerContent){
				var player:XMLList = item.child('PlayerInfos').children();
				var len:uint = player.length();
				playerInfo = new ArrayCollection();
				for (var i:uint = 0; i < len; i++){				
					var obj:ObjectProxy = new ObjectProxy({name:player[i]['name'],profession:profession[player[i]['class']]});
					playerInfo.addItem(obj);
				}
				changePlayerContent = false;
			}
			return playerInfo;
		}
		public function getLoot():ArrayCollection{
			if(changeLootContent){
				var player:XMLList = item.child('Loot').children();
				var len:uint = player.length();
				lootInfo = new ArrayCollection();
				for (var i:uint = 0; i < len; i++){
					var item_id:String = player[i]['ItemID'].toString().split(':')[0];
					var obj:ObjectProxy = new ObjectProxy({
						ItemID:item_id,
						Player:player[i]['Player'],
						itemName:player[i]['ItemName'],
						icon:player[i]['Icon']
					});
					lootInfo.addItem(obj);
				}
				changeLootContent = false;
			}
			return lootInfo;
		}
	}
}
class tmp{
}