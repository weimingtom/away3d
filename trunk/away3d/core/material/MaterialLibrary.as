package away3d.core.material
{
    import away3d.core.proto.*;
    
    import flash.utils.Dictionary;
    
    /** Set of the named materials */
    public class MaterialLibrary
    {
        private var def:IMaterial;
        private var materials:Dictionary = new Dictionary();
    
        public function MaterialLibrary(def:IMaterial = null):void
        {
            this.def = def;
        }
    
        public function add(material:IMaterial, name:String):void
        {
            if (name == "default")
                def = material;
            else
                materials[name] = material;
        }
    
        public function getMaterialByName(name:String):IMaterial
        {
            return (materials[name] || def);
        }
    
        public function getTriangleMaterial(name:String):ITriangleMaterial
        {
            return (materials[name] || def) as ITriangleMaterial;
        }
    
    }
}
