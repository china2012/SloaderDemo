package com.sloader
{
	import flash.system.LoaderContext;

	// contains the SLoader instance current information
	public class SLoaderInfo
	{
		// all loaded file number
		public var loadedFileCount:int;
		
		// all loaded file size
		public var loadedBytes:Number;

		// loaded list number of current
		public var currLoadedFileCount:int;
		
		//  load list number of current
		public var currTotalFileCount:int;
		
		// all loaded file size of current
		public var currLoadedBytes:Number;
		
		// all load list file size of current
		public var currTotalBytes:Number;

		// percentage of current list loaded
		public var currLoadPercentage:Number;
		
		// the load file of current
		public var currLoadFileList:Array;
		
		// all files will be loaded into here
		public var loaderContext:LoaderContext;
	}
}