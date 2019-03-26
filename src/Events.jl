module Events

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

struct CharacterReference
   value          ::String # It's someone else's job to verify that the value is a legititmate character.
   identification ::String
   line_number    ::Int64
end


struct EntityReference
   name           ::String
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
        if is_token(Lexical.cro, tokens)
            @show character_reference(tokens)

        elseif is_token(Lexical.ero, tokens)
            @show entity_reference(tokens)

        else
            @info "NOPE!"
            break
        end
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


function is_token(token_type, tokens)
    if isready(tokens) | isopen(tokens)
        token = fetch(tokens)

        return token.token_type == token_type

    else
        return false
    end
end

end
