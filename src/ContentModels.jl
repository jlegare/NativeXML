module ContentModels

import Base.==

# ----------------------------------------
# EXPORTED INTERFACE
# ----------------------------------------

# ----------------------------------------
# TYPE DECLARATIONS
# ----------------------------------------

abstract type AbstractModel
end

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

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

# These are needed for writing tests, because these types contain other structs inside an array.
#
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

end
