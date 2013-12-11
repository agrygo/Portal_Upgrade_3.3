/**
 * http://www.abdulqabiz.com/blog/archives/2006/06/16/a-mxml-component-that-embeds-javascript-in-html/
 */
package widgets.StreetView.util
{
    import flash.external.ExternalInterface;
    import mx.core.IMXMLObject;
    
    [DefaultProperty("source")]
    public class JavaScript implements IMXMLObject
    {
        public var source:String;
        
        public function JavaScript()
        {
        }
        
        public function initialized(document:Object, id:String):void
        {
            const script:String = source.replace(/(^\s+)|([\r\n]\s*)|(\s+$)/g, "");
            const call:String = "document.insertScript=function(){try{" + script + "}catch(e){alert(e.message)}}";
            ExternalInterface.call(call);
        }
    }
}