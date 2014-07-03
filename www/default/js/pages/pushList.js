
/* JavaScript content from js/pages/pushList.js in folder common */

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

//pushList Click !!
function pushLishClick(notiID){
	console.log("pushLishClick 노티피케이션 아이디 start");
	console.log(notiID);
	console.log("pushLishClick 노티피케이션 아이디 end");
	 if(pagesHistory.length==0){
		pagesHistory.push("pages/pushList.html");
		 }
		$("#page-container").load("pages/pushDetail.html", function() {
			document.addEventListener("deviceready", selectDetail(notiID), false);
		});
	
}


//pushList Click !! select Detail query page !!!
function selectDetail(notiID) {
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db.transaction(function(tx) {
		console.log('step2');
		console.log('notiID:'+notiID);
		tx.executeSql("select * from message where type=0 and id=?",[notiID],
					function(tx, res) {
			console.log('step3');
		            	var selectLength = res.rows.length;
						var htmlTagli="";

						if(selectLength==0){
							console.log('step4');
						}else{
							console.log('step5');
						for (var i = 0; i < selectLength; i++) {
								var contentResult = res.rows.item(i).content;
								contentResult = JSON.parse(contentResult);
								console.log(contentResult.notification.ticker);
								console.log(contentResult.notification.htmlContent);
								console.log(contentResult.notification.imageName);
							    var decContentText=contentResult.notification.htmlContent;
							    var backImageName=contentResult.notification.imageName;
							    var backUrl="url('http://192.168.42.217:9090/static/"+backImageName+"')";
							    console.log("백그라운드 이미지 url");
							    console.log(backUrl);
							    decContentText=b64_to_utf8(decContentText);	
							    console.log("백그라운드 이미지 네임");
							    console.log(backImageName);
							    console.log("테그 디코딩 결과");
							    console.log(decContentText);
							    console.log("테그 디코딩 결과");
							    // $('.scl_cnt').css({ "background-color": "#ffe", "color":"yellow" });
							    //style="background-image: url('http://img.naver.net/static/www/u/2013/0731/nmms_224940510.gif');
							    $(".rs-content").html("<br/><br/><br/><div style='text-align:left;margin-left:20px;'>"+decContentText+"</div>");
							                                         
							    
//							   p { 
//								text-align: left;
//								margin-left: 20px
//							}
							    $(".rs-content").css({"background-image":backUrl});   
							    $(".rs-content").css({"backgroundRepeat":"no-repeat"});
							    $(".rs-content").css({"background-size":"cover"});
//							    $(".rs-content").css({"text-align":"left"});
//							    $(".rs-content").css({"margin-left":"20px"});
//							    $(".rs-content").css({"backgroundPosition":"left -20px"});
							    $(".rs-content").trigger('create');
										      }    
					
						console.log('메세지 리스트 셀렉트 받아오기끝');
						}
								});
			});
}


//pushListDelete click
function pushListDelete(notiID) {
	if (confirm("메세지를 삭제 하시겠습니까??") == true) { // 확인	
		console.log("pushListDelete 노티피케이션 아이디");
		console.log(notiID);
		console.log("pushListDelete 노티피케이션 아이디");
		deleteOneMessage(notiID);
		oScroll.refresh();
	} else { // 취소
		return;
	}
	
}


//pushListDelete click delete query OneMessage
function deleteOneMessage(notiID) {
	var db = window.sqlitePlugin.openDatabase({name : "PushDB"});
			db.transaction(function(tx) {
				tx.executeSql("delete from message where type=0 and id=?", [notiID],
						function(tx, res) {
					        var deleteResult=res.rowsAffected;
							console.log('삭제 쿼리 결과 !!!!!!!!!!!!!!!!!!!!!!!');
							console.log(deleteResult);
							if (deleteResult!==0) {
								$('#'+notiID).closest('li').remove();
								var liTagLength=$('.scl_o').length;
								console.log('LI 테그의 길이가 영이냐?');
								console.log(liTagLength);
								console.log('LI 테그의 길이가 영이냐?');
								if(liTagLength==0){
									$('.ul_pushList').html('<br/><br/><br/><p style="text-align:center;color:#1172b6;">수신된 메세지가 없습니다.</p>');
								}
							
								console.log("메세지 한개 삭제 !!!!!!!");
							} else {
								console.log("!!삭제 한개 삭제 실패 !!");
								
							}
					});
			});
		}





//user Info Click function!!
$('.div_login').click(function(e) {

	console.log('로그인 정보 클릭');
	var dialogTitle="로그인 정보";
	var dialogContent=currentLoginID;
	WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
	    text : '확인'
	  }
	  ]);
	});

//token Info Click function!!
$('.div_tokenInfo').click(function(e) {

	
	var dialogTitle="토큰 정보";
	var dialogContent=currentTokenID;
	WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
	    text : '확인'
	  }
	  ]);
	});


//group info click
$('.div_groupInfo').click(function(e) {

	var groupTopicResult= groupInfoSelect();
	console.log('펑션 호출 결과결과');
	console.log(groupTopicResult);
	if(groupTopicResult){
		var dialogTitle="현재 수신 메세지 그룹 정보";
		var dialogContent=groupTopicResult;
		WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
		    text : '확인'
		  }
		  ]);
	}else{
		var dialogTitle="현재 수신 메세지 그룹 정보";
		var dialogContent='메세지 그룹 조회 실패!';
		WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
		    text : '확인'
		  }
		  ]);
	
	}

	});

// 그룹 정보 쿼리 
function groupInfoSelect(){
	var topicName;
	var db = window.sqlitePlugin.openDatabase({name : "PushDB"});
	
	db.transaction(function(tx) {
		console.log(currentLoginID);
		console.log("위의 아이디로 토픽 조회");
		tx.executeSql("select * from topic where userid=? ", [currentLoginID],
				function(tx, res) {
					var selectLength = res.rows.length;
					console.log('토픽 셀렉트 결과 start!!');
					console.log(res.rows.item(0));
					console.log(selectLength);
					if (selectLength==1) {
						console.log('success!!');
						topicName=res.rows.item(0).topic;
						console.log(topicName);
					} else {
						console.log("!!fail!!");
						
					}
			});
	});
	
	return topicName;
}


//그룹 정보 동기화
$('.div_groupSync').click(function(e) {

	
	var syncResult= syncGroupInfoInsert();
	console.log('그룹정보 동기 쿼리 호출 결과결과');
	console.log(syncResult);
	if(syncResult==1){
		var dialogTitle="메세지 그룹 동기화";
		var dialogContent="동기화 하였습니다.";
		WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
		    text : '확인'
		  }
		  ]);
	}else{
		var dialogTitle="메세지 그룹 동기화";
		var dialogContent='동기화 실패!';
		WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
		    text : '확인'
		  }
		  ]);
	
	}
});


function syncGroupInfoInsert(){
	var insertResult;
	var groupSub="/push/group";

	
	var msg='{"userID":"'+currentLoginID+'"}';
	console.log("그룹정보 동기화 할 유저 아이디 json");
	console.log(msg);
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db.transaction(function(tx) {
		
	tx.executeSql("INSERT INTO job (type,topic,content) VALUES (?,?,?)", [0,groupSub,msg],
				function(tx, res) {
					console.log("그룹 정보 동기화인서트 결과 처리시작");
					insertResult=res.rowsAffected;
					console.log(insertResult);
					console.log("그룹 정보 동기화인서트 결과 처리끝");
					if(insertResult==1){
						console.log("그룹 정보 인서트 성공!!");
					}else{
						console.log("그룹 정보 인서트 실패!!");
					}
				});

		});
	return insertResult;
}




//delete all message Click Function!!
$('.div_deleteAllMessage').click(function(e) {
	
	var dialogTitle="모든 메세지 삭제";
	var dialogContent="모든 메세지를 삭제 하시겠습니까??";
	
	WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
	    text : '확인',
	    handler :  deleteAllMessage
	  },
	  {
		 text : '취소'
		  }
	  ]);
	});

//delete all message Click delete query!!
function deleteAllMessage() {
	var db = window.sqlitePlugin.openDatabase({name : "PushDB"});
			db.transaction(function(tx) {
				tx.executeSql("delete from message where type=0 ", [],
						function(tx, res) {
					        var deleteResult=res.rowsAffected;
							console.log('삭제 쿼리 결과 !!!!!!!!!!!!!!!!!!!!!!!');
							console.log(deleteResult);
							if (deleteResult!==0) {
								$('.ul_pushList li').each(function() { // loops through all li
									console.log("li 삭제 !!!!!!!");
									$(this).remove(); // Remove li one by one
								});
								$('.ul_pushList').html('<br/><br/><br/><p style="text-align:center;color:#1172b6;">수신된 메세지가 없습니다.</p>');
								console.log("메세지 삭제 !!!!!!!");
							} else {
								console.log("!!삭제 실패!!");
								
							}
					});
			});
		}
	


//log out function!!!
$('.div_logout').click(function(e) {
	var dialogTitle="로그아웃";
	var dialogContent="로그아웃 하시 겠습니까??";
	
	WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
	    text : '확인',
	    handler :  logOutQuery
	  },
	  {
		 text : '취소'
		  }
	  ]);
	
});

//logOutQuery !!!!
function logOutQuery(){
	console.log("로그아웃 update 처리시작");
	var db = window.sqlitePlugin.openDatabase({name : "PushDB"});
	//currentLoginID
	db.transaction(function(tx) {
		tx.executeSql("UPDATE user SET currentuser = 0 WHERE userid = ?", [currentLoginID],
				function(tx, res) {
					
					var updateResult=res.rowsAffected;
					console.log(updateResult);
					console.log("로그아웃  update 처리끝");
					if(updateResult==1){
						console.log("로그아웃  update 성공");
					
						$('#page-container').load("pages/pushLogin.html", function() {
							console.log("login 이동 !!");
							
						});
				
					}else{
						console.log("로그아웃  update 실패!!");
						console.log("로그아웃  update실패");
				
			}
		});
	});
}

