package com.sloader.loadhandlers
{
	import com.sloader.SLoaderFile;
	import com.sloader.SLoaderFileInfo;
	
	import flash.system.LoaderContext;

	public class LoadHandler
	{
		protected var _file:SLoaderFile;
		protected var _loaderContext:LoaderContext;

		protected var _onFileComplete:Function = null;
		protected var _onFileProgress:Function = null;
		protected var _onFileStart:Function = null;
		protected var _onFileIoError:Function = null;

		public function LoadHandler(fileVO:SLoaderFile, loaderContext:LoaderContext)
		{
			_file = fileVO;
			_file.loaderInfo = new SLoaderFileInfo();
			_loaderContext = loaderContext;
		}

		public function setFileStartEventHandler(handler:Function):void
		{
			_onFileStart = handler;
		}

		public function setFileProgressEventHandler(handler:Function):void
		{
			_onFileProgress = handler;
		}

		public function setFileCompleteEventHandler(handler:Function):void
		{
			_onFileComplete = handler;
		}

		public function setFileIoErrorEventHandler(handler:Function):void
		{
			_onFileIoError = handler;
		}

		public function load():void
		{

		}
		
		public function unLoad():void
		{
			_file.size = Number.NaN;
			_file.loaderInfo.loadedBytes = 0;
			_file.loaderInfo.totalBytes = 0;
		}
	}
}