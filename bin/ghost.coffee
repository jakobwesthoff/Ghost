# Main entrypoint of the ghost html invoice generator. This file is executed
# directly using the phantomjs runner.

fs = this.require "fs"

# The default behaviour of the require function is overridden in order to allow
# the usage of commonjs modules
require = ( name ) ->
    return phantom.require name if ( name is "fs" or name is "webpage" )

    srcfile = require.locate name
    if not srcfile?
        throw "Module #{name} could not be found"

    srcpath = require.dirname srcfile
    
    src = fs.read srcfile
    
    require.paths.unshift srcpath

    modulefn = new Function( "exports", "module", src )
    module = { exports: {} }
    modulefn.call {}, module.exports, module

    require.paths.shift

    return module.exports

# Try to locate a filename/filepath within all require search paths.
require.locate = ( name ) ->
    realpath = null
    for path in require.paths
        srcfile = require.lookupFile( path, name ) ? require.lookupDirectory( path, name )
        break if srcfile?
    return srcfile

# Search for a given name inside the given path by checking all the usual
# suspects for existance as a file.
#
# The checking includes with and without .js extension
require.lookupFile = ( path, name ) ->
    if fs.isFile "#{path}/#{name}"
        return fs.absolute "#{path}/#{name}"
    if fs.isFile "#{path}/#{name}.js"
        return fs.absolute "#{path}/#{name}.js"
    return null

# Search for given name inside the given path by checking all the usual
# suspects for existance as a directory
#
# If a directory with the given name exists it will be searched for in index.js
# as well as an package.json
require.lookupDirectory = ( path, name ) ->
    directory = "#{path}/#{name}"
    
    if not fs.isDirectory directory
        return null

    if fs.isFile "#{directory}/index.js"
        return fs.absolute "#{directory}/index.js"

    if fs.isFile "#{directory}/package.json"
        package = JSON.parse(
            fs.read "#{directory}/package.json"
        )
        
        if not package.main?
            return null

        if fs.isFile "#{directory}/#{package.main}"
            return "#{directory}/#{package.main}"

    return null

# Return the dirname of a given file, by simply cutting away the last part
# before the directory seperator
require.dirname = ( filepath ) ->
    position = filepath.lastIndexOf fs.seperator
    return "." if position is -1

    filepath.substring(
        0,
        position - 1
    )

# Initialize the search path for modules using the directory of the invoked
# entry point script aka. this one.
require.paths = [
    phantom.libraryPath
]

# Remap the already existant global require to be used as a fallback and inject
# our own require routine.
phantom.require = this.require
this.require = require

console.log( require("foobar") )
