package away3d.core.graphs.bsp
{
	public class BSPBuilder
	{
		public static function generateBuilder(fixTJunctions : Boolean = false, buildCollisionPlanes : Boolean = false, buildPVS : Boolean = false) : IBSPBuilder
		{
			var builder : IBSPBuilder = new BSPGeometryBuilder();

			// wrap with builder decorators as necessary
			if (fixTJunctions || buildCollisionPlanes || buildPVS)
				builder = new BSPPortalBuilder(builder);

			if (fixTJunctions)
				builder = new BSPTJunctionFixer(IBSPPortalProvider(builder));

			if (buildCollisionPlanes)
				builder = new BSPCollisionPlaneBuilder(IBSPPortalProvider(builder));

			if (buildPVS)
				builder = new BSPPVSBuilder(IBSPPortalProvider(builder));

			return builder;
		}
	}
}