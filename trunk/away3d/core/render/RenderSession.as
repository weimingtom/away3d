package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import flash.utils.*;
    import flash.geom.*;
    import flash.display.*;

    /** Object holding information for one rendering frame */
    public final class RenderSession
    {
        public var scene:Scene3D;
        public var camera:Camera3D;
        public var container:Sprite;
        public var clip:Clipping;
        public var lightarray:LightArray;
        public var time:int;
        
		public var gfx:Graphics
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
        
        internal var a2:Number;
        internal var b2:Number;
        internal var c2:Number;
        internal var d2:Number;

        public function renderTriangleBitmap(bitmap:BitmapData, a:Number, b:Number, c:Number, d:Number, tx:Number, ty:Number, 
            v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number, smooth:Boolean, repeat:Boolean):void
        {
            	gfx = _graphics || graphics;
            	a2 = v1x - v0x;
            	b2 = v1y - v0y;
            	c2 = v2x - v0x;
            	d2 = v2y - v0y;

            gfx.lineStyle();
            gfx.beginBitmapFill(bitmap,
            		new Matrix(a*a2 + b*c2, a*b2 + b*d2, c*a2 + d*c2, c*b2 + d*d2, tx*a2 + ty*c2 + v0x, tx*b2 + ty*d2 + v0y),
            		repeat,
            		smooth && (v0x*(v2y - v1y) + v1x*(v0y - v2y) + v2x*(v1y - v0y) > 400));
            
            gfx.moveTo(v0x, v0y);
            gfx.lineTo(v1x, v1y);
            gfx.lineTo(v2x, v2y);
            gfx.endFill();

        }

        public function renderTriangleColor(color:int, alpha:Number, 
            v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number):void
        {
            gfx = _graphics || graphics;

            gfx.lineStyle();
            gfx.beginFill(color, alpha);
            gfx.moveTo(v0x, v0y);
            gfx.lineTo(v1x, v1y);
            gfx.lineTo(v2x, v2y);
            gfx.endFill();
        }

        public function renderTriangleLine(color:int, alpha:Number, width:Number,
            v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number):void
        {
            gfx = _graphics || graphics;

            gfx.lineStyle(color, alpha, width);
            gfx.moveTo(v0x, v0y);
            gfx.lineTo(v1x, v1y);
            gfx.lineTo(v2x, v2y);
            gfx.lineTo(v0x, v0y);
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

