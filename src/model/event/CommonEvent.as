package model.event
{
	import flash.events.Event;
	
	public class CommonEvent extends Event
	{
		public static const DELETE_ITEM_EVENT:String = "deleteItemEvent";
		public static const MODIFY_PICKUP_MEMBER:String = "modifyPickupMember";
		public static const MODIFY_PICKUP_MEMBER_SELECT:String = "modifyPickupMemberSelect";
		public static const MODIFY_RAID_DATA:String = "modifyRaidData";
		public static const MODIFY_DELETE_ITEM_EVENT:String = "modifyDeleteItemEvent";
		public static const MODIFY_INSERT_ITEM_EVENT:String = "modifyInsertItemEvent";
		public static const MODIFY_SAVE_ITEM_EVENT:String = "modifySaveItemEvent";
		
		public var data:Object;
		public function CommonEvent(type:String,obj:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			data = obj;
		}
	}
}