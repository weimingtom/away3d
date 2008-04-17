package away3d.core.render
{
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.light.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
   
	public class AbstractRenderSession
	{
		protected var _view:View3D;
		protected var _containers:Dictionary = new Dictionary(true);
        protected var _lightarray:LightArray;
        protected var _renderSource:Object3D;
        protected var _layerDirty:Boolean;
        
        public var time:int;
        internal var session:AbstractRenderSession;
       	public var sessions:Dictionary = new Dictionary(true);  
       	
       			
		/** Array for storing old displayobjects to the canvas */
		internal var doStore:Array = new Array();
		
		/** Array for storing added displayobjects to the canvas */
		internal var doActive:Array = new Array();
		
		public var children:Dictionary = new Dictionary(true);
		
        public function registerChildSession(session:AbstractRenderSession):void
        {
        	if (!sessions[session])
        		sessions[session] = session;	
        }
        protected var graphics:Graphics;

        protected var a:Number;
        protected var b:Number;
        protected var c:Number;
        protected var d:Number;
        protected var tx:Number;
        protected var ty:Number;
        
        protected var v0x:Number;
        protected var v0y:Number;
        protected var v1x:Number;
        protected var v1y:Number;
        protected var v2x:Number;
        protected var v2y:Number;
        
        protected var a2:Number;
        protected var b2:Number;
        protected var c2:Number;
        protected var d2:Number;
		protected var m:Matrix = new Matrix();
		
		public function get container():DisplayObject
		{
			throw new Error("Not implemented");
		}                
                
        public function set view(val:View3D):void
        {	
        	_view = val;
        	time = getTimer();
        }
        
        public function get view():View3D
        {
        	return _view;
        }
        
        public function set lightarray(val:LightArray):void
        {
        	_lightarray = val;
        }
        
        public function get lightarray():LightArray
        {
        	return _lightarray;
        }
        
        public function clear():void
        {
        	for each(session in sessions)
       			session.clear();
        }
        
        public function addDisplayObject(child:DisplayObject):void
        {
        	throw new Error("Not implemented");
        }        
        
        public function renderBitmap(bitmap:BitmapData, v0:ScreenVertex, smooth:Boolean = false):void
        {
        	throw new Error("Not implemented");
        }
        
        /**
         * Renders bitmap with precalculated matrix to screen. Only works with non rotated / skewed matrizes
         */
        public function renderScaledBitmap(primitive:DrawScaledBitmap, bitmap:BitmapData, mapping:Matrix, smooth:Boolean = false):void
        {
        	throw new Error("Not implemented");
        }
        
        public function renderLine(v0:ScreenVertex, v1:ScreenVertex, width:Number, color:uint, alpha:Number):void
        {
        	throw new Error("Not implemented");
        }
        
        public function renderTriangleBitmap(bitmap:BitmapData, map:Matrix, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex, smooth:Boolean, repeat:Boolean, layerGraphics:Graphics = null):void
        {
        	throw new Error("Not implemented");
        }
        
        public function renderTriangleColor(color:int, alpha:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
        	throw new Error("Not implemented");
        }
        
        public function renderTriangleLine(width:Number, color:int, alpha:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
        	throw new Error("Not implemented");
        }

        public function renderTriangleLineFill(width:Number, color:int, alpha:Number, wirecolor:int, wirealpha:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
        	throw new Error("Not implemented");
        }

        public function renderFogColor(color:int, alpha:Number):void
        {
        	throw new Error("Not implemented");
        }
                
        /**
        * Function to inform render session 
        * object should be rendered immediately 
        */ 
        public function flush():void
        {
       		for each(session in sessions)
       			session.flush();
        }
        
        public function clone():AbstractRenderSession
        {
        	throw new Error("Not implemented");
        }
        
        /**
         *  Returns graphics layer for debug & custom drawing,
         *  performance is not guaranteed as rendering session
         *  may not support this natively
         */
        public function get customGraphics():Graphics
        {
        	throw new Error("Not implemented");
        }
	}
}