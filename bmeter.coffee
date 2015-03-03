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
	page 'agendas',(context)-> # (Apparently, window.location is updated after this handler, so can't get URL hash from it. Page.js provides details in a "context" parameter.)
		cid=context.hash # Gives just the URL fragment, without "#" prefix.
		# Identify category from URL and fetch details; eg "agendas#[92,113,101]" means category includes agendas 92, 113, and 101.
		c=_.find categories,(c)->cid is JSON.stringify c.id #??? No, get rid of JSON consts, use DOM instead.
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
	page 'results',->
		# Wipe old final scores.
		final={}
		###???
		$ '#parties-list>li'
		.each ->
			$ @
			.data 'scored',null
		###
		# Recalculate final scores.
		$ '#agendas-list>li'
		.each ->
			a=$ @
			# Voted?
			#console.log 'voted?',(a.attr 'id'),a.children('button.selected:not(.indifferent)').length isnt 0
			if a.children('button.selected:not(.indifferent)').length isnt 0
				dis_agree=switch
					when a.children('button.selected.agree').length isnt 0 then 1.0
					else -1.0
				console.log 'vote for',(a.attr 'id'),dis_agree
				ps=$.parseJSON a.attr 'data-parties-scores'
				console.log 'ps',ps
				for own party,score of ps
					do (party,score)->
						###???
						final[party]=[score]
						console.log 'p,s',party,score,'pushed to',final
						###
						final[party] or=[] # Initialize to empty array, once.
						final[party].push score*dis_agree # Add score.
						###???
						s=$ "#party-#{p}"
						.data 'scored'
						###
		# Sort parties by score.
		console.log final
		#???...

		# Only show best result's logo.
		$('#parties-list img').hide().first().show()
		show_page '#results'
	page '',->show_page '#splash' # Root page (or index.html?), take us "home".
	page.start() # Begin listening to location changes.

	# Populate categories and agendas from constant JS?! No, write const HTML, not JSON!
	#??? $('#categories-list').html _.template $('#category-template').html(),{categories}
	#??? $('#agendas-list').html _.template $('#agenda-template').html(),{agendas}
	#??? $('#parties-list').html _.template $('#party-template').html(),{parties}

	hide_nav_to_results=->
		# Hide nav to results (entire footer) if no votes.
		$ '#agendas footer,#categories footer'
		.toggle $('#agendas button.selected:not(.indifferent)').length isnt 0
	disable_category=->
		# Mark category to indicate whether votes done in it.
		voted=$('#agendas button.selected:visible:not(.indifferent)').length #???... find any dis/agree votes on this category/page: $ :visible and .dis/agree
		cid=location.pathname+location.hash # Identify current category.
		$('#categories a[href="'+cid+'"]').toggleClass 'has-votes',voted isnt 0

	# Voting buttons handler.
	$ '#agendas-list'
	.on 'click','button',(ev)->
		b=$ ev.target # Which button?
		v=switch # Vote?
			when b.hasClass 'agree' then 1
			when b.hasClass 'indifferent' then 0
			when b.hasClass 'disagree' then -1
		console.log 'Voted',v,'on',b.parent().attr 'id'
		b.addClass 'selected'
		.siblings().removeClass 'selected'
		# Update stuff depending on number of votes.
		disable_category()
		hide_nav_to_results()
	# Cancel votes button handler.
	$ '#cancel'
	.click (ev)->
		$ '#agendas button.selected:visible:not(.indifferent)'
		.each ->
			$ @
			.removeClass 'selected'
			.siblings '.indifferent'
			.addClass 'selected'
		# Update stuff depending on number of votes.
		disable_category()
		hide_nav_to_results()
	# Synopsis expansion clicks.
	$ '.synopsis a'
	.click (ev)->
		ev.preventDefault()
		$ @
		.parents '#agendas-list>li'
		.children 'h4,p:not(.synopsis)'
		.toggle()

	###??? # Reset all voting buttons to "indifferent". #??? No, load states from URL, so can bookmark/share voting prefs!
	$ '#agendas-list button'
	.removeClass 'selected'
	.filter '.indifferent'
	.addClass 'selected'
	###

	# Stuff that needs to be initially hidden. #??? Use new [hidden] attribute? Polyfill it?
	hide_nav_to_results()

	###??? Convert JSON to HTML...
	_.each parties_scores,(a)->
		# absolute_url":"/agenda/113/","parties
		aid='agenda-'+a.absolute_url.slice '/agenda/'.length,-1
		ps={}
		_.each a.parties,(p)->
			# {"volume":0.0,"absolute_url":"/party/6/","score":0.0,"name":"6\u05e7\u05d3\u05d9\u05de\u05d4"}
			if p.score > 0
				pid=p.absolute_url.slice '/party/'.length,-1
				#??? pid='party-'+p.absolute_url.slice '/party/'.length,-1
				ps[pid]=p.score
		$ '#'+aid
		.attr 'data-parties-scores',JSON.stringify ps
	###
