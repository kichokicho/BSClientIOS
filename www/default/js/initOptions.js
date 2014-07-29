// Uncomment the initialization options as required. For advanced initialization options please refer to IBM Worklight Information Center 

var wlInitOptions = {

	// # Should application automatically attempt to connect to Worklight Server
	// on application start up
	// # The default value is true, we are overriding it to false here.
	connectOnStartup : false,

	// # The callback function to invoke in case application fails to connect to
	// Worklight Server
	// onConnectionFailure: function (){},

	// # Worklight server connection timeout
	// timeout: 30000,

	// # How often heartbeat request will be sent to Worklight Server
	// heartBeatIntervalInSecs: 20 * 60,

	// # Enable FIPS 140-2 for data-in-motion (network) and data-at-rest
	// (JSONStore) on iOS or Android.
	// Requires the FIPS 140-2 optional feature to be enabled also.
	// enableFIPS : false,

	// # Application Logger, see documentation more details.
	// - enabled - Determines if log messages are shown (true) or not (false)
	// - level - Logging level, most to least verbose: 'debug', 'log', 'info',
	// 'warn', 'error'
	// - stringify - Turn arguments into strings before printing to the console
	// (true) or not (false)
	// - pretty - Turns JSON Objects into well spaced and formated strings.
	// - tag.level - Append a level tag (e.g. [DEBUG] Message) to the message.
	// - tag.package - Append the package tag (e.g. [my.pkg] Message) to the
	// message if there is one
	// - whitelist - Array of package names to show (e.g ['my.pkg'])
	// - blacklist - Array of package names to ignore (e.g ['my.pkg'])
	// - nativeOptions - Object with configuration specific to underlying native
	// behavior (Android and IOS only)
	logger : {
		enabled : true,
		level : 'debug',
		stringify : true,
		pretty : false,
		tag : {
			level : false,
			pkg : true
		},
		whitelist : [],
		blacklist : [],
		nativeOptions : {
			capture : false
		}
	},

	// #Application Analytics
	// - enabled - Determines if analytics messages are sent to the server
	// - url - server that receives the analytics data (default:
	// [worklight-server]/analytics)
	analytics : {
		enabled : false
	// url : ''
	}

// # The options of busy indicator used during application start up
// busyOptions: {text: "Loading..."}
};


//현재 날자 구하기 
function nowDateResult(){
	var nowDate = new Date();
	var year = "" + nowDate.getFullYear();
	 console.log(year);
	var  month = "" + (nowDate.getMonth() + 1); if (month.length == 1) { month = "0" + month; }
	 console.log(month);
	var  day = "" + nowDate.getDate(); if (day.length == 1) { day = "0" + day; }
	 console.log(day);
	var  hour = "" + nowDate.getHours(); if (hour.length == 1) { hour = "0" + hour; }
	 console.log(hour);
	var  minute = "" + nowDate.getMinutes(); if (minute.length == 1) { minute = "0" + minute; }
	 console.log(minute);
	var  second = "" + nowDate.getSeconds(); if (second.length == 1) { second = "0" + second; }
	  console.log(second);
	var dateNowResult=year + "-" + month + "-" + day + " " + hour + ":" + minute + ":" + second;
	console.log('현재 날짜 구하기 결과');
	console.log(dateNowResult); 

	return dateNowResult;
}
//현재 날자 yyyy-mm-dd hh:mm:ss
var nowDataResult=nowDateResult();
console.log('현재 날짜 구하기 yyyy-mm-dd hh:mm:ss');
console.log(nowDataResult);


//busyindicator!!
window.busy = new WL.BusyIndicator();
//pageHistory!!
var pagesHistory = [];



//currentUserCheck
var currentLoginID;
var currentTokenID;
var listCateGory;
//var deviceID;



document.addEventListener("deviceready", loginCheck, false);

function loginCheck() {
//	console.log('디바이스 아이디 ');
//	deviceID=device.uuid;
//	console.log(deviceID);
//	console.log('디바이스 아이디 끝');
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db.transaction(function(tx) {
		tx.executeSql("select * from user where currentuser=1;", [], function(tx, res) {
			console.log('유저정보 셀렉트');
			console.log(res.rows.length);
			console.log('유저정보 셀렉트 끝');
			var currentUserCheck;
			if(res.rows.length>=1){
				currentUserCheck= "CurrentUser";
				currentLoginID= res.rows.item(0).userid;
				currentTokenID= res.rows.item(0).tokenid;
			}else{
				currentUserCheck="notCurrentUser";
			}
			//user Info check
			console.log("커런트유저 시작");
			console.log(currentUserCheck);
			console.log("커런트유저 끝");
			
			if (currentUserCheck=="CurrentUser") {
			
				$('#page-container').load("pages/pushList.html",function() {
					console.log('푸쉬 리스트로 이동');
					document.addEventListener("deviceready", loginPushListSelect, false);
						});
			} else {
				console.log("커런트유저가 존재하지 않음!");
				$('#page-container').load("pages/pushLogin.html", function() {
					//임시 코드
					console.log('로그인 페이지로 이동');

				});
			}

		});
	});

}

if (window.addEventListener) {
	window.addEventListener('load', function() {
		WL.Client.init(wlInitOptions);
	}, false);
} else if (window.attachEvent) {
	window.attachEvent('onload', function() {
		WL.Client.init(wlInitOptions);
	});
}



function pushListJSAtOnload() {
	var element = document.createElement("script");
	element.src = "js/pages/pushList.js";
	document.body.appendChild(element);
}

// Check for browser support of event handling capability
if (window.addEventListener)
	window.addEventListener("load", pushListJSAtOnload, false);
else if (window.attachEvent)
	window.attachEvent("onload", pushListJSAtOnload);
else
	window.onload = pushListJSAtOnload;

function utf8_to_b64(str) {
	return window.btoa(unescape(encodeURIComponent(str)));
}

function b64_to_utf8(str) {
	return decodeURIComponent(escape(window.atob(str)));
}


WL.App.overrideBackButton(wlbackFunc);
function wlbackFunc() {
	console.log('인잇 옵션 페이지 히스토리 사이즈!!1');
	console.log(pagesHistory.length);
	console.log('인잇 옵션 페이지 히스토리 사이즈!!1');
	if (pagesHistory.length == 0) {

		if (confirm("앱 을 종료 하시겠습니까?") == true) {
			WL.App.close();
		} else {
			return false;
		}
	} else {
		$("#page-container").load(pagesHistory.pop(), function() {

			document.addEventListener("deviceready", nativeBack, false);
		});

	}

}
//listCateGory

function andResumeFunction(){
	console.log('안드로이드 resume Function');


	if(pagesHistory.length==0){
		console.log("페이지 히스토리 0");
		loginPushListSelect();	
	}else if(pagesHistory.length==1){
		console.log('안드로이드 글로벌 카테고리');
		console.log(listCateGory);
		selectDetail(listCateGory);	
		 document.getElementById( 'bottom_div' ).scrollIntoView(true);
	}	
	
}

function refreshFunction(category){
	console.log('리프레쉬 펑션');
	console.log(category);

	if(pagesHistory.length==0){
		console.log("페이지 히스토리 0");
		loginPushListSelect();	
	}else if(pagesHistory.length==1){
		console.log("페이지 히스토리 1");
		selectDetail(category);	
		 document.getElementById( 'bottom_div' ).scrollIntoView(true);
	}	
}
//loginPushListSelect!!
function loginPushListSelect(){
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db.transaction(function(tx) {
		//order  by date(receivedate) DESC		Limit 1
		//select *  from Table order  by date(dateColumn) DESC
//		tx.executeSql("select *, SUM(case when read=0 then 1 else 0 end) as total from message where type=0 or type=1 or type=2 or type=3 group by category ",[],
//				function(tx, res) {
//					var selectLength = res.rows.length;
//				
//					//메세지가 없을때 						
//					if(selectLength==0){
//						
//						console.log('query length is 0..');
//						console.log(res.rows.item(0).total);
//					}else{
//									
//						console.log('quer Conunt 리절트 시작');
//						console.log(res.rows.item(0).total);
//						console.log(res.rows.item(0).total);
//						console.log('quer Conunt 리절트 시작');  
//				
//					}
//					
//
//							});

		
		
		                         //SUM(read)
		tx.executeSql("select * , SUM(read) as total from message where type=0 or type=1 or type=2 or type=3 group by category order  by datetime(receivedate) desc ;",[],
					function(tx, res) {
						var selectLength = res.rows.length;
						var htmlTagli="";
						//메세지가 없을때 						
						if(selectLength==0){
							htmlTagli=htmlTagli.concat("<br/><br/><br/><p style='text-align:center;color:#1172b6;'>수신된 메세지가 없습니다.</p>");
							$(".ul_pushList").html(htmlTagli);
						//수신된 메세지가 있을때
						}else{
										
						for (var i = 0; i < selectLength; i++) {
								var contentResult = res.rows.item(i).content;
								console.log('그룹바이 리절트 시작');
								console.log(contentResult);
								console.log('그룹바이 리절트 끝');
								var notiID = res.rows.item(i).id;
								var receivedate=res.rows.item(i).receivedate;
								var category=res.rows.item(i).category;
								var total=res.rows.item(i).total;
								console.log('total');
								console.log(total);
								console.log('total');
								console.log('카테고리시작 ');
								console.log(category);
								console.log('카테고리 끝');
								console.log('메세지수신날짜');
								console.log(receivedate);
								console.log('메세지수신날짜');
								var subReceive=receivedate.substring(0,10);
								var subnowDate=nowDataResult.substring(0, 10);
								if(subReceive==subnowDate){
									console.log('메세지 수신과 현재 날짜가 같아 ');
									receivedate=receivedate.substring(11,receivedate.length);
									console.log('시간날짜 초를 보여줌');
								}else{
									console.log('메세지 수신과 현재 날짜가 달라 ');
									receivedate=receivedate.substring(0,10);
									console.log('년월날 보여줌');
								}
								console.log("노티피케이션 아이디");
								console.log(notiID);
								console.log("노티피케이션 아이디 끝");
								contentResult = JSON.parse(contentResult);
								console.log(contentResult.notification.ticker);
								console.log(contentResult.notification.contentText);
								var contentText=contentResult.notification.contentText;
								 if(contentText.length>20){
								     	contentText=contentText.substring(0, 18);
									    contentText=contentText.concat('...');
								  }
								 var styleNonetag="";
								 if(total==0 ||total==null){
									 console.log('토탈이 0');
									 styleNonetag='style="display: none;"';
								 }else{
									 styleNonetag="";
								 }
//								 var newItag="";
//									if(res.rows.item(i).read==1){
//										
//									newItag='style="display: none;"';
//									
//									}else{
//										newItag='';
//										console.log('리드가 0인거');
//									}
									
//									console.log("htmlstart");
//									console.log(newItag);
//									console.log("htmlend");
								 
									htmlTagli=htmlTagli.concat('<li class="scl_o" data-val="'+category+'"><p class="scl_tmb"><br /> </p><a class="acategory" id="'+category+'" href="#"   onclick="javascript:pushLishClick(this.id);"><p class="scl_cnt"><span><input type="checkbox" value="'+category+'" name="check_catedelete" style="display:none;" class="cateListcheckBox"></span><span class="scl_messageTitle">'
											+ category
											+ '</span><br> <span class="scl_textContent">'
											+ contentText
											+ '</span><span class="scl_date" >'+receivedate+'&nbsp;&nbsp;<span '+styleNonetag+' class="badge">'+total+'</span></span></p></a></li>');
					                     
							
						}    
						console.log("완성된 html start");
						console.log(htmlTagli);
						console.log("완성된 html end");
						$(".ul_pushList").html(htmlTagli);
						
						oScroll.refresh();
						console.log('메세지 리스트 셀렉트 받아오기끝');
						}
						

								});

			});
	
	
}
//backButton
function nativeBack(){
	var db = window.sqlitePlugin.openDatabase({name : "PushDB"});
	db.transaction(function(tx) {
		
		
//		tx.executeSql("select *, SUM(case when read=0 then 1 else 0 end) as total from message where type=0 or type=1 or type=2 or type=3 group by category ",[],
//				function(tx, res) {
//					var selectLength = res.rows.length;
//				
//					//메세지가 없을때 						
//					if(selectLength==0){
//						
//						console.log('query length is 0..');
//						console.log(res.rows.item(0).total);
//					}else{
//									
//						console.log('quer Conunt 리절트 시작');
//						console.log(res.rows.item(0).total);
//						console.log(res.rows.item(0).total);
//						console.log('quer Conunt 리절트 시작');  
//				
//					}
//					
//
//							});

		
		//read SUM(case when read=0 then 1 else 0 end) 
		 tx.executeSql("select * ,SUM(read) as total from message where type=0 or type=1 or type=2 or type=3 group by category order  by datetime(receivedate)  desc ;",[],
						function(tx, res) {
							var selectLength = res.rows.length;
							var htmlTagli="";
							//메세지가 없을때 
							if(selectLength==0){
							   htmlTagli=htmlTagli.concat("<br/><br/><br/><p style='text-align:center;color:#1172b6;'>수신된 메세지가 없습니다.</p>");
								$(".ul_pushList").html(htmlTagli);
							//수신된 메세지가 있을때
								}else{
														
								for (var i = 0; i < selectLength; i++) {
										var contentResult = res.rows.item(i).content;
										console.log('그룹바이 리절트 시작');
										console.log(contentResult);
										console.log('그룹바이 리절트 끝');
										var notiID = res.rows.item(i).id;
										var receivedate=res.rows.item(i).receivedate;
										var category=res.rows.item(i).category;
										var total=res.rows.item(i).total;
										console.log('total');
										console.log(total);
										console.log('total');
										console.log('카테고리시작 ');
										console.log(category);
										console.log('카테고리 끝');
										console.log('메세지수신날짜');
										console.log(receivedate);
										console.log('메세지수신날짜');
										var subReceive=receivedate.substring(0,10);
										var subnowDate=nowDataResult.substring(0, 10);
										if(subReceive==subnowDate){
											console.log('메세지 수신과 현재 날짜가 같아 ');
											receivedate=receivedate.substring(11,receivedate.length);
											console.log('시간날짜 초를 보여줌');
										}else{
											console.log('메세지 수신과 현재 날짜가 달라 ');
											receivedate=receivedate.substring(0,10);
											console.log('년월날 보여줌');
										}
										console.log("노티피케이션 아이디");
										console.log(notiID);
										console.log("노티피케이션 아이디 끝");
										contentResult = JSON.parse(contentResult);
										console.log(contentResult.notification.ticker);
										console.log(contentResult.notification.contentText);
									    var contentText=contentResult.notification.contentText;
										//제목 길이  
									    if(contentText.length>20){
										      contentText=contentText.substring(0, 18);
											  contentText=contentText.concat('...');
										  }
										 var styleNonetag="";
										 if(total==0 ||total==null){
											 console.log('토탈이 0');
											 styleNonetag='style="display: none;"';
										 }else{
											 styleNonetag="";
										 }
//										 var newItag="";
//											if(res.rows.item(i).read==1){
//												
//											newItag='style="display: none;"';
//											
//											}else{
//												newItag='';
//												console.log('리드가 0인거');
//											}
											
//											console.log("htmlstart");
//											console.log(newItag);
//											console.log("htmlend");
										 
											htmlTagli=htmlTagli.concat('<li class="scl_o" data-val="'+category+'"><p class="scl_tmb"><br /> </p><a class="acategory" id="'+category+'" href="#"   onclick="javascript:pushLishClick(this.id);"><p class="scl_cnt"><span><input type="checkbox" value="'+category+'" name="check_catedelete" style="display:none;" class="cateListcheckBox"></span><span class="scl_messageTitle">'
													+ category
													+ '</span><br> <span class="scl_textContent">'
													+ contentText
													+ '</span><span class="scl_date" >'+receivedate+'&nbsp;&nbsp;<span '+styleNonetag+' class="badge">'+total+'</span></span></p></a></li>');
								}
								
								console.log("완성된 html start");
								console.log(htmlTagli);
								console.log("완성된 html end");
								$(".ul_pushList").html(htmlTagli);
								oScroll.refresh();
								console.log('메세지 리스트 셀렉트 받아오기끝');
								}		
							});
					});
}



