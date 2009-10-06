<script type="text/javascript" src="js/jq.js"></script>
<script type="text/javascript"> 
	$(document).ready(function(){
	
		$(".graph_toggle").toggle(function() {
			$('.wswgraphs').css('display','block');	
			$(this).html('Hide graphs...');
		},function() {
			$('.wswgraphs').css('display','none')
			$(this).html('Show graphs...');
		});

});


</script>
<div class="wswserver">

	<div class="hostname">
		##HOST_NAME##
	</div>

	<div class="basicinfo">

		<div class="title">
				<span class="mapname">map</span> 
				<span class="clientinfo">players</span>
		</div>

	<br style="clear:both;" />

		<div class="info">
			<span class="mapname">##MAP_NAME##</span> 
			<span class="clientinfo">##CLIENTS##/##MAX_PLAYERS##</span>
		</div>

	</div>

	<br style="clear:both;" />

	<div class="levelshot">
		<img width="180px" height="135px" src="##LEVEL_SHOT##"></img>
	</div>


	<div class="gnt">

		<div class="gamename">
			<div class="title">
				...playing
			</div>
			##GAME_TYPE##
		</div>

		<div class="topscores">
			<!-- TODO teamscores / topscores switch -->
			<div class="title">
				top 3 scores
			</div>
			##TOP_SCORES##
		</div>

	</div>

	<br style="clear:both;" />

	<div class="clients">
		<div class="title">
			clients
		</div>
		##CLIENT_LIST##
	</div>

	<br style="clear:both;" />

	<div class="graph_toggle">
		Show graphs...
	</div>

</div>

<br style="clear:both;" />

<div class="wswgraphs wswserver ">
		##GRAPHS##
</div>

