package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;
	import away3d.core.stats.*;
    
    /** Regular polygon */
    public class RegularPolygon extends Mesh
    {
        public function RegularPolygon(init:Object = null) 
        {
            super(init);
                 
            init = Init.parse(init);

            var radius:Number = init.getNumber("radius", 100, {min:0});
            var sections:int = init.getInt("sections", 8, {min:3});
            var mapping:String = init.getString("mapping", "rotate");

            var tp:Number = 2 * Math.PI;
            var i:int;

            var vertices:Array = []
            for (i = 0; i < sections; i++)
                vertices.push(new Vertex(radius*Math.cos(i*tp/sections), 0, radius*Math.sin(i*tp/sections)));

            var center:Vertex = new Vertex(0,0,0);
            vertices.push(center);

            var uvs:Array = [];
            var centeruv:UV;
            switch (mapping)
            {
                case "rotate":
                    for (i = 0; i <= sections; i++)
                        uvs.push(new UV(i / sections, 1));
                    centeruv = new UV(0.5, 0);
                    break;
                case "planar":
                    for (i = 0; i <= sections; i++)
                        uvs.push(new UV(Math.cos(i*tp/sections)/2+0.5, Math.sin(i*tp/sections)/2+0.5));
                    centeruv = new UV(0.5, 0.5);
                    break;
                default:
                    throw new Error("Unknown RegularPolygon mapping: "+mapping);
            }

            for (i = 0; i < sections; i++)
                addFace(new Face(center, vertices[i], vertices[(i+1) % sections], null, centeruv, uvs[i], uvs[i+1]));
				
			type = "RegularPolygon";
        	url = "primitive";
        }
    }
}