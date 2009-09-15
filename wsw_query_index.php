<head>
	<title> tim </title>
	<link rel="stylesheet" type="text/css" href="css/coolbeans.css">
	<link rel="stylesheet" type="text/css" href="css/wsw_server_query.css">

	<!-- jquery action team go! www.jquery.com -->
	<script type="text/javascript" src="js/jq.js"></script>
	<script type="text/javascript" src="js/jquery.history.js"></script>
	<script type="text/javascript">

	jQuery.fn.log = function (msg) {
		console.log("%s: %o", msg, this);
		return this;
	};

	function cloader(hash) {
		if(hash) {
			fillPage(hash);
		} else {
			fillPage("blog");
		}
	}

	function fillPage(stuff) {
		// store the LI for clarity/lazyness
		var theLI = $(".sitenav a[id='" + stuff + "']").parent();
		
		// remove the selected denotationz
		$('.sitenav > li').removeClass("selected");
		$('.sitenav > li > a').removeClass("selected");
		theLI.removeClass("hover");

		// show selection of new element and load content
		theLI.addClass("selected");
		$(".sitenav > li[class='selected'] > a").addClass("selected");
		//$("#content").load('content.php?id=' + stuff);
	}
		

	$(document).ready(function(){
		// thank you rebeccamurphy!
		$('a.anchor').remove().prependTo('body');

		// beginning of ajax with history trickery
		$.history.init(cloader);
		
		$('.sitenav a').hover(function() {
				if ( ! $(this).parent().hasClass(".selected") ) {
				$(this).parent().addClass("hover");
				}
			}, 
			function() {
				$(this).parent().removeClass("hover");
			});
		

		// make the tabs do their thang
		$(".sitenav a[rel='cload']").click(function() {

			// thanks to queness for clearing up hash grab and history.load
			var hash = this.href;
			hash = hash.replace(/^.*#/,'');

			cloader(hash);

			$.history.load(hash);

			return false;
		});

		$('.sitenav a').css('padding-top','-100px');

		
	});
	</script>

</head>
<body>
<div style="position:float; float: top;">
<a name="blog"></a>
<a name="stuff"></a>
<a name="about"></a>
</div>
<div id="bottle">

	<div id="header">

		<div id="timsogard">
			<img src="img/header_white.png" title="that's my name, don't wear it out"></img>
		</div>

		<br style="clear:both;" />

		<div id="menubar">
			<div id="rightmenu">
				<ul class="menus sitenav">
					<li><a rel="cload" id="blog" href="#blog" onclick="return false;">blog</a></li>
					<li><a rel="cload" id="stuff" href="#stuff" onclick="return false;">stuff</a></li>
					<li><a rel="cload" id="about" href="#about" onclick="return false;">about</a></li>
				</ul>
			</div>
		</div>

	</div>
	<br style="clear:both;" />

	<div id="content">
		<div class="wsw_server">
			<div class="hostname">SMO<span class="carrot5">O</span><span class="cattor7">TH OPERATORS NA-CA</span></div>
			<br style="clear:both;" />
			<div class="mapname">babyimwhatb4</div> <div class="clients">8/16</div>
		</div>
		<br style="clear:both;" />
	</div>


</div>

</body>
</html>
