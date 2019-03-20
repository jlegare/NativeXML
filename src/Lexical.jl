module Lexical

# REFERENCES
#
#    [1] Extensible Markup Language (XML) 1.0 (Fifth Edition),
#        https://www.w3.org/TR/xml/

# ----------------------------------------
# EXPORTED INTERFACE
# ----------------------------------------

export tokens

# ----------------------------------------
# TOKEN TYPES
# ----------------------------------------

@enum TokenType begin
    mdo     # markup delimiter open ... <!
    mdc     # markup delimiter close ... >
    dso     # declaration subset open ... [
    dsc     # declaration subset close ... ]
    msc     # marked section close ... ]]
    com     # comment ... --
    rni     # reserved name indicator ... #
    lit     # literal ... "
    lita    # alternative literal ... '
    grpo    # group open ... (
    grpc    # group close ... )
    and     # and connector ... &
    or      # or connector ... |
    seq     # sequence connector ... ,
    opt     # optional occurrence indicator ... ?
    rep     # zero-or-more occurrence indicator ... *
    plus    # one-or-more occurrence indicator ... +
    minus   # exclusion/omission flag ... - ... not actually used in XML
    cro     # character reference open ... &#
    ero     # entity reference open ... &
    pero    # parameter entity reference open ... %
    refc    # reference close ... ;
    pio     # processing instruction open ... <?
    pic     # processing instruction close ... > ... actually ?> in XML
    stago   # start tag open ... <
    etago   # end tag open ... </
    tagc    # tag close ... >
    net     # null end tag ... /
    vi      # value indicator ... =
    ws      # XML white-space ... see [1], § 2.3
    eoi     # end of input
    text    # anything else
end

# ----------------------------------------
# TYPE DECLARATIONS
# ----------------------------------------

struct Token
   token_type     ::TokenType
   value          ::String
   identification ::String
   line_number    ::Int64
end

# ----------------------------------------
# CONSTANTS
# ----------------------------------------

const TwoCharacterTokens = Dict([ '<', '!' ] => mdo,
                                [ ']', ']' ] => msc,
                                [ '-', '-' ] => com,
                                [ '&', '#' ] => cro,
                                [ '<', '?' ] => pio,
                                [ '?', '>' ] => pic,
                                [ '<', '/' ] => stago)
const OneCharacterTokens = Dict('>'  => mdc,
                                '['  => dso,
                                ']'  => dsc,
                                '#'  => rni,
                                '\"' => lit,
                                '\'' => lita,
                                '('  => grpo,
                                ')'  => grpc,
                                '&'  => and,
                                '|'  => or,
                                ','  => seq,
                                '?'  => opt,
                                '*'  => rep,
                                '+'  => plus,
                                '-'  => minus,
                                '&'  => ero,
                                '%'  => pero,
                                ';'  => refc,
                                '<'  => stago,
                                '>'  => tagc,
                                '/'  => net,
                                '='  => vi)

const TokenStarts = Set([ '\"', '#', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '/', ';', '<', '=', '>', '?', '[', ']', '|' ])

const WhiteSpaces = Set([ '\u20', '\u09', '\u0a', '\u0d' ])

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

function consume_until(io, end_markers::Set{Char})
    consumed = Array{Char, 1}()

    while !eof(io)
        c = read(io, Char)
        push!(consumed, c)
        if c ∈ end_markers
            break
        end
    end

    if eof(io)
        # This will get stripped by the caller.
        #
        push!(consumed, '\0')
    end

    return consumed
end


function consume_while(io, set::Set{Char})
    consumed = Array{Char, 1}()

    while !eof(io)
        c = read(io, Char)
        if c ∉ set
            break
        end
        push!(consumed, c)
    end

    return consumed
end


function identification_of(io::IOStream)
    return io.name
end


function identification_of(io)
    return "a buffer"
end


function next(io)::Union{Token, Nothing}
    if eof(io)
        return nothing
    end

    # Okay, that's out of the way. Try the two-character tokens first.
    #
    mark(io)
    if bytesavailable(io) >= 2 && haskey(TwoCharacterTokens, [ read(io, Char) for i ∈ 1:2 ])
        reset(io)
        value = [ read(io, Char) for i ∈ 1:2 ]

        return Token(TwoCharacterTokens[value], String(value), identification_of(io), -1)

    else
        # Now try the one-character tokens.
        #
        reset(io)
        mark(io)
        if haskey(OneCharacterTokens, read(io, Char))
            reset(io)
            value = read(io, Char)

            return Token(OneCharacterTokens[value], String([ value ]), identification_of(io), -1)

        else
            reset(io)
            mark(io)
            consumed = consume_until(io, union(TokenStarts, WhiteSpaces))

            if length(consumed) > 1
                reset(io)
                value = [ read(io, Char) for i ∈ 1:length(consumed) - 1 ]

                return Token(text, String(value), identification_of(io), -1)

            else
                reset(io)
                mark(io)
                consumed = consume_while(io, WhiteSpaces)
                reset(io)
                value = [ read(io, Char) for i ∈ 1:length(consumed) ]

                return Token(ws, String(value), identification_of(io), -1)
            end
        end
    end
end


function tokens(io)
    function tokenized(channel::Channel)
        while true
            token = next(io)
            if token == nothing
                break

            else
                put!(channel, token)
            end
        end
    end

    return Channel(tokenized; ctype=Token, csize=0)
end

end
