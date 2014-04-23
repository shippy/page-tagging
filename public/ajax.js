// Simpler solution: on radio-button click, submit form if name isn't empty
$('submit-button').addClass('hidden');
$('tag-form').input('tag').forEach(function(item) {
	item.onClick(
		function() {
			$('tag-form').submit()
		})
});
if ($('tagger').get('value')) {
	$('sign-in').addClass('hidden');
	$('tags').addClass('full-width');
} else {
	var value = prompt("Please enter your name.");
	$('tagger').set('value', value);
	// FIXME: find a less obtrusive way of doing this
}
