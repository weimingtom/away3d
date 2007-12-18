package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
                               
    import flash.display.Graphics;
    import flash.display.BitmapData;
    import flash.geom.Matrix;

    /** Unscaled bitmap drawing primitive */
    public class DrawBitmap extends DrawPrimitive
    {
        public var bitmap:BitmapData;

        public var v:ScreenVertex;

        public var left:Number;
        public var top:Number;
        public var width:Number;
        public var height:Number;

        public function DrawBitmap(source:Object3D, bitmap:BitmapData, v:ScreenVertex)
        {
            this.source = source;
            this.bitmap = bitmap;
            this.v = v;
            calc();
        }

        public function calc():void
        {
            screenZ = v.z;
            minZ = screenZ;
            maxZ = screenZ;
            minX = v.x - bitmap.width/2;
            minY = v.y - bitmap.height/2;
            maxX = v.x + bitmap.width/2;
            maxY = v.y + bitmap.height/2;
        }

        public override function clear():void
        {
            bitmap = null;
        }

        public override function render():void
        {
            var graphics:Graphics = source.session.graphics;
            graphics.lineStyle();
            graphics.beginBitmapFill(bitmap, new Matrix(1, 0, 0, 1, v.x-bitmap.width/2, v.y-bitmap.height/2));
            graphics.drawRect(v.x-bitmap.width/2, v.y-bitmap.height/2, bitmap.width, bitmap.height);
            graphics.endFill();
        }

        public override function contains(x:Number, y:Number):Boolean
        {   
            return true;
        }
    }
}
