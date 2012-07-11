package com.sloader
{
	import flash.system.LoaderContext;

	// contains the SLoader instance current information
	public class SLoaderInfo
	{
		public var loadedFileCount:int;
		
		public var loadedBytes:Number;

		public var currLoadedFileCount:int;
		
		public var currTotalFileCount:int;
		
		public var currLoadedBytes:Number;
		
		public var currTotalBytes:Number;

		public var currLoadPercentage:Number;
		
		public var loaderContext:LoaderContext;
	}
}