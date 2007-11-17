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
        public var view:View3D;
        public var container:Sprite;
        public var time:int;
        
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
			
            graphics.lineStyle();
            graphics.beginBitmapFill(bitmap, m, repeat, smooth && (v0x*(d2 - b2) - v1x*d2 + v2x*b2 > 400));
            graphics.moveTo(v0x, v0y);
            graphics.lineTo(v1x, v1y);
            graphics.lineTo(v2x, v2y);
            graphics.endFill();

        }

        public function renderTriangleColor(color:int, alpha:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {       	
            graphics.lineStyle();
            graphics.beginFill(color, alpha);
            graphics.moveTo(v0.x, v0.y);
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
            graphics.endFill();
        }

        public function renderTriangleLine(color:int, alpha:Number, width:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
            graphics.lineStyle(color, alpha, width);
            graphics.moveTo(v0x = v0.x, v0y = v0.y);
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
            graphics.lineTo(v0x, v0y);
        }

        public function renderTriangleLineFill(color:int, alpha:Number, wirecolor:int, wirealpha:Number, width:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
            if (wirealpha > 0)
                graphics.lineStyle(width, wirecolor, wirealpha);
            else
                graphics.lineStyle();
    
            if (alpha > 0)
                graphics.beginFill(color, alpha);
    
            graphics.moveTo(v0.x, v0.y);
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
    
            if (wirealpha > 0)
                graphics.lineTo(v0.x, v0.y);
    
            if (alpha > 0)
                graphics.endFill();
        }
        
        public function RenderSession(view:View3D, container:Sprite, lightarray:LightArray)
        {
            this.view = view;
            this.clip = view.clip;
            this.container = container;
            this.graphics = container.graphics;
            this.lightarray = lightarray;
            this.time = getTimer();
        }
    }
}

