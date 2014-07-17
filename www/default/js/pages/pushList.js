var oScroll = new jindo.m.Scroll("scrollWrapper", {
	bUseHScroll : false,
	bUseVScroll : true,
	bUseMomentum : true,
	nDeceleration : 0.0005,
	nHeight : 0
});

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

// pushList Click !!
function pushLishClick(catecory) {
	console.log(" 카테고리 start");
	console.log(catecory);
	console.log(" 카테고리 end");

	
	if (pagesHistory.length == 0) {
		
		pagesHistory.push("pages/pushList.html");
	}
	
	$("#page-container").load("pages/pushDetail.html", function() {
		console.log('푸쉬리스트 클릭 1');
		selectDetail(catecory);
		console.log('푸쉬리스트 클릭 2');
	});

}





// pushList Click !! select Detail query page !!!
function selectDetail(category) {
	console.log('푸쉬리스트 클릭 3');
	
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
									var htmlResult = "";
									
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
											
											
											
											contentResult = JSON
													.parse(contentResult);
											console
													.log(contentResult.notification.ticker);
											console
													.log(contentResult.notification.htmlContent);
											console
													.log(contentResult.notification.imageName);
											var decContentText = contentResult.notification.htmlContent;
											var contentTitle=contentResult.notification.contentTitle;
											var backImageName = contentResult.notification.imageName;
											var pollId;
											if(contentResult.notification.pollID){
												pollId=contentResult.notification.pollID;
											}
											
											console.log('노티피 케이션 리절트 ');
											console.log(contentResult.notification);
											console.log('메세지에서 나온 설문조사 아이디');
									
											//https://210.108.94.90/v1/auth
	//										var backUrl = "url('http://192.168.42.217:9090/static/"
											var backUrl = "url('http://210.108.94.90/static/"
													+ backImageName + "')";
											console.log("백그라운드 이미지 url");
											console.log(backUrl);
											decContentText = b64_to_utf8(decContentText);
											console.log("백그라운드 이미지 네임");
											console.log(backImageName);
											console.log("테그 디코딩 결과");
											console.log(decContentText);
											console.log("테그 디코딩 결과");
											//UPDATE user SET currentuser = 1 WHERE userid = ?", [loginId]
											//읽은 메세지 업데이트 처리 
											tx.executeSql("UPDATE  message SET read =1 WHERE id = ?", [notiId],
													function(tx, res) {
														console.log("update 결과 처리시작");
														var updateResult=res.rowsAffected;
														console.log(updateResult);
														console.log("update 결과 처리끝");
														if(updateResult==1){
															console.log("update 결과 1111");
														}else{
															console.log("update 실패!!");
															console.log("update 실패");
															
														}
													});
											
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
								
											if(category=="설문조사"){
											$("#cd-timeline")
											       .append('<div id="'+notiId+'" class="cd-timeline-block"><div class="cd-timeline-img cd-picture"></div><div class="cd-timeline-content"><h2>'+contentTitle+'</h2><div class="'+notiId+'adminData">'+decContentText+'</div><input class="cd-read-more" style="display: none;width:40px; height:40px;" type="checkbox" value="'+notiId+'" name="check_delete"></input><a href="#" onclick="researchRes('+notiId+','+pollId+')" class="cd-read-more">응답</a><span class="cd-date">'+receivedate+'</span></div> </div> ');	
												
										
											}else{
												
											$("#cd-timeline")
												.append('<div id="'+notiId+'" class="cd-timeline-block"><div class="cd-timeline-img cd-picture"></div><div class="cd-timeline-content"><h2>'+contentTitle+'</h2><div class="'+notiId+'adminData">'+decContentText+'</div><input class="cd-read-more" style="display: none;" type="checkbox" value="'+notiId+'" name="check_delete"></input><span class="cd-date">'+receivedate+'</span></div> </div> ');
										
											}
											//<a href="#0" class="cd-read-more">Delete</a>
											
											
											// p {
											// text-align: left;
											// margin-left: 20px
											// }
											// background:url('kermit.jpg')
											// center center no-repeat;
											$("."+notiId+"adminData")
													.css(
															{
																"background" : backUrl
																		+ "center center no-repeat"
															});
//											$(".adminData")
//											.css(
//													{
//														"background" : backUrl
//																+ "center center no-repeat"
//													});
											// $(".rs-content").css({"backgroundRepeat":"no-repeat"});
											$("."+notiId+"adminData").css({
												"background-size" : "cover"
											});
											// $(".rs-content").css({"text-align":"left"});
											// $(".rs-content").css({"margin-left":"20px"});
											// $(".rs-content").css({"backgroundPosition":"left
											// -20px"});
										
										}	
										console.log('메세지 리스트 셀렉트 받아오기끝');
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
