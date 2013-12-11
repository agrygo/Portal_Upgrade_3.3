package widgets.StreetView
{
    import com.esri.ags.Map;
    import com.esri.ags.geometry.Geometry;
    import com.esri.ags.geometry.MapPoint;
    import com.esri.ags.symbols.Symbol;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    public class StreetViewManSymbol extends Symbol
    {
        private static const PI_OVER_180:Number = Math.PI / 180.0;
        
        [Embed(source="assets/images/SVM.png")]
        private const SVM:Class;
        
        private const m_matrix:Matrix = new Matrix();
        
        private var m_bitmapData:BitmapData;
        
        public function StreetViewManSymbol()
        {
            const bitmap:Bitmap = new SVM();
            m_bitmapData = bitmap.bitmapData;
        }
        
        override public function clear(sprite:Sprite):void
        {
            // clear and position the sprite
            sprite.graphics.clear();
            sprite.x = 0;
            sprite.y = 0;
        }
        
        override public function draw(sprite:Sprite, geometry:Geometry, attributes:Object, map:Map):void
        {
            // duplicate the geometry on the visible worlds
            var geometries:Vector.<Geometry> = getWrapAroundGeometries(map, geometry);
            
            if (geometries)
            {
                for each (var geom:Geometry in geometries)
                {
                    // handle the geometry type
                    if (geom.type == Geometry.MAPPOINT)
                    {
                        while( sprite.numChildren > 0 ) {
                            sprite.removeChildAt( 0 );
                        }
                        const mapPoint:MapPoint = geom as MapPoint;
                        var rSprite:Sprite = new Sprite();
                        m_matrix.createGradientBox(80, 80, 0, -40, -40);
                        
                        rSprite.graphics.beginGradientFill(GradientType.RADIAL, [ 0x417c34, 0x75dc5c ], [ 1.0, 0.1 ], [ 25, 255 ], m_matrix);
                        rSprite.graphics.moveTo(0, 0);
                        curveTo(rSprite.graphics, 40.0 * PI_OVER_180, -40.0 * PI_OVER_180, 0.0, 0.0, 40);
                        rSprite.graphics.lineTo(0, 0);
                        rSprite.graphics.endFill();
                        const r:Number = attributes.rotation;
                        if( r <= 270){
                            rSprite.rotation = r - 90.0;
                        }else{
                            rSprite.rotation = r - 450;
                        }
                        
                        sprite.x = toScreenX(map, mapPoint.x);
                        sprite.y = toScreenY(map, mapPoint.y);
   
                        /*m_matrix.identity();
                        m_matrix.tx = m_bitmapData.width * -0.5;
                        m_matrix.ty = m_bitmapData.height * -0.5;
                        sprite.graphics.beginBitmapFill(m_bitmapData, m_matrix, false, true);
                        sprite.graphics.drawRect(m_matrix.tx, m_matrix.ty, m_bitmapData.width, m_bitmapData.height);
                        sprite.graphics.endFill();*/
                        sprite.graphics
                        var bMap:Bitmap = new Bitmap(m_bitmapData);
                        bMap.x = bMap.y = -30;

                        sprite.addChild(rSprite);
                        sprite.addChild(bMap);
                    }
                }
            }
        }
        
        private function curveTo(g:Graphics, fromRadian:Number, toRadian:Number, centerx:Number, centery:Number, radius:Number):void
        {
            const div:Number = 7;
            const angleRange:Number = toRadian - fromRadian;
            const controlRadius:Number = radius / Math.cos(Math.abs(angleRange) / (div * 2));
            const startPoint:Point = new Point(Math.round((Math.cos(fromRadian) * radius) + centerx), Math.round((-Math.sin(fromRadian) * radius) + centery));
            
            g.lineTo(startPoint.x, startPoint.y);
            
            for (const x:int = 0; x < div; x++)
            {
                const a:Number = fromRadian + (x * angleRange / div);
                const p2:Point = new Point(Math.cos(a + angleRange / div) * radius + centerx, -Math.sin(a + angleRange / div) * radius + centery);
                const cp:Point = new Point(Math.cos(a + (angleRange / (div * 2))) * controlRadius + centerx, -Math.sin(a + (angleRange / (div * 2))) * controlRadius + centery);
                
                g.curveTo(cp.x, cp.y, p2.x, p2.y);
            }
        }
        
        override public function destroy(sprite:Sprite):void
        {
            sprite.graphics.clear();
        }
    }
}