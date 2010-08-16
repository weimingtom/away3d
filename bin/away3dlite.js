$estr = function() { return js.Boot.__string_rec(this,''); }
if(typeof jsflash=='undefined') jsflash = {}
if(!jsflash.events) jsflash.events = {}
jsflash.events.IEventDispatcher = function() { }
jsflash.events.IEventDispatcher.__name__ = ["jsflash","events","IEventDispatcher"];
jsflash.events.IEventDispatcher.prototype.RemoveByID = null;
jsflash.events.IEventDispatcher.prototype.addEventListener = null;
jsflash.events.IEventDispatcher.prototype.dispatchEvent = null;
jsflash.events.IEventDispatcher.prototype.hasEventListener = null;
jsflash.events.IEventDispatcher.prototype.removeEventListener = null;
jsflash.events.IEventDispatcher.prototype.willTrigger = null;
jsflash.events.IEventDispatcher.prototype.__class__ = jsflash.events.IEventDispatcher;
jsflash.events.EventDispatcher = function(target) { if( target === $_ ) return; {
	$s.push("jsflash.events.EventDispatcher::new");
	var $spos = $s.length;
	if(Std["is"](this,jsflash.display.DisplayObject)) this.isInDisplayList = true;
	if(this.mTarget != null) this.mTarget = target;
	else this.mTarget = this;
	this.mEventMap = new Hash();
	$s.pop();
}}
jsflash.events.EventDispatcher.__name__ = ["jsflash","events","EventDispatcher"];
jsflash.events.EventDispatcher.prototype.CapturePhaseDispatch = function(event) {
	$s.push("jsflash.events.EventDispatcher::CapturePhaseDispatch");
	var $spos = $s.length;
	if(!this.isInDisplayList) {
		event.SetPhase(jsflash.events.EventPhase.AT_TARGET);
		{
			$s.pop();
			return;
		}
	}
	var displayObj = this;
	displayObj.root.CapturePhaseDispatch(event);
	$s.pop();
}
jsflash.events.EventDispatcher.prototype.DispatchCompleteEvent = function() {
	$s.push("jsflash.events.EventDispatcher::DispatchCompleteEvent");
	var $spos = $s.length;
	var evt = new jsflash.events.Event(jsflash.events.Event.COMPLETE);
	this.dispatchEvent(evt);
	$s.pop();
}
jsflash.events.EventDispatcher.prototype.DispatchEventInternal = function(event) {
	$s.push("jsflash.events.EventDispatcher::DispatchEventInternal");
	var $spos = $s.length;
	event.currentTarget = this;
	var list = this.mEventMap.get(event.type);
	var capture = event.eventPhase == jsflash.events.EventPhase.CAPTURING_PHASE;
	if(list != null) {
		var idx = 0;
		while(idx < list.length) {
			var listener = list[idx];
			if(listener.mUseCapture == capture) {
				listener.dispatchEvent(event);
				if(event.IsCancelledNow()) {
					$s.pop();
					return true;
				}
			}
			if(idx < list.length && listener != list[idx]) null;
			else idx++;
		}
		{
			$s.pop();
			return true;
		}
	}
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
jsflash.events.EventDispatcher.prototype.DispatchIOErrorEvent = function() {
	$s.push("jsflash.events.EventDispatcher::DispatchIOErrorEvent");
	var $spos = $s.length;
	var evt = new jsflash.events.IOErrorEvent(jsflash.events.IOErrorEvent.IO_ERROR);
	this.dispatchEvent(evt);
	$s.pop();
}
jsflash.events.EventDispatcher.prototype.DumpListeners = function() {
	$s.push("jsflash.events.EventDispatcher::DumpListeners");
	var $spos = $s.length;
	haxe.Log.trace(this.mEventMap,{ fileName : "EventDispatcher.hx", lineNumber : 227, className : "jsflash.events.EventDispatcher", methodName : "DumpListeners"});
	$s.pop();
}
jsflash.events.EventDispatcher.prototype.RemoveByID = function(inType,inID) {
	$s.push("jsflash.events.EventDispatcher::RemoveByID");
	var $spos = $s.length;
	if(!this.mEventMap.exists(inType)) {
		$s.pop();
		return;
	}
	var list = this.mEventMap.get(inType);
	{
		var _g1 = 0, _g = list.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(list[i].mID == inID) {
				list.splice(i,1);
				{
					$s.pop();
					return;
				}
			}
		}
	}
	$s.pop();
}
jsflash.events.EventDispatcher.prototype.addEventListener = function(type,inListener,useCapture,inPriority,useWeakReference) {
	$s.push("jsflash.events.EventDispatcher::addEventListener");
	var $spos = $s.length;
	var capture = (useCapture == null?false:useCapture);
	var priority = (inPriority == null?0:inPriority);
	var list = this.mEventMap.get(type);
	if(list == null) {
		list = new Array();
		this.mEventMap.set(type,list);
	}
	var l = new jsflash.events.Listener(inListener,capture,priority);
	list.push(l);
	{
		var $tmp = l.mID;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.events.EventDispatcher.prototype.dispatchEvent = function(event) {
	$s.push("jsflash.events.EventDispatcher::dispatchEvent");
	var $spos = $s.length;
	var retval = false;
	if(event.target == null) {
		event.target = this.mTarget;
		if(this.isInDisplayList && event.capturing) {
			event.SetPhase(jsflash.events.EventPhase.CAPTURING_PHASE);
			var dsp = this;
			var stack = [];
			var len = 0;
			while(dsp != null) {
				stack.push(dsp);
				dsp = dsp.parent;
				len++;
			}
			while(len-- > 0) {
				stack.pop().DispatchEventInternal(event);
				if(event.IsCancelled()) {
					$s.pop();
					return true;
				}
			}
		}
		event.SetPhase(jsflash.events.EventPhase.AT_TARGET);
		retval = this.DispatchEventInternal(event);
		if(event.bubbles) event.SetPhase(jsflash.events.EventPhase.BUBBLING_PHASE);
		if(event.eventPhase == jsflash.events.EventPhase.BUBBLING_PHASE) {
			var dsp = this;
			while(dsp != null) {
				dsp.DispatchEventInternal(event);
				dsp = dsp.parent;
			}
		}
		{
			$s.pop();
			return retval;
		}
	}
	else {
		{
			var $tmp = this.DispatchEventInternal(event);
			$s.pop();
			return $tmp;
		}
	}
	$s.pop();
}
jsflash.events.EventDispatcher.prototype.hasEventListener = function(type) {
	$s.push("jsflash.events.EventDispatcher::hasEventListener");
	var $spos = $s.length;
	{
		var $tmp = this.mEventMap.exists(type);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.events.EventDispatcher.prototype.isInDisplayList = null;
jsflash.events.EventDispatcher.prototype.mEventMap = null;
jsflash.events.EventDispatcher.prototype.mTarget = null;
jsflash.events.EventDispatcher.prototype.removeEventListener = function(type,listener,inCapture) {
	$s.push("jsflash.events.EventDispatcher::removeEventListener");
	var $spos = $s.length;
	if(!this.mEventMap.exists(type)) {
		$s.pop();
		return;
	}
	var list = this.mEventMap.get(type);
	var capture = (inCapture == null?false:inCapture);
	{
		var _g1 = 0, _g = list.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(list[i].Is(listener,capture)) {
				list.splice(i,1);
				{
					$s.pop();
					return;
				}
			}
		}
	}
	$s.pop();
}
jsflash.events.EventDispatcher.prototype.toString = function() {
	$s.push("jsflash.events.EventDispatcher::toString");
	var $spos = $s.length;
	{
		$s.pop();
		return "[EventDispatcher]";
	}
	$s.pop();
}
jsflash.events.EventDispatcher.prototype.willTrigger = function(type) {
	$s.push("jsflash.events.EventDispatcher::willTrigger");
	var $spos = $s.length;
	{
		var $tmp = this.hasEventListener(type);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.events.EventDispatcher.prototype.__class__ = jsflash.events.EventDispatcher;
jsflash.events.EventDispatcher.__interfaces__ = [jsflash.events.IEventDispatcher];
if(!jsflash.display) jsflash.display = {}
jsflash.display.IBitmapDrawable = function() { }
jsflash.display.IBitmapDrawable.__name__ = ["jsflash","display","IBitmapDrawable"];
jsflash.display.IBitmapDrawable.prototype.__class__ = jsflash.display.IBitmapDrawable;
jsflash.display.DisplayObject = function(p) { if( p === $_ ) return; {
	$s.push("jsflash.display.DisplayObject::new");
	var $spos = $s.length;
	jsflash.events.EventDispatcher.apply(this,[]);
	this.transform = new jsflash.geom.Transform(this);
	this.name = "instance" + jsflash.display.DisplayObject.count++;
	$s.pop();
}}
jsflash.display.DisplayObject.__name__ = ["jsflash","display","DisplayObject"];
jsflash.display.DisplayObject.__super__ = jsflash.events.EventDispatcher;
for(var k in jsflash.events.EventDispatcher.prototype ) jsflash.display.DisplayObject.prototype[k] = jsflash.events.EventDispatcher.prototype[k];
jsflash.display.DisplayObject.count = null;
jsflash.display.DisplayObject.prototype.Internal = function() {
	$s.push("jsflash.display.DisplayObject::Internal");
	var $spos = $s.length;
	{
		$s.pop();
		return this;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.get_height = function() {
	$s.push("jsflash.display.DisplayObject::get_height");
	var $spos = $s.length;
	{
		var $tmp = this.height;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.get_rotationX = function() {
	$s.push("jsflash.display.DisplayObject::get_rotationX");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.get_rotation().x;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.get_rotationY = function() {
	$s.push("jsflash.display.DisplayObject::get_rotationY");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.get_rotation().y;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.get_rotationZ = function() {
	$s.push("jsflash.display.DisplayObject::get_rotationZ");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.get_rotation().z;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.get_scaleX = function() {
	$s.push("jsflash.display.DisplayObject::get_scaleX");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.get_scale().x;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.get_scaleY = function() {
	$s.push("jsflash.display.DisplayObject::get_scaleY");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.get_scale().y;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.get_scaleZ = function() {
	$s.push("jsflash.display.DisplayObject::get_scaleZ");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.get_scale().z;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.get_width = function() {
	$s.push("jsflash.display.DisplayObject::get_width");
	var $spos = $s.length;
	{
		var $tmp = this.width;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.get_x = function() {
	$s.push("jsflash.display.DisplayObject::get_x");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.rawData[12];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.get_y = function() {
	$s.push("jsflash.display.DisplayObject::get_y");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.rawData[13];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.get_z = function() {
	$s.push("jsflash.display.DisplayObject::get_z");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.rawData[14];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.height = null;
jsflash.display.DisplayObject.prototype.matrix = null;
jsflash.display.DisplayObject.prototype.name = null;
jsflash.display.DisplayObject.prototype.parent = null;
jsflash.display.DisplayObject.prototype.root = null;
jsflash.display.DisplayObject.prototype.rotationX = null;
jsflash.display.DisplayObject.prototype.rotationY = null;
jsflash.display.DisplayObject.prototype.rotationZ = null;
jsflash.display.DisplayObject.prototype.scaleX = null;
jsflash.display.DisplayObject.prototype.scaleY = null;
jsflash.display.DisplayObject.prototype.scaleZ = null;
jsflash.display.DisplayObject.prototype.set_height = function(val) {
	$s.push("jsflash.display.DisplayObject::set_height");
	var $spos = $s.length;
	{
		var $tmp = this.height = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_root = function(val) {
	$s.push("jsflash.display.DisplayObject::set_root");
	var $spos = $s.length;
	{
		var $tmp = this.root = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_rotationX = function(val) {
	$s.push("jsflash.display.DisplayObject::set_rotationX");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.get_rotation().set_x(val);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_rotationY = function(val) {
	$s.push("jsflash.display.DisplayObject::set_rotationY");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.get_rotation().set_y(val);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_rotationZ = function(val) {
	$s.push("jsflash.display.DisplayObject::set_rotationZ");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.get_rotation().set_z(val);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_scaleX = function(val) {
	$s.push("jsflash.display.DisplayObject::set_scaleX");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.get_scale().set_x(val);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_scaleY = function(val) {
	$s.push("jsflash.display.DisplayObject::set_scaleY");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.get_scale().set_y(val);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_scaleZ = function(val) {
	$s.push("jsflash.display.DisplayObject::set_scaleZ");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.get_scale().set_z(val);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_stage = function(val) {
	$s.push("jsflash.display.DisplayObject::set_stage");
	var $spos = $s.length;
	this.stage = val;
	if(this.stage != null && val == null && this.hasEventListener(jsflash.events.Event.REMOVED_FROM_STAGE)) this.dispatchEvent(new jsflash.events.Event(jsflash.events.Event.REMOVED_FROM_STAGE,false));
	else if(this.stage == null && val != null && this.hasEventListener(jsflash.events.Event.ADDED_TO_STAGE)) this.dispatchEvent(new jsflash.events.Event(jsflash.events.Event.ADDED_TO_STAGE,false));
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_visible = function(val) {
	$s.push("jsflash.display.DisplayObject::set_visible");
	var $spos = $s.length;
	{
		var $tmp = this.visible = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_width = function(val) {
	$s.push("jsflash.display.DisplayObject::set_width");
	var $spos = $s.length;
	{
		var $tmp = this.width = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_x = function(val) {
	$s.push("jsflash.display.DisplayObject::set_x");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.rawData[12] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_y = function(val) {
	$s.push("jsflash.display.DisplayObject::set_y");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.rawData[13] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.set_z = function(val) {
	$s.push("jsflash.display.DisplayObject::set_z");
	var $spos = $s.length;
	{
		var $tmp = this.matrix.rawData[14] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObject.prototype.stage = null;
jsflash.display.DisplayObject.prototype.transform = null;
jsflash.display.DisplayObject.prototype.visible = null;
jsflash.display.DisplayObject.prototype.width = null;
jsflash.display.DisplayObject.prototype.x = null;
jsflash.display.DisplayObject.prototype.y = null;
jsflash.display.DisplayObject.prototype.z = null;
jsflash.display.DisplayObject.prototype.__class__ = jsflash.display.DisplayObject;
jsflash.display.DisplayObject.__interfaces__ = [jsflash.display.IBitmapDrawable];
jsflash.display.DisplayObjectContainer = function(p) { if( p === $_ ) return; {
	$s.push("jsflash.display.DisplayObjectContainer::new");
	var $spos = $s.length;
	jsflash.display.DisplayObject.apply(this,[]);
	this.__children = [];
	$s.pop();
}}
jsflash.display.DisplayObjectContainer.__name__ = ["jsflash","display","DisplayObjectContainer"];
jsflash.display.DisplayObjectContainer.__super__ = jsflash.display.DisplayObject;
for(var k in jsflash.display.DisplayObject.prototype ) jsflash.display.DisplayObjectContainer.prototype[k] = jsflash.display.DisplayObject.prototype[k];
jsflash.display.DisplayObjectContainer.prototype.__children = null;
jsflash.display.DisplayObjectContainer.prototype.addChild = function(child) {
	$s.push("jsflash.display.DisplayObjectContainer::addChild");
	var $spos = $s.length;
	{
		var $tmp = this.addChildAt(child,this.__children.length);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.addChildAt = function(child,index) {
	$s.push("jsflash.display.DisplayObjectContainer::addChildAt");
	var $spos = $s.length;
	if(index > this.__children.length) throw jsflash.Error.RangeError;
	else if(index == this.__children.length) this.__children.push(child);
	else this.__children.insert(index,child);
	if(child.parent != null) child.parent.removeChild(child);
	child.parent = this;
	child.set_root(this.root);
	child.set_stage(this.stage);
	{
		$s.pop();
		return child;
	}
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.contains = function(child) {
	$s.push("jsflash.display.DisplayObjectContainer::contains");
	var $spos = $s.length;
	{
		var $tmp = Lambda.has(this.__children,child);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.getChildAt = function(index) {
	$s.push("jsflash.display.DisplayObjectContainer::getChildAt");
	var $spos = $s.length;
	{
		var $tmp = this.__children[index];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.getChildByName = function(name) {
	$s.push("jsflash.display.DisplayObjectContainer::getChildByName");
	var $spos = $s.length;
	{
		var $tmp = Lambda.fold(this.__children,function(child,rslt) {
			$s.push("jsflash.display.DisplayObjectContainer::getChildByName@84");
			var $spos = $s.length;
			{
				var $tmp = (((child.name == name)?child:rslt));
				$s.pop();
				return $tmp;
			}
			$s.pop();
		},null);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.getChildIndex = function(child) {
	$s.push("jsflash.display.DisplayObjectContainer::getChildIndex");
	var $spos = $s.length;
	var idx = 0;
	{
		var _g = 0, _g1 = this.__children;
		while(_g < _g1.length) {
			var _child = _g1[_g];
			++_g;
			if(_child == child) {
				$s.pop();
				return idx;
			}
			idx++;
		}
	}
	{
		$s.pop();
		return -1;
	}
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.removeChild = function(child) {
	$s.push("jsflash.display.DisplayObjectContainer::removeChild");
	var $spos = $s.length;
	if(!this.__children.remove(child)) throw jsflash.Error.ArgumentError;
	child.parent = null;
	child.set_root(null);
	child.set_stage(null);
	{
		$s.pop();
		return child;
	}
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.removeChildAt = function(index) {
	$s.push("jsflash.display.DisplayObjectContainer::removeChildAt");
	var $spos = $s.length;
	if(index >= this.__children.length) throw jsflash.Error.RangeError;
	var child = this.__children.splice(index,1)[0];
	child.parent = null;
	child.set_root(null);
	child.set_stage(null);
	{
		$s.pop();
		return child;
	}
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.setChildIndex = function(child,index) {
	$s.push("jsflash.display.DisplayObjectContainer::setChildIndex");
	var $spos = $s.length;
	if(index >= this.__children.length) throw jsflash.Error.RangeError;
	var idx = this.getChildIndex(child);
	if(idx == -1) throw jsflash.Error.ArgumentError;
	this.__children.splice(idx,1);
	this.__children.insert(index,child);
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.set_root = function(val) {
	$s.push("jsflash.display.DisplayObjectContainer::set_root");
	var $spos = $s.length;
	{
		var _g = 0, _g1 = this.__children;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			child.set_root(val);
		}
	}
	{
		var $tmp = jsflash.display.DisplayObject.prototype.set_root.apply(this,[val]);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.set_stage = function(val) {
	$s.push("jsflash.display.DisplayObjectContainer::set_stage");
	var $spos = $s.length;
	{
		var _g = 0, _g1 = this.__children;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			child.set_stage(val);
		}
	}
	{
		var $tmp = jsflash.display.DisplayObject.prototype.set_stage.apply(this,[val]);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.swapChildren = function(child1,child2) {
	$s.push("jsflash.display.DisplayObjectContainer::swapChildren");
	var $spos = $s.length;
	var idx1 = this.getChildIndex(child1);
	var idx2 = this.getChildIndex(child2);
	if(idx1 == -1 || idx2 == -1) throw jsflash.Error.ArgumentError;
	this.__children[idx2] = child1;
	this.__children[idx1] = child2;
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.swapChildrenAt = function(index1,index2) {
	$s.push("jsflash.display.DisplayObjectContainer::swapChildrenAt");
	var $spos = $s.length;
	if(index1 >= this.__children.length || index2 >= this.__children.length) throw jsflash.Error.RangeError;
	var child1 = this.__children[index1];
	var child2 = this.__children[index2];
	this.__children[index2] = child1;
	this.__children[index1] = child2;
	$s.pop();
}
jsflash.display.DisplayObjectContainer.prototype.__class__ = jsflash.display.DisplayObjectContainer;
jsflash.display.Sprite = function(p) { if( p === $_ ) return; {
	$s.push("jsflash.display.Sprite::new");
	var $spos = $s.length;
	jsflash.display.DisplayObjectContainer.apply(this,[]);
	$s.pop();
}}
jsflash.display.Sprite.__name__ = ["jsflash","display","Sprite"];
jsflash.display.Sprite.__super__ = jsflash.display.DisplayObjectContainer;
for(var k in jsflash.display.DisplayObjectContainer.prototype ) jsflash.display.Sprite.prototype[k] = jsflash.display.DisplayObjectContainer.prototype[k];
jsflash.display.Sprite.prototype.buttonMode = null;
jsflash.display.Sprite.prototype.useHandCursor = null;
jsflash.display.Sprite.prototype.__class__ = jsflash.display.Sprite;
if(typeof away3dlite=='undefined') away3dlite = {}
if(!away3dlite.core) away3dlite.core = {}
if(!away3dlite.core.base) away3dlite.core.base = {}
away3dlite.core.base.Object3D = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.core.base.Object3D::new");
	var $spos = $s.length;
	jsflash.display.Sprite.apply(this,[]);
	this._viewMatrix3D = new jsflash.geom.Matrix3D();
	this._sceneMatrix3D = new jsflash.geom.Matrix3D();
	this._screenZ = 0;
	this.materialLibrary = new away3dlite.loaders.utils.MaterialLibrary();
	this.geometryLibrary = new away3dlite.loaders.utils.GeometryLibrary();
	this.animationLibrary = new away3dlite.loaders.utils.AnimationLibrary();
	this.transform.set_matrix3D(new jsflash.geom.Matrix3D());
	$s.pop();
}}
away3dlite.core.base.Object3D.__name__ = ["away3dlite","core","base","Object3D"];
away3dlite.core.base.Object3D.__super__ = jsflash.display.Sprite;
for(var k in jsflash.display.Sprite.prototype ) away3dlite.core.base.Object3D.prototype[k] = jsflash.display.Sprite.prototype[k];
away3dlite.core.base.Object3D.prototype._height = null;
away3dlite.core.base.Object3D.prototype._mouseEnabled = null;
away3dlite.core.base.Object3D.prototype._scene = null;
away3dlite.core.base.Object3D.prototype._sceneMatrix3D = null;
away3dlite.core.base.Object3D.prototype._screenZ = null;
away3dlite.core.base.Object3D.prototype._viewMatrix3D = null;
away3dlite.core.base.Object3D.prototype._width = null;
away3dlite.core.base.Object3D.prototype.animationLibrary = null;
away3dlite.core.base.Object3D.prototype.clone = function(object) {
	$s.push("away3dlite.core.base.Object3D::clone");
	var $spos = $s.length;
	var object3D = ((object != null)?object:new away3dlite.core.base.Object3D());
	object3D.transform.set_matrix3D(this.transform.matrix3D.clone());
	object3D.name = this.name;
	object3D.set_visible(this.visible);
	{
		$s.pop();
		return object3D;
	}
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.copyMatrix3D = function(m1,m2) {
	$s.push("away3dlite.core.base.Object3D::copyMatrix3D");
	var $spos = $s.length;
	var rawData = m1.rawData.concat([]);
	m2.set_rawData(rawData);
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.geometryLibrary = null;
away3dlite.core.base.Object3D.prototype.get__height = function() {
	$s.push("away3dlite.core.base.Object3D::get__height");
	var $spos = $s.length;
	{
		var $tmp = this.get_height();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.get__width = function() {
	$s.push("away3dlite.core.base.Object3D::get__width");
	var $spos = $s.length;
	{
		var $tmp = this.get_width();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.get_position = function() {
	$s.push("away3dlite.core.base.Object3D::get_position");
	var $spos = $s.length;
	{
		var $tmp = this.transform.matrix3D.get_position();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.get_scene = function() {
	$s.push("away3dlite.core.base.Object3D::get_scene");
	var $spos = $s.length;
	{
		var $tmp = this._scene;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.get_sceneMatrix3D = function() {
	$s.push("away3dlite.core.base.Object3D::get_sceneMatrix3D");
	var $spos = $s.length;
	{
		var $tmp = this._sceneMatrix3D;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.get_screenZ = function() {
	$s.push("away3dlite.core.base.Object3D::get_screenZ");
	var $spos = $s.length;
	{
		var $tmp = this._screenZ;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.get_viewMatrix3D = function() {
	$s.push("away3dlite.core.base.Object3D::get_viewMatrix3D");
	var $spos = $s.length;
	{
		var $tmp = this._viewMatrix3D;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.get_width = function() {
	$s.push("away3dlite.core.base.Object3D::get_width");
	var $spos = $s.length;
	{
		var $tmp = this.get__width();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.layer = null;
away3dlite.core.base.Object3D.prototype.lookAt = function(target,upAxis) {
	$s.push("away3dlite.core.base.Object3D::lookAt");
	var $spos = $s.length;
	var tmp = ((upAxis != null)?upAxis:new jsflash.geom.Vector3D(0,-1,0));
	this.transform.matrix3D.pointAt(target,new jsflash.geom.Vector3D(0,0,1),tmp);
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.materialLibrary = null;
away3dlite.core.base.Object3D.prototype.position = null;
away3dlite.core.base.Object3D.prototype.project = function(camera,parentSceneMatrix3D) {
	$s.push("away3dlite.core.base.Object3D::project");
	var $spos = $s.length;
	this._sceneMatrix3D.set_rawData(this.transform.matrix3D.rawData);
	if(parentSceneMatrix3D != null) this._sceneMatrix3D.append(parentSceneMatrix3D);
	this._viewMatrix3D.set_rawData(this._sceneMatrix3D.rawData);
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.scene = null;
away3dlite.core.base.Object3D.prototype.sceneMatrix3D = null;
away3dlite.core.base.Object3D.prototype.screenZ = null;
away3dlite.core.base.Object3D.prototype.set__height = function(val) {
	$s.push("away3dlite.core.base.Object3D::set__height");
	var $spos = $s.length;
	{
		var $tmp = this.set_height(val);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.set__width = function(val) {
	$s.push("away3dlite.core.base.Object3D::set__width");
	var $spos = $s.length;
	{
		var $tmp = this.set_width(val);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.set_width = function(val) {
	$s.push("away3dlite.core.base.Object3D::set_width");
	var $spos = $s.length;
	{
		var $tmp = this.set__width(val);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.type = null;
away3dlite.core.base.Object3D.prototype.updateScene = function(val) {
	$s.push("away3dlite.core.base.Object3D::updateScene");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.core.base.Object3D.prototype.url = null;
away3dlite.core.base.Object3D.prototype.viewMatrix3D = null;
away3dlite.core.base.Object3D.prototype.__class__ = away3dlite.core.base.Object3D;
away3dlite.core.base.Mesh = function(material) { if( material === $_ ) return; {
	$s.push("away3dlite.core.base.Mesh::new");
	var $spos = $s.length;
	away3dlite.core.base.Object3D.apply(this,[]);
	this._materialsCacheList = new Array();
	this._faceLengths = new Array();
	this._faces = new Array();
	this._sort = new Array();
	this._vertices = new Array();
	this._faceMaterials = new Array();
	this.sortFaces = true;
	this._screenVertices = new Array();
	this._uvtData = new Array();
	this._indices = new Array();
	this.set_material(material);
	this.set_bothsides(false);
	this.set_sortType("center");
	$s.pop();
}}
away3dlite.core.base.Mesh.__name__ = ["away3dlite","core","base","Mesh"];
away3dlite.core.base.Mesh.__super__ = away3dlite.core.base.Object3D;
for(var k in away3dlite.core.base.Object3D.prototype ) away3dlite.core.base.Mesh.prototype[k] = away3dlite.core.base.Object3D.prototype[k];
away3dlite.core.base.Mesh.prototype._bothsides = null;
away3dlite.core.base.Mesh.prototype._culling = null;
away3dlite.core.base.Mesh.prototype._faceLengths = null;
away3dlite.core.base.Mesh.prototype._faceMaterials = null;
away3dlite.core.base.Mesh.prototype._faces = null;
away3dlite.core.base.Mesh.prototype._indices = null;
away3dlite.core.base.Mesh.prototype._indicesTotal = null;
away3dlite.core.base.Mesh.prototype._material = null;
away3dlite.core.base.Mesh.prototype._materialsCacheList = null;
away3dlite.core.base.Mesh.prototype._materialsDirty = null;
away3dlite.core.base.Mesh.prototype._screenVertices = null;
away3dlite.core.base.Mesh.prototype._sort = null;
away3dlite.core.base.Mesh.prototype._sortType = null;
away3dlite.core.base.Mesh.prototype._uvtData = null;
away3dlite.core.base.Mesh.prototype._vertexId = null;
away3dlite.core.base.Mesh.prototype._vertexNormals = null;
away3dlite.core.base.Mesh.prototype._vertices = null;
away3dlite.core.base.Mesh.prototype.addMaterial = function(mat) {
	$s.push("away3dlite.core.base.Mesh::addMaterial");
	var $spos = $s.length;
	var sid = this._scene._id;
	var i = mat._id[sid];
	this._materialsCacheList[i] = mat;
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.bothsides = null;
away3dlite.core.base.Mesh.prototype.buildFaces = function() {
	$s.push("away3dlite.core.base.Mesh::buildFaces");
	var $spos = $s.length;
	var gl = (this.stage != null?this.stage.RenderingContext:jsflash.Manager.stage.RenderingContext);
	this._indicesTotal = 0;
	var len = this._faceLengths.length;
	if(len == 0) len = Std["int"](this._indices.length / 3);
	var index = this._indices.length;
	var faceLength;
	var _stData = [];
	var _iData = [];
	var idx = 0;
	var vrt = 0;
	var i = -1;
	while(++i < len) {
		faceLength = this._faceLengths[i];
		if(faceLength == 3) {
			{
				_iData.push(this._indices[idx++]);
				_iData.push(this._indices[idx++]);
				_iData.push(this._indices[idx++]);
			}
			this._indicesTotal += 3;
			this.numItems++;
		}
		else if(faceLength == 4) {
			var i0 = this._indices[idx++];
			var i1 = this._indices[idx++];
			var i2 = this._indices[idx++];
			{
				_iData.push(i0);
				_iData.push(i1);
				_iData.push(i2);
			}
			{
				_iData.push(i0);
				_iData.push(i2);
				_iData.push(this._indices[idx++]);
			}
			this._indicesTotal += 6;
			this.numItems += 2;
		}
		else {
			{
				_iData.push(this._indices[idx++]);
				_iData.push(this._indices[idx++]);
				_iData.push(this._indices[idx++]);
			}
			this._indicesTotal += 3;
			this.numItems++;
		}
	}
	this.numItems = this._indicesTotal;
	var len1 = this._uvtData.length;
	i = -1;
	while(++i < len1) {
		_stData.push(this._uvtData[i]);
		_stData.push(this._uvtData[++i]);
		i++;
	}
	this.indicesBuffer = gl.createBuffer();
	gl.bindBuffer(webgl.wrappers.GLEnum.ELEMENT_ARRAY_BUFFER,this.indicesBuffer);
	gl.bufferData(webgl.wrappers.GLEnum.ELEMENT_ARRAY_BUFFER,new webgl.WebGLUnsignedShortArray(_iData),webgl.wrappers.GLEnum.STATIC_DRAW);
	this.stBuffer = gl.createBuffer();
	gl.bindBuffer(webgl.wrappers.GLEnum.ARRAY_BUFFER,this.stBuffer);
	gl.bufferData(webgl.wrappers.GLEnum.ARRAY_BUFFER,new webgl.WebGLFloatArray(_stData),webgl.wrappers.GLEnum.STATIC_DRAW);
	this.verticesBuffer = gl.createBuffer();
	gl.bindBuffer(webgl.wrappers.GLEnum.ARRAY_BUFFER,this.verticesBuffer);
	gl.bufferData(webgl.wrappers.GLEnum.ARRAY_BUFFER,new webgl.WebGLFloatArray(this._vertices),webgl.wrappers.GLEnum.STATIC_DRAW);
	this._materialsDirty = true;
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.buildMaterials = function(clear) {
	$s.push("away3dlite.core.base.Mesh::buildMaterials");
	var $spos = $s.length;
	if(clear == null) clear = false;
	this._materialsDirty = false;
	if(this._scene != null) {
		var oldMaterial = null;
		var newMaterial = null;
		var i = this._faces.length;
		while(i-- > 0) {
			oldMaterial = this._faces[i].material;
			if(!clear) newMaterial = ((this._faceMaterials[i] != null)?this._faceMaterials[i]:this._material);
			if(oldMaterial != newMaterial) {
				if(oldMaterial != null) {
					this._scene.removeSceneMaterial(oldMaterial);
					this.removeMaterial(oldMaterial);
				}
				if(newMaterial != null) {
					this._scene.addSceneMaterial(newMaterial);
					this.addMaterial(newMaterial);
				}
				this._faces[i].material = newMaterial;
			}
		}
	}
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.clone = function(object) {
	$s.push("away3dlite.core.base.Mesh::clone");
	var $spos = $s.length;
	var mesh = ((object != null)?jsflash.Lib["as"](object,away3dlite.core.base.Mesh):new away3dlite.core.base.Mesh());
	away3dlite.core.base.Object3D.prototype.clone.apply(this,[mesh]);
	mesh.type = this.type;
	mesh.set_material(this.get_material());
	mesh.set_sortType(this.get_sortType());
	mesh.set_bothsides(this.get_bothsides());
	mesh._vertices = this.get_vertices();
	mesh._uvtData = this._uvtData.concat([]);
	mesh._faceMaterials = this._faceMaterials;
	mesh._indices = this._indices.concat([]);
	mesh._faceLengths = this._faceLengths;
	mesh.buildFaces();
	mesh.buildMaterials();
	{
		$s.pop();
		return mesh;
	}
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.faces = null;
away3dlite.core.base.Mesh.prototype.get_bothsides = function() {
	$s.push("away3dlite.core.base.Mesh::get_bothsides");
	var $spos = $s.length;
	{
		var $tmp = this._bothsides;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.get_faces = function() {
	$s.push("away3dlite.core.base.Mesh::get_faces");
	var $spos = $s.length;
	{
		var $tmp = this._faces;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.get_material = function() {
	$s.push("away3dlite.core.base.Mesh::get_material");
	var $spos = $s.length;
	{
		var $tmp = this._material;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.get_sortType = function() {
	$s.push("away3dlite.core.base.Mesh::get_sortType");
	var $spos = $s.length;
	{
		var $tmp = this._sortType;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.get_vertices = function() {
	$s.push("away3dlite.core.base.Mesh::get_vertices");
	var $spos = $s.length;
	{
		var $tmp = this._vertices;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.indicesBuffer = null;
away3dlite.core.base.Mesh.prototype.material = null;
away3dlite.core.base.Mesh.prototype.numItems = null;
away3dlite.core.base.Mesh.prototype.project = function(camera,parentSceneMatrix3D) {
	$s.push("away3dlite.core.base.Mesh::project");
	var $spos = $s.length;
	away3dlite.core.base.Object3D.prototype.project.apply(this,[camera,parentSceneMatrix3D]);
	this.get_vertices();
	var stage = this.stage;
	if(stage == null) stage = jsflash.Manager.stage;
	this.get_material().renderMesh(this,camera,stage);
	if(this._materialsDirty) this.buildMaterials();
	var i = this._materialsCacheList.length;
	var mat;
	while(i-- != 0) {
		if((mat = this._materialsCacheList[i]) != null) {
			this._scene._materialsNextList[i] = mat;
		}
	}
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.removeMaterial = function(mat) {
	$s.push("away3dlite.core.base.Mesh::removeMaterial");
	var $spos = $s.length;
	var sid = this._scene._id;
	var i = mat._id[sid];
	this._materialsCacheList[mat._id[sid]] = null;
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.set_bothsides = function(val) {
	$s.push("away3dlite.core.base.Mesh::set_bothsides");
	var $spos = $s.length;
	this._bothsides = val;
	if(this._bothsides) {
		this._culling = jsflash.display.TriangleCulling.NONE;
	}
	else {
		this._culling = jsflash.display.TriangleCulling.POSITIVE;
	}
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.set_material = function(val) {
	$s.push("away3dlite.core.base.Mesh::set_material");
	var $spos = $s.length;
	val = ((val != null)?val:new away3dlite.materials.WireColorMaterial());
	if(this._material == val) {
		$s.pop();
		return val;
	}
	this._materialsDirty = true;
	{
		var $tmp = this._material = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.set_sortType = function(val) {
	$s.push("away3dlite.core.base.Mesh::set_sortType");
	var $spos = $s.length;
	if(this._sortType == val) {
		$s.pop();
		return val;
	}
	this._sortType = val;
	this.updateSortType();
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.sortFaces = null;
away3dlite.core.base.Mesh.prototype.sortType = null;
away3dlite.core.base.Mesh.prototype.stBuffer = null;
away3dlite.core.base.Mesh.prototype.updateScene = function(val) {
	$s.push("away3dlite.core.base.Mesh::updateScene");
	var $spos = $s.length;
	if(this.get_scene() == val) {
		$s.pop();
		return;
	}
	if(this._scene != null) this.buildMaterials(true);
	this._scene = val;
	if(this._scene != null) this.buildMaterials();
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.updateSortType = function() {
	$s.push("away3dlite.core.base.Mesh::updateSortType");
	var $spos = $s.length;
	var face;
	switch(this._sortType) {
	case "center":{
		{
			var _g = 0, _g1 = this._faces;
			while(_g < _g1.length) {
				var face1 = _g1[_g];
				++_g;
				face1.calculateScreenZ = $closure(face1,"calculateAverageZ");
			}
		}
	}break;
	case "front":{
		{
			var _g = 0, _g1 = this._faces;
			while(_g < _g1.length) {
				var face1 = _g1[_g];
				++_g;
				face1.calculateScreenZ = $closure(face1,"calculateNearestZ");
			}
		}
	}break;
	case "back":{
		{
			var _g = 0, _g1 = this._faces;
			while(_g < _g1.length) {
				var face1 = _g1[_g];
				++_g;
				face1.calculateScreenZ = $closure(face1,"calculateFurthestZ");
			}
		}
	}break;
	default:{
		null;
	}break;
	}
	$s.pop();
}
away3dlite.core.base.Mesh.prototype.vertices = null;
away3dlite.core.base.Mesh.prototype.verticesBuffer = null;
away3dlite.core.base.Mesh.prototype.__class__ = away3dlite.core.base.Mesh;
if(!away3dlite.primitives) away3dlite.primitives = {}
away3dlite.primitives.AbstractPrimitive = function(material) { if( material === $_ ) return; {
	$s.push("away3dlite.primitives.AbstractPrimitive::new");
	var $spos = $s.length;
	away3dlite.core.base.Mesh.apply(this,[material]);
	this._primitiveDirty = true;
	$s.pop();
}}
away3dlite.primitives.AbstractPrimitive.__name__ = ["away3dlite","primitives","AbstractPrimitive"];
away3dlite.primitives.AbstractPrimitive.__super__ = away3dlite.core.base.Mesh;
for(var k in away3dlite.core.base.Mesh.prototype ) away3dlite.primitives.AbstractPrimitive.prototype[k] = away3dlite.core.base.Mesh.prototype[k];
away3dlite.primitives.AbstractPrimitive.prototype._primitiveDirty = null;
away3dlite.primitives.AbstractPrimitive.prototype.buildPrimitive = function() {
	$s.push("away3dlite.primitives.AbstractPrimitive::buildPrimitive");
	var $spos = $s.length;
	this._primitiveDirty = false;
	this._vertices = [];
	this._uvtData = [];
	this._indices = [];
	this._faceLengths = [];
	$s.pop();
}
away3dlite.primitives.AbstractPrimitive.prototype.get_faces = function() {
	$s.push("away3dlite.primitives.AbstractPrimitive::get_faces");
	var $spos = $s.length;
	if(this._primitiveDirty) this.updatePrimitive();
	{
		var $tmp = away3dlite.core.base.Mesh.prototype.get_faces.apply(this,[]);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.primitives.AbstractPrimitive.prototype.get_vertices = function() {
	$s.push("away3dlite.primitives.AbstractPrimitive::get_vertices");
	var $spos = $s.length;
	if(this._primitiveDirty) this.updatePrimitive();
	{
		var $tmp = this._vertices;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.primitives.AbstractPrimitive.prototype.updatePrimitive = function() {
	$s.push("away3dlite.primitives.AbstractPrimitive::updatePrimitive");
	var $spos = $s.length;
	this.buildPrimitive();
	this.buildFaces();
	$s.pop();
}
away3dlite.primitives.AbstractPrimitive.prototype.__class__ = away3dlite.primitives.AbstractPrimitive;
if(!away3dlite.containers) away3dlite.containers = {}
away3dlite.containers.View3D = function(scene,camera,renderer,clipping) { if( scene === $_ ) return; {
	$s.push("away3dlite.containers.View3D::new");
	var $spos = $s.length;
	jsflash.display.Sprite.apply(this,[]);
	this._viewZero = new jsflash.geom.Point();
	this.mouseEnabled3D = true;
	this.set_scene(((scene != null)?scene:new away3dlite.containers.Scene3D()));
	this.set_camera(((camera != null)?camera:new away3dlite.cameras.Camera3D()));
	this.set_renderer(((renderer != null)?renderer:new away3dlite.core.render.BasicRenderer()));
	this.set_clipping(((clipping != null)?clipping:new away3dlite.core.clip.RectangleClipping()));
	$s.pop();
}}
away3dlite.containers.View3D.__name__ = ["away3dlite","containers","View3D"];
away3dlite.containers.View3D.__super__ = jsflash.display.Sprite;
for(var k in jsflash.display.Sprite.prototype ) away3dlite.containers.View3D.prototype[k] = jsflash.display.Sprite.prototype[k];
away3dlite.containers.View3D.prototype._camera = null;
away3dlite.containers.View3D.prototype._clipping = null;
away3dlite.containers.View3D.prototype._face = null;
away3dlite.containers.View3D.prototype._lastmove_mouseX = null;
away3dlite.containers.View3D.prototype._lastmove_mouseY = null;
away3dlite.containers.View3D.prototype._loaderDirty = null;
away3dlite.containers.View3D.prototype._loaderHeight = null;
away3dlite.containers.View3D.prototype._loaderWidth = null;
away3dlite.containers.View3D.prototype._material = null;
away3dlite.containers.View3D.prototype._mouseIsOverView = null;
away3dlite.containers.View3D.prototype._mouseMaterial = null;
away3dlite.containers.View3D.prototype._mouseObject = null;
away3dlite.containers.View3D.prototype._object = null;
away3dlite.containers.View3D.prototype._renderedFaces = null;
away3dlite.containers.View3D.prototype._renderedObjects = null;
away3dlite.containers.View3D.prototype._renderer = null;
away3dlite.containers.View3D.prototype._scene = null;
away3dlite.containers.View3D.prototype._scenePosition = null;
away3dlite.containers.View3D.prototype._screenClipping = null;
away3dlite.containers.View3D.prototype._screenClippingDirty = null;
away3dlite.containers.View3D.prototype._sourceURL = null;
away3dlite.containers.View3D.prototype._stageHeight = null;
away3dlite.containers.View3D.prototype._stageWidth = null;
away3dlite.containers.View3D.prototype._totalFaces = null;
away3dlite.containers.View3D.prototype._totalObjects = null;
away3dlite.containers.View3D.prototype._uvt = null;
away3dlite.containers.View3D.prototype._viewZero = null;
away3dlite.containers.View3D.prototype._x = null;
away3dlite.containers.View3D.prototype._y = null;
away3dlite.containers.View3D.prototype.camera = null;
away3dlite.containers.View3D.prototype.clear = function() {
	$s.push("away3dlite.containers.View3D::clear");
	var $spos = $s.length;
	var gl = jsflash.Manager.stage.RenderingContext;
	gl.clear(webgl.wrappers.GLEnum.COLOR_BUFFER_BIT | webgl.wrappers.GLEnum.DEPTH_BUFFER_BIT);
	$s.pop();
}
away3dlite.containers.View3D.prototype.clipping = null;
away3dlite.containers.View3D.prototype.get_camera = function() {
	$s.push("away3dlite.containers.View3D::get_camera");
	var $spos = $s.length;
	{
		var $tmp = this._camera;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.get_clipping = function() {
	$s.push("away3dlite.containers.View3D::get_clipping");
	var $spos = $s.length;
	{
		var $tmp = this._clipping;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.get_renderedFaces = function() {
	$s.push("away3dlite.containers.View3D::get_renderedFaces");
	var $spos = $s.length;
	{
		var $tmp = this._renderedFaces;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.get_renderedObjects = function() {
	$s.push("away3dlite.containers.View3D::get_renderedObjects");
	var $spos = $s.length;
	{
		var $tmp = this._renderedObjects;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.get_renderer = function() {
	$s.push("away3dlite.containers.View3D::get_renderer");
	var $spos = $s.length;
	{
		var $tmp = this._renderer;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.get_scene = function() {
	$s.push("away3dlite.containers.View3D::get_scene");
	var $spos = $s.length;
	{
		var $tmp = this._scene;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.get_screenClipping = function() {
	$s.push("away3dlite.containers.View3D::get_screenClipping");
	var $spos = $s.length;
	if(this._screenClippingDirty) {
		this.updateScreenClipping();
		this._screenClippingDirty = false;
		{
			var $tmp = this._screenClipping = this._clipping.screen(this,this._loaderWidth,this._loaderHeight);
			$s.pop();
			return $tmp;
		}
	}
	{
		var $tmp = this._screenClipping;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.get_totalFaces = function() {
	$s.push("away3dlite.containers.View3D::get_totalFaces");
	var $spos = $s.length;
	{
		var $tmp = this._totalFaces;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.get_totalObjects = function() {
	$s.push("away3dlite.containers.View3D::get_totalObjects");
	var $spos = $s.length;
	{
		var $tmp = this._totalObjects;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.mouseEnabled3D = null;
away3dlite.containers.View3D.prototype.mouseZeroMove = null;
away3dlite.containers.View3D.prototype.onAddedToStage = function(event) {
	$s.push("away3dlite.containers.View3D::onAddedToStage");
	var $spos = $s.length;
	this.stage.addEventListener(jsflash.events.Event.RESIZE,$closure(this,"onStageResized"));
	$s.pop();
}
away3dlite.containers.View3D.prototype.onClippingUpdated = function(e) {
	$s.push("away3dlite.containers.View3D::onClippingUpdated");
	var $spos = $s.length;
	this._screenClippingDirty = true;
	$s.pop();
}
away3dlite.containers.View3D.prototype.onScreenUpdated = function(e) {
	$s.push("away3dlite.containers.View3D::onScreenUpdated");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.containers.View3D.prototype.onStageResized = function(event) {
	$s.push("away3dlite.containers.View3D::onStageResized");
	var $spos = $s.length;
	this._screenClippingDirty = true;
	$s.pop();
}
away3dlite.containers.View3D.prototype.render = function() {
	$s.push("away3dlite.containers.View3D::render");
	var $spos = $s.length;
	this._totalFaces = 0;
	this._totalObjects = -1;
	this._renderedFaces = 0;
	this._renderedObjects = -1;
	this.clear();
	this._camera.update();
	this._scene.project(this.get_camera());
	$s.pop();
}
away3dlite.containers.View3D.prototype.renderedFaces = null;
away3dlite.containers.View3D.prototype.renderedObjects = null;
away3dlite.containers.View3D.prototype.renderer = null;
away3dlite.containers.View3D.prototype.scene = null;
away3dlite.containers.View3D.prototype.screenClipping = null;
away3dlite.containers.View3D.prototype.set_camera = function(val) {
	$s.push("away3dlite.containers.View3D::set_camera");
	var $spos = $s.length;
	if(this._camera == val) {
		$s.pop();
		return val;
	}
	if(this._camera != null) {
		this.removeChild(this._camera);
		this._camera._view = null;
	}
	this._camera = val;
	if(this._camera != null) {
		this.addChild(this._camera);
		this._camera._view = this;
	}
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.set_clipping = function(val) {
	$s.push("away3dlite.containers.View3D::set_clipping");
	var $spos = $s.length;
	if(this._clipping == val) {
		$s.pop();
		return val;
	}
	if(this._clipping != null) {
		this._clipping.removeEventListener("clippingUpdated",$closure(this,"onClippingUpdated"));
		this._clipping.removeEventListener("screenUpdated",$closure(this,"onScreenUpdated"));
	}
	this._clipping = val;
	this._clipping.setView(this);
	if(this._clipping != null) {
		this._clipping.addEventListener("clippingUpdated",$closure(this,"onClippingUpdated"));
		this._clipping.addEventListener("screenUpdated",$closure(this,"onScreenUpdated"));
	}
	else {
		throw jsflash.Error.Message("View cannot have clipping set to null");
	}
	this._screenClippingDirty = true;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.set_renderer = function(val) {
	$s.push("away3dlite.containers.View3D::set_renderer");
	var $spos = $s.length;
	if(this._renderer == val) {
		$s.pop();
		return val;
	}
	this._renderer = val;
	this._renderer.setView(this);
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.set_scene = function(val) {
	$s.push("away3dlite.containers.View3D::set_scene");
	var $spos = $s.length;
	if(this._scene == val) {
		$s.pop();
		return val;
	}
	if(this._scene != null) {
		this.removeChild(this._scene);
	}
	this._scene = val;
	if(this._scene != null) {
		this.addChild(this._scene);
	}
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.containers.View3D.prototype.totalFaces = null;
away3dlite.containers.View3D.prototype.totalObjects = null;
away3dlite.containers.View3D.prototype.updateScreenClipping = function() {
	$s.push("away3dlite.containers.View3D::updateScreenClipping");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.containers.View3D.prototype.__class__ = away3dlite.containers.View3D;
jsflash.Lib = function() { }
jsflash.Lib.__name__ = ["jsflash","Lib"];
jsflash.Lib.current = null;
jsflash.Lib["as"] = function(obj,clazz) {
	$s.push("jsflash.Lib::as");
	var $spos = $s.length;
	{
		var $tmp = (Std["is"](obj,clazz)?obj:null);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.Lib.vectorOfArray = function(arr) {
	$s.push("jsflash.Lib::vectorOfArray");
	var $spos = $s.length;
	{
		$s.pop();
		return arr;
	}
	$s.pop();
}
jsflash.Lib.prototype.__class__ = jsflash.Lib;
jsflash.events.Listener = function(inListener,inUseCapture,inPriority) { if( inListener === $_ ) return; {
	$s.push("jsflash.events.Listener::new");
	var $spos = $s.length;
	this.mListner = inListener;
	this.mUseCapture = inUseCapture;
	this.mPriority = inPriority;
	this.mID = jsflash.events.Listener.sIDs++;
	$s.pop();
}}
jsflash.events.Listener.__name__ = ["jsflash","events","Listener"];
jsflash.events.Listener.prototype.Is = function(inListener,inCapture) {
	$s.push("jsflash.events.Listener::Is");
	var $spos = $s.length;
	{
		var $tmp = Reflect.compareMethods(this.mListner,inListener) && this.mUseCapture == inCapture;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.events.Listener.prototype.dispatchEvent = function(event) {
	$s.push("jsflash.events.Listener::dispatchEvent");
	var $spos = $s.length;
	this.mListner(event);
	$s.pop();
}
jsflash.events.Listener.prototype.mID = null;
jsflash.events.Listener.prototype.mListner = null;
jsflash.events.Listener.prototype.mPriority = null;
jsflash.events.Listener.prototype.mUseCapture = null;
jsflash.events.Listener.prototype.__class__ = jsflash.events.Listener;
List = function(p) { if( p === $_ ) return; {
	$s.push("List::new");
	var $spos = $s.length;
	this.length = 0;
	$s.pop();
}}
List.__name__ = ["List"];
List.prototype.add = function(item) {
	$s.push("List::add");
	var $spos = $s.length;
	var x = [item];
	if(this.h == null) this.h = x;
	else this.q[1] = x;
	this.q = x;
	this.length++;
	$s.pop();
}
List.prototype.clear = function() {
	$s.push("List::clear");
	var $spos = $s.length;
	this.h = null;
	this.q = null;
	this.length = 0;
	$s.pop();
}
List.prototype.filter = function(f) {
	$s.push("List::filter");
	var $spos = $s.length;
	var l2 = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		if(f(v)) l2.add(v);
	}
	{
		$s.pop();
		return l2;
	}
	$s.pop();
}
List.prototype.first = function() {
	$s.push("List::first");
	var $spos = $s.length;
	{
		var $tmp = (this.h == null?null:this.h[0]);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
List.prototype.h = null;
List.prototype.isEmpty = function() {
	$s.push("List::isEmpty");
	var $spos = $s.length;
	{
		var $tmp = (this.h == null);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
List.prototype.iterator = function() {
	$s.push("List::iterator");
	var $spos = $s.length;
	{
		var $tmp = { h : this.h, hasNext : function() {
			$s.push("List::iterator@196");
			var $spos = $s.length;
			{
				var $tmp = (this.h != null);
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}, next : function() {
			$s.push("List::iterator@199");
			var $spos = $s.length;
			if(this.h == null) {
				$s.pop();
				return null;
			}
			var x = this.h[0];
			this.h = this.h[1];
			{
				$s.pop();
				return x;
			}
			$s.pop();
		}}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
List.prototype.join = function(sep) {
	$s.push("List::join");
	var $spos = $s.length;
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	while(l != null) {
		if(first) first = false;
		else s.b[s.b.length] = sep;
		s.b[s.b.length] = l[0];
		l = l[1];
	}
	{
		var $tmp = s.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
List.prototype.last = function() {
	$s.push("List::last");
	var $spos = $s.length;
	{
		var $tmp = (this.q == null?null:this.q[0]);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
List.prototype.length = null;
List.prototype.map = function(f) {
	$s.push("List::map");
	var $spos = $s.length;
	var b = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		b.add(f(v));
	}
	{
		$s.pop();
		return b;
	}
	$s.pop();
}
List.prototype.pop = function() {
	$s.push("List::pop");
	var $spos = $s.length;
	if(this.h == null) {
		$s.pop();
		return null;
	}
	var x = this.h[0];
	this.h = this.h[1];
	if(this.h == null) this.q = null;
	this.length--;
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
List.prototype.push = function(item) {
	$s.push("List::push");
	var $spos = $s.length;
	var x = [item,this.h];
	this.h = x;
	if(this.q == null) this.q = x;
	this.length++;
	$s.pop();
}
List.prototype.q = null;
List.prototype.remove = function(v) {
	$s.push("List::remove");
	var $spos = $s.length;
	var prev = null;
	var l = this.h;
	while(l != null) {
		if(l[0] == v) {
			if(prev == null) this.h = l[1];
			else prev[1] = l[1];
			if(this.q == l) this.q = prev;
			this.length--;
			{
				$s.pop();
				return true;
			}
		}
		prev = l;
		l = l[1];
	}
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
List.prototype.toString = function() {
	$s.push("List::toString");
	var $spos = $s.length;
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	s.b[s.b.length] = "{";
	while(l != null) {
		if(first) first = false;
		else s.b[s.b.length] = ", ";
		s.b[s.b.length] = Std.string(l[0]);
		l = l[1];
	}
	s.b[s.b.length] = "}";
	{
		var $tmp = s.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
List.prototype.__class__ = List;
if(!away3dlite.materials) away3dlite.materials = {}
away3dlite.materials.Material = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.materials.Material::new");
	var $spos = $s.length;
	jsflash.events.EventDispatcher.apply(this,[]);
	this._id = new Array();
	this._faceCount = new Array();
	this._debug = false;
	this.initializeWebGL();
	$s.pop();
}}
away3dlite.materials.Material.__name__ = ["away3dlite","materials","Material"];
away3dlite.materials.Material.__super__ = jsflash.events.EventDispatcher;
for(var k in jsflash.events.EventDispatcher.prototype ) away3dlite.materials.Material.prototype[k] = jsflash.events.EventDispatcher.prototype[k];
away3dlite.materials.Material._context = null;
away3dlite.materials.Material.prototype._debug = null;
away3dlite.materials.Material.prototype._faceCount = null;
away3dlite.materials.Material.prototype._id = null;
away3dlite.materials.Material.prototype._materialactivated = null;
away3dlite.materials.Material.prototype._materialdeactivated = null;
away3dlite.materials.Material.prototype.context = null;
away3dlite.materials.Material.prototype.debug = null;
away3dlite.materials.Material.prototype.fragmentShaderSource = function() {
	$s.push("away3dlite.materials.Material::fragmentShaderSource");
	var $spos = $s.length;
	{
		$s.pop();
		return "void main(void) {\n\t\t        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);\n\t\t}";
	}
	$s.pop();
}
away3dlite.materials.Material.prototype.get_debug = function() {
	$s.push("away3dlite.materials.Material::get_debug");
	var $spos = $s.length;
	{
		var $tmp = this._debug;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.Material.prototype.gl = null;
away3dlite.materials.Material.prototype.initializeWebGL = function() {
	$s.push("away3dlite.materials.Material::initializeWebGL");
	var $spos = $s.length;
	this.gl = jsflash.Manager.stage.RenderingContext;
	if(away3dlite.materials.Material._context == null) {
		var vShader = this.gl.createShader(webgl.wrappers.GLEnum.VERTEX_SHADER);
		this.gl.shaderSource(vShader,this.vertexShaderSource());
		this.gl.compileShader(vShader);
		if(!this.gl.getShaderParameter(vShader,webgl.wrappers.GLEnum.COMPILE_STATUS)) {
			var resp = this.gl.getShaderInfoLog(vShader);
			js.Lib.alert(resp);
			throw resp;
		}
		var fShader = this.gl.createShader(webgl.wrappers.GLEnum.FRAGMENT_SHADER);
		this.gl.shaderSource(fShader,this.fragmentShaderSource());
		this.gl.compileShader(fShader);
		if(!this.gl.getShaderParameter(fShader,webgl.wrappers.GLEnum.COMPILE_STATUS)) {
			var resp = this.gl.getShaderInfoLog(fShader);
			js.Lib.alert(resp);
			throw resp;
		}
		var program = this.gl.createProgram();
		this.gl.attachShader(program,vShader);
		this.gl.attachShader(program,fShader);
		this.gl.linkProgram(program);
		if(!this.gl.getProgramParameter(program,webgl.wrappers.GLEnum.LINK_STATUS)) {
			js.Lib.alert("Could not initialise shaders");
			throw "Could not initialise shaders";
		}
		var uniformLocations = new Hash();
		this.gl.useProgram(program);
		uniformLocations.set("uCamMatrix",this.gl.getUniformLocation(program,"uCamMatrix"));
		uniformLocations.set("uMVMatrix",this.gl.getUniformLocation(program,"uMVMatrix"));
		var attribLocations = new Hash();
		attribLocations.set("aVertexPosition",this.gl.getAttribLocation(program,"aVertexPosition"));
		this.gl.enableVertexAttribArray(attribLocations.get("aVertexPosition"));
		this.context = away3dlite.materials.Material._context = { vShader : vShader, fShader : fShader, program : program, uniformLocations : uniformLocations, attribLocations : attribLocations}
	}
	else {
		this.context = away3dlite.materials.Material._context;
	}
	$s.pop();
}
away3dlite.materials.Material.prototype.notifyActivate = function(scene) {
	$s.push("away3dlite.materials.Material::notifyActivate");
	var $spos = $s.length;
	if(!this.hasEventListener("materialActivated")) {
		$s.pop();
		return;
	}
	if(this._materialactivated == null) this._materialactivated = new away3dlite.events.MaterialEvent("materialActivated",this);
	this.dispatchEvent(this._materialactivated);
	$s.pop();
}
away3dlite.materials.Material.prototype.notifyDeactivate = function(scene) {
	$s.push("away3dlite.materials.Material::notifyDeactivate");
	var $spos = $s.length;
	if(!this.hasEventListener("materialDeactivated")) {
		$s.pop();
		return;
	}
	if(this._materialdeactivated == null) this._materialdeactivated = new away3dlite.events.MaterialEvent("materialDeactivated",this);
	this.dispatchEvent(this._materialdeactivated);
	$s.pop();
}
away3dlite.materials.Material.prototype.renderMesh = function(mesh,camera,stage) {
	$s.push("away3dlite.materials.Material::renderMesh");
	var $spos = $s.length;
	if(mesh.indicesBuffer == null || mesh.verticesBuffer == null) {
		$s.pop();
		return;
	}
	this.gl.useProgram(this.context.program);
	this.updateUniforms(camera,mesh,stage);
	this.gl.bindBuffer(webgl.wrappers.GLEnum.ARRAY_BUFFER,mesh.verticesBuffer);
	this.gl.vertexAttribPointer(this.context.attribLocations.get("aVertexPosition"),3,webgl.wrappers.GLEnum.FLOAT,false,0,0);
	this.gl.bindBuffer(webgl.wrappers.GLEnum.ELEMENT_ARRAY_BUFFER,mesh.indicesBuffer);
	this.gl.drawElements(webgl.wrappers.GLEnum.TRIANGLES,mesh.numItems,webgl.wrappers.GLEnum.UNSIGNED_SHORT,0);
	$s.pop();
}
away3dlite.materials.Material.prototype.set_debug = function(val) {
	$s.push("away3dlite.materials.Material::set_debug");
	var $spos = $s.length;
	if(this._debug == val) {
		$s.pop();
		return val;
	}
	this._debug = val;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.materials.Material.prototype.updateUniforms = function(camera,mesh,stage) {
	$s.push("away3dlite.materials.Material::updateUniforms");
	var $spos = $s.length;
	this.gl.useProgram(this.context.program);
	this.gl.uniformMatrix4fv(this.context.uniformLocations.get("uCamMatrix"),false,new webgl.WebGLFloatArray(stage.transform.perspectiveProjection.toMatrix3D().rawData));
	var m = mesh.get_sceneMatrix3D().clone();
	m.append(camera.get_invSceneMatrix3D());
	this.gl.uniformMatrix4fv(this.context.uniformLocations.get("uMVMatrix"),false,new webgl.WebGLFloatArray(m.rawData));
	$s.pop();
}
away3dlite.materials.Material.prototype.vertexShaderSource = function() {
	$s.push("away3dlite.materials.Material::vertexShaderSource");
	var $spos = $s.length;
	{
		$s.pop();
		return "attribute vec3 aVertexPosition;\n\t\t\n\t\tuniform mat4 uCamMatrix;\n\t\tuniform mat4 uMVMatrix;\n\t\t\n\t\tvoid main(void) {\n\t\t\tgl_Position = uCamMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);\n\t\t}";
	}
	$s.pop();
}
away3dlite.materials.Material.prototype.__class__ = away3dlite.materials.Material;
away3dlite.materials.BitmapMaterial = function(bitmapData) { if( bitmapData === $_ ) return; {
	$s.push("away3dlite.materials.BitmapMaterial::new");
	var $spos = $s.length;
	this.set_bitmap(bitmapData);
	this.currentTextureType = null;
	away3dlite.materials.Material.apply(this,[]);
	$s.pop();
}}
away3dlite.materials.BitmapMaterial.__name__ = ["away3dlite","materials","BitmapMaterial"];
away3dlite.materials.BitmapMaterial.__super__ = away3dlite.materials.Material;
for(var k in away3dlite.materials.Material.prototype ) away3dlite.materials.BitmapMaterial.prototype[k] = away3dlite.materials.Material.prototype[k];
away3dlite.materials.BitmapMaterial._context = null;
away3dlite.materials.BitmapMaterial.prototype.bitmap = null;
away3dlite.materials.BitmapMaterial.prototype.currentId = null;
away3dlite.materials.BitmapMaterial.prototype.currentTextureType = null;
away3dlite.materials.BitmapMaterial.prototype.fragmentShaderSource = function() {
	$s.push("away3dlite.materials.BitmapMaterial::fragmentShaderSource");
	var $spos = $s.length;
	{
		$s.pop();
		return "varying vec2 vTextureCoord;\n\t\t\n\t\tuniform sampler2D uSampler;\n\t\t\n\t\tvoid main(void) {\n\t\t        gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));\n\t\t}";
	}
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.get_bitmap = function() {
	$s.push("away3dlite.materials.BitmapMaterial::get_bitmap");
	var $spos = $s.length;
	{
		var $tmp = this.bitmap;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.get_height = function() {
	$s.push("away3dlite.materials.BitmapMaterial::get_height");
	var $spos = $s.length;
	{
		var $tmp = this.height;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.get_repeat = function() {
	$s.push("away3dlite.materials.BitmapMaterial::get_repeat");
	var $spos = $s.length;
	{
		var $tmp = this.repeat;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.get_smooth = function() {
	$s.push("away3dlite.materials.BitmapMaterial::get_smooth");
	var $spos = $s.length;
	{
		var $tmp = this.smooth;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.get_width = function() {
	$s.push("away3dlite.materials.BitmapMaterial::get_width");
	var $spos = $s.length;
	{
		var $tmp = this.width;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.handleLoadedTexture = function(ev) {
	$s.push("away3dlite.materials.BitmapMaterial::handleLoadedTexture");
	var $spos = $s.length;
	this.gl.bindTexture(webgl.wrappers.GLEnum.TEXTURE_2D,this.tex);
	this.gl.texImage2D(webgl.wrappers.GLEnum.TEXTURE_2D,0,this.bitmap.data,true,null);
	this.gl.texParameteri(webgl.wrappers.GLEnum.TEXTURE_2D,webgl.wrappers.GLEnum.TEXTURE_MAG_FILTER,webgl.wrappers.GLEnum.LINEAR);
	this.gl.texParameteri(webgl.wrappers.GLEnum.TEXTURE_2D,webgl.wrappers.GLEnum.TEXTURE_MIN_FILTER,webgl.wrappers.GLEnum.LINEAR_MIPMAP_LINEAR);
	this.gl.generateMipmap(webgl.wrappers.GLEnum.TEXTURE_2D);
	this.gl.bindTexture(webgl.wrappers.GLEnum.TEXTURE_2D,null);
	this.currentId = away3dlite.materials.BitmapMaterial._bitmapid++;
	this.currentTextureType = Reflect.field(webgl.wrappers.GLEnum,"TEXTURE" + this.currentId);
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.height = null;
away3dlite.materials.BitmapMaterial.prototype.initTexture = function() {
	$s.push("away3dlite.materials.BitmapMaterial::initTexture");
	var $spos = $s.length;
	this.tex = this.gl.createTexture();
	if(this.bitmap.data.complete) this.handleLoadedTexture();
	else this.bitmap.data.onload = $closure(this,"handleLoadedTexture");
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.initializeWebGL = function() {
	$s.push("away3dlite.materials.BitmapMaterial::initializeWebGL");
	var $spos = $s.length;
	this.gl = jsflash.Manager.stage.RenderingContext;
	if(away3dlite.materials.BitmapMaterial._context == null) {
		var vShader = this.gl.createShader(webgl.wrappers.GLEnum.VERTEX_SHADER);
		this.gl.shaderSource(vShader,this.vertexShaderSource());
		this.gl.compileShader(vShader);
		if(!this.gl.getShaderParameter(vShader,webgl.wrappers.GLEnum.COMPILE_STATUS)) {
			var resp = this.gl.getShaderInfoLog(vShader);
			js.Lib.alert(resp);
			throw resp;
		}
		var fShader = this.gl.createShader(webgl.wrappers.GLEnum.FRAGMENT_SHADER);
		this.gl.shaderSource(fShader,this.fragmentShaderSource());
		this.gl.compileShader(fShader);
		if(!this.gl.getShaderParameter(fShader,webgl.wrappers.GLEnum.COMPILE_STATUS)) {
			var resp = this.gl.getShaderInfoLog(fShader);
			js.Lib.alert(resp);
			throw resp;
		}
		var program = this.gl.createProgram();
		this.gl.attachShader(program,vShader);
		this.gl.attachShader(program,fShader);
		this.gl.linkProgram(program);
		if(!this.gl.getProgramParameter(program,webgl.wrappers.GLEnum.LINK_STATUS)) {
			js.Lib.alert("Could not initialise shaders");
			throw "Could not initialise shaders";
		}
		var uniformLocations = new Hash();
		this.gl.useProgram(program);
		uniformLocations.set("uCamMatrix",this.gl.getUniformLocation(program,"uCamMatrix"));
		uniformLocations.set("uMVMatrix",this.gl.getUniformLocation(program,"uMVMatrix"));
		uniformLocations.set("uSampler",this.gl.getUniformLocation(program,"uSampler"));
		var attribLocations = new Hash();
		attribLocations.set("aVertexPosition",this.gl.getAttribLocation(program,"aVertexPosition"));
		attribLocations.set("aTextureCoord",this.gl.getAttribLocation(program,"aTextureCoord"));
		this.gl.enableVertexAttribArray(attribLocations.get("aVertexPosition"));
		this.gl.enableVertexAttribArray(attribLocations.get("aTextureCoord"));
		this.context = away3dlite.materials.BitmapMaterial._context = { vShader : vShader, fShader : fShader, program : program, uniformLocations : uniformLocations, attribLocations : attribLocations}
	}
	else {
		this.context = away3dlite.materials.BitmapMaterial._context;
	}
	this.initTexture();
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.renderMesh = function(mesh,camera,stage) {
	$s.push("away3dlite.materials.BitmapMaterial::renderMesh");
	var $spos = $s.length;
	if(mesh.indicesBuffer == null || mesh.verticesBuffer == null) {
		$s.pop();
		return;
	}
	this.gl.useProgram(this.context.program);
	this.updateUniforms(camera,mesh,stage);
	this.gl.bindBuffer(webgl.wrappers.GLEnum.ARRAY_BUFFER,mesh.verticesBuffer);
	this.gl.vertexAttribPointer(this.context.attribLocations.get("aVertexPosition"),3,webgl.wrappers.GLEnum.FLOAT,false,0,0);
	this.gl.bindBuffer(webgl.wrappers.GLEnum.ARRAY_BUFFER,mesh.stBuffer);
	this.gl.vertexAttribPointer(this.context.attribLocations.get("aTextureCoord"),2,webgl.wrappers.GLEnum.FLOAT,false,0,0);
	this.gl.bindBuffer(webgl.wrappers.GLEnum.ELEMENT_ARRAY_BUFFER,mesh.indicesBuffer);
	this.gl.drawElements(webgl.wrappers.GLEnum.TRIANGLES,mesh.numItems,webgl.wrappers.GLEnum.UNSIGNED_SHORT,0);
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.repeat = null;
away3dlite.materials.BitmapMaterial.prototype.set_bitmap = function(val) {
	$s.push("away3dlite.materials.BitmapMaterial::set_bitmap");
	var $spos = $s.length;
	{
		var $tmp = this.bitmap = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.set_repeat = function(val) {
	$s.push("away3dlite.materials.BitmapMaterial::set_repeat");
	var $spos = $s.length;
	{
		var $tmp = this.repeat = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.set_smooth = function(val) {
	$s.push("away3dlite.materials.BitmapMaterial::set_smooth");
	var $spos = $s.length;
	{
		var $tmp = this.smooth = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.smooth = null;
away3dlite.materials.BitmapMaterial.prototype.tex = null;
away3dlite.materials.BitmapMaterial.prototype.updateUniforms = function(camera,mesh,stage) {
	$s.push("away3dlite.materials.BitmapMaterial::updateUniforms");
	var $spos = $s.length;
	if(this.currentTextureType == null) {
		$s.pop();
		return;
	}
	this.gl.useProgram(this.context.program);
	this.gl.uniformMatrix4fv(this.context.uniformLocations.get("uCamMatrix"),false,new webgl.WebGLFloatArray(stage.transform.perspectiveProjection.toMatrix3D().rawData));
	var m = mesh.get_sceneMatrix3D().clone();
	m.append(camera.get_invSceneMatrix3D());
	this.gl.uniformMatrix4fv(this.context.uniformLocations.get("uMVMatrix"),false,new webgl.WebGLFloatArray(m.rawData));
	this.gl.activeTexture(this.currentTextureType);
	this.gl.bindTexture(webgl.wrappers.GLEnum.TEXTURE_2D,this.tex);
	this.gl.uniform1i(this.context.uniformLocations.get("uSampler"),0);
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.vertexShaderSource = function() {
	$s.push("away3dlite.materials.BitmapMaterial::vertexShaderSource");
	var $spos = $s.length;
	{
		$s.pop();
		return "attribute vec3 aVertexPosition;\n\t\tattribute vec2 aTextureCoord;\n\t\t\n\t\tuniform mat4 uCamMatrix;\n\t\tuniform mat4 uMVMatrix;\n\t\t\n\t\tvarying vec2 vTextureCoord;\n\t\t\n\t\tvoid main(void) {\n\t\t\tgl_Position = uCamMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);\n\t\t\tvTextureCoord = aTextureCoord;\n\t\t}";
	}
	$s.pop();
}
away3dlite.materials.BitmapMaterial.prototype.width = null;
away3dlite.materials.BitmapMaterial.prototype.__class__ = away3dlite.materials.BitmapMaterial;
if(!away3dlite.loaders) away3dlite.loaders = {}
if(!away3dlite.loaders.data) away3dlite.loaders.data = {}
away3dlite.loaders.data.MaterialData = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.loaders.data.MaterialData::new");
	var $spos = $s.length;
	this.materialType = "wireframeMaterial";
	this.faces = new Array();
	this.meshes = new Array();
	this.materialType = "wireframeMaterial";
	$s.pop();
}}
away3dlite.loaders.data.MaterialData.__name__ = ["away3dlite","loaders","data","MaterialData"];
away3dlite.loaders.data.MaterialData.prototype._material = null;
away3dlite.loaders.data.MaterialData.prototype.alpha = null;
away3dlite.loaders.data.MaterialData.prototype.ambientColor = null;
away3dlite.loaders.data.MaterialData.prototype.clone = function(targetObj) {
	$s.push("away3dlite.loaders.data.MaterialData::clone");
	var $spos = $s.length;
	var cloneMatData = targetObj.materialLibrary.addMaterial(this.name);
	cloneMatData.materialType = this.materialType;
	cloneMatData.ambientColor = this.ambientColor;
	cloneMatData.diffuseColor = this.diffuseColor;
	cloneMatData.shininess = this.shininess;
	cloneMatData.specularColor = this.specularColor;
	cloneMatData.textureBitmap = this.textureBitmap;
	cloneMatData.textureFileName = this.textureFileName;
	cloneMatData.set_material(this._material);
	{
		$s.pop();
		return cloneMatData;
	}
	$s.pop();
}
away3dlite.loaders.data.MaterialData.prototype.diffuseColor = null;
away3dlite.loaders.data.MaterialData.prototype.faces = null;
away3dlite.loaders.data.MaterialData.prototype.get_material = function() {
	$s.push("away3dlite.loaders.data.MaterialData::get_material");
	var $spos = $s.length;
	{
		var $tmp = this._material;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.loaders.data.MaterialData.prototype.material = null;
away3dlite.loaders.data.MaterialData.prototype.materialType = null;
away3dlite.loaders.data.MaterialData.prototype.meshes = null;
away3dlite.loaders.data.MaterialData.prototype.name = null;
away3dlite.loaders.data.MaterialData.prototype.set_material = function(val) {
	$s.push("away3dlite.loaders.data.MaterialData::set_material");
	var $spos = $s.length;
	if(this._material == val) {
		$s.pop();
		return val;
	}
	this._material = val;
	if(js.Boot.__instanceof(this._material,away3dlite.materials.BitmapMaterial)) this.textureBitmap = this._material.bitmap;
	{
		var _g = 0, _g1 = this.meshes;
		while(_g < _g1.length) {
			var mesh = _g1[_g];
			++_g;
			mesh.set_material(this._material);
		}
	}
	{
		var _g = 0, _g1 = this.faces;
		while(_g < _g1.length) {
			var face = _g1[_g];
			++_g;
			face.mesh._faceMaterials[face.faceIndex] = this._material;
			face.mesh._materialsDirty = true;
		}
	}
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.loaders.data.MaterialData.prototype.shininess = null;
away3dlite.loaders.data.MaterialData.prototype.specularColor = null;
away3dlite.loaders.data.MaterialData.prototype.textureBitmap = null;
away3dlite.loaders.data.MaterialData.prototype.textureFileName = null;
away3dlite.loaders.data.MaterialData.prototype.__class__ = away3dlite.loaders.data.MaterialData;
jsflash.events.Event = function(inType,inBubbles,inCancelable,inCapturing) { if( inType === $_ ) return; {
	$s.push("jsflash.events.Event::new");
	var $spos = $s.length;
	if(inCapturing == null) inCapturing = true;
	if(inCancelable == null) inCancelable = false;
	if(inBubbles == null) inBubbles = false;
	this.type = inType;
	this.bubbles = inBubbles;
	this.cancelable = inCancelable;
	this.mIsCancelled = false;
	this.mIsCancelledNow = false;
	this.target = null;
	this.currentTarget = null;
	this.capturing = inCapturing;
	if(this.capturing) this.eventPhase = jsflash.events.EventPhase.CAPTURING_PHASE;
	else this.eventPhase = jsflash.events.EventPhase.AT_TARGET;
	$s.pop();
}}
jsflash.events.Event.__name__ = ["jsflash","events","Event"];
jsflash.events.Event.prototype.IsCancelled = function() {
	$s.push("jsflash.events.Event::IsCancelled");
	var $spos = $s.length;
	{
		var $tmp = this.mIsCancelled;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.events.Event.prototype.IsCancelledNow = function() {
	$s.push("jsflash.events.Event::IsCancelledNow");
	var $spos = $s.length;
	{
		var $tmp = this.mIsCancelledNow;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.events.Event.prototype.SetPhase = function(inPhase) {
	$s.push("jsflash.events.Event::SetPhase");
	var $spos = $s.length;
	this.eventPhase = inPhase;
	$s.pop();
}
jsflash.events.Event.prototype.bubbles = null;
jsflash.events.Event.prototype.cancelable = null;
jsflash.events.Event.prototype.capturing = null;
jsflash.events.Event.prototype.clone = function() {
	$s.push("jsflash.events.Event::clone");
	var $spos = $s.length;
	{
		var $tmp = new jsflash.events.Event(this.type,this.bubbles,this.cancelable);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.events.Event.prototype.currentTarget = null;
jsflash.events.Event.prototype.eventPhase = null;
jsflash.events.Event.prototype.mIsCancelled = null;
jsflash.events.Event.prototype.mIsCancelledNow = null;
jsflash.events.Event.prototype.stopImmediatePropagation = function() {
	$s.push("jsflash.events.Event::stopImmediatePropagation");
	var $spos = $s.length;
	if(this.cancelable) this.mIsCancelledNow = this.mIsCancelled = true;
	$s.pop();
}
jsflash.events.Event.prototype.stopPropagation = function() {
	$s.push("jsflash.events.Event::stopPropagation");
	var $spos = $s.length;
	if(this.cancelable) this.mIsCancelled = true;
	$s.pop();
}
jsflash.events.Event.prototype.target = null;
jsflash.events.Event.prototype.toString = function() {
	$s.push("jsflash.events.Event::toString");
	var $spos = $s.length;
	{
		var $tmp = ("[Event " + this.type) + "]";
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.events.Event.prototype.type = null;
jsflash.events.Event.prototype.__class__ = jsflash.events.Event;
if(!away3dlite.events) away3dlite.events = {}
away3dlite.events.MaterialEvent = function(type,material) { if( type === $_ ) return; {
	$s.push("away3dlite.events.MaterialEvent::new");
	var $spos = $s.length;
	jsflash.events.Event.apply(this,[type]);
	this.material = material;
	$s.pop();
}}
away3dlite.events.MaterialEvent.__name__ = ["away3dlite","events","MaterialEvent"];
away3dlite.events.MaterialEvent.__super__ = jsflash.events.Event;
for(var k in jsflash.events.Event.prototype ) away3dlite.events.MaterialEvent.prototype[k] = jsflash.events.Event.prototype[k];
away3dlite.events.MaterialEvent.prototype.clone = function() {
	$s.push("away3dlite.events.MaterialEvent::clone");
	var $spos = $s.length;
	{
		var $tmp = new away3dlite.events.MaterialEvent(this.type,this.material);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.events.MaterialEvent.prototype.extra = null;
away3dlite.events.MaterialEvent.prototype.material = null;
away3dlite.events.MaterialEvent.prototype.__class__ = away3dlite.events.MaterialEvent;
away3dlite.primitives.Sphere = function(material,radius,segmentsW,segmentsH,yUp) { if( material === $_ ) return; {
	$s.push("away3dlite.primitives.Sphere::new");
	var $spos = $s.length;
	if(yUp == null) yUp = true;
	if(segmentsH == null) segmentsH = 6;
	if(segmentsW == null) segmentsW = 8;
	if(radius == null) radius = 100.0;
	away3dlite.primitives.AbstractPrimitive.apply(this,[material]);
	this._radius = radius;
	this._segmentsW = segmentsW;
	this._segmentsH = segmentsH;
	this._yUp = yUp;
	this.type = "Sphere";
	this.url = "primitive";
	$s.pop();
}}
away3dlite.primitives.Sphere.__name__ = ["away3dlite","primitives","Sphere"];
away3dlite.primitives.Sphere.__super__ = away3dlite.primitives.AbstractPrimitive;
for(var k in away3dlite.primitives.AbstractPrimitive.prototype ) away3dlite.primitives.Sphere.prototype[k] = away3dlite.primitives.AbstractPrimitive.prototype[k];
away3dlite.primitives.Sphere.prototype._radius = null;
away3dlite.primitives.Sphere.prototype._segmentsH = null;
away3dlite.primitives.Sphere.prototype._segmentsW = null;
away3dlite.primitives.Sphere.prototype._yUp = null;
away3dlite.primitives.Sphere.prototype.buildPrimitive = function() {
	$s.push("away3dlite.primitives.Sphere::buildPrimitive");
	var $spos = $s.length;
	away3dlite.primitives.AbstractPrimitive.prototype.buildPrimitive.apply(this,[]);
	var i;
	var j;
	j = -1;
	while(++j <= this._segmentsH) {
		var horangle = (3.141592653589793 * j) / this._segmentsH;
		var z = -this._radius * Math.cos(horangle);
		var ringradius = this._radius * Math.sin(horangle);
		i = -1;
		while(++i <= this._segmentsW) {
			var verangle = ((2 * 3.141592653589793) * i) / this._segmentsW;
			var x = ringradius * Math.cos(verangle);
			var y = ringradius * Math.sin(verangle);
			if(this._yUp) away3dlite.haxeutils.VectorUtils.push3(this._vertices,x,-z,y);
			else away3dlite.haxeutils.VectorUtils.push3(this._vertices,x,y,z);
			away3dlite.haxeutils.VectorUtils.push3(this._uvtData,i / this._segmentsW,1 - j / this._segmentsH,1);
		}
	}
	j = 0;
	while(++j <= this._segmentsH) {
		i = 0;
		while(++i <= this._segmentsW) {
			var a = (this._segmentsW + 1) * j + i;
			var b = ((this._segmentsW + 1) * j + i) - 1;
			var c = ((this._segmentsW + 1) * (j - 1) + i) - 1;
			var d = (this._segmentsW + 1) * (j - 1) + i;
			if(j == this._segmentsH) {
				away3dlite.haxeutils.VectorUtils.push3(this._indices,a,c,d);
				this._faceLengths.push(3);
			}
			else if(j == 1) {
				away3dlite.haxeutils.VectorUtils.push3(this._indices,a,b,c);
				this._faceLengths.push(3);
			}
			else {
				away3dlite.haxeutils.VectorUtils.push4(this._indices,a,b,c,d);
				this._faceLengths.push(4);
			}
		}
	}
	$s.pop();
}
away3dlite.primitives.Sphere.prototype.clone = function(object) {
	$s.push("away3dlite.primitives.Sphere::clone");
	var $spos = $s.length;
	var sphere = ((object != null)?object:new away3dlite.primitives.Sphere());
	away3dlite.primitives.AbstractPrimitive.prototype.clone.apply(this,[sphere]);
	sphere.set_radius(this._radius);
	sphere.set_segmentsW(this._segmentsW);
	sphere.set_segmentsH(this._segmentsH);
	sphere.set_yUp(this._yUp);
	sphere._primitiveDirty = false;
	{
		$s.pop();
		return sphere;
	}
	$s.pop();
}
away3dlite.primitives.Sphere.prototype.get_radius = function() {
	$s.push("away3dlite.primitives.Sphere::get_radius");
	var $spos = $s.length;
	{
		var $tmp = this._radius;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.primitives.Sphere.prototype.get_segmentsH = function() {
	$s.push("away3dlite.primitives.Sphere::get_segmentsH");
	var $spos = $s.length;
	{
		var $tmp = this._segmentsH;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.primitives.Sphere.prototype.get_segmentsW = function() {
	$s.push("away3dlite.primitives.Sphere::get_segmentsW");
	var $spos = $s.length;
	{
		var $tmp = this._segmentsW;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.primitives.Sphere.prototype.get_yUp = function() {
	$s.push("away3dlite.primitives.Sphere::get_yUp");
	var $spos = $s.length;
	{
		var $tmp = this._yUp;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.primitives.Sphere.prototype.radius = null;
away3dlite.primitives.Sphere.prototype.segmentsH = null;
away3dlite.primitives.Sphere.prototype.segmentsW = null;
away3dlite.primitives.Sphere.prototype.set_radius = function(val) {
	$s.push("away3dlite.primitives.Sphere::set_radius");
	var $spos = $s.length;
	if(this._radius == val) {
		$s.pop();
		return val;
	}
	this._primitiveDirty = true;
	{
		var $tmp = this._radius = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.primitives.Sphere.prototype.set_segmentsH = function(val) {
	$s.push("away3dlite.primitives.Sphere::set_segmentsH");
	var $spos = $s.length;
	if(this._segmentsH == val) {
		$s.pop();
		return val;
	}
	this._primitiveDirty = true;
	{
		var $tmp = this._segmentsH = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.primitives.Sphere.prototype.set_segmentsW = function(val) {
	$s.push("away3dlite.primitives.Sphere::set_segmentsW");
	var $spos = $s.length;
	if(this._segmentsW == val) {
		$s.pop();
		return val;
	}
	this._primitiveDirty = true;
	{
		var $tmp = this._segmentsW = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.primitives.Sphere.prototype.set_yUp = function(val) {
	$s.push("away3dlite.primitives.Sphere::set_yUp");
	var $spos = $s.length;
	if(this._yUp == val) {
		$s.pop();
		return val;
	}
	this._primitiveDirty = true;
	{
		var $tmp = this._yUp = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.primitives.Sphere.prototype.yUp = null;
away3dlite.primitives.Sphere.prototype.__class__ = away3dlite.primitives.Sphere;
IntIter = function(min,max) { if( min === $_ ) return; {
	$s.push("IntIter::new");
	var $spos = $s.length;
	this.min = min;
	this.max = max;
	$s.pop();
}}
IntIter.__name__ = ["IntIter"];
IntIter.prototype.hasNext = function() {
	$s.push("IntIter::hasNext");
	var $spos = $s.length;
	{
		var $tmp = this.min < this.max;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
IntIter.prototype.max = null;
IntIter.prototype.min = null;
IntIter.prototype.next = function() {
	$s.push("IntIter::next");
	var $spos = $s.length;
	{
		var $tmp = this.min++;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
IntIter.prototype.__class__ = IntIter;
if(typeof haxe=='undefined') haxe = {}
haxe.Log = function() { }
haxe.Log.__name__ = ["haxe","Log"];
haxe.Log.trace = function(v,infos) {
	$s.push("haxe.Log::trace");
	var $spos = $s.length;
	js.Boot.__trace(v,infos);
	$s.pop();
}
haxe.Log.clear = function() {
	$s.push("haxe.Log::clear");
	var $spos = $s.length;
	js.Boot.__clear_trace();
	$s.pop();
}
haxe.Log.prototype.__class__ = haxe.Log;
if(!away3dlite.core.utils) away3dlite.core.utils = {}
away3dlite.core.utils.Debug = function() { }
away3dlite.core.utils.Debug.__name__ = ["away3dlite","core","utils","Debug"];
away3dlite.core.utils.Debug.redirectTraces = null;
away3dlite.core.utils.Debug.set_redirectTraces = function(val) {
	$s.push("away3dlite.core.utils.Debug::set_redirectTraces");
	var $spos = $s.length;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.core.utils.Debug.clear = function() {
	$s.push("away3dlite.core.utils.Debug::clear");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.core.utils.Debug.delimiter = function() {
	$s.push("away3dlite.core.utils.Debug::delimiter");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.core.utils.Debug.trace = function(message,pos) {
	$s.push("away3dlite.core.utils.Debug::trace");
	var $spos = $s.length;
	if(away3dlite.core.utils.Debug.active) haxe.Log.trace((((((pos.className + " at ") + pos.fileName) + " : ") + pos.lineNumber) + " :: ") + message,{ fileName : "Debug.hx", lineNumber : 88, className : "away3dlite.core.utils.Debug", methodName : "dotrace"});
	$s.pop();
}
away3dlite.core.utils.Debug.warning = function(message,pos) {
	$s.push("away3dlite.core.utils.Debug::warning");
	var $spos = $s.length;
	if(away3dlite.core.utils.Debug.warningsAsErrors) {
		away3dlite.core.utils.Debug.error(message,pos);
		{
			$s.pop();
			return;
		}
	}
	haxe.Log.trace("WARNING: " + message,{ fileName : "Debug.hx", lineNumber : 77, className : "away3dlite.core.utils.Debug", methodName : "warning", customParams : [pos]});
	$s.pop();
}
away3dlite.core.utils.Debug.error = function(message,pos) {
	$s.push("away3dlite.core.utils.Debug::error");
	var $spos = $s.length;
	haxe.Log.trace("ERROR: " + message,{ fileName : "Debug.hx", lineNumber : 82, className : "away3dlite.core.utils.Debug", methodName : "error", customParams : [pos]});
	throw jsflash.Error.Message(message);
	$s.pop();
}
away3dlite.core.utils.Debug.dotrace = function(message,pos) {
	$s.push("away3dlite.core.utils.Debug::dotrace");
	var $spos = $s.length;
	haxe.Log.trace((((((pos.className + " at ") + pos.fileName) + " : ") + pos.lineNumber) + " :: ") + message,{ fileName : "Debug.hx", lineNumber : 88, className : "away3dlite.core.utils.Debug", methodName : "dotrace"});
	$s.pop();
}
away3dlite.core.utils.Debug.prototype.__class__ = away3dlite.core.utils.Debug;
away3dlite.events.ClippingEvent = function(type,clipping) { if( type === $_ ) return; {
	$s.push("away3dlite.events.ClippingEvent::new");
	var $spos = $s.length;
	jsflash.events.Event.apply(this,[type]);
	this.clipping = clipping;
	$s.pop();
}}
away3dlite.events.ClippingEvent.__name__ = ["away3dlite","events","ClippingEvent"];
away3dlite.events.ClippingEvent.__super__ = jsflash.events.Event;
for(var k in jsflash.events.Event.prototype ) away3dlite.events.ClippingEvent.prototype[k] = jsflash.events.Event.prototype[k];
away3dlite.events.ClippingEvent.prototype.clipping = null;
away3dlite.events.ClippingEvent.prototype.clone = function() {
	$s.push("away3dlite.events.ClippingEvent::clone");
	var $spos = $s.length;
	{
		var $tmp = new away3dlite.events.ClippingEvent(this.type,this.clipping);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.events.ClippingEvent.prototype.__class__ = away3dlite.events.ClippingEvent;
Hash = function(p) { if( p === $_ ) return; {
	$s.push("Hash::new");
	var $spos = $s.length;
	this.h = {}
	if(this.h.__proto__ != null) {
		this.h.__proto__ = null;
		delete(this.h.__proto__);
	}
	else null;
	$s.pop();
}}
Hash.__name__ = ["Hash"];
Hash.prototype.exists = function(key) {
	$s.push("Hash::exists");
	var $spos = $s.length;
	try {
		key = "$" + key;
		{
			var $tmp = this.hasOwnProperty.call(this.h,key);
			$s.pop();
			return $tmp;
		}
	}
	catch( $e0 ) {
		{
			var e = $e0;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				
				for(var i in this.h)
					if( i == key ) return true;
			;
				{
					$s.pop();
					return false;
				}
			}
		}
	}
	$s.pop();
}
Hash.prototype.get = function(key) {
	$s.push("Hash::get");
	var $spos = $s.length;
	{
		var $tmp = this.h["$" + key];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Hash.prototype.h = null;
Hash.prototype.iterator = function() {
	$s.push("Hash::iterator");
	var $spos = $s.length;
	{
		var $tmp = { ref : this.h, it : this.keys(), hasNext : function() {
			$s.push("Hash::iterator@214");
			var $spos = $s.length;
			{
				var $tmp = this.it.hasNext();
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}, next : function() {
			$s.push("Hash::iterator@215");
			var $spos = $s.length;
			var i = this.it.next();
			{
				var $tmp = this.ref["$" + i];
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Hash.prototype.keys = function() {
	$s.push("Hash::keys");
	var $spos = $s.length;
	var a = new Array();
	
			for(var i in this.h)
				a.push(i.substr(1));
		;
	{
		var $tmp = a.iterator();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Hash.prototype.remove = function(key) {
	$s.push("Hash::remove");
	var $spos = $s.length;
	if(!this.exists(key)) {
		$s.pop();
		return false;
	}
	delete(this.h["$" + key]);
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
Hash.prototype.set = function(key,value) {
	$s.push("Hash::set");
	var $spos = $s.length;
	this.h["$" + key] = value;
	$s.pop();
}
Hash.prototype.toString = function() {
	$s.push("Hash::toString");
	var $spos = $s.length;
	var s = new StringBuf();
	s.b[s.b.length] = "{";
	var it = this.keys();
	{ var $it1 = it;
	while( $it1.hasNext() ) { var i = $it1.next();
	{
		s.b[s.b.length] = i;
		s.b[s.b.length] = " => ";
		s.b[s.b.length] = Std.string(this.get(i));
		if(it.hasNext()) s.b[s.b.length] = ", ";
	}
	}}
	s.b[s.b.length] = "}";
	{
		var $tmp = s.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Hash.prototype.__class__ = Hash;
away3dlite.containers.ObjectContainer3D = function(childArray) { if( childArray === $_ ) return; {
	$s.push("away3dlite.containers.ObjectContainer3D::new");
	var $spos = $s.length;
	away3dlite.core.base.Mesh.apply(this,[]);
	this._children = new Array();
	this._sprites = new Array();
	this._spriteVertices = new Array();
	this._spriteIndices = new Array();
	this._cameraSceneMatrix3D = new jsflash.geom.Matrix3D();
	this._cameraInvSceneMatrix3D = new jsflash.geom.Matrix3D();
	this._orientationMatrix3D = new jsflash.geom.Matrix3D();
	this._cameraMatrix3D = new jsflash.geom.Matrix3D();
	if(childArray != null) {
		var _g = 0;
		while(_g < childArray.length) {
			var child = childArray[_g];
			++_g;
			this.addChild(child);
		}
	}
	$s.pop();
}}
away3dlite.containers.ObjectContainer3D.__name__ = ["away3dlite","containers","ObjectContainer3D"];
away3dlite.containers.ObjectContainer3D.__super__ = away3dlite.core.base.Mesh;
for(var k in away3dlite.core.base.Mesh.prototype ) away3dlite.containers.ObjectContainer3D.prototype[k] = away3dlite.core.base.Mesh.prototype[k];
away3dlite.containers.ObjectContainer3D.prototype._cameraForwardVector = null;
away3dlite.containers.ObjectContainer3D.prototype._cameraInvSceneMatrix3D = null;
away3dlite.containers.ObjectContainer3D.prototype._cameraMatrix3D = null;
away3dlite.containers.ObjectContainer3D.prototype._cameraPosition = null;
away3dlite.containers.ObjectContainer3D.prototype._cameraSceneMatrix3D = null;
away3dlite.containers.ObjectContainer3D.prototype._children = null;
away3dlite.containers.ObjectContainer3D.prototype._index = null;
away3dlite.containers.ObjectContainer3D.prototype._orientationMatrix3D = null;
away3dlite.containers.ObjectContainer3D.prototype._spriteIndices = null;
away3dlite.containers.ObjectContainer3D.prototype._spritePosition = null;
away3dlite.containers.ObjectContainer3D.prototype._spriteRotationVector = null;
away3dlite.containers.ObjectContainer3D.prototype._spriteVertices = null;
away3dlite.containers.ObjectContainer3D.prototype._sprites = null;
away3dlite.containers.ObjectContainer3D.prototype._spritesDirty = null;
away3dlite.containers.ObjectContainer3D.prototype._viewDecomposed = null;
away3dlite.containers.ObjectContainer3D.prototype.addChild = function(child) {
	$s.push("away3dlite.containers.ObjectContainer3D::addChild");
	var $spos = $s.length;
	child = away3dlite.core.base.Mesh.prototype.addChild.apply(this,[child]);
	this._children[this._children.length] = jsflash.Lib["as"](child,away3dlite.core.base.Object3D);
	jsflash.Lib["as"](child,away3dlite.core.base.Object3D).updateScene(this._scene);
	{
		$s.pop();
		return child;
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.addSprite = function(sprite) {
	$s.push("away3dlite.containers.ObjectContainer3D::addSprite");
	var $spos = $s.length;
	this._sprites[sprite.index = this._sprites.length] = sprite;
	this._uvtData = this._uvtData.concat(sprite.uvtData);
	this._faceMaterials.push(sprite.get_material());
	this._faceLengths.push(4);
	this._spritesDirty = true;
	{
		$s.pop();
		return sprite;
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.children = null;
away3dlite.containers.ObjectContainer3D.prototype.clone = function(object) {
	$s.push("away3dlite.containers.ObjectContainer3D::clone");
	var $spos = $s.length;
	var container = ((object != null)?(jsflash.Lib["as"](object,away3dlite.containers.ObjectContainer3D)):new away3dlite.containers.ObjectContainer3D());
	away3dlite.core.base.Mesh.prototype.clone.apply(this,[container]);
	{
		var _g = 0, _g1 = this.get_children();
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			container.addChild(child.clone());
		}
	}
	{
		$s.pop();
		return container;
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.getBoneByName = function(boneName) {
	$s.push("away3dlite.containers.ObjectContainer3D::getBoneByName");
	var $spos = $s.length;
	var bone;
	{
		var _g = 0, _g1 = this.get_children();
		while(_g < _g1.length) {
			var object3D = _g1[_g];
			++_g;
			if(js.Boot.__instanceof(object3D,away3dlite.animators.bones.Bone)) {
				bone = jsflash.Lib["as"](object3D,away3dlite.animators.bones.Bone);
				if(bone.name != null) if(bone.name == boneName) {
					$s.pop();
					return bone;
				}
				if(bone.boneId != null) if(bone.boneId == boneName) {
					$s.pop();
					return bone;
				}
			}
			if(js.Boot.__instanceof(object3D,away3dlite.containers.ObjectContainer3D)) {
				bone = jsflash.Lib["as"](object3D,away3dlite.containers.ObjectContainer3D).getBoneByName(boneName);
				if(bone != null) {
					$s.pop();
					return bone;
				}
			}
		}
	}
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.getChildByName = function(childName) {
	$s.push("away3dlite.containers.ObjectContainer3D::getChildByName");
	var $spos = $s.length;
	var child;
	{
		var _g = 0, _g1 = this.get_children();
		while(_g < _g1.length) {
			var object3D = _g1[_g];
			++_g;
			if(object3D.name != null) if(object3D.name == childName) {
				$s.pop();
				return object3D;
			}
			if(js.Boot.__instanceof(object3D,away3dlite.containers.ObjectContainer3D)) {
				child = jsflash.Lib["as"](jsflash.Lib["as"](object3D,away3dlite.containers.ObjectContainer3D).getChildByName(childName),away3dlite.core.base.Object3D);
				if(child != null) {
					$s.pop();
					return child;
				}
			}
		}
	}
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.get_children = function() {
	$s.push("away3dlite.containers.ObjectContainer3D::get_children");
	var $spos = $s.length;
	{
		var $tmp = this._children;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.get_sprites = function() {
	$s.push("away3dlite.containers.ObjectContainer3D::get_sprites");
	var $spos = $s.length;
	{
		var $tmp = this._sprites;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.get_vertices = function() {
	$s.push("away3dlite.containers.ObjectContainer3D::get_vertices");
	var $spos = $s.length;
	if(this._sprites.length > 0) {
		var i;
		var index;
		var sprite;
		if(this._spritesDirty) {
			this._spritesDirty = false;
			{
				var _g = 0, _g1 = this._sprites;
				while(_g < _g1.length) {
					var sprite1 = _g1[_g];
					++_g;
					this._spriteIndices = sprite1.indices;
					index = Std["int"](sprite1.index * 4);
					i = 4;
					while(i-- > 0) this._indices[Std["int"](index + i)] = this._spriteIndices[Std["int"](i)] + index;
				}
			}
			this.buildFaces();
		}
		this._orientationMatrix3D.set_rawData(this._sceneMatrix3D.rawData);
		this._orientationMatrix3D.append(this._cameraInvSceneMatrix3D);
		this._viewDecomposed = this._orientationMatrix3D.decompose(jsflash.geom.Orientation3D.AXIS_ANGLE);
		this._orientationMatrix3D.identity();
		this._orientationMatrix3D.appendRotation((-this._viewDecomposed[1].w * 180) / Math.PI,this._viewDecomposed[1]);
		{
			var _g = 0, _g1 = this._sprites;
			while(_g < _g1.length) {
				var sprite1 = _g1[_g];
				++_g;
				if(sprite1.alignmentType == "viewplane") {
					this._orientationMatrix3D.transformVectors(sprite1.get_vertices(),this._spriteVertices);
				}
				else {
					this._spritePosition = sprite1.get_position().subtract(this._cameraPosition);
					this._spriteRotationVector = this._cameraForwardVector.crossProduct(this._spritePosition);
					this._spriteRotationVector.normalize();
					this._cameraMatrix3D.set_rawData(this._orientationMatrix3D.rawData);
					this._cameraMatrix3D.appendRotation(Math.acos(this._cameraForwardVector.dotProduct(this._spritePosition) / (this._cameraForwardVector.get_length() * this._spritePosition.get_length())) * (180 / Math.PI),this._spriteRotationVector);
					this._cameraMatrix3D.transformVectors(sprite1.get_vertices(),this._spriteVertices);
				}
				index = Std["int"](sprite1.index * 12);
				i = 12;
				while((i -= 3) >= 0) {
					this._vertices[Std["int"](index + i)] = this._spriteVertices[Std["int"](i)] + sprite1.x;
					this._vertices[Std["int"]((index + i) + 1)] = this._spriteVertices[Std["int"](i + 1)] + sprite1.y;
					this._vertices[Std["int"]((index + i) + 2)] = this._spriteVertices[Std["int"](i + 2)] + sprite1.z;
				}
			}
		}
	}
	{
		var $tmp = this._vertices;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.iterator = function() {
	$s.push("away3dlite.containers.ObjectContainer3D::iterator");
	var $spos = $s.length;
	{
		var $tmp = this._children.iterator();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.project = function(camera,parentSceneMatrix3D) {
	$s.push("away3dlite.containers.ObjectContainer3D::project");
	var $spos = $s.length;
	if(this._sprites.length != 0) {
		this._cameraInvSceneMatrix3D = camera.get_invSceneMatrix3D();
		this._cameraSceneMatrix3D.set_rawData(this._cameraInvSceneMatrix3D.rawData);
		this._cameraSceneMatrix3D.invert();
		this._cameraPosition = this._cameraSceneMatrix3D.get_position();
		this._cameraForwardVector = new jsflash.geom.Vector3D(this._cameraSceneMatrix3D.rawData[8],this._cameraSceneMatrix3D.rawData[9],this._cameraSceneMatrix3D.rawData[10]);
	}
	away3dlite.core.base.Mesh.prototype.project.apply(this,[camera,parentSceneMatrix3D]);
	var child;
	{
		var _g = 0, _g1 = this._children;
		while(_g < _g1.length) {
			var child1 = _g1[_g];
			++_g;
			child1.project(camera,this._sceneMatrix3D);
		}
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.removeChild = function(child) {
	$s.push("away3dlite.containers.ObjectContainer3D::removeChild");
	var $spos = $s.length;
	child = away3dlite.core.base.Mesh.prototype.removeChild.apply(this,[child]);
	this._index = -1;
	var i = 0;
	{
		var _g = 0, _g1 = this._children;
		while(_g < _g1.length) {
			var _child = _g1[_g];
			++_g;
			if(_child == child) this._index = i;
			i++;
		}
	}
	if(this._index == -1) {
		$s.pop();
		return null;
	}
	this._children.splice(this._index,1);
	jsflash.Lib["as"](child,away3dlite.core.base.Object3D).updateScene(null);
	{
		$s.pop();
		return child;
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.removeSprite = function(sprite) {
	$s.push("away3dlite.containers.ObjectContainer3D::removeSprite");
	var $spos = $s.length;
	this._index = away3dlite.haxeutils.ArrayUtils.indexOf(this._sprites,sprite);
	if(this._index == -1) {
		$s.pop();
		return null;
	}
	this._sprites.splice(this._index,1);
	this._uvtData.splice(this._index * 12,12);
	this._faceMaterials.splice(this._index,1);
	this._faceLengths.splice(this._index,1);
	this._spritesDirty = true;
	{
		$s.pop();
		return sprite;
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.sprites = null;
away3dlite.containers.ObjectContainer3D.prototype.updateScene = function(val) {
	$s.push("away3dlite.containers.ObjectContainer3D::updateScene");
	var $spos = $s.length;
	if(this.get_scene() == val) {
		$s.pop();
		return;
	}
	away3dlite.core.base.Mesh.prototype.updateScene.apply(this,[val]);
	{
		var _g = 0, _g1 = this._children;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			child.updateScene(this._scene);
		}
	}
	$s.pop();
}
away3dlite.containers.ObjectContainer3D.prototype.__class__ = away3dlite.containers.ObjectContainer3D;
if(!away3dlite.animators) away3dlite.animators = {}
if(!away3dlite.animators.bones) away3dlite.animators.bones = {}
away3dlite.animators.bones.Bone = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.animators.bones.Bone::new");
	var $spos = $s.length;
	away3dlite.containers.ObjectContainer3D.apply(this,[]);
	this.addChild(this.joint = new away3dlite.containers.ObjectContainer3D());
	$s.pop();
}}
away3dlite.animators.bones.Bone.__name__ = ["away3dlite","animators","bones","Bone"];
away3dlite.animators.bones.Bone.__super__ = away3dlite.containers.ObjectContainer3D;
for(var k in away3dlite.containers.ObjectContainer3D.prototype ) away3dlite.animators.bones.Bone.prototype[k] = away3dlite.containers.ObjectContainer3D.prototype[k];
away3dlite.animators.bones.Bone.prototype.boneId = null;
away3dlite.animators.bones.Bone.prototype.clone = function(object) {
	$s.push("away3dlite.animators.bones.Bone::clone");
	var $spos = $s.length;
	var bone = ((object != null)?(jsflash.Lib["as"](object,away3dlite.animators.bones.Bone)):new away3dlite.animators.bones.Bone());
	away3dlite.containers.ObjectContainer3D.prototype.clone.apply(this,[bone]);
	bone.joint = jsflash.Lib["as"](bone.get_children()[0],away3dlite.containers.ObjectContainer3D);
	{
		$s.pop();
		return bone;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.get_jointRotationX = function() {
	$s.push("away3dlite.animators.bones.Bone::get_jointRotationX");
	var $spos = $s.length;
	{
		var $tmp = this.joint.get_rotationX();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.get_jointRotationY = function() {
	$s.push("away3dlite.animators.bones.Bone::get_jointRotationY");
	var $spos = $s.length;
	{
		var $tmp = this.joint.get_rotationY();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.get_jointRotationZ = function() {
	$s.push("away3dlite.animators.bones.Bone::get_jointRotationZ");
	var $spos = $s.length;
	{
		var $tmp = this.joint.get_rotationZ();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.get_jointScaleX = function() {
	$s.push("away3dlite.animators.bones.Bone::get_jointScaleX");
	var $spos = $s.length;
	{
		var $tmp = this.joint.get_scaleX();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.get_jointScaleY = function() {
	$s.push("away3dlite.animators.bones.Bone::get_jointScaleY");
	var $spos = $s.length;
	{
		var $tmp = this.joint.get_scaleY();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.get_jointScaleZ = function() {
	$s.push("away3dlite.animators.bones.Bone::get_jointScaleZ");
	var $spos = $s.length;
	{
		var $tmp = this.joint.get_scaleZ();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.joint = null;
away3dlite.animators.bones.Bone.prototype.jointRotationX = null;
away3dlite.animators.bones.Bone.prototype.set_jointRotationX = function(rot) {
	$s.push("away3dlite.animators.bones.Bone::set_jointRotationX");
	var $spos = $s.length;
	{
		var $tmp = this.joint.set_rotationX(rot);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.set_jointRotationY = function(rot) {
	$s.push("away3dlite.animators.bones.Bone::set_jointRotationY");
	var $spos = $s.length;
	{
		var $tmp = this.joint.set_rotationY(rot);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.set_jointRotationZ = function(rot) {
	$s.push("away3dlite.animators.bones.Bone::set_jointRotationZ");
	var $spos = $s.length;
	{
		var $tmp = this.joint.set_rotationZ(rot);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.set_jointScaleX = function(scale) {
	$s.push("away3dlite.animators.bones.Bone::set_jointScaleX");
	var $spos = $s.length;
	{
		var $tmp = this.joint.set_scaleX(scale);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.set_jointScaleY = function(scale) {
	$s.push("away3dlite.animators.bones.Bone::set_jointScaleY");
	var $spos = $s.length;
	{
		var $tmp = this.joint.set_scaleY(scale);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.set_jointScaleZ = function(scale) {
	$s.push("away3dlite.animators.bones.Bone::set_jointScaleZ");
	var $spos = $s.length;
	{
		var $tmp = this.joint.set_scaleZ(scale);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.Bone.prototype.__class__ = away3dlite.animators.bones.Bone;
if(!haxe.io) haxe.io = {}
haxe.io.Bytes = function(length,b) { if( length === $_ ) return; {
	$s.push("haxe.io.Bytes::new");
	var $spos = $s.length;
	this.length = length;
	this.b = b;
	$s.pop();
}}
haxe.io.Bytes.__name__ = ["haxe","io","Bytes"];
haxe.io.Bytes.alloc = function(length) {
	$s.push("haxe.io.Bytes::alloc");
	var $spos = $s.length;
	var a = new Array();
	{
		var _g = 0;
		while(_g < length) {
			var i = _g++;
			a.push(0);
		}
	}
	{
		var $tmp = new haxe.io.Bytes(length,a);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.ofString = function(s) {
	$s.push("haxe.io.Bytes::ofString");
	var $spos = $s.length;
	var a = new Array();
	{
		var _g1 = 0, _g = s.length;
		while(_g1 < _g) {
			var i = _g1++;
			var c = s["cca"](i);
			if(c <= 127) a.push(c);
			else if(c <= 2047) {
				a.push(192 | (c >> 6));
				a.push(128 | (c & 63));
			}
			else if(c <= 65535) {
				a.push(224 | (c >> 12));
				a.push(128 | ((c >> 6) & 63));
				a.push(128 | (c & 63));
			}
			else {
				a.push(240 | (c >> 18));
				a.push(128 | ((c >> 12) & 63));
				a.push(128 | ((c >> 6) & 63));
				a.push(128 | (c & 63));
			}
		}
	}
	{
		var $tmp = new haxe.io.Bytes(a.length,a);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.ofData = function(b) {
	$s.push("haxe.io.Bytes::ofData");
	var $spos = $s.length;
	{
		var $tmp = new haxe.io.Bytes(b.length,b);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.b = null;
haxe.io.Bytes.prototype.blit = function(pos,src,srcpos,len) {
	$s.push("haxe.io.Bytes::blit");
	var $spos = $s.length;
	if(pos < 0 || srcpos < 0 || len < 0 || pos + len > this.length || srcpos + len > src.length) throw haxe.io.Error.OutsideBounds;
	var b1 = this.b;
	var b2 = src.b;
	if(b1 == b2 && pos > srcpos) {
		var i = len;
		while(i > 0) {
			i--;
			b1[i + pos] = b2[i + srcpos];
		}
		{
			$s.pop();
			return;
		}
	}
	{
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			b1[i + pos] = b2[i + srcpos];
		}
	}
	$s.pop();
}
haxe.io.Bytes.prototype.compare = function(other) {
	$s.push("haxe.io.Bytes::compare");
	var $spos = $s.length;
	var b1 = this.b;
	var b2 = other.b;
	var len = ((this.length < other.length)?this.length:other.length);
	{
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			if(b1[i] != b2[i]) {
				var $tmp = b1[i] - b2[i];
				$s.pop();
				return $tmp;
			}
		}
	}
	{
		var $tmp = this.length - other.length;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.get = function(pos) {
	$s.push("haxe.io.Bytes::get");
	var $spos = $s.length;
	{
		var $tmp = this.b[pos];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.getData = function() {
	$s.push("haxe.io.Bytes::getData");
	var $spos = $s.length;
	{
		var $tmp = this.b;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.length = null;
haxe.io.Bytes.prototype.readString = function(pos,len) {
	$s.push("haxe.io.Bytes::readString");
	var $spos = $s.length;
	if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
	var s = "";
	var b = this.b;
	var fcc = $closure(String,"fromCharCode");
	var i = pos;
	var max = pos + len;
	while(i < max) {
		var c = b[i++];
		if(c < 128) {
			if(c == 0) break;
			s += fcc(c);
		}
		else if(c < 224) s += fcc(((c & 63) << 6) | (b[i++] & 127));
		else if(c < 240) {
			var c2 = b[i++];
			s += fcc((((c & 31) << 12) | ((c2 & 127) << 6)) | (b[i++] & 127));
		}
		else {
			var c2 = b[i++];
			var c3 = b[i++];
			s += fcc(((((c & 15) << 18) | ((c2 & 127) << 12)) | ((c3 << 6) & 127)) | (b[i++] & 127));
		}
	}
	{
		$s.pop();
		return s;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.set = function(pos,v) {
	$s.push("haxe.io.Bytes::set");
	var $spos = $s.length;
	this.b[pos] = (v & 255);
	$s.pop();
}
haxe.io.Bytes.prototype.sub = function(pos,len) {
	$s.push("haxe.io.Bytes::sub");
	var $spos = $s.length;
	if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
	{
		var $tmp = new haxe.io.Bytes(len,this.b.slice(pos,pos + len));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.toString = function() {
	$s.push("haxe.io.Bytes::toString");
	var $spos = $s.length;
	{
		var $tmp = this.readString(0,this.length);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.__class__ = haxe.io.Bytes;
away3dlite.core.base.Face = function(mesh,faceIndex,index,length) { if( mesh === $_ ) return; {
	$s.push("away3dlite.core.base.Face::new");
	var $spos = $s.length;
	this.mesh = mesh;
	this.faceIndex = faceIndex;
	var _mesh_arcane = mesh;
	this._uvtData = _mesh_arcane._uvtData;
	this._vertices = _mesh_arcane._vertices;
	this._screenVertices = _mesh_arcane._screenVertices;
	this.i0 = _mesh_arcane._indices[Std["int"](index)];
	this.i1 = _mesh_arcane._indices[Std["int"](index + 1)];
	this.i2 = _mesh_arcane._indices[Std["int"](index + 2)];
	this.x0 = 2 * this.i0;
	this.y0 = 2 * this.i0 + 1;
	this.x1 = 2 * this.i1;
	this.y1 = 2 * this.i1 + 1;
	this.x2 = 2 * this.i2;
	this.y2 = 2 * this.i2 + 1;
	this.u0 = 3 * this.i0;
	this.v0 = 3 * this.i0 + 1;
	this.t0 = 3 * this.i0 + 2;
	this.u1 = 3 * this.i1;
	this.v1 = 3 * this.i1 + 1;
	this.t1 = 3 * this.i1 + 2;
	this.u2 = 3 * this.i2;
	this.v2 = 3 * this.i2 + 1;
	this.t2 = 3 * this.i2 + 2;
	if(length > 3) {
		this.i3 = _mesh_arcane._indices[Std["int"](index + 3)];
		this.x3 = 2 * this.i3;
		this.y3 = 2 * this.i3 + 1;
		this.u3 = 3 * this.i3;
		this.v3 = 3 * this.i3 + 1;
		this.t3 = 3 * this.i3 + 2;
	}
	$s.pop();
}}
away3dlite.core.base.Face.__name__ = ["away3dlite","core","base","Face"];
away3dlite.core.base.Face.prototype._screenVertices = null;
away3dlite.core.base.Face.prototype._uvtData = null;
away3dlite.core.base.Face.prototype._vertices = null;
away3dlite.core.base.Face.prototype.calculateAverageZ = function() {
	$s.push("away3dlite.core.base.Face::calculateAverageZ");
	var $spos = $s.length;
	{
		var $tmp = ((this.i3 != 0)?Std["int"]((((this._uvtData[this.t0] + this._uvtData[this.t1]) + this._uvtData[this.t2]) + this._uvtData[this.t3]) * 750000):Std["int"](((this._uvtData[this.t0] + this._uvtData[this.t1]) + this._uvtData[this.t2]) * 1000000));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Face.prototype.calculateFurthestZ = function() {
	$s.push("away3dlite.core.base.Face::calculateFurthestZ");
	var $spos = $s.length;
	var z = this._uvtData[this.t0];
	if(z > this._uvtData[this.t1]) z = this._uvtData[this.t1];
	if(z > this._uvtData[this.t2]) z = this._uvtData[this.t2];
	if(this.i3 != 0 && z > this._uvtData[this.t3]) z = this._uvtData[this.t3];
	{
		var $tmp = Std["int"](z * 3000000);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Face.prototype.calculateNearestZ = function() {
	$s.push("away3dlite.core.base.Face::calculateNearestZ");
	var $spos = $s.length;
	var z = this._uvtData[this.t0];
	if(z < this._uvtData[this.t1]) z = this._uvtData[this.t1];
	if(z < this._uvtData[this.t2]) z = this._uvtData[this.t2];
	if(this.i3 != 0 && z < this._uvtData[this.t3]) z = this._uvtData[this.t3];
	{
		var $tmp = Std["int"](z * 3000000);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Face.prototype.calculateScreenZ = null;
away3dlite.core.base.Face.prototype.calculateUVT = function(x,y) {
	$s.push("away3dlite.core.base.Face::calculateUVT");
	var $spos = $s.length;
	var v0x = this._vertices[this.x0];
	var v0y = this._vertices[this.y0];
	var v2x = this._vertices[this.x2];
	var v2y = this._vertices[this.y2];
	var ax;
	var ay;
	var az;
	var au;
	var av;
	var bx;
	var by;
	var bz;
	var bu;
	var bv;
	var cx;
	var cy;
	var cz;
	var cu;
	var cv;
	if(this.i3 != 0 && ((v0x * (v2y - y) + x * (v0y - v2y)) + v2x * (y - v0y)) < 0) {
		az = this._uvtData[this.t0];
		bz = this._uvtData[this.t2];
		cz = this._uvtData[this.t3];
		ax = (this._screenVertices[this.x0] - x) / az;
		bx = (this._screenVertices[this.x2] - x) / bz;
		cx = (this._screenVertices[this.x3] - x) / cz;
		ay = (this._screenVertices[this.y0] - y) / az;
		by = (this._screenVertices[this.y2] - y) / bz;
		cy = (this._screenVertices[this.y3] - y) / cz;
		au = this._uvtData[this.u0];
		av = this._uvtData[this.v0];
		bu = this._uvtData[this.u2];
		bv = this._uvtData[this.v2];
		cu = this._uvtData[this.u3];
		cv = this._uvtData[this.v3];
	}
	else {
		az = this._uvtData[this.t0];
		bz = this._uvtData[this.t1];
		cz = this._uvtData[this.t2];
		ax = (this._screenVertices[this.x0] - x) / az;
		bx = (this._screenVertices[this.x1] - x) / bz;
		cx = (this._screenVertices[this.x2] - x) / cz;
		ay = (this._screenVertices[this.y0] - y) / az;
		by = (this._screenVertices[this.y1] - y) / bz;
		cy = (this._screenVertices[this.y2] - y) / cz;
		au = this._uvtData[this.u0];
		av = this._uvtData[this.v0];
		bu = this._uvtData[this.u1];
		bv = this._uvtData[this.v1];
		cu = this._uvtData[this.u2];
		cv = this._uvtData[this.v2];
	}
	var det = (ax * (by - cy) + bx * (cy - ay)) + cx * (ay - by);
	var ad = (x * (by - cy) + bx * (cy - y)) + cx * (y - by);
	var bd = (ax * (y - cy) + x * (cy - ay)) + cx * (ay - y);
	var cd = (ax * (by - y) + bx * (y - ay)) + x * (ay - by);
	{
		var $tmp = new jsflash.geom.Vector3D(((ad * au + bd * bu) + cd * cu) / det,((ad * av + bd * bv) + cd * cv) / det,((ad / az + bd / bz) + cd / cz) / det);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.base.Face.prototype.faceIndex = null;
away3dlite.core.base.Face.prototype.i0 = null;
away3dlite.core.base.Face.prototype.i1 = null;
away3dlite.core.base.Face.prototype.i2 = null;
away3dlite.core.base.Face.prototype.i3 = null;
away3dlite.core.base.Face.prototype.material = null;
away3dlite.core.base.Face.prototype.mesh = null;
away3dlite.core.base.Face.prototype.t0 = null;
away3dlite.core.base.Face.prototype.t1 = null;
away3dlite.core.base.Face.prototype.t2 = null;
away3dlite.core.base.Face.prototype.t3 = null;
away3dlite.core.base.Face.prototype.u0 = null;
away3dlite.core.base.Face.prototype.u1 = null;
away3dlite.core.base.Face.prototype.u2 = null;
away3dlite.core.base.Face.prototype.u3 = null;
away3dlite.core.base.Face.prototype.v0 = null;
away3dlite.core.base.Face.prototype.v1 = null;
away3dlite.core.base.Face.prototype.v2 = null;
away3dlite.core.base.Face.prototype.v3 = null;
away3dlite.core.base.Face.prototype.x0 = null;
away3dlite.core.base.Face.prototype.x1 = null;
away3dlite.core.base.Face.prototype.x2 = null;
away3dlite.core.base.Face.prototype.x3 = null;
away3dlite.core.base.Face.prototype.y0 = null;
away3dlite.core.base.Face.prototype.y1 = null;
away3dlite.core.base.Face.prototype.y2 = null;
away3dlite.core.base.Face.prototype.y3 = null;
away3dlite.core.base.Face.prototype.__class__ = away3dlite.core.base.Face;
away3dlite.loaders.data.ChannelData = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.loaders.data.ChannelData::new");
	var $spos = $s.length;
	null;
	$s.pop();
}}
away3dlite.loaders.data.ChannelData.__name__ = ["away3dlite","loaders","data","ChannelData"];
away3dlite.loaders.data.ChannelData.prototype.channel = null;
away3dlite.loaders.data.ChannelData.prototype.name = null;
away3dlite.loaders.data.ChannelData.prototype.type = null;
away3dlite.loaders.data.ChannelData.prototype.xml = null;
away3dlite.loaders.data.ChannelData.prototype.__class__ = away3dlite.loaders.data.ChannelData;
if(!jsflash.geom) jsflash.geom = {}
jsflash.geom.Matrix = function(p) { if( p === $_ ) return; {
	$s.push("jsflash.geom.Matrix::new");
	var $spos = $s.length;
	null;
	$s.pop();
}}
jsflash.geom.Matrix.__name__ = ["jsflash","geom","Matrix"];
jsflash.geom.Matrix.prototype.__class__ = jsflash.geom.Matrix;
if(!away3dlite.core.render) away3dlite.core.render = {}
away3dlite.core.render.Renderer = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.core.render.Renderer::new");
	var $spos = $s.length;
	null;
	$s.pop();
}}
away3dlite.core.render.Renderer.__name__ = ["away3dlite","core","render","Renderer"];
away3dlite.core.render.Renderer.prototype._clipping = null;
away3dlite.core.render.Renderer.prototype._face = null;
away3dlite.core.render.Renderer.prototype._faceStore = null;
away3dlite.core.render.Renderer.prototype._faces = null;
away3dlite.core.render.Renderer.prototype._ind = null;
away3dlite.core.render.Renderer.prototype._index = null;
away3dlite.core.render.Renderer.prototype._indexX = null;
away3dlite.core.render.Renderer.prototype._indexY = null;
away3dlite.core.render.Renderer.prototype._mouseEnabled = null;
away3dlite.core.render.Renderer.prototype._mouseEnabledArray = null;
away3dlite.core.render.Renderer.prototype._pointFace = null;
away3dlite.core.render.Renderer.prototype._scene = null;
away3dlite.core.render.Renderer.prototype._screenPointVertexArrays = null;
away3dlite.core.render.Renderer.prototype._screenPointVertices = null;
away3dlite.core.render.Renderer.prototype._screenVertexArrays = null;
away3dlite.core.render.Renderer.prototype._screenVertices = null;
away3dlite.core.render.Renderer.prototype._screenZ = null;
away3dlite.core.render.Renderer.prototype._sort = null;
away3dlite.core.render.Renderer.prototype._uvt = null;
away3dlite.core.render.Renderer.prototype._vert = null;
away3dlite.core.render.Renderer.prototype._view = null;
away3dlite.core.render.Renderer.prototype.collectPointFace = function(x,y) {
	$s.push("away3dlite.core.render.Renderer::collectPointFace");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.core.render.Renderer.prototype.collectPointVertices = function(x,y) {
	$s.push("away3dlite.core.render.Renderer::collectPointVertices");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.core.render.Renderer.prototype.collectScreenVertices = function(mesh) {
	$s.push("away3dlite.core.render.Renderer::collectScreenVertices");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.core.render.Renderer.prototype.getFaceUnderPoint = function(x,y) {
	$s.push("away3dlite.core.render.Renderer::getFaceUnderPoint");
	var $spos = $s.length;
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
away3dlite.core.render.Renderer.prototype.i = null;
away3dlite.core.render.Renderer.prototype.j = null;
away3dlite.core.render.Renderer.prototype.k = null;
away3dlite.core.render.Renderer.prototype.np0 = null;
away3dlite.core.render.Renderer.prototype.np1 = null;
away3dlite.core.render.Renderer.prototype.q0 = null;
away3dlite.core.render.Renderer.prototype.q1 = null;
away3dlite.core.render.Renderer.prototype.ql = null;
away3dlite.core.render.Renderer.prototype.render = function() {
	$s.push("away3dlite.core.render.Renderer::render");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.core.render.Renderer.prototype.setView = function(view) {
	$s.push("away3dlite.core.render.Renderer::setView");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.core.render.Renderer.prototype.sortFaces = function() {
	$s.push("away3dlite.core.render.Renderer::sortFaces");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.core.render.Renderer.prototype.__class__ = away3dlite.core.render.Renderer;
jsflash.display.BitmapData = function(p) { if( p === $_ ) return; {
	$s.push("jsflash.display.BitmapData::new");
	var $spos = $s.length;
	null;
	$s.pop();
}}
jsflash.display.BitmapData.__name__ = ["jsflash","display","BitmapData"];
jsflash.display.BitmapData.ofFile = function(src) {
	$s.push("jsflash.display.BitmapData::ofFile");
	var $spos = $s.length;
	var bd = new jsflash.display.BitmapData();
	bd.data = new Image();
	bd.data.onload = $closure(bd,"onload");
	bd.data.src = src;
	{
		$s.pop();
		return bd;
	}
	$s.pop();
}
jsflash.display.BitmapData.prototype.data = null;
jsflash.display.BitmapData.prototype.loaded = null;
jsflash.display.BitmapData.prototype.onload = function(ev) {
	$s.push("jsflash.display.BitmapData::onload");
	var $spos = $s.length;
	this.loaded = true;
	$s.pop();
}
jsflash.display.BitmapData.prototype.__class__ = jsflash.display.BitmapData;
if(!away3dlite.haxeutils) away3dlite.haxeutils = {}
away3dlite.haxeutils.FastReflect = function() { }
away3dlite.haxeutils.FastReflect.__name__ = ["away3dlite","haxeutils","FastReflect"];
away3dlite.haxeutils.FastReflect.hasField = function(o,field) {
	$s.push("away3dlite.haxeutils.FastReflect::hasField");
	var $spos = $s.length;
	{
		var $tmp = Reflect.hasField(o,field);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.FastReflect.prototype.__class__ = away3dlite.haxeutils.FastReflect;
if(!away3dlite.loaders.utils) away3dlite.loaders.utils = {}
away3dlite.loaders.utils.MaterialLibrary = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.loaders.utils.MaterialLibrary::new");
	var $spos = $s.length;
	Hash.apply(this,[]);
	this.length = 0;
	$s.pop();
}}
away3dlite.loaders.utils.MaterialLibrary.__name__ = ["away3dlite","loaders","utils","MaterialLibrary"];
away3dlite.loaders.utils.MaterialLibrary.__super__ = Hash;
for(var k in Hash.prototype ) away3dlite.loaders.utils.MaterialLibrary.prototype[k] = Hash.prototype[k];
away3dlite.loaders.utils.MaterialLibrary.prototype.addMaterial = function(name) {
	$s.push("away3dlite.loaders.utils.MaterialLibrary::addMaterial");
	var $spos = $s.length;
	if(this.exists(name)) {
		var $tmp = this.get(name);
		$s.pop();
		return $tmp;
	}
	this.length++;
	var materialData = new away3dlite.loaders.data.MaterialData();
	this.set(materialData.name = name,materialData);
	{
		$s.pop();
		return materialData;
	}
	$s.pop();
}
away3dlite.loaders.utils.MaterialLibrary.prototype.getMaterial = function(name) {
	$s.push("away3dlite.loaders.utils.MaterialLibrary::getMaterial");
	var $spos = $s.length;
	var ret = this.get(name);
	if(ret == null) away3dlite.core.utils.Debug.warning(("Material '" + name) + "' does not exist",{ fileName : "MaterialLibrary.hx", lineNumber : 57, className : "away3dlite.loaders.utils.MaterialLibrary", methodName : "getMaterial"});
	{
		$s.pop();
		return ret;
	}
	$s.pop();
}
away3dlite.loaders.utils.MaterialLibrary.prototype.length = null;
away3dlite.loaders.utils.MaterialLibrary.prototype.loadRequired = null;
away3dlite.loaders.utils.MaterialLibrary.prototype.texturePath = null;
away3dlite.loaders.utils.MaterialLibrary.prototype.texturesLoaded = function(loadQueue) {
	$s.push("away3dlite.loaders.utils.MaterialLibrary::texturesLoaded");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.loaders.utils.MaterialLibrary.prototype.__class__ = away3dlite.loaders.utils.MaterialLibrary;
away3dlite.loaders.data.FaceData = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.loaders.data.FaceData::new");
	var $spos = $s.length;
	null;
	$s.pop();
}}
away3dlite.loaders.data.FaceData.__name__ = ["away3dlite","loaders","data","FaceData"];
away3dlite.loaders.data.FaceData.prototype.materialData = null;
away3dlite.loaders.data.FaceData.prototype.uv0 = null;
away3dlite.loaders.data.FaceData.prototype.uv1 = null;
away3dlite.loaders.data.FaceData.prototype.uv2 = null;
away3dlite.loaders.data.FaceData.prototype.v0 = null;
away3dlite.loaders.data.FaceData.prototype.v1 = null;
away3dlite.loaders.data.FaceData.prototype.v2 = null;
away3dlite.loaders.data.FaceData.prototype.visible = null;
away3dlite.loaders.data.FaceData.prototype.__class__ = away3dlite.loaders.data.FaceData;
if(!away3dlite.core.clip) away3dlite.core.clip = {}
away3dlite.core.clip.Clipping = function(minX,maxX,minY,maxY,minZ,maxZ) { if( minX === $_ ) return; {
	$s.push("away3dlite.core.clip.Clipping::new");
	var $spos = $s.length;
	if(maxZ == null) maxZ = 10000;
	if(minZ == null) minZ = -10000;
	if(maxY == null) maxY = 10000;
	if(minY == null) minY = -10000;
	if(maxX == null) maxX = 10000;
	if(minX == null) minX = -10000;
	jsflash.events.EventDispatcher.apply(this,[]);
	this._localPointTL = new jsflash.geom.Point(0,0);
	this._localPointBR = new jsflash.geom.Point(0,0);
	this._globalPointTL = new jsflash.geom.Point(0,0);
	this._globalPointBR = new jsflash.geom.Point(0,0);
	this._screenVerticesCull = new Array();
	this._minX = minX;
	this._maxX = maxX;
	this._minY = minY;
	this._maxY = maxY;
	this._minZ = minZ;
	this._maxZ = maxZ;
	$s.pop();
}}
away3dlite.core.clip.Clipping.__name__ = ["away3dlite","core","clip","Clipping"];
away3dlite.core.clip.Clipping.__super__ = jsflash.events.EventDispatcher;
for(var k in jsflash.events.EventDispatcher.prototype ) away3dlite.core.clip.Clipping.prototype[k] = jsflash.events.EventDispatcher.prototype[k];
away3dlite.core.clip.Clipping.prototype._clippingClone = null;
away3dlite.core.clip.Clipping.prototype._clippingupdated = null;
away3dlite.core.clip.Clipping.prototype._cullCount = null;
away3dlite.core.clip.Clipping.prototype._cullTotal = null;
away3dlite.core.clip.Clipping.prototype._face = null;
away3dlite.core.clip.Clipping.prototype._faces = null;
away3dlite.core.clip.Clipping.prototype._globalPointBR = null;
away3dlite.core.clip.Clipping.prototype._globalPointTL = null;
away3dlite.core.clip.Clipping.prototype._index = null;
away3dlite.core.clip.Clipping.prototype._indexX = null;
away3dlite.core.clip.Clipping.prototype._indexY = null;
away3dlite.core.clip.Clipping.prototype._indexZ = null;
away3dlite.core.clip.Clipping.prototype._localPointBR = null;
away3dlite.core.clip.Clipping.prototype._localPointTL = null;
away3dlite.core.clip.Clipping.prototype._maX = null;
away3dlite.core.clip.Clipping.prototype._maY = null;
away3dlite.core.clip.Clipping.prototype._maxX = null;
away3dlite.core.clip.Clipping.prototype._maxY = null;
away3dlite.core.clip.Clipping.prototype._maxZ = null;
away3dlite.core.clip.Clipping.prototype._miX = null;
away3dlite.core.clip.Clipping.prototype._miY = null;
away3dlite.core.clip.Clipping.prototype._minX = null;
away3dlite.core.clip.Clipping.prototype._minY = null;
away3dlite.core.clip.Clipping.prototype._minZ = null;
away3dlite.core.clip.Clipping.prototype._screenVertices = null;
away3dlite.core.clip.Clipping.prototype._screenVerticesCull = null;
away3dlite.core.clip.Clipping.prototype._screenupdated = null;
away3dlite.core.clip.Clipping.prototype._stage = null;
away3dlite.core.clip.Clipping.prototype._stageHeight = null;
away3dlite.core.clip.Clipping.prototype._stageWidth = null;
away3dlite.core.clip.Clipping.prototype._uvtData = null;
away3dlite.core.clip.Clipping.prototype._view = null;
away3dlite.core.clip.Clipping.prototype.clone = function(object) {
	$s.push("away3dlite.core.clip.Clipping::clone");
	var $spos = $s.length;
	var clipping = ((object != null)?object:new away3dlite.core.clip.Clipping());
	clipping.set_minX(this.get_minX());
	clipping.set_minY(this.get_minY());
	clipping.set_minZ(this.get_minZ());
	clipping.set_maxX(this.get_maxX());
	clipping.set_maxY(this.get_maxY());
	clipping.set_maxZ(this.get_maxZ());
	{
		$s.pop();
		return clipping;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.collectFaces = function(mesh,faces) {
	$s.push("away3dlite.core.clip.Clipping::collectFaces");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.get_maxX = function() {
	$s.push("away3dlite.core.clip.Clipping::get_maxX");
	var $spos = $s.length;
	{
		var $tmp = this._maxX;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.get_maxY = function() {
	$s.push("away3dlite.core.clip.Clipping::get_maxY");
	var $spos = $s.length;
	{
		var $tmp = this._maxY;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.get_maxZ = function() {
	$s.push("away3dlite.core.clip.Clipping::get_maxZ");
	var $spos = $s.length;
	{
		var $tmp = this._maxZ;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.get_minX = function() {
	$s.push("away3dlite.core.clip.Clipping::get_minX");
	var $spos = $s.length;
	{
		var $tmp = this._minX;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.get_minY = function() {
	$s.push("away3dlite.core.clip.Clipping::get_minY");
	var $spos = $s.length;
	{
		var $tmp = this._minY;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.get_minZ = function() {
	$s.push("away3dlite.core.clip.Clipping::get_minZ");
	var $spos = $s.length;
	{
		var $tmp = this._minZ;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.maxX = null;
away3dlite.core.clip.Clipping.prototype.maxY = null;
away3dlite.core.clip.Clipping.prototype.maxZ = null;
away3dlite.core.clip.Clipping.prototype.minX = null;
away3dlite.core.clip.Clipping.prototype.minY = null;
away3dlite.core.clip.Clipping.prototype.minZ = null;
away3dlite.core.clip.Clipping.prototype.notifyClippingUpdate = function() {
	$s.push("away3dlite.core.clip.Clipping::notifyClippingUpdate");
	var $spos = $s.length;
	if(!this.hasEventListener("clippingUpdated")) {
		$s.pop();
		return;
	}
	if(this._clippingupdated == null) this._clippingupdated = new away3dlite.events.ClippingEvent("clippingUpdated",this);
	this.dispatchEvent(this._clippingupdated);
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.notifyScreenUpdate = function() {
	$s.push("away3dlite.core.clip.Clipping::notifyScreenUpdate");
	var $spos = $s.length;
	if(!this.hasEventListener("screenUpdated")) {
		$s.pop();
		return;
	}
	if(this._screenupdated == null) this._screenupdated = new away3dlite.events.ClippingEvent("screenUpdated",this);
	this.dispatchEvent(this._screenupdated);
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.onScreenUpdate = function(event) {
	$s.push("away3dlite.core.clip.Clipping::onScreenUpdate");
	var $spos = $s.length;
	this.notifyScreenUpdate();
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.screen = function(container,_loaderWidth,_loaderHeight) {
	$s.push("away3dlite.core.clip.Clipping::screen");
	var $spos = $s.length;
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.setView = function(view) {
	$s.push("away3dlite.core.clip.Clipping::setView");
	var $spos = $s.length;
	this._view = view;
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.set_maxX = function(value) {
	$s.push("away3dlite.core.clip.Clipping::set_maxX");
	var $spos = $s.length;
	if(this._maxX == value) {
		$s.pop();
		return value;
	}
	this._maxX = value;
	this.notifyClippingUpdate();
	{
		$s.pop();
		return value;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.set_maxY = function(value) {
	$s.push("away3dlite.core.clip.Clipping::set_maxY");
	var $spos = $s.length;
	if(this._maxY == value) {
		$s.pop();
		return value;
	}
	this._maxY = value;
	this.notifyClippingUpdate();
	{
		$s.pop();
		return value;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.set_maxZ = function(value) {
	$s.push("away3dlite.core.clip.Clipping::set_maxZ");
	var $spos = $s.length;
	if(this._maxZ == value) {
		$s.pop();
		return value;
	}
	this._maxZ = value;
	this.notifyClippingUpdate();
	{
		$s.pop();
		return value;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.set_minX = function(value) {
	$s.push("away3dlite.core.clip.Clipping::set_minX");
	var $spos = $s.length;
	if(this._minX == value) {
		$s.pop();
		return value;
	}
	this._minX = value;
	this.notifyClippingUpdate();
	{
		$s.pop();
		return value;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.set_minY = function(value) {
	$s.push("away3dlite.core.clip.Clipping::set_minY");
	var $spos = $s.length;
	if(this._minY == value) {
		$s.pop();
		return value;
	}
	this._minY = value;
	this.notifyClippingUpdate();
	{
		$s.pop();
		return value;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.set_minZ = function(value) {
	$s.push("away3dlite.core.clip.Clipping::set_minZ");
	var $spos = $s.length;
	if(this._minZ == value) {
		$s.pop();
		return value;
	}
	this._minZ = value;
	this.notifyClippingUpdate();
	{
		$s.pop();
		return value;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.toString = function() {
	$s.push("away3dlite.core.clip.Clipping::toString");
	var $spos = $s.length;
	{
		var $tmp = ((((((((((("{minX:" + this.get_minX()) + " maxX:") + this.get_maxX()) + " minY:") + this.get_minY()) + " maxY:") + this.get_maxY()) + " minZ:") + this.get_minZ()) + " maxZ:") + this.get_maxZ()) + "}";
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.clip.Clipping.prototype.__class__ = away3dlite.core.clip.Clipping;
if(typeof js=='undefined') js = {}
js.Boot = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	$s.push("js.Boot::__unhtml");
	var $spos = $s.length;
	{
		var $tmp = s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.Boot.__trace = function(v,i) {
	$s.push("js.Boot::__trace");
	var $spos = $s.length;
	var msg = (i != null?((i.fileName + ":") + i.lineNumber) + ": ":"");
	msg += js.Boot.__unhtml(js.Boot.__string_rec(v,"")) + "<br/>";
	var d = document.getElementById("haxe:trace");
	if(d == null) alert("No haxe:trace element defined\n" + msg);
	else d.innerHTML += msg;
	$s.pop();
}
js.Boot.__clear_trace = function() {
	$s.push("js.Boot::__clear_trace");
	var $spos = $s.length;
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = "";
	else null;
	$s.pop();
}
js.Boot.__closure = function(o,f) {
	$s.push("js.Boot::__closure");
	var $spos = $s.length;
	var m = o[f];
	if(m == null) {
		$s.pop();
		return null;
	}
	var f1 = function() {
		$s.push("js.Boot::__closure@67");
		var $spos = $s.length;
		{
			var $tmp = m.apply(o,arguments);
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	f1.scope = o;
	f1.method = m;
	{
		$s.pop();
		return f1;
	}
	$s.pop();
}
js.Boot.__string_rec = function(o,s) {
	$s.push("js.Boot::__string_rec");
	var $spos = $s.length;
	if(o == null) {
		$s.pop();
		return "null";
	}
	if(s.length >= 5) {
		$s.pop();
		return "<...>";
	}
	var t = typeof(o);
	if(t == "function" && (o.__name__ != null || o.__ename__ != null)) t = "object";
	switch(t) {
	case "object":{
		if(o instanceof Array) {
			if(o.__enum__ != null) {
				if(o.length == 2) {
					var $tmp = o[0];
					$s.pop();
					return $tmp;
				}
				var str = o[0] + "(";
				s += "\t";
				{
					var _g1 = 2, _g = o.length;
					while(_g1 < _g) {
						var i = _g1++;
						if(i != 2) str += "," + js.Boot.__string_rec(o[i],s);
						else str += js.Boot.__string_rec(o[i],s);
					}
				}
				{
					var $tmp = str + ")";
					$s.pop();
					return $tmp;
				}
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			{
				var _g = 0;
				while(_g < l) {
					var i1 = _g++;
					str += ((i1 > 0?",":"")) + js.Boot.__string_rec(o[i1],s);
				}
			}
			str += "]";
			{
				$s.pop();
				return str;
			}
		}
		var tostr;
		try {
			tostr = o.toString;
		}
		catch( $e2 ) {
			{
				var e = $e2;
				{
					$e = [];
					while($s.length >= $spos) $e.unshift($s.pop());
					$s.push($e[0]);
					{
						$s.pop();
						return "???";
					}
				}
			}
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") {
				$s.pop();
				return s2;
			}
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = (o.hasOwnProperty != null);
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) continue;
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__") continue;
		if(str.length != 2) str += ", \n";
		str += ((s + k) + " : ") + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += ("\n" + s) + "}";
		{
			$s.pop();
			return str;
		}
	}break;
	case "function":{
		{
			$s.pop();
			return "<function>";
		}
	}break;
	case "string":{
		{
			$s.pop();
			return o;
		}
	}break;
	default:{
		{
			var $tmp = String(o);
			$s.pop();
			return $tmp;
		}
	}break;
	}
	$s.pop();
}
js.Boot.__interfLoop = function(cc,cl) {
	$s.push("js.Boot::__interfLoop");
	var $spos = $s.length;
	if(cc == null) {
		$s.pop();
		return false;
	}
	if(cc == cl) {
		$s.pop();
		return true;
	}
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) {
				$s.pop();
				return true;
			}
		}
	}
	{
		var $tmp = js.Boot.__interfLoop(cc.__super__,cl);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.Boot.__instanceof = function(o,cl) {
	$s.push("js.Boot::__instanceof");
	var $spos = $s.length;
	try {
		if(o instanceof cl) {
			if(cl == Array) {
				var $tmp = (o.__enum__ == null);
				$s.pop();
				return $tmp;
			}
			{
				$s.pop();
				return true;
			}
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) {
			$s.pop();
			return true;
		}
	}
	catch( $e3 ) {
		{
			var e = $e3;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				if(cl == null) {
					$s.pop();
					return false;
				}
			}
		}
	}
	switch(cl) {
	case Int:{
		{
			var $tmp = Math.ceil(o%2147483648.0) === o;
			$s.pop();
			return $tmp;
		}
	}break;
	case Float:{
		{
			var $tmp = typeof(o) == "number";
			$s.pop();
			return $tmp;
		}
	}break;
	case Bool:{
		{
			var $tmp = o === true || o === false;
			$s.pop();
			return $tmp;
		}
	}break;
	case String:{
		{
			var $tmp = typeof(o) == "string";
			$s.pop();
			return $tmp;
		}
	}break;
	case Dynamic:{
		{
			$s.pop();
			return true;
		}
	}break;
	default:{
		if(o == null) {
			$s.pop();
			return false;
		}
		{
			var $tmp = o.__enum__ == cl || (cl == Class && o.__name__ != null) || (cl == Enum && o.__ename__ != null);
			$s.pop();
			return $tmp;
		}
	}break;
	}
	$s.pop();
}
js.Boot.__init = function() {
	$s.push("js.Boot::__init");
	var $spos = $s.length;
	js.Lib.isIE = (typeof document!='undefined' && document.all != null && typeof window!='undefined' && window.opera == null);
	js.Lib.isOpera = (typeof window!='undefined' && window.opera != null);
	Array.prototype.copy = Array.prototype.slice;
	Array.prototype.insert = function(i,x) {
		$s.push("js.Boot::__init@205");
		var $spos = $s.length;
		this.splice(i,0,x);
		$s.pop();
	}
	Array.prototype.remove = (Array.prototype.indexOf?function(obj) {
		$s.push("js.Boot::__init@208");
		var $spos = $s.length;
		var idx = this.indexOf(obj);
		if(idx == -1) {
			$s.pop();
			return false;
		}
		this.splice(idx,1);
		{
			$s.pop();
			return true;
		}
		$s.pop();
	}:function(obj) {
		$s.push("js.Boot::__init@213");
		var $spos = $s.length;
		var i = 0;
		var l = this.length;
		while(i < l) {
			if(this[i] == obj) {
				this.splice(i,1);
				{
					$s.pop();
					return true;
				}
			}
			i++;
		}
		{
			$s.pop();
			return false;
		}
		$s.pop();
	});
	Array.prototype.iterator = function() {
		$s.push("js.Boot::__init@225");
		var $spos = $s.length;
		{
			var $tmp = { cur : 0, arr : this, hasNext : function() {
				$s.push("js.Boot::__init@225@229");
				var $spos = $s.length;
				{
					var $tmp = this.cur < this.arr.length;
					$s.pop();
					return $tmp;
				}
				$s.pop();
			}, next : function() {
				$s.push("js.Boot::__init@225@232");
				var $spos = $s.length;
				{
					var $tmp = this.arr[this.cur++];
					$s.pop();
					return $tmp;
				}
				$s.pop();
			}}
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	var cca = String.prototype.charCodeAt;
	String.prototype.cca = cca;
	String.prototype.charCodeAt = function(i) {
		$s.push("js.Boot::__init@239");
		var $spos = $s.length;
		var x = cca.call(this,i);
		if(isNaN(x)) {
			$s.pop();
			return null;
		}
		{
			$s.pop();
			return x;
		}
		$s.pop();
	}
	var oldsub = String.prototype.substr;
	String.prototype.substr = function(pos,len) {
		$s.push("js.Boot::__init@246");
		var $spos = $s.length;
		if(pos != null && pos != 0 && len != null && len < 0) {
			$s.pop();
			return "";
		}
		if(len == null) len = this.length;
		if(pos < 0) {
			pos = this.length + pos;
			if(pos < 0) pos = 0;
		}
		else if(len < 0) {
			len = (this.length + len) - pos;
		}
		{
			var $tmp = oldsub.apply(this,[pos,len]);
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	$closure = js.Boot.__closure;
	$s.pop();
}
js.Boot.prototype.__class__ = js.Boot;
away3dlite.core.base.SortType = function() { }
away3dlite.core.base.SortType.__name__ = ["away3dlite","core","base","SortType"];
away3dlite.core.base.SortType.prototype.__class__ = away3dlite.core.base.SortType;
haxe.StackItem = { __ename__ : ["haxe","StackItem"], __constructs__ : ["CFunction","Module","FilePos","Method","Lambda"] }
haxe.StackItem.CFunction = ["CFunction",0];
haxe.StackItem.CFunction.toString = $estr;
haxe.StackItem.CFunction.__enum__ = haxe.StackItem;
haxe.StackItem.FilePos = function(s,file,line) { var $x = ["FilePos",2,s,file,line]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.StackItem.Lambda = function(v) { var $x = ["Lambda",4,v]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.StackItem.Method = function(classname,method) { var $x = ["Method",3,classname,method]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.StackItem.Module = function(m) { var $x = ["Module",1,m]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.Stack = function() { }
haxe.Stack.__name__ = ["haxe","Stack"];
haxe.Stack.callStack = function() {
	$s.push("haxe.Stack::callStack");
	var $spos = $s.length;
	{
		var $tmp = haxe.Stack.makeStack("$s");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.Stack.exceptionStack = function() {
	$s.push("haxe.Stack::exceptionStack");
	var $spos = $s.length;
	{
		var $tmp = haxe.Stack.makeStack("$e");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.Stack.toString = function(stack) {
	$s.push("haxe.Stack::toString");
	var $spos = $s.length;
	var b = new StringBuf();
	{
		var _g = 0;
		while(_g < stack.length) {
			var s = stack[_g];
			++_g;
			b.b[b.b.length] = "\nCalled from ";
			haxe.Stack.itemToString(b,s);
		}
	}
	{
		var $tmp = b.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.Stack.itemToString = function(b,s) {
	$s.push("haxe.Stack::itemToString");
	var $spos = $s.length;
	var $e = (s);
	switch( $e[1] ) {
	case 0:
	{
		b.b[b.b.length] = "a C function";
	}break;
	case 1:
	var m = $e[2];
	{
		b.b[b.b.length] = "module ";
		b.b[b.b.length] = m;
	}break;
	case 2:
	var line = $e[4], file = $e[3], s1 = $e[2];
	{
		if(s1 != null) {
			haxe.Stack.itemToString(b,s1);
			b.b[b.b.length] = " (";
		}
		b.b[b.b.length] = file;
		b.b[b.b.length] = " line ";
		b.b[b.b.length] = line;
		if(s1 != null) b.b[b.b.length] = ")";
	}break;
	case 3:
	var meth = $e[3], cname = $e[2];
	{
		b.b[b.b.length] = cname;
		b.b[b.b.length] = ".";
		b.b[b.b.length] = meth;
	}break;
	case 4:
	var n = $e[2];
	{
		b.b[b.b.length] = "local function #";
		b.b[b.b.length] = n;
	}break;
	}
	$s.pop();
}
haxe.Stack.makeStack = function(s) {
	$s.push("haxe.Stack::makeStack");
	var $spos = $s.length;
	var a = (function($this) {
		var $r;
		try {
			$r = eval(s);
		}
		catch( $e4 ) {
			{
				var e = $e4;
				$r = (function($this) {
					var $r;
					$e = [];
					while($s.length >= $spos) $e.unshift($s.pop());
					$s.push($e[0]);
					$r = [];
					return $r;
				}($this));
			}
		}
		return $r;
	}(this));
	var m = new Array();
	{
		var _g1 = 0, _g = a.length - (s == "$s"?2:0);
		while(_g1 < _g) {
			var i = _g1++;
			var d = a[i].split("::");
			m.unshift(haxe.StackItem.Method(d[0],d[1]));
		}
	}
	{
		$s.pop();
		return m;
	}
	$s.pop();
}
haxe.Stack.prototype.__class__ = haxe.Stack;
jsflash.events.MouseEvent = function(type,bubbles,cancelable,in_localX,in_localY,in_relatedObject,in_ctrlKey,in_altKey,in_shiftKey,in_buttonDown,in_delta) { if( type === $_ ) return; {
	$s.push("jsflash.events.MouseEvent::new");
	var $spos = $s.length;
	jsflash.events.Event.apply(this,[type,bubbles,cancelable]);
	this.shiftKey = (in_shiftKey == null?false:in_shiftKey);
	this.altKey = (in_altKey == null?false:in_altKey);
	this.ctrlKey = (in_ctrlKey == null?false:in_ctrlKey);
	bubbles = (in_buttonDown == null?false:in_buttonDown);
	this.relatedObject = in_relatedObject;
	this.delta = (in_delta == null?0:in_delta);
	this.localX = (in_localX == null?0:in_localX);
	this.localY = (in_localY == null?0:in_localY);
	this.buttonDown = (in_buttonDown == null?false:in_buttonDown);
	$s.pop();
}}
jsflash.events.MouseEvent.__name__ = ["jsflash","events","MouseEvent"];
jsflash.events.MouseEvent.__super__ = jsflash.events.Event;
for(var k in jsflash.events.Event.prototype ) jsflash.events.MouseEvent.prototype[k] = jsflash.events.Event.prototype[k];
jsflash.events.MouseEvent.prototype.altKey = null;
jsflash.events.MouseEvent.prototype.buttonDown = null;
jsflash.events.MouseEvent.prototype.ctrlKey = null;
jsflash.events.MouseEvent.prototype.delta = null;
jsflash.events.MouseEvent.prototype.localX = null;
jsflash.events.MouseEvent.prototype.localY = null;
jsflash.events.MouseEvent.prototype.relatedObject = null;
jsflash.events.MouseEvent.prototype.shiftKey = null;
jsflash.events.MouseEvent.prototype.stageX = null;
jsflash.events.MouseEvent.prototype.stageY = null;
jsflash.events.MouseEvent.prototype.updateAfterEvent = function() {
	$s.push("jsflash.events.MouseEvent::updateAfterEvent");
	var $spos = $s.length;
	null;
	$s.pop();
}
jsflash.events.MouseEvent.prototype.__class__ = jsflash.events.MouseEvent;
ValueType = { __ename__ : ["ValueType"], __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] }
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
Type = function() { }
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	$s.push("Type::getClass");
	var $spos = $s.length;
	if(o == null) {
		$s.pop();
		return null;
	}
	if(o.__enum__ != null) {
		$s.pop();
		return null;
	}
	{
		var $tmp = o.__class__;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.getEnum = function(o) {
	$s.push("Type::getEnum");
	var $spos = $s.length;
	if(o == null) {
		$s.pop();
		return null;
	}
	{
		var $tmp = o.__enum__;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.getSuperClass = function(c) {
	$s.push("Type::getSuperClass");
	var $spos = $s.length;
	{
		var $tmp = c.__super__;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.getClassName = function(c) {
	$s.push("Type::getClassName");
	var $spos = $s.length;
	if(c == null) {
		$s.pop();
		return null;
	}
	var a = c.__name__;
	{
		var $tmp = a.join(".");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.getEnumName = function(e) {
	$s.push("Type::getEnumName");
	var $spos = $s.length;
	var a = e.__ename__;
	{
		var $tmp = a.join(".");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.resolveClass = function(name) {
	$s.push("Type::resolveClass");
	var $spos = $s.length;
	var cl;
	try {
		cl = eval(name);
	}
	catch( $e5 ) {
		{
			var e = $e5;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				cl = null;
			}
		}
	}
	if(cl == null || cl.__name__ == null) {
		$s.pop();
		return null;
	}
	{
		$s.pop();
		return cl;
	}
	$s.pop();
}
Type.resolveEnum = function(name) {
	$s.push("Type::resolveEnum");
	var $spos = $s.length;
	var e;
	try {
		e = eval(name);
	}
	catch( $e6 ) {
		{
			var err = $e6;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				e = null;
			}
		}
	}
	if(e == null || e.__ename__ == null) {
		$s.pop();
		return null;
	}
	{
		$s.pop();
		return e;
	}
	$s.pop();
}
Type.createInstance = function(cl,args) {
	$s.push("Type::createInstance");
	var $spos = $s.length;
	if(args.length <= 3) {
		var $tmp = new cl(args[0],args[1],args[2]);
		$s.pop();
		return $tmp;
	}
	if(args.length > 8) throw "Too many arguments";
	{
		var $tmp = new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.createEmptyInstance = function(cl) {
	$s.push("Type::createEmptyInstance");
	var $spos = $s.length;
	{
		var $tmp = new cl($_);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.createEnum = function(e,constr,params) {
	$s.push("Type::createEnum");
	var $spos = $s.length;
	var f = Reflect.field(e,constr);
	if(f == null) throw "No such constructor " + constr;
	if(Reflect.isFunction(f)) {
		if(params == null) throw ("Constructor " + constr) + " need parameters";
		{
			var $tmp = f.apply(e,params);
			$s.pop();
			return $tmp;
		}
	}
	if(params != null && params.length != 0) throw ("Constructor " + constr) + " does not need parameters";
	{
		$s.pop();
		return f;
	}
	$s.pop();
}
Type.createEnumIndex = function(e,index,params) {
	$s.push("Type::createEnumIndex");
	var $spos = $s.length;
	var c = Type.getEnumConstructs(e)[index];
	if(c == null) throw index + " is not a valid enum constructor index";
	{
		var $tmp = Type.createEnum(e,c,params);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.getInstanceFields = function(c) {
	$s.push("Type::getInstanceFields");
	var $spos = $s.length;
	var a = Reflect.fields(c.prototype);
	a.remove("__class__");
	{
		$s.pop();
		return a;
	}
	$s.pop();
}
Type.getClassFields = function(c) {
	$s.push("Type::getClassFields");
	var $spos = $s.length;
	var a = Reflect.fields(c);
	a.remove("__name__");
	a.remove("__interfaces__");
	a.remove("__super__");
	a.remove("prototype");
	{
		$s.pop();
		return a;
	}
	$s.pop();
}
Type.getEnumConstructs = function(e) {
	$s.push("Type::getEnumConstructs");
	var $spos = $s.length;
	{
		var $tmp = e.__constructs__;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type["typeof"] = function(v) {
	$s.push("Type::typeof");
	var $spos = $s.length;
	switch(typeof(v)) {
	case "boolean":{
		{
			var $tmp = ValueType.TBool;
			$s.pop();
			return $tmp;
		}
	}break;
	case "string":{
		{
			var $tmp = ValueType.TClass(String);
			$s.pop();
			return $tmp;
		}
	}break;
	case "number":{
		if(Math.ceil(v) == v % 2147483648.0) {
			var $tmp = ValueType.TInt;
			$s.pop();
			return $tmp;
		}
		{
			var $tmp = ValueType.TFloat;
			$s.pop();
			return $tmp;
		}
	}break;
	case "object":{
		if(v == null) {
			var $tmp = ValueType.TNull;
			$s.pop();
			return $tmp;
		}
		var e = v.__enum__;
		if(e != null) {
			var $tmp = ValueType.TEnum(e);
			$s.pop();
			return $tmp;
		}
		var c = v.__class__;
		if(c != null) {
			var $tmp = ValueType.TClass(c);
			$s.pop();
			return $tmp;
		}
		{
			var $tmp = ValueType.TObject;
			$s.pop();
			return $tmp;
		}
	}break;
	case "function":{
		if(v.__name__ != null) {
			var $tmp = ValueType.TObject;
			$s.pop();
			return $tmp;
		}
		{
			var $tmp = ValueType.TFunction;
			$s.pop();
			return $tmp;
		}
	}break;
	case "undefined":{
		{
			var $tmp = ValueType.TNull;
			$s.pop();
			return $tmp;
		}
	}break;
	default:{
		{
			var $tmp = ValueType.TUnknown;
			$s.pop();
			return $tmp;
		}
	}break;
	}
	$s.pop();
}
Type.enumEq = function(a,b) {
	$s.push("Type::enumEq");
	var $spos = $s.length;
	if(a == b) {
		$s.pop();
		return true;
	}
	try {
		if(a[0] != b[0]) {
			$s.pop();
			return false;
		}
		{
			var _g1 = 2, _g = a.length;
			while(_g1 < _g) {
				var i = _g1++;
				if(!Type.enumEq(a[i],b[i])) {
					$s.pop();
					return false;
				}
			}
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) {
			$s.pop();
			return false;
		}
	}
	catch( $e7 ) {
		{
			var e = $e7;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				{
					$s.pop();
					return false;
				}
			}
		}
	}
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
Type.enumConstructor = function(e) {
	$s.push("Type::enumConstructor");
	var $spos = $s.length;
	{
		var $tmp = e[0];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.enumParameters = function(e) {
	$s.push("Type::enumParameters");
	var $spos = $s.length;
	{
		var $tmp = e.slice(2);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.enumIndex = function(e) {
	$s.push("Type::enumIndex");
	var $spos = $s.length;
	{
		var $tmp = e[1];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.prototype.__class__ = Type;
js.Lib = function() { }
js.Lib.__name__ = ["js","Lib"];
js.Lib.isIE = null;
js.Lib.isOpera = null;
js.Lib.document = null;
js.Lib.window = null;
js.Lib.alert = function(v) {
	$s.push("js.Lib::alert");
	var $spos = $s.length;
	alert(js.Boot.__string_rec(v,""));
	$s.pop();
}
js.Lib.eval = function(code) {
	$s.push("js.Lib::eval");
	var $spos = $s.length;
	{
		var $tmp = eval(code);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.Lib.setErrorHandler = function(f) {
	$s.push("js.Lib::setErrorHandler");
	var $spos = $s.length;
	js.Lib.onerror = f;
	$s.pop();
}
js.Lib.prototype.__class__ = js.Lib;
if(!jsflash.xml) jsflash.xml = {}
jsflash.xml.XML = function(data) { if( data === $_ ) return; {
	$s.push("jsflash.xml.XML::new");
	var $spos = $s.length;
	throw "I don't think this will work";
	$s.pop();
}}
jsflash.xml.XML.__name__ = ["jsflash","xml","XML"];
jsflash.xml.XML.prototype.__class__ = jsflash.xml.XML;
if(!away3dlite["namespace"]) away3dlite["namespace"] = {}
away3dlite.namespace.Arcane = function() { }
away3dlite.namespace.Arcane.__name__ = ["away3dlite","namespace","Arcane"];
away3dlite.namespace.Arcane.arcaneNS = function(obj) {
	$s.push("away3dlite.namespace.Arcane::arcaneNS");
	var $spos = $s.length;
	{
		$s.pop();
		return obj;
	}
	$s.pop();
}
away3dlite.namespace.Arcane.arcane_ns = function(obj) {
	$s.push("away3dlite.namespace.Arcane::arcane_ns");
	var $spos = $s.length;
	{
		$s.pop();
		return obj;
	}
	$s.pop();
}
away3dlite.namespace.Arcane.prototype.__class__ = away3dlite.namespace.Arcane;
if(!away3dlite.sprites) away3dlite.sprites = {}
away3dlite.sprites.Sprite3D = function(material,scale) { if( material === $_ ) return; {
	$s.push("away3dlite.sprites.Sprite3D::new");
	var $spos = $s.length;
	if(scale == null) scale = 1.0;
	this.indices = new Array();
	this.uvtData = new Array();
	this._vertices = new Array();
	this._position = new jsflash.geom.Vector3D();
	this.x = this.y = this.z = 0;
	this.set_material(material);
	this.set_scale(scale);
	this.alignmentType = "viewplane";
	away3dlite.haxeutils.VectorUtils.push3(this.indices,0,1,2);
	this.indices.push(3);
	away3dlite.haxeutils.VectorUtils.push3(this.uvtData,0,0,0);
	away3dlite.haxeutils.VectorUtils.push3(this.uvtData,0,1,0);
	away3dlite.haxeutils.VectorUtils.push3(this.uvtData,1,1,0);
	away3dlite.haxeutils.VectorUtils.push3(this.uvtData,1,0,0);
	this.updateVertices();
	$s.pop();
}}
away3dlite.sprites.Sprite3D.__name__ = ["away3dlite","sprites","Sprite3D"];
away3dlite.sprites.Sprite3D.prototype._height = null;
away3dlite.sprites.Sprite3D.prototype._material = null;
away3dlite.sprites.Sprite3D.prototype._position = null;
away3dlite.sprites.Sprite3D.prototype._scale = null;
away3dlite.sprites.Sprite3D.prototype._vertices = null;
away3dlite.sprites.Sprite3D.prototype._verticesDirty = null;
away3dlite.sprites.Sprite3D.prototype._width = null;
away3dlite.sprites.Sprite3D.prototype.alignmentType = null;
away3dlite.sprites.Sprite3D.prototype.clone = function(object) {
	$s.push("away3dlite.sprites.Sprite3D::clone");
	var $spos = $s.length;
	var sprite3D = (jsflash.Lib["as"](object,away3dlite.sprites.Sprite3D));
	if(sprite3D == null) sprite3D = new away3dlite.sprites.Sprite3D();
	sprite3D.x = this.x;
	sprite3D.y = this.y;
	sprite3D.z = this.z;
	sprite3D.set_scale(this.get_scale());
	sprite3D.set_width(this._width);
	sprite3D.set_height(this._height);
	sprite3D.set_material(this.get_material());
	{
		$s.pop();
		return sprite3D;
	}
	$s.pop();
}
away3dlite.sprites.Sprite3D.prototype.get_height = function() {
	$s.push("away3dlite.sprites.Sprite3D::get_height");
	var $spos = $s.length;
	if(Math.isNaN(this._height)) {
		$s.pop();
		return 100;
	}
	{
		var $tmp = this._height;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.sprites.Sprite3D.prototype.get_material = function() {
	$s.push("away3dlite.sprites.Sprite3D::get_material");
	var $spos = $s.length;
	{
		var $tmp = this._material;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.sprites.Sprite3D.prototype.get_position = function() {
	$s.push("away3dlite.sprites.Sprite3D::get_position");
	var $spos = $s.length;
	this._position.set_x(this.x);
	this._position.set_y(this.y);
	this._position.set_z(this.z);
	{
		var $tmp = this._position;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.sprites.Sprite3D.prototype.get_scale = function() {
	$s.push("away3dlite.sprites.Sprite3D::get_scale");
	var $spos = $s.length;
	{
		var $tmp = this._scale;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.sprites.Sprite3D.prototype.get_vertices = function() {
	$s.push("away3dlite.sprites.Sprite3D::get_vertices");
	var $spos = $s.length;
	if(this._verticesDirty) this.updateVertices();
	{
		var $tmp = this._vertices;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.sprites.Sprite3D.prototype.get_width = function() {
	$s.push("away3dlite.sprites.Sprite3D::get_width");
	var $spos = $s.length;
	if(Math.isNaN(this._width)) {
		$s.pop();
		return 100;
	}
	{
		var $tmp = this._width;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.sprites.Sprite3D.prototype.height = null;
away3dlite.sprites.Sprite3D.prototype.index = null;
away3dlite.sprites.Sprite3D.prototype.indices = null;
away3dlite.sprites.Sprite3D.prototype.material = null;
away3dlite.sprites.Sprite3D.prototype.position = null;
away3dlite.sprites.Sprite3D.prototype.scale = null;
away3dlite.sprites.Sprite3D.prototype.set_height = function(val) {
	$s.push("away3dlite.sprites.Sprite3D::set_height");
	var $spos = $s.length;
	if(this._height == val) {
		$s.pop();
		return val;
	}
	this._height = val;
	this._verticesDirty = true;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.sprites.Sprite3D.prototype.set_material = function(val) {
	$s.push("away3dlite.sprites.Sprite3D::set_material");
	var $spos = $s.length;
	val = ((val != null)?val:new away3dlite.materials.WireColorMaterial());
	if(this._material == val) {
		$s.pop();
		return val;
	}
	this._material = val;
	if(js.Boot.__instanceof(this._material,away3dlite.materials.BitmapMaterial)) {
		var bitmapMaterial = jsflash.Lib["as"](this._material,away3dlite.materials.BitmapMaterial);
		if(Math.isNaN(this._width)) this.set_width(bitmapMaterial.width);
		if(Math.isNaN(this._height)) this.set_height(bitmapMaterial.get_height());
	}
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.sprites.Sprite3D.prototype.set_scale = function(val) {
	$s.push("away3dlite.sprites.Sprite3D::set_scale");
	var $spos = $s.length;
	if(this._scale == val) {
		$s.pop();
		return val;
	}
	this._scale = val;
	this._verticesDirty = true;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.sprites.Sprite3D.prototype.set_width = function(val) {
	$s.push("away3dlite.sprites.Sprite3D::set_width");
	var $spos = $s.length;
	if(this._width == val) {
		$s.pop();
		return val;
	}
	this._width = val;
	this._verticesDirty = true;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.sprites.Sprite3D.prototype.updateVertices = function() {
	$s.push("away3dlite.sprites.Sprite3D::updateVertices");
	var $spos = $s.length;
	this._verticesDirty = false;
	away3dlite.haxeutils.VectorUtils.push3(this._vertices,(-this._width * this._scale) / 2,(-this._height * this._scale) / 2,0);
	away3dlite.haxeutils.VectorUtils.push3(this._vertices,(-this._width * this._scale) / 2,(this._height * this._scale) / 2,0);
	away3dlite.haxeutils.VectorUtils.push3(this._vertices,(this._width * this._scale) / 2,(this._height * this._scale) / 2,0);
	away3dlite.haxeutils.VectorUtils.push3(this._vertices,(this._width * this._scale) / 2,(-this._height * this._scale) / 2,0);
	$s.pop();
}
away3dlite.sprites.Sprite3D.prototype.uvtData = null;
away3dlite.sprites.Sprite3D.prototype.vertices = null;
away3dlite.sprites.Sprite3D.prototype.width = null;
away3dlite.sprites.Sprite3D.prototype.x = null;
away3dlite.sprites.Sprite3D.prototype.y = null;
away3dlite.sprites.Sprite3D.prototype.z = null;
away3dlite.sprites.Sprite3D.prototype.__class__ = away3dlite.sprites.Sprite3D;
Reflect = function() { }
Reflect.__name__ = ["Reflect"];
Reflect.hasField = function(o,field) {
	$s.push("Reflect::hasField");
	var $spos = $s.length;
	if(o.hasOwnProperty != null) {
		var $tmp = o.hasOwnProperty(field);
		$s.pop();
		return $tmp;
	}
	var arr = Reflect.fields(o);
	{ var $it8 = arr.iterator();
	while( $it8.hasNext() ) { var t = $it8.next();
	if(t == field) {
		$s.pop();
		return true;
	}
	}}
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
Reflect.field = function(o,field) {
	$s.push("Reflect::field");
	var $spos = $s.length;
	var v = null;
	try {
		v = o[field];
	}
	catch( $e9 ) {
		{
			var e = $e9;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				null;
			}
		}
	}
	{
		$s.pop();
		return v;
	}
	$s.pop();
}
Reflect.setField = function(o,field,value) {
	$s.push("Reflect::setField");
	var $spos = $s.length;
	o[field] = value;
	$s.pop();
}
Reflect.callMethod = function(o,func,args) {
	$s.push("Reflect::callMethod");
	var $spos = $s.length;
	{
		var $tmp = func.apply(o,args);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Reflect.fields = function(o) {
	$s.push("Reflect::fields");
	var $spos = $s.length;
	if(o == null) {
		var $tmp = new Array();
		$s.pop();
		return $tmp;
	}
	var a = new Array();
	if(o.hasOwnProperty) {
		
					for(var i in o)
						if( o.hasOwnProperty(i) )
							a.push(i);
				;
	}
	else {
		var t;
		try {
			t = o.__proto__;
		}
		catch( $e10 ) {
			{
				var e = $e10;
				{
					$e = [];
					while($s.length >= $spos) $e.unshift($s.pop());
					$s.push($e[0]);
					t = null;
				}
			}
		}
		if(t != null) o.__proto__ = null;
		
					for(var i in o)
						if( i != "__proto__" )
							a.push(i);
				;
		if(t != null) o.__proto__ = t;
	}
	{
		$s.pop();
		return a;
	}
	$s.pop();
}
Reflect.isFunction = function(f) {
	$s.push("Reflect::isFunction");
	var $spos = $s.length;
	{
		var $tmp = typeof(f) == "function" && f.__name__ == null;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Reflect.compare = function(a,b) {
	$s.push("Reflect::compare");
	var $spos = $s.length;
	{
		var $tmp = ((a == b)?0:((((a) > (b))?1:-1)));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Reflect.compareMethods = function(f1,f2) {
	$s.push("Reflect::compareMethods");
	var $spos = $s.length;
	if(f1 == f2) {
		$s.pop();
		return true;
	}
	if(!Reflect.isFunction(f1) || !Reflect.isFunction(f2)) {
		$s.pop();
		return false;
	}
	{
		var $tmp = f1.scope == f2.scope && f1.method == f2.method && f1.method != null;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Reflect.isObject = function(v) {
	$s.push("Reflect::isObject");
	var $spos = $s.length;
	if(v == null) {
		$s.pop();
		return false;
	}
	var t = typeof(v);
	{
		var $tmp = (t == "string" || (t == "object" && !v.__enum__) || (t == "function" && v.__name__ != null));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Reflect.deleteField = function(o,f) {
	$s.push("Reflect::deleteField");
	var $spos = $s.length;
	if(!Reflect.hasField(o,f)) {
		$s.pop();
		return false;
	}
	delete(o[f]);
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
Reflect.copy = function(o) {
	$s.push("Reflect::copy");
	var $spos = $s.length;
	var o2 = { }
	{
		var _g = 0, _g1 = Reflect.fields(o);
		while(_g < _g1.length) {
			var f = _g1[_g];
			++_g;
			o2[f] = Reflect.field(o,f);
		}
	}
	{
		$s.pop();
		return o2;
	}
	$s.pop();
}
Reflect.makeVarArgs = function(f) {
	$s.push("Reflect::makeVarArgs");
	var $spos = $s.length;
	{
		var $tmp = function() {
			$s.push("Reflect::makeVarArgs@378");
			var $spos = $s.length;
			var a = new Array();
			{
				var _g1 = 0, _g = arguments.length;
				while(_g1 < _g) {
					var i = _g1++;
					a.push(arguments[i]);
				}
			}
			{
				var $tmp = f(a);
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Reflect.prototype.__class__ = Reflect;
away3dlite.core.utils.Cast = function() { }
away3dlite.core.utils.Cast.__name__ = ["away3dlite","core","utils","Cast"];
away3dlite.core.utils.Cast.string = function(data) {
	$s.push("away3dlite.core.utils.Cast::string");
	var $spos = $s.length;
	if(js.Boot.__instanceof(data,Class)) data = new data();
	if(js.Boot.__instanceof(data,String)) {
		$s.pop();
		return data;
	}
	{
		var $tmp = new String(data);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.utils.Cast.bytearray = function(data) {
	$s.push("away3dlite.core.utils.Cast::bytearray");
	var $spos = $s.length;
	if(js.Boot.__instanceof(data,Class)) data = new data();
	if(js.Boot.__instanceof(data,jsflash.utils.ByteArray)) {
		$s.pop();
		return data;
	}
	{
		var $tmp = data.downcast(jsflash.utils.ByteArray);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.utils.Cast.xml = function(data) {
	$s.push("away3dlite.core.utils.Cast::xml");
	var $spos = $s.length;
	if(js.Boot.__instanceof(data,Class)) data = new data();
	if(js.Boot.__instanceof(data,jsflash.xml.XML)) {
		$s.pop();
		return data;
	}
	if(js.Boot.__instanceof(data,jsflash.xml.XML)) {
		var $tmp = new jsflash.xml.XML(data);
		$s.pop();
		return $tmp;
	}
	{
		var $tmp = new jsflash.xml.XML(new jsflash.xml.XML(data));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.core.utils.Cast.hexstring = function(string) {
	$s.push("away3dlite.core.utils.Cast::hexstring");
	var $spos = $s.length;
	var _length = string.length;
	var i = -1;
	while(++i < _length) {
		if(away3dlite.core.utils.Cast.hexchars.indexOf(string.charAt(i)) == -1) {
			$s.pop();
			return false;
		}
	}
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
away3dlite.core.utils.Cast.color = function(data) {
	$s.push("away3dlite.core.utils.Cast::color");
	var $spos = $s.length;
	if(js.Boot.__instanceof(data,Int)) {
		$s.pop();
		return data;
	}
	if(js.Boot.__instanceof(data,Int)) {
		$s.pop();
		return data;
	}
	if(js.Boot.__instanceof(data,String)) {
		var datastr = data;
		if(datastr == "random") {
			var $tmp = Std["int"](Math.random() * 16777216);
			$s.pop();
			return $tmp;
		}
		if((datastr.length == 6) && away3dlite.core.utils.Cast.hexstring(datastr)) {
			var $tmp = parseInt("0x" + datastr);
			$s.pop();
			return $tmp;
		}
	}
	{
		$s.pop();
		return 16777215;
	}
	$s.pop();
}
away3dlite.core.utils.Cast.bitmap = function(data) {
	$s.push("away3dlite.core.utils.Cast::bitmap");
	var $spos = $s.length;
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
away3dlite.core.utils.Cast.tryclass = function(name) {
	$s.push("away3dlite.core.utils.Cast::tryclass");
	var $spos = $s.length;
	if(away3dlite.core.utils.Cast.notclasses.get(name)) {
		$s.pop();
		return name;
	}
	var result = away3dlite.core.utils.Cast.classes.get(name);
	if(result != null) {
		$s.pop();
		return result;
	}
	result = Type.resolveClass(name);
	if(result != null) {
		away3dlite.core.utils.Cast.classes.set(name,result);
		{
			$s.pop();
			return result;
		}
	}
	away3dlite.core.utils.Cast.notclasses.set(name,true);
	{
		$s.pop();
		return name;
	}
	$s.pop();
}
away3dlite.core.utils.Cast.material = function(data) {
	$s.push("away3dlite.core.utils.Cast::material");
	var $spos = $s.length;
	if(data == null) {
		$s.pop();
		return null;
	}
	if(js.Boot.__instanceof(data,String)) data = away3dlite.core.utils.Cast.tryclass(data);
	if(js.Boot.__instanceof(data,Class)) {
		try {
			data = new data();
		}
		catch( $e11 ) {
			{
				var materialerror = $e11;
				{
					$e = [];
					while($s.length >= $spos) $e.unshift($s.pop());
					$s.push($e[0]);
					data = new data(0,0);
				}
			}
		}
	}
	if(js.Boot.__instanceof(data,away3dlite.materials.Material)) {
		$s.pop();
		return data;
	}
	if(js.Boot.__instanceof(data,Int)) {
		var $tmp = (new away3dlite.materials.ColorMaterial(data));
		$s.pop();
		return $tmp;
	}
	if(js.Boot.__instanceof(data,String)) {
		if(data == "") {
			$s.pop();
			return null;
		}
	}
	try {
		var bmd = away3dlite.core.utils.Cast.bitmap(data);
		{
			var $tmp = new away3dlite.materials.BitmapMaterial(bmd);
			$s.pop();
			return $tmp;
		}
	}
	catch( $e12 ) {
		{
			var error = $e12;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				null;
			}
		}
	}
	throw jsflash.Error.Message("Can't cast to material: " + data);
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
away3dlite.core.utils.Cast.prototype.__class__ = away3dlite.core.utils.Cast;
jsflash.geom.Point = function(x,y) { if( x === $_ ) return; {
	$s.push("jsflash.geom.Point::new");
	var $spos = $s.length;
	if(y == null) y = 0.0;
	if(x == null) x = 0.0;
	this.x = x;
	this.y = y;
	$s.pop();
}}
jsflash.geom.Point.__name__ = ["jsflash","geom","Point"];
jsflash.geom.Point.prototype.x = null;
jsflash.geom.Point.prototype.y = null;
jsflash.geom.Point.prototype.__class__ = jsflash.geom.Point;
away3dlite.materials.WireframeMaterial = function(color,alpha) { if( color === $_ ) return; {
	$s.push("away3dlite.materials.WireframeMaterial::new");
	var $spos = $s.length;
	if(alpha == null) alpha = 1.0;
	if(color == null) color = 16777215;
	away3dlite.materials.Material.apply(this,[]);
	this._color = color;
	this._alpha = alpha;
	$s.pop();
}}
away3dlite.materials.WireframeMaterial.__name__ = ["away3dlite","materials","WireframeMaterial"];
away3dlite.materials.WireframeMaterial.__super__ = away3dlite.materials.Material;
for(var k in away3dlite.materials.Material.prototype ) away3dlite.materials.WireframeMaterial.prototype[k] = away3dlite.materials.Material.prototype[k];
away3dlite.materials.WireframeMaterial.prototype._alpha = null;
away3dlite.materials.WireframeMaterial.prototype._color = null;
away3dlite.materials.WireframeMaterial.prototype.alpha = null;
away3dlite.materials.WireframeMaterial.prototype.color = null;
away3dlite.materials.WireframeMaterial.prototype.get_alpha = function() {
	$s.push("away3dlite.materials.WireframeMaterial::get_alpha");
	var $spos = $s.length;
	{
		var $tmp = this._alpha;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.WireframeMaterial.prototype.get_color = function() {
	$s.push("away3dlite.materials.WireframeMaterial::get_color");
	var $spos = $s.length;
	{
		var $tmp = this._color;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.WireframeMaterial.prototype.set_alpha = function(val) {
	$s.push("away3dlite.materials.WireframeMaterial::set_alpha");
	var $spos = $s.length;
	if(this._alpha == val) {
		$s.pop();
		return val;
	}
	this._alpha = val;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.materials.WireframeMaterial.prototype.set_color = function(val) {
	$s.push("away3dlite.materials.WireframeMaterial::set_color");
	var $spos = $s.length;
	if(this._color == val) {
		$s.pop();
		return val;
	}
	this._color = val;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.materials.WireframeMaterial.prototype.__class__ = away3dlite.materials.WireframeMaterial;
away3dlite.haxeutils.FastStd = function() { }
away3dlite.haxeutils.FastStd.__name__ = ["away3dlite","haxeutils","FastStd"];
away3dlite.haxeutils.FastStd.parseInt = function(str) {
	$s.push("away3dlite.haxeutils.FastStd::parseInt");
	var $spos = $s.length;
	{
		var $tmp = parseInt(str);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.FastStd.parseIntRadix = function(str,radix) {
	$s.push("away3dlite.haxeutils.FastStd::parseIntRadix");
	var $spos = $s.length;
	{
		var $tmp = parseInt(str,radix);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.FastStd.parseFloat = function(str) {
	$s.push("away3dlite.haxeutils.FastStd::parseFloat");
	var $spos = $s.length;
	{
		var $tmp = parseFloat(str);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.FastStd.parseFloatRadix = function(str,radix) {
	$s.push("away3dlite.haxeutils.FastStd::parseFloatRadix");
	var $spos = $s.length;
	{
		var $tmp = parseFloat(str,radix);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.FastStd["is"] = function(v,t) {
	$s.push("away3dlite.haxeutils.FastStd::is");
	var $spos = $s.length;
	{
		var $tmp = js.Boot.__instanceof(v,t);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.FastStd.string = function(s) {
	$s.push("away3dlite.haxeutils.FastStd::string");
	var $spos = $s.length;
	{
		var $tmp = new String(s);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.FastStd.prototype.__class__ = away3dlite.haxeutils.FastStd;
away3dlite.loaders.data.MeshMaterialData = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.loaders.data.MeshMaterialData::new");
	var $spos = $s.length;
	this.faceList = [];
	$s.pop();
}}
away3dlite.loaders.data.MeshMaterialData.__name__ = ["away3dlite","loaders","data","MeshMaterialData"];
away3dlite.loaders.data.MeshMaterialData.prototype.faceList = null;
away3dlite.loaders.data.MeshMaterialData.prototype.symbol = null;
away3dlite.loaders.data.MeshMaterialData.prototype.__class__ = away3dlite.loaders.data.MeshMaterialData;
jsflash.display.Bitmap = function(p) { if( p === $_ ) return; {
	$s.push("jsflash.display.Bitmap::new");
	var $spos = $s.length;
	null;
	$s.pop();
}}
jsflash.display.Bitmap.__name__ = ["jsflash","display","Bitmap"];
jsflash.display.Bitmap.prototype.__class__ = jsflash.display.Bitmap;
jsflash.events.IOErrorEvent = function(type,bubbles,cancelable,inText) { if( type === $_ ) return; {
	$s.push("jsflash.events.IOErrorEvent::new");
	var $spos = $s.length;
	if(inText == null) inText = "";
	jsflash.events.Event.apply(this,[type,bubbles,cancelable]);
	this.text = inText;
	$s.pop();
}}
jsflash.events.IOErrorEvent.__name__ = ["jsflash","events","IOErrorEvent"];
jsflash.events.IOErrorEvent.__super__ = jsflash.events.Event;
for(var k in jsflash.events.Event.prototype ) jsflash.events.IOErrorEvent.prototype[k] = jsflash.events.Event.prototype[k];
jsflash.events.IOErrorEvent.prototype.text = null;
jsflash.events.IOErrorEvent.prototype.__class__ = jsflash.events.IOErrorEvent;
away3dlite.loaders.data.GeometryData = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.loaders.data.GeometryData::new");
	var $spos = $s.length;
	this.skinControllers = [];
	this.materials = [];
	this.faces = [];
	this.indices = new Array();
	this.vertices = new Array();
	this.skinVertices = new Array();
	this.uvtData = new Array();
	this.faceLengths = new Array();
	$s.pop();
}}
away3dlite.loaders.data.GeometryData.__name__ = ["away3dlite","loaders","data","GeometryData"];
away3dlite.loaders.data.GeometryData.prototype.bothsides = null;
away3dlite.loaders.data.GeometryData.prototype.ctrlXML = null;
away3dlite.loaders.data.GeometryData.prototype.faceLengths = null;
away3dlite.loaders.data.GeometryData.prototype.faces = null;
away3dlite.loaders.data.GeometryData.prototype.geoXML = null;
away3dlite.loaders.data.GeometryData.prototype.indices = null;
away3dlite.loaders.data.GeometryData.prototype.materials = null;
away3dlite.loaders.data.GeometryData.prototype.maxX = null;
away3dlite.loaders.data.GeometryData.prototype.maxY = null;
away3dlite.loaders.data.GeometryData.prototype.maxZ = null;
away3dlite.loaders.data.GeometryData.prototype.minX = null;
away3dlite.loaders.data.GeometryData.prototype.minY = null;
away3dlite.loaders.data.GeometryData.prototype.minZ = null;
away3dlite.loaders.data.GeometryData.prototype.name = null;
away3dlite.loaders.data.GeometryData.prototype.skinControllers = null;
away3dlite.loaders.data.GeometryData.prototype.skinVertices = null;
away3dlite.loaders.data.GeometryData.prototype.uvtData = null;
away3dlite.loaders.data.GeometryData.prototype.vertices = null;
away3dlite.loaders.data.GeometryData.prototype.__class__ = away3dlite.loaders.data.GeometryData;
Lambda = function() { }
Lambda.__name__ = ["Lambda"];
Lambda.array = function(it) {
	$s.push("Lambda::array");
	var $spos = $s.length;
	var a = new Array();
	{ var $it13 = it.iterator();
	while( $it13.hasNext() ) { var i = $it13.next();
	a.push(i);
	}}
	{
		$s.pop();
		return a;
	}
	$s.pop();
}
Lambda.list = function(it) {
	$s.push("Lambda::list");
	var $spos = $s.length;
	var l = new List();
	{ var $it14 = it.iterator();
	while( $it14.hasNext() ) { var i = $it14.next();
	l.add(i);
	}}
	{
		$s.pop();
		return l;
	}
	$s.pop();
}
Lambda.map = function(it,f) {
	$s.push("Lambda::map");
	var $spos = $s.length;
	var l = new List();
	{ var $it15 = it.iterator();
	while( $it15.hasNext() ) { var x = $it15.next();
	l.add(f(x));
	}}
	{
		$s.pop();
		return l;
	}
	$s.pop();
}
Lambda.mapi = function(it,f) {
	$s.push("Lambda::mapi");
	var $spos = $s.length;
	var l = new List();
	var i = 0;
	{ var $it16 = it.iterator();
	while( $it16.hasNext() ) { var x = $it16.next();
	l.add(f(i++,x));
	}}
	{
		$s.pop();
		return l;
	}
	$s.pop();
}
Lambda.has = function(it,elt,cmp) {
	$s.push("Lambda::has");
	var $spos = $s.length;
	if(cmp == null) {
		{ var $it17 = it.iterator();
		while( $it17.hasNext() ) { var x = $it17.next();
		if(x == elt) {
			$s.pop();
			return true;
		}
		}}
	}
	else {
		{ var $it18 = it.iterator();
		while( $it18.hasNext() ) { var x = $it18.next();
		if(cmp(x,elt)) {
			$s.pop();
			return true;
		}
		}}
	}
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
Lambda.exists = function(it,f) {
	$s.push("Lambda::exists");
	var $spos = $s.length;
	{ var $it19 = it.iterator();
	while( $it19.hasNext() ) { var x = $it19.next();
	if(f(x)) {
		$s.pop();
		return true;
	}
	}}
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
Lambda.foreach = function(it,f) {
	$s.push("Lambda::foreach");
	var $spos = $s.length;
	{ var $it20 = it.iterator();
	while( $it20.hasNext() ) { var x = $it20.next();
	if(!f(x)) {
		$s.pop();
		return false;
	}
	}}
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
Lambda.iter = function(it,f) {
	$s.push("Lambda::iter");
	var $spos = $s.length;
	{ var $it21 = it.iterator();
	while( $it21.hasNext() ) { var x = $it21.next();
	f(x);
	}}
	$s.pop();
}
Lambda.filter = function(it,f) {
	$s.push("Lambda::filter");
	var $spos = $s.length;
	var l = new List();
	{ var $it22 = it.iterator();
	while( $it22.hasNext() ) { var x = $it22.next();
	if(f(x)) l.add(x);
	}}
	{
		$s.pop();
		return l;
	}
	$s.pop();
}
Lambda.fold = function(it,f,first) {
	$s.push("Lambda::fold");
	var $spos = $s.length;
	{ var $it23 = it.iterator();
	while( $it23.hasNext() ) { var x = $it23.next();
	first = f(x,first);
	}}
	{
		$s.pop();
		return first;
	}
	$s.pop();
}
Lambda.count = function(it) {
	$s.push("Lambda::count");
	var $spos = $s.length;
	var n = 0;
	{ var $it24 = it.iterator();
	while( $it24.hasNext() ) { var _ = $it24.next();
	++n;
	}}
	{
		$s.pop();
		return n;
	}
	$s.pop();
}
Lambda.empty = function(it) {
	$s.push("Lambda::empty");
	var $spos = $s.length;
	{
		var $tmp = !it.iterator().hasNext();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Lambda.prototype.__class__ = Lambda;
ExSphereSpeedTest = function(p) { if( p === $_ ) return; {
	$s.push("ExSphereSpeedTest::new");
	var $spos = $s.length;
	this.fpsCounter = js.Lib.document.getElementById("fps");
	this.textCount = js.Lib.document.getElementById("count");
	this.stage = jsflash.Manager.stage;
	this.stage.set_frameRate(200);
	this.persp = this.stage.transform.perspectiveProjection;
	this.persp.Zfar = 1000;
	this.onInit();
	this.frameCount = 0;
	$s.pop();
}}
ExSphereSpeedTest.__name__ = ["ExSphereSpeedTest"];
ExSphereSpeedTest.main = function() {
	$s.push("ExSphereSpeedTest::main");
	var $spos = $s.length;
	jsflash.Manager.init(js.Lib.document.getElementById("mycanvas"),600,600);
	jsflash.Manager.setupWebGL();
	new ExSphereSpeedTest();
	$s.pop();
}
ExSphereSpeedTest.prototype.currTime = null;
ExSphereSpeedTest.prototype.fpsCounter = null;
ExSphereSpeedTest.prototype.frameCount = null;
ExSphereSpeedTest.prototype.material = null;
ExSphereSpeedTest.prototype.onEnterFrame = function(event) {
	$s.push("ExSphereSpeedTest::onEnterFrame");
	var $spos = $s.length;
	this.onPreRender();
	this.view.render();
	$s.pop();
}
ExSphereSpeedTest.prototype.onInit = function(e) {
	$s.push("ExSphereSpeedTest::onInit");
	var $spos = $s.length;
	this.material = new away3dlite.materials.BitmapMaterial(jsflash.display.BitmapData.ofFile("earth.jpg"));
	this.view = new away3dlite.containers.View3D();
	this.stage.addChild(this.view);
	this.view.get_camera().set_z(1000);
	this.onMouseUp();
	this.onMouseUp();
	this.onMouseUp();
	this.onMouseUp();
	this.onMouseUp();
	this.onMouseUp();
	this.stage.addEventListener(jsflash.events.MouseEvent.MOUSE_DOWN,$closure(this,"onMouseDown"));
	this.stage.addEventListener(jsflash.events.MouseEvent.CLICK,$closure(this,"onMouseUp"));
	this.stage.addEventListener(jsflash.events.Event.ENTER_FRAME,$closure(this,"onEnterFrame"));
	$s.pop();
}
ExSphereSpeedTest.prototype.onMouseDown = function(event) {
	$s.push("ExSphereSpeedTest::onMouseDown");
	var $spos = $s.length;
	var _g = 0, _g1 = this.view.get_scene().get_children();
	while(_g < _g1.length) {
		var _mesh = _g1[_g];
		++_g;
		var mesh = jsflash.Lib["as"](_mesh,away3dlite.core.base.Mesh);
		mesh.get_material().set_debug(true);
	}
	$s.pop();
}
ExSphereSpeedTest.prototype.onMouseUp = function(event) {
	$s.push("ExSphereSpeedTest::onMouseUp");
	var $spos = $s.length;
	var sphere = new away3dlite.primitives.Sphere();
	sphere.set_radius(100);
	sphere.set_segmentsH(20);
	sphere.set_segmentsW(20);
	sphere.set_material(this.material);
	sphere.sortFaces = false;
	this.view.get_scene().addChild(sphere);
	var numChildren = this.view.get_scene().get_children().length;
	var i = 0;
	{
		var _g = 0, _g1 = this.view.get_scene().get_children();
		while(_g < _g1.length) {
			var _mesh = _g1[_g];
			++_g;
			var mesh = jsflash.Lib["as"](_mesh,away3dlite.core.base.Mesh);
			mesh.get_material().set_debug(false);
			mesh.set_x((numChildren * 50) * Math.sin(((2 * Math.PI) * i) / numChildren));
			mesh.set_y((numChildren * 50) * Math.cos(((2 * Math.PI) * i) / numChildren));
			i++;
		}
	}
	var face = Std["int"](sphere.get_vertices().length / 3);
	this.textCount.innerHTML = (("Faces: " + face * numChildren) + " Objects: ") + numChildren;
	$s.pop();
}
ExSphereSpeedTest.prototype.onPreRender = function() {
	$s.push("ExSphereSpeedTest::onPreRender");
	var $spos = $s.length;
	if(this.currTime == null) {
		this.currTime = haxe.Timer.stamp();
	}
	else {
		var lastTime = this.currTime;
		if(this.frameCount++ > 20) {
			this.fpsCounter.innerHTML = "FPS: " + (1 / ((this.currTime = haxe.Timer.stamp()) - lastTime));
			this.frameCount = 0;
		}
		else {
			this.currTime = haxe.Timer.stamp();
		}
	}
	{
		var _g = this.view.get_scene();
		_g.set_z(_g.get_z() - ((1000 + this.view.get_scene().get_children().length * 100) + this.view.get_scene().get_z()) / 25);
	}
	this.persp.Znear = (this.view.get_scene().get_children().length / 10);
	this.persp.Zfar = ((this.view.get_scene().get_children().length * this.view.get_scene().get_children().length) * 100);
	{
		var _g = 0, _g1 = this.view.get_scene().get_children();
		while(_g < _g1.length) {
			var mesh = _g1[_g];
			++_g;
			{
				var _g2 = mesh, _g3 = _g2.get_rotationX();
				_g2.set_rotationX(_g3 + 1);
				_g3;
			}
			{
				var _g2 = mesh, _g3 = _g2.get_rotationY();
				_g2.set_rotationY(_g3 + 1);
				_g3;
			}
			{
				var _g2 = mesh, _g3 = _g2.get_rotationZ();
				_g2.set_rotationZ(_g3 + 1);
				_g3;
			}
		}
	}
	$s.pop();
}
ExSphereSpeedTest.prototype.persp = null;
ExSphereSpeedTest.prototype.stage = null;
ExSphereSpeedTest.prototype.textCount = null;
ExSphereSpeedTest.prototype.view = null;
ExSphereSpeedTest.prototype.__class__ = ExSphereSpeedTest;
jsflash.geom.Orientation3D = { __ename__ : ["jsflash","geom","Orientation3D"], __constructs__ : ["AXIS_ANGLE","EULER_ANGLES","QUATERNION"] }
jsflash.geom.Orientation3D.AXIS_ANGLE = ["AXIS_ANGLE",0];
jsflash.geom.Orientation3D.AXIS_ANGLE.toString = $estr;
jsflash.geom.Orientation3D.AXIS_ANGLE.__enum__ = jsflash.geom.Orientation3D;
jsflash.geom.Orientation3D.EULER_ANGLES = ["EULER_ANGLES",1];
jsflash.geom.Orientation3D.EULER_ANGLES.toString = $estr;
jsflash.geom.Orientation3D.EULER_ANGLES.__enum__ = jsflash.geom.Orientation3D;
jsflash.geom.Orientation3D.QUATERNION = ["QUATERNION",2];
jsflash.geom.Orientation3D.QUATERNION.toString = $estr;
jsflash.geom.Orientation3D.QUATERNION.__enum__ = jsflash.geom.Orientation3D;
away3dlite.haxeutils.HaxeUtils = function() { }
away3dlite.haxeutils.HaxeUtils.__name__ = ["away3dlite","haxeutils","HaxeUtils"];
away3dlite.haxeutils.HaxeUtils.downcast = function(object,cl) {
	$s.push("away3dlite.haxeutils.HaxeUtils::downcast");
	var $spos = $s.length;
	{
		$s.pop();
		return object;
	}
	$s.pop();
}
away3dlite.haxeutils.HaxeUtils.asString = function(object) {
	$s.push("away3dlite.haxeutils.HaxeUtils::asString");
	var $spos = $s.length;
	{
		var $tmp = new String(object);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.HaxeUtils.asFloat = function(object) {
	$s.push("away3dlite.haxeutils.HaxeUtils::asFloat");
	var $spos = $s.length;
	{
		var $tmp = parseFloat(object.asString());
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.HaxeUtils.asInt = function(object) {
	$s.push("away3dlite.haxeutils.HaxeUtils::asInt");
	var $spos = $s.length;
	{
		var $tmp = parseInt(object.asString());
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.HaxeUtils.prototype.__class__ = away3dlite.haxeutils.HaxeUtils;
away3dlite.haxeutils.VectorUtils = function() { }
away3dlite.haxeutils.VectorUtils.__name__ = ["away3dlite","haxeutils","VectorUtils"];
away3dlite.haxeutils.VectorUtils.push4 = function(arr,a1,a2,a3,a4) {
	$s.push("away3dlite.haxeutils.VectorUtils::push4");
	var $spos = $s.length;
	arr.push(a1);
	arr.push(a2);
	arr.push(a3);
	arr.push(a4);
	$s.pop();
}
away3dlite.haxeutils.VectorUtils.push3 = function(arr,a1,a2,a3) {
	$s.push("away3dlite.haxeutils.VectorUtils::push3");
	var $spos = $s.length;
	arr.push(a1);
	arr.push(a2);
	arr.push(a3);
	$s.pop();
}
away3dlite.haxeutils.VectorUtils.prototype.__class__ = away3dlite.haxeutils.VectorUtils;
away3dlite.haxeutils.ArrayUtils = function() { }
away3dlite.haxeutils.ArrayUtils.__name__ = ["away3dlite","haxeutils","ArrayUtils"];
away3dlite.haxeutils.ArrayUtils.indexOf = function(arr,needle) {
	$s.push("away3dlite.haxeutils.ArrayUtils::indexOf");
	var $spos = $s.length;
	var len = arr.length;
	var i = -2;
	while(++i < len) {
		if((i >= 0) && (arr[i] == needle)) break;
	}
	{
		$s.pop();
		return i;
	}
	$s.pop();
}
away3dlite.haxeutils.ArrayUtils.push4 = function(arr,a1,a2,a3,a4) {
	$s.push("away3dlite.haxeutils.ArrayUtils::push4");
	var $spos = $s.length;
	arr.push(a1);
	arr.push(a2);
	arr.push(a3);
	arr.push(a4);
	$s.pop();
}
away3dlite.haxeutils.ArrayUtils.push3 = function(arr,a1,a2,a3) {
	$s.push("away3dlite.haxeutils.ArrayUtils::push3");
	var $spos = $s.length;
	arr.push(a1);
	arr.push(a2);
	arr.push(a3);
	$s.pop();
}
away3dlite.haxeutils.ArrayUtils.push2 = function(arr,a1,a2) {
	$s.push("away3dlite.haxeutils.ArrayUtils::push2");
	var $spos = $s.length;
	arr.push(a1);
	arr.push(a2);
	$s.pop();
}
away3dlite.haxeutils.ArrayUtils.prototype.__class__ = away3dlite.haxeutils.ArrayUtils;
away3dlite.haxeutils.StringUtils = function() { }
away3dlite.haxeutils.StringUtils.__name__ = ["away3dlite","haxeutils","StringUtils"];
away3dlite.haxeutils.StringUtils.match = function(str,regex) {
	$s.push("away3dlite.haxeutils.StringUtils::match");
	var $spos = $s.length;
	{
		var $tmp = str.match(regex.r);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.StringUtils.substring = function(str,startIndex,endIndex) {
	$s.push("away3dlite.haxeutils.StringUtils::substring");
	var $spos = $s.length;
	{
		var $tmp = str.substr(startIndex,endIndex - startIndex);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.StringUtils.charCode = function(str,at) {
	$s.push("away3dlite.haxeutils.StringUtils::charCode");
	var $spos = $s.length;
	{
		var $tmp = str.cca(at);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.haxeutils.StringUtils.prototype.__class__ = away3dlite.haxeutils.StringUtils;
jsflash.VectorCompatibility = function() { }
jsflash.VectorCompatibility.__name__ = ["jsflash","VectorCompatibility"];
jsflash.VectorCompatibility.prototype.__class__ = jsflash.VectorCompatibility;
jsflash.geom.Vector3D = function(ax,ay,az,aw) { if( ax === $_ ) return; {
	$s.push("jsflash.geom.Vector3D::new");
	var $spos = $s.length;
	if(aw == null) aw = 0;
	if(az == null) az = 0;
	if(ay == null) ay = 0;
	if(ax == null) ax = 0;
	this.x = ax;
	this.y = ay;
	this.z = az;
	this.w = aw;
	this.set_dirty(true);
	$s.pop();
}}
jsflash.geom.Vector3D.__name__ = ["jsflash","geom","Vector3D"];
jsflash.geom.Vector3D.angleBetween = function(a,b) {
	$s.push("jsflash.geom.Vector3D::angleBetween");
	var $spos = $s.length;
	{
		var $tmp = Math.acos(a.dotProduct(b) / (a.get_length() * b.get_length()));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.distance = function(pt1,pt2) {
	$s.push("jsflash.geom.Vector3D::distance");
	var $spos = $s.length;
	var vx = pt1.x - pt2.x;
	var vy = pt1.y - pt2.y;
	var vz = pt1.z - pt2.z;
	{
		var $tmp = Math.sqrt((vx * vx + vy * vy) + vz * vz);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.Change = function(x,y,z,w) {
	$s.push("jsflash.geom.Vector3D::Change");
	var $spos = $s.length;
	this.x = x;
	this.y = y;
	this.z = z;
	this.w = w;
	this.set_dirty(true);
	$s.pop();
}
jsflash.geom.Vector3D.prototype.Internal = function() {
	$s.push("jsflash.geom.Vector3D::Internal");
	var $spos = $s.length;
	{
		$s.pop();
		return this;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.OnChange = null;
jsflash.geom.Vector3D.prototype.add = function(a) {
	$s.push("jsflash.geom.Vector3D::add");
	var $spos = $s.length;
	{
		var $tmp = new jsflash.geom.Vector3D(this.x + a.x,this.y + a.y,this.z + a.z);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.clone = function() {
	$s.push("jsflash.geom.Vector3D::clone");
	var $spos = $s.length;
	{
		var $tmp = new jsflash.geom.Vector3D(this.x,this.y,this.z,this.w);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.crossProduct = function(a) {
	$s.push("jsflash.geom.Vector3D::crossProduct");
	var $spos = $s.length;
	{
		var $tmp = new jsflash.geom.Vector3D((this.y * a.z - this.z * a.y),(this.z * a.x - this.x * a.z),(this.x * a.y - this.y * a.x),1);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.decrementBy = function(a) {
	$s.push("jsflash.geom.Vector3D::decrementBy");
	var $spos = $s.length;
	this.x = this.x - a.x;
	this.y = this.y - a.y;
	this.z = this.z - a.z;
	this.set_dirty(true);
	$s.pop();
}
jsflash.geom.Vector3D.prototype.dirty = null;
jsflash.geom.Vector3D.prototype.dotProduct = function(a) {
	$s.push("jsflash.geom.Vector3D::dotProduct");
	var $spos = $s.length;
	{
		var $tmp = (this.x * a.x + this.y * a.y) + this.z * a.z;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.equals = function(toCompare,allFour) {
	$s.push("jsflash.geom.Vector3D::equals");
	var $spos = $s.length;
	{
		var $tmp = (this.x == toCompare.x && this.y == toCompare.y && this.z == toCompare.z?(allFour?(this.w == toCompare.w?true:false):true):false);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.get_length = function() {
	$s.push("jsflash.geom.Vector3D::get_length");
	var $spos = $s.length;
	if(this.dirty) {
		this.set_dirty(false);
		this.length = Math.sqrt((this.x * this.x + this.y * this.y) + this.z * this.z);
	}
	{
		var $tmp = this.length;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.get_lengthSquared = function() {
	$s.push("jsflash.geom.Vector3D::get_lengthSquared");
	var $spos = $s.length;
	{
		var $tmp = ((this.x * this.x + this.y * this.y) + this.z * this.z);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.incrementBy = function(a) {
	$s.push("jsflash.geom.Vector3D::incrementBy");
	var $spos = $s.length;
	this.x = this.x + a.x;
	this.y = this.y + a.y;
	this.z = this.z + a.z;
	this.set_dirty(true);
	$s.pop();
}
jsflash.geom.Vector3D.prototype.length = null;
jsflash.geom.Vector3D.prototype.lengthSquared = null;
jsflash.geom.Vector3D.prototype.nearEquals = function(toCompare,tolerance,allFour) {
	$s.push("jsflash.geom.Vector3D::nearEquals");
	var $spos = $s.length;
	if(allFour == null) allFour = false;
	{
		var $tmp = (jsflash.FastMath.abs(this.x - toCompare.x) < tolerance && jsflash.FastMath.abs(this.y - toCompare.y) < tolerance && jsflash.FastMath.abs(this.z - toCompare.z) < tolerance?(allFour?(jsflash.FastMath.abs(this.w - toCompare.w) < tolerance?true:false):true):false);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.negate = function() {
	$s.push("jsflash.geom.Vector3D::negate");
	var $spos = $s.length;
	this.x = -this.x;
	this.y = -this.y;
	this.z = -this.z;
	$s.pop();
}
jsflash.geom.Vector3D.prototype.normalize = function() {
	$s.push("jsflash.geom.Vector3D::normalize");
	var $spos = $s.length;
	var l = this.get_length();
	this.x /= l;
	this.y /= l;
	this.z /= l;
	this.set_dirty(false);
	this.length = 1;
	{
		$s.pop();
		return l;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.project = function() {
	$s.push("jsflash.geom.Vector3D::project");
	var $spos = $s.length;
	this.x /= this.w;
	this.y /= this.w;
	this.z /= this.w;
	this.set_dirty(true);
	$s.pop();
}
jsflash.geom.Vector3D.prototype.scaleBy = function(s) {
	$s.push("jsflash.geom.Vector3D::scaleBy");
	var $spos = $s.length;
	this.x = s * this.x;
	this.y = s * this.y;
	this.z = s * this.z;
	this.w = s * this.w;
	this.set_dirty(true);
	$s.pop();
}
jsflash.geom.Vector3D.prototype.set_dirty = function(val) {
	$s.push("jsflash.geom.Vector3D::set_dirty");
	var $spos = $s.length;
	if(val && this.OnChange != null) this.OnChange();
	{
		var $tmp = this.dirty = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.set_w = function(val) {
	$s.push("jsflash.geom.Vector3D::set_w");
	var $spos = $s.length;
	if(val != this.w) this.set_dirty(true);
	{
		var $tmp = this.w = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.set_x = function(val) {
	$s.push("jsflash.geom.Vector3D::set_x");
	var $spos = $s.length;
	if(val != this.x) {
		this.x = val;
		this.set_dirty(true);
	}
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.set_y = function(val) {
	$s.push("jsflash.geom.Vector3D::set_y");
	var $spos = $s.length;
	if(val != this.y) {
		this.y = val;
		this.set_dirty(true);
	}
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.set_z = function(val) {
	$s.push("jsflash.geom.Vector3D::set_z");
	var $spos = $s.length;
	if(val != this.z) {
		this.z = val;
		this.set_dirty(true);
	}
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.subtract = function(a) {
	$s.push("jsflash.geom.Vector3D::subtract");
	var $spos = $s.length;
	{
		var $tmp = new jsflash.geom.Vector3D(this.x - a.x,this.y - a.y,this.z - a.z);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.toString = function() {
	$s.push("jsflash.geom.Vector3D::toString");
	var $spos = $s.length;
	{
		var $tmp = ((((("Vector3D(" + this.x) + ", ") + this.y) + ", ") + this.z) + ")";
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Vector3D.prototype.w = null;
jsflash.geom.Vector3D.prototype.x = null;
jsflash.geom.Vector3D.prototype.y = null;
jsflash.geom.Vector3D.prototype.z = null;
jsflash.geom.Vector3D.prototype.__class__ = jsflash.geom.Vector3D;
StringBuf = function(p) { if( p === $_ ) return; {
	$s.push("StringBuf::new");
	var $spos = $s.length;
	this.b = new Array();
	$s.pop();
}}
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype.add = function(x) {
	$s.push("StringBuf::add");
	var $spos = $s.length;
	this.b[this.b.length] = x;
	$s.pop();
}
StringBuf.prototype.addChar = function(c) {
	$s.push("StringBuf::addChar");
	var $spos = $s.length;
	this.b[this.b.length] = String.fromCharCode(c);
	$s.pop();
}
StringBuf.prototype.addSub = function(s,pos,len) {
	$s.push("StringBuf::addSub");
	var $spos = $s.length;
	this.b[this.b.length] = s.substr(pos,len);
	$s.pop();
}
StringBuf.prototype.b = null;
StringBuf.prototype.toString = function() {
	$s.push("StringBuf::toString");
	var $spos = $s.length;
	{
		var $tmp = this.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
StringBuf.prototype.__class__ = StringBuf;
away3dlite.animators.bones.Channel = function(name) { if( name === $_ ) return; {
	$s.push("away3dlite.animators.bones.Channel::new");
	var $spos = $s.length;
	this.name = name;
	this.type = [];
	this.param = [];
	this.inTangent = [];
	this.outTangent = [];
	this.times = [];
	this.interpolations = [];
	this.setFields = new Hash();
	$s.pop();
}}
away3dlite.animators.bones.Channel.__name__ = ["away3dlite","animators","bones","Channel"];
away3dlite.animators.bones.Channel.prototype._index = null;
away3dlite.animators.bones.Channel.prototype._length = null;
away3dlite.animators.bones.Channel.prototype._oldlength = null;
away3dlite.animators.bones.Channel.prototype.clone = function(object) {
	$s.push("away3dlite.animators.bones.Channel::clone");
	var $spos = $s.length;
	var channel = new away3dlite.animators.bones.Channel(this.name);
	channel.target = jsflash.Lib["as"](object.getChildByName(this.name),away3dlite.core.base.Object3D);
	channel.type = this.type.copy();
	channel.param = this.param.copy();
	channel.inTangent = this.inTangent.copy();
	channel.outTangent = this.outTangent.copy();
	channel.times = this.times.copy();
	channel.interpolations = this.interpolations.copy();
	{
		$s.pop();
		return channel;
	}
	$s.pop();
}
away3dlite.animators.bones.Channel.prototype.i = null;
away3dlite.animators.bones.Channel.prototype.inTangent = null;
away3dlite.animators.bones.Channel.prototype.interpolations = null;
away3dlite.animators.bones.Channel.prototype.lastLen = null;
away3dlite.animators.bones.Channel.prototype.name = null;
away3dlite.animators.bones.Channel.prototype.outTangent = null;
away3dlite.animators.bones.Channel.prototype.param = null;
away3dlite.animators.bones.Channel.prototype.setFields = null;
away3dlite.animators.bones.Channel.prototype.target = null;
away3dlite.animators.bones.Channel.prototype.times = null;
away3dlite.animators.bones.Channel.prototype.type = null;
away3dlite.animators.bones.Channel.prototype.update = function(time,interpolate) {
	$s.push("away3dlite.animators.bones.Channel::update");
	var $spos = $s.length;
	if(interpolate == null) interpolate = true;
	if(this.target == null) {
		$s.pop();
		return;
	}
	if(this.lastLen != this.type.length) this.updateFields();
	this.i = this.type.length;
	if(time < this.times[0]) {
		while(this.i-- != 0) {
			var setField = this.setFields.get(this.type[this.i]);
			if(setField != null) setField(this.param[0][this.i]);
			else this.target[this.type[this.i]] = this.param[0][this.i];
		}
	}
	else if(time > this.times[Std["int"](this.times.length - 1)]) {
		while(this.i-- != 0) {
			var setField = this.setFields.get(this.type[this.i]);
			if(setField != null) setField(this.param[Std["int"](this.times.length - 1)][this.i]);
			else this.target[this.type[this.i]] = this.param[Std["int"](this.times.length - 1)][this.i];
		}
	}
	else {
		this._index = this._length = this._oldlength = this.times.length - 1;
		while(this._length > 1) {
			this._oldlength = this._length;
			this._length >>= 1;
			if(this.times[this._index - this._length] > time) {
				this._index -= this._length;
				this._length = this._oldlength - this._length;
			}
		}
		this._index--;
		while(this.i-- != 0) {
			if(this.type[this.i] == "transform") {
				this.target.transform.set_matrix3D(this.param[this._index][this.i]);
			}
			else if(this.type[this.i] == "visibility") {
				this.target.set_visible(this.param[this._index][this.i] > 0);
			}
			else {
				if(interpolate) {
					var setValue = ((time - this.times[this._index]) * this.param[Std["int"](this._index + 1)][this.i] + (this.times[Std["int"](this._index + 1)] - time) * this.param[this._index][this.i]) / (this.times[Std["int"](this._index + 1)] - this.times[this._index]);
					var setField = this.setFields.get(this.type[this.i]);
					if(setField != null) setField(setValue);
					else this.target[this.type[this.i]] = setValue;
				}
				else {
					var setValue = this.param[this._index][this.i];
					var setField = this.setFields.get(this.type[this.i]);
					if(setField != null) setField(setValue);
					else this.target[this.type[this.i]] = setValue;
				}
			}
		}
	}
	$s.pop();
}
away3dlite.animators.bones.Channel.prototype.updateFields = function() {
	$s.push("away3dlite.animators.bones.Channel::updateFields");
	var $spos = $s.length;
	this.i = this.type.length;
	while(--this.i >= this.lastLen) {
		if(Reflect.hasField(this.target,"set_" + this.type[this.i])) this.setFields.set(this.type[this.i],Reflect.field(this.target,"set_" + this.type[this.i]));
	}
	this.lastLen = this.type.length;
	$s.pop();
}
away3dlite.animators.bones.Channel.prototype.__class__ = away3dlite.animators.bones.Channel;
jsflash.geom.Transform = function(displayObject) { if( displayObject === $_ ) return; {
	$s.push("jsflash.geom.Transform::new");
	var $spos = $s.length;
	this.displayObject = displayObject;
	this.set_matrix3D(new jsflash.geom.Matrix3D());
	$s.pop();
}}
jsflash.geom.Transform.__name__ = ["jsflash","geom","Transform"];
jsflash.geom.Transform.prototype.displayObject = null;
jsflash.geom.Transform.prototype.getRelativeMatrix3D = function(relativeTo) {
	$s.push("jsflash.geom.Transform::getRelativeMatrix3D");
	var $spos = $s.length;
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
jsflash.geom.Transform.prototype.matrix3D = null;
jsflash.geom.Transform.prototype.perspectiveProjection = null;
jsflash.geom.Transform.prototype.set_matrix3D = function(val) {
	$s.push("jsflash.geom.Transform::set_matrix3D");
	var $spos = $s.length;
	this.displayObject.matrix = val;
	{
		var $tmp = this.matrix3D = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Transform.prototype.__class__ = jsflash.geom.Transform;
jsflash.geom.Matrix3D = function(data) { if( data === $_ ) return; {
	$s.push("jsflash.geom.Matrix3D::new");
	var $spos = $s.length;
	if(data != null) this.rawData = data;
	else this.identity();
	this.set_position(new jsflash.geom.Vector3D(this.rawData[12],this.rawData[13],this.rawData[14],this.rawData[15]));
	this.get_position().OnChange = $closure(this,"posVectorHandler");
	this.dirty = true;
	$s.pop();
}}
jsflash.geom.Matrix3D.__name__ = ["jsflash","geom","Matrix3D"];
jsflash.geom.Matrix3D.prototype.Internal = function() {
	$s.push("jsflash.geom.Matrix3D::Internal");
	var $spos = $s.length;
	{
		$s.pop();
		return this;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.Matrix3dToEulerAnglePrepend = function(e) {
	$s.push("jsflash.geom.Matrix3D::Matrix3dToEulerAnglePrepend");
	var $spos = $s.length;
	var math = Math;
	var _z = math.atan2(e[1],e[0]);
	var sz = math.sin(_z);
	var cz = math.cos(_z);
	var _y = (math.abs(cz) > 0.7?math.atan2(-e[2],e[0] / cz):math.atan2(-e[2],e[1] / sz));
	var sy = math.sin(_y);
	var cy = math.cos(_y);
	var _x = (math.abs(cz) > 0.7?math.atan2((sy * sz - (e[9] * cy) / e[10]),cz):math.atan2(((e[8] * cy) / e[10] - sy * cz) / sz,1));
	var sx = math.sin(_x);
	var cx = math.cos(_x);
	var scale_x = ((sy != 0)?-e[2] / sy:(e[0] / (cy * cz)));
	var scale_y = ((sx != 0 && cy != 0)?e[6] / (sx * cy):(e[5] / ((sx * sy) * sz + cx * cz)));
	var scale_z = ((cx != 0 && cy != 0)?e[10] / (cx * cy):1);
	{
		var $tmp = [new jsflash.geom.Vector3D(e[12],e[13],e[14]),new jsflash.geom.Vector3D(_x,_y,_z),new jsflash.geom.Vector3D(scale_x,scale_y,scale_z)];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.Matrix3dToQuaternion = function(entity,scale,orientationStyle) {
	$s.push("jsflash.geom.Matrix3D::Matrix3dToQuaternion");
	var $spos = $s.length;
	var e = entity.concat([]);
	if(scale.x > 0) {
		e[0] /= scale.x;
		e[4] /= scale.x;
		e[8] /= scale.x;
	}
	if(scale.y > 0) {
		e[1] /= scale.y;
		e[5] /= scale.y;
		e[9] /= scale.y;
	}
	if(scale.z > 0) {
		e[2] /= scale.z;
		e[6] /= scale.z;
		e[10] /= scale.z;
	}
	var w = 0.0, x = 0.0, y = 0.0, z = 0;
	var math = Math;
	var _ar = [(e[0] + e[5]) + e[10],(e[0] - e[5]) - e[10],(e[5] - e[0]) - e[10],(e[10] - e[0]) - e[5]];
	var idx = 0;
	var val = _ar[0];
	var biggestIndex = 0;
	{
		var _g = 0;
		while(_g < _ar.length) {
			var f = _ar[_g];
			++_g;
			if(f > val) {
				val = f;
				biggestIndex = idx;
			}
			idx++;
		}
	}
	var biggestVal = math.sqrt(_ar[biggestIndex] + 1) * 0.5;
	var mult = 0.25 / biggestVal;
	switch(biggestIndex) {
	case 0:{
		w = biggestVal;
		x = (e[6] - e[9]) * mult;
		y = (e[8] - e[2]) * mult;
		z = (e[1] - e[4]) * mult;
	}break;
	case 1:{
		x = biggestVal;
		w = (e[6] - e[9]) * mult;
		y = (e[4] + e[1]) * mult;
		z = (e[2] + e[8]) * mult;
	}break;
	case 2:{
		y = biggestVal;
		w = (e[8] - e[2]) * mult;
		x = (e[4] + e[1]) * mult;
		z = (e[9] + e[6]) * mult;
	}break;
	case 3:{
		z = biggestVal;
		w = (e[1] - e[4]) * mult;
		x = (e[2] + e[8]) * mult;
		y = (e[9] + e[6]) * mult;
	}break;
	default:{
		throw "unexpected error";
	}break;
	}
	var $e = (orientationStyle);
	switch( $e[1] ) {
	case 0:
	{
		{
			var acosw = math.acos(w);
			var sin_acosw = math.sin(acosw);
			if(sin_acosw != 0) {
				x = x / sin_acosw;
				y = y / sin_acosw;
				z = z / sin_acosw;
				w = 2 * acosw;
			}
			else {
				x = y = z = w = 0;
			}
		}
	}break;
	default:{
		null;
	}break;
	}
	{
		var $tmp = [new jsflash.geom.Vector3D(e[12],e[13],e[14]),new jsflash.geom.Vector3D(x,y,z,w),new jsflash.geom.Vector3D(jsflash.FastMath.abs(scale.x),jsflash.FastMath.abs(scale.y),jsflash.FastMath.abs(scale.z),jsflash.FastMath.abs(scale.w))];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.RawDataFromQuaternion = function(x,y,z,w) {
	$s.push("jsflash.geom.Matrix3D::RawDataFromQuaternion");
	var $spos = $s.length;
	this.dirty = true;
	var p = new Array();
	p[0] = (((w * w + x * x) - y * y) - z * z);
	p[1] = 2 * (y * x + w * z);
	p[2] = 2 * (z * x - w * y);
	p[3] = 0;
	p[4] = 2 * (y * x - w * z);
	p[5] = (((w * w - x * x) + y * y) - z * z);
	p[6] = 2 * (w * x + z * y);
	p[7] = 0;
	p[8] = 2 * (z * x + w * y);
	p[9] = 2 * (z * y - w * x);
	p[10] = (((w * w - x * x) - y * y) + z * z);
	p[11] = 0;
	p[12] = 0;
	p[13] = 0;
	p[14] = 0;
	p[15] = 1;
	{
		$s.pop();
		return p;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.SWX = null;
jsflash.geom.Matrix3D.prototype.SWY = null;
jsflash.geom.Matrix3D.prototype.SWZ = null;
jsflash.geom.Matrix3D.prototype.SXX = null;
jsflash.geom.Matrix3D.prototype.SXY = null;
jsflash.geom.Matrix3D.prototype.SXZ = null;
jsflash.geom.Matrix3D.prototype.SYX = null;
jsflash.geom.Matrix3D.prototype.SYY = null;
jsflash.geom.Matrix3D.prototype.SYZ = null;
jsflash.geom.Matrix3D.prototype.SZX = null;
jsflash.geom.Matrix3D.prototype.SZY = null;
jsflash.geom.Matrix3D.prototype.SZZ = null;
jsflash.geom.Matrix3D.prototype.TW = null;
jsflash.geom.Matrix3D.prototype.TX = null;
jsflash.geom.Matrix3D.prototype.TY = null;
jsflash.geom.Matrix3D.prototype.TZ = null;
jsflash.geom.Matrix3D.prototype.append = function(lhs) {
	$s.push("jsflash.geom.Matrix3D::append");
	var $spos = $s.length;
	this.dirty = true;
	this.set_rawData(this.matrix44Calculat(this.rawData,lhs.rawData));
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.appendRotation = function(degrees,axis,pivotPoint) {
	$s.push("jsflash.geom.Matrix3D::appendRotation");
	var $spos = $s.length;
	this.dirty = true;
	if(pivotPoint == null) {
		pivotPoint = new jsflash.geom.Vector3D(0,0,0);
	}
	var tempAxis = axis.clone();
	var degreesPIper360 = (degrees / 360) * Math.PI;
	var w = Math.cos(degreesPIper360);
	var x = Math.sin(degreesPIper360) * tempAxis.x;
	var y = Math.sin(degreesPIper360) * tempAxis.y;
	var z = Math.sin(degreesPIper360) * tempAxis.z;
	var p = this.RawDataFromQuaternion(x,y,z,w);
	this.set_rawData(this.matrix44Calculat(this.rawData,p));
	this.appendTranslation(pivotPoint.x,pivotPoint.y,pivotPoint.z);
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.appendScale = function(xScale,yScale,zScale) {
	$s.push("jsflash.geom.Matrix3D::appendScale");
	var $spos = $s.length;
	this.dirty = true;
	this.rawData[0] *= xScale;
	this.rawData[1] *= yScale;
	this.rawData[2] *= zScale;
	this.rawData[4] *= xScale;
	this.rawData[5] *= yScale;
	this.rawData[6] *= zScale;
	this.rawData[8] *= xScale;
	this.rawData[9] *= yScale;
	this.rawData[10] *= zScale;
	this.rawData[12] *= xScale;
	this.rawData[13] *= yScale;
	this.rawData[14] *= zScale;
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.appendTranslation = function(x,y,z) {
	$s.push("jsflash.geom.Matrix3D::appendTranslation");
	var $spos = $s.length;
	this.rawData[12] += x;
	this.rawData[13] += y;
	this.rawData[14] += z;
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.checkDirty = function() {
	$s.push("jsflash.geom.Matrix3D::checkDirty");
	var $spos = $s.length;
	if(this.dirty) {
		var dec = this.Matrix3dToEulerAnglePrepend(this.rawData);
		if(this.scale != null) this.scale.OnChange = null;
		if(this.rotation != null) this.rotation.OnChange = null;
		this.scale = dec[2];
		this.rotation = new jsflash.geom.Vector3D(dec[1].x * (180 / 3.141592653589793),dec[1].y * (180 / 3.141592653589793),dec[1].z * (180 / 3.141592653589793));
		dec[2].OnChange = $closure(this,"scaleRotationHandler");
		this.rotation.OnChange = $closure(this,"scaleRotationHandler");
		this.dirty = false;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.clone = function() {
	$s.push("jsflash.geom.Matrix3D::clone");
	var $spos = $s.length;
	{
		var $tmp = new jsflash.geom.Matrix3D(this.rawData.concat([]));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.cofactor = function(c0,c1,c2,c3,c4,c5,c6,c7,c8) {
	$s.push("jsflash.geom.Matrix3D::cofactor");
	var $spos = $s.length;
	{
		var $tmp = (c0 * (c4 * c8 - c5 * c7) + c1 * (c5 * c6 - c3 * c8)) + c2 * (c3 * c7 - c4 * c6);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.decompose = function(orientation) {
	$s.push("jsflash.geom.Matrix3D::decompose");
	var $spos = $s.length;
	if(orientation == null) orientation = jsflash.geom.Orientation3D.EULER_ANGLES;
	var e = this.rawData;
	var vec = this.Matrix3dToEulerAnglePrepend(e);
	{
		var $tmp = (function($this) {
			var $r;
			var $e = (orientation);
			switch( $e[1] ) {
			case 1:
			{
				$r = vec;
			}break;
			default:{
				$r = $this.Matrix3dToQuaternion(e,vec[2],orientation);
			}break;
			}
			return $r;
		}(this));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.deltaTransformVector = function(v) {
	$s.push("jsflash.geom.Matrix3D::deltaTransformVector");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = new jsflash.geom.Vector3D(((this.rawData[0] * v.x + this.rawData[4] * v.y) + this.rawData[8] * v.z),((this.rawData[1] * v.x + this.rawData[5] * v.y) + this.rawData[9] * v.z),((this.rawData[2] * v.x + this.rawData[6] * v.y) + this.rawData[10] * v.z),((this.rawData[3] * v.x + this.rawData[7] * v.y) + this.rawData[11] * v.z));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.determinant = null;
jsflash.geom.Matrix3D.prototype.dirty = null;
jsflash.geom.Matrix3D.prototype.get_SWX = function() {
	$s.push("jsflash.geom.Matrix3D::get_SWX");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[3];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_SWY = function() {
	$s.push("jsflash.geom.Matrix3D::get_SWY");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[7];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_SWZ = function() {
	$s.push("jsflash.geom.Matrix3D::get_SWZ");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[11];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_SXX = function() {
	$s.push("jsflash.geom.Matrix3D::get_SXX");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[0];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_SXY = function() {
	$s.push("jsflash.geom.Matrix3D::get_SXY");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[4];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_SXZ = function() {
	$s.push("jsflash.geom.Matrix3D::get_SXZ");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[8];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_SYX = function() {
	$s.push("jsflash.geom.Matrix3D::get_SYX");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[1];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_SYY = function() {
	$s.push("jsflash.geom.Matrix3D::get_SYY");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[5];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_SYZ = function() {
	$s.push("jsflash.geom.Matrix3D::get_SYZ");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[9];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_SZX = function() {
	$s.push("jsflash.geom.Matrix3D::get_SZX");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[2];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_SZY = function() {
	$s.push("jsflash.geom.Matrix3D::get_SZY");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[6];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_SZZ = function() {
	$s.push("jsflash.geom.Matrix3D::get_SZZ");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[10];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_TW = function() {
	$s.push("jsflash.geom.Matrix3D::get_TW");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[15];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_TX = function() {
	$s.push("jsflash.geom.Matrix3D::get_TX");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[12];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_TY = function() {
	$s.push("jsflash.geom.Matrix3D::get_TY");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[13];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_TZ = function() {
	$s.push("jsflash.geom.Matrix3D::get_TZ");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[14];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_determinant = function() {
	$s.push("jsflash.geom.Matrix3D::get_determinant");
	var $spos = $s.length;
	var e = this.rawData;
	var e0 = e[0];
	var e1 = e[1];
	var e2 = e[2];
	var e3 = e[3];
	var e4 = e[4];
	var e5 = e[5];
	var e6 = e[6];
	var e7 = e[7];
	var e8 = e[8];
	var e9 = e[9];
	var e10 = e[10];
	var e11 = e[11];
	var e12 = e[12];
	var e13 = e[13];
	var e14 = e[14];
	var e15 = e[15];
	var d = e0 * ((((((e5 * e10) * e15 + (e6 * e11) * e13) + (e7 * e9) * e14) - (e7 * e10) * e13) - (e6 * e9) * e15) - (e5 * e11) * e14);
	d -= e1 * ((((((e4 * e10) * e15 + (e6 * e11) * e12) + (e7 * e8) * e14) - (e7 * e10) * e12) - (e6 * e8) * e15) - (e4 * e11) * e14);
	d += e2 * ((((((e4 * e9) * e15 + (e5 * e11) * e12) + (e7 * e8) * e13) - (e7 * e9) * e12) - (e5 * e8) * e15) - (e4 * e11) * e13);
	d -= e3 * ((((((e4 * e9) * e14 + (e5 * e10) * e12) + (e6 * e8) * e13) - (e6 * e9) * e12) - (e5 * e8) * e14) - (e4 * e10) * e13);
	d -= (((e4 - e8) * e1 + (e9 - e5) * e0) * e11) * e14;
	{
		var $tmp = -d;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_position = function() {
	$s.push("jsflash.geom.Matrix3D::get_position");
	var $spos = $s.length;
	this.position.Change(this.rawData[12],this.rawData[13],this.rawData[14],this.rawData[15]);
	{
		var $tmp = this.position;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_rotation = function() {
	$s.push("jsflash.geom.Matrix3D::get_rotation");
	var $spos = $s.length;
	this.checkDirty();
	{
		var $tmp = this.rotation;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.get_scale = function() {
	$s.push("jsflash.geom.Matrix3D::get_scale");
	var $spos = $s.length;
	this.checkDirty();
	{
		var $tmp = this.scale;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.identity = function() {
	$s.push("jsflash.geom.Matrix3D::identity");
	var $spos = $s.length;
	this.dirty = true;
	this.set_rawData([1.0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]);
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.invert = function() {
	$s.push("jsflash.geom.Matrix3D::invert");
	var $spos = $s.length;
	this.dirty = true;
	var e = this.rawData;
	var e0 = e[0];
	var e1 = e[1];
	var e2 = e[2];
	var e3 = e[3];
	var e4 = e[4];
	var e5 = e[5];
	var e6 = e[6];
	var e7 = e[7];
	var e8 = e[8];
	var e9 = e[9];
	var e10 = e[10];
	var e11 = e[11];
	var e12 = e[12];
	var e13 = e[13];
	var e14 = e[14];
	var e15 = e[15];
	var a = new Array();
	a[0] = (e5 * (e10 * e15 - e14 * e11) + e9 * (e14 * e7 - e6 * e15)) + e13 * (e6 * e11 - e10 * e7);
	a[1] = -(e4 * (e10 * e15 - e14 * e11) + e8 * (e14 * e7 - e6 * e15)) + e12 * (e6 * e11 - e10 * e7);
	a[2] = (e4 * (e9 * e15 - e13 * e11) + e8 * (e13 * e7 - e5 * e15)) + e12 * (e5 * e11 - e9 * e7);
	a[3] = -(e4 * (e9 * e14 - e13 * e10) + e8 * (e13 * e6 - e5 * e14)) + e12 * (e5 * e10 - e9 * e6);
	a[4] = -(e1 * (e10 * e15 - e14 * e11) + e9 * (e14 * e3 - e2 * e15)) + e13 * (e2 * e11 - e10 * e3);
	a[5] = (e0 * (e10 * e15 - e14 * e11) + e8 * (e14 * e3 - e2 * e15)) + e12 * (e2 * e11 - e10 * e3);
	a[6] = -(e0 * (e9 * e15 - e13 * e11) + e8 * (e13 * e3 - e1 * e15)) + e12 * (e1 * e11 - e9 * e3);
	a[7] = (e0 * (e9 * e14 - e13 * e10) + e8 * (e13 * e2 - e1 * e14)) + e12 * (e1 * e10 - e9 * e2);
	a[8] = (e1 * (e6 * e15 - e14 * e7) + e5 * (e14 * e3 - e2 * e15)) + e13 * (e2 * e7 - e6 * e3);
	a[9] = -(e0 * (e6 * e15 - e14 * e7) + e4 * (e14 * e3 - e2 * e15)) + e12 * (e2 * e7 - e6 * e3);
	a[10] = (e0 * (e5 * e15 - e13 * e7) + e4 * (e13 * e3 - e1 * e15)) + e12 * (e1 * e7 - e5 * e3);
	a[11] = -(e0 * (e5 * e14 - e13 * e6) + e4 * (e13 * e2 - e1 * e14)) + e12 * (e1 * e6 - e5 * e2);
	a[12] = -(e1 * (e6 * e11 - e10 * e7) + e5 * (e10 * e3 - e2 * e11)) + e9 * (e2 * e7 - e6 * e3);
	a[13] = (e0 * (e6 * e11 - e10 * e7) + e4 * (e10 * e3 - e2 * e11)) + e8 * (e2 * e7 - e6 * e3);
	a[14] = -(e0 * (e5 * e11 - e9 * e7) + e4 * (e9 * e3 - e1 * e11)) + e8 * (e1 * e7 - e5 * e3);
	a[15] = (e0 * (e5 * e10 - e9 * e6) + e4 * (e9 * e2 - e1 * e10)) + e8 * (e1 * e6 - e5 * e2);
	var d = ((e[0] * a[0] + e[1] * a[1]) + e[2] * a[2]) + e[3] * a[3];
	if(d != 0) {
		this.set_rawData([a[0] / d,a[4] / d,a[8] / d,a[12] / d,a[1] / d,a[5] / d,a[9] / d,a[13] / d,a[2] / d,a[6] / d,a[10] / d,a[14] / d,a[3] / d,a[7] / d,a[11] / d,a[15] / d]);
		{
			$s.pop();
			return true;
		}
	}
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.matrix44Calculat = function(e,p) {
	$s.push("jsflash.geom.Matrix3D::matrix44Calculat");
	var $spos = $s.length;
	var pe = new Array();
	pe[0] = ((p[0] * e[0] + p[4] * e[1]) + p[8] * e[2]) + p[12] * e[3];
	pe[1] = ((p[1] * e[0] + p[5] * e[1]) + p[9] * e[2]) + p[13] * e[3];
	pe[2] = ((p[2] * e[0] + p[6] * e[1]) + p[10] * e[2]) + p[14] * e[3];
	pe[3] = ((p[3] * e[0] + p[7] * e[1]) + p[11] * e[2]) + p[15] * e[3];
	pe[4] = ((p[0] * e[4] + p[4] * e[5]) + p[8] * e[6]) + p[12] * e[7];
	pe[5] = ((p[1] * e[4] + p[5] * e[5]) + p[9] * e[6]) + p[13] * e[7];
	pe[6] = ((p[2] * e[4] + p[6] * e[5]) + p[10] * e[6]) + p[14] * e[7];
	pe[7] = ((p[3] * e[4] + p[7] * e[5]) + p[11] * e[6]) + p[15] * e[7];
	pe[8] = ((p[0] * e[8] + p[4] * e[9]) + p[8] * e[10]) + p[12] * e[11];
	pe[9] = ((p[1] * e[8] + p[5] * e[9]) + p[9] * e[10]) + p[13] * e[11];
	pe[10] = ((p[2] * e[8] + p[6] * e[9]) + p[10] * e[10]) + p[14] * e[11];
	pe[11] = ((p[3] * e[8] + p[7] * e[9]) + p[11] * e[10]) + p[15] * e[11];
	pe[12] = ((p[0] * e[12] + p[4] * e[13]) + p[8] * e[14]) + p[12] * e[15];
	pe[13] = ((p[1] * e[12] + p[5] * e[13]) + p[9] * e[14]) + p[13] * e[15];
	pe[14] = ((p[2] * e[12] + p[6] * e[13]) + p[10] * e[14]) + p[14] * e[15];
	pe[15] = ((p[3] * e[12] + p[7] * e[13]) + p[11] * e[14]) + p[15] * e[15];
	{
		$s.pop();
		return pe;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.pointAt = function(pos,at,up) {
	$s.push("jsflash.geom.Matrix3D::pointAt");
	var $spos = $s.length;
	var currpos = this.get_position();
	var zvec = new jsflash.geom.Vector3D(currpos.x - pos.x,currpos.y - pos.y,currpos.z - pos.z);
	var xvec = at.clone();
	zvec.crossProduct(zvec);
	xvec.normalize();
	var yvec = zvec.clone();
	yvec.crossProduct(xvec);
	var rotMatrix = new jsflash.geom.Matrix3D([xvec.x,yvec.x,zvec.x,0,xvec.y,yvec.y,zvec.y,0,xvec.z,yvec.z,zvec.z,0,0,0,0,1]);
	this.append(rotMatrix);
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.posVectorHandler = function() {
	$s.push("jsflash.geom.Matrix3D::posVectorHandler");
	var $spos = $s.length;
	this.rawData[12] = this.position.x;
	this.rawData[13] = this.position.y;
	this.rawData[14] = this.position.z;
	this.rawData[15] = this.position.w;
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.position = null;
jsflash.geom.Matrix3D.prototype.prepend = function(rhs) {
	$s.push("jsflash.geom.Matrix3D::prepend");
	var $spos = $s.length;
	this.dirty = true;
	this.set_rawData(this.matrix44Calculat(rhs.rawData,this.rawData));
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.prependRotation = function(degrees,axis,pivotPoint) {
	$s.push("jsflash.geom.Matrix3D::prependRotation");
	var $spos = $s.length;
	this.dirty = true;
	if(pivotPoint == null) {
		pivotPoint = new jsflash.geom.Vector3D(0,0,0);
	}
	var tempAxis = axis.clone();
	tempAxis.normalize();
	var degreesPIper360 = (degrees / 360) * Math.PI;
	var w = Math.cos(degreesPIper360);
	var x = Math.sin(degreesPIper360) * tempAxis.x;
	var y = Math.sin(degreesPIper360) * tempAxis.y;
	var z = Math.sin(degreesPIper360) * tempAxis.z;
	var p = this.RawDataFromQuaternion(x,y,z,w);
	this.set_rawData(this.matrix44Calculat(p,this.rawData));
	this.appendTranslation(pivotPoint.x,pivotPoint.y,pivotPoint.z);
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.prependScale = function(xScale,yScale,zScale) {
	$s.push("jsflash.geom.Matrix3D::prependScale");
	var $spos = $s.length;
	this.dirty = true;
	this.rawData[0] *= xScale;
	this.rawData[1] *= xScale;
	this.rawData[2] *= xScale;
	this.rawData[3] *= xScale;
	this.rawData[4] *= yScale;
	this.rawData[5] *= yScale;
	this.rawData[6] *= yScale;
	this.rawData[7] *= yScale;
	this.rawData[8] *= zScale;
	this.rawData[9] *= zScale;
	this.rawData[10] *= zScale;
	this.rawData[11] *= zScale;
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.prependTranslation = function(x,y,z) {
	$s.push("jsflash.geom.Matrix3D::prependTranslation");
	var $spos = $s.length;
	this.rawData[12] += (this.rawData[0] * x + this.rawData[4] * y) + this.rawData[8] * z;
	this.rawData[13] += (this.rawData[1] * x + this.rawData[5] * y) + this.rawData[9] * z;
	this.rawData[14] += (this.rawData[2] * x + this.rawData[6] * y) + this.rawData[10] * z;
	this.rawData[15] += (this.rawData[3] * x + this.rawData[7] * y) + this.rawData[11] * z;
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.rawData = null;
jsflash.geom.Matrix3D.prototype.recompose = function(components,orientation) {
	$s.push("jsflash.geom.Matrix3D::recompose");
	var $spos = $s.length;
	this.dirty = true;
	if(orientation == null) orientation = jsflash.geom.Orientation3D.EULER_ANGLES;
	var scale = [];
	scale[0] = scale[1] = scale[2] = components[2].x;
	scale[4] = scale[5] = scale[6] = components[2].y;
	scale[8] = scale[9] = scale[10] = components[2].z;
	var v = [];
	var math = Math;
	var $e = (orientation);
	switch( $e[1] ) {
	case 1:
	{
		{
			var cx = math.cos(components[1].x);
			var cy = math.cos(components[1].y);
			var cz = math.cos(components[1].z);
			var sx = math.sin(components[1].x);
			var sy = math.sin(components[1].y);
			var sz = math.sin(components[1].z);
			v[0] = (cy * cz) * scale[0];
			v[1] = (cy * sz) * scale[1];
			v[2] = -sy * scale[2];
			v[3] = 0;
			v[4] = ((sx * sy) * cz - cx * sz) * scale[4];
			v[5] = ((sx * sy) * sz + cx * cz) * scale[5];
			v[6] = (sx * cy) * scale[6];
			v[7] = 0;
			v[8] = ((cx * sy) * cz + sx * sz) * scale[8];
			v[9] = ((cx * sy) * sz - sx * cz) * scale[9];
			v[10] = (cx * cy) * scale[10];
			v[11] = 0;
			v[12] = components[0].x;
			v[13] = components[0].y;
			v[14] = components[0].z;
			v[15] = 1;
		}
	}break;
	default:{
		{
			var x = components[1].x;
			var y = components[1].y;
			var z = components[1].z;
			var w = components[1].w;
			if(Type.enumEq(orientation,jsflash.geom.Orientation3D.AXIS_ANGLE)) {
				x *= math.sin(w / 2);
				y *= math.sin(w / 2);
				z *= math.sin(w / 2);
				w = math.cos(w / 2);
			}
			v[0] = ((1 - (2 * y) * y) - (2 * z) * z) * scale[0];
			v[1] = ((2 * x) * y + (2 * w) * z) * scale[1];
			v[2] = ((2 * x) * z - (2 * w) * y) * scale[2];
			v[3] = 0;
			v[4] = ((2 * x) * y - (2 * w) * z) * scale[4];
			v[5] = ((1 - (2 * x) * x) - (2 * z) * z) * scale[5];
			v[6] = ((2 * y) * z + (2 * w) * x) * scale[6];
			v[7] = 0;
			v[8] = ((2 * x) * z + (2 * w) * y) * scale[8];
			v[9] = ((2 * y) * z - (2 * w) * x) * scale[9];
			v[10] = ((1 - (2 * x) * x) - (2 * y) * y) * scale[10];
			v[11] = 0;
			v[12] = components[0].x;
			v[13] = components[0].y;
			v[14] = components[0].z;
			v[15] = 1;
		}
	}break;
	}
	if(components[2].x == 0) v[0] = 1e-15;
	if(components[2].y == 0) v[5] = 1e-15;
	if(components[2].z == 0) v[10] = 1e-15;
	this.set_rawData(v);
	{
		var $tmp = !(components[2].x == 0 || components[2].y == 0 || components[2].y == 0);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.rotation = null;
jsflash.geom.Matrix3D.prototype.sarrus = function(c0,c1,c2,c3,c4,c5,c6,c7,c8) {
	$s.push("jsflash.geom.Matrix3D::sarrus");
	var $spos = $s.length;
	{
		var $tmp = (((((c0 * c4) * c8 + (c3 * c7) * c2) + (c6 * c1) * c5) - (c6 * c4) * c2) - (c3 * c1) * c8) - (c0 * c7) * c5;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.scale = null;
jsflash.geom.Matrix3D.prototype.scaleRotationHandler = function() {
	$s.push("jsflash.geom.Matrix3D::scaleRotationHandler");
	var $spos = $s.length;
	this.checkDirty();
	var math = Math;
	var v = this.rawData;
	var rotation = this.rotation;
	var cx = math.cos(rotation.x * (3.141592653589793 / 180));
	var cy = math.cos(rotation.y * (3.141592653589793 / 180));
	var cz = math.cos(rotation.z * (3.141592653589793 / 180));
	var sx = math.sin(rotation.x * (3.141592653589793 / 180));
	var sy = math.sin(rotation.y * (3.141592653589793 / 180));
	var sz = math.sin(rotation.z * (3.141592653589793 / 180));
	var scale = this.scale;
	var sc_x = scale.x;
	var sc_y = scale.y;
	var sc_z = scale.z;
	v[0] = (cy * cz) * sc_x;
	v[1] = (cy * sz) * sc_x;
	v[2] = -sy * sc_x;
	v[4] = ((sx * sy) * cz - cx * sz) * sc_y;
	v[5] = ((sx * sy) * sz + cx * cz) * sc_y;
	v[6] = (sx * cy) * sc_y;
	v[8] = ((cx * sy) * cz + sx * sz) * sc_z;
	v[9] = ((cx * sy) * sz - sx * cz) * sc_z;
	v[10] = (cx * cy) * sc_z;
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_SWX = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_SWX");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData[3] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_SWY = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_SWY");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData[7] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_SWZ = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_SWZ");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData[11] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_SXX = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_SXX");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData[0] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_SXY = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_SXY");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData[4] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_SXZ = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_SXZ");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData[8] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_SYX = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_SYX");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData[1] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_SYY = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_SYY");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData[5] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_SYZ = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_SYZ");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData[9] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_SZX = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_SZX");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData[2] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_SZY = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_SZY");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData[6] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_SZZ = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_SZZ");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData[10] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_TW = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_TW");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[15] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_TX = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_TX");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[12] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_TY = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_TY");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[13] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_TZ = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_TZ");
	var $spos = $s.length;
	{
		var $tmp = this.rawData[14] = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_position = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_position");
	var $spos = $s.length;
	this.position = val;
	this.get_position().OnChange = $closure(this,"posVectorHandler");
	this.posVectorHandler();
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_rawData = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_rawData");
	var $spos = $s.length;
	this.dirty = true;
	{
		var $tmp = this.rawData = val.concat([]);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_rotation = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_rotation");
	var $spos = $s.length;
	val.OnChange = $closure(this,"scaleRotationHandler");
	this.scaleRotationHandler();
	{
		var $tmp = this.rotation = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.set_scale = function(val) {
	$s.push("jsflash.geom.Matrix3D::set_scale");
	var $spos = $s.length;
	val.OnChange = $closure(this,"scaleRotationHandler");
	this.scaleRotationHandler();
	{
		var $tmp = this.scale = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.transformVector = function(v) {
	$s.push("jsflash.geom.Matrix3D::transformVector");
	var $spos = $s.length;
	var ret = new jsflash.geom.Vector3D();
	ret.set_x(((this.rawData[0] * v.x + this.rawData[4] * v.y) + this.rawData[8] * v.z) + this.rawData[12]);
	ret.set_y(((this.rawData[1] * v.x + this.rawData[5] * v.y) + this.rawData[9] * v.z) + this.rawData[13]);
	ret.set_z(((this.rawData[2] * v.x + this.rawData[6] * v.y) + this.rawData[10] * v.z) + this.rawData[14]);
	ret.set_w(((this.rawData[3] * v.x + this.rawData[7] * v.y) + this.rawData[11] * v.z) + this.rawData[15]);
	{
		$s.pop();
		return ret;
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.transformVectors = function(vin,vout) {
	$s.push("jsflash.geom.Matrix3D::transformVectors");
	var $spos = $s.length;
	var n = vin.length;
	var temp = new Array();
	var i = -3;
	while((i += 3) < n) {
		vout[i] = ((this.rawData[0] * vin[i] + this.rawData[4] * vin[i + 1]) + this.rawData[8] * vin[i + 2]) + this.rawData[12];
		vout[i + 1] = ((this.rawData[1] * vin[i] + this.rawData[5] * vin[i + 1]) + this.rawData[9] * vin[i + 2]) + this.rawData[13];
		vout[i + 2] = ((this.rawData[2] * vin[i] + this.rawData[6] * vin[i + 1]) + this.rawData[10] * vin[i + 2]) + this.rawData[14];
	}
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.transpose = function() {
	$s.push("jsflash.geom.Matrix3D::transpose");
	var $spos = $s.length;
	this.dirty = true;
	this.set_rawData([this.rawData[0],this.rawData[4],this.rawData[8],this.rawData[12],this.rawData[1],this.rawData[5],this.rawData[9],this.rawData[13],this.rawData[2],this.rawData[6],this.rawData[10],this.rawData[14],this.rawData[3],this.rawData[7],this.rawData[11],this.rawData[15]]);
	$s.pop();
}
jsflash.geom.Matrix3D.prototype.__class__ = jsflash.geom.Matrix3D;
away3dlite.haxeutils.MathUtils = function() { }
away3dlite.haxeutils.MathUtils.__name__ = ["away3dlite","haxeutils","MathUtils"];
away3dlite.haxeutils.MathUtils.prototype.__class__ = away3dlite.haxeutils.MathUtils;
away3dlite.materials.ColorMaterial = function(color,alpha) { if( color === $_ ) return; {
	$s.push("away3dlite.materials.ColorMaterial::new");
	var $spos = $s.length;
	if(alpha == null) alpha = 1.0;
	away3dlite.materials.Material.apply(this,[]);
	this._color = ((color != null)?away3dlite.core.utils.Cast.color(color):away3dlite.core.utils.Cast.color("random"));
	this._alpha = alpha;
	this._wglColor = [((this._color >> 16) & 255) / 255,((this._color >> 8) & 255) / 255,(this._color & 255) / 255,alpha];
	$s.pop();
}}
away3dlite.materials.ColorMaterial.__name__ = ["away3dlite","materials","ColorMaterial"];
away3dlite.materials.ColorMaterial.__super__ = away3dlite.materials.Material;
for(var k in away3dlite.materials.Material.prototype ) away3dlite.materials.ColorMaterial.prototype[k] = away3dlite.materials.Material.prototype[k];
away3dlite.materials.ColorMaterial._context = null;
away3dlite.materials.ColorMaterial.prototype._alpha = null;
away3dlite.materials.ColorMaterial.prototype._color = null;
away3dlite.materials.ColorMaterial.prototype._wglColor = null;
away3dlite.materials.ColorMaterial.prototype.alpha = null;
away3dlite.materials.ColorMaterial.prototype.color = null;
away3dlite.materials.ColorMaterial.prototype.fragmentShaderSource = function() {
	$s.push("away3dlite.materials.ColorMaterial::fragmentShaderSource");
	var $spos = $s.length;
	{
		$s.pop();
		return "varying vec4 vColor;\r\n\t\t\r\n\t\tvoid main(void) {\r\n\t\t        gl_FragColor = vColor;\r\n\t\t}";
	}
	$s.pop();
}
away3dlite.materials.ColorMaterial.prototype.get_alpha = function() {
	$s.push("away3dlite.materials.ColorMaterial::get_alpha");
	var $spos = $s.length;
	{
		var $tmp = this._alpha;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.ColorMaterial.prototype.get_color = function() {
	$s.push("away3dlite.materials.ColorMaterial::get_color");
	var $spos = $s.length;
	{
		var $tmp = this._color;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.ColorMaterial.prototype.initializeWebGL = function() {
	$s.push("away3dlite.materials.ColorMaterial::initializeWebGL");
	var $spos = $s.length;
	this.gl = jsflash.Manager.stage.RenderingContext;
	if(away3dlite.materials.ColorMaterial._context == null) {
		var vShader = this.gl.createShader(webgl.wrappers.GLEnum.VERTEX_SHADER);
		this.gl.shaderSource(vShader,this.vertexShaderSource());
		this.gl.compileShader(vShader);
		if(!this.gl.getShaderParameter(vShader,webgl.wrappers.GLEnum.COMPILE_STATUS)) {
			var resp = this.gl.getShaderInfoLog(vShader);
			js.Lib.alert(resp);
			throw resp;
		}
		var fShader = this.gl.createShader(webgl.wrappers.GLEnum.FRAGMENT_SHADER);
		this.gl.shaderSource(fShader,this.fragmentShaderSource());
		this.gl.compileShader(fShader);
		if(!this.gl.getShaderParameter(fShader,webgl.wrappers.GLEnum.COMPILE_STATUS)) {
			var resp = this.gl.getShaderInfoLog(fShader);
			js.Lib.alert(resp);
			throw resp;
		}
		var program = this.gl.createProgram();
		this.gl.attachShader(program,vShader);
		this.gl.attachShader(program,fShader);
		this.gl.linkProgram(program);
		if(!this.gl.getProgramParameter(program,webgl.wrappers.GLEnum.LINK_STATUS)) {
			js.Lib.alert("Could not initialise shaders");
			throw "Could not initialise shaders";
		}
		var uniformLocations = new Hash();
		this.gl.useProgram(program);
		uniformLocations.set("uCamMatrix",this.gl.getUniformLocation(program,"uCamMatrix"));
		uniformLocations.set("uMVMatrix",this.gl.getUniformLocation(program,"uMVMatrix"));
		uniformLocations.set("uColor",this.gl.getUniformLocation(program,"uColor"));
		var attribLocations = new Hash();
		attribLocations.set("aVertexPosition",this.gl.getAttribLocation(program,"aVertexPosition"));
		this.gl.enableVertexAttribArray(attribLocations.get("aVertexPosition"));
		this.context = away3dlite.materials.ColorMaterial._context = { vShader : vShader, fShader : fShader, program : program, uniformLocations : uniformLocations, attribLocations : attribLocations}
	}
	else {
		this.context = away3dlite.materials.ColorMaterial._context;
	}
	$s.pop();
}
away3dlite.materials.ColorMaterial.prototype.set_alpha = function(val) {
	$s.push("away3dlite.materials.ColorMaterial::set_alpha");
	var $spos = $s.length;
	if(this._alpha == val) {
		$s.pop();
		return val;
	}
	this._alpha = val;
	this._wglColor[3] = this._alpha;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.materials.ColorMaterial.prototype.set_color = function(val) {
	$s.push("away3dlite.materials.ColorMaterial::set_color");
	var $spos = $s.length;
	if(this._color == val) {
		$s.pop();
		return val;
	}
	this._color = val;
	this._wglColor = [((val >> 16) & 255) / 255,((val >> 8) & 255) / 255,(val & 255) / 255,this._alpha];
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.materials.ColorMaterial.prototype.updateUniforms = function(camera,mesh,stage) {
	$s.push("away3dlite.materials.ColorMaterial::updateUniforms");
	var $spos = $s.length;
	this.gl.useProgram(this.context.program);
	this.gl.uniformMatrix4fv(this.context.uniformLocations.get("uCamMatrix"),false,new webgl.WebGLFloatArray(stage.transform.perspectiveProjection.toMatrix3D().rawData));
	var m = mesh.get_sceneMatrix3D().clone();
	m.append(camera.get_invSceneMatrix3D());
	this.gl.uniformMatrix4fv(this.context.uniformLocations.get("uMVMatrix"),false,new webgl.WebGLFloatArray(m.rawData));
	this.gl.uniform4fv(this.context.uniformLocations.get("uColor"),this._wglColor);
	$s.pop();
}
away3dlite.materials.ColorMaterial.prototype.vertexShaderSource = function() {
	$s.push("away3dlite.materials.ColorMaterial::vertexShaderSource");
	var $spos = $s.length;
	{
		$s.pop();
		return "attribute vec3 aVertexPosition;\r\n\t\t\r\n\t\tuniform mat4 uCamMatrix;\r\n\t\tuniform mat4 uMVMatrix;\r\n\t\tuniform vec4 uColor;\r\n\t\t\r\n\t\tvarying vec4 vColor;\r\n\t\t\r\n\t\tvoid main(void) {\r\n\t\t\tgl_Position = uCamMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);\r\n\t\t\tvColor = uColor;\r\n\t\t}";
	}
	$s.pop();
}
away3dlite.materials.ColorMaterial.prototype.__class__ = away3dlite.materials.ColorMaterial;
away3dlite.materials.WireColorMaterial = function(color,alpha,wireColor,wireAlpha,thickness) { if( color === $_ ) return; {
	$s.push("away3dlite.materials.WireColorMaterial::new");
	var $spos = $s.length;
	if(thickness == null) thickness = 1.0;
	if(wireAlpha == null) wireAlpha = 1.0;
	if(alpha == null) alpha = 1.0;
	away3dlite.materials.ColorMaterial.apply(this,[color,alpha]);
	this._wireColor = ((wireColor != null)?away3dlite.core.utils.Cast.color(wireColor):0);
	this._wireAlpha = wireAlpha;
	this._thickness = thickness;
	$s.pop();
}}
away3dlite.materials.WireColorMaterial.__name__ = ["away3dlite","materials","WireColorMaterial"];
away3dlite.materials.WireColorMaterial.__super__ = away3dlite.materials.ColorMaterial;
for(var k in away3dlite.materials.ColorMaterial.prototype ) away3dlite.materials.WireColorMaterial.prototype[k] = away3dlite.materials.ColorMaterial.prototype[k];
away3dlite.materials.WireColorMaterial.prototype._thickness = null;
away3dlite.materials.WireColorMaterial.prototype._wireAlpha = null;
away3dlite.materials.WireColorMaterial.prototype._wireColor = null;
away3dlite.materials.WireColorMaterial.prototype.get_thickness = function() {
	$s.push("away3dlite.materials.WireColorMaterial::get_thickness");
	var $spos = $s.length;
	{
		var $tmp = this._thickness;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.WireColorMaterial.prototype.get_wireAlpha = function() {
	$s.push("away3dlite.materials.WireColorMaterial::get_wireAlpha");
	var $spos = $s.length;
	{
		var $tmp = this._wireAlpha;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.WireColorMaterial.prototype.get_wireColor = function() {
	$s.push("away3dlite.materials.WireColorMaterial::get_wireColor");
	var $spos = $s.length;
	{
		var $tmp = this._wireColor;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.materials.WireColorMaterial.prototype.renderMesh = function(mesh,camera,stage) {
	$s.push("away3dlite.materials.WireColorMaterial::renderMesh");
	var $spos = $s.length;
	if(mesh.indicesBuffer == null || mesh.verticesBuffer == null) {
		$s.pop();
		return;
	}
	this.gl.useProgram(this.context.program);
	this.updateUniforms(camera,mesh,stage);
	this.gl.bindBuffer(webgl.wrappers.GLEnum.ARRAY_BUFFER,mesh.verticesBuffer);
	this.gl.vertexAttribPointer(this.context.attribLocations.get("aVertexPosition"),3,webgl.wrappers.GLEnum.FLOAT,false,0,0);
	this.gl.bindBuffer(webgl.wrappers.GLEnum.ELEMENT_ARRAY_BUFFER,mesh.indicesBuffer);
	this.gl.drawElements(webgl.wrappers.GLEnum.TRIANGLES,mesh.numItems,webgl.wrappers.GLEnum.UNSIGNED_SHORT,0);
	this.gl.lineWidth(3);
	this.gl.drawElements(webgl.wrappers.GLEnum.LINES,mesh.numItems,webgl.wrappers.GLEnum.UNSIGNED_SHORT,0);
	$s.pop();
}
away3dlite.materials.WireColorMaterial.prototype.set_thickness = function(val) {
	$s.push("away3dlite.materials.WireColorMaterial::set_thickness");
	var $spos = $s.length;
	if(this._thickness == val) {
		$s.pop();
		return val;
	}
	this._thickness = val;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.materials.WireColorMaterial.prototype.set_wireAlpha = function(val) {
	$s.push("away3dlite.materials.WireColorMaterial::set_wireAlpha");
	var $spos = $s.length;
	if(this._wireAlpha == val) {
		$s.pop();
		return val;
	}
	this._wireAlpha = val;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.materials.WireColorMaterial.prototype.set_wireColor = function(val) {
	$s.push("away3dlite.materials.WireColorMaterial::set_wireColor");
	var $spos = $s.length;
	if(this._wireColor == val) {
		$s.pop();
		return val;
	}
	this._wireColor = val;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.materials.WireColorMaterial.prototype.thickness = null;
away3dlite.materials.WireColorMaterial.prototype.wireAlpha = null;
away3dlite.materials.WireColorMaterial.prototype.wireColor = null;
away3dlite.materials.WireColorMaterial.prototype.__class__ = away3dlite.materials.WireColorMaterial;
away3dlite.animators.BonesAnimator = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.animators.BonesAnimator::new");
	var $spos = $s.length;
	away3dlite.core.utils.Debug.trace(" + bonesAnimator",{ fileName : "BonesAnimator.hx", lineNumber : 43, className : "away3dlite.animators.BonesAnimator", methodName : "new"});
	this._channels = new Array();
	this._skinControllers = new Array();
	this._skinVertices = new Array();
	this.loop = true;
	this.length = 0;
	$s.pop();
}}
away3dlite.animators.BonesAnimator.__name__ = ["away3dlite","animators","BonesAnimator"];
away3dlite.animators.BonesAnimator.prototype._channels = null;
away3dlite.animators.BonesAnimator.prototype._skinController = null;
away3dlite.animators.BonesAnimator.prototype._skinControllers = null;
away3dlite.animators.BonesAnimator.prototype._skinVertex = null;
away3dlite.animators.BonesAnimator.prototype._skinVertices = null;
away3dlite.animators.BonesAnimator.prototype.addChannel = function(channel) {
	$s.push("away3dlite.animators.BonesAnimator::addChannel");
	var $spos = $s.length;
	this._channels.push(channel);
	$s.pop();
}
away3dlite.animators.BonesAnimator.prototype.addSkinController = function(skinController) {
	$s.push("away3dlite.animators.BonesAnimator::addSkinController");
	var $spos = $s.length;
	if(away3dlite.haxeutils.ArrayUtils.indexOf(this._skinControllers,skinController) != -1) {
		$s.pop();
		return;
	}
	this._skinControllers.push(skinController);
	{
		var _g = 0, _g1 = skinController.skinVertices;
		while(_g < _g1.length) {
			var _skinVertex = _g1[_g];
			++_g;
			if(away3dlite.haxeutils.ArrayUtils.indexOf(this._skinVertices,_skinVertex) == -1) this._skinVertices.push(_skinVertex);
		}
	}
	$s.pop();
}
away3dlite.animators.BonesAnimator.prototype.clone = function(object) {
	$s.push("away3dlite.animators.BonesAnimator::clone");
	var $spos = $s.length;
	var bonesAnimator = new away3dlite.animators.BonesAnimator();
	bonesAnimator.loop = this.loop;
	bonesAnimator.length = this.length;
	bonesAnimator.start = this.start;
	{
		var _g = 0, _g1 = this._channels;
		while(_g < _g1.length) {
			var channel = _g1[_g];
			++_g;
			bonesAnimator.addChannel(channel.clone(object));
		}
	}
	{
		$s.pop();
		return bonesAnimator;
	}
	$s.pop();
}
away3dlite.animators.BonesAnimator.prototype.length = null;
away3dlite.animators.BonesAnimator.prototype.loop = null;
away3dlite.animators.BonesAnimator.prototype.start = null;
away3dlite.animators.BonesAnimator.prototype.update = function(time,interpolate) {
	$s.push("away3dlite.animators.BonesAnimator::update");
	var $spos = $s.length;
	if(interpolate == null) interpolate = true;
	if(time > this.start + this.length) {
		if(this.loop) {
			time = this.start + (time - this.start) % this.length;
		}
		else {
			time = this.start + this.length;
		}
	}
	else if(time < this.start) {
		if(this.loop) {
			time = (this.start + (time - this.start) % this.length) + this.length;
		}
		else {
			time = this.start;
		}
	}
	{
		var _g = 0, _g1 = this._channels;
		while(_g < _g1.length) {
			var channel = _g1[_g];
			++_g;
			channel.update(time,interpolate);
		}
	}
	{
		var _g = 0, _g1 = this._skinControllers;
		while(_g < _g1.length) {
			var _skinController = _g1[_g];
			++_g;
			_skinController.update();
		}
	}
	{
		var _g = 0, _g1 = this._skinVertices;
		while(_g < _g1.length) {
			var _skinVertex = _g1[_g];
			++_g;
			_skinVertex.update();
		}
	}
	$s.pop();
}
away3dlite.animators.BonesAnimator.prototype.__class__ = away3dlite.animators.BonesAnimator;
if(typeof webgl=='undefined') webgl = {}
webgl.WebGL = function() { }
webgl.WebGL.__name__ = ["webgl","WebGL"];
webgl.WebGL.init = function(canvas,parameters) {
	$s.push("webgl.WebGL::init");
	var $spos = $s.length;
	var ret = null;
	try {
		if(parameters != null) ret = canvas.getContext("experimental-webgl",parameters);
		else ret = canvas.getContext("experimental-webgl");
	}
	catch( $e25 ) {
		{
			var e = $e25;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				null;
			}
		}
	}
	if(ret == null) {
		js.Lib.alert("No WebGL Context was found!");
		throw "No WebGL Context was found!";
	}
	if (!webgl.wrappers) webgl.wrappers = {}
	webgl.wrappers.GLEnum = ret;
	{
		$s.pop();
		return ret;
	}
	$s.pop();
}
webgl.WebGL.prototype.__class__ = webgl.WebGL;
if(!away3dlite.cameras) away3dlite.cameras = {}
away3dlite.cameras.Camera3D = function(zoom,focus) { if( zoom === $_ ) return; {
	$s.push("away3dlite.cameras.Camera3D::new");
	var $spos = $s.length;
	if(focus == null) focus = 10;
	if(zoom == null) zoom = 10;
	away3dlite.core.base.Object3D.apply(this,[]);
	this._screenMatrix3D = new jsflash.geom.Matrix3D();
	this._invSceneMatrix3D = new jsflash.geom.Matrix3D();
	this._fieldOfViewDirty = true;
	this.set_zoom(zoom);
	this.set_focus(focus);
	this.set_z(1000);
	$s.pop();
}}
away3dlite.cameras.Camera3D.__name__ = ["away3dlite","cameras","Camera3D"];
away3dlite.cameras.Camera3D.__super__ = away3dlite.core.base.Object3D;
for(var k in away3dlite.core.base.Object3D.prototype ) away3dlite.cameras.Camera3D.prototype[k] = away3dlite.core.base.Object3D.prototype[k];
away3dlite.cameras.Camera3D.prototype._fieldOfViewDirty = null;
away3dlite.cameras.Camera3D.prototype._focus = null;
away3dlite.cameras.Camera3D.prototype._invSceneMatrix3D = null;
away3dlite.cameras.Camera3D.prototype._projection = null;
away3dlite.cameras.Camera3D.prototype._projectionMatrix3D = null;
away3dlite.cameras.Camera3D.prototype._screenMatrix3D = null;
away3dlite.cameras.Camera3D.prototype._view = null;
away3dlite.cameras.Camera3D.prototype._zoom = null;
away3dlite.cameras.Camera3D.prototype.focus = null;
away3dlite.cameras.Camera3D.prototype.get_focus = function() {
	$s.push("away3dlite.cameras.Camera3D::get_focus");
	var $spos = $s.length;
	{
		var $tmp = this._focus;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.cameras.Camera3D.prototype.get_invSceneMatrix3D = function() {
	$s.push("away3dlite.cameras.Camera3D::get_invSceneMatrix3D");
	var $spos = $s.length;
	{
		var $tmp = this._invSceneMatrix3D;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.cameras.Camera3D.prototype.get_projectionMatrix3D = function() {
	$s.push("away3dlite.cameras.Camera3D::get_projectionMatrix3D");
	var $spos = $s.length;
	{
		var $tmp = this._projectionMatrix3D;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.cameras.Camera3D.prototype.get_screenMatrix3D = function() {
	$s.push("away3dlite.cameras.Camera3D::get_screenMatrix3D");
	var $spos = $s.length;
	{
		var $tmp = this._screenMatrix3D;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.cameras.Camera3D.prototype.get_zoom = function() {
	$s.push("away3dlite.cameras.Camera3D::get_zoom");
	var $spos = $s.length;
	{
		var $tmp = this._zoom;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.cameras.Camera3D.prototype.invSceneMatrix3D = null;
away3dlite.cameras.Camera3D.prototype.projectionMatrix3D = null;
away3dlite.cameras.Camera3D.prototype.screenMatrix3D = null;
away3dlite.cameras.Camera3D.prototype.set_focus = function(val) {
	$s.push("away3dlite.cameras.Camera3D::set_focus");
	var $spos = $s.length;
	this._focus = val;
	this._fieldOfViewDirty = true;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.cameras.Camera3D.prototype.set_zoom = function(val) {
	$s.push("away3dlite.cameras.Camera3D::set_zoom");
	var $spos = $s.length;
	this._zoom = val;
	this._fieldOfViewDirty = true;
	{
		$s.pop();
		return val;
	}
	$s.pop();
}
away3dlite.cameras.Camera3D.prototype.update = function() {
	$s.push("away3dlite.cameras.Camera3D::update");
	var $spos = $s.length;
	this._projection = this.root.transform.perspectiveProjection;
	this._projectionMatrix3D = this._projection.toMatrix3D();
	this._invSceneMatrix3D = this.transform.matrix3D.clone();
	this._invSceneMatrix3D.prependTranslation(0,0,-this._focus);
	this._invSceneMatrix3D.invert();
	this._screenMatrix3D = this._invSceneMatrix3D.clone();
	this._screenMatrix3D.append(this._projectionMatrix3D);
	$s.pop();
}
away3dlite.cameras.Camera3D.prototype.zoom = null;
away3dlite.cameras.Camera3D.prototype.__class__ = away3dlite.cameras.Camera3D;
Std = function() { }
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	$s.push("Std::is");
	var $spos = $s.length;
	{
		var $tmp = js.Boot.__instanceof(v,t);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Std.string = function(s) {
	$s.push("Std::string");
	var $spos = $s.length;
	{
		var $tmp = js.Boot.__string_rec(s,"");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Std["int"] = function(x) {
	$s.push("Std::int");
	var $spos = $s.length;
	if(x < 0) {
		var $tmp = Math.ceil(x);
		$s.pop();
		return $tmp;
	}
	{
		var $tmp = Math.floor(x);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Std.parseInt = function(x) {
	$s.push("Std::parseInt");
	var $spos = $s.length;
	var v = parseInt(x);
	if(Math.isNaN(v)) {
		$s.pop();
		return null;
	}
	{
		$s.pop();
		return v;
	}
	$s.pop();
}
Std.parseFloat = function(x) {
	$s.push("Std::parseFloat");
	var $spos = $s.length;
	{
		var $tmp = parseFloat(x);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Std.random = function(x) {
	$s.push("Std::random");
	var $spos = $s.length;
	{
		var $tmp = Math.floor(Math.random() * x);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Std.prototype.__class__ = Std;
jsflash.Manager = function() { }
jsflash.Manager.__name__ = ["jsflash","Manager"];
jsflash.Manager.current = null;
jsflash.Manager.stage = null;
jsflash.Manager.init = function(canvas,width,height) {
	$s.push("jsflash.Manager::init");
	var $spos = $s.length;
	if(canvas == null) canvas = js.Lib.document.createElement("canvas");
	if(width != null) canvas.width = width;
	if(height != null) canvas.height = height;
	jsflash.Manager.stage = new jsflash.display.Stage(canvas);
	jsflash.Manager.current = new jsflash.display.Sprite();
	jsflash.Manager.stage.addChild(jsflash.Manager.current);
	jsflash.Lib.current = jsflash.Manager.current;
	$s.pop();
}
jsflash.Manager.setupWebGL = function(stage) {
	$s.push("jsflash.Manager::setupWebGL");
	var $spos = $s.length;
	if(stage == null) stage = jsflash.Manager.stage;
	var gl = stage.RenderingContext;
	gl.viewport(0,0,Std["int"](stage.get_stageWidth()),Std["int"](stage.get_stageHeight()));
	gl.clearColor(0.0,0.0,0.0,1.0);
	gl.clearDepth(1.0);
	gl.enable(webgl.wrappers.GLEnum.DEPTH_TEST);
	gl.depthFunc(webgl.wrappers.GLEnum.LEQUAL);
	gl.cullFace(webgl.wrappers.GLEnum.FRONT);
	$s.pop();
}
jsflash.Manager.prototype.__class__ = jsflash.Manager;
haxe.Timer = function(time_ms) { if( time_ms === $_ ) return; {
	$s.push("haxe.Timer::new");
	var $spos = $s.length;
	this.id = haxe.Timer.arr.length;
	haxe.Timer.arr[this.id] = this;
	this.timerId = window.setInterval(("haxe.Timer.arr[" + this.id) + "].run();",time_ms);
	$s.pop();
}}
haxe.Timer.__name__ = ["haxe","Timer"];
haxe.Timer.delay = function(f,time_ms) {
	$s.push("haxe.Timer::delay");
	var $spos = $s.length;
	var t = new haxe.Timer(time_ms);
	t.run = function() {
		$s.push("haxe.Timer::delay@78");
		var $spos = $s.length;
		t.stop();
		f();
		$s.pop();
	}
	{
		$s.pop();
		return t;
	}
	$s.pop();
}
haxe.Timer.stamp = function() {
	$s.push("haxe.Timer::stamp");
	var $spos = $s.length;
	{
		var $tmp = Date.now().getTime() / 1000;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.Timer.prototype.id = null;
haxe.Timer.prototype.run = function() {
	$s.push("haxe.Timer::run");
	var $spos = $s.length;
	null;
	$s.pop();
}
haxe.Timer.prototype.stop = function() {
	$s.push("haxe.Timer::stop");
	var $spos = $s.length;
	if(this.id == null) {
		$s.pop();
		return;
	}
	window.clearInterval(this.timerId);
	haxe.Timer.arr[this.id] = null;
	if(this.id > 100 && this.id == haxe.Timer.arr.length - 1) {
		var p = this.id - 1;
		while(p >= 0 && haxe.Timer.arr[p] == null) p--;
		haxe.Timer.arr = haxe.Timer.arr.slice(0,p + 1);
	}
	this.id = null;
	$s.pop();
}
haxe.Timer.prototype.timerId = null;
haxe.Timer.prototype.__class__ = haxe.Timer;
away3dlite.loaders.data.AnimationData = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.loaders.data.AnimationData::new");
	var $spos = $s.length;
	this.start = Math.POSITIVE_INFINITY;
	this.end = 0;
	this.animationType = "skinAnimation";
	this.channels = new Hash();
	$s.pop();
}}
away3dlite.loaders.data.AnimationData.__name__ = ["away3dlite","loaders","data","AnimationData"];
away3dlite.loaders.data.AnimationData.prototype.animation = null;
away3dlite.loaders.data.AnimationData.prototype.animationType = null;
away3dlite.loaders.data.AnimationData.prototype.channels = null;
away3dlite.loaders.data.AnimationData.prototype.clone = function(object) {
	$s.push("away3dlite.loaders.data.AnimationData::clone");
	var $spos = $s.length;
	var animationData = object.animationLibrary.addAnimation(this.name);
	animationData.start = this.start;
	animationData.end = this.end;
	animationData.animationType = this.animationType;
	animationData.animation = this.animation.clone(object);
	{
		$s.pop();
		return animationData;
	}
	$s.pop();
}
away3dlite.loaders.data.AnimationData.prototype.end = null;
away3dlite.loaders.data.AnimationData.prototype.name = null;
away3dlite.loaders.data.AnimationData.prototype.start = null;
away3dlite.loaders.data.AnimationData.prototype.__class__ = away3dlite.loaders.data.AnimationData;
jsflash.events.EventPhase = function() { }
jsflash.events.EventPhase.__name__ = ["jsflash","events","EventPhase"];
jsflash.events.EventPhase.prototype.__class__ = jsflash.events.EventPhase;
jsflash.display.TriangleCulling = { __ename__ : ["jsflash","display","TriangleCulling"], __constructs__ : ["NONE","POSITIVE","NEGATIVE"] }
jsflash.display.TriangleCulling.NEGATIVE = ["NEGATIVE",2];
jsflash.display.TriangleCulling.NEGATIVE.toString = $estr;
jsflash.display.TriangleCulling.NEGATIVE.__enum__ = jsflash.display.TriangleCulling;
jsflash.display.TriangleCulling.NONE = ["NONE",0];
jsflash.display.TriangleCulling.NONE.toString = $estr;
jsflash.display.TriangleCulling.NONE.__enum__ = jsflash.display.TriangleCulling;
jsflash.display.TriangleCulling.POSITIVE = ["POSITIVE",1];
jsflash.display.TriangleCulling.POSITIVE.toString = $estr;
jsflash.display.TriangleCulling.POSITIVE.__enum__ = jsflash.display.TriangleCulling;
away3dlite.loaders.utils.AnimationLibrary = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.loaders.utils.AnimationLibrary::new");
	var $spos = $s.length;
	Hash.apply(this,[]);
	$s.pop();
}}
away3dlite.loaders.utils.AnimationLibrary.__name__ = ["away3dlite","loaders","utils","AnimationLibrary"];
away3dlite.loaders.utils.AnimationLibrary.__super__ = Hash;
for(var k in Hash.prototype ) away3dlite.loaders.utils.AnimationLibrary.prototype[k] = Hash.prototype[k];
away3dlite.loaders.utils.AnimationLibrary.prototype.addAnimation = function(name) {
	$s.push("away3dlite.loaders.utils.AnimationLibrary::addAnimation");
	var $spos = $s.length;
	if(this.exists(name)) {
		var $tmp = this.get(name);
		$s.pop();
		return $tmp;
	}
	var animationData = new away3dlite.loaders.data.AnimationData();
	this.set(animationData.name = name,animationData);
	{
		$s.pop();
		return animationData;
	}
	$s.pop();
}
away3dlite.loaders.utils.AnimationLibrary.prototype.getAnimation = function(name) {
	$s.push("away3dlite.loaders.utils.AnimationLibrary::getAnimation");
	var $spos = $s.length;
	if(this.exists(name)) {
		var $tmp = this.get(name);
		$s.pop();
		return $tmp;
	}
	away3dlite.core.utils.Debug.warning(("Animation '" + name) + "' does not exist",{ fileName : "AnimationLibrary.hx", lineNumber : 39, className : "away3dlite.loaders.utils.AnimationLibrary", methodName : "getAnimation"});
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
away3dlite.loaders.utils.AnimationLibrary.prototype.__class__ = away3dlite.loaders.utils.AnimationLibrary;
if(!jsflash.utils) jsflash.utils = {}
jsflash.utils.ByteArray = function(p) { if( p === $_ ) return; {
	$s.push("jsflash.utils.ByteArray::new");
	var $spos = $s.length;
	null;
	$s.pop();
}}
jsflash.utils.ByteArray.__name__ = ["jsflash","utils","ByteArray"];
jsflash.utils.ByteArray.prototype.__class__ = jsflash.utils.ByteArray;
away3dlite.core.clip.RectangleClipping = function(minX,maxX,minY,maxY,minZ,maxZ) { if( minX === $_ ) return; {
	$s.push("away3dlite.core.clip.RectangleClipping::new");
	var $spos = $s.length;
	if(maxZ == null) maxZ = 100000;
	if(minZ == null) minZ = -100000;
	if(maxY == null) maxY = 100000;
	if(minY == null) minY = -100000;
	if(maxX == null) maxX = 100000;
	if(minX == null) minX = -100000;
	away3dlite.core.clip.Clipping.apply(this,[minX,maxX,minY,maxY,minZ,maxZ]);
	$s.pop();
}}
away3dlite.core.clip.RectangleClipping.__name__ = ["away3dlite","core","clip","RectangleClipping"];
away3dlite.core.clip.RectangleClipping.__super__ = away3dlite.core.clip.Clipping;
for(var k in away3dlite.core.clip.Clipping.prototype ) away3dlite.core.clip.RectangleClipping.prototype[k] = away3dlite.core.clip.Clipping.prototype[k];
away3dlite.core.clip.RectangleClipping.prototype.clone = function(object) {
	$s.push("away3dlite.core.clip.RectangleClipping::clone");
	var $spos = $s.length;
	var clipping = ((object != null)?jsflash.Lib["as"](object,away3dlite.core.clip.RectangleClipping):new away3dlite.core.clip.RectangleClipping());
	away3dlite.core.clip.Clipping.prototype.clone.apply(this,[clipping]);
	{
		$s.pop();
		return clipping;
	}
	$s.pop();
}
away3dlite.core.clip.RectangleClipping.prototype.collectFaces = function(mesh,faces) {
	$s.push("away3dlite.core.clip.RectangleClipping::collectFaces");
	var $spos = $s.length;
	null;
	$s.pop();
}
away3dlite.core.clip.RectangleClipping.prototype.__class__ = away3dlite.core.clip.RectangleClipping;
away3dlite.core.render.BasicRenderer = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.core.render.BasicRenderer::new");
	var $spos = $s.length;
	away3dlite.core.render.Renderer.apply(this,[]);
	$s.pop();
}}
away3dlite.core.render.BasicRenderer.__name__ = ["away3dlite","core","render","BasicRenderer"];
away3dlite.core.render.BasicRenderer.__super__ = away3dlite.core.render.Renderer;
for(var k in away3dlite.core.render.Renderer.prototype ) away3dlite.core.render.BasicRenderer.prototype[k] = away3dlite.core.render.Renderer.prototype[k];
away3dlite.core.render.BasicRenderer.prototype.__class__ = away3dlite.core.render.BasicRenderer;
jsflash.display.Stage = function(canvas) { if( canvas === $_ ) return; {
	$s.push("jsflash.display.Stage::new");
	var $spos = $s.length;
	jsflash.display.DisplayObjectContainer.apply(this,[]);
	this.Canvas = canvas;
	this.stage = this;
	this.root = this;
	this.transform.perspectiveProjection = new jsflash.geom.PerspectiveProjection();
	this.transform.perspectiveProjection.set_fieldOfView(45);
	this.set_frameRate(30);
	this.RenderingContext = webgl.WebGL.init(canvas);
	this.setupEventHandlers();
	$s.pop();
}}
jsflash.display.Stage.__name__ = ["jsflash","display","Stage"];
jsflash.display.Stage.__super__ = jsflash.display.DisplayObjectContainer;
for(var k in jsflash.display.DisplayObjectContainer.prototype ) jsflash.display.Stage.prototype[k] = jsflash.display.DisplayObjectContainer.prototype[k];
jsflash.display.Stage.prototype.Canvas = null;
jsflash.display.Stage.prototype.RenderingContext = null;
jsflash.display.Stage.prototype.enterFrameDispatch = function(dispObj) {
	$s.push("jsflash.display.Stage::enterFrameDispatch");
	var $spos = $s.length;
	if(dispObj.hasEventListener(jsflash.events.Event.ENTER_FRAME)) {
		dispObj.dispatchEvent(new jsflash.events.Event(jsflash.events.Event.ENTER_FRAME,false,false,false));
	}
	if(Std["is"](dispObj,jsflash.display.DisplayObjectContainer)) {
		var cont = dispObj;
		{
			var _g = 0, _g1 = cont.__children;
			while(_g < _g1.length) {
				var child = _g1[_g];
				++_g;
				this.enterFrameDispatch(child);
			}
		}
	}
	$s.pop();
}
jsflash.display.Stage.prototype.fpsTimer = null;
jsflash.display.Stage.prototype.frameRate = null;
jsflash.display.Stage.prototype.get_stageHeight = function() {
	$s.push("jsflash.display.Stage::get_stageHeight");
	var $spos = $s.length;
	{
		var $tmp = this.set_stageHeight(this.Canvas.height);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.Stage.prototype.get_stageWidth = function() {
	$s.push("jsflash.display.Stage::get_stageWidth");
	var $spos = $s.length;
	{
		var $tmp = this.set_stageWidth(this.Canvas.width);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.Stage.prototype.mouseClickHandler = function(evt) {
	$s.push("jsflash.display.Stage::mouseClickHandler");
	var $spos = $s.length;
	this.dispatchEvent(new jsflash.events.MouseEvent(jsflash.events.MouseEvent.CLICK));
	$s.pop();
}
jsflash.display.Stage.prototype.mouseDownHandler = function(evt) {
	$s.push("jsflash.display.Stage::mouseDownHandler");
	var $spos = $s.length;
	this.dispatchEvent(new jsflash.events.MouseEvent(jsflash.events.MouseEvent.MOUSE_DOWN));
	$s.pop();
}
jsflash.display.Stage.prototype.mouseMoveHandler = function(event) {
	$s.push("jsflash.display.Stage::mouseMoveHandler");
	var $spos = $s.length;
	if(event.pageX == null) {
		var d = ((js.Lib.document.documentElement && js.Lib.document.documentElement.scrollLeft != null)?js.Lib.document.documentElement:js.Lib.document.body);
		this.mouseX = event.clientX + d.scrollLeft;
		this.mouseY = event.clientY + d.scrollTop;
	}
	else {
		this.mouseX = event.pageX;
		this.mouseY = event.pageY;
	}
	this.dispatchEvent(new jsflash.events.MouseEvent(jsflash.events.MouseEvent.MOUSE_MOVE,true,false,this.mouseX,this.mouseY));
	$s.pop();
}
jsflash.display.Stage.prototype.mouseUpHandler = function(evt) {
	$s.push("jsflash.display.Stage::mouseUpHandler");
	var $spos = $s.length;
	this.dispatchEvent(new jsflash.events.MouseEvent(jsflash.events.MouseEvent.MOUSE_UP));
	$s.pop();
}
jsflash.display.Stage.prototype.mouseX = null;
jsflash.display.Stage.prototype.mouseY = null;
jsflash.display.Stage.prototype.set_frameRate = function(val) {
	$s.push("jsflash.display.Stage::set_frameRate");
	var $spos = $s.length;
	if(this.fpsTimer != null) {
		this.fpsTimer.stop();
		this.fpsTimer.run = null;
	}
	this.fpsTimer = new haxe.Timer(Std["int"](1000 / val));
	this.fpsTimer.run = function(f,a1) {
		$s.push("jsflash.display.Stage::set_frameRate@132");
		var $spos = $s.length;
		{
			var $tmp = function() {
				$s.push("jsflash.display.Stage::set_frameRate@132@132");
				var $spos = $s.length;
				{
					var $tmp = f(a1);
					$s.pop();
					return $tmp;
				}
				$s.pop();
			}
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}($closure(this,"enterFrameDispatch"),this);
	{
		var $tmp = this.frameRate = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.Stage.prototype.set_stageHeight = function(val) {
	$s.push("jsflash.display.Stage::set_stageHeight");
	var $spos = $s.length;
	this.Canvas.height = Std["int"](val);
	{
		var $tmp = this.stageHeight = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.Stage.prototype.set_stageWidth = function(val) {
	$s.push("jsflash.display.Stage::set_stageWidth");
	var $spos = $s.length;
	this.Canvas.width = Std["int"](val);
	{
		var $tmp = this.stageWidth = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.display.Stage.prototype.setupEventHandlers = function() {
	$s.push("jsflash.display.Stage::setupEventHandlers");
	var $spos = $s.length;
	this.Canvas.onmousemove = $closure(this,"mouseMoveHandler");
	this.Canvas.onclick = $closure(this,"mouseClickHandler");
	this.Canvas.onmousedown = $closure(this,"mouseDownHandler");
	this.Canvas.onmouseup = $closure(this,"mouseUpHandler");
	$s.pop();
}
jsflash.display.Stage.prototype.stageHeight = null;
jsflash.display.Stage.prototype.stageWidth = null;
jsflash.display.Stage.prototype.__class__ = jsflash.display.Stage;
away3dlite.loaders.utils.GeometryLibrary = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.loaders.utils.GeometryLibrary::new");
	var $spos = $s.length;
	Hash.apply(this,[]);
	$s.pop();
}}
away3dlite.loaders.utils.GeometryLibrary.__name__ = ["away3dlite","loaders","utils","GeometryLibrary"];
away3dlite.loaders.utils.GeometryLibrary.__super__ = Hash;
for(var k in Hash.prototype ) away3dlite.loaders.utils.GeometryLibrary.prototype[k] = Hash.prototype[k];
away3dlite.loaders.utils.GeometryLibrary.prototype._geometryArray = null;
away3dlite.loaders.utils.GeometryLibrary.prototype._geometryArrayDirty = null;
away3dlite.loaders.utils.GeometryLibrary.prototype.addGeometry = function(name,geoXML,ctrlXML) {
	$s.push("away3dlite.loaders.utils.GeometryLibrary::addGeometry");
	var $spos = $s.length;
	if(this.exists(name)) {
		var $tmp = this.get(name);
		$s.pop();
		return $tmp;
	}
	this._geometryArrayDirty = true;
	var geometryData = new away3dlite.loaders.data.GeometryData();
	geometryData.geoXML = geoXML;
	geometryData.ctrlXML = ctrlXML;
	this.set(geometryData.name = name,geometryData);
	{
		$s.pop();
		return geometryData;
	}
	$s.pop();
}
away3dlite.loaders.utils.GeometryLibrary.prototype.getGeometry = function(name) {
	$s.push("away3dlite.loaders.utils.GeometryLibrary::getGeometry");
	var $spos = $s.length;
	if(this.exists(name)) {
		var $tmp = this.get(name);
		$s.pop();
		return $tmp;
	}
	away3dlite.core.utils.Debug.warning(("Geometry '" + name) + "' does not exist",{ fileName : "GeometryLibrary.hx", lineNumber : 60, className : "away3dlite.loaders.utils.GeometryLibrary", methodName : "getGeometry"});
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
away3dlite.loaders.utils.GeometryLibrary.prototype.getGeometryArray = function() {
	$s.push("away3dlite.loaders.utils.GeometryLibrary::getGeometryArray");
	var $spos = $s.length;
	if(this._geometryArrayDirty) this.updateGeometryArray();
	{
		var $tmp = this._geometryArray;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.loaders.utils.GeometryLibrary.prototype.name = null;
away3dlite.loaders.utils.GeometryLibrary.prototype.updateGeometryArray = function() {
	$s.push("away3dlite.loaders.utils.GeometryLibrary::updateGeometryArray");
	var $spos = $s.length;
	this._geometryArray = [];
	{ var $it26 = this.iterator();
	while( $it26.hasNext() ) { var _geodata = $it26.next();
	{
		this._geometryArray.push(_geodata);
	}
	}}
	$s.pop();
}
away3dlite.loaders.utils.GeometryLibrary.prototype.__class__ = away3dlite.loaders.utils.GeometryLibrary;
haxe.io.Error = { __ename__ : ["haxe","io","Error"], __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] }
haxe.io.Error.Blocked = ["Blocked",0];
haxe.io.Error.Blocked.toString = $estr;
haxe.io.Error.Blocked.__enum__ = haxe.io.Error;
haxe.io.Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe.io.Error; $x.toString = $estr; return $x; }
haxe.io.Error.OutsideBounds = ["OutsideBounds",2];
haxe.io.Error.OutsideBounds.toString = $estr;
haxe.io.Error.OutsideBounds.__enum__ = haxe.io.Error;
haxe.io.Error.Overflow = ["Overflow",1];
haxe.io.Error.Overflow.toString = $estr;
haxe.io.Error.Overflow.__enum__ = haxe.io.Error;
jsflash.Error = { __ename__ : ["jsflash","Error"], __constructs__ : ["RangeError","ArgumentError","Message"] }
jsflash.Error.ArgumentError = ["ArgumentError",1];
jsflash.Error.ArgumentError.toString = $estr;
jsflash.Error.ArgumentError.__enum__ = jsflash.Error;
jsflash.Error.Message = function(str) { var $x = ["Message",2,str]; $x.__enum__ = jsflash.Error; $x.toString = $estr; return $x; }
jsflash.Error.RangeError = ["RangeError",0];
jsflash.Error.RangeError.toString = $estr;
jsflash.Error.RangeError.__enum__ = jsflash.Error;
away3dlite.animators.bones.SkinVertex = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.animators.bones.SkinVertex::new");
	var $spos = $s.length;
	this._position = new jsflash.geom.Vector3D();
	this.weights = new Array();
	this.controllers = new Array();
	$s.pop();
}}
away3dlite.animators.bones.SkinVertex.__name__ = ["away3dlite","animators","bones","SkinVertex"];
away3dlite.animators.bones.SkinVertex.prototype._baseVertex = null;
away3dlite.animators.bones.SkinVertex.prototype._i = null;
away3dlite.animators.bones.SkinVertex.prototype._output = null;
away3dlite.animators.bones.SkinVertex.prototype._position = null;
away3dlite.animators.bones.SkinVertex.prototype._startIndex = null;
away3dlite.animators.bones.SkinVertex.prototype._vertices = null;
away3dlite.animators.bones.SkinVertex.prototype.clone = function() {
	$s.push("away3dlite.animators.bones.SkinVertex::clone");
	var $spos = $s.length;
	var skinVertex = new away3dlite.animators.bones.SkinVertex();
	skinVertex.weights = this.weights;
	skinVertex.controllers = this.controllers;
	{
		$s.pop();
		return skinVertex;
	}
	$s.pop();
}
away3dlite.animators.bones.SkinVertex.prototype.controllers = null;
away3dlite.animators.bones.SkinVertex.prototype.update = function() {
	$s.push("away3dlite.animators.bones.SkinVertex::update");
	var $spos = $s.length;
	this._output = new jsflash.geom.Vector3D();
	this._i = this.weights.length;
	while(this._i-- != 0) {
		this._position = this.controllers[this._i]._transformMatrix3D.transformVector(this._baseVertex);
		this._position.scaleBy(this.weights[this._i]);
		this._output = this._output.add(this._position);
	}
	this._vertices[Std["int"](this._startIndex)] = this._output.x;
	this._vertices[Std["int"](this._startIndex + 1)] = this._output.y;
	this._vertices[Std["int"](this._startIndex + 2)] = this._output.z;
	$s.pop();
}
away3dlite.animators.bones.SkinVertex.prototype.updateVertices = function(startIndex,vertices) {
	$s.push("away3dlite.animators.bones.SkinVertex::updateVertices");
	var $spos = $s.length;
	this._startIndex = startIndex;
	this._vertices = vertices;
	this._baseVertex = new jsflash.geom.Vector3D(this._vertices[this._startIndex],this._vertices[this._startIndex + 1],this._vertices[this._startIndex + 2]);
	$s.pop();
}
away3dlite.animators.bones.SkinVertex.prototype.weights = null;
away3dlite.animators.bones.SkinVertex.prototype.__class__ = away3dlite.animators.bones.SkinVertex;
jsflash.display.IGraphicsData = function() { }
jsflash.display.IGraphicsData.__name__ = ["jsflash","display","IGraphicsData"];
jsflash.display.IGraphicsData.prototype.__class__ = jsflash.display.IGraphicsData;
away3dlite.events.MouseEvent3D = function(type) { if( type === $_ ) return; {
	$s.push("away3dlite.events.MouseEvent3D::new");
	var $spos = $s.length;
	jsflash.events.Event.apply(this,[type,false,true]);
	$s.pop();
}}
away3dlite.events.MouseEvent3D.__name__ = ["away3dlite","events","MouseEvent3D"];
away3dlite.events.MouseEvent3D.__super__ = jsflash.events.Event;
for(var k in jsflash.events.Event.prototype ) away3dlite.events.MouseEvent3D.prototype[k] = jsflash.events.Event.prototype[k];
away3dlite.events.MouseEvent3D.prototype.clone = function() {
	$s.push("away3dlite.events.MouseEvent3D::clone");
	var $spos = $s.length;
	var result = new away3dlite.events.MouseEvent3D(this.type);
	result.screenX = this.screenX;
	result.screenY = this.screenY;
	result.scenePosition = this.scenePosition;
	result.view = this.view;
	result.object = this.object;
	result.material = this.material;
	result.uvt = this.uvt;
	result.ctrlKey = this.ctrlKey;
	result.shiftKey = this.shiftKey;
	{
		$s.pop();
		return result;
	}
	$s.pop();
}
away3dlite.events.MouseEvent3D.prototype.ctrlKey = null;
away3dlite.events.MouseEvent3D.prototype.material = null;
away3dlite.events.MouseEvent3D.prototype.object = null;
away3dlite.events.MouseEvent3D.prototype.scenePosition = null;
away3dlite.events.MouseEvent3D.prototype.screenX = null;
away3dlite.events.MouseEvent3D.prototype.screenY = null;
away3dlite.events.MouseEvent3D.prototype.shiftKey = null;
away3dlite.events.MouseEvent3D.prototype.uvt = null;
away3dlite.events.MouseEvent3D.prototype.view = null;
away3dlite.events.MouseEvent3D.prototype.__class__ = away3dlite.events.MouseEvent3D;
jsflash.FastMath = function() { }
jsflash.FastMath.__name__ = ["jsflash","FastMath"];
jsflash.FastMath.abs = function(x) {
	$s.push("jsflash.FastMath::abs");
	var $spos = $s.length;
	{
		var $tmp = ((x < 0)?-x:x);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.FastMath.prototype.__class__ = jsflash.FastMath;
away3dlite.sprites.AlignmentType = function() { }
away3dlite.sprites.AlignmentType.__name__ = ["away3dlite","sprites","AlignmentType"];
away3dlite.sprites.AlignmentType.prototype.__class__ = away3dlite.sprites.AlignmentType;
jsflash.geom.PerspectiveProjection = function(p) { if( p === $_ ) return; {
	$s.push("jsflash.geom.PerspectiveProjection::new");
	var $spos = $s.length;
	this.set_projectionCenter(new jsflash.geom.Point(0,0));
	this.set_fieldOfView(55);
	this.Znear = 0.1;
	this.Zfar = 1000;
	this.Aspect = 1;
	$s.pop();
}}
jsflash.geom.PerspectiveProjection.__name__ = ["jsflash","geom","PerspectiveProjection"];
jsflash.geom.PerspectiveProjection.makeFrustum = function(left,right,bottom,top,znear,zfar) {
	$s.push("jsflash.geom.PerspectiveProjection::makeFrustum");
	var $spos = $s.length;
	var X = (2 * znear) / (right - left);
	var Y = (2 * znear) / (top - bottom);
	var A = (right + left) / (right - left);
	var B = (top + bottom) / (top - bottom);
	var C = -(zfar + znear) / (zfar - znear);
	var D = ((-2 * zfar) * znear) / (zfar - znear);
	{
		var $tmp = [X,0,0,0,0,Y,0,0,A,B,C,-1,0,0,D,0];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.PerspectiveProjection.prototype.Aspect = null;
jsflash.geom.PerspectiveProjection.prototype.Internal = function() {
	$s.push("jsflash.geom.PerspectiveProjection::Internal");
	var $spos = $s.length;
	{
		$s.pop();
		return this;
	}
	$s.pop();
}
jsflash.geom.PerspectiveProjection.prototype.PerspectiveMatrix3D = function(pixelPerUnitRatio) {
	$s.push("jsflash.geom.PerspectiveProjection::PerspectiveMatrix3D");
	var $spos = $s.length;
	if(pixelPerUnitRatio == null) pixelPerUnitRatio = 250;
	var ymax = this.Znear * Math.tan((this.fieldOfView * Math.PI) / 360);
	var ymin = -ymax;
	var xmin = ymin * this.Aspect;
	var xmax = ymax * this.Aspect;
	{
		var $tmp = new jsflash.geom.Matrix3D(jsflash.geom.PerspectiveProjection.makeFrustum(xmin,xmax,ymin,ymax,this.Znear,this.Zfar));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.PerspectiveProjection.prototype.Zfar = null;
jsflash.geom.PerspectiveProjection.prototype.Znear = null;
jsflash.geom.PerspectiveProjection.prototype.fieldOfView = null;
jsflash.geom.PerspectiveProjection.prototype.focalLength = null;
jsflash.geom.PerspectiveProjection.prototype.focalLengthFromFoV = function(fov) {
	$s.push("jsflash.geom.PerspectiveProjection::focalLengthFromFoV");
	var $spos = $s.length;
	{
		var $tmp = (-0.5 * Math.cos(fov * .5)) / Math.sin(fov * .5);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.PerspectiveProjection.prototype.fovFromFocalLength = function(fl) {
	$s.push("jsflash.geom.PerspectiveProjection::fovFromFocalLength");
	var $spos = $s.length;
	{
		var $tmp = 2 * Math.atan(1 / (fl * -2));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.PerspectiveProjection.prototype.matrix = null;
jsflash.geom.PerspectiveProjection.prototype.projectionCenter = null;
jsflash.geom.PerspectiveProjection.prototype.set_fieldOfView = function(val) {
	$s.push("jsflash.geom.PerspectiveProjection::set_fieldOfView");
	var $spos = $s.length;
	this.focalLength = (-0.5 * Math.cos(val * .5)) / Math.sin(val * .5);
	{
		var $tmp = this.fieldOfView = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.PerspectiveProjection.prototype.set_focalLength = function(val) {
	$s.push("jsflash.geom.PerspectiveProjection::set_focalLength");
	var $spos = $s.length;
	this.fieldOfView = 2 * Math.atan(1 / (val * -2));
	{
		var $tmp = this.focalLength = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.PerspectiveProjection.prototype.set_projectionCenter = function(val) {
	$s.push("jsflash.geom.PerspectiveProjection::set_projectionCenter");
	var $spos = $s.length;
	{
		var $tmp = this.projectionCenter = val;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.PerspectiveProjection.prototype.toMatrix3D = function(pixelPerUnitRatio) {
	$s.push("jsflash.geom.PerspectiveProjection::toMatrix3D");
	var $spos = $s.length;
	if(pixelPerUnitRatio == null) pixelPerUnitRatio = 250;
	var fov = this.fieldOfView;
	var cx = this.projectionCenter.x;
	var cy = this.projectionCenter.y;
	{
		var $tmp = this.PerspectiveMatrix3D(pixelPerUnitRatio);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jsflash.geom.PerspectiveProjection.prototype.__class__ = jsflash.geom.PerspectiveProjection;
away3dlite.animators.bones.SkinController = function(p) { if( p === $_ ) return; {
	$s.push("away3dlite.animators.bones.SkinController::new");
	var $spos = $s.length;
	this.skinVertices = new Array();
	$s.pop();
}}
away3dlite.animators.bones.SkinController.__name__ = ["away3dlite","animators","bones","SkinController"];
away3dlite.animators.bones.SkinController.prototype._transformMatrix3D = null;
away3dlite.animators.bones.SkinController.prototype.bindMatrix = null;
away3dlite.animators.bones.SkinController.prototype.get_transformMatrix3D = function() {
	$s.push("away3dlite.animators.bones.SkinController::get_transformMatrix3D");
	var $spos = $s.length;
	{
		var $tmp = this._transformMatrix3D;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
away3dlite.animators.bones.SkinController.prototype.joint = null;
away3dlite.animators.bones.SkinController.prototype.name = null;
away3dlite.animators.bones.SkinController.prototype.parent = null;
away3dlite.animators.bones.SkinController.prototype.skinVertices = null;
away3dlite.animators.bones.SkinController.prototype.transformMatrix3D = null;
away3dlite.animators.bones.SkinController.prototype.update = function() {
	$s.push("away3dlite.animators.bones.SkinController::update");
	var $spos = $s.length;
	if(this.joint == null) {
		$s.pop();
		return;
	}
	this._transformMatrix3D = this.joint.transform.matrix3D.clone();
	var child = this.joint;
	while(child.parent != this.parent) {
		child = child.parent;
		this._transformMatrix3D.append(child.transform.matrix3D);
	}
	this._transformMatrix3D.prepend(this.bindMatrix);
	$s.pop();
}
away3dlite.animators.bones.SkinController.prototype.__class__ = away3dlite.animators.bones.SkinController;
EReg = function(r,opt) { if( r === $_ ) return; {
	$s.push("EReg::new");
	var $spos = $s.length;
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
	$s.pop();
}}
EReg.__name__ = ["EReg"];
EReg.prototype.customReplace = function(s,f) {
	$s.push("EReg::customReplace");
	var $spos = $s.length;
	var buf = new StringBuf();
	while(true) {
		if(!this.match(s)) break;
		buf.b[buf.b.length] = this.matchedLeft();
		buf.b[buf.b.length] = f(this);
		s = this.matchedRight();
	}
	buf.b[buf.b.length] = s;
	{
		var $tmp = buf.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.match = function(s) {
	$s.push("EReg::match");
	var $spos = $s.length;
	this.r.m = this.r.exec(s);
	this.r.s = s;
	this.r.l = RegExp.leftContext;
	this.r.r = RegExp.rightContext;
	{
		var $tmp = (this.r.m != null);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.matched = function(n) {
	$s.push("EReg::matched");
	var $spos = $s.length;
	{
		var $tmp = (this.r.m != null && n >= 0 && n < this.r.m.length?this.r.m[n]:(function($this) {
			var $r;
			throw "EReg::matched";
			return $r;
		}(this)));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.matchedLeft = function() {
	$s.push("EReg::matchedLeft");
	var $spos = $s.length;
	if(this.r.m == null) throw "No string matched";
	if(this.r.l == null) {
		var $tmp = this.r.s.substr(0,this.r.m.index);
		$s.pop();
		return $tmp;
	}
	{
		var $tmp = this.r.l;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.matchedPos = function() {
	$s.push("EReg::matchedPos");
	var $spos = $s.length;
	if(this.r.m == null) throw "No string matched";
	{
		var $tmp = { pos : this.r.m.index, len : this.r.m[0].length}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.matchedRight = function() {
	$s.push("EReg::matchedRight");
	var $spos = $s.length;
	if(this.r.m == null) throw "No string matched";
	if(this.r.r == null) {
		var sz = this.r.m.index + this.r.m[0].length;
		{
			var $tmp = this.r.s.substr(sz,this.r.s.length - sz);
			$s.pop();
			return $tmp;
		}
	}
	{
		var $tmp = this.r.r;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.r = null;
EReg.prototype.replace = function(s,by) {
	$s.push("EReg::replace");
	var $spos = $s.length;
	{
		var $tmp = s.replace(this.r,by);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.split = function(s) {
	$s.push("EReg::split");
	var $spos = $s.length;
	var d = "#__delim__#";
	{
		var $tmp = s.replace(this.r,d).split(d);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.__class__ = EReg;
away3dlite.containers.Scene3D = function(childArray) { if( childArray === $_ ) return; {
	$s.push("away3dlite.containers.Scene3D::new");
	var $spos = $s.length;
	this._id = away3dlite.containers.Scene3D._idTotal++;
	away3dlite.containers.ObjectContainer3D.apply(this,[]);
	this._broadcaster = new jsflash.display.Sprite();
	this._materialsSceneList = new Array();
	this._materialsPreviousList = new Array();
	this._materialsNextList = new Array();
	if(childArray != null) {
		var _g = 0;
		while(_g < childArray.length) {
			var child = childArray[_g];
			++_g;
			this.addChild(child);
		}
	}
	this._scene = this;
	$s.pop();
}}
away3dlite.containers.Scene3D.__name__ = ["away3dlite","containers","Scene3D"];
away3dlite.containers.Scene3D.__super__ = away3dlite.containers.ObjectContainer3D;
for(var k in away3dlite.containers.ObjectContainer3D.prototype ) away3dlite.containers.Scene3D.prototype[k] = away3dlite.containers.ObjectContainer3D.prototype[k];
away3dlite.containers.Scene3D.prototype._broadcaster = null;
away3dlite.containers.Scene3D.prototype._id = null;
away3dlite.containers.Scene3D.prototype._materialsNextList = null;
away3dlite.containers.Scene3D.prototype._materialsPreviousList = null;
away3dlite.containers.Scene3D.prototype._materialsSceneList = null;
away3dlite.containers.Scene3D.prototype.addSceneMaterial = function(mat) {
	$s.push("away3dlite.containers.Scene3D::addSceneMaterial");
	var $spos = $s.length;
	if(mat._faceCount.length <= this._id) mat._id.length = mat._faceCount.length = this._id + 1;
	if(mat._faceCount[this._id] == 0) {
		var i = 0;
		var length = this._materialsSceneList.length;
		while(i < length) {
			if(this._materialsSceneList[i] == null) {
				this._materialsSceneList[mat._id[this._id] = i] = mat;
				break;
			}
			else {
				i++;
			}
		}
		if(i == length) {
			this._materialsSceneList[mat._id[this._id] = i] = mat;
		}
	}
	mat._faceCount[this._id]++;
	$s.pop();
}
away3dlite.containers.Scene3D.prototype.project = function(camera,parentSceneMatrix3D) {
	$s.push("away3dlite.containers.Scene3D::project");
	var $spos = $s.length;
	this._materialsNextList = new Array();
	away3dlite.containers.ObjectContainer3D.prototype.project.apply(this,[camera,parentSceneMatrix3D]);
	var i;
	var matPrevious;
	var matNext;
	if(this._materialsPreviousList.length > this._materialsNextList.length) i = this._materialsPreviousList.length;
	else i = this._materialsNextList.length;
	while(i-- != 0) {
		matPrevious = this._materialsPreviousList[i];
		matNext = this._materialsNextList[i];
		if(matPrevious != matNext) {
			if(matPrevious != null) matPrevious.notifyDeactivate(this);
			if(matNext != null) matNext.notifyActivate(this);
		}
	}
	this._materialsPreviousList = this._materialsNextList;
	$s.pop();
}
away3dlite.containers.Scene3D.prototype.removeSceneMaterial = function(mat) {
	$s.push("away3dlite.containers.Scene3D::removeSceneMaterial");
	var $spos = $s.length;
	if(--mat._faceCount[this._id] == 0) {
		this._materialsSceneList[mat._id[this._id]] == null;
		if(mat._id[this._id] == this._materialsSceneList.length - 1) null;
	}
	$s.pop();
}
away3dlite.containers.Scene3D.prototype.__class__ = away3dlite.containers.Scene3D;
$Main = function() { }
$Main.__name__ = ["@Main"];
$Main.prototype.__class__ = $Main;
$_ = {}
js.Boot.__res = {}
$s = [];
$e = [];
js.Boot.__init();
{
	Math.NaN = Number["NaN"];
	Math.NEGATIVE_INFINITY = Number["NEGATIVE_INFINITY"];
	Math.POSITIVE_INFINITY = Number["POSITIVE_INFINITY"];
	Math.isFinite = function(i) {
		$s.push("@Main::new@73");
		var $spos = $s.length;
		{
			var $tmp = isFinite(i);
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	Math.isNaN = function(i) {
		$s.push("@Main::new@85");
		var $spos = $s.length;
		{
			var $tmp = isNaN(i);
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	Math.__name__ = ["Math"];
}
{
	js.Lib.document = document;
	js.Lib.window = window;
	onerror = function(msg,url,line) {
		var stack = $s.copy();
		var f = js.Lib.onerror;
		$s.splice(0,$s.length);
		if( f == null ) {
			var i = stack.length;
			var s = "";
			while( --i >= 0 )
				s += "Called from "+stack[i]+"\n";
			alert(msg+"\n\n"+s);
			return false;
		}
		return f(msg,stack);
	}
}
{
	Date.now = function() {
		$s.push("@Main::new@124");
		var $spos = $s.length;
		{
			var $tmp = new Date();
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	Date.fromTime = function(t) {
		$s.push("@Main::new@127");
		var $spos = $s.length;
		var d = new Date();
		d["setTime"](t);
		{
			$s.pop();
			return d;
		}
		$s.pop();
	}
	Date.fromString = function(s) {
		$s.push("@Main::new@136");
		var $spos = $s.length;
		switch(s.length) {
		case 8:{
			var k = s.split(":");
			var d = new Date();
			d["setTime"](0);
			d["setUTCHours"](k[0]);
			d["setUTCMinutes"](k[1]);
			d["setUTCSeconds"](k[2]);
			{
				$s.pop();
				return d;
			}
		}break;
		case 10:{
			var k = s.split("-");
			{
				var $tmp = new Date(k[0],k[1] - 1,k[2],0,0,0);
				$s.pop();
				return $tmp;
			}
		}break;
		case 19:{
			var k = s.split(" ");
			var y = k[0].split("-");
			var t = k[1].split(":");
			{
				var $tmp = new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
				$s.pop();
				return $tmp;
			}
		}break;
		default:{
			throw "Invalid date format : " + s;
		}break;
		}
		$s.pop();
	}
	Date.prototype["toString"] = function() {
		$s.push("@Main::new@165");
		var $spos = $s.length;
		var date = this;
		var m = date.getMonth() + 1;
		var d = date.getDate();
		var h = date.getHours();
		var mi = date.getMinutes();
		var s = date.getSeconds();
		{
			var $tmp = (((((((((date.getFullYear() + "-") + ((m < 10?"0" + m:"" + m))) + "-") + ((d < 10?"0" + d:"" + d))) + " ") + ((h < 10?"0" + h:"" + h))) + ":") + ((mi < 10?"0" + mi:"" + mi))) + ":") + ((s < 10?"0" + s:"" + s));
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	Date.prototype.__class__ = Date;
	Date.__name__ = ["Date"];
}
{
	String.prototype.__class__ = String;
	String.__name__ = ["String"];
	Array.prototype.__class__ = Array;
	Array.__name__ = ["Array"];
	Int = { __name__ : ["Int"]}
	Dynamic = { __name__ : ["Dynamic"]}
	Float = Number;
	Float.__name__ = ["Float"];
	Bool = { __ename__ : ["Bool"]}
	Class = { __name__ : ["Class"]}
	Enum = { }
	Void = { __ename__ : ["Void"]}
}
{
	if(typeof webgl=='undefined') webgl = {}
		try
	  	{
		    WebGLFloatArray;
		  }
		  catch (e)
		  {
		    try
		    {
		      WebGLFloatArray = CanvasFloatArray;
			  WebGLShortArray = CanvasShortArray;
		      WebGLUnsignedShortArray = CanvasUnsignedShortArray;
			  WebGLByteArray = CanvasByteArray;
			  WebGLUnsignedByteArray = CanvasUnsignedByteArray;
			  WebGLIntArray = CanvasIntArray;
			  WebGLUnsignedIntArray = CanvasUnsignedIntArray;
			  WebGLArrayBuffer = CanvasArrayBuffer;
		    }
		    catch (e)
		    {
		      alert("Could not find any WebGL array types.");
		    }
		 }
}
{
	webgl.WebGLByteArray = WebGLByteArray;
}
{
	webgl.WebGLUnsignedByteArray = WebGLUnsignedByteArray;
}
{
	webgl.WebGLShortArray = WebGLShortArray;
}
{
	webgl.WebGLUnsignedShortArray = WebGLUnsignedShortArray;
}
{
	webgl.WebGLIntArray = WebGLIntArray;
}
{
	webgl.WebGLUnsignedIntArray = WebGLUnsignedIntArray;
}
{
	webgl.WebGLFloatArray = WebGLFloatArray;
}
{
	webgl.WebGLArrayBuffer = WebGLArrayBuffer;
}
jsflash.events.EventDispatcher.mIDBase = 0;
away3dlite.containers.View3D.VERSION = "1";
away3dlite.containers.View3D.REVISION = "0.2";
away3dlite.containers.View3D.APPLICATION_NAME = "Away3D.com";
jsflash.events.Listener.sIDs = 1;
away3dlite.materials.BitmapMaterial._bitmapid = 0;
away3dlite.loaders.data.MaterialData.TEXTURE_MATERIAL = "textureMaterial";
away3dlite.loaders.data.MaterialData.SHADING_MATERIAL = "shadingMaterial";
away3dlite.loaders.data.MaterialData.COLOR_MATERIAL = "colorMaterial";
away3dlite.loaders.data.MaterialData.WIREFRAME_MATERIAL = "wireframeMaterial";
jsflash.events.Event.ACTIVATE = "activate";
jsflash.events.Event.ADDED = "added";
jsflash.events.Event.ADDED_TO_STAGE = "addedToStage";
jsflash.events.Event.CANCEL = "cancel";
jsflash.events.Event.CHANGE = "change";
jsflash.events.Event.CLOSE = "close";
jsflash.events.Event.COMPLETE = "complete";
jsflash.events.Event.CONNECT = "connect";
jsflash.events.Event.DEACTIVATE = "deactivate";
jsflash.events.Event.ENTER_FRAME = "enterFrame";
jsflash.events.Event.ID3 = "id3";
jsflash.events.Event.INIT = "init";
jsflash.events.Event.MOUSE_LEAVE = "mouseLeave";
jsflash.events.Event.OPEN = "open";
jsflash.events.Event.REMOVED = "removed";
jsflash.events.Event.REMOVED_FROM_STAGE = "removedFromStage";
jsflash.events.Event.RENDER = "render";
jsflash.events.Event.RESIZE = "resize";
jsflash.events.Event.SCROLL = "scroll";
jsflash.events.Event.SELECT = "select";
jsflash.events.Event.SOUND_COMPLETE = "soundComplete";
jsflash.events.Event.TAB_CHILDREN_CHANGE = "tabChildrenChange";
jsflash.events.Event.TAB_ENABLED_CHANGE = "tabEnabledChange";
jsflash.events.Event.TAB_INDEX_CHANGE = "tabIndexChange";
jsflash.events.Event.UNLOAD = "unload";
away3dlite.events.MaterialEvent.LOAD_ERROR = "loadError";
away3dlite.events.MaterialEvent.LOAD_PROGRESS = "loadProgress";
away3dlite.events.MaterialEvent.LOAD_SUCCESS = "loadSuccess";
away3dlite.events.MaterialEvent.MATERIAL_UPDATED = "materialUpdated";
away3dlite.events.MaterialEvent.MATERIAL_CHANGED = "materialChanged";
away3dlite.events.MaterialEvent.MATERIAL_ACTIVATED = "materialActivated";
away3dlite.events.MaterialEvent.MATERIAL_DEACTIVATED = "materialDeactivated";
away3dlite.core.utils.Debug.active = false;
away3dlite.core.utils.Debug.warningsAsErrors = false;
away3dlite.core.utils.Debug.haxeTrace = $closure(haxe.Log,"trace");
away3dlite.events.ClippingEvent.CLIPPING_UPDATED = "clippingUpdated";
away3dlite.events.ClippingEvent.SCREEN_UPDATED = "screenUpdated";
away3dlite.containers.ObjectContainer3D._toDegrees = 180 / Math.PI;
away3dlite.core.base.SortType.CENTER = "center";
away3dlite.core.base.SortType.FRONT = "front";
away3dlite.core.base.SortType.BACK = "back";
jsflash.events.MouseEvent.CLICK = "click";
jsflash.events.MouseEvent.DOUBLE_CLICK = "doubleClick";
jsflash.events.MouseEvent.MOUSE_DOWN = "mouseDown";
jsflash.events.MouseEvent.MOUSE_MOVE = "mouseMove";
jsflash.events.MouseEvent.MOUSE_OUT = "mouseOut";
jsflash.events.MouseEvent.MOUSE_OVER = "mouseOver";
jsflash.events.MouseEvent.MOUSE_UP = "mouseUp";
jsflash.events.MouseEvent.MOUSE_WHEEL = "mouseWheel";
jsflash.events.MouseEvent.ROLL_OUT = "rollOut";
jsflash.events.MouseEvent.ROLL_OVER = "rollOver";
js.Lib.onerror = null;
away3dlite.core.utils.Cast.hexchars = "0123456789abcdefABCDEF";
away3dlite.core.utils.Cast.notclasses = new Hash();
away3dlite.core.utils.Cast.classes = new Hash();
jsflash.events.IOErrorEvent.IO_ERROR = "IO_ERROR";
jsflash.geom.Vector3D.X_AXIS = new jsflash.geom.Vector3D(1,0,0);
jsflash.geom.Vector3D.Y_AXIS = new jsflash.geom.Vector3D(0,1,0);
jsflash.geom.Vector3D.Z_AXIS = new jsflash.geom.Vector3D(0,0,1);
away3dlite.haxeutils.MathUtils.PI = 3.141592653589793;
away3dlite.haxeutils.MathUtils.HALF_PI = 3.141592653589793 / 2;
away3dlite.haxeutils.MathUtils.TWO_PI = 3.141592653589793 * 2;
away3dlite.haxeutils.MathUtils.NEGATIVE_INFINITY = Math.NEGATIVE_INFINITY;
away3dlite.haxeutils.MathUtils.POSITIVE_INFINITY = Math.POSITIVE_INFINITY;
away3dlite.haxeutils.MathUtils.toRADIANS = 3.141592653589793 / 180;
away3dlite.haxeutils.MathUtils.toDEGREES = 180 / 3.141592653589793;
away3dlite.haxeutils.MathUtils.B = 4 / 3.141592653589793;
away3dlite.haxeutils.MathUtils.C = -4 / (3.141592653589793 * 3.141592653589793);
away3dlite.haxeutils.MathUtils.P = 0.225;
webgl.WebGL.WEBGL_CONTEXT = "experimental-webgl";
away3dlite.cameras.Camera3D.toRADIANS = Math.PI / 180;
away3dlite.cameras.Camera3D.toDEGREES = 180 / Math.PI;
haxe.Timer.arr = new Array();
away3dlite.loaders.data.AnimationData.VERTEX_ANIMATION = "vertexAnimation";
away3dlite.loaders.data.AnimationData.SKIN_ANIMATION = "skinAnimation";
jsflash.events.EventPhase.CAPTURING_PHASE = 0;
jsflash.events.EventPhase.AT_TARGET = 1;
jsflash.events.EventPhase.BUBBLING_PHASE = 2;
away3dlite.events.MouseEvent3D.MOUSE_OVER = "mouseOver3d";
away3dlite.events.MouseEvent3D.MOUSE_OUT = "mouseOut3d";
away3dlite.events.MouseEvent3D.MOUSE_UP = "mouseUp3d";
away3dlite.events.MouseEvent3D.MOUSE_DOWN = "mouseDown3d";
away3dlite.events.MouseEvent3D.MOUSE_MOVE = "mouseMove3d";
away3dlite.events.MouseEvent3D.ROLL_OVER = "rollOver3d";
away3dlite.events.MouseEvent3D.ROLL_OUT = "rollOut3d";
jsflash.FastMath.PI = 3.141592653589793;
jsflash.FastMath.HALF_PI = 3.141592653589793 / 2;
jsflash.FastMath.TWO_PI = 3.141592653589793 * 2;
jsflash.FastMath.toRADIANS = 3.141592653589793 / 180;
jsflash.FastMath.toDEGREES = 180 / 3.141592653589793;
away3dlite.sprites.AlignmentType.VIEWPLANE = "viewplane";
away3dlite.sprites.AlignmentType.VIEWPOINT = "viewpoint";
away3dlite.containers.Scene3D._idTotal = 0;
$Main.init = ExSphereSpeedTest.main();
