

//로그인 펑션
function loginFunction() {
	var formCheck = loginFormCheck();
	var loginAjaxData = "";
	if (formCheck) {
		var loginId = $('#loginId').val();
		var loginPass = $('#loginPass').val();

		busy.show();
		// ajax call server auth
		var deviceID = "";
		var db = window.sqlitePlugin.openDatabase({
			name : "PushDB"
		});

		db.transaction(function(tx) {
			tx.executeSql("select id  from Device", [], function(tx, res) {
				console.log("디바이스 아이디 검색시작");
				var userSelectResult = res.rows.length;

				if (userSelectResult == 1) {
					console.log("디바이스 아이디 존재함");
					deviceID = res.rows.item(0).id;
					console.log('디바이스 아이디');
					console.log(deviceID);
					var devicePlatform = device.platform;

					// sqlite device id get
					if (devicePlatform === "iOS") {
						console.log('디바이스 플랫폼이 아이폰 입니다.');

						loginAjaxData = '{"userID":"' + loginId + '","password":"'
								+ loginPass + '","deviceID":"' + deviceID
								+ '","apnsToken":"' + deviceID + '"}';
						$.ajax({
							// https://210.108.94.90/pushAdmin/
							// url :'http://210.108.94.90/v1/auth',
//							url : 'https://bsmoffice.busanbank.co.kr/v1/auth',
							url : 'http://adflow.net:8080/v1/auth',
//							 url : 'http://192.168.42.2:8080/v1/auth',
							type : 'POST',
							timeout : 10000,
							contentType : "application/json",
							dataType : 'json',
							async : true,
							data : loginAjaxData,
							success : function(data) {
								console.log('로그인 호출 성공');
								var loginResult = data.result.success;
								if (loginResult) {
									if (!data.result.errors) {
										var tokenID = data.result.data.tokenID;
										currentTokenID = tokenID;
										console.log('현재 유저가 있는지 검색 시작');
												nowLoginInfoSelect(loginId, loginPass,tokenID)
									} else {
										busy.hide();
										var dialogTitle = "Token not found";
										var dialogContent = "로그인 정보가 일치 하지 않습니다!";
										WL.SimpleDialog.show(dialogTitle, dialogContent,
												[ {
													text : '확인'
												} ]);
									}
								} else {
									busy.hide();
									console.log('push server fail');
									var dialogTitle = "Login fail";
									var dialogContent = "로그인에 실패하였습니다.!";
									WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
										text : '확인'
									} ]);

								}

							},
							error : function(data, textStatus, request) {
								console.log('fail start...........');
								console.log(data);
								console.log(textStatus);
								busy.hide();
								var dialogTitle = "로그인 실패";
								var dialogContent = "로그인에 실패하였습니다.!";
								WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
									text : '확인'
								} ]);

							}
						});

					} else {
						loginAjaxData = '{"userID":"' + loginId + '","password":"'
								+ loginPass + '","deviceID":"' + deviceID + '"}';
						console.log('else data ');
						console.log(loginAjaxData);
						$.ajax({
							// https://210.108.94.90/pushAdmin/
							// url :'http://210.108.94.90/v1/auth',
//							url : 'https://bsmoffice.busanbank.co.kr/v1/auth',
							url : 'http://adflow.net:8080/v1/auth',
//							 url : 'http://192.168.42.2:8080/v1/auth',
							type : 'POST',
							timeout : 10000,
							contentType : "application/json",
							dataType : 'json',
							async : true,
							data : loginAjaxData,
							success : function(data) {
								console.log('로그인 호출 성공');
								var loginResult = data.result.success;
								if (loginResult) {
									if (!data.result.errors) {
										var tokenID = data.result.data.tokenID;
										currentTokenID = tokenID;
										// sql lite 현재 유저가 있는지 검색
										console.log('현재 유저가 있는지 검색 시작');

												nowLoginInfoSelect(loginId, loginPass,tokenID);
									} else {
										busy.hide();
										var dialogTitle = "Token not found";
										var dialogContent = "로그인 정보가 일치 하지 않습니다!";
										WL.SimpleDialog.show(dialogTitle, dialogContent,
												[ {
													text : '확인'
												} ]);
									}
								} else {
									busy.hide();
									console.log('push server fail');
									var dialogTitle = "로그인 실패";
									var dialogContent = "로그인에 실패하였습니다.!";
									WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
										text : '확인'
									} ]);

								}

							},
							error : function(data, textStatus, request) {
								console.log(data);
								console.log(textStatus);
								busy.hide();
								var dialogTitle = "로그인 실패";
								var dialogContent = "로그인에 실패하였습니다.!";
								WL.SimpleDialog.show(dialogTitle, dialogContent, [ {
									text : '확인'
								} ]);

							}
						});

					}
					
					
				} else {
					console.log("디바이스 아이디 존재 하지 않음 ");

				}

			});

		});



	}
}

// nowLoginInfoSelect

function nowLoginInfoSelect(loginId, loginPass, tokenID) {
	console.log('유저정보가 있는지 검색  시작');
	console.log(loginId);
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db.transaction(function(tx) {
		tx.executeSql("select * from user where userid=?;", [ loginId ],
				function(tx, res) {
					console.log("로그인 아이디로 검색 start");
					var userSelectResult = res.rows.length;

					if (userSelectResult == 1) {
						console.log("해당아이디의 유저가 존재함");
						currentLoginID = loginId;
						currentUserUpdate(loginId);

					} else {
						console.log("해당아이디의 유저가 존재하지 않음");
						loginInfoInsert(loginId, loginPass, tokenID);
					}

				});

	});
	console.log('유저정보가 있는지 검색 끝 ');
}

// 커런트 유저 업데이트
function currentUserUpdate(loginId) {
	console.log("커런트유저  업데이트 처리시작");
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db.transaction(function(tx) {
				tx.executeSql("UPDATE user SET currentuser = 1 WHERE userid = ?",[ loginId ],
								function(tx, res) {
									var updateResult = res.rowsAffected;
									if (updateResult == 1) {
										console.log("커런트유저  업데이트 성공");
										busy.hide();
										$('#page-container').load("pages/pushList.html",function() {
															console.log("카테고리 리스트로 이동");
															cateListSelect();
														});

									} else {
										console.log("커런트유저  업데이트 실패!!");
									}
								});

			});
	console.log("커런트유저  업데이트 처리 끝");
}

// first Login Insert
function loginInfoInsert(loginId, loginPass, tokenID) {
	console.log('로그인 정보 인서트 시작!!');
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db
			.transaction(function(tx) {
				tx
						.executeSql(
								"INSERT INTO user (userid,password,tokenid,currentuser) VALUES (?,?,?,?)",
								[ loginId, loginPass, tokenID, 1 ],
								function(tx, res) {
									var insertResult = res.rowsAffected;
									if (insertResult == 1) {
										currentLoginID = loginId;
										currentTokenID = tokenID;
										busy.hide();
										$('#page-container').load("pages/pushList.html",
														function() {
															console.log("카테고리 리스트로 이동 시작!");
															cateListSelect();
														});

									} else {
										console.log("인서트 실패!!");

									}
								});

			});
	console.log('로그인 정보 인서트 끝!!');
}


// form check

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
