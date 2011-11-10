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

    # Render the given invoice context using the given template to the given
    # filepath as a PDF file. The provided callback will be executed once the
    # rendering is complete
    renderTo: ( filepath, callback ) ->
        processedFile = @engine.process @context
        @page.open(
            processedFile,
            ( status ) =>
                @page.render "#{filepath}.pdf"
                callback()
        )

# Export public symbols
module.exports = PhantomPageRenderer
