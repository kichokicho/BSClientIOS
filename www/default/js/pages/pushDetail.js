
/* JavaScript content from js/pages/pushDetail.js in folder common */
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