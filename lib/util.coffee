fs = require "fs"

# Generic utillity functions, which are needed at different codepositions, but
# are not provided by the phantomjs environment

# Copy over the dirname implementation from the require module. We have to
# define it there and copy it here, as we need it during the require
# implementation where we can not use require yet to get it from the util class
# ;)
dirname = require.dirname

# Extract the basename from a given filepath optionally removing the given
# extension as well
basename = ( filepath, extension = null ) ->
    position = filepath.lastIndexOf fs.separator
    if position is -1
        base = filepath
    else
        base = filepath.substring position + 1

    if extension isnt null
        if base.substring( base.length - extension.length ) is extension
            base = base.substring( 0, base.length - extension.length )

    return base

# Create a temporary directory
# By default a directory inside the '/tmp' folder will be created you may
# however provide an argument to the function provinding an alternative path
tempdir = ( directory = "/tmp" ) ->
    while true
        tempdirectory = "#{directory}/#{uuidgen()}"
        return tempdirectory if fs.makeDirectory( tempdirectory ) is true

# Create a temporary file and return its name
# By default the file will be created inside the '/tmp' directory
# The first argument given to the function however may specify an alternative
# directory.
# Furthermore a filename suffix may be requested using the second argument
tempfile = ( directory = "/tmp", suffix = "" ) ->
    while true
        tempfile = "#{directory}/#{uuidgen()}#{suffix}"
        # The create operation is not atomic :( But I don't see any way of
        # realizing this in phantomjs
        if fs.exists( tempfile ) isnt true
            fs.touch tempfile
            return tempfile

# Generate a UUID id based on the v4 specification
# Quite elegant UUID code taken from:
# http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
# and converted to coffee script
uuidgen = () ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(
        /[xy]/g,
        ( c ) ->
            r = Math.random()*16|0
            v = if ( c == 'x' ) then r else ( r & 0x3 | 0x8 )
            v.toString(16)
    )

# Export all public symbols
exports.dirname = dirname
exports.basename = basename
exports.tempdir = tempdir
exports.tempfile = tempfile
exports.uuidgen = uuidgen
