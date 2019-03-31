using NativeXML
using Test

using NativeXML.Lexical
using NativeXML.Events

tests = [ "lexical", "events/entities", ]

for test ∈ tests
    include("$test.jl")
end


