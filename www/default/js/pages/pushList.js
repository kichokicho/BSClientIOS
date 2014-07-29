var oScroll = new jindo.m.Scroll("scrollWrapper", {
	bUseHScroll : false,
	bUseVScroll : true,
	bUseMomentum : true,
	nDeceleration : 0.0005,
	nHeight : 0
});

var iphonebadgeCheck=false;


// scroll end

// revealsidebar start...
var oRevealSidebarUI = new jindo.m.RevealSidebarUI().attach({
	"beforeSlide" : function(we) {
		console.log(we.sType, we.sStatus);
	},
	"slide" : function(we) {
		console.log(we.sType, we.sStatus);
	},
	"beforeRestore" : function(we) {
		console.log(we.sType, we.sStatus);
	},
	"restore" : function(we) {
		console.log(we.sType, we.sStatus);
	}
});
jindo.m.bindPageshow(function(e) {
	console.log(e);
});




var devicePlatform=device.platform;

function deleteButtonCateOffFuncton() {

	console.log('헤더 클릭 편집 버튼 클릭 이벤트 ');
	$('.deleteOffButtonCate').hide();
	$('.deleteOnButtonCate').show();

	console.log('test');
	 $('.acategory').removeAttr("onclick");
		 
	
	
	// .fa-envelope{
	// margin-left: 32px;
	//
	// }
	// $('.fa-envelope')
	$('[name=check_catedelete]').each(function() {
		$('[name=check_catedelete]').show();
	});

}

function deleteSelectCateOnFuncton() {
	console.log('delete on  버튼 클릭 이벤트 ');
	 $('.acategory').attr("onclick", "javascript:pushLishClick(this.id);");
	if ($('[name=check_catedelete]:checked').length == 0) {
		console.log('check length is 0!!!');
		$('.deleteOffButtonCate').show();
		$('.deleteOnButtonCate').hide();
		$('[name=check_catedelete]').each(function() {
			$('[name=check_catedelete]').hide();
		});

	} else {
		var cateID = "";
		console.log('check length is not 0');
		$('[name=check_catedelete]:checked').each(function() {
			console.log($(this).val());
			cateID = cateID.concat("\""+$(this).val() + "\",");
		});
		console.log('before slice category');
		console.log(cateID);
		console.log('slice category');
		cateID = cateID.slice(0, -1);
		console.log(cateID);
		if (confirm("선택된 메세지를 삭제 하시겠습니까??") == true) { // 확인
			console.log("선택된 cateID 아이디");
			console.log(cateID);
			console.log("선택된 cateID 아이디");
			cateDelete(cateID);
			// deleteOneMessage(notiID);
			// oScroll.refresh();
		} else { // 취소
			$('.deleteOffButtonCate').show();
			$('.deleteOnButtonCate').hide();
			$('[name=check_catedelete]').each(function() {
				$('[name=check_catedelete]').attr('checked', false);
				$('[name=check_catedelete]').hide();

			});
			return;
		}
	}

	// $('.deleteOnButton').hide();
	// $('.deleteOffButton').show();

}

function cateDelete(cateID) {
	console.log('멀티 삭제 cateDelete 아이디 start');
	console.log(cateID);
	console.log(JSON.stringify(cateID));
	console.log('STrin gtest');
	console.log(' 삭제 cateDelete 아이디 end');
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db
			.transaction(function(tx) {
				tx
						.executeSql(
								//delete from message where id in
								"delete from message where category in(" + cateID
										+ ")",
								[],
								function(tx, res) {
									var deleteResult = res.rowsAffected;
									console
											.log('삭제 쿼리 결과 !!!!!!!!!!!!!!!!!!!!!!!');
									console.log(deleteResult);
									if (deleteResult !== 0) {
										var cateArr = [];
										cateArr = cateID.replace(/"/g, "").split(',');

										for (var i = 0; i < cateArr.length; i++) {
											console.log('in for start');
											console.log(cateArr[i]);
											console.log($("li[data-val*="+cateArr[i]+"]"));
											console.log('li select test end');
											 $('li').each(function(){
												 console.log('chan');
												 console.log($(this).data('val'));
												 console.log(';chan..ebd');
												   if($(this).data('val')==cateArr[i]){
													   console.log($(this).data('val'));
												    console.log('select .remove... li ');
												    console.log($(this).remove());
												    console.log('select remove li end..');
												  }
												});
										
											console.log('in for cateArr end');
										}

										$('.deleteOffButtonCate').show();
										$('.deleteOnButtonCate').hide();
										$('[name=check_catedelete]').each(
												function() {
													$('[name=check_catedelete]')
															.hide();
												});
										
										var divTagLength = $('.ul_pushList li').length;
										console.log('.ul_pushList li 테그의 길이가 영이냐?');
										console.log(divTagLength);
										console.log('.ul_pushList li 테그의 길이가 영이냐?');
										if (divTagLength == 0) {
											console.log('영입니다');
											$('.ul_pushList')
											.html(
													'<br/><br/><br/><p style="text-align:center;color:#1172b6;">수신된 메세지가 없습니다.</p>');
										}
										oScroll.refresh();
										console.log("메세지 다중 삭제 !!!!!!!");
									} else {
										console.log("!!삭제 실패 삭제 실패 !!");

									}
								});
			});

}

//var longpress;
//
//$(".scl_o").on('mousedown' ,function(){      
// longpress=true;    
// setTimeout(function() {    
//    if(longpress)
//     alert("long press works!");         
//                  }, 3000);
//});
//$(".scl_o").on('mouseup' ,function(){      
//    longpress=false;    
//});



//var timer;
//var istrue = false;
//var delay = 1000; // how much long u have to hold click in MS
//function onMouseDown()
//{
//	
//	console.log('다운이벤트');
//   istrue = true;
//   timer = setTimeout(function(){ makeChange();},delay);
//}
//function onMouseUp()
//{
//	
//	console.log('업이벤트');
//   istrue =false;
//}
//
//
//function makeChange()
//{
//      if(timer)
//      clearTimeout(timer);
//      
//      if(istrue)
//      {
//            /// rest of your code
//          alert('holding');
//
//      }
//}


//$(document).mousedown(function(e){
//  console.log('마우스 다움!!!');
//});   
//$(document).mouseup(function(e){
//    console.log('마우스 온!!!');
//});


// pushList Click !!
function pushLishClick(catecory) {
	
	var startDateTime = new Date();
    var startDateTimeM= startDateTime.getTime();
    listCateGory=catecory;
    console.log(" 카테고리 start");
	console.log(catecory);
	console.log(" 카테고리 end");

	var endDateTime = new Date();
    var endDateTimeM=endDateTime.getTime();
    
	var resultTime=endDateTimeM-startDateTimeM;
	console.log('클릭 타임 시작');
	console.log(resultTime);
    console.log('클릭타임 끝');
	if (pagesHistory.length == 0) {
		
		pagesHistory.push("pages/pushList.html");
	}

	$("#page-container").load("pages/pushDetail.html", function() {
		
		console.log('푸쉬리스트 클릭 1');
		selectDetail(catecory);
		console.log('푸쉬리스트 클릭 2');
		detailJsAdd();
                              
//                              console.log("=======   iphonebadgeCheck :" + iphonebadgeCheck);
//                              
//                              console.log("=======   devicePlatform : "+ devicePlatform);
//                              
//                              
//                              if(iphonebadgeCheck&&devicePlatform==="iOS"){
//                              console.log('업데이트시 아이폰 코도바 플러그인 호출 ');
//                              cordova.exec(badgeSendSuccess, badgeSendFailure, "BadgeSendPlugin", "badgeSend", []);
//                              
//                              //											iphonebadgeCheck=false;
//                              }
//                              
//                              iphonebadgeCheck=false;

	});
                         
                         


	
}





function detailJsAdd() {
	var element = document.createElement("script");
	element.src = "js/pages/pushDetail.js";
	document.body.appendChild(element);
}


// pushList Click !! select Detail query page !!!
function selectDetail(category) {
	console.log('푸쉬리스트 클릭 3');
	
	if($('.categoryTitle').length){
		
	}else{
		$('<span class="categoryTitle">'+category+'</span>').insertAfter(".bsMobileMessageDetailI");
	}
	
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	console.log('푸쉬리스트 클릭 4');
	db
			.transaction(function(tx) {
				console.log('푸쉬리스트 클릭 5');
				console.log('category:' + category);
				tx
						.executeSql(
								"select * from message where category = ? and ( type= 0 or type= 1 or type= 2 or type= 3);",
								[ category ],
								function(tx, res) {
									console.log('푸쉬리스트 클릭 6');
									var selectLength = res.rows.length;
							
									var resultHtml="";
									if (selectLength == 0) {
										console.log('푸쉬리스트 클릭 7');
									} else {
										console.log('푸쉬리스트 클릭 8');
										for (var i = 0; i < selectLength; i++) {
											var contentResult = res.rows
													.item(i).content;
											var notiId=res.rows.item(i).id;
											
											
											console.log('푸쉬리스트 클릭 9');
											
											console.log('noti id');
											console.log(notiId);
											console.log('notiidend');
											
											
											
											var receivedate=res.rows.item(i).receivedate;

											console.log('메세지수신날짜');
											console.log(receivedate);
											console.log('메세지수신날짜');
//											var subReceive=receivedate.substring(0,10);
//											var subnowDate=nowDataResult.substring(0, 10);
//											if(subReceive==subnowDate){
//												console.log('메세지 수신과 현재 날짜가 같아 ');
//												receivedate=receivedate.substring(11,receivedate.length);
//												console.log('시간날짜 초를 보여줌');
//											}else{
//												console.log('메세지 수신과 현재 날짜가 달라 ');
//												receivedate=receivedate.substring(0,10);
//												console.log('년월날 보여줌');
//											}
											var dateyyy=receivedate.substring(0,10);
											var datetime=receivedate.substring(11,receivedate.length);
											
											
											
											
											
											contentResult = JSON
													.parse(contentResult);
											console
													.log(contentResult.notification.ticker);
											console
													.log(contentResult.notification.htmlContent);
//											console
//													.log(contentResult.notification.imageName);
											var decContentText = contentResult.notification.htmlContent;
											var contentTitle=contentResult.notification.contentTitle;
//											var backImageName = contentResult.notification.imageName;
											var userPhone=contentResult.notification.userPhone;
											console.log("user Phone!!!!!");
											console.log(userPhone);
											if(userPhone==null||userPhone==""){
												userPhone="번호없음";
											}
											var pollId;
											if(contentResult.notification.pollID){
												pollId=contentResult.notification.pollID;
											}
											
											console.log('노티피 케이션 리절트 ');
											console.log(contentResult.notification);
											console.log('메세지에서 나온 설문조사 아이디');
									
											//https://210.108.94.90/v1/auth
	//										var backUrl = "url('http://192.168.42.217:9090/static/"
//											var backUrl = "url('http://210.108.94.90/static/"
//													+ backImageName + "')";
//											console.log("백그라운드 이미지 url");
//											console.log(backUrl);
											decContentText = b64_to_utf8(decContentText);
//											console.log("백그라운드 이미지 네임");
//											console.log(backImageName);
											console.log("테그 디코딩 결과");
											console.log(decContentText);
											console.log("테그 디코딩 결과");
											var read=res.rows.item(i).read;
											
											if(read==1){
												console.log('read 가 1');
												tx.executeSql("UPDATE  message SET read =0 WHERE id = ?", [notiId],
														function(tx, res) {
															console.log("update 결과 처리시작");
															var updateResult=res.rowsAffected;
															console.log(updateResult);
															console.log("update 결과 처리끝");
															if(updateResult==1){
																console.log("update 결과 1111");
																
//																if(iphonebadgeCheck&&devicePlatform==="iOS"){
//																	console.log('업데이트시 아이폰 코도바 플러그인 호출 ');
//																	 cordova.exec(badgeSendSuccess, badgeSendFailure, "BadgeSendPlugin", "badgeSend", []);
//																	 
//																	iphonebadgeCheck=false;
//																}
																
																iphonebadgeCheck=true;
																//sqlite device id get 
																
															}else{
																console.log("update 실패!!");
																console.log("update 실패");
																
															}
														});
												
											}
											//UPDATE user SET currentuser = 1 WHERE userid = ?", [loginId]
											//읽은 메세지 업데이트 처리 
										
											
											// $('.scl_cnt').css({
											// "background-color": "#ffe",
											// "color":"yellow" });
											// style="background-image:
											// url('http://img.naver.net/static/www/u/2013/0731/nmms_224940510.gif');
											// $(".rs-content").html(
											// "<br/><br/><br/><div
											// style='text-align:left;margin-left:20px;'>"
											// + decContentText
											// + "</div>");
											console.log("timestart");
											console.log(dateyyy);
											console.log("time end");
											if(category=="설문조사"){
											var surveyNoid=contentResult.notification.noid;
											console.log('설문조사 무기명 유무');
											console.log(surveyNoid);
											resultHtml=resultHtml.concat('<li id="'+notiId+'"><time class="cbp_tmtime"><span><input type="checkbox" value="'+notiId+'" name="check_delete" style="display:none;" class="mycheckbox2"></span><span style="color:#1172b6;">'+dateyyy+'</span> <span>'+datetime+'</span></time><div class="cbp_tmlabel"> <h3>'+contentTitle+'</h3><br/><div class="'+notiId+'adminData">'+decContentText+'</div><a href="#" onclick="researchRes('+notiId+','+pollId+','+surveyNoid+')" class="cd-read-more">응답</a></div></li>');
									
			
											}else{
												resultHtml=resultHtml.concat('<li id="'+notiId+'"><time class="cbp_tmtime"><span><input type="checkbox" value="'+notiId+'" name="check_delete" style="display:none;" class="mycheckbox2"></span><span style="color:#1172b6;">'+dateyyy+'</span> <span>'+datetime+'</span></time><div class="cbp_tmlabel"> <h3>'+contentTitle+'</h3><br/><div class="'+notiId+'adminData">'+decContentText+'</div><br/><a href="tel:'+userPhone+'" class="cd-read-more phonehover">'+userPhone+'</a></div></li>');
												
											
											}
	
											
//											<a href="#0" class="cd-read-more">Delete</a>
											
											
											// p {
											// text-align: left;
											// margin-left: 20px
											// }
											// background:url('kermit.jpg')
											// center center no-repeat;
//											$("."+notiId+"adminData")
//													.css(
//															{
//																"background" : backUrl
//																		+ "center center no-repeat"
//															});
////											$(".adminData")
////											.css(
////													{
////														"background" : backUrl
////																+ "center center no-repeat"
////													});
//											// $(".rs-content").css({"backgroundRepeat":"no-repeat"});
//											$("."+notiId+"adminData").css({
//												"background-size" : "cover"
//											});
											
											
//											
//											$(".cbp_tmtimeline").attr({ scrollTop: $(".cbp_tmtimeline").attr("scrollHeight") });
//											$(".cbp_tmtimeline").animate({ scrollTop: $(".cbp_tmtimeline").attr("scrollHeight") }, 3000);
											// $(".rs-content").css({"text-align":"left"});
											// $(".rs-content").css({"margin-left":"20px"});
											// $(".rs-content").css({"backgroundPosition":"left
											// -20px"});
								
										}	
										
                                    
                                    console.log("===========  resultHtml : " + resultHtml);
										
										$(".cbp_tmtimeline").html(resultHtml);
									
									}
								});
				
		
				
			});
	

}



// user Info Click function!!
$('.div_login').click(function(e) {

	// console.log('유저정보 확인!');
	testLog();

	var dialogTitle = "로그인 정보";
	var dialogContent = currentLoginID;
	WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
		text : '확인'
	} ]);
});

function testLog() {
	console.log('in test log 테스트 로그 안');
}

// token Info Click function!!
$('.div_tokenInfo').click(function(e) {

	var dialogTitle = "토큰 정보";
	var dialogContent = currentTokenID;
	WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
		text : '확인'
	} ]);
});

// group info click
$('.div_groupInfo').click(function(e) {

	var groupTopicResult = groupInfoSelect();
	console.log('펑션 호출 결과결과');
	console.log(groupTopicResult);
	if (groupTopicResult) {
		var dialogTitle = "현재 수신 메세지 그룹 정보";
		var dialogContent = groupTopicResult;
		WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
			text : '확인'
		} ]);
	} else {
		var dialogTitle = "현재 수신 메세지 그룹 정보";
		var dialogContent = '메세지 그룹 조회 실패!';
		WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
			text : '확인'
		} ]);

	}

});

// 그룹 정보 쿼리
function groupInfoSelect() {
	var topicName="";
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});

	db.transaction(function(tx) {
		console.log(currentLoginID);
		console.log("위의 아이디로 토픽 조회");
		tx.executeSql("select * from topic where userid=? ",
				[ currentLoginID ], function(tx, res) {
					var selectLength = res.rows.length;
					console.log('토픽 셀렉트 결과 start!!');
					console.log(res.rows.item(0));
					console.log(selectLength);
				
					if (selectLength >= 1) {
						console.log('success!!');
						for(var i=0 ; i<selectLength;i++){
							topicName=topicName+ res.rows.item(i).topic+",";
							console.log('토픽 셀렉트 결과 시작');
							console.log(topicName);
							console.log('토픽 셀렉트 결과 끝');
						}
						topicName=topicName.slice(0, -1);
					} else {
						console.log("!!fail!!");

					}
				});
	});

	return topicName;
}

// 그룹 정보 동기화
$('.div_groupSync').click(function(e) {

	var dialogTitle = "메세지 그룹 동기화";
	var dialogContent = "메세지 그룹을 동기화 하시겠습니까?";
	WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
		text : '확인',
		handler : syncGroupInfoInsert
	}, {
		text : '취소'
	} ]);

});

function syncGroupInfoInsert() {

	var groupSub = "/push/group";

	var msg = '{"userID":"' + currentLoginID + '"}';
	console.log("그룹정보 동기화 할 유저 아이디 json");
	console.log(msg);
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db.transaction(function(tx) {

		tx.executeSql("INSERT INTO job (type,topic,content) VALUES (?,?,?)", [
				0, groupSub, msg ], function(tx, res) {
			console.log("그룹 정보 동기화인서트 결과 처리시작");
			var insertResult = res.rowsAffected;
			console.log(insertResult);
			console.log("그룹 정보 동기화인서트 결과 처리끝");
			if (insertResult == 1) {
				console.log("그룹 정보 인서트 성공!!");
				var dialogTitle = "메세지 그룹 동기화 성공! ";
				var dialogContent = '동기화에 성공 하였습니다.';
				WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
					text : '확인'
				} ]);

			} else {
				console.log("메세지 그룹 동기화 실패");
				var dialogTitle = "메세지 그룹 동기화 실패";
				var dialogContent = '동기화에 실패 하였습니다.';
				WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
					text : '확인'
				} ]);

			}
		});

	});

}

// delete all message Click Function!!
$('.div_deleteAllMessage').click(function(e) {

	var dialogTitle = "모든 메세지 삭제";
	var dialogContent = "모든 메세지를 삭제 하시겠습니까??";

	WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
		text : '확인',
		handler : deleteAllMessage
	}, {
		text : '취소'
	} ]);
});

// delete all message Click delete query!!
function deleteAllMessage() {
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db
			.transaction(function(tx) {
				tx
						.executeSql(
								"delete from message where type=0 or type=1 or type=2 ",
								[],
								function(tx, res) {
									var deleteResult = res.rowsAffected;
									console
											.log('삭제 쿼리 결과 !!!!!!!!!!!!!!!!!!!!!!!');
									console.log(deleteResult);
									if (deleteResult !== 0) {
										$('.ul_pushList li').each(function() { // loops
											// through
											// all
											// li
											console.log("li 삭제 !!!!!!!");
											$(this).remove(); // Remove li one
											// by one
										});
										$('.ul_pushList')
												.html(
														'<br/><br/><br/><p style="text-align:center;color:#1172b6;">수신된 메세지가 없습니다.</p>');
										console.log("메세지 삭제 !!!!!!!");
										oScroll.refresh();
									} else {
										console.log("!!삭제 실패!!");

									}
								});
			});
}

// log out function!!!
$('.div_logout').click(function(e) {
	var dialogTitle = "로그아웃";
	var dialogContent = "로그아웃 하시 겠습니까??";

	WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
		text : '확인',
		handler : logOutQuery
	}, {
		text : '취소'
	} ]);

});

function badgeSendSuccess(){
	console.log('cordova iphone exeu success');
}
function badgeSendFailure(){
	console.log('cordova iphone exeu fail');
}

// logOutQuery !!!!
function logOutQuery() {
	console.log("로그아웃 update 처리시작");
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	// currentLoginID
	db.transaction(function(tx) {
		tx.executeSql("UPDATE user SET currentuser = 0 WHERE userid = ?",
				[ currentLoginID ], function(tx, res) {

					var updateResult = res.rowsAffected;
					console.log(updateResult);
					console.log("로그아웃  update 처리끝");
					if (updateResult == 1) {
						console.log("로그아웃  update 성공");

						$('#page-container').load("pages/pushLogin.html",
								function() {
									console.log("login 이동 !!");

								});

					} else {
						console.log("로그아웃  update 실패!!");
						console.log("로그아웃  update실패");

					}
				});
	});
}
