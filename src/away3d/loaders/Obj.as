package away3d.loaders
{
    import away3d.core.*;
	import away3d.core.base.*;
    import away3d.core.utils.*;
	
    /**
    * File loader for the OBJ file format.<br/>
    * <br/>
	* note: Only the geometry and mapping of one mesh is currently parsed. Group is not supported yet.<br/>
	* Class tested with the following 3D apps:<br/>
	* - Strata CX mac 5.0 ok<br/>
	* - Biturn ver 0.87b4 PC ok<br/>
	* - LightWave 3D OBJ Export v2.1 PC ok<br/>
	* - Max2Obj Version 4.0 PC --> ok, with no groups<br/>
	* - tags f,v,vt are being parsed<br/>
	* <br/>
	* export from apps as polygon group or mesh as .obj file.<br/>
    */
    public class Obj 
    {
		use namespace arcane;
    	
    	private var ini:Init;
        private var mesh:Mesh;
        private var scaling:Number;
    
        private function parseObj(data:String):void 
        {
            var lines:Array = data.split('\n');

            // zero start -> index start
            var vertices:Array = [new Vertex()];
            var uvs:Array = [new UV()];
            
            for each (var line:String in lines)
            {
                var trunk:Array = line.replace("  "," ").replace("  "," ").replace("  "," ").split(" ");
                switch (trunk[0])
                {
                    case "v":
                        // y and z swap
                        var x:Number =   parseFloat(trunk[1]) * scaling;
                        var y:Number = - parseFloat(trunk[3]) * scaling;
                        var z:Number =   parseFloat(trunk[2]) * scaling;
                        vertices.push(new Vertex(x, y, z));
                        break;
                    case "vt":
                        uvs.push(new UV(parseFloat(trunk[1]), parseFloat(trunk[2])));
                        break;
                    case "f":
                        var face0:Array = trysplit(trunk[1], "/");
                        var face1:Array = trysplit(trunk[2], "/");
                        var face2:Array = trysplit(trunk[3], "/");
                        var face3:Array = trysplit(trunk[4], "/");

                        if (face3 != null)
                        {
                            mesh.addFace(new Face(vertices[parseInt(face1[0])], vertices[parseInt(face0[0])], vertices[parseInt(face3[0])], 
                                             null, uvs[parseInt(face1[1])], uvs[parseInt(face0[1])], uvs[parseInt(face3[1])]));

                            mesh.addFace(new Face(vertices[parseInt(face2[0])], vertices[parseInt(face1[0])], vertices[parseInt(face3[0])], 
                                             null, uvs[parseInt(face2[1])], uvs[parseInt(face1[1])], uvs[parseInt(face3[1])]));
                        }
                        else
                        {
                            mesh.addFace(new Face(vertices[parseInt(face2[0])], vertices[parseInt(face1[0])], vertices[parseInt(face0[0])], 
                                             null, uvs[parseInt(face2[1])], uvs[parseInt(face1[1])], uvs[parseInt(face0[1])]));
                        }
                        break;
                    case "vn": // vector normal
                        break;
                    case "g": // group
                        break;
                }
            }
            
            mesh.type = ".Obj";
        }
            
        private static function trysplit(source:String, by:String):Array
        {
            if (source == null)
                return null;
            if (source.indexOf(by) == -1)
                return [source];
            return source.split(by);
        }
        
		/**
		 * Creates a new <code>Obj</code> object. Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods.
		 * 
		 * @param	data				The binary data of a loaded file.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * 
		 * @see away3d.loaders.Obj#parse()
		 * @see away3d.loaders.Obj#load()
		 */
        public function Obj(data:String, init:Object = null)
        {
            ini = Init.parse(init);

            scaling = ini.getNumber("scaling", 1) * 10;

            mesh = new Mesh(ini);

            parseObj(data);
        }

		/**
		 * Creates a 3d mesh object from the raw ascii data of a obj file.
		 * 
		 * @param	data				The ascii data of a loaded file.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * @param	loader	[optional]	Not intended for direct use.
		 * 
		 * @return						A 3d mesh object representation of the obj file.
		 */
        public static function parse(data:*, init:Object = null, loader:Object3DLoader = null):Mesh
        {
            return new Obj(Cast.string(data), init).mesh;
        }
    	
    	/**
    	 * Loads and parses a obj file into a 3d mesh object.
    	 * 
    	 * @param	url					The url location of the file to load.
    	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
    	 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.
    	 */
        public static function load(url:String, init:Object = null):Object3DLoader
        {
            return Object3DLoader.loadGeometry(url, parse, false, init);
        }
    }
}