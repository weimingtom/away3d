package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
                               
    import flash.display.Graphics;
    import flash.display.BitmapData;
    import flash.geom.Matrix;

    public class DrawScaledBitmap extends DrawPrimitive
    {
        public var bitmap:BitmapData;

        public var v:Vertex2D;

        //public var x:Number;
        //public var y:Number;
        public var scale:Number;
        public var left:Number;
        public var top:Number;
        public var width:Number;
        public var height:Number;

        public function DrawScaledBitmap(bitmap:BitmapData, v:Vertex2D, scale:Number)
        {
            this.bitmap = bitmap;
            this.v = v;
            this.scale = scale;
            calc();
        }

        public function calc():void
        {
            screenZ = v.z;
            minZ = screenZ;
            maxZ = screenZ;
            width = bitmap.width * scale;
            height = bitmap.height * scale;
            left = v.x - width/2;
            top  = v.y - height/2;
            minX = int(Math.ceil(left));
            minY = int(Math.ceil(top));
            maxX = int(Math.floor(left + width));
            maxY = int(Math.floor(top + height));
        }

        public override function clear():void
        {
            bitmap = null;
        }

        public override function render(session:RenderSession):void
        {
            var graphics:Graphics = session.graphics;
            graphics.lineStyle();
            graphics.beginBitmapFill(bitmap, new Matrix(scale, 0, 0, scale, minX, minY), false);
            graphics.drawRect(minX, minY, maxX-minX, maxY-minY);
            //graphics.beginBitmapFill(bitmap, new Matrix(scale, 0, 0, scale, minX, minY));
            //graphics.drawRect(left, top, width, height);
            graphics.endFill();
        }

        public override function contains(x:Number, y:Number):Boolean
        {   
            return true;
        }
    }
}
