
//for iphone badge
$(function(){
        if(iphonebadgeCheck&&devicePlatform==="iOS"){
        console.log('업데이트시 아이폰 코도바 플러그인 호출 ');
        cordova.exec(badgeSendSuccess, badgeSendFailure, "BadgeSendPlugin", "badgeSend", []);
        }
        
        iphonebadgeCheck=false;
});

//image click
$("img").click(function(){
	var imageSource=$(this).attr('src');
	 var imageWidth =$(this).css("width");
	 var imageHeight =$(this).css("height");
	 console.log('이미지 src');
	 console.log(imageSource);
	 console.log(imageWidth);
	 console.log(imageHeight);
	 console.log('이미지 src end');
     
     window.open(imageSource,'_system','height='+imageHeight+', width='+imageWidth+'');

});

// Check for browser support of event handling capability
	if (window.addEventListener){
		 document.getElementById( 'bottom_div' ).scrollIntoView(true);
	}
		
	else if (window.attachEvent){
		 document.getElementById( 'bottom_div' ).scrollIntoView(true);
	}
	
	else{
		 document.getElementById( 'bottom_div' ).scrollIntoView(true);
	}
		

function deleteButtonOffFuncton() {

	console.log('편집 아이콘 클릭');
	$('.deleteOffButton').hide();
	$('.deleteOnButton').show();
	$('[name=check_delete]').each(function() {
		$('[name=check_delete]').show();
	});

}

function deleteSelectOnFuncton() {
	console.log('삭제 아이콘 클릭');
	if ($('[name=check_delete]:checked').length == 0) {
		console.log('check length is 0!!!');
		$('.deleteOffButton').show();
		$('.deleteOnButton').hide();
		$('[name=check_delete]').each(function() {
			$('[name=check_delete]').hide();
		});

	} else {
		var notiID = "";
		console.log('check length is not 0');
		$('[name=check_delete]:checked').each(function() {
			notiID = notiID.concat($(this).val() + ",");
		});

		notiID = notiID.slice(0, -1);
		console.log(notiID);
		if (confirm("선택된 메세지를 삭제 하시겠습니까??") == true) { // 확인
			console.log("선택된 notiID 아이디");
			console.log(notiID);
			console.log("선택된 notiID 아이디");
			multiDelete(notiID);
			// deleteOneMessage(notiID);
			// oScroll.refresh();
		} else { // 취소
			$('.deleteOffButton').show();
			$('.deleteOnButton').hide();
			$('[name=check_delete]').each(function() {
				$('[name=check_delete]').attr('checked', false);
				$('[name=check_delete]').hide();

			});
			return;
		}
	}



}

//설문조사 응답 코드
function researchRes(notiId,pollId,surveyNoid){
	var researchResult="";
	var researchInt="";
	console.log("설문조사 아이디");
	console.log(pollId);
	var radio=$("li#"+notiId+" input[type=radio]");
	
	for(var i=0;i<radio.length;i++){
			if(radio[i].checked){
				console.log('체크된 라디오 버튼 위치 ');
				console.log(i);
				researchInt=i;
				console.log('체크된 라디오 버튼 벨류');
				console.log(radio[i].value);
				researchResult=radio[i].value;
			}

	}
		
	if(researchResult==""||researchResult==null){
		
		alert('설문 항목을 선택해 주세요');
		return false;
	}
	
	var dialogContent="";
	console.log('설문조사 응압 무기명일까요?');
	console.log(surveyNoid);
	if(surveyNoid=="true"||surveyNoid==true){
		dialogContent = researchResult+"으로 설문(무기명)에 응하 시겠습니까 ?";
	}else{
		dialogContent = researchResult+"으로 설문에 응하 시겠습니까 ?";
	}

	var r = confirm(dialogContent);
	if (r == true) {
		researchInsert(researchResult,notiId,pollId,researchInt,surveyNoid);
	} else {
	   
	}
	
}
	//설문 조사 인설트 
function researchInsert(researchResult,notiId,pollId,researchInt,surveyNoid){
	console.log('설문조사 인서트 시작');
		var db = window.sqlitePlugin.openDatabase({
			name : "PushDB"
		});
		db.transaction(function(tx) {
			var loginid=currentLoginID;
			if(surveyNoid=="true"||surveyNoid==true){
				loginid="";
				console.log('무기명일경우 로그인아이디 ');
				console.log(loginid);
			}else{
				console.log('무기명이 아닐경우');
				console.log(loginid);
			}
		//insert
			tx.executeSql("INSERT INTO job (type,topic,content) VALUES (?,?,?)", [0,"/push/poll","{\"id\":"+pollId+",\"answerid\":"+researchInt+",\"userid\":\""+loginid+"\"}"],
					function(tx, res) {
						console.log("설문조사 인서트 결과 처리시작");
						var insertResult=res.rowsAffected;
						console.log(insertResult);
						if(insertResult==1){
							alert('설문에 응답하였습니다.');
						}else{
							console.log("인서트 실패!!");
							alert('설문에 응답에 실패하였습니다.');
						}
					});
		//delete
			tx
			.executeSql(
					"delete from message where id="+notiId,
					[],
					function(tx, res) {
						var deleteResult = res.rowsAffected;
						console.log(deleteResult);
						if (deleteResult !== 0) {
								$('#' + notiId).remove();
								console.log('in for end');
							var divTagLength = $('.cbp_tmtimeline li').length;
							if (divTagLength == 0) {
								$('.cbp_tmtimeline')
										.html(
												'<br/><p style="text-align:center;color:#1172b6;">수신된 메세지가 없습니다.</p>');
							}

							console.log("설문조사 삭제 !!!!!!!");
						} else {
							console.log("설문조사 삭제 실패");

						}
					});
		
		

			});

		
		
		
	}
	
	
	
	



function multiDelete(notiid) {
	console.log('삭제');
	console.log(notiid);
	var db = window.sqlitePlugin.openDatabase({
		name : "PushDB"
	});
	db
			.transaction(function(tx) {
				tx
						.executeSql(
								"delete from message where id in(" + notiid
										+ ")",
								[],
								function(tx, res) {
									var deleteResult = res.rowsAffected;
									console.log(deleteResult);
									if (deleteResult !== 0) {
										var notiArr = [];
										notiArr = notiid.split(',');

										for (var i = 0; i < notiArr.length; i++) {
											console.log(notiArr[i]);
											$('#' + notiArr[i]).remove();
										}

										$('.deleteOffButton').show();
										$('.deleteOnButton').hide();
										$('[name=check_delete]').each(
												function() {
													$('[name=check_delete]')
															.hide();
												});
										
										var divTagLength = $('.cbp_tmtimeline li').length;
										if (divTagLength == 0) {
											$('.cbp_tmtimeline')
													.html(
															'<br/><p style="text-align:center;color:#1172b6;">수신된 메세지가 없습니다.</p>');
										}

										console.log("메세지 다중 삭제 !!!!!!!");
									} else {
										console.log("!!삭제 실패 삭제 실패 !!");

									}
								});
			});

}


//icon backButton!! click!
function backButton() {
	$("#page-container").load(pagesHistory.pop(), function() {
      
		document.addEventListener("deviceready", cateListSelect, false);
		
	});
}

