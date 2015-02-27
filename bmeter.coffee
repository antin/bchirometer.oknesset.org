$ ->
	show_page=(p)->
		#???console.log 'Page to',p
		$('section').hide().filter(p).show()
		$('body').toggleClass 'splash',p is '#splash'
		window.scrollTo 0,0
	page_turner=(p)->return ->return show_page p
	page.base '/'
	page 'about',page_turner '#about'
	page 'qna',page_turner '#qna'
	page 'categories',page_turner '#categories'
	page 'agendas',(context)->
		# (Apparently, window.location is updated after this handler, so can't get URL hash from it. Page.js provides details in a "context" parameter.)
		cid=context.hash # Gives just the URL fragment, without "#" prefix.
		# Disable chosen category??? Meh, bad UX, probably.
		$ "[href=\"agendas##{cid}\"]"
		.prop 'disabled',true
		# Identify category from URL and fetch details; eg "agendas#[92,113,101]" means category includes agendas 92, 113, and 101.
		c=_.find categories,(c)->cid is JSON.stringify c.id
		c or= # Failsafe?
			'category':'כל האג\'נדות' # Title.
			'id':[] # Empty array means all agendas.
			'fonticon':'' # (No) icon.
		showall=not c.id.length
		# Set heading to chosen category.
		$ '#agendas h2'
		.empty()
		.text c.category
		.prepend $ "<i class=\"fa #{c.fonticon or ''}\"></i>"
		# Filter agendas list for selected category.
		$ '#agendas-list li'
		.each ->
			a=$ @ # Wrap DOM node with jQuery? Yeah, easier to work with.
			aid=a.attr 'id' # Each li has an id attribute in the form "agenda-113".
			.slice 'agenda-'.length
			a.toggle showall or parseInt(aid,10) in c.id
		show_page '#agendas'
	page 'results',page_turner '#results'
	page '',->show_page '#splash' # Root page (or index.html?), take us "home".
	page.start() # Begin listening to location changes.

	# Populate categories and agendas from constant JS?!
	$('#categories-list').html _.template $('#category-template').html(),{categories}
	$('#agendas-list').html _.template $('#agenda-template').html(),{agendas}
	$('#parties-list').html _.template $('#party-template').html(),{parties}

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
