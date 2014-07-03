
/* JavaScript content from js/initOptions.js in folder common */
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

document.addEventListener("deviceready", loginCheck, false);

function loginCheck() {
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db.transaction(function(tx) {
		tx.executeSql("select * from user where currentuser=1;", [], function(tx, res) {
			console.log('유저정보 셀렉트');
			console.log(res.rows.length);
			console.log('유저정보 셀렉트 끝');
			var currentUserCheck;
			if(res.rows.length==1){
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

//loginPushListSelect!!
function loginPushListSelect(){
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db.transaction(function(tx) {
		tx.executeSql("select * from message where type=0 order by id desc;",[],
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
								var notiID = res.rows.item(i).id;
								var receivedate=res.rows.item(i).receivedate;
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
						
								htmlTagli=htmlTagli.concat('<li class="scl_o"><p class="scl_tmb"><br /> <a href="#" onclick="javascript:pushListDelete('+notiID+');"><i class="fa fa-trash-o fa-2x"></i></a></p><a a href="#" onclick="javascript:pushLishClick('+notiID+');"><p class="scl_cnt"><span class="scl_messageTitle">'
										+ contentResult.notification.contentTitle
										+ '</span><br> <span class="scl_textContent">'
										+ contentText
										+ '</span> <span class="scl_date" id="'+notiID+'">'+receivedate+'</span></p></a></li>');
										                    }    
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
		 tx.executeSql("select * from message where type=0 order by id desc;",[],
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
										var notiID = res.rows.item(i).id;
										var receivedate=res.rows.item(i).receivedate;
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
										htmlTagli=htmlTagli.concat('<li class="scl_o"><p class="scl_tmb"><br /> <a href="#" onclick="javascript:pushListDelete('+notiID+');"><i class="fa fa-trash-o fa-2x"></i></a></p><a a href="#" onclick="javascript:pushLishClick('+notiID+');"><p class="scl_cnt"><span class="scl_messageTitle">'
												+ contentResult.notification.contentTitle
												+ '</span><br> <span class="scl_textContent">'
												+ contentText
												+ '</span> <span class="scl_date" id="'+notiID+'">'+receivedate+'</span></p></a></li>');
								                    }    
								$(".ul_pushList").html(htmlTagli);
								oScroll.refresh();
								console.log('메세지 리스트 셀렉트 받아오기끝');
								}		
							});
					});
}



