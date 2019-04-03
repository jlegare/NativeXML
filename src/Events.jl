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


struct DataContent
    value          ::String
    is_ws          ::Bool
    identification ::String
    line_number    ::Int64
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
DataContent(value, identification, line_number) = DataContent(value, false, identification, line_number)
ElementEnd(name, identification, line_number) = ElementEnd(false, name, identification, line_number) 
ElementStart(name, attributes, identification, line_number) = ElementStart(false, name, attributes, identification, line_number)
is_eoi(tokens) = !isopen(tokens) & !isready(tokens)


# This is needed for writing tests, because MarkupError contains other structs inside an array.
#
function Base.:(==)(left::MarkupError, right::MarkupError)
    return (left.message           == right.message
            && left.discarded      == right.discarded
            && left.identification == right.identification
            && left.line_number    == right.line_number)
end


function cdata_marked_section(mdo, tokens, channel)
    dso = take!(tokens)

    if is_token(Lexical.text, tokens)
        text = fetch(tokens)

        if text.value == "CDATA"
            take!(tokens)

            if is_token(Lexical.dso, tokens)
                take!(tokens)

                put!(channel, CDATAMarkedSectionStart(Lexical.location_of(mdo)...))

                consumed = Array{Lexical.Token, 1}()

                while true
                    if is_token(Lexical.msc, tokens)
                        msc = take!(tokens)

                        if is_token(Lexical.tagc, tokens)
                            take!(tokens)
                            put!(channel, DataContent(join(map(value -> value.value, consumed), ""), Lexical.location_of(mdo)...))
                            put!(channel, CDATAMarkedSectionEnd(Lexical.location_of(msc)...))
                            break

                        else
                            put!(channel, DataContent(join(map(value -> value.value, consumed), ""), Lexical.location_of(mdo)...))
                            put!(channel, MarkupError("ERROR: Expecting '>' to end a CDATA marked section.", [ ],
                                                      Lexical.location_of(msc)...))
                            put!(channel, CDATAMarkedSectionEnd(true, Lexical.location_of(msc)...))
                            break
                        end

                    elseif is_eoi(tokens)
                        put!(channel, DataContent(join(map(value -> value.value, consumed), ""), Lexical.location_of(mdo)...))
                        put!(channel, MarkupError("ERROR: Expecting ']]>' to end a CDATA marked section.", [ ],
                                                  Lexical.location_of(consumed[end])...))
                        put!(channel, CDATAMarkedSectionEnd(true, Lexical.location_of(consumed[end])...))
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

    else
        put!(channel, MarkupError("ERROR: Expecting 'CDATA' to open a CDATA marked section.", [ mdo, dso ],
                                  Lexical.location_of(dso)...))
    end
end


function collect_attributes(tokens)
    function collect_attribute(tokens)
        name = take!(tokens) # Collect the attribute name token that got us here.
        if is_token(Lexical.ws, tokens)
            take!(tokens)
        end

        value = Array{Union{DataContent, CharacterReference, EntityReferenceGeneral, EntityReferenceParameter, MarkupError}, 1}()

        if is_token(Lexical.vi, tokens)
            vi = take!(tokens)
            if is_token(Lexical.ws, tokens)
                take!(tokens)
            end
            collect_attribute_value(value, tokens)

        else
            push!(value, MarkupError("ERROR: Expecting '=' after an attribute name.", [ ], Lexical.location_of(name)...))
        end

        return AttributeSpecification(name.value, value, Lexical.location_of(name)...)
    end

    function collect_attribute_value(value, tokens)
        if is_token(Lexical.lit, tokens) | is_token(Lexical.lita, tokens)
            delimiter = take!(tokens)

            while true
                if fetch(tokens).token_type == delimiter.token_type
                    take!(tokens)
                    break

                elseif is_token(Lexical.cro, tokens)
                    push!(value, character_reference(tokens))

                elseif is_token(Lexical.ero, tokens)
                    push!(value, entity_reference(tokens, true))

                elseif is_token(Lexical.stago, tokens)
                    stago = take!(tokens)
                    push!(value, MarkupError("ERROR: A '<' must escaped inside an attribute value.", [ stago ],
                                             Lexical.location_of(stago)...))

                elseif is_token(Lexical.ws, tokens)
                    ws = take!(tokens)
                    push!(value, DataContent(ws.value, true, Lexical.location_of(ws)...))

                else
                    data_content = take!(tokens)
                    push!(value, DataContent(data_content.value, Lexical.location_of(data_content)...))
                end
            end
        end
    end


    attributes = Array{AttributeSpecification, 1}()

    while true
        if is_token(Lexical.ws, tokens)
            take!(tokens)
        end

        if is_token(Lexical.text, tokens)
            push!(attributes, collect_attribute(tokens))

        else
            break
        end
    end

    return attributes
end


function comment(mdo, tokens, channel)
    function locations_of(com, consumed)
        if length(consumed) > 0
            head = Lexical.location_of(consumed[1])

        else
            head = Lexical.location_of(com)
        end

        if length(consumed) > 0
            tail = Lexical.location_of(consumed[end])

        else
            tail = Lexical.location_of(com)
        end

        return ( head = head, tail = tail )
    end


    com = take!(tokens)

    consumed = Array{Lexical.Token, 1}()

    put!(channel, CommentStart(Lexical.location_of(mdo)...))

    while true
        if is_token(Lexical.com, tokens)
            tail = take!(tokens)

            if is_token(Lexical.tagc, tokens)
                take!(tokens)
                put!(channel, DataContent(join(map(value -> value.value, consumed), ""), locations_of(com, consumed)[:head]...))
                put!(channel, CommentEnd(Lexical.location_of(com)...))
                break

            elseif is_eoi(tokens)
                put!(channel, DataContent(join(map(value -> value.value, consumed), ""), locations_of(com, consumed)[:head]...))
                put!(channel, MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], locations_of(com, consumed)[:tail]...))
                put!(channel, CommentEnd(true, locations_of(com, consumed)[:tail]...))
                break

            else
                put!(channel, DataContent(join(map(value -> value.value, consumed), ""), locations_of(com, consumed)[:head]...))
                put!(channel, MarkupError("ERROR: '--' is not allowed inside a comment.", [ ],
                                          locations_of(com, consumed)[:tail]...))
                put!(channel, CommentEnd(true, locations_of(com, consumed)[:tail]...))
                break
            end

        elseif is_eoi(tokens)
            put!(channel, DataContent(join(map(value -> value.value, consumed), ""), locations_of(com, consumed)[:head]...))
            put!(channel, MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], locations_of(com, consumed)[:tail]...))
            put!(channel, CommentEnd(true, locations_of(com, consumed)[:tail]...))
            break

        else
            push!(consumed, take!(tokens))
        end
    end
end


function element_end(tokens, channel)
    etago = take!(tokens) # Consume the ETAGO that got us here.

    if is_token(Lexical.text, tokens)
        name = take!(tokens)
        if is_token(Lexical.ws, tokens) # Trailing white space is allowed ...
            take!(tokens)               # ... and just discard it.
        end

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
        attributes = collect_attributes(tokens)

        if is_token(Lexical.ws, tokens) # Trailing white space is allowed ...
            take!(tokens)               # ... and just discard it.
        end

        if is_token(Lexical.net, tokens)
            take!(tokens)
            if is_token(Lexical.tagc, tokens)
                take!(tokens)
                put!(channel, ElementStart(name.value, attributes, Lexical.location_of(name)...))
                put!(channel, ElementEnd(name.value, Lexical.location_of(name)...))

            else
                put!(channel, ElementStart(true, name.value, attributes, Lexical.location_of(name)...))
                put!(channel, MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], Lexical.location_of(name)...))
                put!(channel, ElementEnd(true, name.value, Lexical.location_of(name)...))
            end

        elseif is_token(Lexical.tagc, tokens)
            take!(tokens)
            put!(channel, ElementStart(name.value, attributes, Lexical.location_of(name)...))

        else
            put!(channel, ElementStart(true, name.value, attributes, Lexical.location_of(name)...))
            put!(channel, MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], Lexical.location_of(name)...))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting an element name.", [ stago ], Lexical.location_of(stago)...))
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

            else
                # This isn't right ... unmatched tokens should be gobbled up in a MarkupError().
                #
                break
            end
        end
    end

    return Channel(eventified; csize = 1)
end


function is_token(token_type, tokens)
    if isready(tokens) | isopen(tokens)
        token = fetch(tokens)

        return token.token_type == token_type

    else
        return false
    end
end


function markup_declaration(tokens, channel)
    mdo = take!(tokens) # Consume the MDO token that got us here.

    if is_token(Lexical.dso, tokens)
        cdata_marked_section(mdo, tokens, channel)

    elseif is_token(Lexical.com, tokens)
        comment(mdo, tokens, channel)

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


end
