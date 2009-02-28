package away3d.animators.data;

import away3d.haxeutils.Error;
import away3d.core.math.Number3D;


/**
 * Holds information about a single Path definition.
 */
class Path  {
	public var smoothed(getSmoothed, null) : Bool;
	public var averaged(getAveraged, null) : Bool;
	public var length(getLength, null) : Int;
	public var array(getArray, null) : Array<Dynamic>;
	
	/**
	 * The array that contains the path definition.
	 */
	public var aSegments:Array<Dynamic>;
	/**
	 * The worldAxis of reference
	 */
	public var worldAxis:Number3D;
	private var _smoothed:Bool;
	private var _averaged:Bool;
	

	/**
	 * returns true if the smoothPath handler is being used.
	 */
	public function getSmoothed():Bool {
		
		return _smoothed;
	}

	/**
	 * returns true if the averagePath handler is being used.
	 */
	public function getAveraged():Bool {
		
		return _averaged;
	}

	/**
	 * Creates a new <code>Path</code> object.
	 * 
	 * @param	 aVectors		An array of a series of number3D's organized in the following fashion. [a,b,c,a,b,c etc...] a = v1, b=vc (control point), c = v2
	 */
	public function new(aVectors:Array<Dynamic>) {
		this.worldAxis = new Number3D(0, 1, 0);
		
		
		if (aVectors.length < 3) {
			throw new Error("Path array must contain at least 3 Number3D's");
		}
		this.aSegments = [];
		var i:Int = 0;
		while (i < aVectors.length) {
			this.aSegments.push(new CurveSegment(aVectors[i], aVectors[i + 1], aVectors[i + 2]));
			
			// update loop variables
			i += 3;
		}

	}

	/**
	 * adds a CurveSegment to the path
	 * @see CurveSegment:
	 */
	public function add(cs:CurveSegment):Void {
		
		this.aSegments.push(cs);
	}

	/**
	 * returns the length of the Path elements array
	 * 
	 * @return	an integer: the length of the Path elements array
	 */
	public function getLength():Int {
		
		return this.aSegments.length;
	}

	/**
	 * returns the Path elements array
	 * 
	 * @return	an Array: the Path elements array
	 */
	public function getArray():Array<Dynamic> {
		
		return this.aSegments;
	}

	/**
	 * removes a segment in the path according to id.
	 * 
	 */
	public function removeSegment(index:Int):Void {
		
		if (index <= this.aSegments.length - 2) {
			var nextSeg:Number3D = this.aSegments[index + 1].v0;
			nextSeg = this.aSegments[index].v1;
		}
		this.aSegments.splice(index, 1);
	}

	/**
	 * handler will smooth the path using anchors as control vector of the CurveSegments 
	 * note that this is not dynamic, the CurveSegments values are overwrited
	 */
	public function smoothPath():Void {
		
		if (this.aSegments.length <= 2) {
			return;
		}
		_smoothed = true;
		_averaged = false;
		var x:Float;
		var y:Float;
		var z:Float;
		var seg0:Number3D;
		var seg1:Number3D;
		var tmp:Array<Dynamic> = [];
		var i:Int;
		var startseg:Number3D = new Number3D(this.aSegments[0].v0.x, this.aSegments[0].v0.y, this.aSegments[0].v0.z);
		var endseg:Number3D = new Number3D(this.aSegments[this.aSegments.length - 1].v1.x, this.aSegments[this.aSegments.length - 1].v1.y, this.aSegments[this.aSegments.length - 1].v1.z);
		i = 0;
		while (i < length - 1) {
			if (this.aSegments[i].vc == null) {
				this.aSegments[i].vc = this.aSegments[i].v1;
			}
			if (this.aSegments[i + 1].vc == null) {
				this.aSegments[i + 1].vc = this.aSegments[i + 1].v1;
			}
			seg0 = this.aSegments[i].vc;
			seg1 = this.aSegments[i + 1].vc;
			x = (seg0.x + seg1.x) * .5;
			y = (seg0.y + seg1.y) * .5;
			z = (seg0.z + seg1.z) * .5;
			tmp.push(startseg, new Number3D(seg0.x, seg0.y, seg0.z), new Number3D(x, y, z));
			startseg = new Number3D(x, y, z);
			this.aSegments[i] = null;
			
			// update loop variables
			++i;
		}

		seg0 = this.aSegments[this.aSegments.length - 1].vc;
		tmp.push(startseg, new Number3D((seg0.x + seg1.x) * .5, (seg0.y + seg1.y) * .5, (seg0.z + seg1.z) * .5), endseg);
		this.aSegments[0] = null;
		this.aSegments = [];
		i = 0;
		while (i < tmp.length) {
			this.aSegments.push(new CurveSegment(tmp[i], tmp[i + 1], tmp[i + 2]));
			
			// update loop variables
			i += 3;
		}

		tmp[i] = tmp[i + 1] = tmp[i + 2] = null;
		tmp = null;
	}

	/**
	 * handler will average the path using averages of the CurveSegments
	 * note that this is not dynamic, the path values are overwrited
	 */
	public function averagePath():Void {
		
		_averaged = true;
		_smoothed = false;
		var i:Int = 0;
		while (i < this.aSegments.length) {
			this.aSegments[i].vc.x = (this.aSegments[i].v0.x + this.aSegments[i].v1.x) * .5;
			this.aSegments[i].vc.y = (this.aSegments[i].v0.y + this.aSegments[i].v1.y) * .5;
			this.aSegments[i].vc.z = (this.aSegments[i].v0.z + this.aSegments[i].v1.z) * .5;
			
			// update loop variables
			++i;
		}

	}

}

