using NativeXML
using Test

using NativeXML.Lexical
using NativeXML.Events

tests = [ "lexical", "events", ]

for test ∈ tests
    include("$test.jl")
end


