WebPage = require "webpage"
fs = require "fs"

# Renderer using the phantom WebPage object to render the given template data
# to a pdf page
class PhantomPageRenderer
    # Construct a new renderer taking a template engine instance, the invoice
    # context to render as well as the pagesize for the rendering as arguments
    constructor: ( @engine, @context, @pagesize, @border = 0 ) ->
        @page = WebPage.create()
        @page.paperSize =
            format: @pagesize
            orientation: 'portrait'
            border: @border
        @page.libraryPath = fs.absolute(
            @engine.filepath.substring(
                0,
                @engine.filepath.lastIndexOf(
                    fs.separator
                )
            )
        )
        console.log( @page.libraryPath )

    # Render the given invoice context using the given template to the given
    # filepath as a PDF file
    renderTo: ( filepath ) ->
        @page.content = @engine.process @context
        @page.render "#{filepath}.pdf",

# Export public symbols
module.exports = PhantomPageRenderer
