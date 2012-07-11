package com.sloader
{
	import com.sloader.loadhandlers.LoadHandler;
	
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.Dictionary;

	public class SLoader
	{
		private var _loaderContext:LoaderContext;
		
		private var _loadInfo:SLoaderInfo;
		
		private var _eventHandlers:Dictionary;
		
		private var _listLoaded:Array;
		
		private var _listReadyLoad:Array;
		
		private const _concurrent:uint = 3;
		
		////////////////////////////////////////////////////////////////////////
		private var _isLoading:Boolean;
		
		private var _lastProgressLoadedBytes:Number;
		
		private var _loadedBytes:Number;
		
		private var _currTotalFileCount:int;
		private var _currLoadedFileCount:int;
		
		private var _currTotalBytes:Number;
		private var _currLoadedBytes:Number;

		private var _currLoadPercentage:Number;
		////////////////////////////////////////////////////////////////////////
		
		public function SLoader(name:String, loaderContext:LoaderContext=null)
		{
			SLoaderManage.instance.addSLoader(name, this);
			
			_loaderContext = loaderContext ? loaderContext:new LoaderContext(false, ApplicationDomain.currentDomain, SecurityDomain.currentDomain);
			
			registerEventHandler();
			
			initializePar();
		}
		
		private function initializePar():void
		{
			_isLoading = false;
			_listLoaded = [];
			_listReadyLoad = [];
			_loadedBytes = 0;
			_loadInfo = new SLoaderInfo();
		}
		
		private function registerEventHandler():void
		{
			_eventHandlers = new Dictionary();
			_eventHandlers[SLoaderEventType.FILE_COMPLETE] = [];
			_eventHandlers[SLoaderEventType.FILE_ERROR] =  [];
			_eventHandlers[SLoaderEventType.FILE_PROGRESS] = [];
			_eventHandlers[SLoaderEventType.FILE_START] = [];
			_eventHandlers[SLoaderEventType.SLOADER_COMPLETE] = [];
			_eventHandlers[SLoaderEventType.SLOADER_PROGRESS] = [];
			_eventHandlers[SLoaderEventType.SLOADER_START] = [];
		}
		
		///////////////////////////////////////////////////////////////////////////
		// loadListManage
		///////////////////////////////////////////////////////////////////////////
		public function addFile(fileVO:SLoaderFile):void
		{
			checkLoadIt();
			checkFileVO(fileVO);
			checkRepeatFileVO(fileVO);
			
			_listReadyLoad.push(fileVO);
		}
		
		public function addFiles(files:Array):void
		{
			checkLoadIt();
			
			for (var i:int=0; i<files.length; i++)
			{
				var fileVO:SLoaderFile = files[i];
				checkFileVO(fileVO);
				checkRepeatFileVO(fileVO);
				
				_listReadyLoad.push(fileVO);
			}
		}
		
		public function removeFile(fileVO:SLoaderFile):void
		{
			checkLoadIt();
			
			var index:int = _listReadyLoad.indexOf(fileVO);
			if (index != -1)
				_listReadyLoad.splice(index, 1);
		}
		
		public function execute():void
		{
			checkLoadIt();
			
			if (_listReadyLoad.length < 1)
				return;
			
			_isLoading = true;
			
			currTotalBytes = 0;
			for each(var fileVO:SLoaderFile in _listReadyLoad)
			{
				if (isNaN(fileVO.size))
				{
					currTotalBytes = Number.NaN;
					break;
				}
				else
					currTotalBytes += fileVO.size;
			}
			
			currLoadedBytes = 0;
			currLoadedFileCount = 0;
			currTotalFileCount = _listReadyLoad.length;
			
			_execute(currLoadedFileCount);
		}
		
		private function _execute(fileIndex:int):void
		{
			var fileVO:SLoaderFile = _listReadyLoad[fileIndex];
			var fileType:String = SLoaderManage.instance.getFileType(fileVO).toLowerCase();
			var fileLoadHandlerClass:Class = SLoaderManage.instance.getFileLoadHandler(fileType);
			if (!fileLoadHandlerClass)
			{
				throw new Error("you not registered handler on ["+fileType+"]");
			}
			else
			{
				var loadHandler:LoadHandler = new fileLoadHandlerClass(fileVO, _loaderContext);
				loadHandler.setFileCompleteEventHandler(onFileComplete);
				loadHandler.setFileProgressEventHandler(onFileProgress);
				loadHandler.setFileStartEventHandler(onFileStart);
				loadHandler.setFileIoErrorEventHandler(onFileIoError);
				loadHandler.load();
			}
		}
		
		///////////////////////////////////////////////////////////////////////////
		// eventManage
		///////////////////////////////////////////////////////////////////////////
		public function addEventListener(type:String, handler:Function):void
		{
			if (!_eventHandlers[type])
				throw new Error("event name["+type+"] is Invalid");
			
			_eventHandlers[type].push(handler);
		}
		
		public function removeEventListener(type:String, handler:Function):void
		{
			if (!_eventHandlers[type])
				return;
			
			var index:int = _eventHandlers[type].indexOf(handler);
			if (index != -1)
				_eventHandlers[type].splice(index, 1);
		}
		
		private function onFileStart(fileVO:SLoaderFile):void
		{
			_lastProgressLoadedBytes = 0;
			
			if (_currLoadedFileCount == 0)
				onSloaderStart(fileVO);

			executeHandlers(_eventHandlers[SLoaderEventType.FILE_START], fileVO);
		}
		
		private function onFileProgress(fileVO:SLoaderFile):void
		{
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_PROGRESS], fileVO);
			onSloaderProgress(fileVO);
		}
		
		private function onFileComplete(fileVO:SLoaderFile):void
		{
			currLoadedFileCount ++;
			
			_listLoaded.push(fileVO);
			
			SLoaderManage.instance.addFileToGroup(fileVO.group, fileVO);
			
			var hasfile:Boolean = _currTotalFileCount > _currLoadedFileCount;
			_isLoading = hasfile;
			
			if (!hasfile)
			{
				_currLoadedFileCount = 0;
				_listReadyLoad.length = 0;
			}
			
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_COMPLETE], fileVO);
			
			if (hasfile)
				_execute(_currLoadedFileCount);
			else
				onSloaderComplete(fileVO);
		}
		
		private function onFileIoError(error:SLoaderError):void
		{
			currLoadedFileCount++;
			
			var hasfile:Boolean = _currTotalFileCount > _currLoadedFileCount;
			_isLoading = hasfile;
			
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_ERROR], error);
			
			if (hasfile)
				_execute(_currLoadedFileCount);
			else
				onSloaderComplete(error.file);
		}
		
		private function onSloaderStart(currFileVO:SLoaderFile):void
		{
			executeHandlers(_eventHandlers[SLoaderEventType.SLOADER_START], _loadInfo);
		}
		
		private function onSloaderProgress(currFileVO:SLoaderFile):void
		{
			_lastProgressLoadedBytes = currFileVO.loaderInfo.loadedBytes - _lastProgressLoadedBytes;
			currLoadedBytes += _lastProgressLoadedBytes;
			loadedBytes += _lastProgressLoadedBytes;
			if (isNaN(_currTotalBytes))
			{
				currLoadPercentage = _currLoadedFileCount/_currTotalFileCount
					+ currFileVO.loaderInfo.loadedBytes/currFileVO.loaderInfo.totalBytes/_currTotalFileCount;
			}
			else
			{
				currLoadPercentage = _currLoadedBytes/_currTotalBytes;
			}
			_lastProgressLoadedBytes = currFileVO.loaderInfo.loadedBytes;
			
			executeHandlers(_eventHandlers[SLoaderEventType.SLOADER_PROGRESS], _loadInfo);
		}
		
		private function onSloaderComplete(currFileVO:SLoaderFile):void
		{
			executeHandlers(_eventHandlers[SLoaderEventType.SLOADER_COMPLETE], _loadInfo);
		}
		
		private function executeHandlers(handlers:Array, file:*):void
		{
			for (var i:int=0; i<handlers.length; i++)
			{
				var handler:Function = handlers[i];
				handler(file);
			}
		}
		
		///////////////////////////////////////////////////////////////////////////
		// check
		///////////////////////////////////////////////////////////////////////////
		private function checkLoadIt():void
		{
			if (_isLoading)
				throw new Error("Refused the operation, is loaded in");
		}
		
		private function checkFileVO(fileVO:SLoaderFile):void
		{
			if (
				!fileVO.name || 
				!fileVO.url || 
				!fileVO.title || 
				!fileVO.group ||
				fileVO.group == ""
			)
				throw new Error("The fileVO parameter is incorrect");
		}
		
		private function checkRepeatFileVO(fileVO:SLoaderFile):void
		{
			var globalHasFileVO:Boolean = SLoaderManage.instance.getFileVO(fileVO.title) != null;
			if (globalHasFileVO)
				throw new Error("Duplication of add file(title:"+fileVO.title+")");
			
			for each(var file:SLoaderFile in _listReadyLoad)
			{
				if (file.title == fileVO.title)
					throw new Error("Duplication of add file(title:"+fileVO.title+")");
			}
		}
		
		///////////////////////////////////////////////////////////////////////////
		// get set
		///////////////////////////////////////////////////////////////////////////		
		public function getFileVO(fileTitle:String):SLoaderFile
		{
			if (!_listLoaded)
				return null;
			
			for each(var fileVO:SLoaderFile in _listLoaded)
			{
				if (fileVO.title == fileTitle)
					return fileVO;
			}
			return null;
		}
		
		public function get loadInfo():SLoaderInfo
		{
			return _loadInfo;
		}
		
		private function set loadedBytes(value:Number):void
		{
			_loadedBytes = value;
			_loadInfo.loadedBytes = value;
		}
		
		private function get loadedBytes():Number
		{
			return _loadedBytes;
		}
		
		private function set currLoadedBytes(value:Number):void
		{
			_currLoadedBytes = value;
			_loadInfo.currLoadedBytes = value;
		}
		
		private function get currLoadedBytes():Number
		{
			return _currLoadedBytes;
		}
		
		private function set currTotalBytes(value:Number):void
		{
			_currTotalBytes = value;
			_loadInfo.currTotalBytes = value;
		}
		
		private function get currTotalBytes():Number
		{
			return _currTotalBytes;
		}
		
		private function set currLoadedFileCount(value:int):void
		{
			_currLoadedFileCount = value;
			_loadInfo.currLoadedFileCount = value;
		}
		
		private function get currLoadedFileCount():int
		{
			return _currLoadedFileCount;
		}
		
		private function set currTotalFileCount(value:int):void
		{
			_currTotalFileCount = value;
			_loadInfo.currTotalFileCount = value;
		}
		
		private function get currTotalFileCount():int
		{
			return _currTotalFileCount;
		}
		
		private function set currLoadPercentage(value:Number):void
		{
			_currLoadPercentage = value;
			_loadInfo.currLoadPercentage = value;
		}
		
		private function get currLoadPercentage():Number
		{
			return _currLoadPercentage;
		}
		
		public function get isLoading():Boolean
		{
			return _isLoading;
		}
	}
}