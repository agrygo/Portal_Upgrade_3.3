package widgets.eSearch
{
	import flash.events.Event;
	
	public class RelateChosenEvent extends Event
	{
		
		public var data:*;

		
		public static const RELATE_CLICKED:String = "relateClicked";
		
		
		public function RelateChosenEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:* = null)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new RelateChosenEvent(type, bubbles, cancelable, data);
		}
	}
}