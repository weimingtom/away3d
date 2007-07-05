package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.Graphics;
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Point;

    /** Helper class for drawing operations */
    public class RenderTriangle
    {
        public static function renderBitmap(graphics:Graphics, bitmap:BitmapData, a:Number, b:Number, c:Number, d:Number, tx:Number, ty:Number, 
            v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number, smooth:Boolean, repeat:Boolean):void
        {
            var a2:Number = v1x - v0x;
            var b2:Number = v1y - v0y;
            var c2:Number = v2x - v0x;
            var d2:Number = v2y - v0y;
                                   
            var matrix:Matrix = new Matrix(a*a2 + b*c2, 
                                           a*b2 + b*d2, 
                                           c*a2 + d*c2, 
                                           c*b2 + d*d2,
                                           tx*a2 + ty*c2 + v0x, 
                                           tx*b2 + ty*d2 + v0y);

            graphics.lineStyle();
            graphics.beginBitmapFill(bitmap, matrix, repeat, smooth && (v0x*(v2y - v1y) + v1x*(v0y - v2y) + v2x*(v1y - v0y) > 400));
            graphics.moveTo(v0x, v0y);
            graphics.lineTo(v1x, v1y);
            graphics.lineTo(v2x, v2y);
            graphics.endFill();

        }

        public static function renderColor(graphics:Graphics, color:int, alpha:Number, 
            v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number):void
        {
            graphics.lineStyle();
            graphics.beginFill(color, alpha);
            graphics.moveTo(v0x, v0y);
            graphics.lineTo(v1x, v1y);
            graphics.lineTo(v2x, v2y);
            graphics.endFill();

        }
    }
}