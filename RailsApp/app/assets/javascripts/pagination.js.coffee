# jQuery ->
# 	if $('#infinite-scrolling').size() > 0
# 		$(window).on 'scroll', ->
# 			more_objects_url = $('.pagination .next_page a').attr('href')
# 			if more_objects_url  && $(window).scrollTop() > $(document).height() - $(window).height() - 60
# 				return if more_objects_url.match(/^#$/)
# 				$('.pagination').html('<div style="text-align: center"><img src="/assets/ajax-loader.gif" alt="Cargando..." title="Cargando..."/></div>')
# 				$.getScript more_objects_url
# 			else
# 				# $('#infinite-scrolling').remove()
# 			return
# 		return