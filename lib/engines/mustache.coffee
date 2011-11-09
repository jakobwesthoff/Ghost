Mustache = require "node_modules/mustache"
fs = require "fs"

# Template engined using the mustache template system for rendering
# Because the given invoice definition is designed to be used with mustache
# this is a very simple wrapper around the mustache library. It simply defines
# a public interface to maybe support other template engines in the future.
class MustacheTemplateEngine
    # Construct a new Mustache template engine reading the given template file
    # into memory
    constructor: ( @filepath ) ->
        @template = fs.read @filepath

    # Process the loaded template using the given context (aka. invoice
    # definition) and return the result
    process: ( context ) ->
        Mustache.to_html @template, context
