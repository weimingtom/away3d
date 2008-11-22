package away3d.core.render;

	import away3d.containers.*;
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.light.*;
	import away3d.core.traverse.*;
	import away3d.events.Object3DEvent;
	import away3d.events.SessionEvent;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
    
	use namespace arcane;
	
	/**
	 * Dispatched when the render contents of the session require updating.
	 * 
	 * @eventType away3d.events.SessionEvent
	 */
	/*[Event(name="sessionUpdated",type="away3d.events.SessionEvent")]*/
	
    /**
    * Abstract Drawing session object containing the method used for drawing the view to screen.
    * Not intended for direct use - use <code>SpriteRenderSession</code> or <code>BitmapRenderSession</code>.
    */
	class AbstractRenderSession extends EventDispatcher {
		public var renderer(getRenderer, setRenderer) : IPrimitiveConsumer;
		/** @private */
		public function new() {
		_containers = new Dictionary(true);
		_doStore = new Array();
		_doActive = new Array();
		_doStores = new Dictionary(true);
		_doActives = new Dictionary(true);
		_renderers = new Dictionary(true);
		m = new Matrix();
		alpha = 1;
		spriteLayers = new Array();
		children = new Dictionary(true);
		priconsumers = new Dictionary(true);
		}
		
		/** @private */
		arcane var _containers:Dictionary ;
		/** @private */
		arcane var _shape:Shape;
		/** @private */
        arcane var _renderSource:Object3D;
		/** @private */
        arcane var _layerDirty:Bool;
		/** Array for storing old displayobjects to the canvas */
		arcane var _doStore:Array<Dynamic> ;
		/** Array for storing added displayobjects to the canvas */
		arcane var _doActive:Array<Dynamic> ;
		/** @private */
		arcane function notifySessionUpdate():Void
		{
			if (!hasEventListener(SessionEvent.SESSION_UPDATED))
                return;
			
            if (!_sessionupdated)
                _sessionupdated = new SessionEvent(SessionEvent.SESSION_UPDATED, this);
            
            dispatchEvent(_sessionupdated);
		}
		/** @private */
        arcane function internalAddSceneSession(session:AbstractRenderSession):Void
        {
        	sessions = [session];
        	session.addOnSessionUpdate(onSessionUpdate);
        }
		/** @private */
        arcane function internalRemoveSceneSession(session:AbstractRenderSession):Void
        {
        	sessions = [];
        	session.removeOnSessionUpdate(onSessionUpdate);
        }
		/** @private */
        arcane function internalAddOwnSession(object:Object3D):Void
        {
        	object.addEventListener(Object3DEvent.SESSION_UPDATED, onObjectSessionUpdate);
        }
		/** @private */
        arcane function internalRemoveOwnSession(object:Object3D):Void
        {
        	object.removeEventListener(Object3DEvent.SESSION_UPDATED, onObjectSessionUpdate);
        }
        var _consumer:IPrimitiveConsumer;
        var _doStores:Dictionary ;
        var _doActives:Dictionary ;
		var _renderers:Dictionary ;
		var _renderer:IPrimitiveConsumer;
        var _session:AbstractRenderSession;
        var _sessionupdated:SessionEvent;
        var a:Float;
        var b:Float;
        var c:Float;
        var d:Float;
        var tx:Float;
        var ty:Float;
        var v0x:Float;
        var v0y:Float;
        var v1x:Float;
        var v1y:Float;
        var v2x:Float;
        var v2y:Float;       
        var a2:Float;
        var b2:Float;
        var c2:Float;
        var d2:Float;
		var m:Matrix ;
        var cont:Shape;
        var ds:DisplayObject;
        var time:Int;
        var materials:Dictionary;
        var primitive:DrawPrimitive;
        var triangle:DrawTriangle;
        
        function onObjectSessionUpdate(object:Object3DEvent):Void
        {
        	notifySessionUpdate();
        }
		
		function getDOStore(view:View3D):Array<Dynamic>
		{
			if (!_doStores[view])
        		return _doStores[view] = new Array();
        	
			return _doStores[view];
		}
		
		function getDOActive(view:View3D):Array<Dynamic>
		{
			if (!_doActives[view])
        		return _doActives[view] = new Array();
        	
			return _doActives[view];
		}
		
        function onSessionUpdate(event:SessionEvent):Void
        {
        	dispatchEvent(event);
        }
        
		/** @private */
        var i:Int;
        
        public var parent:AbstractRenderSession;
        
        public var updated:Bool;
        
        public var primitives:Array<Dynamic>;
        
        /**
        * Placeholder for filters property of containers
        */
        public var filters:Array<Dynamic>;
        
        /**
        * Placeholder for alpha property of containers
        */
        public var alpha:Int ;
        
        /**
        * Placeholder for blendMode property of containers
        */
        public var blendMode:String;
        
        /**
        * Array of child sessions.
        */
       	public var sessions:Array<Dynamic>;
       	
       	/**
       	 * Dictionary of sprite layers for rendering composite materials.
       	 * 
       	 * @see away3d.materials.CompositeMaterial#renderTriangle()
       	 */
       	public var spriteLayers:Array<Dynamic> ;
       	
       	/**
       	 * Holds the last added layer sprite.
       	 */
       	public var newLayer:Sprite;
       			
		/**
		 * Dictionary of child displayobjects.
		 */
		public var children:Dictionary ;
        
        /**
        * Reference to the current graphics object being used for drawing.
        */
        public var graphics:Graphics;
        
        public var priconsumers:Dictionary ;
        
        public var consumer:IPrimitiveConsumer;
		
		public function getRenderer():IPrimitiveConsumer{
			return _renderer;
		}
		
		public function setRenderer(val:IPrimitiveConsumer):IPrimitiveConsumer{
			if (_renderer == val)
				return;
			
			_renderer = val;
			
			clearRenderers();
			
			for each (_session in sessions)
				_session.clearRenderers();
			return val;
		}
        
		/**
		 * Adds a session as a child of the session object.
		 * 
		 * @param	session		The session object to be added as a child.
		 */
        public function addChildSession(session:AbstractRenderSession):Void
        {
        	if (sessions.indexOf(session) != -1)
        		return;
        	
        	sessions.push(session);
        	session.addOnSessionUpdate(onSessionUpdate);
        	session.parent = this;
        }
        
		/**
		 * Removes a child session of the session object.
		 * 
		 * @param	session		The session object to be removed.
		 */
        public function removeChildSession(session:AbstractRenderSession):Void
        {
        	session.removeOnSessionUpdate(onSessionUpdate);
        	
        	var index:Int = sessions.indexOf(session);
            if (index == -1)
                return;
            
            sessions.splice(index, 1);	
        }
        
        public function clearChildSessions():Void
        {
        	for each (_session in sessions)
        		_session.removeOnSessionUpdate(onSessionUpdate);
        		
        	sessions = new Array();
        }
        
       	/**
       	 * Creates a new render layer for rendering composite materials.
       	 * 
       	 * @see away3d.materials.CompositeMaterial#renderTriangle()
       	 */
        function createLayer():Void
        {
			throw new Error("Not implemented");
        }
        
		/**
		 * Returns a display object representing the container for the specified view.
		 * 
		 * @param	view	The view object being rendered.
		 * @return			The display object container.
		 */
		public function getContainer(view:View3D):DisplayObject
		{
			throw new Error("Not implemented");
		}
			
		public function getConsumer(view:View3D):IPrimitiveConsumer
		{
			if (_renderers[view])
				return _renderers[view];
			
			if (_renderer)
				return _renderers[view] = _renderer.clone();
			
			if (parent)
				return _renderers[view] = parent.getConsumer(view).clone();
			
			return _renderers[view] = (cast( view.session.renderer, IPrimitiveConsumer)).clone();
		}
		
        public function getTotalFaces(view:View3D):Int
        {
        	var output:Int = getConsumer(view).list().length;
			
			for each (_session in sessions)
				output += _session.getTotalFaces(view);
				
			return output;
        }
        
		/**
		 * Clears the render session.
		 */
        public function clear(view:View3D):Void
        {
        	updated = view.updated || view.forceUpdate || view.scene.updatedSessions[this];
			
        	for each(_session in sessions)
       			_session.clear(view);
        	
			if (updated) {
	        	for (sprite in spriteLayers) {
	        		sprite.graphics.clear();
	        		if (sprite.numChildren) {
	        			var i:Int = sprite.numChildren;
	        			while (i--) {
	        				ds = sprite.getChildAt(i);
	        				if (Std.is( ds, Shape))
	        					(cast( ds, Shape)).graphics.clear();
	        			}
	        		}
	        	}
	        	
	        	_consumer = getConsumer(view);
	        	
	        	_doStore = getDOStore(view);
	        	_doActive = getDOActive(view);
	        	//clear child canvases
	            i = _doActive.length;
	            while (i--) {
	            	cont = _doActive.pop();
	            	cont.graphics.clear();
	            	_doStore.push(cont);
	            }
	            
	            //clear primitives consumer
	            _consumer.clear(view);
			}
        }
        
        public function render(view:View3D):Void
        {
	        //index -= priconsumer.length;
        	for each(_session in sessions)
       			_session.render(view);
       		
        	if (updated)
	            (cast( getConsumer(view), IRenderer)).render(view);
        }
        
        public function clearRenderers():Void
        {
        	_renderers = new Dictionary(true);
        }
        
        /**
        * Adds a display object to the render session display list.
        * 
        * @param	child	The display object to add.
        */
        public function addDisplayObject(child:DisplayObject):Void
        {
        	throw new Error("Not implemented");
        }        
        
        /**
        * Adds a layer sprite to the render session display list.
        * Doesn't update graphics so that elements in comosite materials
        * can render in separate layers.
        * 
        * @param	child	The display object to add.
        */
        public function addLayerObject(child:Sprite):Void
        {
            throw new Error("Not implemented");
        }
        
        /**
        * Draws a non-scaled bitmap into the graphics object.
        */
        public function renderBitmap(bitmap:BitmapData, v0:ScreenVertex, ?smooth:Bool = false):Void
        {
        	if (_layerDirty)
        		createLayer();
        	
        	m.identity();
        	m.tx = v0.x-bitmap.width/2; m.ty = v0.y-bitmap.height/2;
            graphics.lineStyle();
            graphics.beginBitmapFill(bitmap, m, false,smooth);
            graphics.drawRect(v0.x-bitmap.width/2, v0.y-bitmap.height/2, bitmap.width, bitmap.height);
            graphics.endFill();
        }
        
        /**
         * Draws a bitmap with a precalculated matrix into the graphics object.
         */
        public function renderScaledBitmap(primitive:DrawScaledBitmap, bitmap:BitmapData, mapping:Matrix, ?smooth:Bool = false):Void
        {
        	if (_layerDirty)
        		createLayer();
        	
            if (primitive.rotation != 0) {           
	            graphics.beginBitmapFill(bitmap, mapping, false, smooth);
	            graphics.moveTo(primitive.topleft.x, primitive.topleft.y);
	            graphics.lineTo(primitive.topright.x, primitive.topright.y);
	            graphics.lineTo(primitive.bottomright.x, primitive.bottomright.y);
	            graphics.lineTo(primitive.bottomleft.x, primitive.bottomleft.y);
	            graphics.lineTo(primitive.topleft.x, primitive.topleft.y);
	            graphics.endFill();
            } else {
	            graphics.beginBitmapFill(bitmap, mapping, false, smooth);	            
	            graphics.drawRect(primitive.minX, primitive.minY, primitive.maxX-primitive.minX, primitive.maxY-primitive.minY);
            	graphics.endFill();
            }
        }
        
        /**
         * Draws a segment element into the graphics object.
         */
        public function renderLine(v0:ScreenVertex, v1:ScreenVertex, width:Float, color:UInt, alpha:Float):Void
        {
        	if (_layerDirty)
        		createLayer();
        	
            graphics.lineStyle(width, color, alpha);
            graphics.moveTo(v0.x, v0.y);
            graphics.lineTo(v1.x, v1.y);
        }
        
        /**
         * Draws a triangle element with a bitmap texture into the graphics object.
         */
        public function renderTriangleBitmap(bitmap:BitmapData, map:Matrix, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex, smooth:Bool, repeat:Bool, ?layerGraphics:Graphics = null):Void
        {
        	if (_layerDirty)
        		createLayer();
        	
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
			
			if (layerGraphics) {
				layerGraphics.lineStyle();
	            layerGraphics.moveTo(v0x, v0y);
	            layerGraphics.beginBitmapFill(bitmap, m, repeat, smooth && (v0x*(d2 - b2) - v1x*d2 + v2x*b2 > 400));
	            layerGraphics.lineTo(v1x, v1y);
	            layerGraphics.lineTo(v2x, v2y);
	            layerGraphics.endFill();
	  		} else {
	  			graphics.lineStyle();
	            graphics.moveTo(v0x, v0y);       
	            graphics.beginBitmapFill(bitmap, m, repeat, smooth && (v0x*(d2 - b2) - v1x*d2 + v2x*b2 > 400));
	            graphics.lineTo(v1x, v1y);
	            graphics.lineTo(v2x, v2y);
	            graphics.endFill();
	  		}
        }
        
        /**
         * Draws a triangle element with a fill color into the graphics object.
         */
        public function renderTriangleColor(color:Int, alpha:Float, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):Void
        {
        	if (_layerDirty)
        		createLayer();
        	     	
            graphics.lineStyle();
            graphics.moveTo(v0.x, v0.y); // Always move before begin will to prevent bugs
            graphics.beginFill(color, alpha);
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
            graphics.endFill();
        }
        
        /**
         * Draws a wire triangle element into the graphics object.
         */
        public function renderTriangleLine(width:Float, color:Int, alpha:Float, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):Void
        {
        	if (_layerDirty)
        		createLayer();
        	
            graphics.lineStyle(width, color, alpha);
            graphics.moveTo(v0x = v0.x, v0y = v0.y);
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
            graphics.lineTo(v0x, v0y);
        }
        
        /**
         * Draws a wire triangle element with a fill color into the graphics object.
         */
        public function renderTriangleLineFill(width:Float, color:Int, alpha:Float, wirecolor:Int, wirealpha:Float, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):Void
        {
        	if (_layerDirty)
        		createLayer();
        	
            if (wirealpha > 0)
                graphics.lineStyle(width, wirecolor, wirealpha);
            else
                graphics.lineStyle();
    
            graphics.moveTo(v0.x, v0.y);

            if (alpha > 0)
                graphics.beginFill(color, alpha);
    
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
    
            if (wirealpha > 0)
                graphics.lineTo(v0.x, v0.y);
    
            if (alpha > 0)
                graphics.endFill();
        }
        
        /**
         * Draws a fog element into the graphics object.
         */
        public function renderFogColor(clip:Clipping, color:Int, alpha:Float):Void
        {
        	if (_layerDirty)
        		createLayer();
        	
        	graphics.lineStyle();
            graphics.beginFill(color, alpha);
            graphics.drawRect(clip.minX, clip.minY, clip.maxX - clip.minX, clip.maxY - clip.minY);
            graphics.endFill();
        }
		
		/**
		 * Duplicates the render session's properties to another render session.
		 * 
		 * @return						The new render session instance with duplicated properties applied
		 */
        public function clone():AbstractRenderSession
        {
        	throw new Error("Not implemented");
        }
		
		/**
		 * Default method for adding a sessionUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnSessionUpdate(listener:Dynamic):Void
        {
            addEventListener(SessionEvent.SESSION_UPDATED, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a sessionUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnSessionUpdate(listener:Dynamic):Void
        {
            removeEventListener(SessionEvent.SESSION_UPDATED, listener, false);
        }
	}
