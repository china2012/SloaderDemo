package com.sloader
{
	import com.sloader.loadhandlers.LoadHandler;
	
	import flash.system.ApplicationDomain;

	public class SLoaderFileInfo
	{
		// the loader Class may be (Loader, UrlLoader, Sound,,,,)
		// changes according to file type
		public var loader:*;
		
		// the file loaded size in current loading
		public var loadedBytes:int;
		
		// file total Bytes in current loading
		public var totalBytes:int;
		
		// according to the file types load handling procedures
		public var loadHandler:LoadHandler;
	}
}