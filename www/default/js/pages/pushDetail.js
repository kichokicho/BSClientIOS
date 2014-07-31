

$("img").click(function(){
	var imageSource=$(this).attr('src');
	 var imageWidth =$(this).css("width");
	 var imageHeight =$(this).css("height");
	 console.log('이미지 src');
	 console.log(imageSource);
	 console.log(imageWidth);
	 console.log(imageHeight);
	 console.log('이미지 src end');
     
     window.open(imageSource,'myWin','height='+imageHeight+', width='+imageWidth+'');

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

	console.log('헤더 클릭 편집 버튼 클릭 이벤트 ');
	$('.deleteOffButton').hide();
	$('.deleteOnButton').show();

	// .fa-envelope{
	// margin-left: 32px;
	//
	// }
	// $('.fa-envelope')
	$('[name=check_delete]').each(function() {
		$('[name=check_delete]').show();
	});

}

function deleteSelectOnFuncton() {
	console.log('delete on  버튼 클릭 이벤트 ');

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
			console.log($(this).val());
			notiID = notiID.concat($(this).val() + ",");
		});
		console.log('before slice category');
		console.log(notiID);
		console.log('slice category');
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

	// $('.deleteOnButton').hide();
	// $('.deleteOffButton').show();

}

//설문조사 응답 코드
//$( "#log" ).html( $( "input:checked" ).val() + " is checked!" );
//nameResearch
function researchRes(notiId,pollId,surveyNoid){
	//var mailTp 		= $(':radio[name="mailTp"]:checked').val();
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
	
//	.each( function() {
//		console.log('라디오 버튼 선택된값 시작');
//		console.log(this.value);
//		console.log('라디오 버튼 선택된값 끝');
//		researchResult=this.value;
//	});
	
	if(researchResult==""||researchResult==null){
		
		alert('설문 항목을 선택해 주세요');
		return false;
	}
	
//	var dialogTitle = "설문조사 응답";
	var dialogContent="";
	console.log('설문조사 응압 무기명일까요?');
	console.log(surveyNoid);
	if(surveyNoid=="true"||surveyNoid==true){
		console.log('이프');
		dialogContent = researchResult+"으로 설문(무기명)에 응하 시겠습니까 ?";
	}else{
		console.log('엘스');
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
	console.log('설문조사 인설트 시작');
	console.log(researchResult);
	console.log(notiId);
	console.log(pollId);
	console.log(currentLoginID);
	console.log(researchInt);
	console.log('설문조사 인서트 데이터 내용 끝');
		var db = window.sqlitePlugin.openDatabase({
			name : "PushDB"
		});
		console.log('db 트랙젼션 시작 전');
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
						console.log("인서트 결과 처리시작");
						var insertResult=res.rowsAffected;
						console.log(insertResult);
						console.log("인서트 결과 처리끝");
						if(insertResult==1){
							console.log("인서트 결과 1!!");
							alert('설문에 응답하였습니다.');
						}else{
							console.log("인서트 실패!!");
							console.log("로그인 실패");
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
						console
								.log('삭제 쿼리 결과 !!!!!!!!!!!!!!!!!!!!!!!');
						console.log(deleteResult);
						if (deleteResult !== 0) {
								$('#' + notiId).remove();
								console.log('in for end');
							var divTagLength = $('.cbp_tmtimeline li').length;
							console.log('divTagLength 테그의 길이가 영이냐?');
							console.log(divTagLength);
							console.log('divTagLength 테그의 길이가 영이냐?');
							if (divTagLength == 0) {
								console.log('영입니다.');
								$('.cbp_tmtimeline')
										.html(
												'<br/><p style="text-align:center;color:#1172b6;">수신된 메세지가 없습니다.</p>');
							}

							console.log("메세지  삭제 !!!!!!!");
						} else {
							console.log("!!삭제 실패 삭제 실패 !!");

						}
					});
		
		

			});

		
		
		
	}
	
	
	
	



function multiDelete(notiid) {
	console.log('멀티 삭제 notiid 아이디 start');
	console.log(notiid);
	console.log(' 삭제 notiid 아이디 end');
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
									console
											.log('삭제 쿼리 결과 !!!!!!!!!!!!!!!!!!!!!!!');
									console.log(deleteResult);
									if (deleteResult !== 0) {
										var notiArr = [];
										notiArr = notiid.split(',');

										for (var i = 0; i < notiArr.length; i++) {
											console.log('in for start');
											console.log(notiArr[i]);
											$('#' + notiArr[i]).remove();
											console.log('in for end');
										}

										$('.deleteOffButton').show();
										$('.deleteOnButton').hide();
										$('[name=check_delete]').each(
												function() {
													$('[name=check_delete]')
															.hide();
												});
										
										var divTagLength = $('.cbp_tmtimeline li').length;
										console.log('cbp_tmtimeline 테그의 길이가 영이냐?');
										console.log(divTagLength);
										console.log('cbp_tmtimeline 테그의 길이가 영이냐?');
										if (divTagLength == 0) {
											console.log('영입니다');
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


//function selectDetail(category) {
//	
//	
//	var db = window.sqlitePlugin.openDatabase({
//		name : "PushDB"
//	});
//	db
//			.transaction(function(tx) {
//				console.log('step2');
//				console.log('category:' + category);
//				tx
//						.executeSql(
//								"select * from message where category = ?;",
//								[ category ],
//								function(tx, res) {
//									console.log('step3');
//									var selectLength = res.rows.length;
//									var htmlResult = "";
//									
//									if (selectLength == 0) {
//										console.log('step4');
//									} else {
//										console.log('step5');
//										for (var i = 0; i < selectLength; i++) {
//											var contentResult = res.rows
//													.item(i).content;
//											contentResult = JSON
//													.parse(contentResult);
//											console
//													.log(contentResult.notification.ticker);
//											console
//													.log(contentResult.notification.htmlContent);
//											console
//													.log(contentResult.notification.imageName);
//											var decContentText = contentResult.notification.htmlContent;
//											var contentTitle=contentResult.notification.contentTitle;
//											var backImageName = contentResult.notification.imageName;
//											var backUrl = "url('http://192.168.1.4:9090/static/"
//													+ backImageName + "')";
//											console.log("백그라운드 이미지 url");
//											console.log(backUrl);
//											decContentText = b64_to_utf8(decContentText);
//											console.log("백그라운드 이미지 네임");
//											console.log(backImageName);
//											console.log("테그 디코딩 결과");
//											console.log(decContentText);
//											console.log("테그 디코딩 결과");
//											// $('.scl_cnt').css({
//											// "background-color": "#ffe",
//											// "color":"yellow" });
//											// style="background-image:
//											// url('http://img.naver.net/static/www/u/2013/0731/nmms_224940510.gif');
//											// $(".rs-content").html(
//											// "<br/><br/><br/><div
//											// style='text-align:left;margin-left:20px;'>"
//											// + decContentText
//											// + "</div>");
//												
//											
//											//<a href="#0" class="cd-read-more">Delete</a>
//											$("#cd-timeline")
//													.append('<div class="cd-timeline-block"><div class="cd-timeline-img cd-picture"></div><div class="cd-timeline-content"><h2>'+contentTitle+'</h2><div class="adminData">'+decContentText+'</div><span class="cd-date">Jan 14</span></div> </div> ');
//											
//											// p {
//											// text-align: left;
//											// margin-left: 20px
//											// }
//											// background:url('kermit.jpg')
//											// center center no-repeat;
//											$(".adminData")
//													.css(
//															{
//																"background" : backUrl
//																		+ "center center no-repeat"
//															});
//											$(".adminData")
//											.css(
//													{
//														"background" : backUrl
//																+ "center center no-repeat"
//													});
//											// $(".rs-content").css({"backgroundRepeat":"no-repeat"});
//											$(".adminData").css({
//												"background-size" : "cover"
//											});
//											// $(".rs-content").css({"text-align":"left"});
//											// $(".rs-content").css({"margin-left":"20px"});
//											// $(".rs-content").css({"backgroundPosition":"left
//											// -20px"});
//										
//										}	
//										console.log('메세지 리스트 셀렉트 받아오기끝');
//									}
//								});
//			});
//}




//icon backButton!! click!
function backButton() {
	$("#page-container").load(pagesHistory.pop(), function() {
      
		document.addEventListener("deviceready", pageBack, false);
		
	});
}

//pageBack Query!!
function pageBack() {
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

$(function(){
  console.log("=======   iphonebadgeCheck :" + iphonebadgeCheck);
  
  console.log("=======   devicePlatform : "+ devicePlatform);
  if(devicePlatform==="iOS"){
  console.log('업데이트시 아이폰 코도바 플러그인 호출 ');
  cordova.exec(badgeSendSuccess, badgeSendFailure, "BadgeSendPlugin", "badgeSend", []);
  
  //											iphonebadgeCheck=false;
  }
  
  iphonebadgeCheck=false;
  });