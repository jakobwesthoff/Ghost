# Simple argument parser capable of transforming given commandline arguments
# into an object consisting of boolean and string values
# Unfortunately nice nodejs libraries like optimist do not work with phantomjs,
# as certain required dependencies are non existant. Therefore we have to do
# this on our own.

# All the parsing functions are declared inside the module instead of inside
# the class. This way we can provide a clean exported Arguments object, while
# still reusing the parser code in proper isolation

# Parse all arguments taking into account a set of given option definitions
# The provided option definitions should have been mapped to their long and
# short properties to provide a faster lookup
parse = ( options ) ->
    # Clone the given arguments for working on them
    args = JSON.parse(
        JSON.stringify(
            @args
        )
    )
    
    while args.length > 0
        current = args.shift()
        if current.indexOf( "-" ) isnt 0 or current is "--"
            # We reached the end of options the following args are
            # parameters
            args.unshift current if current isnt "--"
            @_ = args
            break

        # Long or short option?
        if current.substring( 0,2 ) is "--"
            type = "long"
            identifier = current.substring(2)
        else
            type = "short"
            identifier = current.substring(1)
        
        if not options[identifier]?
            throw "Unknown option '#{identifier}' detected."

        if options[identifier].data? is true
            if args.length is 0
                throw "Data argument for option '#{identifier}' expected"
            this[options[identifier].long] = this[options[identifier].short] = args.shift()
        else
            this[options[identifier].long] = this[options[identifier].short] = true

# Map all the option definitions to an object containing each of them
# associated with their long and short option as a key
mapOptions = () ->
    mapped = {}
    for option in @options
        mapped[option.short] = option
        mapped[option.long] = option
    return mapped

# Export target to be used for argument handling
# The ArgumentParser is supposed to be created with an array of option
# defintions.
# An option defintion always needs to have a 'long' and a 'short' key. It may
# furthermore include a key name 'data' specifying if it is a value option
# indicating, that it needs to be followed by a data value. Furthermore a key
# named 'default' may be specified in order to signal the parser that the given
# option is not enforced, but optional. The value of the 'default' key is
# taken as the default value in case the option is not specified:
#   [
#     {
#       long: 'help',
#       short: 'h',
#       default: false
#     },
#     {
#       long: 'source',
#       short: 's',
#       data: true
#     },
#   ]
#
class ArgumentParser
    constructor: ( @options ) ->
        # Make a deep copy of all the arguments given to process
        @args = JSON.parse(
            JSON.stringify(
                phantom.args
            )
        )

        # Preinitialize all optional options
        for option in @options
            if option.default?
                this[option.long] = this[option.short] = option.default

        parse.call this, mapOptions.call this

# Export the ArgumentParser as public symbol
module.exports = ArgumentParser
