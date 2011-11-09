ArgumentParser = require "argumentparser"
MustacheTemplateEngine = require "engines/mustache"
PhantomPageRenderer = require "renderer/phantompage"

fs = require "fs"

# Main application entry point
# An instance of this class is created after the application has been executed.
# After the construction the run method will be called on the instantiated
# application object.
class Ghost
    constructor: ->
        @args = null

    run: () ->
        try
            @args = new ArgumentParser([
                { short: 'h', long: 'help', default: false },
                { short: 't', long: 'template', data: true },
                { short: 'o', long: 'output', data: true, default: fs.workingDirectory }
            ])
        catch e
            @usage "Error: #{e}"

        if @args.help is true
            @usage()

        if @args._.length isnt 1
            @usage "Error: You need to provide an invoice definition as argument"

        try
            invoiceFile = fs.absolute @args._[0]
            invoice = JSON.parse(
                fs.read invoiceFile
            )
        catch e
            @usage "Error: invoice definition '#{@args._[0]}' could not be parsed: #{e}"

        if not fs.isFile @args.template
            throw "Given template '#{@args.template}' can not be read."
            
        templateEngine = new MustacheTemplateEngine(
            @args.template
        )
        console.log templateEngine

        renderer = new PhantomPageRenderer(
            templateEngine,
            invoice,
            'A4'
        )

        renderer.renderTo "#{@args.output}/#{@basename invoiceFile, ".json"}"

    # Display usage information and exit with errorcode 1
    # Optionally an error message may be provided as first argument, which will
    # be displayed between the application name and the usage information
    usage: ( msg = null ) ->
        console.log "Ghost - HTML to PDF invoice creator"
        console.log msg if msg?
        console.log ""
        console.log "Usage:"
        console.log "  ./ghost [-t/--template <templatefile>] <invoice.json>"
        console.log ""
        console.log "Options:"
        console.log "  -h/--help: Display this usage information"
        console.log "  -t/--template: Specify a template file to be used for rendering the invoice html"
        console.log "  -o/--output: Output directory to be used for the created invoice (default: cwd)"
        phantom.exit 1

    # Extract the basename from a given filepath optionally removing the given
    # extension as well
    basename: ( filepath, extension = null ) ->
        position = filepath.lastIndexOf fs.separator
        if position is -1
            base = filepath
        else
            base = filepath.substring position + 1

        if extension isnt null
            if base.substring( base.length - 1 - extension.length ) is extension
                base = base.substring( 0, -1 * extension.length )

        return base

# Export the Ghost class as the only accessible public object from this module
module.exports = Ghost
