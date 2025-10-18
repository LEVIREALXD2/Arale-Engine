package funkin.backend.scripting.events;

import options.packages.Objects.OptionCata;

final class CataEvent extends CancellableEvent {
	/**
	 * Cata type for creating spesific option
	 */
	public var type:String;
	/**
	 * Created obj in addCata() function, so you doesn't need to create it again
	 */
	public var obj:OptionCata;

	public function new(type:String, obj:OptionCata)
	{
		super();
		this.type = type;
		this.obj = obj;
	}
}