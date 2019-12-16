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

struct ExternalIdentifier
    public_identifier ::Union{Nothing, String}
    system_identifier ::Union{Nothing, String}
    location          ::Lexical.Location
end


struct CDATAMarkedSectionStart
    location ::Lexical.Location
end


struct CDATAMarkedSectionEnd
    is_recovery ::Bool
    location    ::Lexical.Location
end


struct CharacterReference
    value    ::String # It's someone else's job to verify that the value is a legitimate character.
    location ::Lexical.Location
end


struct CommentStart
    location ::Lexical.Location
end


struct CommentEnd
    is_recovery ::Bool
    location    ::Lexical.Location
end


struct DTDEnd
    location ::Lexical.Location
end


struct DTDStart
    root                ::String
    external_identifier ::Union{Nothing, ExternalIdentifier}
    location            ::Lexical.Location
end


struct DTDInternalEnd
    location ::Lexical.Location
end


struct DTDInternalStart
    location ::Lexical.Location
end


struct DataContent
    value    ::String
    is_ws    ::Bool
    location ::Lexical.Location
end


struct EntityDeclarationExternalGeneralData
    name                ::String
    external_identifier ::Union{Nothing, ExternalIdentifier}
    ndata_declaration   ::Union{Nothing, String}
    location            ::Lexical.Location
end


struct EntityDeclarationExternalGeneralText
    name                ::String
    external_identifier ::Union{Nothing, ExternalIdentifier}
    location            ::Lexical.Location
end


struct EntityDeclarationExternalParameter
    name                ::String
    external_identifier ::Union{Nothing, ExternalIdentifier}
    location            ::Lexical.Location
end


struct EntityDeclarationInternalGeneral
    name         ::String
    entity_value ::String
    location     ::Lexical.Location
end


struct EntityDeclarationInternalParameter
    name         ::String
    entity_value ::String
    location     ::Lexical.Location
end


struct EntityReferenceGeneral
    name     ::String
    location ::Lexical.Location
end


struct EntityReferenceParameter
    name     ::String
    location ::Lexical.Location
end


struct NotationDeclaration
    name                ::String
    external_identifier ::Union{Nothing, ExternalIdentifier}
    location            ::Lexical.Location
end


struct ProcessingInstruction
    target   ::String # It's someone else's job to verify that this isn't some case variant of "XML".
    value    ::String
    location ::Lexical.Location
end


struct MarkupError
    message   ::String # I'll eventually do something more sophisticated here.
    discarded ::Array{Lexical.Token, 1}
    location  ::Lexical.Location
end


struct AttributeSpecification
    name     ::String
    value    ::Array{Union{DataContent, CharacterReference, EntityReferenceGeneral, EntityReferenceParameter, MarkupError}, 1}
    location ::Lexical.Location
end


struct ElementEnd
    is_recovery ::Bool
    name        ::String
    location    ::Lexical.Location
end


struct ElementStart
    is_recovery ::Bool
    is_empty    ::Bool
    name        ::String
    attributes  ::Array{AttributeSpecification, 1}
    location    ::Lexical.Location
end

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

CommentEnd(location) = CommentEnd(false, location)
CDATAMarkedSectionEnd(location) = CDATAMarkedSectionEnd(false, location)
ElementEnd(name, location) = ElementEnd(false, name, location)
ElementStart(name, attributes, location) = ElementStart(false, name, attributes, location)
ElementStart(is_empty, name, attributes, location) = ElementStart(false, is_empty, name, attributes, location)
DataContent(tokens::Array, location) = DataContent(join(map(token -> token.value, tokens), ""), location)
DataContent(value, location) = DataContent(value, false, location)


# These are needed for writing tests, because these types contain other structs inside an array.
#
function Base.:(==)(left::MarkupError, right::MarkupError)
    return (left.message      == right.message
            && left.discarded == right.discarded
            && left.location  == right.location)
end


function Base.:(==)(left::ElementStart, right::ElementStart)
    return (left.is_recovery   == right.is_recovery
            && left.name       == right.name
            && left.attributes == right.attributes
            && left.location   == right.location)
end


function Base.:(==)(left::AttributeSpecification, right::AttributeSpecification)
    return (left.name        == right.name
            && left.value    == right.value
            && left.location == right.location)
end


function cdata_marked_section(mdo, tokens, channel)
    dso = take!(tokens) # Consume the DSO that got us here.

    if is_keyword("CDATA", tokens, channel)
        text = take!(tokens) # Consume the CDATA keyword.

        if is_token(Lexical.dso, tokens)
            take!(tokens)

            put!(channel, CDATAMarkedSectionStart(Lexical.location_of(mdo)))

            consumed = Array{Lexical.Token, 1}()

            while true
                if is_token(Lexical.msc, tokens)
                    msc = take!(tokens)

                    if is_token(Lexical.tagc, tokens)
                        take!(tokens)
                        put!(channel, DataContent(consumed, locations_of(mdo, consumed)[:head]))
                        put!(channel, CDATAMarkedSectionEnd(Lexical.location_of(msc)))
                        break

                    else
                        put!(channel, DataContent(consumed, locations_of(mdo, consumed)[:head]))
                        put!(channel, MarkupError("ERROR: Expecting '>' to end a CDATA marked section.", [ ],
                                                  Lexical.location_of(msc)))
                        put!(channel, CDATAMarkedSectionEnd(true, Lexical.location_of(msc)))
                        break
                    end

                elseif is_eoi(tokens)
                    put!(channel, DataContent(consumed, locations_of(mdo, consumed)[:head]))
                    put!(channel, MarkupError("ERROR: Expecting ']]>' to end a CDATA marked section.", [ ],
                                              locations_of(mdo, consumed)[:tail]))
                    put!(channel, CDATAMarkedSectionEnd(true, locations_of(mdo, consumed)[:tail]))
                    break

                else
                    push!(consumed, take!(tokens))
                end
            end

        else
            put!(channel, MarkupError("ERROR: Expecting '[' to open a CDATA marked section.", [ mdo, dso, text ],
                                      Lexical.location_of(text)))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting 'CDATA' to open a CDATA marked section.", [ mdo, dso ],
                                  Lexical.location_of(dso)))
    end
end


function comment(mdo, tokens, channel)
    com = take!(tokens) # Consume the COM token that got us here.

    consumed = Array{Lexical.Token, 1}()

    put!(channel, CommentStart(Lexical.location_of(mdo)))

    while true
        if is_token(Lexical.com, tokens)
            tail = take!(tokens)

            # We cannot encounter EOI here ... if we hit "--" at EOI, it gets classified as TEXT, not COM. See
            # consume_until() in src/Lexical.jl
            #
            if is_token(Lexical.tagc, tokens)
                take!(tokens)
                put!(channel, DataContent(consumed, locations_of(com, consumed)[:head]))
                put!(channel, CommentEnd(Lexical.location_of(com)))
                break

            else
                put!(channel, DataContent(consumed, locations_of(com, consumed)[:head]))
                put!(channel, MarkupError("ERROR: '--' is not allowed inside a comment.", [ ],
                                          locations_of(com, consumed)[:tail]))
                put!(channel, CommentEnd(true, locations_of(com, consumed)[:tail]))
                break
            end

        elseif is_eoi(tokens)
            put!(channel, DataContent(consumed, locations_of(com, consumed)[:head]))
            put!(channel, MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], locations_of(com, consumed)[:tail]))
            put!(channel, CommentEnd(true, locations_of(com, consumed)[:tail]))
            break

        else
            push!(consumed, take!(tokens))
        end
    end
end


function document_type_declaration(mdo, tokens, channel)
    doctype = take!(tokens)      # Consume the DOCTYPE keyword that got us here ...
    consume_white_space!(tokens) # ... but discard any following white space.

    if is_token(Lexical.text, tokens)
        root = take!(tokens)
        consume_white_space!(tokens)
        external_identifier = collect_external_identifier(mdo, tokens, channel)
        consume_white_space!(tokens)
        if is_token(Lexical.tagc, tokens)
            tagc = take!(tokens)
            put!(channel, DTDStart(root.value, external_identifier, Lexical.location_of(doctype)))
            put!(channel, DTDEnd(Lexical.location_of(doctype)))

        elseif is_token(Lexical.dso, tokens)
            dso = take!(tokens)
            put!(channel, DTDStart(root.value, external_identifier, Lexical.location_of(doctype)))
            put!(channel, DTDInternalStart(Lexical.location_of(doctype)))

        else
            put!(channel, MarkupError("ERROR: Expecting '>' to end a document type declaration.",
                                      [ mdo, doctype, root ], Lexical.location_of(root)))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting a root element name.", [ mdo, doctype ], Lexical.location_of(doctype)))
    end
end


function element_end(tokens, channel)
    etago = take!(tokens) # Consume the ETAGO that got us here.

    if is_name(tokens)
        name = take!(tokens)
        consume_white_space!(tokens)

        if is_token(Lexical.tagc, tokens)
            take!(tokens)
            put!(channel, ElementEnd(name.value, Lexical.location_of(name)))

        else
            put!(channel, MarkupError("ERROR: Expecting '>' to end an element close tag.", [ ], Lexical.location_of(name)))
            put!(channel, ElementEnd(true, name.value, Lexical.location_of(name)))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting an element name.", [ etago ], Lexical.location_of(etago)))
    end
end


function element_start(tokens, channel)
    stago = take!(tokens) # Consume the STAGO that got us here.

    if is_name(tokens)
        name = take!(tokens)
        attributes = collect_attributes(tokens) # We should really slip the is_recovery flag on the ElementStart if any
                                                # of the attributes contain a MarkupError.
        consume_white_space!(tokens)

        if is_token(Lexical.net, tokens)
            take!(tokens)
            if is_token(Lexical.tagc, tokens)
                take!(tokens)
                put!(channel, ElementStart(true, name.value, attributes, Lexical.location_of(name)))
                put!(channel, ElementEnd(name.value, Lexical.location_of(name)))

            else
                put!(channel, ElementStart(true, true, name.value, attributes, Lexical.location_of(name)))
                put!(channel, MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ],
                                          Lexical.location_of(name)))
                put!(channel, ElementEnd(true, name.value, Lexical.location_of(name)))
            end

        elseif is_token(Lexical.tagc, tokens)
            take!(tokens)
            put!(channel, ElementStart(name.value, attributes, Lexical.location_of(name)))

        else
            put!(channel, ElementStart(true, false, name.value, attributes, Lexical.location_of(name)))
            put!(channel, MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], Lexical.location_of(name)))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting an element name.", [ stago ], Lexical.location_of(stago)))
    end
end


function entity_declaration(mdo, tokens, channel)
    function collect_entity_definition(entity_name, tokens, channel)
        external_identifier = collect_external_identifier(entity_name, tokens, channel)
        if isnothing(external_identifier)
            entity_value = collect_string(Lexical.location_of(entity_name), tokens, channel)

            if isnothing(entity_value)
                # Something is messed up.
                #
                return ( external_identifier = nothing, entity_value = nothing, ndata_name = nothing )

            else
                return ( external_identifier = external_identifier, entity_value = stringify(entity_value), ndata_name = nothing )
            end

        else
            consume_white_space!(tokens)
            if is_keyword("NDATA", tokens, channel)
                ndata = take!(tokens)        # Consume the NDATA keyword ...
                consume_white_space!(tokens) # ... but discard any following white space.

                if is_token(Lexical.text, tokens)
                    ndata_name = take!(tokens)

                    return ( external_identifier = external_identifier, entity_value = nothing, ndata_name =  ndata_name )

                else
                    put!(channel, MarkupError("ERROR: Expecting a notation name.", [ ndata ],
                                              Lexical.location_of(entity_name)))

                    return ( external_identifier = external_identifier, entity_value = nothing, ndata_name = nothing )
                end

            else
                return ( external_identifier = external_identifier, entity_value = nothing, ndata_name = nothing )
            end
        end
    end


    entity = take!(tokens)       # Consume the ENTITY keyword that got us here.
    ws = consume_white_space!(tokens)

    if isnothing(ws)
        # See [1], § 4.2 ... the white space is required.
        #
        put!(channel, MarkupError("ERROR: White space is required following the 'ENTITY' keyword.", [ mdo, entity ],
                                  Lexical.location_of(entity)))
    end

    is_parameter_entity = is_token(Lexical.pero, tokens)
    if is_parameter_entity
        pero = take!(tokens)
        ws = consume_white_space!(tokens)

        if isnothing(ws)
            # See [1], § 4.2 ... the white space is required. This one is pretty lame, but it is what it is.
            #
            put!(channel, MarkupError("ERROR: White space is required following '%'.", [ mdo, entity, pero ],
                                      Lexical.location_of(pero)))
        end
    end

    if is_name(tokens)
        entity_name = take!(tokens)
        consume_white_space!(tokens)
        ( external_identifier, entity_value, ndata_name ) = collect_entity_definition(entity_name, tokens, channel)
        consume_white_space!(tokens)

        if is_parameter_entity && !isnothing(ndata_name)
            put!(channel, MarkupError("ERROR: A parameter entity cannot have a notation.", [ ndata_name ],
                                      Lexical.location_of(entity_name)))
            ndata_name = nothing
        end

        if is_token(Lexical.tagc, tokens)
            tagc = take!(tokens)

        else
            put!(channel, MarkupError("ERROR: Expecting '>' to end an entity declaration.", [ mdo, entity ],
                                      Lexical.location_of(entity_name)))
            # From now on in this branch, we're basically doing error-recovery: better to pretend the entity declaration
            # was properly parsed, otherwise there could be a cascade of errors down the line.
            #
        end

        constructor = nothing # Make sure we throw if something goes wrong below.

        if isnothing(entity_value)
            if is_parameter_entity
                constructor = (name, location) -> EntityDeclarationExternalParameter(name, external_identifier, location)

            elseif isnothing(ndata_name)
                constructor = (name, location) -> EntityDeclarationExternalGeneralText(name, external_identifier, location)

            else
                constructor = (name, location) -> EntityDeclarationExternalGeneralData(name, external_identifier,
                                                                                       ndata_name.value, location)
            end

        else
            if is_parameter_entity
                constructor = (name, location) -> EntityDeclarationInternalParameter(name, entity_value, location)

            else
                constructor = (name, location) -> EntityDeclarationInternalGeneral(name, entity_value, location)
            end
        end

        put!(channel, constructor(entity_name.value, Lexical.location_of(entity)))

    else
        put!(channel, MarkupError("ERROR: Expecting an entity name.", [ mdo, entity ], Lexical.location_of(entity)))
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
                put!(channel, collect_entity_reference(tokens))

            elseif is_token(Lexical.pero, tokens)
                put!(channel, collect_parameter_entity_reference(tokens))

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
                    ws = consume_white_space!(tokens)
                    push!(channel, DataContent(ws.value, true, Lexical.location_of(ws)))

                else
                    token = take!(tokens)
                    push!(channel, DataContent(token.value, Lexical.location_of(token)))
                end
            end
        end
    end

    return Channel(eventified; csize = 1)
end


function markup_declaration(tokens, channel)
    mdo = take!(tokens) # Consume the MDO token that got us here.

    if is_token(Lexical.dso, tokens)
        cdata_marked_section(mdo, tokens, channel)

    elseif is_token(Lexical.com, tokens)
        comment(mdo, tokens, channel)

    elseif is_keyword("ATTLIST", tokens, channel)
        # This is temporary until I write the attribute declaration parser.
        #
        put!(channel, MarkupError("ERROR: Expecting the start of a markup declaration.", [ mdo ], Lexical.location_of(mdo)))

    elseif is_keyword("DOCTYPE", tokens, channel)
        document_type_declaration(mdo, tokens, channel)

    elseif is_keyword("ELEMENT", tokens, channel)
        # This is temporary until I write the element declaration parser.
        #
        put!(channel, MarkupError("ERROR: Expecting the start of a markup declaration.", [ mdo ], Lexical.location_of(mdo)))

    elseif is_keyword("ENTITY", tokens, channel)
        entity_declaration(mdo, tokens, channel)

    elseif is_keyword("NOTATION", tokens, channel)
        notation_declaration(mdo, tokens, channel)

    else
        if is_keyword("sgml", tokens, channel)
            put!(channel, MarkupError("ERROR: The keyword 'SGML' is not available in XML.", [ ], Lexical.location_of(mdo)))

        elseif is_keyword("shortref", tokens, channel)
            put!(channel, MarkupError("ERROR: The keyword 'SHORTREF' is not available in XML.", [ ], Lexical.location_of(mdo)))

        elseif is_keyword("usemap", tokens, channel)
            put!(channel, MarkupError("ERROR: The keyword 'USEMAP' is not available in XML.", [ ], Lexical.location_of(mdo)))

        else
            put!(channel, MarkupError("ERROR: Expecting the start of a markup declaration.", [ mdo ], Lexical.location_of(mdo)))
        end
    end
end


function notation_declaration(mdo, tokens, channel)
    notation = take!(tokens)      # Consume the NOTATION keyword that got us here ...
    consume_white_space!(tokens)  # ... but discard any following white space.

    if is_token(Lexical.text, tokens)
        notation_name = take!(tokens)
        consume_white_space!(tokens)

        external_identifier = collect_external_identifier(mdo, tokens, false, channel)
        consume_white_space!(tokens)

        if isnothing(external_identifier)
            put!(channel, MarkupError("ERROR: A notation declaration must specify an external identifier.",
                                      [ mdo, notation, notation_name ], Lexical.location_of(notation_name)))
        end

        if is_token(Lexical.tagc, tokens)
            tagc = take!(tokens)

        else
            put!(channel, MarkupError("ERROR: Expecting '>' to end a notation declaration.",
                                      [ mdo, notation, notation_name ], Lexical.location_of(notation_name)))
        end
        put!(channel, NotationDeclaration(notation_name.value, external_identifier, Lexical.location_of(notation)))

    else
        put!(channel, MarkupError("ERROR: Expecting a notation name.", [ mdo, notation ], Lexical.location_of(notation)))
    end
end


function processing_instruction(tokens, channel)
    pio = take!(tokens) # Consume the PIO token that got us here.

    if is_token(Lexical.text, tokens)
        if is_keyword("XML", tokens, false, channel)
            put!(channel, MarkupError("ERROR: A PI target cannot be any case variant of 'XML'.",
                                      [ pio ], Lexical.location_of(pio)))
        end

        target = take!(tokens) # See [1], § 2.6 ... the PI target is required.

        consume_white_space!(tokens) # Discard any white space. Again, see [1], § 2.6 ... the white space is required,
                                     # so it's syntax and doesn't belong in the PI value.

        consumed = Array{Lexical.Token, 1}()

        while true
            if is_token(Lexical.pic, tokens)
                take!(tokens)

                put!(channel, ProcessingInstruction(target.value, join(map(value -> value.value, consumed), ""),
                                                    Lexical.location_of(pio)))
                break

            elseif is_eoi(tokens)
                t = vcat(pio, target, consumed)
                put!(channel, MarkupError("ERROR: Expecting '?>' to end a processing instruction.",
                                          t, Lexical.location_of(t[end])))
                break

            else
                push!(consumed, take!(tokens))
            end
        end

    else
        put!(channel, MarkupError("ERROR: Expecting a PI target.", [ pio ], Lexical.location_of(pio)))
    end
end

# ----------------------------------------
# SMALL PARSERS
#
# Small parsers return the event rather than emitting it to a channel. They can, however, emit markup errors.
# ----------------------------------------

function character_reference(tokens)
    cro = take!(tokens) # Consume the CRO token that got us here.

    if is_token(Lexical.text, tokens)
        value = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            return CharacterReference(value.value, Lexical.location_of(cro))

        else
            return MarkupError("ERROR: Expecting ';' to end a character reference.", [ cro, value ],
                               Lexical.location_of(value))
        end

    else
        return MarkupError("ERROR: Expecting a character value.", [ cro ], Lexical.location_of(cro))
    end
end


function collect_attributes(tokens)
    function collect_attribute(tokens)
        name = take!(tokens)         # Collect the attribute name token that got us here ...
        consume_white_space!(tokens) # ... but discard any following white space.

        value = Array{Union{DataContent, CharacterReference, EntityReferenceGeneral, EntityReferenceParameter, MarkupError}, 1}()

        if is_token(Lexical.vi, tokens)
            vi = take!(tokens)
            consume_white_space!(tokens)
            collect_attribute_value(vi, value, tokens)

        else
            push!(value, MarkupError("ERROR: Expecting '=' after an attribute name.", [ ], Lexical.location_of(name)))
        end

        return AttributeSpecification(name.value, value, Lexical.location_of(name))
    end

    function collect_attribute_value(vi, value, tokens)
        if is_token(Lexical.lit, tokens) | is_token(Lexical.lita, tokens)
            delimiter = take!(tokens)

            while true
                if is_eoi(tokens)
                    push!(value, MarkupError("ERROR: Expecting the remainder of an attribute value.", [ ],
                                             Lexical.location_of(vi)))
                    break

                elseif fetch(tokens).token_type == delimiter.token_type
                    take!(tokens)
                    break

                elseif is_token(Lexical.cro, tokens)
                    push!(value, character_reference(tokens))

                elseif is_token(Lexical.ero, tokens)
                    push!(value, collect_entity_reference(tokens, true))

                elseif is_token(Lexical.stago, tokens)
                    stago = take!(tokens)
                    push!(value, MarkupError("ERROR: A '<' must be escaped inside an attribute value.", [ stago ],
                                             Lexical.location_of(stago)))

                elseif is_token(Lexical.ws, tokens)
                    ws = consume_white_space!(tokens)
                    push!(value, DataContent(ws.value, true, Lexical.location_of(ws)))

                else
                    data_content = take!(tokens)
                    push!(value, DataContent(data_content.value, Lexical.location_of(data_content)))
                end
            end

        else
            push!(value, MarkupError("ERROR: Expecting a quoted attribute value after '='.", [ ], Lexical.location_of(vi)))
        end
    end


    attributes = Array{AttributeSpecification, 1}()

    while true
        if is_token(Lexical.ws, tokens)
            consume_white_space!(tokens)

            if is_name(tokens)
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


function collect_entity_reference(tokens, in_attribute = false)
    ero = take!(tokens) # Consume the ERO token that got us here.

    if is_name(tokens)
        name = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            return EntityReferenceGeneral(name.value, Lexical.location_of(ero))

        else
            return MarkupError("ERROR: Expecting ';' to end an entity reference.", [ ero, name ], Lexical.location_of(name))
        end

    else
        if in_attribute
            return MarkupError("ERROR: A '&' must be escaped inside an attribute value.", [ ero ], Lexical.location_of(ero))

        else
            return MarkupError("ERROR: Expecting an entity name.", [ ero ], Lexical.location_of(ero))
        end
    end
end


function collect_external_identifier(mdo, tokens, channel)
    return collect_external_identifier(mdo, tokens, true, channel)
end


function collect_external_identifier(mdo, tokens, is_strict, channel)
    if is_keyword("SYSTEM", tokens, channel)
        system = take!(tokens)
        system_identifier = collect_string(Lexical.location_of(system), tokens, channel)

        if isnothing(system_identifier)
            # There's something funky going on.
            #
            return nothing

        else
            return ExternalIdentifier(nothing, stringify(system_identifier), Lexical.location_of(system))
        end

    elseif is_keyword("PUBLIC", tokens, channel)
        public = take!(tokens)
        public_identifier = collect_string(Lexical.location_of(public), tokens, channel)
        if isnothing(public_identifier)
            # Something is funky. Don't bother trying to parse the system identifier.
            #
            return nothing

        else
            if is_token(Lexical.ws, tokens)
                consume_white_space!(tokens) # Consume any white space. See [1], § 4.2.2 ... the white space is
                                             # required, which seems kind of lame off hand, but so be it.

            elseif is_strict | is_token(Lexical.lit, tokens) | is_token(Lexical.lita, tokens)
                # In strict mode, we always emit a markup if there is no white space between the public and system
                # identifiers. In non-strict mode, we only output a markup error if it appears that we're looking at a
                # system identifier.
                #
                put!(channel, MarkupError("ERROR: Expecting white space following a public identifier.",
                                          [ ], locations_of(mdo, public_identifier)[:tail]))
            end

            system_identifier = collect_string(locations_of(mdo, public_identifier)[:tail], tokens, is_strict, channel)

            if isnothing(system_identifier)
                if is_strict
                    put!(channel, MarkupError("ERROR: Expecting a system identifier following a public identifier.",
                                              [ ], locations_of(mdo, public_identifier)[:tail]))
                end

                return ExternalIdentifier(stringify(public_identifier), nothing, Lexical.location_of(public))

            else
                return ExternalIdentifier(stringify(public_identifier), stringify(system_identifier), Lexical.location_of(public))
            end
        end

    else
        return nothing
    end
end


function collect_parameter_entity_reference(tokens)
    pero = take!(tokens) # Consume the PERO token that got us here.

    if is_name(tokens)
        name = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            return EntityReferenceParameter(name.value, Lexical.location_of(pero))

        else
            return MarkupError("ERROR: Expecting ';' to end a parameter entity reference.", [ pero, name ],
                               Lexical.location_of(name))
        end

    else
        return MarkupError("ERROR: Expecting a parameter entity name.", [ pero ], Lexical.location_of(pero))
    end
end


function collect_string(location, tokens, channel)
    return collect_string(location, tokens, true, channel)
end


function collect_string(location, tokens, is_strict, channel)
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
        if is_strict
            put!(channel, MarkupError("ERROR: Expecting a quoted string.", [ ], location))
        end

        return nothing
    end
end

# ----------------------------------------
# UTILITIES
# ----------------------------------------

function consume_white_space!(tokens)
    if is_token(Lexical.ws, tokens)
        return take!(tokens)

    else
        return nothing
    end
end


function is_eoi(tokens)
    return !isopen(tokens) & !isready(tokens)
end


function is_keyword(keyword, tokens, channel)
    is_keyword(keyword, tokens, true, channel)
end


function is_keyword(keyword, tokens, case_sensitive, channel)
    if is_token(Lexical.text, tokens)
        text = fetch(tokens)

        if text.value == keyword
            return true

        elseif lowercase(text.value) == lowercase(keyword)
            if case_sensitive
                put!(channel, MarkupError("ERROR: The keyword '" * text.value * "' must be uppercased.",
                                          [ ], Lexical.location_of(text)))
            end

            return true

        else
            return false
        end

    else
        return false
    end
end


function is_name(tokens)
    function is_name_start_char(c)
        # See [1], § 2.3, production [4].
        #
        #       ":"             | [A-Z]           | "_"             | [a-z]
        #     | [#xC0-#xD6]     | [#xD8-#xF6]     | [#xF8-#x2FF]    | [#x370-#x37D]   | [#x37F-#x1FFF]
        #     | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF]
        #     | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
        #
        # The ranges are split solely for readability.
        #
        if c == ':' || c ∈ 'A':'Z' || c ∈ 'a':'z'
            return true

        elseif Int(c) ∈ 0xc0:0xd6 || Int(c) ∈ 0xd8:0xf6 || Int(c) ∈ 0xf8:0x2ff || Int(c) ∈ 0x370:0x37d || Int(c) ∈ 0x37f:0x1fff
            return true

        elseif Int(c) ∈ 0x200c:0x200d || Int(c) ∈ 0x2070:0x218f || Int(c) ∈ 0x2c00:0x2fef || Int(c) ∈ 0x3001:0xd7ff
            return true

        elseif Int(c) ∈ 0xf900:0xfdcf || Int(c) ∈ 0xfdf0:0xfffd || Int(c) ∈ 0x10000:0xeffff
            return true

        else
            return false
        end
    end


    function is_name_char(c)
        # See [1], § 2.3, production [4a].
        #
        #       NameStartChar | "-" | "." | [0-9] | #xB7 | [#x0300-#x036F] | [#x203F-#x2040]
        #
        # The ranges are split solely for readability.
        #
        if is_name_start_char(c)
            return true

        elseif c == '-' || c == '.' || c ∈ '0':'9' || Int(c) == 0xb7
            return true

        elseif Int(c) ∈ 0x300:0x36f || Int(c) ∈ 0x203f:0x2040
            return true

        else
            return false
        end
    end


    if is_token(Lexical.text, tokens)
        text = fetch(tokens)

        return all(vcat(is_name_start_char(text.value[1]), map(is_name_char, collect(text.value[nextind(text.value, 1):end]))))

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


function stringify(consumed_tokens)
    return join(map(value -> value.value, consumed_tokens), "")
end

end
