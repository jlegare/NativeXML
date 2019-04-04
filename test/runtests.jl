using NativeXML
using Test

using NativeXML.Lexical
using NativeXML.Events

tests = [ "lexical", 
          "events/basic", "events/cdata_ms", "events/comments",
          "events/element_end",
          "events/entities", "events/pis", ]

for test ∈ tests
    include("$test.jl")
end


