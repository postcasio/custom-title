_updateWindowTitle = null

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

		@configSub = atom.config.observe 'updated-custom-title.template', ->
			templateString = atom.config.get('updated-custom-title.template')

			if templateString
				try
					template = allowUnsafeNewFunction -> _.template templateString
				catch e
					template = null
			else
				template = null

			atom.workspace.updateWindowTitle()

		_updateWindowTitle = atom.workspace.updateWindowTitle

		atom.workspace.updateWindowTitle = ->
			if template
				item = atom.workspace.getActivePaneItem()

				fileName = item?.getTitle?() ? 'untitled'
				filePath = item?.getPath?()

				fileInProject = false

				for directory in atom.project.getDirectories()
					if directory.contains(filePath)
						projectPath = directory.getPath()
						projectName = path.basename(projectPath)
						relativeFilePath = directory.relativize(filePath)
						fileInProject = true
						break

				devMode = atom.inDevMode()
				safeMode = atom.inSafeMode?()

				repo = atom.project.getRepositories()[0]
				gitHead = repo?.getShortHead()

				gitAdded = null
				gitDeleted = null

				promises = []

				if fileInProject
					promises.push(atom.project.repositoryForDirectory(directory))

				Promise.all(promises).then (result) ->
					repo = result[0]
					if repo
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

					try
						title = template {
							projectPath, projectName, fileInProject,
							filePath, relativeFilePath, fileName,
							gitHead, gitAdded, gitDeleted
							devMode, safeMode
						}

						if filePath or projectPath
							atom.setRepresentedFilename(filePath ? projectPath)
						document.title = title
					catch e
						_updateWindowTitle.call(this)
			else
				_updateWindowTitle.call(this)

		atom.workspace.updateWindowTitle()

		@subscriptions.add atom.workspace.observeTextEditors (editor) =>
			editorSubscriptions = new CompositeDisposable
			editorSubscriptions.add editor.onDidSave -> atom.workspace.updateWindowTitle()
			editorSubscriptions.add editor.onDidDestroy -> editorSubscriptions.dispose()

			@subscriptions.add editorSubscriptions


	deactivate: ->
		@subscriptions?.dispose()
		@configSub?.dispose()
		atom.workspace.updateWindowTitle = _updateWindowTitle

	serialize: ->
