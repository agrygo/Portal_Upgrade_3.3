////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2010 ESRI
//
// All rights reserved under the copyright laws of the United States.
// You may freely redistribute and use this software, with or
// without modification, provided you include the original copyright
// and use restrictions.  See use restrictions in the file:
// <install location>/License.txt
//
////////////////////////////////////////////////////////////////////////////////
package widgets.eSearch
{
	import com.esri.ags.Graphic;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.symbols.Symbol;
	import flash.events.EventDispatcher;
	
	[Bindable]
	[RemoteClass(alias="widgets.eSearch.SearchResult")]
	
	public class SearchResult extends EventDispatcher
	{
	    public var title:String;
		
		public var icon:String;
	
	    public var content:String;
		
		public var zoompercent:Number;
		
		public var zoomscale:Number;
	
	    public var point:MapPoint;
		
		public var links:Array = [];
		
		public var graphic:Graphic;
		
		public var selected:Boolean;
		
		public var oid:Number;
		
		public var multi:String;
		
		public var relateicon:String;
		
		public var relates:Array;
		
		public var relatetooltip:String;

		//Modified 7/15/2011 Create variables to only show the go to details button if 
		//it is the parcels layer
		public var parcelLayerName:String;
		public var selectedLayerName:String;
	}
}