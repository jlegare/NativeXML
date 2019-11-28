module Events

# REFERENCES
#
#    [1] Extensible Markup Language (XML) 1.0 (Fifth Edition),
#        https://www.w3.org/TR/xml/

# ----------------------------------------
# EXPORTED INTERFACE
# ----------------------------------------

export events

# ----------------------------------------
# IMPORTED NAMESPACES
# ----------------------------------------

include("./Lexical.jl")

import .Lexical

# ----------------------------------------
# TYPE DECLARATIONS
# ----------------------------------------

struct CDATAMarkedSectionStart
    identification ::String
    line_number    ::Int64
end


struct CDATAMarkedSectionEnd
    is_recovery    ::Bool
    identification ::String
    line_number    ::Int64
end


struct CharacterReference
    value          ::String # It's someone else's job to verify that the value is a legitimate character.
    identification ::String
    line_number    ::Int64
end


struct CommentStart
    identification ::String
    line_number    ::Int64
end


struct CommentEnd
    is_recovery    ::Bool
    identification ::String
    line_number    ::Int64
end


struct DTDEnd
    identification ::String
    line_number    ::Int64
end

struct DTDStart
    root              ::String
    public_identifier ::Union{Nothing, String}
    system_identifier ::Union{Nothing, String}
    identification    ::String
    line_number       ::Int64
end

struct DTDInternalEnd
    identification ::String
    line_number    ::Int64
end

struct DTDInternalStart
    identification ::String
    line_number    ::Int64
end

struct DataContent
    value          ::String
    is_ws          ::Bool
    identification ::String
    line_number    ::Int64
end


struct EntityDeclarationExternal
    name             ::String
    is_parameter     ::Bool
    public_identifier::Union{Nothing, String}
    system_identifier::Union{Nothing, String}
    ndata_declaration::Union{Nothing, String}
    identification   ::String
    line_number      ::Int64
end

struct EntityDeclarationInternal
    name             ::String
    is_parameter     ::Bool
    entity_definition::String
    identification   ::String
    line_number      ::Int64
end

struct EntityReferenceGeneral
    name           ::String
    identification ::String
    line_number    ::Int64
end


struct EntityReferenceParameter
    name           ::String
    identification ::String
    line_number    ::Int64
end


struct ProcessingInstruction
    target         ::String # It's someone else's job to verify that this isn't some case variant of "XML".
    value          ::String
    identification ::String
    line_number    ::Int64
end


struct MarkupError
    message        ::String # I'll eventually do something more sophisticated here.
    discarded      ::Array{Lexical.Token, 1}
    identification ::String
    line_number    ::Int64
end


struct AttributeSpecification
    name           ::String
    value          ::Array{Union{DataContent, CharacterReference, EntityReferenceGeneral, EntityReferenceParameter, MarkupError}, 1}
    identification ::String
    line_number    ::Int64
end


struct ElementEnd
    is_recovery    ::Bool
    name           ::String
    identification ::String
    line_number    ::Int64
end


struct ElementStart
    is_recovery    ::Bool
    is_empty       ::Bool
    name           ::String
    attributes     ::Array{AttributeSpecification, 1}
    identification ::String
    line_number    ::Int64
end

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

CommentEnd(identification, line_number) = CommentEnd(false, identification, line_number)
CDATAMarkedSectionEnd(identification, line_number) = CDATAMarkedSectionEnd(false, identification, line_number)
ElementEnd(name, identification, line_number) = ElementEnd(false, name, identification, line_number)
ElementStart(name, attributes, identification, line_number) = ElementStart(false, name, attributes, identification, line_number)
ElementStart(is_empty, name, attributes, identification, line_number) = ElementStart(false, is_empty, name, attributes,
                                                                                     identification, line_number)

DataContent(tokens::Array, identification, line_number) = DataContent(join(map(token -> token.value, tokens), ""),
                                                                      identification, line_number)
DataContent(value, identification, line_number) = DataContent(value, false, identification, line_number)

is_eoi(tokens) = !isopen(tokens) & !isready(tokens)


# These are needed for writing tests, because these types contain other structs inside an array.
#
function Base.:(==)(left::MarkupError, right::MarkupError)
    return (left.message           == right.message
            && left.discarded      == right.discarded
            && left.identification == right.identification
            && left.line_number    == right.line_number)
end


function Base.:(==)(left::ElementStart, right::ElementStart)
    return (left.is_recovery       == right.is_recovery
            && left.name           == right.name
            && left.attributes     == right.attributes
            && left.identification == right.identification
            && left.line_number    == right.line_number)
end


function Base.:(==)(left::AttributeSpecification, right::AttributeSpecification)
    return (left.name              == right.name
            && left.value          == right.value
            && left.identification == right.identification
            && left.line_number    == right.line_number)
end


function cdata_marked_section(mdo, tokens, channel)
    dso = take!(tokens)

    if is_keyword("CDATA", tokens)
        text = take!(tokens) # Consume the CDATA keyword.

        if is_token(Lexical.dso, tokens)
            take!(tokens)

            put!(channel, CDATAMarkedSectionStart(Lexical.location_of(mdo)...))

            consumed = Array{Lexical.Token, 1}()

            while true
                if is_token(Lexical.msc, tokens)
                    msc = take!(tokens)

                    if is_token(Lexical.tagc, tokens)
                        take!(tokens)
                        put!(channel, DataContent(consumed, locations_of(mdo, consumed)[:head]...))
                        put!(channel, CDATAMarkedSectionEnd(Lexical.location_of(msc)...))
                        break

                    else
                        put!(channel, DataContent(consumed, locations_of(mdo, consumed)[:head]...))
                        put!(channel, MarkupError("ERROR: Expecting '>' to end a CDATA marked section.", [ ],
                                                  Lexical.location_of(msc)...))
                        put!(channel, CDATAMarkedSectionEnd(true, Lexical.location_of(msc)...))
                        break
                    end

                elseif is_eoi(tokens)
                    put!(channel, DataContent(consumed, locations_of(mdo, consumed)[:head]...))
                    put!(channel, MarkupError("ERROR: Expecting ']]>' to end a CDATA marked section.", [ ],
                                              locations_of(mdo, consumed)[:tail]...))
                    put!(channel, CDATAMarkedSectionEnd(true, locations_of(mdo, consumed)[:tail]...))
                    break

                else
                    push!(consumed, take!(tokens))
                end
            end

        else
            put!(channel, MarkupError("ERROR: Expecting '[' to open a CDATA marked section.", [ mdo, dso, text ],
                                      Lexical.location_of(text)...))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting 'CDATA' to open a CDATA marked section.", [ mdo, dso ],
                                  Lexical.location_of(dso)...))
    end
end


function collect_attributes(tokens)
    function collect_attribute(tokens)
        name = take!(tokens) # Collect the attribute name token that got us here.
        consume_white_space!(tokens)

        value = Array{Union{DataContent, CharacterReference, EntityReferenceGeneral, EntityReferenceParameter, MarkupError}, 1}()

        if is_token(Lexical.vi, tokens)
            vi = take!(tokens)
            consume_white_space!(tokens)
            collect_attribute_value(vi, value, tokens)

        else
            push!(value, MarkupError("ERROR: Expecting '=' after an attribute name.", [ ], Lexical.location_of(name)...))
        end

        return AttributeSpecification(name.value, value, Lexical.location_of(name)...)
    end

    function collect_attribute_value(vi, value, tokens)
        if is_token(Lexical.lit, tokens) | is_token(Lexical.lita, tokens)
            delimiter = take!(tokens)

            while true
                if is_eoi(tokens)
                    push!(value, MarkupError("ERROR: Expecting the remainder of an attribute value.", [ ],
                                             Lexical.location_of(vi)...))
                    break

                elseif fetch(tokens).token_type == delimiter.token_type
                    take!(tokens)
                    break

                elseif is_token(Lexical.cro, tokens)
                    push!(value, character_reference(tokens))

                elseif is_token(Lexical.ero, tokens)
                    push!(value, entity_reference(tokens, true))

                elseif is_token(Lexical.stago, tokens)
                    stago = take!(tokens)
                    push!(value, MarkupError("ERROR: A '<' must be escaped inside an attribute value.", [ stago ],
                                             Lexical.location_of(stago)...))

                elseif is_token(Lexical.ws, tokens)
                    ws = take!(tokens)
                    push!(value, DataContent(ws.value, true, Lexical.location_of(ws)...))

                else
                    data_content = take!(tokens)
                    push!(value, DataContent(data_content.value, Lexical.location_of(data_content)...))
                end
            end

        else
            push!(value, MarkupError("ERROR: Expecting a quoted attribute value after '='.", [ ], Lexical.location_of(vi)...))
        end
    end


    attributes = Array{AttributeSpecification, 1}()

    while true
        if is_token(Lexical.ws, tokens)
            take!(tokens)

            if is_token(Lexical.text, tokens)
                push!(attributes, collect_attribute(tokens))

            else
                break
            end

        else
            break
        end
    end

    return attributes
end


function comment(mdo, tokens, channel)
    com = take!(tokens)

    consumed = Array{Lexical.Token, 1}()

    put!(channel, CommentStart(Lexical.location_of(mdo)...))

    while true
        if is_token(Lexical.com, tokens)
            tail = take!(tokens)

            if is_token(Lexical.tagc, tokens)
                take!(tokens)
                put!(channel, DataContent(consumed, locations_of(com, consumed)[:head]...))
                put!(channel, CommentEnd(Lexical.location_of(com)...))
                break

            elseif is_eoi(tokens)
                put!(channel, DataContent(consumed, locations_of(com, consumed)[:head]...))
                put!(channel, MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], locations_of(com, consumed)[:tail]...))
                put!(channel, CommentEnd(true, locations_of(com, consumed)[:tail]...))
                break

            else
                put!(channel, DataContent(consumed, locations_of(com, consumed)[:head]...))
                put!(channel, MarkupError("ERROR: '--' is not allowed inside a comment.", [ ],
                                          locations_of(com, consumed)[:tail]...))
                put!(channel, CommentEnd(true, locations_of(com, consumed)[:tail]...))
                break
            end

        elseif is_eoi(tokens)
            put!(channel, DataContent(consumed, locations_of(com, consumed)[:head]...))
            put!(channel, MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], locations_of(com, consumed)[:tail]...))
            put!(channel, CommentEnd(true, locations_of(com, consumed)[:tail]...))
            break

        else
            push!(consumed, take!(tokens))
        end
    end
end


function consume_white_space!(tokens)
    if is_token(Lexical.ws, tokens)
        take!(tokens)
    end
end


function document_type_declaration(mdo, tokens, channel)
    doctype = take!(tokens)
    consume_white_space!(tokens)

    if is_token(Lexical.text, tokens)
        root = take!(tokens)
        consume_white_space!(tokens)
        external_identifier = collect_external_identifier(mdo, tokens, channel)
        consume_white_space!(tokens)
        if is_token(Lexical.tagc, tokens)
            tagc = take!(tokens)
            put!(channel, DTDStart(root.value, external_identifier..., Lexical.location_of(doctype)...))
            put!(channel, DTDEnd(Lexical.location_of(doctype)...))

        elseif is_token(Lexical.dso, tokens)
            dso = take!(tokens)
            put!(channel, DTDStart(root.value, external_identifier..., Lexical.location_of(doctype)...))
            put!(channel, DTDInternalStart(Lexical.location_of(doctype)...))

        else
            put!(channel, MarkupError("ERROR: Expecting '>' to end a document type declaration.",
                                      [ mdo, doctype, root ], Lexical.location_of(root)...))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting a root element name.", [ mdo, doctype ], Lexical.location_of(doctype)...))
    end
end


function element_end(tokens, channel)
    etago = take!(tokens) # Consume the ETAGO that got us here.

    if is_token(Lexical.text, tokens)
        name = take!(tokens)
        consume_white_space!(tokens)

        if is_token(Lexical.tagc, tokens)
            take!(tokens)
            put!(channel, ElementEnd(name.value, Lexical.location_of(name)...))

        else
            put!(channel, MarkupError("ERROR: Expecting '>' to end an element close tag.", [ ], Lexical.location_of(name)...))
            put!(channel, ElementEnd(true, name.value, Lexical.location_of(name)...))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting an element name.", [ etago ], Lexical.location_of(etago)...))
    end
end


function element_start(tokens, channel)
    stago = take!(tokens) # Consume the STAGO that got us here.

    if is_token(Lexical.text, tokens)
        name = take!(tokens)
        attributes = collect_attributes(tokens) # We should really slip the is_recovery flag on the ElementStart if any
                                                # of the attributes contain a MarkupError.
        consume_white_space!(tokens)

        if is_token(Lexical.net, tokens)
            take!(tokens)
            if is_token(Lexical.tagc, tokens)
                take!(tokens)
                put!(channel, ElementStart(true, name.value, attributes, Lexical.location_of(name)...))
                put!(channel, ElementEnd(name.value, Lexical.location_of(name)...))

            else
                put!(channel, ElementStart(true, true, name.value, attributes, Lexical.location_of(name)...))
                put!(channel, MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], Lexical.location_of(name)...))
                put!(channel, ElementEnd(true, name.value, Lexical.location_of(name)...))
            end

        elseif is_token(Lexical.tagc, tokens)
            take!(tokens)
            put!(channel, ElementStart(name.value, attributes, Lexical.location_of(name)...))

        else
            put!(channel, ElementStart(true, false, name.value, attributes, Lexical.location_of(name)...))
            put!(channel, MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], Lexical.location_of(name)...))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting an element name.", [ stago ], Lexical.location_of(stago)...))
    end
end


function entity_declaration(mdo, tokens, channel)
    function collect_entity_definition(entity_name, is_parameter_entity, tokens, channel)
        external_identifier = collect_external_identifier(entity_name, tokens, channel)
        if external_identifier == ( nothing, nothing )
            entity_value = collect_string(Lexical.location_of(entity_name), tokens, channel)

            return ( external_identifier = external_identifier, entity_value = stringify(entity_value), ndata_name = nothing )

        else
            if is_parameter_entity
                return ( external_identifier = external_identifier, entity_value = nothing, ndata_name = nothing )

            else
                consume_white_space!(tokens)
                if is_keyword("NDATA", tokens)
                    ndata = take!(tokens) # Consume the NDATA keyword.
                    consume_white_space!(tokens)

                    if is_token(Lexical.text, tokens)
                        ndata_name = take!(tokens)

                        return ( external_identifier = external_identifier, entity_value = nothing, ndata_name =  ndata_name.value )

                    else
                        put!(channel, MarkupError("ERROR: Expecting a notation name.", [ entity_name ],
                                                  Lexical.location_of(entity_name)...))

                        return ( external_identifier = external_identifier, entity_value = nothing, ndata_name = nothing )
                    end

                else
                    return ( external_identifier = external_identifier, entity_value = nothing, ndata_name = nothing )
                end
            end
        end
    end


    entity = take!(tokens)
    consume_white_space!(tokens)

    is_parameter_entity = is_token(Lexical.pero, tokens)
    if is_parameter_entity
        take!(tokens)
        consume_white_space!(tokens)
    end

    if is_token(Lexical.text, tokens)
        entity_name = take!(tokens)
        consume_white_space!(tokens)
        entity_definition = collect_entity_definition(entity_name, is_parameter_entity, tokens, channel)
        consume_white_space!(tokens)
        if is_token(Lexical.tagc, tokens)
            tagc = take!(tokens)
            if entity_definition[2] == nothing
                put!(channel, EntityDeclarationExternal(entity_name.value, is_parameter_entity,
                                                        entity_definition[:external_identifier]...,
                                                        entity_definition[:ndata_name],
                                                        Lexical.location_of(entity)...))

            else
                put!(channel, EntityDeclarationInternal(entity_name.value, is_parameter_entity, entity_definition[:entity_value],
                                                        Lexical.location_of(entity)...))
            end

        else
            put!(channel, MarkupError("ERROR: Expecting '>' to end an entity declaration.",
                                      [ mdo, entity, entity_name ], Lexical.location_of(entity_name)...))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting an entity name.", [ mdo, entity ], Lexical.location_of(entity)...))
    end
end


function events(state::Lexical.State)
    function eventified(channel::Channel)
        tokens = Lexical.tokens(state)

        while true
            if is_token(Lexical.mdo, tokens)
                markup_declaration(tokens, channel)

            elseif is_token(Lexical.cro, tokens)
                put!(channel, character_reference(tokens))

            elseif is_token(Lexical.ero, tokens)
                put!(channel, entity_reference(tokens))

            elseif is_token(Lexical.pero, tokens)
                parameter_entity_reference(tokens, channel)

            elseif is_token(Lexical.pio, tokens)
                processing_instruction(tokens, channel)

            elseif is_token(Lexical.stago, tokens)
                element_start(tokens, channel)

            elseif is_token(Lexical.etago, tokens)
                element_end(tokens, channel)

            elseif is_eoi(tokens)
                break

            else
                if is_token(Lexical.ws, tokens)
                    ws = take!(tokens)
                    push!(channel, DataContent(ws.value, true, Lexical.location_of(ws)...))

                else
                    token = take!(tokens)
                    push!(channel, DataContent(token.value, Lexical.location_of(token)...))
                end
            end
        end
    end

    return Channel(eventified; csize = 1)
end


function is_keyword(keyword, tokens)
    if is_token(Lexical.text, tokens)
        text = fetch(tokens)

        return text.value == keyword

    else
        return false
    end
end


function is_token(token_type, tokens)
    if isready(tokens) | isopen(tokens)
        token = fetch(tokens)

        return token.token_type == token_type

    else
        return false
    end
end


function locations_of(leader, consumed)
    if length(consumed) > 0
        head = Lexical.location_of(consumed[1])

    else
        head = Lexical.location_of(leader)
    end

    if length(consumed) > 0
        tail = Lexical.location_of(consumed[end])

    else
        tail = Lexical.location_of(leader)
    end

    return ( head = head, tail = tail )
end


function markup_declaration(tokens, channel)
    mdo = take!(tokens) # Consume the MDO token that got us here.

    if is_token(Lexical.dso, tokens)
        cdata_marked_section(mdo, tokens, channel)

    elseif is_token(Lexical.com, tokens)
        comment(mdo, tokens, channel)

    elseif is_keyword("DOCTYPE", tokens)
        document_type_declaration(mdo, tokens, channel)

    elseif is_keyword("ENTITY", tokens)
        entity_declaration(mdo, tokens, channel)

    else
        put!(channel, MarkupError("ERROR: Expecting the start of a markup declaration.", [ mdo ], Lexical.location_of(mdo)...))
    end
end


function parameter_entity_reference(tokens, channel)
    pero = take!(tokens) # Consume the PERO token that got us here.

    if is_token(Lexical.text, tokens)
        name = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            put!(channel, EntityReferenceParameter(name.value, Lexical.location_of(pero)...))

        else
            put!(channel, MarkupError("ERROR: Expecting ';' to end a parameter entity reference.", [ pero, name ],
                                      Lexical.location_of(name)...))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting a parameter entity name.", [ pero ], Lexical.location_of(pero)...))
    end
end


function processing_instruction(tokens, channel)
    pio = take!(tokens) # Consume the PIO token that got us here.

    if is_token(Lexical.text, tokens)
        target = take!(tokens) # See [1], § 2.6 ... the PI target is required. Technically, we should exclude all case
                               # variants of "XML" from the PI target, but let's leave that to another layer for now.

        if is_token(Lexical.ws, tokens)
            take!(tokens) # Don't bother holding on to this one. Again, see [1], § 2.6 ... the white space is required,
                          # so it's syntax and doesn't belong in the PI value.

            consumed = Array{Lexical.Token, 1}()

            while true
                if is_token(Lexical.pic, tokens)
                    take!(tokens)

                    put!(channel, ProcessingInstruction(target.value, join(map(value -> value.value, consumed), ""),
                                                        Lexical.location_of(pio)...))
                    break

                elseif is_eoi(tokens)
                    t = vcat(pio, target, consumed)
                    put!(channel, MarkupError("ERROR: Expecting '?>' to end a processing instruction.",
                                              t, Lexical.location_of(t[end])...))
                    break

                else
                    push!(consumed, take!(tokens))
                end
            end

        elseif is_token(Lexical.pic, tokens)
            take!(tokens)

            put!(channel, ProcessingInstruction(target.value, "", Lexical.location_of(pio)...))

        else
            put!(channel, MarkupError("ERROR: Expecting '?>' to end a processing instruction.", [ pio, target ] ,
                                      Lexical.location_of(target)...))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting a PI target.", [ pio ], Lexical.location_of(pio)...))
    end
end

# ----------------------------------------
# SMALL PARSERS
# ----------------------------------------

function character_reference(tokens)
    cro = take!(tokens) # Consume the CRO token that got us here.

    if is_token(Lexical.text, tokens)
        value = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            return CharacterReference(value.value, Lexical.location_of(cro)...)

        else
            return MarkupError("ERROR: Expecting ';' to end a character reference.", [ cro, value ], Lexical.location_of(value)...)
        end

    else
        return MarkupError("ERROR: Expecting a character value.", [ cro ], Lexical.location_of(cro)...)
    end
end


function entity_reference(tokens, in_attribute = false)
    ero = take!(tokens) # Consume the ERO token that got us here.

    if is_token(Lexical.text, tokens)
        name = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            return EntityReferenceGeneral(name.value, Lexical.location_of(ero)...)

        else
            return MarkupError("ERROR: Expecting ';' to end an entity reference.", [ ero, name ], Lexical.location_of(name)...)
        end

    else
        if in_attribute
            return MarkupError("ERROR: A '&' must be escaped inside an attribute value.", [ ero ], Lexical.location_of(ero)...)

        else
            return MarkupError("ERROR: Expecting an entity name.", [ ero ], Lexical.location_of(ero)...)
        end
    end
end


function collect_external_identifier(mdo, tokens, channel)
    if is_keyword("SYSTEM", tokens)
        system = take!(tokens)

        return ( nothing, stringify(collect_string(Lexical.location_of(system), tokens, channel)) )

    elseif is_keyword("PUBLIC", tokens)
        public = take!(tokens)
        public_identifier = collect_string(Lexical.location_of(public), tokens, channel)
        if public_identifier == nothing
            # Something is funky. Don't bother trying to parse the system identifier.
            #
            return ( nothing, nothing )

        else
            if is_token(Lexical.ws, tokens)
                take!(tokens) # Don't bother holding on to this one. See [1], § 4.2.2 ... the white space is
                              # required, which seems kind of lame off hand, but so be it.
                system_identifier = collect_string(locations_of(mdo, public_identifier)[:tail], tokens, channel)

                if system_identifier == nothing
                    put!(channel, MarkupError("ERROR: Expecting a system identifier following a public identifier.",
                                              [ ], locations_of(mdo, public_identifier)[:tail]...))

                    return ( stringify(public_identifier), nothing )

                else
                    return ( stringify(public_identifier), stringify(system_identifier) )
                end

            else
                put!(channel, MarkupError("ERROR: Expecting white space following a public identifier.",
                                          [ ], locations_of(mdo, public_identifier)[:tail]...))

                return ( stringify(public_identifier), nothing )
            end
        end

    else
        return ( nothing, nothing )
    end
end


function collect_string(location, tokens, channel)
    consume_white_space!(tokens)

    if is_token(Lexical.lit, tokens) | is_token(Lexical.lita, tokens)
        delimiter = take!(tokens)

        consumed = Array{Lexical.Token, 1}()

        while true
            if fetch(tokens).token_type == delimiter.token_type
                take!(tokens)
                break

            else
                push!(consumed, take!(tokens))
            end
        end

        return consumed

    else
        put!(channel, MarkupError("ERROR: Expecting a quoted string.", [ ], location...))

        return nothing
    end
end

# ----------------------------------------
# UTILITIES
# ----------------------------------------

function stringify(consumed_tokens)
    return join(map(value -> value.value, consumed_tokens), "")
end

end
