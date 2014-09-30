_updateTitle = null

module.exports =
	configDefaults:
		template: '<%= fileName %><% if (projectPath) { %> - <%= projectPath %><% } %>'

	config:
		template:
			type: 'string'
			default: '<%= fileName %><% if (projectPath) { %> - <%= projectPath %><% } %>'

	subscriptions: null
	configSub: null

	activate: (state) ->
		_ = require 'underscore'
		{ allowUnsafeNewFunction } = require 'loophole'
		path = require 'path'
		{CompositeDisposable} = require 'event-kit'

		@subscriptions = new CompositeDisposable

		template = null

		@configSub = atom.config.observe 'custom-title.template', ->
			templateString = atom.config.get('custom-title.template')

			if templateString
				try
					template = allowUnsafeNewFunction -> _.template templateString
				catch e
					template = null
			else
				template = null

			atom.workspaceView.updateTitle()

		_updateTitle = atom.workspaceView.updateTitle

		atom.workspaceView.updateTitle = ->
			if template
				projectPath = atom.project.getPath()
				projectName = if projectPath then path.basename(projectPath) else null

				item = @getModel().getActivePaneItem()

				fileName = item?.getTitle?() ? 'untitled'
				filePath = item?.getPath?()

				repo = atom.project.getRepo()
				gitHead = repo?.getShortHead()

				gitAdded = null
				gitDeleted = null

				if filePath and repo
					status = repo.getCachedPathStatus(filePath)
					if repo.isStatusModified(status)
						stats = repo.getDiffStats(filePath)
						gitAdded = stats.added
						gitDeleted = stats.deleted
					else if repo.isStatusNew(status)
						gitAdded = item.getBuffer?().getLineCount()
						gitDeleted = 0
					else
						gitAdded = gitDeleted = 0

				if filePath and projectPath
					relativeFilePath = path.relative(projectPath, filePath)

				try
					title = template {projectPath, projectName, filePath, relativeFilePath, fileName, gitHead, gitAdded, gitDeleted}

					@setTitle(title, filePath)
				catch e
					_updateTitle.call(this)
			else
				_updateTitle.call(this)

		atom.workspaceView.updateTitle()

		@subscriptions.add atom.workspace.observeTextEditors (editor) =>
			editorSubscriptions = new CompositeDisposable
			editorSubscriptions.add editor.onDidSave -> atom.workspaceView.updateTitle()
			editorSubscriptions.add editor.onDidDestroy -> editorSubscriptions.dispose()

			@subscriptions.add editorSubscriptions


	deactivate: ->
		@subscriptions?.dispose()
		@configSub?.off()
		atom.workspaceView.updateTitle = _updateTitle

	serialize: ->
