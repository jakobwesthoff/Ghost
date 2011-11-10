Mustache = require "node_modules/mustache"
TemplateEngine = require "engines/base"

fs = require "fs"

# Template engined using the mustache template system for rendering
# Because the given invoice definition is designed to be used with mustache
# this is a very simple wrapper around the mustache library. It simply defines
# a public interface to maybe support other template engines in the future.
class MustacheTemplateEngine extends TemplateEngine
    # Construct a new Mustache template engine reading the template file from
    # the template directory into memory
    constructor: ( path ) ->
        super path
        @templateFile = "#{@tmpDirectory}/index.mustache"
        
        if fs.isFile( @templateFile ) isnt true
            throw "Mustache template #{@templateFile} could not be read."

        @template = fs.read @templateFile

    # Process the loaded template using the given context (aka. invoice
    # definition) and return the filename and path to the file which does
    # contain the processed data
    process: ( context ) ->
        processed = Mustache.to_html @template, context
        @storeProcessed processed

# Export public symbols
module.exports = MustacheTemplateEngine
