package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import flash.utils.*;
    import flash.geom.*;
    import flash.display.*;

    /** Object holding information for one rendering frame */
    public class RenderSession
    {
        public var scene:Scene3D;
        public var camera:Camera3D;
        public var container:Sprite;
        public var clip:Clipping;
        public var lightarray:LightArray;
        public var time:int;

        private var _graphics:Graphics;

        public function get graphics():Graphics
        {
            if (_graphics == null)
            {
                var sprite:Sprite = new Sprite();
                container.addChild(sprite);
                _graphics = sprite.graphics;
            }
            return _graphics;
        }

        public function renderTriangleBitmap(bitmap:BitmapData, a:Number, b:Number, c:Number, d:Number, tx:Number, ty:Number, 
            v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number, smooth:Boolean, repeat:Boolean):void
        {
            var graphics:Graphics = _graphics || this.graphics;

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

        public function renderTriangleColor(color:int, alpha:Number, 
            v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number):void
        {
            var graphics:Graphics = _graphics || this.graphics;

            graphics.lineStyle();
            graphics.beginFill(color, alpha);
            graphics.moveTo(v0x, v0y);
            graphics.lineTo(v1x, v1y);
            graphics.lineTo(v2x, v2y);
            graphics.endFill();
        }

        public function renderTriangleLine(color:int, alpha:Number, width:Number,
            v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number):void
        {
            var graphics:Graphics = _graphics || this.graphics;

            graphics.lineStyle(color, alpha, width);
            graphics.moveTo(v0x, v0y);
            graphics.lineTo(v1x, v1y);
            graphics.lineTo(v2x, v2y);
            graphics.lineTo(v0x, v0y);
        }

        public function addDisplayObject(child:DisplayObject):void
        {
            _graphics = null;
            container.addChild(child);
            child.visible = true;
        }

        public function RenderSession(scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping, lightarray:LightArray)
        {
            this.scene = scene;
            this.camera = camera;
            this.container = container;
            _graphics = container.graphics;
            this.clip = clip;
            this.lightarray = lightarray;
            this.time = getTimer();
        }
    }
}

