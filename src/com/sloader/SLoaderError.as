package com.sloader
{
	public class SLoaderError
	{
		public var file:SLoaderFile;
		public var desc:String;

		public function SLoaderError(fileVO:SLoaderFile, descStr:String)
		{
			file = fileVO;
			desc = descStr;
		}
	}
}