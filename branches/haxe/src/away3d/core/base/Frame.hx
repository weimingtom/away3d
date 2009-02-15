package away3d.core.base;



/**
 * Holds vertexposition information about a single animation frame.
 */
class Frame implements IFrame {
	
	private var _vertexposition:VertexPosition;
	/**
	 * An array of vertex position objects.
	 */
	public var vertexpositions:Array<Dynamic>;
	

	/**
	 * Creates a new <code>Frame</code> object.
	 */
	public function new() {
		this.vertexpositions = [];
		
		
	}

	/**
	 * @inheritDoc
	 */
	public function adjust(?k:Float=1):Void {
		
		for (__i in 0...vertexpositions.length) {
			_vertexposition = vertexpositions[__i];

			_vertexposition.adjust(k);
		}

	}

	// temp undocumented patch for missing indexes on md2 files and as3 outputs for as3exporters
	public function getIndexes(vertices:Array<Dynamic>):Array<Dynamic> {
		
		var indexes:Array<Dynamic> = [];
		for (__i in 0...vertexpositions.length) {
			_vertexposition = vertexpositions[__i];

			indexes.push(_vertexposition.getIndex(vertices));
		}

		return indexes;
	}

}

