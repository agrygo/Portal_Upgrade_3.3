package widgets.CoordinateMenu
{
	import com.esri.ags.SpatialReference;
	import com.esri.ags.events.GeometryServiceEvent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.tasks.GeometryService;
	import com.esri.ags.tasks.supportClasses.ProjectParameters;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;

	public class Projector
	{
		public var geometryServiceURL:String;
		public var geometryService:GeometryService;
		
		public function Projector(geomServiceURL:String)
		{
			this.geometryServiceURL = geomServiceURL;
		}
		
		public function projectPoint(mapPoint:MapPoint, toWKID:Number, callbackFunction:Function, errorFunction:Function = null):void
		{
			this.geometryService = new GeometryService(this.geometryServiceURL);
			this.geometryService.addEventListener(GeometryServiceEvent.PROJECT_COMPLETE, callbackFunction);
			if (errorFunction != null)
			{
				this.geometryService.addEventListener(FaultEvent.FAULT, errorFunction);
			}
			else
			{
				this.geometryService.addEventListener(FaultEvent.FAULT, function():void
				{
					Alert.show("Error projecting coordinates.","Error");
				});
			}
			
			//UPDARTED FOR API 3.0
			var projectParams:ProjectParameters =  new ProjectParameters();
				projectParams.outSpatialReference = new SpatialReference(toWKID);
				projectParams.geometries =[mapPoint];
			
			this.geometryService.project(projectParams);
		}
	}
}