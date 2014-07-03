
/* JavaScript content from js/pages/pushLogin.js in folder common */
//로그인 펑션
function loginFunction() {
	var formCheck = loginFormCheck();

	if (formCheck) {
		var loginId = $('#loginId').val();
		var loginPass = $('#loginPass').val();
		busy.show();
		//ajax call server auth 
		$
		.ajax({
			url : 'http://192.168.2.1:8080/v1/auth',
			type : 'POST',
			contentType : "application/json",
			dataType : 'json',
			async : false,
			data : '{"userID":"' + loginId + '","password":"' + loginPass
              '","password":"' + loginPass
					+ '"}',
			success : function(data) {
				console.log('로그인 호출 성공');
				var loginResult = data.result.success;
				// success
				console.log('로그인 호출 결과값 시작!');
				console.log(data.result);
				console.log(data.result.success);
				console.log('로그인 호출 결과값 끝!');
				if (loginResult) {
					console.log('로그인 리절트 이프!');
					var tokenID = data.result.data.tokenID;
					currentTokenID=tokenID;
					console.log('토큰 아이디');
					console.log(tokenID);
					console.log('토큰 아이디');
					//sql lite 현재 유저가 있는지 검색
					console.log('현재 유저가 있는지 검색!! start');
					document.addEventListener("deviceready", nowLoginInfoSelect(loginId,loginPass,tokenID), false);
						
				} else {
					busy.hide();
					console.log('로그인 리절트 엘스!');
					
					
				}

			},
			error : function(data, textStatus, request) {
				console.log('fail start...........');
				console.log(data);
				console.log(textStatus);
				busy.hide();
				var dialogTitle="로그인";
				var dialogContent="로그인에 실패하였습니다.!";
				WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
				    text : '확인'
				  }
				  ]);
				
				
				console.log('fail end.............');
			}
		});
		
	}
}



//nowLoginInfoSelect

function nowLoginInfoSelect(loginId,loginPass,tokenID){
	console.log('sql lite에  유저정보가 있는지 검색  시작!!');
	console.log(loginId);
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db.transaction(function(tx) {
	tx.executeSql("select * from user where userid=?;", [loginId],
				function(tx, res) {
					console.log("로그인 아이디로 검색 start");
					var userSelectResult=res.rows.length;
					
					if(userSelectResult==1){
						console.log("해당아이디의 유저가 존재함");
						currentLoginID=loginId;
						//this user update currentUsercode !
						document.addEventListener("deviceready", currentUserUpdate(loginId), false);
//						$('#page-container').load("pages/pushList.html", function() {
//							console.log("푸시 리스트로 이동 !!메세지 리스트 셀렉트 시작!!");
//							
//						});
					}else{
						console.log("sql lite에 해당아이디의 유저가 no!!");
						document.addEventListener("deviceready", loginInfoInsert(loginId,loginPass,tokenID), false);
					}
					
//					console.log(userSelectResult);
//					console.log(JSON.stringify(res.rows.item(0)));
//					var resultUserid =res.rows.item(0).userid;
//					currentTokenID=res.rows.item(0).tokenid;
//					console.log("로그인 아이디로 검색 end");
				
				});

		});
	console.log('유저정보가 있는지 검색  ');
}


//커런트 유저 업데이트
function currentUserUpdate(loginId){
	console.log("커런트유저  update 처리시작");
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db.transaction(function(tx) {
	tx.executeSql("UPDATE user SET currentuser = 1 WHERE userid = ?", [loginId],
				function(tx, res) {
					console.log("커런트유저  update 처리시작");
					var updateResult=res.rowsAffected;
					console.log(updateResult);
					console.log("커런트유저  update 처리끝");
					if(updateResult==1){
						console.log("커런트유저  update 성공");
						busy.hide();
						$('#page-container').load("pages/pushList.html", function() {
							console.log("푸시 리스트로 이동 !!메세지 리스트 셀렉트 시작!!");
							document.addEventListener("deviceready", loginFuncionSelect, false);
						});
						
					}else{
						console.log("커런트유저  update 실패!!");
						console.log("커런트유저  update실패");
						
					}
				});

		});
}


//first Login Insert
function loginInfoInsert(loginId,loginPass,tokenID){
	console.log('로그인 정보 입력  시작!!');
	console.log(loginId);
	console.log(loginPass);
	console.log(tokenID);
	console.log('로그인 쿼리 시작!!');
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db.transaction(function(tx) {
	tx.executeSql("INSERT INTO user (userid,password,tokenid,currentuser) VALUES (?,?,?,?)", [loginId,loginPass,tokenID,1],
				function(tx, res) {
					console.log("인서트 결과 처리시작");
					var insertResult=res.rowsAffected;
					console.log(insertResult);
					console.log("인서트 결과 처리끝");
					if(insertResult==1){
						currentLoginID=loginId;
						currentTokenID=tokenID;
						console.log("인서트 결과 1!!");
						busy.hide();
						$('#page-container').load("pages/pushList.html", function() {
							console.log("푸시 리스트로 이동 !!메세지 리스트 셀렉트 시작!!");
							document.addEventListener("deviceready", loginFuncionSelect, false);
						});
						
					}else{
						console.log("인서트 실패!!");
						console.log("로그인 실패");
						
					}
				});

		});
	
	
}

//login functionSelectList

function loginFuncionSelect() {
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


//form check

function loginFormCheck() {

	var loginId = $('#loginId').val();
	var loginPass = $('#loginPass').val();

	if (loginId === null || loginId === "") {
		alert('아이디 를 입력해주세요');
		return false;
	} else if (loginPass === null || loginPass === "") {
		alert('비밀번호 를 입력해주세요');
		return false;
	}

	return true;
}

