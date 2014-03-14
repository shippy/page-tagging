// Hide form, reveal buttons
$('tag-form').addClass('hidden');
$('fancy-tagger').removeClass('hidden');
// Onclick of any buttons, select the apropriate option and submit form remotely
$$('#fancy-tagger li').onClick(
		function() {
			content = this.text().toLowerCase();
			$(content + '-radio').checked = true;
			$('tag-form').send({
				onSuccess: function() {
						   $('viewer').attr('src', '');
						   // FIXME: get the next page with AJAX
					   },
				onFailure: function() {
						   $('msg').contents("Failed");
					   }
			})
		})
// If success, load another page to iframe / reload this one?
