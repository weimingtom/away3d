package away3d.core.draw;

	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.block.*;
	import away3d.core.clip.*;
	import away3d.core.filter.*;
	import away3d.core.render.*;
	
	import flash.utils.Dictionary;
    
    //TODO: properly implement a volume block renderer.
    /**
    * Volume block tree for storing drawing primitives
    */
    class PrimitiveVolumeBlock implements IPrimitiveConsumer {
        public function new() {
        _blocks = new Dictionary(true);
        _root = new PrimitiveVolumeBlockNode(null);
        }
        
        var _blocks:Dictionary ;
        var _block:PrimitiveVolumeBlockNode;
        var _root:PrimitiveVolumeBlockNode ;
        var _clip:Clipping;
        var _result:Array<Dynamic>;
		var _primitive:DrawPrimitive;
        var _scene:Scene3D;
        var _camera:Camera3D;
		var _filter:IPrimitiveFilter;
        
		/**
		 * @inheritDoc
		 */
        public function primitive(pri:DrawPrimitive):Void
        {
            if (_clip.check(pri))
            {
                if (pri.source == null) {
                    _root.push(pri);
                } else {
                    _block = _blocks[pri.source];
                    
                    if (_block == null)
                        _block = _blocks[pri.source] = new PrimitiveVolumeBlockNode(pri.source);
                    
                    _block.push(pri);
                }
            }
        }
        
        /**
        * removes a drawing primitive from the volume block.
        * 
        * @param	pri	The drawing primitive to remove.
        */
        public function remove(pri:DrawPrimitive):Void
        {
            if (pri.source == null) {
                _root.remove(pri);
            } else {
                _block = list[pri.source];
                if (_block == null)
                    throw new Error("Can't remove");
                _block.remove(pri);
            }
        }
		
		/**
		 * A list of volume blocks contained in the scene.
		 * 
		 * @return	An array containing all volume blocks in the scene.
		 */
        public function blocks():Array<Dynamic>
        {   
            _result = _root.list.length > 0 ? [_root] : [];
            for each (_block in _blocks)
                _result.push(_block);
            return _result;
        }
		
		/**
		 * A list of primitives that have been clipped.
		 * 
		 * @return	An array containing the primitives to be rendered.
		 */
        public function list():Array<Dynamic>
        {   
            _result = [];
            for each (var rpri:DrawPrimitive in _root)
                if (rpri.screenZ != Infinity)
                    _result.push(rpri);
            _root = null;
            
            for (_block in _blocks)
            {
                var list:Array<Dynamic> = _block.list;
                for each (var pri:DrawPrimitive in list)
                    if (pri.screenZ != Infinity)
                        _result.push(pri);
                _block.list = null;
            }
            return _result;
        }

        public function getTouching(target:PrimitiveVolumeBlockNode):Array<Dynamic>
        {   
            _result = [];
            for (block in blocks)
            {
                if (block.minZ > target.maxZ)
                    continue;
                if (block.maxZ < target.minZ)
                    continue;
                if (block.minX > target.maxX)
                    continue;
                if (block.maxX < target.minX)
                    continue;
                if (block.minY > target.maxY)
                    continue;
                if (block.maxY < target.minY)
                    continue;

                _result.push(block);
            }
            return _result;
        }
                
        public function clear(view:View3D):Void
        {
			_scene = view.scene;
			_camera = view.camera;
			_clip = view.clip;
        	_result = [];
        }
        
        public function clone():IPrimitiveConsumer
        {
        	return new PrimitiveVolumeBlock();
        }
        
        public function render(view:View3D):Void
        {
    		// render all primitives
        }
		
		public function filter(filters:Array<Dynamic>):Void
		{
			for each (_filter in filters)
        		_result = _filter.filter(_result, _scene, _camera, _clip);
		}
    }
