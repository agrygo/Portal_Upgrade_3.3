package widgets.eMapSwitcher
{
	public class Basemap
	{
	    public var id:String;
	    public var thumbnail:String;
	    public var label:String;
	    public var visible:Boolean;
		public var lalpha:Number;
		public var forcescaleonswitch:Number;
		public var autoswitchtoscale:Number;
	
	    public function Basemap(id:String, label:String, thumbnail:String = null, visible:Boolean = false, 
								alpha:Number = 0, forcescaleonswitch:Number = Number.NaN, 
								autoswitchtoscale:Number = Number.NaN){
	        this.id = id;
	        this.label = label;
	        this.thumbnail = thumbnail;
	        this.visible = visible;
			this.lalpha = alpha;
			this.forcescaleonswitch = forcescaleonswitch;
			this.autoswitchtoscale = autoswitchtoscale;
	    }
	}
}
