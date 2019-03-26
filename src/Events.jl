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

struct EntityReference
   name ::String
end

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

function events(state::Lexical.State)
    tokens = Lexical.tokens(state)

    while true
        if is_token(Lexical.ero, tokens)
            take!(tokens)

            if is_token(Lexical.text, tokens)
                name = take!(tokens).value
                if is_token(Lexical.refc, tokens)
                    @show EntityReference(name)

                else
                    @info "ERROR: Expecting ';' to end an entity reference."
                end

            else
                @info "ERROR: Expecting an entity name."
            end

        else
            @info "NOPE!"
            break
        end
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
