package com.sloader
{
	import com.sloader.loadhandlers.LoadHandler;
	
	import flash.system.ApplicationDomain;

	public class SLoaderFileInfo
	{
		public var applicationDomain:ApplicationDomain;
		public var loader:*;
		public var loadedBytes:int;
		public var totalBytes:int;
		public var loadHandler:LoadHandler;
	}
}