module ContentModels

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


struct Optional <: AbstractModel
   item ::AbstractModel
end


struct ZeroOrMore <: AbstractModel
   item ::AbstractModel
end


struct OneOrMore <: AbstractModel
   item ::AbstractModel
end

end
