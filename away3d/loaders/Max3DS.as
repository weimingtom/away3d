/**
 * @author Philippe Ajoux (philippe.ajoux@gmail.com)
 */
package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    import flash.utils.*;

    public class Max3DS
    {
        private var mesh:Mesh3D;
        private var scaling:Number;

        public function Max3DS(data:ByteArray, material:IMaterial, init:Object = null)
        {
            init = Init.parse(init);

            scaling = init.getNumber("scaling", 1) * 100;

            mesh = new Mesh3D(material, init);

            parse3DS(data);
        }
        
        public static function parse(data:*, material:* = null, init:Object = null):Mesh3D
        {
            var max:Max3DS = new Max3DS(Cast.bytearray(data), Cast.material(material), init);
            return max.mesh;
        }
    
        private function parse3DS(data:ByteArray):void
        {
            // New revision's of Papervision3D have vertex and face data in a "Geometry" object.
            // I don't really understand this at all, but I think it is used so object share 
            // data and overall less memory usage. It's annoying. LAMEZ ;)
            var vertices:Array = mesh.vertices;
            var faces:Array = mesh.faces;
            
            // Temporary arrays for faces and uv coordinates
            var tempFaces:Array = new Array();
            var uvs:Array = new Array();
            
            // Other variables used in the parsing process
            var chunkID:uint, chunkLength:uint;
            var i:uint, size:uint;
            var buffer:String;
            var face:Object;
            
            // Endian needed to read in the binary data
            // MAKE SURE TO DO THIS, OR YOU WILL HATE LIFE (I did)
            data.endian = Endian.LITTLE_ENDIAN;
            
            while (data.bytesAvailable > 0)
            {
                chunkID = data.readUnsignedShort();
                chunkLength = data.readUnsignedInt();
                
                switch (chunkID)
                {
                // MAIN_CHUNK, EDITOR_CHUNK, TRIANGLE_MESH_BLOCK (ignored)
                // NOTE: We have to break because these blocks don't actually contain
                // data, but are more of header indicators, and thus don't have a length
                // so we need to just ignore them
                case 0x4d4d: break;
                case 0x3d3d: break;
                case 0x4100: break;
                
                // OBJECT_BLOCK
                //      We read in the object name using a temporary buffer
                case 0x4000:
                    buffer = "";
                    while ((size = data.readByte()) != 0)
                        buffer += String.fromCharCode(size);
                    mesh.name = buffer;
                    break;
                
                // VERTEX_BLOCK 
                case 0x4110:
                    size = data.readUnsignedShort();
                    for (i = 0; i < size; i++)
                        vertices.push(new Vertex3D(
                             data.readFloat() * scaling, 
                             data.readFloat() * scaling,
                             data.readFloat() * scaling
                        ));
                    break;
                    
                // FACE_BLOCK
                case 0x4120:
                    size = data.readUnsignedShort();
                    for (i = 0; i < size; i++)
                        tempFaces.push(
                        {
                            a: data.readUnsignedShort(),
                            b: data.readUnsignedShort(),
                            c: data.readUnsignedShort(),
                            flags: data.readUnsignedShort()
                        });
                    break;
                
                // TEXTURE_VERTEX_BLOCK
                case 0x4140:
                    throw new Error("TEXTURE_VERTEX_BLOCK");
                    size = data.readUnsignedShort();
                    for (i = 0; i < size; i++)
                        uvs.push(new NumberUV(data.readFloat(), data.readFloat()));
                    break;
                        
                // Other blocks are just skipped completely by their length
                default:
                    data.position += chunkLength - 6;
                }
            }
            

            // Actually add the faces with the proper UV coordinate texturing
            // NOTE: We actually support loading files that have no texturing!
            for each (face in tempFaces)
                if (uvs.length != vertices.length)
                {
                    // Add faces without any texturing
                    faces.push(new Face3D(vertices[face.c], vertices[face.b], vertices[face.a], null));

                }
                else
                {
                    // Add faces WITH texture mapping
                    faces.push(new Face3D(vertices[face.c], vertices[face.b], vertices[face.a], 
                                          null, uvs[face.c], uvs[face.b], uvs[face.a]));
                }
        }
    }
}