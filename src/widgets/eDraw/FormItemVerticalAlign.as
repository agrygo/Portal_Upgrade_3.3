package widgets.eDraw
{
	import mx.containers.FormItem;
	
	[Style(name="verticalAlign", type="String", enumeration="bottom,middle,top", inherit="no")]
	
	public class FormItemVerticalAlign extends FormItem
	{
		public function FormItemVerticalAlign()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w, h);   
			// vertically align (top by default)
			var verticalAlign:String = getStyle("verticalAlign");
			if (verticalAlign == "middle") {   
				itemLabel.y = Math.max(0, (h - itemLabel.height) / 2);
			} else if (verticalAlign == "bottom") {
				var padBottom:Number = getStyle("paddingBottom");
				itemLabel.y = Math.max(0, h - itemLabel.height - padBottom);
			}
		}
	}
}