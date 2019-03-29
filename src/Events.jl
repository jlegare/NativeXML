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
    identification ::String
    line_number    ::Int64
end


struct EntityReference
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
    consumed       ::Array{Lexical.Token, 1}
    identification ::String
    line_number    ::Int64
end

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------


function CommentEnd(identification, line_number)
    return CommentEnd(false, identification, line_number)
end


function CDATAMarkedSectionEnd(identification, line_number)
    return CDATAMarkedSectionEnd(false, identification, line_number)
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
                            put!(channel, MarkupError("ERROR: Expecting '>' to end a CDATA marked section.", [ msc ],
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


function character_reference(tokens, channel)
    cro = take!(tokens) # Consume the CRO token that got us here.

    if is_token(Lexical.text, tokens)
        value = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            put!(channel, CharacterReference(value.value, Lexical.location_of(cro)...))

        else
            put!(channel, MarkupError("ERROR: Expecting ';' to end a character reference.", [ ero, value ], 
                                      Lexical.location_of(name)...))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting a character value.", [ ero ], Lexical.location_of(ero)...))
    end
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
                put!(channel, DataContent(join(map(value -> value.value, consumed), ""), Lexical.location_of(consumed[1])...))
                put!(channel, CommentEnd(Lexical.location_of(mdo)...))
                break

            elseif is_eoi(tokens)
                put!(channel, DataContent(join(map(value -> value.value, consumed), ""), Lexical.location_of(consumed[1])...))
                put!(channel, MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], Lexical.location_of(consumed[end])...))
                put!(channel, CommentEnd(true, Lexical.location_of(consumed[end])...))
                break

            else
                put!(channel, DataContent(join(map(value -> value.value, consumed), ""), Lexical.location_of(consumed[1])...))
                put!(channel, MarkupError("ERROR: '--' is not allowed inside a comment.", [ ], 
                                          Lexical.location_of(consumed[end])...))
                put!(channel, CommentEnd(true, Lexical.location_of(consumed[end])...))
                break
            end

        elseif is_eoi(tokens)
            put!(channel, DataContent(join(map(value -> value.value, consumed), ""), Lexical.location_of(consumed[1])...))
            put!(channel, MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], Lexical.location_of(consumed[end])...))
            put!(channel, CommentEnd(true, Lexical.location_of(consumed[end])...))
            break

        else
            push!(consumed, take!(tokens))
        end
    end
end


function entity_reference(tokens, channel)
    ero = take!(tokens) # Consume the ERO token that got us here.

    if is_token(Lexical.text, tokens)
        name = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            put!(channel, EntityReference(name.value, Lexical.location_of(ero)...))

        else
            put!(channel, MarkupError("ERROR: Expecting ';' to end an entity reference.", [ ero, name ], 
                                      Lexical.location_of(name)...))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting an entity name.", [ ero ], Lexical.location_of(ero)...))
    end
end


function events(state::Lexical.State)
    function eventified(channel::Channel)
        tokens = Lexical.tokens(state)

        while true
            if is_token(Lexical.mdo, tokens)
                markup_declaration(tokens, channel)

            elseif is_token(Lexical.cro, tokens)
                character_reference(tokens, channel)

            elseif is_token(Lexical.ero, tokens)
                entity_reference(tokens, channel)

            elseif is_token(Lexical.pio, tokens)
                processing_instruction(tokens, channel)

            else
                break
            end
        end
    end

    return Channel(eventified; csize = 1)
end


function is_eoi(tokens)
    return !isopen(tokens)
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
                    t = vcat(pio, consumed)

                    put!(channel, MarkupError("ERROR: Expecting '?>' to end a processing instruction.", t, 
                                              Lexical.location_of(t[end])...))
                    break

                else
                    push!(consumed, take!(tokens))
                end
            end

        elseif is_token(Lexical.pic, tokens)
            take!(tokens)

            put!(channel, ProcessingInstruction(target.value, "", Lexical.location_of(pio)...))

        else
            put!(channel, MarkupError("ERROR: Expecting '?>' to end a processing instruction.", [ target ] ,
                                      Lexical.location_of(target)...))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting a PI target.", [ pio ], Lexical.location_of(pio)...))
    end
end

end
