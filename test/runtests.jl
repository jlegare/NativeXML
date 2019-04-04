using NativeXML
using Test

using NativeXML.Lexical
using NativeXML.Events

tests = [ "lexical", "events/basic", "events/entities", "events/pis", "events/comments", "events/element_end", ]

for test ∈ tests
    include("$test.jl")
end


