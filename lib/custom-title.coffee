_updateTitle = null

module.exports =
	configDefaults:
		template: '<%= fileName %><% if (projectPath) { %> - <%= projectPath %><% } %>'

	saveSub: null

	activate: (state) ->
		_ = require 'underscore'
		{ allowUnsafeNewFunction } = require 'loophole'
		path = require 'path'

		template = null

		atom.config.observe 'custom-title.template', ->
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

		@saveSub = atom.workspaceView.on 'core:save', -> atom.workspaceView.updateTitle()


	deactivate: ->
		@saveSub?.off()
		atom.workspaceView.updateTitle = _updateTitle

	serialize: ->
