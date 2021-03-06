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

# This is used for element declarations only, but has to be declared earlier because it appears in ElementDeclaration.
#
abstract type AbstractModel
end


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


struct DTDInternalStart
    location ::Lexical.Location
end


struct DataContent
    value    ::String
    is_ws    ::Bool
    location ::Lexical.Location
end


struct ElementDeclaration
    is_recovery   ::Bool
    name          ::String
    content_model ::AbstractModel
    location      ::Lexical.Location
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
    target   ::String
    value    ::String
    location ::Lexical.Location
end


struct MarkupError
    message  ::String # I'll eventually do something more sophisticated here.
    location ::Lexical.Location
end


struct AttributeSpecification
    name     ::String
    value    ::Array{Union{DataContent, CharacterReference, EntityReferenceGeneral, EntityReferenceParameter}, 1}
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

struct ConditionalSectionEnd
    location ::Lexical.Location
end

struct ConditionalSectionStart
    is_recovery ::Bool
    conditional ::Union{String, EntityReferenceParameter}
    location    ::Lexical.Location
end


# These are for element declarations.
#
struct AnyModel <: AbstractModel
end


struct ElementModel <: AbstractModel
    element_name ::String
end


struct EmptyModel <: AbstractModel
end


struct MixedModel <: AbstractModel
   items ::Array{AbstractModel, 1}
end


struct ChoiceGroup <: AbstractModel
   items ::Array{AbstractModel, 1}
end


struct SequenceGroup <: AbstractModel
   items ::Array{AbstractModel, 1}
end


struct OneOrMore <: AbstractModel
   item ::AbstractModel
end


struct Optional <: AbstractModel
   item ::AbstractModel
end


struct ZeroOrMore <: AbstractModel
   item ::AbstractModel
end


# These are for attribute declarations.
#
struct EntityType
end


struct EntitiesType
end


struct EnumeratedNotationType
    names ::Array{String, 1}
end


struct EnumeratedType
    nmtokens ::Array{String, 1}
end


struct IDRefType
end


struct IDRefsType
end


struct IDType
end


struct NameTokenType
end


struct NameTokensType
end


struct StringType
end


struct DefaultValue
    is_fixed ::Bool
    value    ::Array{Union{DataContent, CharacterReference, EntityReferenceGeneral, EntityReferenceParameter}, 1}
end


struct Implied
end


struct Required
end


struct AttributeDeclaration
    is_recovery ::Bool # This basically is a synthesized attribute.
    name        ::String
    type        ::Union{EntityType, EntitiesType, EnumeratedNotationType, EnumeratedType, IDRefType,
                        IDRefsType, IDType, NameTokenType, NameTokensType, StringType}
    default     ::Union{DefaultValue, Implied, Required}
end


struct AttributeDeclarations
    is_recovery  ::Bool # This is a synthesized attribute, synthesized from the contained AttributeDeclaration children.
    name         ::String
    declarations ::Array{AttributeDeclaration, 1}
    location     ::Lexical.Location
end

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

CommentEnd(location) = CommentEnd(false, location)
CDATAMarkedSectionEnd(location) = CDATAMarkedSectionEnd(false, location)
ConditionalSectionStart(conditional, location) = ConditionalSectionStart(false, conditional, location)
ElementEnd(name, location) = ElementEnd(false, name, location)
ElementStart(name, attributes, location) = ElementStart(false, name, attributes, location)
ElementStart(is_empty, name, attributes, location) = ElementStart(false, is_empty, name, attributes, location)
DataContent(tokens::Array, location) = DataContent(stringify(tokens), location)
DataContent(value, location) = DataContent(value, false, location)


# These are needed for writing tests, because these types contain other structs inside an array.
#
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


function Base.:(==)(left::ElementDeclaration, right::ElementDeclaration)
    return (left.is_recovery      == right.is_recovery
            && left.name          == right.name
            && left.content_model == right.content_model
            && left.location      == right.location)
end


function Base.:(==)(left::MixedModel, right::MixedModel)
    return left.items == right.items
end


function Base.:(==)(left::OneOrMore, right::OneOrMore)
    return left.item == right.item
end


function Base.:(==)(left::Optional, right::Optional)
    return left.item == right.item
end


function Base.:(==)(left::ZeroOrMore, right::ZeroOrMore)
    return left.item == right.item
end


function Base.:(==)(left::ChoiceGroup, right::ChoiceGroup)
    return left.items == right.items
end


function Base.:(==)(left::SequenceGroup, right::SequenceGroup)
    return left.items == right.items
end


function Base.:(==)(left::AttributeDeclarations, right::AttributeDeclarations)
    return (left.is_recovery     == right.is_recovery
            && left.name         == right.name
            && left.declarations == right.declarations
            && left.location     == right.location)
end


function Base.:(==)(left::AttributeDeclaration, right::AttributeDeclaration)
    return (left.is_recovery == right.is_recovery
            && left.name     == right.name
            && left.type     == right.type
            && left.default  == right.default)
end


function Base.:(==)(left::EnumeratedType, right::EnumeratedType)
    return left.nmtokens == right.nmtokens
end


function Base.:(==)(left::EnumeratedNotationType, right::EnumeratedNotationType)
    return left.names == right.names
end


function Base.:(==)(left::DefaultValue, right::DefaultValue)
    return left.value == right.value
end


function attribute_declarations(mdo, tokens, channel)
    function attribute_declaration(element_name, tokens, channel)
        attribute_name = take!(tokens) # Collect the attribute name token that got us here ...
        consume_white_space!(tokens)   # ... but discard any following white space.

        ( attribute_type_recovery, attribute_type ) = collect_attribute_type(element_name, attribute_name, tokens, channel)
        consume_white_space!(tokens) # Discard any trailing white space.

        ( attribute_default_recovery, attribute_default ) = collect_attribute_default(element_name, attribute_name, tokens, channel)

        return AttributeDeclaration(any([ attribute_type_recovery, attribute_default_recovery ]),
                                    attribute_name.value, attribute_type, attribute_default)
    end

    function collect_attribute_default(element_name, attribute_name, tokens, channel)
        attribute_default = Implied()
        is_recovery       = false

        if is_reserved_name("#IMPLIED", tokens, channel)
            take!(tokens)

        elseif is_reserved_name("#REQUIRED", tokens, channel)
            take!(tokens)
            attribute_default = Required()

        else
            is_fixed = false
            if is_reserved_name("#FIXED", tokens, channel)
                is_fixed = true
                take!(tokens)
                consume_white_space!(tokens)
            end

            ( value_recovery, value ) = collect_attribute_value(attribute_name, tokens, channel)

            attribute_default = DefaultValue(is_fixed, value)
            is_recovery = any([ is_recovery, value_recovery ])
        end

        return ( is_recovery, attribute_default )
    end

    function collect_attribute_type(element_name, attribute_name, tokens, channel)
        attribute_type = StringType()
        is_recovery    = false

        if is_keyword("CDATA", tokens, channel)
            take!(tokens)

        elseif is_keyword("ENTITY", tokens, channel)
            take!(tokens)
            attribute_type = EntityType()

        elseif is_keyword("ENTITIES", tokens, channel)
            take!(tokens)
            attribute_type = EntitiesType()

        elseif is_keyword("IDREF", tokens, channel)
            take!(tokens)
            attribute_type = IDRefType()

        elseif is_keyword("IDREFS", tokens, channel)
            take!(tokens)
            attribute_type = IDRefsType()

        elseif is_keyword("ID", tokens, channel)
            take!(tokens)
            attribute_type = IDType()

        elseif is_keyword("NMTOKEN", tokens, channel)
            take!(tokens)
            attribute_type = NameTokenType()

        elseif is_keyword("NMTOKENS", tokens, channel)
            take!(tokens)
            attribute_type = NameTokensType()

        elseif is_keyword("NOTATION", tokens, channel)
            notation = take!(tokens)
            ws = consume_white_space!(tokens)

            if isnothing(ws)
                # See [1], § 3.3.1 ... the white space is required. This is really bogus, because the only thing that
                # can follow NOTATION in this position is an open parenthesis, so there would be no ambiguity in making
                # the white space optional
                #
                put!(channel, MarkupError("ERROR: White space is required following the 'NOTATION' keyword.",
                                          Lexical.location_of(notation)))
                is_recovery = true
            end

            if !is_token(Lexical.grpo, tokens)
                put!(channel, MarkupError("ERROR: Expecting '(' to open an enumerated notation attribute value.",
                                          Lexical.location_of(notation)))
                is_recovery = true
            end

            # Regardless of whether or not we saw GRPO, try parsing the group as a recovery mechanism.
            #
            ( names_recovery, names ) = collect_group(notation, is_name,
                                                      "ERROR: Expecting a name for an enumerated attribute value.",
                                                      tokens, channel)
            is_recovery = any([ is_recovery, names_recovery ])
            attribute_type = EnumeratedNotationType(names)

        elseif is_token(Lexical.grpo, tokens)
            ( nmtokens_recovery, nmtokens ) = collect_group(attribute_name, is_nmtoken,
                                                            "ERROR: Expecting a NMTOKEN for an enumerated attribute value.",
                                                            tokens, channel)
            is_recovery = any([ is_recovery, nmtokens_recovery ])
            attribute_type = EnumeratedType(nmtokens)

        else
            put!(channel, MarkupError("ERROR: Expecting an attribute type.", Lexical.location_of(attribute_name)))
        end

        return ( is_recovery, attribute_type )
    end

    function collect_group(token, matcher, message, tokens, channel)
        # Careful here ... we're called whether or not the GRPO was present. So only consume it if it's there.
        #
        if is_token(Lexical.grpo, tokens)
            grpo = take!(tokens)
            consume_white_space!(tokens)
        end

        items = Array{String, 1}()
        is_recovery = false

        while true
            if matcher(tokens)
                push!(items, take!(tokens).value)
                consume_white_space!(tokens)

            elseif is_token(Lexical.or, tokens) || is_token(Lexical.grpc, tokens)
                # Leave the token there ... we'll consume it below.
                #
                put!(channel, MarkupError(message, Lexical.location_of(token)))
                is_recovery = true

            else
                put!(channel, MarkupError(message, Lexical.location_of(token)))
                is_recovery = true
                take!(tokens) # Drop the token and try recovering.
                consume_white_space!(tokens)
            end

            if is_token(Lexical.or, tokens)
                take!(tokens)
                consume_white_space!(tokens)

            elseif is_token(Lexical.grpc, tokens)
                take!(tokens)
                consume_white_space!(tokens)
                break

            elseif matcher(tokens)
                put!(channel, MarkupError("ERROR: Expecting '|' between items in an enumerated attribute value.",
                                          Lexical.location_of(token)))
                is_recovery = true

            else
                put!(channel, MarkupError("ERROR: Expecting '|' or ')'.", Lexical.location_of(token)))
                is_recovery = true
                break
            end
        end

        return ( is_recovery, items )
    end

    attlist = take!(tokens) # Consume the ATTLIST keyword that got us here.
    ws      = consume_white_space!(tokens)

    is_recovery = false

    if isnothing(ws)
        # See [1], § 3.3 ... the white space is required.
        #
        put!(channel, MarkupError("ERROR: White space is required following the 'ATTLIST' keyword.", Lexical.location_of(attlist)))
        is_recovery = true
    end

    if is_name(tokens)
        element_name = take!(tokens)

        attribute_declarations = Array{AttributeDeclaration, 1}()

        while true
            if is_token(Lexical.ws, tokens)
                consume_white_space!(tokens)

                if is_name(tokens)
                    push!(attribute_declarations, attribute_declaration(element_name, tokens, channel))

                else
                    break
                end

            else
                break
            end
        end

        if is_token(Lexical.tagc, tokens)
            take!(tokens)

        else
            is_recovery = true
            put!(channel, MarkupError("ERROR: Expecting '>' to end an attribute list declaration.",
                                      Lexical.location_of(element_name)))
        end

        is_recovery = any(vcat(is_recovery, map(declaration -> declaration.is_recovery, attribute_declarations)))

        put!(channel, AttributeDeclarations(is_recovery, element_name.value, attribute_declarations, Lexical.location_of(mdo)))

    else
        put!(channel, MarkupError("ERROR: Expecting an element name.", Lexical.location_of(attlist)))
    end
end


function cdata_marked_section(mdo, dso, tokens, channel)
    text = take!(tokens) # Consume the CDATA keyword that got us here.

    ws = consume_white_space!(tokens)
    if !isnothing(ws)
        # Discard the white space ... there isn't much we can do with it.
        #
        put!(channel, MarkupError("ERROR: White space is not allowed after the 'CDATA' keyword.", Lexical.location_of(text)))
    end

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
                    put!(channel, MarkupError("ERROR: Expecting '>' to end a CDATA marked section.", Lexical.location_of(msc)))
                    put!(channel, CDATAMarkedSectionEnd(true, Lexical.location_of(msc)))
                    break
                end

            elseif is_eoi(tokens)
                put!(channel, DataContent(consumed, locations_of(mdo, consumed)[:head]))
                put!(channel, MarkupError("ERROR: Expecting ']]>' to end a CDATA marked section.",
                                          locations_of(mdo, consumed)[:tail]))
                put!(channel, CDATAMarkedSectionEnd(true, locations_of(mdo, consumed)[:tail]))
                break

            else
                push!(consumed, take!(tokens))
            end
        end

    else
        put!(channel, MarkupError("ERROR: Expecting '[' to open a CDATA marked section.", Lexical.location_of(text)))
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
                put!(channel, MarkupError("ERROR: '--' is not allowed inside a comment.", locations_of(com, consumed)[:tail]))
                put!(channel, CommentEnd(true, locations_of(com, consumed)[:tail]))
                break
            end

        elseif is_eoi(tokens)
            put!(channel, DataContent(consumed, locations_of(com, consumed)[:head]))
            put!(channel, MarkupError("ERROR: Expecting '-->' to end a comment.", locations_of(com, consumed)[:tail]))
            put!(channel, CommentEnd(true, locations_of(com, consumed)[:tail]))
            break

        else
            push!(consumed, take!(tokens))
        end
    end
end


function conditional_marked_section(mdo, dso, conditional, tokens, channel)
    if is_token(Lexical.dso, tokens)
        is_recovery(string::String) = !(all(map(isuppercase, collect(string))))
        is_recovery(_) = false

        take!(tokens) # Discard the DSO token that follows the conditional ... we don't need it.

        put!(channel, ConditionalSectionStart(is_recovery(conditional), conditional, Lexical.location_of(mdo)))

    else
        # It would be more accurate to use the location of the conditional here, but it isn't necessarily a token ... it
        # could be a properly-parsed parameter entity reference.
        #
        put!(channel, MarkupError("ERROR: Expecting '[' to open a conditional marked section.", Lexical.location_of(mdo)))
        put!(channel, ConditionalSectionStart(true, conditional, Lexical.location_of(mdo)))
    end
end


function document_type_declaration(mdo, tokens, channel)
    doctype = take!(tokens)      # Consume the DOCTYPE keyword that got us here ...
    consume_white_space!(tokens) # ... but discard any following white space.

    if is_name(tokens)
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
            put!(channel, MarkupError("ERROR: Expecting '>' to end a document type declaration.", Lexical.location_of(root)))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting a root element name.", Lexical.location_of(doctype)))
    end
end


function element_declaration(mdo, tokens, channel)
    element = take!(tokens) # Consume the ELEMENT keyword that got us here.
    ws = consume_white_space!(tokens)

    is_recovery = false

    if isnothing(ws)
        # See [1], § 3.2 ... the white space is required.
        #
        put!(channel, MarkupError("ERROR: White space is required following the 'ELEMENT' keyword.", Lexical.location_of(element)))
        is_recovery = true
    end

    if is_name(tokens)
        element_name = take!(tokens)
        ws = consume_white_space!(tokens)

        if isnothing(ws)
            # See [1], § 3.2 ... the white space is required. This is a bit lame ... the white space wouldn't be needed
            # to disambiguate in some cases (e.g., if the content model begins with a parenthesis), but ... well
            # ... whatever.
            #
            put!(channel, MarkupError("ERROR: White space is required following an element name.",
                                      Lexical.location_of(element_name)))
            is_recovery = true
        end

        content_model = AnyModel()

        if is_keyword("ANY", tokens, channel)
            take!(tokens)
            content_model = AnyModel()

        elseif is_keyword("EMPTY", tokens, channel)
            take!(tokens)
            content_model = EmptyModel()

        elseif is_token(Lexical.grpo, tokens)
            grpo = take!(tokens)
            consume_white_space!(tokens)

            if is_reserved_name("#PCDATA", tokens, channel)
                take!(tokens)
                consume_white_space!(tokens)

                ( content_model_recovery, items ) = collect_mixed_content_model(tokens, channel)
                is_recovery = is_recovery || content_model_recovery

                if is_token(Lexical.grpc, tokens)
                    take!(tokens)

                    if is_token(Lexical.rep, tokens)
                        take!(tokens)

                    elseif length(items) > 0
                        # The trailing '*' is only required if element names were encountered while parsing the content
                        # model. Really. See § 3.2.2, the first branch of production [51].
                        #
                        put!(channel, MarkupError("ERROR: Expecting '*' to end a mixed content model.",
                                                  Lexical.location_of(element_name)))
                        is_recovery = true
                    end

                else
                    put!(channel, MarkupError("ERROR: Expecting ')*' to end a mixed content model.",
                                              Lexical.location_of(element_name)))
                    is_recovery = true
                end

                content_model = MixedModel(items)

            else
                ( group_recovery, content_model ) = collect_content_model_group(grpo, tokens, channel)
                is_recovery = is_recovery || group_recovery

                if isnothing(content_model)
                    content_model = AnyModel()

                else
                    if is_token(Lexical.grpc, tokens)
                        take!(tokens)
                        consume_white_space!(tokens)

                    else
                        consume_white_space!(tokens)
                        put!(channel, MarkupError("ERROR: Expecting ')' to end a content model group.", Lexical.location_of(grpo)))
                        is_recovery = true
                    end

                    content_model = collect_occurrence_indicator(content_model, tokens)
                end
            end

        else
            put!(channel, MarkupError("ERROR: Expecting 'ANY', 'EMPTY', or '(' to open a content model.",
                                      Lexical.location_of(element)))
            is_recovery = true
        end

        consume_white_space!(tokens)

        if is_token(Lexical.tagc, tokens)
            take!(tokens)
            put!(channel, ElementDeclaration(is_recovery, element_name.value, content_model, Lexical.location_of(mdo)))

        else
            take!(tokens)
            put!(channel, MarkupError("ERROR: Expecting '>' to end an element declaration.", Lexical.location_of(element_name)))
            put!(channel, ElementDeclaration(true, element_name.value, content_model, Lexical.location_of(element)))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting an element name.", Lexical.location_of(element)))
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
            put!(channel, MarkupError("ERROR: Expecting '>' to end an element close tag.", Lexical.location_of(name)))
            put!(channel, ElementEnd(true, name.value, Lexical.location_of(name)))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting an element name.", Lexical.location_of(etago)))
    end
end


function element_start(tokens, channel)
    stago = take!(tokens) # Consume the STAGO that got us here.

    if is_name(tokens)
        name = take!(tokens)
        attributes = collect_attributes(tokens, channel) # We should really flip the is_recovery flag on the
                                                         # ElementStart if any of the attributes contain a MarkupError.
        consume_white_space!(tokens)

        if is_token(Lexical.net, tokens)
            take!(tokens)
            if is_token(Lexical.tagc, tokens)
                take!(tokens)
                put!(channel, ElementStart(true, name.value, attributes, Lexical.location_of(name)))
                put!(channel, ElementEnd(name.value, Lexical.location_of(name)))

            else
                put!(channel, ElementStart(true, true, name.value, attributes, Lexical.location_of(name)))
                put!(channel, MarkupError("ERROR: Expecting '>' to end an element open tag.", Lexical.location_of(name)))
                put!(channel, ElementEnd(true, name.value, Lexical.location_of(name)))
            end

        elseif is_token(Lexical.tagc, tokens)
            take!(tokens)
            put!(channel, ElementStart(name.value, attributes, Lexical.location_of(name)))

        else
            put!(channel, ElementStart(true, false, name.value, attributes, Lexical.location_of(name)))
            put!(channel, MarkupError("ERROR: Expecting '>' to end an element open tag.", Lexical.location_of(name)))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting an element name.", Lexical.location_of(stago)))
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

                if is_name(tokens)
                    ndata_name = take!(tokens)

                    return ( external_identifier = external_identifier, entity_value = nothing, ndata_name =  ndata_name )

                else
                    put!(channel, MarkupError("ERROR: Expecting a notation name.", Lexical.location_of(entity_name)))

                    return ( external_identifier = external_identifier, entity_value = nothing, ndata_name = nothing )
                end

            else
                return ( external_identifier = external_identifier, entity_value = nothing, ndata_name = nothing )
            end
        end
    end


    entity = take!(tokens) # Consume the ENTITY keyword that got us here.
    ws = consume_white_space!(tokens)

    if isnothing(ws)
        # See [1], § 4.2 ... the white space is required.
        #
        put!(channel, MarkupError("ERROR: White space is required following the 'ENTITY' keyword.", Lexical.location_of(entity)))
    end

    is_parameter_entity = is_token(Lexical.pero, tokens)
    if is_parameter_entity
        pero = take!(tokens)
        ws = consume_white_space!(tokens)

        if isnothing(ws)
            # See [1], § 4.2 ... the white space is required. This one is pretty lame, but it is what it is.
            #
            put!(channel, MarkupError("ERROR: White space is required following '%'.", Lexical.location_of(pero)))
        end
    end

    if is_name(tokens)
        entity_name = take!(tokens)
        ws = consume_white_space!(tokens)

        if isnothing(ws)
            # See [1], § 4.2, productions [71] and [72] ... the white space is required.
            #
            put!(channel, MarkupError("ERROR: White space is required between the entity name and the entity value.",
                                      Lexical.location_of(entity)))
        end

        ( external_identifier, entity_value, ndata_name ) = collect_entity_definition(entity_name, tokens, channel)
        consume_white_space!(tokens)

        if is_parameter_entity && !isnothing(ndata_name)
            put!(channel, MarkupError("ERROR: A parameter entity cannot have a notation.", Lexical.location_of(entity_name)))
            ndata_name = nothing
        end

        if is_token(Lexical.tagc, tokens)
            tagc = take!(tokens)

        else
            put!(channel, MarkupError("ERROR: Expecting '>' to end an entity declaration.", Lexical.location_of(entity_name)))
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
        put!(channel, MarkupError("ERROR: Expecting an entity name.", Lexical.location_of(entity)))
    end
end


function events(state::Lexical.State)
    function eventified(channel::Channel)
        tokens = Lexical.tokens(state)

        while true
            if is_token(Lexical.mdo, tokens)
                markup_declaration(tokens, channel)

            elseif is_token(Lexical.cro, tokens)
                put!(channel, collect_character_reference(tokens, channel))

            elseif is_token(Lexical.ero, tokens)
                put!(channel, collect_entity_reference(tokens, channel))

            elseif is_token(Lexical.pero, tokens)
                put!(channel, collect_parameter_entity_reference(tokens, channel))

            elseif is_token(Lexical.pio, tokens)
                processing_instruction(tokens, channel)

            elseif is_token(Lexical.stago, tokens)
                element_start(tokens, channel)

            elseif is_token(Lexical.etago, tokens)
                element_end(tokens, channel)

            elseif is_eoi(tokens)
                break

            elseif is_token(Lexical.msc, tokens)
                msc = take!(tokens) # We're only holding on to this for the sake of its location.

                if is_token(Lexical.tagc, tokens)
                    take!(tokens) # We don't need to hold on to this.
                    push!(channel, ConditionalSectionEnd(Lexical.location_of(msc)))

                else
                    push!(channel, DataContent(msc.value, Lexical.location_of(msc)))
                end

            else
                if is_token(Lexical.ws, tokens)
                    ws = consume_white_space!(tokens)
                    push!(channel, DataContent(ws.value, true, Lexical.location_of(ws)))

                elseif is_token(Lexical.illegal, tokens)
                    token = take!(tokens)
                    put!(channel, MarkupError("ERROR: Encountered the illegal character \'"
                                              * "#x" * string(Int(token.value[1]), base = 16) * "\'."
                                              * " It will be discarded.", Lexical.location_of(token)))

                else
                    token = take!(tokens)
                    push!(channel, DataContent(token.value, Lexical.location_of(token)))
                end
            end
        end
    end

    return Channel(eventified; csize = 1)
end


function marked_section(mdo, tokens, channel)
    dso = take!(tokens) # Consume the DSO that got us here.

    leading = consume_white_space!(tokens) # There might be white space here. It is allowed for conditional sections,
                                           # but disallowed for CDATA sections. For some reason.

    if is_keyword("CDATA", tokens, channel)
        if !isnothing(leading)
            # Discard the white space ... there isn't much we can do with it.
            #
            put!(channel, MarkupError("ERROR: White space is not allowed before the 'CDATA' keyword.", Lexical.location_of(dso)))
        end

        cdata_marked_section(mdo, dso, tokens, channel)

    elseif is_keyword("IGNORE", tokens, channel) || is_keyword("INCLUDE", tokens, channel)
        conditional = take!(tokens)  # Consume the IGNORE/INCLUDE keyword ...
        consume_white_space!(tokens) # ... and discard any trailing white space.

        conditional_marked_section(mdo, dso, conditional.value, tokens, channel)

    elseif is_token(Lexical.pero, tokens)
        conditional = collect_parameter_entity_reference(tokens, channel) # Consume the parameter entity reference ...
        consume_white_space!(tokens)                                      # ... and discard any trailing white space.

        conditional_marked_section(mdo, dso, conditional, tokens, channel)

    else
        put!(channel, MarkupError("ERROR: Expecting the start of a CDATA or conditional marked section.", Lexical.location_of(dso)))
        if !isnothing(leading)
            put!(channel, DataContent(leading.value, true, locations_of(mdo, [ dso ])[:head]))
        end
    end
end


function markup_declaration(tokens, channel)
    mdo = take!(tokens) # Consume the MDO token that got us here.

    if is_token(Lexical.dso, tokens)
        marked_section(mdo, tokens, channel)

    elseif is_token(Lexical.com, tokens)
        comment(mdo, tokens, channel)

    elseif is_keyword("ATTLIST", tokens, channel)
        attribute_declarations(mdo, tokens, channel)

    elseif is_keyword("DOCTYPE", tokens, channel)
        document_type_declaration(mdo, tokens, channel)

    elseif is_keyword("ELEMENT", tokens, channel)
        element_declaration(mdo, tokens, channel)

    elseif is_keyword("ENTITY", tokens, channel)
        entity_declaration(mdo, tokens, channel)

    elseif is_keyword("NOTATION", tokens, channel)
        notation_declaration(mdo, tokens, channel)

    else
        if is_keyword("sgml", tokens, channel)
            put!(channel, MarkupError("ERROR: The keyword 'SGML' is not available in XML.", Lexical.location_of(mdo)))

        elseif is_keyword("shortref", tokens, channel)
            put!(channel, MarkupError("ERROR: The keyword 'SHORTREF' is not available in XML.", Lexical.location_of(mdo)))

        elseif is_keyword("usemap", tokens, channel)
            put!(channel, MarkupError("ERROR: The keyword 'USEMAP' is not available in XML.", Lexical.location_of(mdo)))

        else
            put!(channel, MarkupError("ERROR: Expecting the start of a markup declaration.", Lexical.location_of(mdo)))
        end
    end
end


function notation_declaration(mdo, tokens, channel)
    notation = take!(tokens)      # Consume the NOTATION keyword that got us here ...
    consume_white_space!(tokens)  # ... but discard any following white space.

    if is_name(tokens)
        notation_name = take!(tokens)
        consume_white_space!(tokens)

        external_identifier = collect_external_identifier(mdo, tokens, false, channel)
        consume_white_space!(tokens)

        if isnothing(external_identifier)
            put!(channel, MarkupError("ERROR: A notation declaration must specify an external identifier.",
                                      Lexical.location_of(notation_name)))
        end

        if is_token(Lexical.tagc, tokens)
            tagc = take!(tokens)

        else
            put!(channel, MarkupError("ERROR: Expecting '>' to end a notation declaration.", Lexical.location_of(notation_name)))
        end
        put!(channel, NotationDeclaration(notation_name.value, external_identifier, Lexical.location_of(notation)))

    else
        put!(channel, MarkupError("ERROR: Expecting a notation name.", Lexical.location_of(notation)))
    end
end


function processing_instruction(tokens, channel)
    pio = take!(tokens) # Consume the PIO token that got us here.

    if is_name(tokens)
        if is_keyword("XML", tokens, false, channel)
            put!(channel, MarkupError("ERROR: A PI target cannot be any case variant of 'XML'.", Lexical.location_of(pio)))
        end

        target = take!(tokens) # See [1], § 2.6 ... the PI target is required.

        consume_white_space!(tokens) # Discard any white space. Again, see [1], § 2.6 ... the white space is required,
                                     # so it's syntax and doesn't belong in the PI value.

        consumed = Array{Lexical.Token, 1}()

        while true
            if is_token(Lexical.opt, tokens)
                opt = take!(tokens)

                if is_token(Lexical.tagc, tokens)
                    take!(tokens)
                    put!(channel, ProcessingInstruction(target.value, stringify(consumed), Lexical.location_of(pio)))
                    break

                else
                    push!(consumed, opt)
                end

            elseif is_eoi(tokens)
                put!(channel, MarkupError("ERROR: Expecting '?>' to end a processing instruction.",
                                          locations_of(pio, vcat([ target ], consumed))[:tail]))
                break

            else
                push!(consumed, take!(tokens))
            end
        end

    else
        put!(channel, MarkupError("ERROR: Expecting a PI target.", Lexical.location_of(pio)))
    end
end

# ----------------------------------------
# SMALL PARSERS
#
# Small parsers return the event rather than emitting it to a channel. They can, however, emit markup errors.
# ----------------------------------------

function collect_attribute_value(start, tokens, channel)
    value       = Array{Union{DataContent, CharacterReference, EntityReferenceGeneral, EntityReferenceParameter}, 1}()
    is_recovery = false

    if is_token(Lexical.lit, tokens) || is_token(Lexical.lita, tokens)
        delimiter = take!(tokens)

        while true
            if is_eoi(tokens)
                put!(channel, MarkupError("ERROR: Expecting the remainder of an attribute value.", Lexical.location_of(start)))
                is_recovery = true
                break

            elseif fetch(tokens).token_type == delimiter.token_type
                take!(tokens)
                break

            elseif is_token(Lexical.cro, tokens)
                push!(value, collect_character_reference(tokens, channel))

            elseif is_token(Lexical.ero, tokens)
                push!(value, collect_entity_reference(tokens, channel, true))

            elseif is_token(Lexical.stago, tokens)
                stago = take!(tokens)
                put!(channel, MarkupError("ERROR: A '<' must be escaped inside an attribute value.", Lexical.location_of(stago)))
                is_recovery = true

            elseif is_token(Lexical.ws, tokens)
                ws = consume_white_space!(tokens)
                push!(value, DataContent(ws.value, true, Lexical.location_of(ws)))

            else
                data_content = take!(tokens)
                push!(value, DataContent(data_content.value, Lexical.location_of(data_content)))
            end
        end

    else
        put!(channel, MarkupError("ERROR: Expecting a quoted attribute value.", Lexical.location_of(start)))
        is_recovery = true
    end

    return ( is_recovery, value )
end


function collect_attributes(tokens, channel)
    function collect_attribute(tokens, channel)
        name = take!(tokens)         # Collect the attribute name token that got us here ...
        consume_white_space!(tokens) # ... but discard any following white space.

        value = Array{Union{DataContent, CharacterReference, EntityReferenceGeneral, EntityReferenceParameter}, 1}()

        if is_token(Lexical.vi, tokens)
            vi = take!(tokens)
            consume_white_space!(tokens)
            ( _, value ) = collect_attribute_value(vi, tokens, channel)

        else
            put!(channel, MarkupError("ERROR: Expecting '=' after an attribute name.", Lexical.location_of(name)))
        end

        return AttributeSpecification(name.value, value, Lexical.location_of(name))
    end


    attributes = Array{AttributeSpecification, 1}()

    while true
        if is_token(Lexical.ws, tokens)
            consume_white_space!(tokens)

            if is_name(tokens)
                push!(attributes, collect_attribute(tokens, channel))

            else
                break
            end

        else
            break
        end
    end

    return attributes
end


function collect_character_reference(tokens, channel)
    cro = take!(tokens) # Consume the CRO token that got us here.

    if is_token(Lexical.text, tokens)
        value = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            return CharacterReference(value.value, Lexical.location_of(cro))

        else
            put!(channel, MarkupError("ERROR: Expecting ';' to end a character reference.", Lexical.location_of(value)))

            return DataContent([ cro, value ], Lexical.location_of(value))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting a character value.", Lexical.location_of(cro)))

        return DataContent(cro.value, Lexical.location_of(cro))
    end
end


function collect_content_model_group(grpo, tokens, channel)
    function collect_content_model_group_items(grpo, separator, tokens, channel)
        # By the time we're called, we've seen one group item and the separator (which has been consumed). See See [1],
        # § 3.2.1 ... we require another item.
        #
        is_recovery = false
        items       = Array{AbstractModel, 1}()

        while true
            ( item_recovery, item ) = collect_content_model_group_item(grpo, tokens, channel)
            is_recovery = is_recovery || item_recovery

            if isnothing(item)
                break

            else
                push!(items, item)
            end

            if is_token(separator.token_type, tokens)
                take!(tokens)
                consume_white_space!(tokens)

            elseif is_token(Lexical.or, tokens) || is_token(Lexical.seq, tokens)
                s = take!(tokens)
                consume_white_space!(tokens)
                put!(channel, MarkupError("ERROR: '|' and ',' cannot be used in the same content group.", Lexical.location_of(s)))
                is_recovery = true

            elseif is_token(Lexical.grpc, tokens)
                break

            else
                put!(channel, MarkupError("ERROR: Expecting '" * separator.value * "'.", Lexical.location_of(grpo)))
                is_recovery = true
            end
        end

        return ( is_recovery, items )
    end


    ( is_recovery, first_item ) = collect_content_model_group_item(grpo, tokens, channel)

    if isnothing(first_item)
        return ( true, first_item )
    end

    if is_token(Lexical.or, tokens) || is_token(Lexical.seq, tokens)
        separator = take!(tokens)
        consume_white_space!(tokens)

        ( group_recovery, items ) = collect_content_model_group_items(grpo, separator, tokens, channel)
        is_recovery = is_recovery || group_recovery

        pushfirst!(items, first_item)

        if separator.token_type == Lexical.or
            return ( is_recovery, ChoiceGroup(items) )

        else
            return ( is_recovery, SequenceGroup(items) )
        end

    else
        return ( false, first_item )
    end
end


function collect_content_model_group_item(grpo, tokens, channel)
    if is_name(tokens)
        name = take!(tokens)
        consume_white_space!(tokens)

        return ( false, ElementModel(name.value) )

    elseif is_token(Lexical.grpo, tokens)
        grpo = take!(tokens)
        consume_white_space!(tokens)

        ( is_recovery, item ) = collect_content_model_group(grpo, tokens, channel)

        if is_token(Lexical.grpc, tokens)
            take!(tokens)
            consume_white_space!(tokens)

        else
            take!(tokens)
            consume_white_space!(tokens)
            put!(channel, MarkupError("ERROR: Expecting ')' to end a content model group.", Lexical.location_of(grpo)))
            is_recovery = true
        end

        item = collect_occurrence_indicator(item, tokens)

        consume_white_space!(tokens) # In case we saw an occurrence indicator.

        return ( is_recovery, item )

    else
        put!(channel, MarkupError("ERROR: Expecting an element name or '('.", Lexical.location_of(grpo)))

        return ( true, nothing )
    end
end


function collect_entity_reference(tokens, channel, in_attribute = false)
    ero = take!(tokens) # Consume the ERO token that got us here.

    if is_name(tokens)
        name = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            return EntityReferenceGeneral(name.value, Lexical.location_of(ero))

        else
            put!(channel, MarkupError("ERROR: Expecting ';' to end an entity reference.", Lexical.location_of(name)))

            # Let's assume we saw the REFC.
            #
            return EntityReferenceGeneral(name.value, Lexical.location_of(ero))
        end

    else
        if in_attribute
            put!(channel, MarkupError("ERROR: A '&' must be escaped inside an attribute value.", Lexical.location_of(ero)))

        else
            put!(channel, MarkupError("ERROR: Expecting an entity name.", Lexical.location_of(ero)))
        end

        return DataContent([ ero ], Lexical.location_of(ero))
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

            elseif is_strict || is_token(Lexical.lit, tokens) || is_token(Lexical.lita, tokens)
                # In strict mode, we always emit a markup if there is no white space between the public and system
                # identifiers. In non-strict mode, we only output a markup error if it appears that we're looking at a
                # system identifier.
                #
                put!(channel, MarkupError("ERROR: Expecting white space following a public identifier.",
                                          locations_of(mdo, public_identifier)[:tail]))
            end

            system_identifier = collect_string(locations_of(mdo, public_identifier)[:tail], tokens, is_strict, channel)

            if isnothing(system_identifier)
                if is_strict
                    put!(channel, MarkupError("ERROR: Expecting a system identifier following a public identifier.",
                                              locations_of(mdo, public_identifier)[:tail]))
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


function collect_mixed_content_model(tokens, channel)
    is_recovery = false
    items       = Array{AbstractModel, 1}()

    while true
        if is_token(Lexical.or, tokens)
            or = take!(tokens)
            consume_white_space!(tokens)

            if is_name(tokens)
                name = take!(tokens)
                consume_white_space!(tokens)
                push!(items, ElementModel(name.value))

            elseif is_reserved_name("#PCDATA", tokens, channel)
                put!(channel, MarkupError("ERROR: '#PCDATA' can only appear at the start of a mixed content model.",
                                          Lexical.location_of(or)))
                is_recovery = true
                take!(tokens)
                consume_white_space!(tokens)

            elseif is_token(Lexical.or, tokens)
                # Don't break in this case ... maybe we can keep parsing and make sense of this. Also, don't
                # consume it ... we're going to consume it as soon as we wrap around, on the next iteration.
                #
                put!(channel, MarkupError("ERROR: Expecting an element name.", Lexical.location_of(or)))
                is_recovery = true

            else
                put!(channel, MarkupError("ERROR: Expecting an element name.", Lexical.location_of(or)))
                is_recovery = true
                break
            end

        elseif is_name(tokens)
            name = take!(tokens)
            consume_white_space!(tokens)
            put!(channel, MarkupError("ERROR: Items in a mixed content model must be separated by '|'.", Lexical.location_of(name)))
            is_recovery = true
            push!(items, ElementModel(name.value))

        elseif is_reserved_name("#PCDATA", tokens, channel)
            t = take!(tokens)
            put!(channel, MarkupError("ERROR: '#PCDATA' can only appear at the start of a mixed content model.",
                                      Lexical.location_of(t)))
            is_recovery = true
            consume_white_space!(tokens)

        else
            break
        end
    end

    return ( is_recovery, items )
end


function collect_occurrence_indicator(content_model, tokens)
    if is_token(Lexical.opt, tokens)
        take!(tokens)

        return Optional(content_model)

    elseif is_token(Lexical.rep, tokens)
        take!(tokens)

        return ZeroOrMore(content_model)

    elseif is_token(Lexical.plus, tokens)
        take!(tokens)

        return OneOrMore(content_model)

    else
        return content_model
    end
end


function collect_parameter_entity_reference(tokens, channel)
    pero = take!(tokens) # Consume the PERO token that got us here.

    if is_name(tokens)
        name = take!(tokens)
        if is_token(Lexical.refc, tokens)
            refc = take!(tokens)

            return EntityReferenceParameter(name.value, Lexical.location_of(pero))

        else
            put!(channel, MarkupError("ERROR: Expecting ';' to end a parameter entity reference.", Lexical.location_of(name)))

            # Let's assume we saw the REFC.
            #
            return EntityReferenceParameter(name.value, Lexical.location_of(pero))
        end

    else
        put!(channel, MarkupError("ERROR: Expecting a parameter entity name.", Lexical.location_of(pero)))

        return DataContent([ pero ], Lexical.location_of(pero))
    end
end


function collect_string(location, tokens, channel)
    return collect_string(location, tokens, true, channel)
end


function collect_string(location, tokens, is_strict, channel)
    consume_white_space!(tokens)

    if is_token(Lexical.lit, tokens) || is_token(Lexical.lita, tokens)
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
            put!(channel, MarkupError("ERROR: Expecting a quoted string.", location))
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
                # All keywords in XML are uppercased. The only thing that comes close to being an exception is 'XML',
                # where all case variants are reserved.
                #
                put!(channel, MarkupError("ERROR: The keyword '" * text.value * "' must be uppercased.", Lexical.location_of(text)))
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
    if is_token(Lexical.text, tokens)
        text = fetch(tokens)

        return all(vcat(is_name_start_char(text.value[1]), map(is_name_char, collect(text.value[nextind(text.value, 1):end]))))

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


function is_nmtoken(tokens)
    if is_token(Lexical.text, tokens)
        text = fetch(tokens)

        return all(map(is_name_char, collect(text.value)))

    elseif is_token(Lexical.com, tokens)
        # This makes no sense to me, but it is definitely allowed by the specification: see § 2.3, productions [4a] and
        # [7], which combined definitely allow "--" (i.e., COM) as a NMTOKEN.
        #
        return true

    else
        return false
    end
end


function is_reserved_name(keyword, tokens, channel)
    if length(keyword) > 1 && (keyword[1] == '#') && is_token(Lexical.text, tokens)
        return is_keyword(keyword, tokens, channel)

    else
        return false
    end
end


function is_token(token_type, tokens)
    if isready(tokens) || isopen(tokens)
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


function stringify(tokens)
    return join(map(token -> token.value, tokens), "")
end

end
