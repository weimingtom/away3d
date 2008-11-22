package away3d.core.render;

	import away3d.containers.*;
	import away3d.arcane;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.events.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	use namespace arcane;
	
    /**
    * Drawing session object that renders all drawing primitives into a <code>Sprite</code> container.
    */
	class SpriteRenderSession extends AbstractRenderSession {
        
        var _container:Sprite;
        var _clip:Clipping;
        
        override function onSessionUpdate(event:SessionEvent):Void
        {
        	super.onSessionUpdate(event);
        	
        	cacheAsBitmap = false;
        }
        
        public var cacheAsBitmap:Bool;
        
		/**
		 * Creates a new <code>SpriteRenderSession</code> object.
		 */
		public function new(){
		}
        
		/**
		 * @inheritDoc
		 */
		public override function getContainer(view:View3D):DisplayObject
		{
			if (!_containers[view])
        		return _containers[view] = new Sprite();
        	
			return _containers[view];
		}
        
		/**
		 * @inheritDoc
		 */
        public override function addDisplayObject(child:DisplayObject):Void
        {
            //add to container
            _container.addChild(child);
            child.visible = true;
            
            //add child to children
            children[child] = child;
            
            _layerDirty = true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function addLayerObject(child:Sprite):Void
        {
            //add to container
            _container.addChild(child);
            child.visible = true;
            
            //add child to children
            children[child] = child;
            
            newLayer = child;
        }
        
		/**
		 * @inheritDoc
		 */
        override function createLayer():Void
        {
            //create new canvas for remaining triangles
            if (_doStore.length) {
            	_shape = _doStore.pop();
            } else {
            	_shape = new Shape();
            }
            
            //update graphics reference
            graphics = _shape.graphics;
            
            //store new canvas
            _doActive.push(_shape);
            
            //add new canvas to base canvas
            _container.addChild(_shape);
       		
			_layerDirty = false;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function clear(view:View3D):Void
        {
       		super.clear(view);
       		
    		_container = cast( getContainer(view), Sprite);
        	if (updated) {
	 			graphics = _container.graphics;
	 			
	        	//clip the edges of the root container with  scrollRect
	        	if (this == view.session) {
		        	_clip = view.clip;
		        	_container.scrollRect = new Rectangle(_clip.minX-1, _clip.minY-1, _clip.maxX - _clip.minX + 2, _clip.maxY - _clip.minY + 2);
		        	_container.x = _clip.minX - 1;
		        	_container.y = _clip.minY - 1;
		        }
        		_container.cacheAsBitmap = false;
        		
	        	//clear base canvas
	            graphics.clear();
	            
	            //remove all children
	            i = _container.numChildren;
				while (i--)
					_container.removeChild(_container.getChildAt(i));
				
	            children = new Dictionary(true);
	            newLayer = null;
	            
        	} else {
        		_container.cacheAsBitmap = cacheAsBitmap;
        	}
        	
        	if ((filters && filters.length) || (_container.filters && _container.filters.length))
        		_container.filters = filters;
        	
        	_container.alpha = alpha;
        	_container.blendMode = blendMode || BlendMode.NORMAL;
        }   
        
		/**
		 * @inheritDoc
		 */
        public override function clone():AbstractRenderSession
        {
        	return new SpriteRenderSession();
        }
	}
