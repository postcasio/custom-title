# custom-title package

Set your own template for Atom's title bar. Uses [underscore.js templates](http://underscorejs.org/#template).

The following variables are available:

- `projectPath`
- `projectName`
- `filePath`
- `relativeFilePath`
- `fileName`
- `gitHead`
- `gitAdded`
- `gitDeleted`
- `devMode`
- `safeMode` (always false, since the package will not be loaded in safe mode!)

Plus the `atom` global, as usual.

Project and git variables always refer to the first path in your project.

## Examples

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
