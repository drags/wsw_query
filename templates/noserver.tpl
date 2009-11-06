<script type="text/javascript" src="js/jq.js"></script>
<script type="text/javascript"> 
	$(document).ready(function(){
	
		$("#hostlist").change(function() {
			location.search = "?server=" + $(this).attr("value");
		});

});


</script>

<div class="wswserver">

	<div class="hostname">
		Select a host...
	</div>

	<div class="basicinfo">
		<div class="hostpick">
			<select id="hostlist" name="hostlist">
				<option selected="selected" value="">Select existing host</option>
				<option value="so.nuclearfallout.net:44400">so.nuclearfallout.net:44400</option>
				<option value="66.150.214.231:44400">66.150.214.231:44400</option>
			</select> 
			or <input name="newhost" value="add new host">
		</div>
	</div>

