$ ->
	show_page=(where)->$('body>section').hide().filter(where).show()
	page_turner=(where)->return ->return show_page where
	page.base '/'
	page 'categories',page_turner '#categories'
	page 'agendas',->
		# Filter agendas list for selected category.
		#??? ...
		show_page '#agendas'
	page 'results',page_turner '#results'
	page '*',page_turner '#splash' # Anything else, take us "home".
	page() # Begin listening to location changes.

	# Populate categories and agendas from constant JS?!
	$('#categories-list').html _.template $('#category-template').html(),{categories}
	$('#agendas-list').html _.template $('#agenda-template').html(),{agendas}

	# Button handlers.
	$ '#agendas'
	.on 'click','button',(ev)->
		b=$ ev.target # Which button?
		v=switch # Vote?
			when b.hasClass 'agree' then 1
			when b.hasClass 'indifferent' then 0
			when b.hasClass 'disagree' then -1
		console.log 'Voted',v,'on',b.parent().attr 'id'
		b.addClass 'selected'
		.siblings().removeClass 'selected'

	#???...
