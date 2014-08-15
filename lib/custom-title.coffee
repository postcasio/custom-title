_updateTitle = null

module.exports =
	configDefaults:
		template: '<%= fileName %><% if (projectPath) { %> - <%= projectPath %><% } %>'

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
				if projectPath = atom.project.getPath()
					projectName = path.basename(projectPath)
				else
					projectName = null

				if item = @getModel().getActivePaneItem()
					fileName = item.getTitle?() ? 'untitled'
					filePath = item.getPath?()
				else
					fileName = null
					filePath = null

				try
					title = template {projectPath, fileName, filePath, projectName}

					@setTitle(title, filePath)
				catch e
					_updateTitle.call(this)
			else
				_updateTitle.call(this)

		atom.workspaceView.updateTitle()


	deactivate: ->
		atom.workspaceView.updateTitle = _updateTitle

	serialize: ->
