package widgets.CoordinateMenu
{
	public class CoordinateSystem
	{
		public var name:String;
		public var wkid:Number;
		public var decimals:Number = 5;
		
		public function CoordinateSystem(_name:String, _wkid:Number, _decimals:Number)
		{
			this.name = _name;
			this.wkid = _wkid;
			if (_decimals)
				this.decimals = _decimals;
		}
	}
}