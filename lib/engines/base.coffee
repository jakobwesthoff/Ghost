util = require "util"
fs = require "fs"

# Template engine base class used by every implemented template engine to
# provide certain base functionallity
class TemplateEngine
    # Construct a new template engine taking the path to a template as argument
    #
    # The given Template folder will be copied to a temporary location where it
    # can be accessed for further processing. The location will be stored
    # inside the 'tmpDirectory' property
    constructor: ( @path ) ->
        @tmpDirectory = util.tempdir()
        fs.copyTree @path, @tmpDirectory

    # Store the given data to a temporary file inside the cloded template
    # directory and return its filepath
    storeProcessed: ( @processed ) ->
        tmpfile = util.tempfile @tmpDirectory, '.html'
        fs.write tmpfile, @processed, "w"
        return tmpfile

    # Remove all the temporary stuff created for processing
    cleanup: ->
        fs.removeTree @tmpDirectory

# Export all public symbols
module.exports = TemplateEngine
