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

    public class DrawBitmap extends DrawPrimitive
    {
        public var bitmap:BitmapData;

        public var x:Number;
        public var y:Number;

        public function DrawBitmap(bitmap:BitmapData, x:Number, y:Number, z:Number)
        {
            this.bitmap = bitmap;
            this.x = x;
            this.y = y;
            this.screenZ = z;
            calc();
        }
        /*
        public static function create(bitmap:BitmapData, x:Number, y:Number, z:Number):DrawBitmap
        {
            var db:DrawBitmap = new DrawBitmap();
            db.bitmap = bitmap;
            db.x = x;
            db.y = y;
            db.screenZ = z;
            db.calc();
            return db;
        }
        */
        public function calc():void
        {
            minZ = screenZ;
            maxZ = screenZ;
            minX = int(Math.floor(x - bitmap.width/2));
            minY = int(Math.floor(y - bitmap.height/2));
            maxX = int(Math.ceil(x + bitmap.width/2));
            maxY = int(Math.ceil(y + bitmap.height/2));
        }

        public override function clear():void
        {
            bitmap = null;
        }

        public override function render(session:RenderSession):void
        {
            var graphics:Graphics = session.graphics;
            graphics.lineStyle();
            graphics.beginBitmapFill(bitmap, new Matrix(1, 0, 0, 1, x-bitmap.width/2, y-bitmap.height/2));
            graphics.drawRect(x-bitmap.width/2, y-bitmap.height/2, bitmap.width, bitmap.height);
            graphics.endFill();
        }

        public override function contains(x:Number, y:Number):Boolean
        {   
            return true;
        }
    }
}
