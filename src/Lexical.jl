module Lexical

# REFERENCES
#
#    [1] ISO 8879:1986 Information processing -- Text and office systems -- Standard Generalized Markup Language (SGML)
#        https://www.iso.org/standard/16387.html
#    [2] Extensible Markup Language (XML) 1.0 (Fifth Edition),
#        https://www.w3.org/TR/xml/

# ----------------------------------------
# EXPORTED INTERFACE
# ----------------------------------------

export tokens
export location_of

# ----------------------------------------
# TOKEN TYPES
# ----------------------------------------

@enum TokenType begin
    # These token names and values come from the SGML specification. See [1].
    #
    mdo     # markup delimiter open ... <!
    mdc     # markup delimiter close ... > ... this one will never show up ... we'll use tagc instead.
    dso     # declaration subset open ... [
    dsc     # declaration subset close ... ]
    msc     # marked section close ... ]]
    com     # comment ... --
    rni     # reserved name indicator ... #
    lit     # literal ... "
    lita    # alternative literal ... '
    grpo    # group open ... (
    grpc    # group close ... )
    and     # and connector ... & ... this is not actually used in XML, and will never show up because ero will be found instead.
    or      # or connector ... |
    seq     # sequence connector ... ,
    opt     # optional occurrence indicator ... ?
    rep     # zero-or-more occurrence indicator ... *
    plus    # one-or-more occurrence indicator ... +
    minus   # exclusion/omission flag ... - ... this is not actually used in XML.
    cro     # character reference open ... &#
    ero     # entity reference open ... &
    pero    # parameter entity reference open ... %
    refc    # reference close ... ;
    pio     # processing instruction open ... <?
    pic     # processing instruction close ... > ... this is actually ?> in XML ... but see below in TwoCharacterTokens.
    stago   # start tag open ... <
    etago   # end tag open ... </
    tagc    # tag close ... >
    net     # null end tag ... /
    vi      # value indicator ... =

    # The rest of these don't represent traditional SGML tokens.
    #
    ws      # XML white-space ... see [2], § 2.3
    eoi     # end of input
    text    # anything else, except ...

    illegal # this is not actually used in XML.
end

# ----------------------------------------
# TYPE DECLARATIONS
# ----------------------------------------

struct Location
   identification ::String
   line_number    ::Int64
end

mutable struct State
   io          ::Union{IOStream, IOBuffer}
   line_number ::Int64
   last_match  ::Union{Nothing, Array{Char, 1}}
   length_of   ::Int64
end


struct Token
   token_type ::TokenType
   value      ::String
   location   ::Location
end

# ----------------------------------------
# CONSTANTS
# ----------------------------------------

# In XML, pic should be ?>, as compared to > in SGML. However, we can't actually tokenize ?> as a single token, because
# then element declarations that happen to be optional (e.g., <!ELEMENT a (b)?>) would be tokenized incorrectly (unless
# there happens to be space between the two characters) and then we'd have to bend over backwards in the element
# declaration parser. What kills me is that according to [1], § 1.1, "It shall be easy to write programs which process
# XML documents.". If they'd left pic as >, like in SGML, it would've been easier to parse: you'd end a PI by looking
# for tagc. Otherwise as it stands you'd need a context-sensitive lexical layer to distinguish the token ?> from the two
# tokens ? and >. And in the same section, "XML shall be compatible with SGML." ... well it isn't: PIs in SGML by
# default end with a tagc (i.e., >), not with the sequence ?>. Anyway, that's my tirade for today.
#
const TwoCharacterTokens = Dict([ '<', '!' ] => mdo,
                                [ ']', ']' ] => msc,
                                [ '-', '-' ] => com,
                                [ '&', '#' ] => cro,
                                [ '<', '?' ] => pio,
                                [ '<', '/' ] => etago)
const OneCharacterTokens = Dict('>'  => mdc, # Again, this will never show up ... we'll always emit tagc instead.
                                '['  => dso,
                                ']'  => dsc,
                                # '#'  => rni, ... Including this as a token in XML makes parsing reserved names a pain.
                                '\"' => lit,
                                '\'' => lita,
                                '('  => grpo,
                                ')'  => grpc,
                                '&'  => and, # Again, this will never show up ... we'll always emit ero instead.
                                '|'  => or,
                                ','  => seq,
                                '?'  => opt,
                                '*'  => rep,
                                '+'  => plus,
                                # '-'  => minus, ... This is not a token in XML, and including it causes too many headaches.
                                '&'  => ero,
                                '%'  => pero,
                                ';'  => refc,
                                '<'  => stago,
                                '>'  => tagc,
                                '/'  => net,
                                '='  => vi)
const IllegalCharacters = Set(vcat('\u00':'\u08', '\u0e':'\u1f', '\ud800':'\udfff', [ '\u0b', '\u0c', '\ufffe', '\uffff' ]))
const TokenStarts       = Set([ '\"', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '/', ';', '<', '=', '>', '?', '[', ']', '|' ])
const WhiteSpaces       = Set([ '\u20', '\u09', '\u0a', '\u0d' ])

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

State(io) = State(io, -1, nothing, -1)
Token(token_type::TokenType, token_value::String, state::State) = Token(token_type, token_value, location_of(state))
location_of(token::Token) = token.location


function consume_last_match(state::State)
    skip(state.io, state.length_of)

    return state.last_match
end


function consume_until(state::State, end_markers::Set{Char})
    consumed   = Array{Char, 1}()
    start      = position(state.io)
    bytes_read = 0

    while !eof(state.io)
        c = read(state.io, Char)
        if c ∈ end_markers
            if c == '-'
                # Be careful here: '-' is a token in SGML (minus), but in XML we need to look ahead to see if it is
                # followed by another '-'. If so, then "--" is a token (com), but only if it, in turn, is followed by
                # '>' (mdc/tagc). Otherwise it is part of the current token (text).
                #
                # Ultimately, it might be easier to handle this in an other layer, by consuming a sequence of tokens and
                # grouping then. But this will do for now.
                #
                if eof(state.io)
                    bytes_read = position(state.io) - start
                    push!(consumed, c)
                    break
                end

                current_position = position(state.io)

                if read(state.io, Char) == '-' && !eof(state.io) && read(state.io, Char) ∈ [ '-', '>' ]
                    break

                else
                    # Keep going.
                    #
                    seek(state.io, current_position)
                end

            else
                break
            end
        end
        bytes_read = position(state.io) - start
        push!(consumed, c)
    end

    return ( bytes_read, consumed )
end


function consume_while(state::State, set::Set{Char})
    consumed   = Array{Char, 1}()
    start      = position(state.io)
    bytes_read = 0

    while !eof(state.io)
        c = read(state.io, Char)
        if c ∉ set
            break
        end
        bytes_read = position(state.io) - start
        push!(consumed, c)
    end

    return ( bytes_read, consumed )
end


function location_of(state::State)
    name_of(io::IOStream) = io.name
    name_of(io) = "a buffer"

    return Location(name_of(state.io), -1)
end


function is_delimiter_one(state::State)::Bool
    start = mark(state.io)
    token_value = read(state.io, Char)
    current = position(state.io)
    reset(state.io)

    if haskey(OneCharacterTokens, token_value)
        state.last_match = [ token_value ]
        state.length_of  = current - start

        return true

    else
        return false
    end
end


function is_delimiter_two(state::State)::Bool
    start = mark(state.io)
    first = read(state.io, Char)

    if eof(state.io)
        reset(state.io)

        return false

    else
        second = read(state.io, Char)
        current = position(state.io)
        reset(state.io)

        if haskey(TwoCharacterTokens, [ first, second ])
            state.last_match = [ first, second ]
            state.length_of  = current - start

            return true

        else
            return false
        end
    end
end


function is_text(state::State)::Bool
    start = mark(state.io)
    ( bytes_read, token_value ) = consume_until(state, ∪(TokenStarts, WhiteSpaces, IllegalCharacters))
    reset(state.io)

    if length(token_value) > 0
        state.last_match = token_value
        state.length_of  = bytes_read

        return true

    else
        return false
    end
end


function is_white_space(state::State)::Bool
    start = mark(state.io)
    ( bytes_read, token_value ) = consume_while(state, WhiteSpaces)
    reset(state.io)

    if length(token_value) > 0
        state.last_match = token_value
        state.length_of  = bytes_read

        return true

    else
        return false
    end
end


function tokens(state::State)
    function next(state::State)::Union{Token, Nothing}
        if is_delimiter_two(state)
            token_value = consume_last_match(state)

            return Token(TwoCharacterTokens[token_value], String(token_value), state)

        elseif is_delimiter_one(state)
            token_value = consume_last_match(state)

            return Token(OneCharacterTokens[token_value[1]], String(token_value), state)

        elseif is_text(state)
            return Token(text, String(consume_last_match(state)), state)

        elseif is_white_space(state)
            return Token(ws, String(consume_last_match(state)), state)

        else
            return Token(illegal, string(read(state.io, Char)), state)
        end
    end

    function tokenized(channel::Channel)
        while !eof(state.io)
            put!(channel, next(state))
        end
    end

    return Channel(tokenized; ctype = Token, csize = 1)
end

end
