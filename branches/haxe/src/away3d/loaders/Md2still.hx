package away3d.loaders;

    import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.utils.*;
    
    import flash.utils.*;

	use namespace arcane;
	
    /**
    * File loader for the Md2 file format (non-animated version).
    * 
    * @author Philippe Ajoux (philippe.ajoux@gmail.com)
    */
    class Md2still extends AbstractParser {
    	
    	var ini:Init;
        var ident:Int;
        var version:Int;
        var skinwidth:Int;
        var skinheight:Int;
        var framesize:Int;
        var num_skins:Int;
        var num_vertices:Int;
        var num_st:Int;
        var num_tris:Int;
        var num_glcmds:Int;
        var num_frames:Int;
        var offset_skins:Int;
        var offset_st:Int;
        var offset_tris:Int;
        var offset_frames:Int;
        var offset_glcmds:Int;
        var offset_end:Int;
        var mesh:Mesh;
        var scaling:Float;
    
        function parseMd2still(data:ByteArray):Void
        {
            data.endian = Endian.LITTLE_ENDIAN;

            var vertices:Array<Dynamic> = [];
            var uvs:Array<Dynamic> = [];
            
            ident = data.readInt();
            version = data.readInt();

            // Make sure it is valid MD2 file
            if (ident != 844121161 || version != 8)
                throw new Error("Error loading MD2 file: Not a valid MD2 file/bad version");
                
            skinwidth = data.readInt();
            skinheight = data.readInt();
            framesize = data.readInt();
            num_skins = data.readInt();
            num_vertices = data.readInt();
            num_st = data.readInt();
            num_tris = data.readInt();
            num_glcmds = data.readInt();
            num_frames = data.readInt();
            offset_skins = data.readInt();
            offset_st = data.readInt();
            offset_tris = data.readInt();
            offset_frames = data.readInt();
            offset_glcmds = data.readInt();
            offset_end = data.readInt();

            var i:Int;
            // Vertice setup
            //      Be sure to allocate memory for the vertices to the object
            //      These vertices will be updated each frame with the proper coordinates
            for (i = 0; i < num_vertices; i++)
                vertices.push(new Vertex());

            // UV coordinates
            data.position = offset_st;
            for (i = 0; i < num_st; i++)
                uvs.push(new UV(data.readShort() / skinwidth, 1 - ( data.readShort() / skinheight) ));

            // Faces
            data.position = offset_tris;
            for (i in 0...num_tris)
            {
                var a:Int = data.readUnsignedShort();
                var b:Int = data.readUnsignedShort();
                var c:Int = data.readUnsignedShort();
                var ta:Int = data.readUnsignedShort();
                var tb:Int = data.readUnsignedShort();
                var tc:Int = data.readUnsignedShort();
                
                mesh.addFace(new Face(vertices[a], vertices[b], vertices[c], null, uvs[ta], uvs[tb], uvs[tc]));
            }
            
            // Frame animation data
            //      This part is a little funky.
            data.position = offset_frames;
            readFrames(data, vertices, num_frames);
            
            mesh.type = ".Md2";
        }
        
        function readFrames(data:ByteArray, vertices:Array<Dynamic>, num_frames:Int):Void
        {
            for (i in 0...num_frames)
            {
                var frame:Dynamic = {name:""};
                
                var sx:Int = data.readFloat();
                var sy:Int = data.readFloat();
                var sz:Int = data.readFloat();
                
                var tx:Int = data.readFloat();
                var ty:Int = data.readFloat();
                var tz:Int = data.readFloat();

                for (j in 0...16)
                {
                    var char:Int = data.readUnsignedByte();
                    if (char != 0)
                        frame.name += String.fromCharCode(char);
                }
                
                for (h in 0...vertices.length)
                {
                    vertices[h].x = -((sx * data.readUnsignedByte()) + tx) * scaling;
                    vertices[h].z = ((sy * data.readUnsignedByte()) + ty) * scaling;
                    vertices[h].y = ((sz * data.readUnsignedByte()) + tz) * scaling;
                    data.readUnsignedByte(); // "vertex normal index"
                }
                break; // only 1st frame for now
            }
        }
        
		/**
		 * Creates a new <code>Md2Still</code> object. Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods.
		 * 
		 * @param	data				The binary data of a loaded file.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * 
		 * @see away3d.loaders.Md2Still#parse()
		 * @see away3d.loaders.Md2Still#load()
		 */
        public function new(data:Dynamic, ?init:Dynamic = null)
        {
            ini = Init.parse(init);

            scaling = ini.getNumber("scaling", 1) * 100;

            mesh = cast( (container = new Mesh(ini)), Mesh);

            parseMd2still(Cast.bytearray(data));
        }

		/**
		 * Creates a 3d mesh object from the raw xml data of an md2 file.
		 * 
		 * @param	data				The binary data of a loaded file.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * 
		 * @return						A 3d mesh object representation of the md2 file.
		 */
        public static function parse(data:Dynamic, ?init:Dynamic = null):Mesh
        {
            return cast( Object3DLoader.parseGeometry(data, Md2still, init).handle, Mesh);
        }
    	
    	/**
    	 * Loads and parses an md2 file into a 3d mesh object.
    	 * 
    	 * @param	url					The url location of the file to load.
    	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
    	 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.
    	 */
        public static function load(url:String, ?init:Dynamic = null):Object3DLoader
        {
            return Object3DLoader.loadGeometry(url, Md2still, true, init);
        }
    }
