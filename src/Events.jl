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

struct CDATAMarkedSection
    value          ::String
    identification ::String
    line_number    ::Int64
end


struct CharacterReference
    value          ::String # It's someone else's job to verify that the value is a legitimate character.
    identification ::String
    line_number    ::Int64
end


struct Comment
    value          ::String # It's someone else's job to verify that the value is a legitimate character.
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

function events(state::Lexical.State)
    tokens = Lexical.tokens(state)

    while true
        if is_token(Lexical.mdo, tokens)
            @show markup_declaration(tokens)

        elseif is_token(Lexical.cro, tokens)
            @show character_reference(tokens)

        elseif is_token(Lexical.ero, tokens)
            @show entity_reference(tokens)

        elseif is_token(Lexical.pio, tokens)
            @show processing_instruction(tokens)

        else
            @info "NOPE!"
            break
        end
    end
end


function cdata_marked_section(mdo, tokens)
    dso = take!(tokens)

    if is_token(Lexical.text, tokens)
        text = fetch(tokens)

        if text.value == "CDATA"
            take!(tokens)

            if is_token(Lexical.dso, tokens)
                take!(tokens)

                consumed = Array{Lexical.Token, 1}()

                while true
                    if is_token(Lexical.msc, tokens)
                        msc = take!(tokens)

                        if is_token(Lexical.tagc, tokens)
                            return CDATAMarkedSection(join(map(value -> value.value, consumed), ""),
                                                      Lexical.location_of(mdo)...)

                        else
                            t = vcat(mdo, dso, text, consumed, msc)

                            return MarkupError("ERROR: Expecting '>' to end a CDATA marked section.", t,
                                               Lexical.location_of(t[end])...)
                        end

                    elseif is_eoi(tokens)
                        t = vcat(mdo, dso, text, consumed)

                        return MarkupError("ERROR: Expecting ']]>' to end a CDATA marked section.", t,
                                           Lexical.location_of(t[end])...)

                    else
                        push!(consumed, take!(tokens))
                    end
                end

                # Handle the content of a CDATA marked section here.

            else
                return MarkupError("ERROR: Expecting '[' to open a CDATA marked section.", [ mdo, dso, text ],
                                   Lexical.location_of(text)...)
            end

        else
            return MarkupError("ERROR: Expecting 'CDATA' to open a CDATA marked section.", [ mdo, dso ],
                               Lexical.location_of(dso)...)
        end

    else
        return MarkupError("ERROR: Expecting 'CDATA' to open a CDATA marked section.", [ mdo, dso ],
                           Lexical.location_of(dso)...)
    end
end


function character_reference(tokens)::Union{CharacterReference, MarkupError}
    cro = take!(tokens) # Consume the CRO token that got us here.

    if is_token(Lexical.text, tokens)
        value = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            return CharacterReference(value.value, Lexical.location_of(cro)...)

        else
            return MarkupError("ERROR: Expecting ';' to end a character reference.", [ ero, value ], Lexical.location_of(name)...)
        end

    else
        return MarkupError("ERROR: Expecting a character value.", [ ero ], Lexical.location_of(ero)...)
    end
end


function comment(mdo, tokens)::Union{Comment, MarkupError}
    com = take!(tokens)

    consumed = Array{Lexical.Token, 1}()

    while true
        if is_token(Lexical.com, tokens)
            tail = take!(tokens)

            if is_token(Lexical.tagc, tokens)
                return Comment(join(map(value -> value.value, consumed), ""), Lexical.location_of(mdo)...)

            else
                t = vcat(mdo, com, consumed, tail)

                return MarkupError("ERROR: '--' is not allowed inside a comment.", t, Lexical.location_of(t[end])...)
            end

        elseif is_eoi(tokens)
            t = vcat(mdo, com, consumed)

            return MarkupError("ERROR: Expecting '-->' to end a comment.", t, Lexical.location_of(t[end])...)

        else
            push!(consumed, take!(tokens))
        end
    end
end


function entity_reference(tokens)::Union{EntityReference, MarkupError}
    ero = take!(tokens) # Consume the ERO token that got us here.

    if is_token(Lexical.text, tokens)
        name = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            return EntityReference(name.value, Lexical.location_of(ero)...)

        else
            return MarkupError("ERROR: Expecting ';' to end an entity reference.", [ ero, name ], Lexical.location_of(name)...)
        end

    else
        return MarkupError("ERROR: Expecting an entity name.", [ ero ], Lexical.location_of(ero)...)
    end
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


function markup_declaration(tokens)
    mdo = take!(tokens) # Consume the MDO token that got us here.

    if is_token(Lexical.dso, tokens)
        return cdata_marked_section(mdo, tokens)

    elseif is_token(Lexical.com, tokens)
        return comment(mdo, tokens)

    else
        return MarkupError("ERROR: Expecting the start of a markup declaration.", [ mdo ], Lexical.location_of(mdo)...)
    end
end


function processing_instruction(tokens)::Union{ProcessingInstruction, MarkupError}
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

                    return ProcessingInstruction(target.value, join(map(value -> value.value, consumed), ""),
                                                 Lexical.location_of(pio)...)

                elseif is_eoi(tokens)
                    t = vcat(pio, consumed)

                    return MarkupError("ERROR: Expecting '?>' to end a processing instruction.", t, Lexical.location_of(t[end])...)

                else
                    push!(consumed, take!(tokens))
                end
            end

        elseif is_token(Lexical.pic, tokens)
            take!(tokens)

            return ProcessingInstruction(target.value, "", Lexical.location_of(pio)...)

        else
            return MarkupError("ERROR: Expecting '?>' to end a processing instruction.", [ target ] ,
                               Lexical.location_of(target)...)
        end

    else
        return MarkupError("ERROR: Expecting a PI target.", [ pio ], Lexical.location_of(pio)...)
    end
end

end
