package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import flash.utils.*;
    import flash.geom.*;
    import flash.display.*;
    import away3d.core.mesh.Vertex;

    /** Object holding information for one rendering frame */
    public class RenderSession
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
        
        internal var a:Number;
        internal var b:Number;
        internal var c:Number;
        internal var d:Number;
        internal var tx:Number;
        internal var ty:Number;
        
        internal var v0x:Number;
        internal var v0y:Number;
        internal var v1x:Number;
        internal var v1y:Number;
        internal var v2x:Number;
        internal var v2y:Number;
        
        internal var a2:Number;
        internal var b2:Number;
        internal var c2:Number;
        internal var d2:Number;
		internal var m:Matrix = new Matrix();
		
		internal var map:Matrix;
		//internal var v0:ScreenVertex;
		//internal var v1:ScreenVertex;
		//internal var v2:ScreenVertex;
		
        public function renderTriangleBitmap(bitmap:BitmapData, map:Matrix, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex, smooth:Boolean, repeat:Boolean):void
        {
        	gfx = _graphics || graphics;
        	
        	//map = tri.texturemapping || tri.transformUV(tri.material as IUVMaterial);
        	
        	a2 = (v1x = v1.x) - (v0x = v0.x);
        	b2 = (v1y = v1.y) - (v0y = v0.y);
        	c2 = (v2x = v2.x) - v0x;
        	d2 = (v2y = v2.y) - v0y;
        	
			m.a = (a = map.a)*a2 + (b = map.b)*c2;
			m.b = a*b2 + b*d2;
			m.c = (c = map.c)*a2 + (d = map.d)*c2;
			m.d = c*b2 + d*d2;
			m.tx = (tx = map.tx)*a2 + (ty = map.ty)*c2 + v0x;
			m.ty = tx*b2 + ty*d2 + v0y;
			
            gfx.lineStyle();
            gfx.beginBitmapFill(bitmap, m, repeat, smooth && (v0x*(d2 - b2) - v1x*d2 - v2x*b2 > 400));
            gfx.moveTo(v0x, v0y);
            gfx.lineTo(v1x, v1y);
            gfx.lineTo(v2x, v2y);
            gfx.endFill();

        }

        public function renderTriangleColor(color:int, alpha:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
            gfx = _graphics || graphics;
        	
            gfx.lineStyle();
            gfx.beginFill(color, alpha);
            gfx.moveTo(v0.x, v0.y);
            gfx.lineTo(v1.x, v1.y);
            gfx.lineTo(v2.x, v2.y);
            gfx.endFill();
        }

        public function renderTriangleLine(color:int, alpha:Number, width:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
            gfx = _graphics || graphics;
        	
            gfx.lineStyle(color, alpha, width);
            gfx.moveTo(v0x = v0.x, v0y = v0.y);
            gfx.lineTo(v1.x, v1.y);
            gfx.lineTo(v2.x, v2.y);
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

