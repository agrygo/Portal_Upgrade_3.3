package widgets.eSearch
{
	/*This code is by Mark Hoyland
	taken from his selection widget 10 Oct 2012
	http://www.arcgis.com/home/item.html?id=20ed6af9ab204548bbf092d51b51fef8
	*/
	import com.esri.ags.FeatureSet;
	import com.esri.ags.tasks.QueryTask;
	import com.esri.ags.tasks.supportClasses.Query;
	
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.rpc.AsyncResponder;
	
	import spark.formatters.DateTimeFormatter;
	
	/**
	 *  Dispatched when the paging query is fully complete.
	 *  
	 *  @eventType "pagingComplete"
	 */
	[Event(name="pagingComplete", type="mx.events.FlexEvent")]
	
	/**
	 *  Dispatched when the paging query faults.
	 *  
	 *  @eventType "pagingFault"
	 */
	[Event(name="pagingFault", type="mx.events.FlexEvent")]
	
	[Bindable]
	public class PagingQueryTask extends EventDispatcher
	{
		private var _url:String;
		private var _fieldName:String;
		private var _allValues:Array = [];
		private var _uniqueValues:Array = [];
		private var _isQuerying:Boolean = false;
		private var _featuresProcessed:int = 0;
		private var _featuresTotal:int = 0;
		private var _sItemVal:SearchExpValueItem;
		private var _uniqueCache:Object;
		private var _useAMF:Boolean;
		private var _pagingEscaped:Boolean;
		private var _isRequired:Boolean;
		private var _dateFormat:String;
		private var _useUTC:Boolean;
		private var blankStringExists:Boolean;
		private var _token:String;
        private var _proxy:String;
		
		private var query:Query = new Query;
		private var queryTask:QueryTask = new QueryTask();
		
		//Array of all ObjectIds for given service populated using executeForIDs call
		private var objectIdsArray:Array = [];
		private var esc:Boolean = false;
		
		private var iStart:int = 0;
		private var iMaxRecords:int = 0;
		
		private var dateFormatter:DateTimeFormatter = new DateTimeFormatter();
		
		public function PagingQueryTask(url:String="", fieldName:String="", useAMF:Boolean=false, 
										sItemVal:SearchExpValueItem=null, uniqueCache:Object=null, 
										isRequired:Boolean=false, dateFormat:String="",
										useUTC:Boolean=false, token:String=null, proxy:String=null)
		{
			_url = url;
			_fieldName = fieldName;
			_sItemVal = sItemVal;
			_uniqueCache = uniqueCache;
			_useAMF = useAMF;
			_isRequired = isRequired;
			_dateFormat = dateFormat;
			_useUTC = useUTC;
			_token = token;
            _proxy = proxy;
		}

		/**
		 * String with the field name for which 
		 * unique values will be returned.
		 */
		public function set fieldName(value:String):void
		{
			_fieldName = value;
		}
		public function get fieldName():String
		{
			return _fieldName;
		}
		
		/**
		 * String with the token for the searched 
		 * Layer.
		 */
		public function set token(value:String):void
		{
			_token = value;
		}
		
		/**
		 * Boolean as whether to use AMF or not.
		 */
		public function set useAMF(value:Boolean):void
		{
			_useAMF = value;
		}
		
		/**
		 * Boolean as whether to value is required or not.
		 */
		public function set isRequired(value:Boolean):void
		{
			_isRequired = value;
		}
		
		/**
		 * Boolean as whether to use UTC or not.
		 */
		public function set useUTC(value:Boolean):void
		{
			_useUTC = value;
		}
		
		/**
		 * String of Date Format to use to format dates.
		 */
		public function set dateFormat(value:String):void
		{
			_dateFormat = value;
		}
		
		/**
		 * Boolean as to whether the esc key was pressed
		 * before paging was completed.
		 */
		public function get pagingEscaped():Boolean
		{
			return _pagingEscaped;
		}
		
		/**
		 * sItemVal which the unique vals 
		 * will be added to.
		 */
		public function set sItemVal(value:SearchExpValueItem):void
		{
			_sItemVal = value;
		}
		public function get sItemVal():SearchExpValueItem
		{
			return _sItemVal;
		}
		
		/**
		 * uniqueCache which the unique vals array
		 * will be added to.
		 */
		public function set uniqueCache(value:Object):void
		{
			_uniqueCache = value;
		}
		public function get uniqueCache():Object
		{
			return _uniqueCache;
		}
		
		/**
		 * String with the URL of the layer to query.
		 */
		public function set url(value:String):void
		{
			_url = value;
		}
		
		/**
		 * Array of unique features returned from the query. 
		 * <p>Can be used as source for Binding.</p>
		 */
		public function get uniqueValues():Array
		{
			return _uniqueValues;
		}
		private function set uniqueValues(value:Array):void
		{
			_uniqueValues = value;
		}
		
		/**
		 * Array of all features returned from the query. 
		 * <p>Can be used as source for Binding.</p>
		 */
		public function get allValues():Array
		{
			return _allValues;
		}
		private function set allValues(value:Array):void
		{
			_allValues = value;
		}

		/**
		 * Boolean value set to true while the query is in progress.
		 * <p>Can be used as source for Binding.</p>
		 */
		public function get isQuerying():Boolean
		{
			return _isQuerying;
		}
		private function set isQuerying(value:Boolean):void
		{
			_isQuerying = value;
		}
		
		/**
		 * Returns a count of how many features have currently been queried.
		 * <p>Can be used as source for Binding.</p>
		 */
		public function get featuresProcessed():int
		{
			return _featuresProcessed;
		}
		private function set featuresProcessed(value:int):void
		{
			_featuresProcessed = value;
		}
		
		/**
		 * Returns a count of how many features there are.
		 * <p>Can be used as source for Binding.</p>
		 */
		public function get featuresTotal():int
		{
			return _featuresTotal;
		}
		private function set featuresTotal(value:int):void
		{
			_featuresTotal = value;
		}
		
		/**
		 * Allow the user to break out of query by hitting escape key.
		 */
		protected function keyUpHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ESCAPE){
				esc = true;
				_pagingEscaped = true;
			}
		}
		
		/**
		 * Executes a query against an ArcGIS Server map layer or table. 
		 * Uses the ObjectIDS to query the layer, and will keep paging
		 * until all features have been processed. The ArcGIS Server setting for
		 * the maximum returned results, is used as the value for paging.
		 * Pressing the ESC key will cancel the query.
		 * 
		 * <p><code>uniqueValues</code> arrayCollection will be populated with unique features.
		 * <code>allValues</code> array will be populated with all values from the query.
		 * <code>featuresProcessed</code> will be updated with how many features have been processed.
		 * <code>isQuerying</code> will be set to true while the query is still paging.</p>
		 * 
		 */
		public function execute():void
		{
			FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			blankStringExists = false;
			iStart = 0;
			iMaxRecords = 0;
			featuresProcessed = 0;
			featuresTotal = 0;
			
			isQuerying = true;
			
			query.returnGeometry = false;
			query.outFields = [_fieldName]
			query.objectIds = null;
			query.text = "%";
			queryTask.url = _url;
			queryTask.useAMF = _useAMF;
			queryTask.token = _token;
            if(_proxy){
                queryTask.proxyURL = _proxy;
            }
			queryTask.executeForIds(query, new AsyncResponder(onExecuteForIdsComplete, queryTask_faultHandler));
		}
		
		/**
		 * Start querying for features now that the total amount of features is known,
		 * 
		 */
		private function onExecuteForIdsComplete(objectIds:Array, token:Object = null):void
		{
			allValues = [];
			objectIdsArray = objectIds;
			featuresTotal = objectIdsArray.length;
			
			query.where = "";
			query.text = null;			
			query.objectIds = objectIdsArray;
			queryTask.useAMF = _useAMF;
			queryTask.token = _token;
            if(_proxy){
                queryTask.proxyURL = _proxy;
            }
			queryTask.execute(query, new AsyncResponder(queryTask_executeCompleteHandler, queryTask_faultHandler));
		}
		
		/**
		 * Go though the unique values and replace the date numbers with string dates
		 */
		private function replaceDatesWithStrings():void
		{
			var val:String;
			var uVal:SearchDDItem;
			for(var i:int=0; i<uniqueValues.length; i++){
				var dateMS:Number = Number(uniqueValues[i].value);
				if (!isNaN(dateMS)){
					//Fix the date format to use the Spark format
					if(_dateFormat){
						_dateFormat = _dateFormat.replace(/D/g, "d").replace(/Y/g, "y");
					}
					val = msToDate(dateMS, _dateFormat);
				}
				uniqueValues[i].value = val;
				uniqueValues[i].label = val;
			}
			if(_isRequired == false){
				if(blankStringExists){
					uniqueValues.shift();
					uVal = new SearchDDItem;
					uVal.label = " ";
					uVal.value = '" "';
					uniqueValues.splice(0, 0, uVal);
				}
				uVal = new SearchDDItem;
				uVal.label = "";
				uVal.value = "";
				uniqueValues.splice(0, 0, uVal);
			}
			uVal = new SearchDDItem;
			uVal.label = "all";
			uVal.value = "allu";
			uniqueValues.push(uVal);
			dispatchEvent(new FlexEvent("pagingComplete"));
			isQuerying = false;
		}
		
		/**
		* return a date string from a number and a format string and use UTC value
		* @param Number ms the number representation of the date
		* @param String dateFormat the date format to return the string in
		*/
		private function msToDate(ms:Number, dateFormat:String):String
		{
			var date:Date = new Date(ms);
			if (date.milliseconds == 999){ // workaround for REST bug
				date.milliseconds++;
			}
			if (_useUTC){
				date.minutes += date.timezoneOffset;
			}
			if (dateFormat){
				dateFormatter.dateTimePattern = dateFormat;
				var result:String = dateFormatter.format(date);
				if (result){
					return result;
				}else{
					return dateFormatter.errorText;
				}
			}else{
				return date.toLocaleString();
			}
		}
		
		/**
		 * Keep querying the layer until all features have been queried.
		 * Check to see if ESC key has been pressed.
		 */
		private function queryTask_executeCompleteHandler(featureSet:FeatureSet, token:Object = null):void
		{
			FlexGlobals.topLevelApplication.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			query.where = "";
			query.text = null;
			var uVal:SearchDDItem;
			featuresProcessed += featureSet.attributes.length;
			
			allValues = allValues.concat(featureSet.attributes);	

			//check to see if all records were returned.
			if (featuresProcessed >= objectIdsArray.length){
				// get the unique values
				uniqueValues = getDistinctValues(allValues, _fieldName);
				if(_dateFormat != ""){
					replaceDatesWithStrings();
					return;
				}else{
					if(_isRequired == false){
						//trace(ObjectUtil.toString(uniqueValues));
						if(blankStringExists){
							uVal = new SearchDDItem;
							uVal.value = " ";
							uVal.label = '" "';
							uniqueValues.shift();
							uniqueValues.splice(0, 0, uVal);
						}
						uVal = new SearchDDItem;
						uVal.label = "";
						uVal.value = "";
						uniqueValues.splice(0, 0, uVal);
					}
					uVal = new SearchDDItem;
					uVal.label = "all";
					uVal.value = "allu";
					uniqueValues.push(uVal);
					dispatchEvent(new FlexEvent("pagingComplete"));
					isQuerying = false;
					return;
				}
			}
				
			// check to see if max records has been determined.
			// add the max records to the start index as these have already been queried.
			if (iMaxRecords == 0){
				iMaxRecords = featuresProcessed;
				iStart += iMaxRecords;
			}
			
			// Query the server for the next lot of features
			// Use the objectids as the input for the query.
			// Do not continue if the esc button has been pressed.
			if (iStart < objectIdsArray.length && esc == false){
				//If we get this far we need to requery the server for the next lot of records
				isQuerying = true;
				FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
				
				query.objectIds = objectIdsArray.slice(iStart, iStart + iMaxRecords);
				queryTask.useAMF = _useAMF;
				queryTask.token = _token;
                if(_proxy){
                    queryTask.proxyURL = _proxy;
                }
				queryTask.execute(query, new AsyncResponder(queryTask_executeCompleteHandler, 
															queryTask_faultHandler));
				
				iStart += iMaxRecords;
			}
			
			//reset the escape parameter if it was triggered.
			if (esc == true){
				esc = false;
				isQuerying = false;
				dispatchEvent(new FlexEvent("pagingComplete"));
			}
			
			// get the unique values
			uniqueValues = getDistinctValues(allValues, _fieldName);
		}
		
		/**
		 * Reset parameters if query has failed.
		 */
		private function queryTask_faultHandler(info:Object, token:Object = null):void
		{
			isQuerying = false;
			FlexGlobals.topLevelApplication.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			esc = false;
			dispatchEvent(new FlexEvent("pagingComplete"));
			dispatchEvent(new FlexEvent("pagingFault"));
		}
		
		/**
		 * Return an array of unique values.
		 * 
		 * @param array Array of values to parse the unique filter on.
		 * @param fieldName The name of the field in the input array to parse.
		 */
		private function getDistinctValues(array:Array, fieldName:String):Array 
		{
			//prepare result array
			var collection:ArrayCollection = new ArrayCollection(array);
			var distinctValuesCollection:ArrayCollection = new ArrayCollection();
			
			//prepare a temp working array
			var tempPropertyArray:Array = [];
			
			//loop over all the objects in the collection
			for each (var object:Object in collection) {
				//get the value from the object
				var propertyValue:Object
				propertyValue = object[fieldName];
				//write the value as a property. If it exists it will be overwritten
				//which creates a distinct list
				tempPropertyArray[propertyValue] = true;
			}
			
			//loop over all the properties in the tempPropertyArray
			for (var propertyName:String in tempPropertyArray) {
				//add the propertyName (which is actually a distinct property value) 
				//to the distinct values collection
				if(propertyName == " "){
					blankStringExists = true;
				}
                const uVal:SearchDDItem = new SearchDDItem();
                uVal.label = propertyName;
                uVal.value = propertyName;
                distinctValuesCollection.addItem(uVal);
			}
			
			distinctValuesCollection.source.sortOn("value");
			//return the collection of distinct values
			return distinctValuesCollection.source;
		}
	}
}