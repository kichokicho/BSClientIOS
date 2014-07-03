
/* JavaScript content from js/jindo/pushList.js in folder common */


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

// detailList Show
// function detailListShow() {
// pagesHistory.push("pages/pushList.html");
// $("#page-container").load("pages/pushDetail.html", function() {
//
// });
// }

// ul list click function..
$('.scl_cnt').click(function(e) {

	pagesHistory.push("pages/pushList.html");
	$("#page-container").load("pages/pushDetail.html", function() {

	});

});

$('.rs-contentrow1').click(function(e) {

	alert('내정보');

});

$('.rs-contentrow2').click(function(e) {
	// userInfo
	confirm('모든 메세지를 삭제 하시겠습니까?');

});

$('.rs-contentrow3').click(function(e) {
	confirm('로그 아웃 하시겠습니까?');

});
// // delte All message
// function deleteAllMessage() {
//	
// }
// // logOut
// function logOut() {
//	
// }
//
 // pushListDelete
 function pushListDelete() {
 confirm("메세지를 삭제 하시겠습니까?");
 }
//
// // revealsidebar end....

