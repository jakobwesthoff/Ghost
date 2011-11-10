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


# Export all public symbols
exports.dirname = dirname
exports.basename = basename
