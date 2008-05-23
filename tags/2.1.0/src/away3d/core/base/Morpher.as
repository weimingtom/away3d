package away3d.core.base
{
    /**
    * Keyframe animation morpher
    */
    public class Morpher extends Object3D
    {
        private var weight:Number;
        private var vertices:BaseMesh;
    	
		/**
		 * Creates a new <code>Morpher</code> object.
		 *
		 * @param	vertices	A mesh object used to define the starting vertices.
		 */
        public function Morpher(vertices:BaseMesh)
        {
            this.vertices = vertices;
        }
		
		/**
		 * resets all vertex objects to 0,0,0
		 */
        public function start():void
        {
            weight = 0;
            for each (var v:Vertex in vertices.vertices)
            {
                v.x = 0;
                v.y = 0;
                v.z = 0;
            }
        }
		
		/**
		 * interpolates the vertex objects position values between the current vertex positions and the external vertex positions
		 * 
		 * @param	comp	The external mesh used for interpolating values
		 * @param	k		The increment used on the weighting value 
		 */
        public function mix(comp:BaseMesh, k:Number):void
        {
            weight += k;
            var length:int = vertices.vertices.length;
            for (var i:int = 0; i < length; i++)
            {
                vertices.vertices[i].x += comp.vertices[i].x * k;
                vertices.vertices[i].y += comp.vertices[i].y * k;
                vertices.vertices[i].z += comp.vertices[i].z * k;
            }
        }
		
		/**
		 * resets all vertex objects to the external mesh positions
		 * 
		 * @param	comp	The external mesh used for vertex values
		 */
        public function finish(comp:BaseMesh):void
        {
            mix(comp, 1 - weight);
            weight = 1;
        }
    }
}
