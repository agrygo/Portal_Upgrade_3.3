////////////////////////////////////////////////////////////////////////////////
//
// Delevoped by Robert Scheitlin
//
////////////////////////////////////////////////////////////////////////////////

package widgets.eSearch
{
	import spark.components.gridClasses.GridColumn;
	
	public class joinDataGridColumn extends GridColumn
	{
		public function joinDataGridColumn(columnName:String=null)
		{
			super(columnName);
			sortCompareFunction=labelCompareFunction1;
		}
		
		public function labelCompareFunction1(obj1:Object, obj2:Object, column:GridColumn = null):int
		{  
			var lab1:Object;  
			var lab2:Object;  
			
			if(labelFunction!=null){    
				lab1= labelFunction(obj1,this);  
				lab2= labelFunction(obj2,this);  
			}
			
			
			if(is_numeric(lab1) && is_numeric(lab2)){
				var cVal1:Number = Number(lab1);
				var cVal2:Number = Number(lab2);
				if(cVal1<cVal2)   
					return -1;  
				if(cVal1==cVal2)   
					return 0;  
				if(cVal1>cVal2)   
					return 1;
			}else{
				if(lab1<lab2)   
					return -1;  
				if(lab1==lab2)   
					return 0;  
				if(lab1>lab2)   
					return 1;
			} 
			return 0  
		}
		
		private function is_numeric(val:*):Boolean {
			
			if (!isNaN(Number(val))){
				return true;
			}
			return false;
		}  
	}
}