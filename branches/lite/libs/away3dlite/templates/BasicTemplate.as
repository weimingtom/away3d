package away3dlite.templates
{
	import away3dlite.arcane;
	import away3dlite.core.clip.*;
	import away3dlite.core.render.*;

	use namespace arcane;

	/**
	 * Template setup designed for general use.
	 */
	public class BasicTemplate extends Template
	{
		/** @private */
		arcane override function init():void
		{
			super.init();

			view.renderer = renderer = renderer ? renderer : view.renderer as BasicRenderer;
			view.clipping = clipping = clipping ? clipping : view.clipping;
		}

		/**
		 * The renderer object used in the template.
		 */
		public var renderer:BasicRenderer;

		/**
		 * The clipping object used in the template.
		 */
		public var clipping:Clipping;
	}
}