package away3d.loaders
{
    import away3d.core.material.*;
    
    import flash.utils.Dictionary;
    
    /** Set of the named materials */
    public class MaterialLibrary
    {
        public var def:IMaterial;
        private var materials:Dictionary = new Dictionary();
    
        public function MaterialLibrary(def:IMaterial = null):void
        {
            this.def = def;
        }
    
        public function add(material:IMaterial, name:String):void
        {
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
