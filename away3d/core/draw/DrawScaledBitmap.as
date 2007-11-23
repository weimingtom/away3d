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

    /** Scaled bitmap primitive */
    public class DrawScaledBitmap extends DrawPrimitive
    {
        public var bitmap:BitmapData;

        public var v:ScreenVertex;

        public var scale:Number;
        public var left:Number;
        public var top:Number;
        public var width:Number;
        public var height:Number;

        public var smooth:Boolean;

        public function DrawScaledBitmap(source:Object3D, bitmap:BitmapData, v:ScreenVertex, scale:Number, smooth:Boolean)
        {
            this.source = source;
            this.bitmap = bitmap;
            this.v = v;
            this.scale = scale;
            this.smooth = smooth;
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

        public override function render():void
        {
            var graphics:Graphics = object.session.graphics;
            graphics.lineStyle();
            //graphics.beginBitmapFill(bitmap, new Matrix(scale, 0, 0, scale, minX, minY), false);
            //graphics.drawRect(minX, minY, maxX-minX, maxY-minY);
            graphics.beginBitmapFill(bitmap, new Matrix(scale, 0, 0, scale, left, top), false, smooth);
            graphics.drawRect(left, top, width, height);
            graphics.endFill();
        }

        public override function contains(x:Number, y:Number):Boolean
        {   
            if (!bitmap.transparent)
                return true;

            var px:int = int(Math.round((x-left)/scale));
            var py:int = int(Math.round((y-top)/scale));
            if (px < 0)
                px = 0;
            if (py < 0)
                py = 0;
            if (px >= bitmap.width)
                px = bitmap.width-1;
            if (py >= bitmap.height)
                py = bitmap.height-1;

            var p:uint = bitmap.getPixel(px, py);
            return (p >> 24) <= 0x80;
        }
    }
}
