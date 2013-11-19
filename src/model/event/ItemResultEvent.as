package model.event
{
	import flash.events.Event;
	
	public class ItemResultEvent extends Event
	{
		//事件列表
		public static const MEMBER_LIST_EVENT:String = "memberListEvent";
		public static const MEMBER_COMMON_LIST_EVENT:String = "memberCommonListEvent";
		public static const GET_ITEMTIP_RESULT:String = "getItemTiptResult";
		public static const SAVE_RAID_DATA_RESULT:String = "saveRaidDataResult";
		public static const GET_RAID_DATA_LIST_RESULT:String = "getRaidDataListResult";
		public static const GET_RAID_DATA_DETAIL_RESULT:String = "getRaidDataDetailResult";
		public static const DELETE_RAID_DATA_RESULT:String = "deleteRaidDataResult";
		public static const GET_MEMBER_ITEMLIST_RESULT:String = "getMemberItemListResult";
		public static const GET_MEMBER_ATTEND_RESULT:String = "getMemberAttendResult";
		public static const GET_MEMBER_ANALYSIS_RESULT:String = "getMemberAnalysisResult";
		public static const GET_ATTEND_STATUS_LIST_RESULT:String = "getAttendStatusListResult";
		public static const GET_ITEM_NUMBER_RESULT:String = "getItemNumberResult";
		public static const GET_ALL_MEMBER_LIST_RESULT:String = "getAllMemberListResult";
		public static const GET_RAID_AREA_LIST_RESULT:String = "getRaidAreaListResult";
		public static const GET_MEMBER_WISH_LIST_RESULT:String = "getMemberWishListResult";
		public static const GET_BOSS_ITEM_LIST_RESULT:String = "getBossItemListResult";
		public static const GET_WISH_LIST_RESULT:String = "getWishListResult";
		public static const LOCK_OR_UNLOCK_PROCESS_RESULT:String = "lockOrUnlockProcessResult";
		public static const GET_RAID_ITEM_DETAIL_RESULT:String = "getRaidItemDetailResult";
		public static const MODIFY_RAID_ITEM_DETAIL_RESULT:String = "modifyRaidItemDetailResult";
		public static const MEMBER_MANAGER_RESULT:String = "memberManagerResult";
		public static const COMMON_EVENT_RESULT:String = "commonEventResult";
		public static const MODIFY_PASSWORD_RESULT:String = "modifyPasswordResult";
		//儲存物件
		public var data:Object;
		public function ItemResultEvent(type:String, data:Object,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
		public function get result():Object{
			return data;
		}
	}
}