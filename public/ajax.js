// Simpler solution: on radio-button click, submit form if name isn't empty
$('submit-button').addClass('hidden');
$('tag-form').input('tag').forEach(function(item) {
	item.onClick(
		function() {
			$('tag-form').send({
				onSuccess: function() {
						   location.reload() // FIXME: Overcome cross-origin security warning when changing iframe src?
						   src = Xhr.load('/next-url')
						   $('viewer').set('src', src.responseText);
						   // FIXME: get the next page with AJAX
					   }
			})
		})
});
if ($('tagger').get('value') != '') {
	$('sign-in').addClass('hidden');
}
