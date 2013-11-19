package proxy
{
	/**
	 * 此類別用以與伺服器溝通
	 */
	
	import flash.display.DisplayObject;
	
	import model.event.ItemResultEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.ObjectProxy;

	
	public class ConnectionProxy extends UIComponent
	{
		private var basepath:String;
		private static var connect:ConnectionProxy;
		private static var popup:Canvas;
		//所有會員列表
		private var memberList:ArrayCollection;
		private var memberCommonList:ArrayCollection;
		//副本區域列表
		private var areaList:ArrayCollection;
		//boss掉落物品列表
		private var bossItemList:Array = new Array();
		//物品說明列表
		private var itemHTML:Array = new Array();
		
		/**
		 * 基本設定函數
		 */
		public var target:UIComponent;
		public var token:String;
		public static function getInstances():ConnectionProxy{
			if(connect==null){
				connect = new ConnectionProxy();
				popup = new Canvas();
				var label:Label = new Label();
				label.text = "從伺服器取得資料...";
				label.setStyle("StyleName","titleLabel");
				popup.setStyle("StyleName","loginStyle");
				popup.addChild(label);
			}
			return connect;
		}
		
		public function set path(path:String):void{
			basepath = path;
		}
		
		/**
		 * 類別內的http傳送函數
		 */
		private function sendHttpFunction(file:String,handler:Function,obj:Object=null,resultFormat:String='',method:String="POST"):void{
			var http:HTTPService = new HTTPService();
			http.url = basepath+file;
			if(resultFormat!=''){
				http.resultFormat = resultFormat;
			}
			http.method = method;
			http.addEventListener(ResultEvent.RESULT,sendSuccessEvent);
			http.addEventListener(ResultEvent.RESULT,handler);
			http.addEventListener(FaultEvent.FAULT,sendFaultEvent);
			if(obj==null){
				obj = new Object();
			}
			obj.authenticate = token;
			http.send(obj);
			try{
				PopUpManager.removePopUp(popup);
			}catch(e:Error){}
			PopUpManager.addPopUp(popup,target,true);
			PopUpManager.centerPopUp(popup);
		}
		private function sendSuccessEvent(event:ResultEvent):void{
			PopUpManager.removePopUp(popup);
		}
		private function sendFaultEvent(event:FaultEvent):void{
			trace("sendFaultEvent: "+event.message);
			PopUpManager.removePopUp(popup);
		}
		/**
		 * 取得所有副本區域資料
		 */
		public function getRaidAreaList():void{
			if(areaList == null){
				sendHttpFunction('bossList.php',getRaidAreaListHandler);
			}else{
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_RAID_AREA_LIST_RESULT,areaList,true));
			}
		}
		private function getRaidAreaListHandler(event:ResultEvent):void{
			if(event.result.bossList.area is ObjectProxy){
				areaList = new ArrayCollection();
				areaList.addItem(event.result.bossList.area);
			}else{
				areaList = event.result.bossList.area as ArrayCollection;
			}
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_RAID_AREA_LIST_RESULT,areaList,true));
			
		}
		/**
		 * 取得所有會員資料
		 */
		public function getMemberList():void{
			if(memberList == null){
				sendHttpFunction('memberList.php',getMemberListHandler);
			}else{
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.MEMBER_LIST_EVENT,memberList,true));
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.MEMBER_COMMON_LIST_EVENT,memberCommonList,true));
			}
		}
		private function getMemberListHandler(event:ResultEvent):void{
			if(event.result.memberList.member as ObjectProxy){
				memberList = new ArrayCollection();
				memberList.addItem(event.result.memberList.member);
			}else memberList = event.result.memberList.member;
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.MEMBER_LIST_EVENT,memberList,true));
			var name:String;
			var level:String;
			var id:String;
			memberCommonList = new ArrayCollection();
			for(var i:String in memberList){
				if(memberList[i]['children'] is ObjectProxy){
					name = memberList[i]['children'].label;
					level = memberList[i]['children'].level;
					id = memberList[i]['children'].data;
					memberCommonList.addItem({label:name,level:level,data:id});
				}else{
					for(var j:String in memberList[i]['children']){
						name = memberList[i]['children'][j].label;
						level = memberList[i]['children'][j].level;
						id = memberList[i]['children'][j].data;
						memberCommonList.addItem({label:name,level:level,data:id});
					}
				}
			}
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.MEMBER_COMMON_LIST_EVENT,memberCommonList,true));
		}
		/**
		 * 取得傳入物品id的html介紹
		 */
		public function getItemTipList(item_id:String):void{
			if(itemHTML[item_id] == null){
				var obj:Object = new Object();
				obj.itemId = item_id;
				sendHttpFunction('itemHtml.php',getItemTipListHandler,obj,HTTPService.RESULT_FORMAT_TEXT);
			}else{
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_ITEMTIP_RESULT,itemHTML[item_id],true));
			}
		}
		private function getItemTipListHandler(event:ResultEvent):void{
			var str:String = event.result.toString().substring(5);
			var id:String = event.result.toString().substring(5,0);
			if(str == ''){
				str = '物品資料庫內無此物品資料!';
			}
			itemHTML[id] = str;
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_ITEMTIP_RESULT,str,true));
		}
		/**
		 * 送出儲存副本資料
		 */
		public function saveRaidData(data:String,date:String,title:String,description:String):void{
			var obj:Object = new Object();
			obj.json_data = data.toString()+"";
			obj.date = date;
			obj.title = title;
			obj.description = description;
			sendHttpFunction('saveRaidData.php',saveRaidDataHandler,obj);
		}
		private function saveRaidDataHandler(event:ResultEvent):void{
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.SAVE_RAID_DATA_RESULT,event.result.result,true));
		}
		/**
		 * 取得副本出團列表
		 */
		public function getRaidDataList(type:String,from:String,to:String):void{
			var obj:Object = new Object();
			obj.type = type;
			obj.from = from;
			obj.to = to;
			sendHttpFunction('getRaidDataList.php',getRaidDataListHandler,obj);
		}
		private function getRaidDataListHandler(event:ResultEvent):void{
			if(event.result.result!= null){
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_RAID_DATA_LIST_RESULT,event.result.result.event,true));
			}else{
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_RAID_DATA_LIST_RESULT,null,true));
			}
		}
		/**
		 * 取得單場出團詳細資料
		 */
		public function getRaidDetail(id:String):void{
			var obj:Object = new Object();
			obj.id = id;
			sendHttpFunction('getRaidDataDetail.php',getRaidDetailHandler,obj);
		}
		private function getRaidDetailHandler(event:ResultEvent):void{
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_RAID_DATA_DETAIL_RESULT,event.result.result,true));
		}
		/**
		 * 刪除出團場次資料
		 */
		public function deleteRaidInfo(id:String):void{
			var obj:Object = new Object();
			obj.id = id;
			sendHttpFunction('raidInfoDelete.php',deleteRaidInfoDataHandler,obj,HTTPService.RESULT_FORMAT_TEXT);
		}
		private function deleteRaidInfoDataHandler(event:ResultEvent):void{
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.DELETE_RAID_DATA_RESULT,event.result.toString(),true));
		}
		/**
		 * 取得該會員所獲物品列表
		 */
		public function getMemberItemList(id:String):void{
			if(id!='' && id != null){
				var obj:Object = new Object();
				obj.user_id = id;
				sendHttpFunction('memberPickupStatus.php',getMemberItemListHandler,obj);
			}
		}
		private function getMemberItemListHandler(event:ResultEvent):void{
			if(event.result != null && event.result.result != null){
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_MEMBER_ITEMLIST_RESULT,event.result.result.item,true));
			}else{
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_MEMBER_ITEMLIST_RESULT,null,true));
			}
		}
		/**
		 * 取得該會員所參與副本活動列表
		 */
		public function getMemberAttendList(id:String):void{
			if(id!='' && id != null){
				var obj:Object = new Object();
				obj.user_id = id;
				sendHttpFunction('memberAttendList.php',getMemberAttendListHandler,obj);
			}
		}
		private function getMemberAttendListHandler(event:ResultEvent):void{
			if(event.result.result != null){
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_MEMBER_ATTEND_RESULT,event.result.result.item,true));
			}else{
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_MEMBER_ATTEND_RESULT,null,true));
			}
		}
		/**
		 * 取得該會員所參與副本活動分析
		 */
		public function getMemberAnalysis(id:String,type:String,from:String,to:String):void{
			var obj:Object = new Object();
			obj.user_id = id;
			obj.type = type;
			obj.from = from;
			obj.to = to;
			sendHttpFunction('memberAttendStatus.php',getMemberAnalysisHandler,obj);
		}
		private function getMemberAnalysisHandler(event:ResultEvent):void{
			if(event.result.result.personal!=null){
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_MEMBER_ANALYSIS_RESULT,event.result['result'],true));				
			}
		}
		/**
		 * 儲存修改後的資料
		 */
		public function saveRaidModify(sn:String,title:String,date:String,dec:String,member_data:String):void{
			var obj:Object = new Object();
			obj.sn = sn;
			obj.title = title;
			obj.date = date;
			obj.dec = dec;
			obj.json_data = member_data;
			sendHttpFunction('saveRaidModify.php',saveRaidModifyHandler,obj,HTTPService.RESULT_FORMAT_TEXT);
		}
		private function saveRaidModifyHandler(event:ResultEvent):void{
			if(event.result == 'success'){
				Alert.show('修改完成!');
			}else{
				Alert.show('儲存時發生未知錯誤!');
			}
		}
		/**
		 * 取得所有成員出席率
		 */
		public function memberAttendStatusList(type:String,from:String,to:String):void{
			var obj:Object = new Object();
			obj.type = type;
			obj.from = from;
			obj.to = to;
			sendHttpFunction('memberAttendStatusList.php',memberAttendStatusListHandler,obj);
		}
		private function memberAttendStatusListHandler(event:ResultEvent):void{
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_ATTEND_STATUS_LIST_RESULT,event.result.result,true));				
		}
		/**
		 * 搜尋物品編號
		 */
		public function getItemNumber(name:String,mode:String):void{
			var obj:Object = new Object();
			obj.name = name;
			obj.mode = mode;
			sendHttpFunction('searchItemNum.php',getItemNumberHandler,obj,HTTPService.RESULT_FORMAT_TEXT);
		}
		private function getItemNumberHandler(event:ResultEvent):void{
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_ITEM_NUMBER_RESULT,event.result.toString(),true));				
		}
		/**
		 * 搜尋全部會員資料(包括非副本會員)
		 */
		public function getAllMemberInfo(obj:Object=null):void{
			sendHttpFunction('getAllMemberList.php',getAllMemberInfoHandler,obj);
		}
		private function getAllMemberInfoHandler(event:ResultEvent):void{
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_ALL_MEMBER_LIST_RESULT,event.result.memberList.item,true));				
		}
		/**
		 * 取得會員的願望清單列表
		 */
		public function getPersonWishList(id:String):void{
			var obj:Object = new Object();
			obj.id = id;
			sendHttpFunction('wishList.php',getPersonWishListHandler,obj);
		}
		private function getPersonWishListHandler(event:ResultEvent):void{
			var wish1:ArrayCollection = new ArrayCollection();
			if(event.result.bossDropList.major != null){
				if(event.result.bossDropList.major.item is ObjectProxy){
					wish1.addItem(event.result.bossDropList.major.item);
				}else{
					wish1 = event.result.bossDropList.major.item as ArrayCollection;
				}
			}
			var wish2:ArrayCollection = new ArrayCollection();
			if(event.result.bossDropList.secondary != null){
				if(event.result.bossDropList.secondary.item is ObjectProxy){
					wish2.addItem(event.result.bossDropList.secondary.item);
				}else{
					wish2 = event.result.bossDropList.secondary.item as ArrayCollection;
				}
			}
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_MEMBER_WISH_LIST_RESULT,{wish1:wish1,wish2:wish2},true));				
		}
		/**
		 * 搜尋某BOSS的掉落物品
		 */
		public function getBossItemList(id:String):void{
			if(bossItemList[id] == null){
				var obj:Object = new Object();
				obj.id = id;
				sendHttpFunction('getBossItemList.php',getBossItemListHandler,obj);
			}else{
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_BOSS_ITEM_LIST_RESULT,bossItemList[id],true));	
			}
		}
		private function getBossItemListHandler(event:ResultEvent):void{
			var list:ArrayCollection;
			if(event.result.itemList.item is ObjectProxy){
				list = new ArrayCollection();
				list.addItem(event.result.itemList.item);
			}else{
				list = event.result.itemList.item as ArrayCollection;
			}
			bossItemList[event.result.itemList.boss] = list;
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_BOSS_ITEM_LIST_RESULT,list,true));				
		}
		/**
		 * 搜尋該物品想要的人的清單及排序
		 */
		public function getWishList(obj:Object):void{
			sendHttpFunction('getItemWishList.php',getWishListHandler,obj);
		}
		private function getWishListHandler(event:ResultEvent):void{
			if(event.result.itemList!=null){
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_WISH_LIST_RESULT,event.result.itemList.item,true));				
			}else{
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_WISH_LIST_RESULT,null,true));				
			}
		}
		/**
		 * 設定現在是否可以修改物品的開關
		 */
		public function lockOrUnlockProcess(id:String):void{
			var obj:Object = new Object();
			obj.member_id = id;
			sendHttpFunction('toggleLogin.php',lockOrUnlockProcessHandler,obj);
		}
		private function lockOrUnlockProcessHandler(event:ResultEvent):void{
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.LOCK_OR_UNLOCK_PROCESS_RESULT,event.result.status,true));				
		}
		/**
		 * 修改密碼
		 */
		public function changePassword(id:String,password:String):void{
			var obj:Object = new Object();
			obj.id = id;
			obj.password = password;
			sendHttpFunction('modifyPassword.php',changePasswordHandler,obj,HTTPService.RESULT_FORMAT_TEXT);
		}
		private function changePasswordHandler(event:ResultEvent):void{
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.MODIFY_PASSWORD_RESULT,event.result,true));			
		}
		/**
		 * 取得該次團隊事件的詳細撿寶資料
		 */
		public function getRaidItemDetail(id:String):void{
			var obj:Object = new Object();
			obj.sn = id;
			obj.type = 'get';
			sendHttpFunction('getRaidItemDetail.php',getRaidItemDetailResult,obj);
		}
		private function getRaidItemDetailResult(event:ResultEvent):void{
			if(event.result.result != null){
				var tmp:ArrayCollection;
				if(event.result.result.data as ObjectProxy){
					tmp = new ArrayCollection();
					tmp.addItem(event.result.result.data);
				}else{
					tmp = event.result.result.data;
				}
				this.dispatchEvent(new ItemResultEvent(ItemResultEvent.GET_RAID_ITEM_DETAIL_RESULT,tmp,true));				
			}
		}
		/**
		 * 修改或刪除團隊事件物品相關資料
		 */
		public function modifyRaidItemDetail(event_sn:String,type:String,pickup_sn:String,user_id:String='',item_name:String=''):void{
			var obj:Object = new Object();
			obj.sn = event_sn;
			obj.type = type;
			obj.pickup_sn = pickup_sn;
			obj.user_id = user_id;
			obj.item_name = item_name;
			sendHttpFunction('getRaidItemDetail.php',modifyRaidItemDetailResult,obj,HTTPService.RESULT_FORMAT_TEXT);
		}
		private function modifyRaidItemDetailResult(event:ResultEvent):void{
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.MODIFY_RAID_ITEM_DETAIL_RESULT,event.result.toString(),true));				
		}
		/**
		 * 新增刪除或修改會員
		 */
		public function memberManager(obj:Object=null):void{
			sendHttpFunction("insertMember.php",memberManagerHander,obj,HTTPService.RESULT_FORMAT_TEXT);
		}
		private function memberManagerHander(event:ResultEvent):void{
			memberList = null;
			getMemberList();
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.MEMBER_MANAGER_RESULT,event.result,true));				
		}
		/**
		 * 共通使用
		 */
		public function commonEvent(file:String,obj:Object=null):void{
			sendHttpFunction(file,commonEventHander,obj);
		}
		private function commonEventHander(event:ResultEvent):void{
			this.dispatchEvent(new ItemResultEvent(ItemResultEvent.COMMON_EVENT_RESULT,event.result,true));				
		}
		
	}
}