package widgets.eSearch.utils
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IViewCursor;
	import mx.controls.Alert;
	import mx.core.ClassFactory;
	import mx.formatters.DateFormatter;
	import mx.utils.ObjectUtil;
	
	import spark.collections.Sort;
	import spark.components.DataGrid;
	import spark.components.gridClasses.GridColumn;
	
	import widgets.eSearch.HyperLinkColumn;
	import widgets.eSearch.HyperLinkIconColumn;
	
	public class PrintUtil
	{
		private static function returnArrayOfSheetsNeededHorizontally(mpageWidth:Number, dataGrid:DataGrid):Array
		{
			var columnArray:ArrayList = dataGrid.columns as ArrayList;
			var retArray:Array = [];
			var sheet:Sprite
			var currPos:int = 36;
			var columnCount:int = columnArray.length;
			var dataGridColumn:GridColumn;
			sheet = new Sprite();
			
			for(var h:int = 0; h < columnCount; h++){
				dataGridColumn = columnArray.getItemAt(h) as GridColumn;
				
				if(!dataGridColumn.visible){
					continue;
				}
				if(dataGridColumn.dataField == "icon"){
					continue;
				}
				currPos += convP2MM(dataGridColumn.width);
				if (currPos > mpageWidth){
					currPos = 36;
					retArray.push(sheet);
					sheet = new Sprite();
					currPos += convP2MM(dataGridColumn.width);
				}
			}
			retArray.push(sheet);
			return retArray;
		}
		
		private static function duplicateTextField($textField:TextField):TextField
		{
			var dupeTextField:TextField = new TextField();
			dupeTextField.wordWrap = $textField.wordWrap;
			dupeTextField.background = $textField.background;
			dupeTextField.border = $textField.border;
			dupeTextField.borderColor = $textField.borderColor;
			dupeTextField.backgroundColor = $textField.backgroundColor;
			dupeTextField.x = $textField.x;
			dupeTextField.y = 36;//$textField.y;
			dupeTextField.width = $textField.width;
			dupeTextField.height = $textField.height;
			dupeTextField.focusRect = $textField.focusRect;
			dupeTextField.multiline = $textField.multiline;
			dupeTextField.autoSize = $textField.autoSize;
			dupeTextField.defaultTextFormat = $textField.defaultTextFormat;
			dupeTextField.text = $textField.text;
			dupeTextField.textColor = $textField.textColor;
			return dupeTextField;
		}

		private static function convP2MM(value:Number):Number
		{
			/*The auto sized field widths are to large for the printed output so some
			  downsizing has to occur */
			return value / 1.5;
		}
        
		public static function printDataGrid(printProps:PrintProperties, stage:Stage = null, browserName:String="NA"):void {
			var pageArray:Array = [];
			var printJob:PrintJob = new PrintJob();
			var sheetArr:Array;
			var sheetHeaders:Array = [];
			var s:int;
			
			if (printJob.start()){
				try{
                    //trace(browserName + " Page Width: " + printJob.pageWidth);
                    //trace(browserName + " Page Height: " + printJob.pageHeight);
					var mpageWidth:Number = printJob.pageWidth - ((browserName=="Chrome")?0:72); //this equals a .5 inch margin on left and right
					var mpageHeight:Number = printJob.pageHeight - ((browserName=="Chrome")?0:72); //this equals a .5 inch margin on left and right
					
					sheetArr = returnArrayOfSheetsNeededHorizontally(mpageWidth,printProps.dataGrid);
					var topM:int = ((browserName=="Chrome")?40:80);
					
					//Report Title
					var rheader:TextField = new TextField();
					rheader.x = 0
					rheader.y = ((browserName=="Chrome")?0:36);
					rheader.width = printJob.pageWidth;
					rheader.height = 24;
					rheader.multiline = false;
					rheader.focusRect = new ClassFactory(null);
					
					var format:TextFormat = new TextFormat();
					format.font = "Helvetica";
					format.align = TextFormatAlign.CENTER;
					format.color = 0x000000;
					format.size = 12;
					format.bold = true;
					
					rheader.defaultTextFormat = format;
					format.bold = true;
					format.size = 18;
					rheader.autoSize = TextFieldAutoSize.NONE;
					rheader.text = printProps.title + " ";
					rheader.setTextFormat(format);
					sheetArr[0].addChild(rheader);
					
					var currPosX:int = ((browserName=="Chrome")?0:32);
					var currPos:int = topM;
					
					try{
						var data:String = "";
						var columnArray:ArrayList = printProps.dataGrid.columns as ArrayList;
						var columnCount:int = columnArray.length;
						var dataGridColumn:GridColumn;
						var dataProvider:ArrayCollection = ObjectUtil.copy(printProps.dataGrid.dataProvider) as ArrayCollection;
						
						//Set the sorting
						var sortFields:Array = [];
						var dpSort:Sort = new Sort();
						for (var v:int = 0; v < printProps.sortCols.length; v++){
							dataGridColumn = columnArray.getItemAt(printProps.sortCols[v]) as GridColumn;
							sortFields.push(dataGridColumn.sortField);
						}
						dpSort.fields = sortFields;
						dataProvider.sort = dpSort;
						dataProvider.refresh();
						
						var rowCount:int = dataProvider.length;
						var dp:Object = null;
						var cursor:IViewCursor = dataProvider.createCursor();
						var j:int = 0;
						
						var txt:TextField;
						var format2:TextFormat;
						var currHPosX1:int = ((browserName=="Chrome")?0:36);
						var hSheetIndx:int = 0;
						var headers:Array = [];
						
						//loop through the column headers to draw the table headers
						for(var h:int = 0; h < columnCount; h++){
							dataGridColumn = columnArray.getItemAt(h) as GridColumn;
							
							if(!dataGridColumn.visible){
								continue;
							}
							if(dataGridColumn.dataField == "icon"){
								continue;
							}
							
							txt = new TextField();
							txt.wordWrap = true;
							txt.background = true;
							txt.border = true;
							txt.borderColor = 0x000000;
							txt.backgroundColor = printProps.headerBGColor;
							txt.y = currPos;
							txt.x = currHPosX1;
							currHPosX1 += convP2MM(dataGridColumn.width);
							
							if (currHPosX1 > mpageWidth){
								currHPosX1 = ((browserName=="Chrome")?0:36);
								if((hSheetIndx + 1) < sheetArr.length){
									hSheetIndx++;
								}
								sheetHeaders.push(headers);
								txt.x = currHPosX1;
								currHPosX1 += convP2MM(dataGridColumn.width);
								headers = [];
							}
							
							txt.width = convP2MM(dataGridColumn.width);
							txt.height = 15;
							txt.focusRect = new ClassFactory(null);
							txt.multiline = false;
							txt.autoSize = TextFieldAutoSize.NONE;
							format2 = new TextFormat();
							format2.font = "Helvetica";
							format2.color = printProps.headerFontColor;
							format2.size = 8;
							format2.align = TextFormatAlign.CENTER;
							format2.bold = true;
							txt.defaultTextFormat = format2;
							txt.text = dataGridColumn.headerText;
							sheetArr[hSheetIndx].addChild(txt);
							headers.push(duplicateTextField(txt));
						}
						sheetHeaders.push(headers);
						currPos += 15;
						
						//loop through rows
						while (!cursor.afterLast){
							var object:Object = null;
							object = cursor.current;
							var currPosX1:int = ((browserName=="Chrome")?0:36);
							var myBGColor:uint = 0xffffff;
							hSheetIndx = 0;
							
							//loop through all columns for the row
							for(var i:int = 0; i < columnCount; i++){
								dataGridColumn = columnArray.getItemAt(i) as GridColumn;

								//Exclude column data which is invisible (hidden)
								if(!dataGridColumn.visible){
									continue;
								}
								if(dataGridColumn.dataField == "icon"){
									continue;
								}
								
								txt = new TextField();
								txt.wordWrap = true;
								txt.background = true;
								txt.border = true;
								txt.borderColor = 0x000000;
								txt.backgroundColor = 0xffffff;
								txt.y = currPos;
								txt.x = currPosX1;
								currPosX1 += convP2MM(dataGridColumn.width);
								
								if (currPosX1 > mpageWidth){
									currPosX1 = ((browserName=="Chrome")?0:36);
									if((hSheetIndx + 1) < sheetArr.length){
										hSheetIndx++;
									}
									txt.x = currPosX1;
									currPosX1 += convP2MM(dataGridColumn.width);
								}
								
								txt.width = convP2MM(dataGridColumn.width);
								txt.height = 15;
								txt.focusRect = new ClassFactory(null);
								txt.multiline = false;
								txt.autoSize = TextFieldAutoSize.NONE;
								format2 = new TextFormat();
								format2.font = "Helvetica";
								format2.color = 0x000000;
								format2.size = 8;
								format2.align = TextFormatAlign.LEFT;
								format2.bold = false;
								txt.defaultTextFormat = format2;
								
								if((dataGridColumn.itemRenderer == HyperLinkColumn)||(dataGridColumn.itemRenderer == HyperLinkIconColumn)){
									if(object[dataGridColumn.dataField] != null){
										txt.text = object[dataGridColumn.dataField];
									}else{
										txt.text = "";
									}
								}else{
									if(dataGridColumn.itemToLabel(object) != null){
										txt.text = dataGridColumn.itemToLabel(object);
									}else{
										txt.text = "";
									}
								}
								sheetArr[hSheetIndx].addChild(txt);
							}
							currPos += 15;
							if (currPos > mpageHeight){
								currPos = 36;
								hSheetIndx = 0;
								var newSheetArr:Array = [];
								for(s=0; s<sheetArr.length; s++){
									pageArray.push(sheetArr[s]);
									var sheet:Sprite = new Sprite();
									if(printProps.repeatHeader){
										for(var sh:int=0; sh < sheetHeaders[s].length; sh++){
											sheet.addChild(duplicateTextField(sheetHeaders[s][sh]));
										}
									}
									newSheetArr.push(sheet);
								}
								if(printProps.repeatHeader){currPos += 15;};
								//make a new sheet array
								sheetArr = newSheetArr;
							}
							cursor.moveNext ();
						}
						//set references to null:
						dataProvider = null;
						columnArray = null;
						dataGridColumn = null;
						for(s=0; s<sheetArr.length; s++){
							pageArray.push(sheetArr[s]);
						}
					}
					
					catch(error:Error)
					{
						Alert.show(error.message);
					}
				}
				catch (error:Error){
					Alert.show(error.message);
				}
				//Add page footers
				for (var ps:int=0; ps<pageArray.length; ps++){
					var pageSprite:Sprite = pageArray[ps] as Sprite;
                    
                    //Google Chrome Print work around
                    if (stage){
                        stage.addChild(pageSprite);
                    }
					var footer:TextField = new TextField();
					footer.x = ((browserName=="Chrome")?0:36);
					footer.y = printJob.pageHeight - ((browserName=="Chrome")?0:36);
					footer.width = printJob.pageWidth;
					footer.height = 30;
					footer.focusRect = new ClassFactory(null);
					var formatf:TextFormat = new TextFormat();
					formatf.font = "Helvetica";
					formatf.color = 0x000000;
					formatf.size = 8;
					formatf.italic = true;
					
					footer.defaultTextFormat = formatf;
					footer.autoSize = TextFieldAutoSize.LEFT;
					var pn:int = ps + 1;
					var pop:Array = printProps.pageofpage.split("##");
					footer.text = pop[0] + pn + pop[1] + pageArray.length;
					pageSprite.addChild(footer);
					
					if(printProps.includedate){
						footer =  new TextField();
						footer.x = 36;
						footer.y = printJob.pageHeight - ((browserName=="Chrome")?0:36);
						footer.width = printJob.pageWidth - ((browserName=="Chrome")?36:72);
						footer.height = 30;
						footer.focusRect = new ClassFactory(null);
						
						footer.defaultTextFormat = formatf;
						footer.autoSize = TextFieldAutoSize.RIGHT;
						var df:DateFormatter = new DateFormatter();
						df.formatString = printProps.dateformat;
						footer.text = df.format(new Date());
						pageSprite.addChild(footer);
					}
					
					if(printProps.disclaimer != ""){
						footer =  new TextField();
						footer.x = 36;
						footer.y = printJob.pageHeight - ((browserName=="Chrome")?0:36);
						footer.width = printJob.pageWidth - ((browserName=="Chrome")?0:72);
						footer.height = 30;
						footer.focusRect = new ClassFactory(null);
						
						footer.defaultTextFormat = formatf;
						footer.autoSize = TextFieldAutoSize.CENTER;
						footer.text = printProps.disclaimer;
						pageSprite.addChild(footer);
					}
					
					printJob.addPage(pageSprite, new Rectangle(0, 0, printJob.paperWidth,printJob.paperHeight));
				}
				printJob.send();
                //Google Chrome Print work around
                for (var ps2:int=0; ps2<pageArray.length; ps2++){
                    var pageSprite2:Sprite = pageArray[ps2] as Sprite;
                    if (stage && stage.contains(pageSprite2)){
                        stage.removeChild(pageSprite2);//once done remove from stage
                    }
                }
                //Clean up Objects
                pageArray = null;
                printJob = null;
                sheetArr = null;
                sheetHeaders = null;
			}
		}
	}
}