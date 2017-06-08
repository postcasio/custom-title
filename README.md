# custom-window-title package

This was forked from the [custom-title](https://github.com/postcasio/custom-title) package as the owner has stopped updating for quite some time while there are stale bugs.

Set your own template for Atom's title bar. Uses [underscore.js templates](http://underscorejs.org/#template).

The following variables are available:

- `projectPath` (Path to root project directory)
- `projectName` (Directory name of project or title from [Project Manager](https://atom.io/packages/project-manager))
- `filePath` (Path to current file)
- `fileInProject` (Boolean)
- `relativeFilePath` (Path to file relative to current project)
- `fileName` (File name)
- `gitHead`
- `gitAdded`
- `gitDeleted`
- `devMode`
- `safeMode` (always false, since the package will not be loaded in safe mode!)

In addition the following variables from `os` is available:

- `username`
- `hostname`

Plus the `atom` global, as usual.

Project and git variables always refer to the first path in your project.

## Examples

These examples can all be tested by going to the package settings and setting the template field.

### Default

The default template matches the regular Atom titlebar:

```
<%= fileName %><% if (projectPath) { %> - <%= projectPath %><% } %>
```

### With Atom version

```
<%= fileName %><% if (projectPath) { %> - <%= projectPath %><% } %> - Atom <%= atom.getVersion() %>
```

### With the current git branch

```
<%= fileName %><% if (projectPath) { %> - <%= projectPath %><% if (gitHead) { %> [<%= gitHead %>]<% } %><% } %>
```

### With hostname and username

```
<%= username %> @ <%= hostname %> : <%= fileName %><% if (projectPath) { %> - <%= projectPath %><% if (gitHead) { %> [<%= gitHead %>]<% } %><% } %>
```

### Project name display

```
<% if (projectName) { %> <%= projectName %> <% } %><% if (gitHead) { %> [ ⛕<%= gitHead %> ] <% } %> <%= fileName %><% if (filePath) { %> - <%= filePath %> <% } %>
```
