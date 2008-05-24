package away3d.core.render
{
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.core.clip.Clipping;
	import away3d.core.draw.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
    /**
    * Drawing session object that renders all drawing primitives into a <code>Sprite</code> container.
    */
	public class SpriteRenderSession extends AbstractRenderSession
	{
		use namespace arcane;
		
        private var _container:Sprite;
        private var _clip:Clipping;
        
		/**
		 * @inheritDoc
		 */
        public override function get view():View3D
        {
        	return _view;
        }
        public override function set view(val:View3D):void
        {	
        	super.view = val;
        	
        	_container = getContainer(_view) as Sprite;
        	graphics = _container.graphics;
        	
        	//clip the edges of the root container with  scrollRect
        	if (this == view.session) {
	        	_clip = _view.clip;
	        	_container.scrollRect = new Rectangle(_clip.minX-1, _clip.minY-1, _clip.maxX - _clip.minX + 2, _clip.maxY - _clip.minY + 2);
	        	_container.x = _clip.minX - 1;
	        	_container.y = _clip.minY - 1;
	        }
        }
		
		/**
		 * Creates a new <code>SpriteRenderSession</code> object.
		 */
		public function SpriteRenderSession():void
		{
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
        public override function addDisplayObject(child:DisplayObject):void
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
        public override function addLayerObject(child:Sprite):void
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
        protected override function createLayer():void
        {
            //create new canvas for remaining triangles
            if (doStore.length) {
            	_shape = doStore.pop();
            } else {
            	_shape = new Shape();
            }
            
            //update graphics reference
            graphics = _shape.graphics;
            
            //store new canvas
            doActive.push(_shape);
            
            //add new canvas to base canvas
            _container.addChild(_shape);
       		
			_layerDirty = false;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function clear():void
        {
        	super.clear();
        	
        	//clear base canvas
            _container.graphics.clear();
            
            //remove all children
            i = _container.numChildren;
			while (i--)
				_container.removeChild(_container.getChildAt(i));
			
            children = new Dictionary(true);
            newLayer = null;
            
 			graphics = _container.graphics;	
        }	          
        
		/**
		 * @inheritDoc
		 */
        public override function flush():void
        {
        	super.flush();
       		// NOP
        }       
        
		/**
		 * @inheritDoc
		 */
        public override function clone():AbstractRenderSession
        {
        	return new SpriteRenderSession();
        }
	}
}