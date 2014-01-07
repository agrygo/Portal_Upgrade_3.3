package widgets.CoordinateMenu
{
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;

	public class CoordinateMenuWidgetHelper
	{
		[Bindable]
		public var precision:Number = 4;
		[Bindable]
		public var zoomScale:Number = 10000;
		[Bindable]
		public var geometryServiceURL:String;
		[Bindable]
		public var hideESRIAboutItems:Boolean = false;
		[Bindable]
		public var copyFormat:String =  "X: {X} Y: {Y}";
		[Bindable]
		public var markerRemoveDelay:Number = 2000;
		[Bindable]
		public var coordinateSystemsXML:XMLList = new XMLList();
		[Bindable]
		public var coordinateSystems:ArrayCollection = new ArrayCollection();
		
		[Bindable]
		public var map:Map;
		
		[Bindable]
		private var graphicsLayer:GraphicsLayer = null;
		[Bindable]
		private var graphicsLayer2:GraphicsLayer = null;
		private var markerSymbol:PictureMarkerSymbol;
		private var copiedSymbol:PictureMarkerSymbol;
		[@Embed(source='images/copied.png')]
		[Bindable]
		private var copied:Class;
		
		public function CoordinateMenuWidgetHelper(configXML:XML,_map:Map)
		{
			//SET MAP
			this.map = _map;
			
			//config XML items
			var hideItems:String = configXML.hideESRIAboutItems;
			this.hideESRIAboutItems = (hideItems.toLocaleLowerCase() == 'true') ? true : false;
			this.copyFormat = configXML.copyFormat;
			this.markerRemoveDelay = configXML.markerRemoveDelay;
			this.coordinateSystemsXML = configXML.coordinateSystems;
			this.geometryServiceURL = configXML.geometryServiceURL;
			this.zoomScale = Number(configXML.zoomScale);
			this.precision = Number(configXML.precision);
		
			//convert coordinateSystemsXML to coordinateSystems obj
			for each (var cs:XML in this.coordinateSystemsXML.coordinateSystem) 
			{
				var name:String = cs.@name;
				var wkid:Number = Number(cs.@wkid);
				var decimals:Number = Number(cs.@decimals);
				this.coordinateSystems.addItem( new CoordinateSystem(name,wkid,decimals));
			}
		}
		
		public function format(mPoint:MapPoint):String
		{
			//format String from config.XML definition.
			var copyString:String = this.copyFormat;  // copy value to keep format intact
			copyString = copyString.replace(/{X}/g, mPoint.x.toFixed(this.precision)); //replace X
			copyString = copyString.replace(/{Y}/g, mPoint.y.toFixed(this.precision)); // replace y
			return copyString;
		}
		
		public function formatString(x:String,y:String):String
		{
			//format String from config.XML definition.
			var copyString:String = this.copyFormat;  // copy value to keep format intact
			copyString = copyString.replace(/{X}/g, x); //replace X
			copyString = copyString.replace(/{Y}/g, y); // replace y
			return copyString;
		}
		
		private function validateGraphicLayers():void
		{
			if (this.graphicsLayer == null)
			{
				//Graphics Layers
				this.graphicsLayer = new GraphicsLayer();
				this.graphicsLayer2 = new GraphicsLayer();
				
				//Symbols
				this.markerSymbol = new PictureMarkerSymbol("assets/images/Red_glow.swf",20,20,-5);
				this.copiedSymbol = new PictureMarkerSymbol(copied,61,45,-1,17);
				
				//Set Symbols
				this.graphicsLayer.symbol= this.markerSymbol;
				this.graphicsLayer2.symbol= this.copiedSymbol;
				
				this.map.addLayer(this.graphicsLayer);
				this.map.addLayer(this.graphicsLayer2);
			}
		}
		
		
		private function setGraphicTimer(graphic:Graphic, gLayer:GraphicsLayer):void
		{
			//create a timer to remove graphics after X delay.
			var timer:Timer = new Timer(this.markerRemoveDelay,1);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function (event:TimerEvent):void
			{
				//remove graphic and stop timer.
				gLayer.remove(graphic);
				timer.stop();
			});
		}
		
		public function showGraphic(mPoint:MapPoint):void
		{
			this.validateGraphicLayers();
			
			//show graphic
			var graphic:Graphic = new Graphic(mPoint);
			this.graphicsLayer.add(graphic);
			this.setGraphicTimer(graphic,graphicsLayer);
		}
		
		public function showGraphicAsCopied(mPoint:MapPoint):void
		{
			this.validateGraphicLayers();
			
			//show graphic
			var graphic:Graphic = new Graphic(mPoint);
			var graphic2:Graphic = new Graphic(mPoint);
			
			this.graphicsLayer.add(graphic);
			this.graphicsLayer2.add(graphic2);
			this.setGraphicTimer(graphic,graphicsLayer);
			this.setGraphicTimer(graphic2,graphicsLayer2);
		}
		
		
	}
}