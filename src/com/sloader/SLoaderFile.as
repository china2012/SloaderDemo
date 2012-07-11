package com.sloader
{
	public class SLoaderFile
	{
		public var name:String;			// *
		public var title:String;			// *
		public var url:String;				// *
		public var version:String;

		// if you set type value, system will use it select file load handler procedures
		// else system use url determine file load handler
		public var type:String;
		
		// size can be used to accurately calculate the pecentage of the currently loaded data,
		// and, on currently load list, you must set size in all files the size, he can task effect
		public var size:Number;

		public var loaderInfo:SLoaderFileInfo;
	}
}