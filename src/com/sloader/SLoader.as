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
		
		private var _loadedFiles:Array;
		
		private var _loadedBytes:Number;
		
		private const _concurrent:uint = 3;
		
		////////////////////////////////////////////////////////////////////////
		private var _isLoading:Boolean;
		
		private var _lastProgressLoadedBytes:Number;
		
		private var _currLoadFiles:Array;
		private var _currLoadedFiles:Array;
		private var _currLoadErrorFiles:Array;
		
		private var _currTotalBytes:Number;
		private var _currLoadedBytes:Number;
		
		private var _currLoadingFiles:Array;

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
			_loadedFiles = [];
			
			_isLoading = false;
			
			_currLoadFiles = [];
			_currLoadingFiles = [];
			_currLoadedFiles = [];
			
			_loadedBytes = 0;
			_currLoadErrorFiles = [];
			_loadInfo = new SLoaderInfo();
			_loadInfo.currLoadingFiles = [];
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
			
			_currLoadFiles.push(fileVO);
		}
		
		public function addFiles(files:Array):void
		{
			checkLoadIt();
			
			for (var i:int=0; i<files.length; i++)
			{
				var fileVO:SLoaderFile = files[i];
				checkFileVO(fileVO);
				checkRepeatFileVO(fileVO);
				
				_currLoadFiles.push(fileVO);
			}
		}
		
		public function removeFile(fileVO:SLoaderFile):void
		{
			checkLoadIt();
			
			var index:int = _currLoadFiles.indexOf(fileVO);
			if (index != -1)
				_currLoadFiles.splice(index, 1);
		}
		
		public function execute():void
		{
			checkLoadIt();
			
			if (_currLoadFiles.length < 1)
				return;
			
			//////////////////////////////////
			// 初始化一些加载过程中会用到的数据
			_isLoading = true;
			
			currTotalBytes = 0;
			for each(var fileVO:SLoaderFile in _currLoadFiles)
			{
				if (isNaN(fileVO.size)){
					currTotalBytes = Number.NaN;
					break;
				}else{
					currTotalBytes += fileVO.size;
				}
			}
			
			currLoadedBytes = 0;
			
			_currLoadedFiles.length = 0;
			
			_currLoadErrorFiles.length = 0;
			
			//////////////////////////////////
			// 开始加载
			executeConcurrent();
		}
		
		private function _execute(fileVO:SLoaderFile):void
		{
			// 如果执行加载的文件
			//--【存在于加载出错文件列表】
			//--【存在于本次已经加载列表中】
			//--【不存在于本次加载列表】
			// 则放弃加载
			if (
				_currLoadErrorFiles.indexOf(fileVO) != -1 ||
				_currLoadedFiles.indexOf(fileVO) != -1 ||
				_currLoadFiles.indexOf(fileVO) == -1
			)
				return;
			
			var fileType:String = SLoaderManage.instance.getFileType(fileVO).toLowerCase();
			var loadHandlerClass:Class = SLoaderManage.instance.getFileLoadHandler(fileType);
			if (!loadHandlerClass)
			{
				throw new Error("you not registered handler on ["+fileType+"]");
			}
			else
			{
				var loadHandler:LoadHandler = new loadHandlerClass(fileVO, _loaderContext);
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
			
			if (_currLoadedFiles.length == 0)
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
			_currLoadedFiles.push(fileVO);
			
			_loadedFiles.push(fileVO);
			
			var loadingIndex:int = _currLoadingFiles.indexOf(fileVO);
			if (loadingIndex != -1)
				_currLoadingFiles.splice(loadingIndex, 1);
			
			SLoaderManage.instance.addFileToGroup(fileVO.group, fileVO);
			
			var hasfile:Boolean = _currLoadFiles.length > _currLoadedFiles.length;
			_isLoading = hasfile;
			
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_COMPLETE], fileVO);
			
//			var rest:int = _currLoadFiles.length - _currLoadedFiles.length - _currLoadErrorFiles.length;
//			trace(fileVO.name + "-加载成功..,"+"当前并发["+_currLoadingFiles.length+"],系统允许最高["+(_concurrent>rest ? rest:_concurrent)+"]");
			executeConcurrent();
			
			if (!hasfile)
				onSloaderComplete(fileVO);
		}
		
		private function onFileIoError(error:SLoaderError):void
		{
			_currLoadErrorFiles.push(error.file);
			
			var loadingIndex:int = _currLoadingFiles.indexOf(error.file);
			if (loadingIndex != -1)
				_currLoadingFiles.splice(loadingIndex, 1);
			
			var hasfile:Boolean = _currLoadFiles.length > _currLoadedFiles.length;
			_isLoading = hasfile;
			
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_ERROR], error);
			
			if (!hasfile)
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
				currLoadPercentage = _currLoadedFiles.length/_currLoadFiles.length
					+ currFileVO.loaderInfo.loadedBytes/currFileVO.loaderInfo.totalBytes/_currLoadFiles.length;
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
			
			_currLoadFiles.length = 0;
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
		// 并发加载机制
		///////////////////////////////////////////////////////////////////////////
		private function executeConcurrent():void
		{
			var rest:int = _currLoadFiles.length - _currLoadedFiles.length - _currLoadErrorFiles.length;
			while (_currLoadingFiles.length < (_concurrent>rest ? rest:_concurrent) )
			{
				// 在本次加载队列中寻找一个【不在加载中】【没有加载成功】【没有加载出错】的文件进行加载操作
				var readyFileVO:SLoaderFile = null;
				for each(var file:SLoaderFile in _currLoadFiles)
				{
					if (
						_currLoadingFiles.indexOf(file) == -1 && 
						_loadedFiles.indexOf(file) == -1 &&
						_currLoadErrorFiles.indexOf(file) == -1
					){
						_currLoadingFiles.push(file);
						readyFileVO = file;
//						trace("【并发机制】添加["+file.name+"]----当前并发["+_currLoadingFiles.length+"], 系统允许最高["+(_concurrent > rest ? rest:_concurrent)+"]");
						
						break;
					}
				}
				
				if (readyFileVO)
					_execute(readyFileVO);
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
			
			for each(var file:SLoaderFile in _currLoadFiles)
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
			if (!_loadedFiles)
				return null;
			
			for each(var fileVO:SLoaderFile in _loadedFiles)
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