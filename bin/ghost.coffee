# Main entrypoint of the ghost html invoice generator. This file is executed
# directly using the phantomjs runner.

# Load the fs module for further usage within the application
fs = this.require "fs"

# The default behaviour of the require function is overridden in order to allow
# the usage of commonjs modules
require = ( name ) ->
    return phantom.require name if ( name is "fs" or name is "webpage" )

    srcfile = require.locate name
    if not srcfile?
        throw "Module #{name} could not be found"

    if not require.cache[srcfile]?
        srcpath = require.dirname srcfile
        
        src = fs.read srcfile
        
        require.paths.unshift srcpath

        modulefn = new Function( "exports", "module", src )
        module = { exports: {} }
        modulefn.call {}, module.exports, module

        require.paths.shift

        require.cache[srcfile] = module.exports

    return require.cache[srcfile]

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
    filename = fs.absolute "#{path}/#{name}"

    if fs.isFile filename
        return filename
    if fs.isFile "#{filename}.js"
        return "#{filename}.js"
    return null

# Search for given name inside the given path by checking all the usual
# suspects for existance as a directory
#
# If a directory with the given name exists it will be searched for in index.js
# as well as an package.json
require.lookupDirectory = ( path, name ) ->
    directory = fs.absolute "#{path}/#{name}"
    
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

        lookedupMain = require.lookupFile( directory, package.main )
        return lookedupMain if lookedupMain?

    return null

# Return the dirname of a given file, by simply cutting away the last part
# before the directory seperator
require.dirname = ( filepath ) ->
    position = filepath.lastIndexOf fs.separator
    return "." if position is -1

    filepath.substring(
        0,
        position
    )

# The cache is used to store modules which have been included once. Therefore
# they are only evaluated one time eventhough they might be required multiple
# times. This is done in compliance with the CommonJS module specification
require.cache = {}

# Initialize the search path for modules using the directory of the invoked
# entry point script aka. this one.
require.paths = [
    phantom.libraryPath
]

# Remap the already existant global require to be used as a fallback and inject
# our own require routine.
phantom.require = this.require
this.require = require

# Add the top-level projects dir as well as the node_modules directory in there
# to the require paths
#
# This allows easy inclusion of the application modules as well as third party
# modules installed through npm
# 
# Remember we are adding to the head of the array therefore the searchorder is
# reversed
require.paths.unshift "#{phantom.libraryPath}/../node_modules"
require.paths.unshift "#{phantom.libraryPath}/.."

# Require and execute the ghost application entry point from the lib directory
try
    Ghost = require( "lib/ghost" )
    app = new Ghost()
    app.run()
catch e
    if e.message?
        console.log "Fatal error: #{e.message)}"
    else
        console.log "Fatal error: #{JSON.stringify(e)}"
    phantom.exit 255
