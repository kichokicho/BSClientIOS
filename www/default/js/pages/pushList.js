//for iphone
var iphonebadgeCheck=false;
// devicePlatform
var devicePlatform=device.platform;
//jindo Scroll
var oScroll = new jindo.m.Scroll("scrollWrapper", {
	bUseHScroll : false,
	bUseVScroll : true,
	bUseMomentum : true,
	nDeceleration : 0.0005,
	nHeight : 0
});


// jindo Layout
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


//편집 버튼 클릭
function deleteButtonCateOffFuncton() {
	console.log('편집 아이콘 클릭');
	//편집 hide
	$('.deleteOffButtonCate').hide();
	//삭제 show
	$('.deleteOnButtonCate').show();
    //onclick disable
	$('.acategory').removeAttr("onclick");
	//checkbox show
	$('[name=check_catedelete]').each(function() {
		$('[name=check_catedelete]').show();
	});

}
//삭제 버튼 클릭
function deleteSelectCateOnFuncton() {
	console.log('삭제 아이콘 클릭');
	//onclick enable
	$('.acategory').attr("onclick", "javascript:pushLishClick(this.id);");
	//input check length check
	if ($('[name=check_catedelete]:checked').length == 0) {
		console.log('체크 된게 없을시');
		//편집 show
		$('.deleteOffButtonCate').show();
		//삭제 hide
		$('.deleteOnButtonCate').hide();
		//checkbox hide
		$('[name=check_catedelete]').each(function() {
			$('[name=check_catedelete]').hide();
		});

	} else {
		var cateID = "";
		console.log('체크된게 있을경우');
		$('[name=check_catedelete]:checked').each(function() {
			console.log($(this).val());
			cateID = cateID.concat("\""+$(this).val() + "\",");
		});
		cateID = cateID.slice(0, -1);
		console.log(cateID);
		if (confirm("선택된 메세지를 삭제 하시겠습니까??") == true) { // 확인
			console.log("선택된 카테고리 아이디");
			console.log(cateID);
			cateDelete(cateID);

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


}

function cateDelete(cateID) {
	console.log('카테고리 리스트  선택 삭제 시작!');
	console.log(cateID);

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
									console.log(deleteResult);
									if (deleteResult !== 0) {
										var cateArr = [];
										cateArr = cateID.split(',');
										for (var i = 0; i < cateArr.length; i++) {
											var cateRemove=cateArr[i].replace(/"/g, "");
											 $('li').each(function(){
												   if($(this).data('val')==cateRemove){
													   $(this).remove();
												  }
												});
									
										}
										$('.deleteOffButtonCate').show();
										$('.deleteOnButtonCate').hide();
										$('[name=check_catedelete]').each(
										function() {$('[name=check_catedelete]').hide();});
						
										var divTagLength = $('.ul_pushList li').length;
										console.log('카테고리 리스트  길이 체크');
										console.log(divTagLength);
										if (divTagLength == 0) {
											console.log('카테고리 리스트 길이 가 없음');
											$('.ul_pushList')
											.html(
													'<br/><br/><br/><p style="text-align:center;color:#1172b6;">수신된 메세지가 없습니다.</p>');
										}
										oScroll.refresh();
										console.log("카테고리 리스트 선택삭제 성공");
									} else {
										console.log("카테고리 리스트 선택삭제 실패");

									}
								});
			});

}




// 카테고리 리스트 클릭
function pushLishClick(catecory) {
    listCateGory=catecory;
	var startDateTime = new Date();
    var startDateTimeM= startDateTime.getTime();
	var endDateTime = new Date();
    var endDateTimeM=endDateTime.getTime();
	var resultTime=endDateTimeM-startDateTimeM;

	if (pagesHistory.length == 0) {
		
		pagesHistory.push("pages/pushList.html");
	}

	$("#page-container").load("pages/pushDetail.html", function() {
		//디데일 리스트 만들기
		console.log('디데일 이동 시작');
		selectDetail(catecory);
		detailJsAdd();
		console.log('디테일 이동 끜');
	});


	
}


function detailJsAdd() {
	var element = document.createElement("script");
	element.src = "js/pages/pushDetail.js";
	document.body.appendChild(element);
}


// pushList Click !! select Detail query page !!!
function selectDetail(category) {

	var iphonebadgeCheck=false;
	if($('.categoryTitle').length){	
	}else{
		$('<span class="categoryTitle">'+category+'</span>').insertAfter(".bsMobileMessageDetailI");
	}
	
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db
			.transaction(function(tx) {
				tx
						.executeSql(
								"select * from message where category = ? and ( type= 0 or type= 1 or type= 2 or type= 3);",
								[ category ],
								function(tx, res) {
									var selectLength = res.rows.length;
									var resultHtml="";
									if (selectLength == 0) {

									} else {

										for (var i = 0; i < selectLength; i++) {
											var contentResult = res.rows
													.item(i).content;
											var notiId=res.rows.item(i).id;
											var receivedate=res.rows.item(i).receivedate;
											var dateyyy=receivedate.substring(0,10);
											var datetime=receivedate.substring(11,receivedate.length);
											contentResult = JSON
													.parse(contentResult);
											var decContentText = contentResult.notification.htmlContent;
											var contentTitle=contentResult.notification.contentTitle;
											var userPhone=contentResult.notification.userPhone;
											var pollId;
											if(userPhone==null||userPhone==""||userPhone==undefined){
												userPhone="번호없음";
											}

											if(contentResult.notification.pollID){
												pollId=contentResult.notification.pollID;
											}

											decContentText = b64_to_utf8(decContentText);

											console.log("테그 디코딩 결과");
											console.log(decContentText);
											console.log("테그 디코딩 결과");
											var read=res.rows.item(i).read;
											
											if(read==1){
												console.log('읽지않은 메세지가 있을때');
												tx.executeSql("UPDATE  message SET read =0 WHERE id = ?", [notiId],
														function(tx, res) {
															console.log("읽지않은 메세지 업데이트");
															var updateResult=res.rowsAffected;
															if(updateResult==1){
																console.log("읽지않은 메세지 결과 1");											
																//for iphone
																iphonebadgeCheck=true;

									
															}else{
																console.log("읽지않은 메세지 업데이트 실패!!");
																
															}
														});
												
											}
											if(category=="설문조사"){
											var surveyNoid=contentResult.notification.noid;
											resultHtml=resultHtml.concat('<li id="'+notiId+'"><time class="cbp_tmtime"><span><input type="checkbox" value="'+notiId+'" name="check_delete" style="display:none;" class="detailcheckbox"></span><span style="color:#1172b6;">'+dateyyy+'</span> <span>'+datetime+'</span></time><div class="cbp_tmlabel"> <h3>'+contentTitle+'</h3><br/><div class="'+notiId+'adminData">'+decContentText+'</div><a href="#" onclick="researchRes('+notiId+','+pollId+','+surveyNoid+')" class="cd-read-more">응답</a></div></li>');
									
											}else{
											resultHtml=resultHtml.concat('<li id="'+notiId+'"><time class="cbp_tmtime"><span><input type="checkbox" value="'+notiId+'" name="check_delete" style="display:none;" class="detailcheckbox"></span><span style="color:#1172b6;">'+dateyyy+'</span> <span>'+datetime+'</span></time><div class="cbp_tmlabel"> <h3>'+contentTitle+'</h3><br/><div class="'+notiId+'adminData">'+decContentText+'</div><br/><a href="tel:'+userPhone+'" class="cd-read-more phonehover">'+userPhone+'</a></div></li>');
												
											
											}
										}	

										$(".cbp_tmtimeline").html(resultHtml);
									
									}
								});
				
		
				
			});
	

}



// user Info Click function!!
$('.div_login').click(function(e) {

	var dialogTitle = "로그인 정보";
	var dialogContent = currentLoginID;
	WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
		text : '확인'
	} ]);
});



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

						if (selectLength >= 1) {
							for(var i=0 ; i<selectLength;i++){
								topicName=topicName+ res.rows.item(i).topic+",";

							}
							topicName=topicName.slice(0, -1);
							console.log('토픽 셀렉트 결과');
							console.log(topicName);
						} else {
							console.log("토픽 셀렉트 결과 실패");

						}
					});
		});

	if (topicName!=null&&topicName!="") {
		var dialogTitle = "현재 수신 메세지 그룹 정보";
		var dialogContent = topicName;
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
	console.log("그룹정보 동기화 할 유저 아이디 ");
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
								"delete from message where type=0 or type=1 or type=2 or type=3 ",
								[],
								function(tx, res) {
									var deleteResult = res.rowsAffected;
									console.log(deleteResult);
									if (deleteResult !== 0) {
										$('.ul_pushList li').each(function() { // loops
											$(this).remove(); // Remove li one
										});
										$('.ul_pushList')
												.html(
														'<br/><br/><br/><p style="text-align:center;color:#1172b6;">수신된 메세지가 없습니다.</p>');
										console.log("전체 메세지 삭제");
										oScroll.refresh();
									} else {
										console.log("전체 메세지 삭제 실패");

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
	console.log('아이폰 배지 콜백 성공');
}
function badgeSendFailure(){
	console.log('아이폰 배치 콜백 실패');
}

// logOutQuery !!!!
function logOutQuery() {
	console.log("로그아웃 업데이트처리시작");
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
