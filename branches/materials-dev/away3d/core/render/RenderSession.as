package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.scene.*;
    
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;

    /** Object holding information for one rendering frame */
    public class RenderSession
    {
        public var scene:Scene3D;
        public var camera:Camera3D;
        public var container:Sprite;
        public var time:int;
        
		public var gfx:Graphics
        public var graphics:Graphics;
        public var lightarray:LightArray;
        public var clip:Clipping;
        
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
		
        public function renderTriangleBitmap(bitmap:BitmapData, map:Matrix, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex, smooth:Boolean, repeat:Boolean):void
        {
        	gfx = graphics;
        	
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
            gfx = graphics;
        	
            gfx.lineStyle();
            gfx.beginFill(color, alpha);
            gfx.moveTo(v0.x, v0.y);
            gfx.lineTo(v1.x, v1.y);
            gfx.lineTo(v2.x, v2.y);
            gfx.endFill();
        }

        public function renderTriangleLine(color:int, alpha:Number, width:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
            gfx = graphics;
        	
            gfx.lineStyle(color, alpha, width);
            gfx.moveTo(v0x = v0.x, v0y = v0.y);
            gfx.lineTo(v1.x, v1.y);
            gfx.lineTo(v2.x, v2.y);
            gfx.lineTo(v0x, v0y);
        }

        public function RenderSession(scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping, lightarray:LightArray)
        {
            this.scene = scene;
            this.camera = camera;
            this.container = container;
            this.graphics = container.graphics;
            this.lightarray = lightarray;
            this.clip = clip;
            this.time = getTimer();
        }
    }
}

