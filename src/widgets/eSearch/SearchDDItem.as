package widgets.eSearch
{
    import flash.events.EventDispatcher;
    
    [Bindable]
    [RemoteClass(alias="widgets.eSearch.SearchDDItem")]

	public class SearchDDItem extends EventDispatcher
	{
		public function SearchDDItem()
		{
			super();
		}
		
		public var value:String = "";
		
        public var label:String = "";
	}
}