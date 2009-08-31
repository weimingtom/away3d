package away3dlite.containers
{
	
	import away3dlite.arcane;
	import away3dlite.core.base.*;
	
	import flash.geom.*;
	import flash.display.*;
	
	use namespace arcane;
    
    /**
    * 3d object container node for other 3d objects in a scene.
    */
	public class ObjectContainer3D extends Object3D
	{
		arcane override function updateScene(val:Scene3D):void
		{
			if (scene == val)
				return;
			
			_scene = val;
			
			var child:Object3D;
			
			for each (child in _children)
				child.updateScene(_scene);
		}
		
		private var _index:int;
		private var _children:Array = new Array();
        
        /**
        * Returns the children of the container as an array of 3d objects.
        */
		public function get children():Array
		{
			return _children;
		}
		
	    /**
	    * Creates a new <code>ObjectContainer3D</code> object
	    */
		public function ObjectContainer3D()
		{
			super();
			
			transform.matrix3D = new Matrix3D();
		}
        
		/**
		 * Adds a 3d object to the scene as a child of the container.
		 * 
		 * @param	child	The 3d object to be added.
		 */
		public override function addChild(child:DisplayObject):DisplayObject
		{
			child = super.addChild(child);
			
			_children[_children.length] = child;
			
			(child as Object3D).updateScene(_scene);
			
			if (_scene)
				_scene._dirtyFaces = true;
			
			return child;
		}
        
		/**
		 * Removes a 3d object from the child array of the container.
		 * 
		 * @param	child	The 3d object to be removed.
		 */
		public override function removeChild(child:DisplayObject):DisplayObject
		{
			child = super.removeChild(child);
			
			_index = _children.indexOf(child);
			
			if (_index == -1)
				return null;
			
			_children.splice(_index, 1);
			
			(child as Object3D)._scene = null;
			
			_scene._dirtyFaces = true;
			
			return child;
		}
    	
		/**
		 * 
		 */
		public override function project(parentMatrix3D:Matrix3D):void
		{
			super.project(parentMatrix3D);
			
			var i:int = numChildren;
			
			while (i--)
				(getChildAt(i) as Object3D).project(_viewTransform);
		}
		
		/**
		 * Duplicates the 3d object's properties to another <code>ObjectContainer3D</code> object
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
        public override function clone(object:Object3D = null):Object3D
        {
            var container:ObjectContainer3D = (object as ObjectContainer3D) || new ObjectContainer3D();
            super.clone(container);
			
			var child:Object3D;
            for each (child in children)
            	container.addChild(child.clone());
            
            return container;
        }
	}
}