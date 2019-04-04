using NativeXML
using Test

using NativeXML.Lexical
using NativeXML.Events

tests = [ "lexical", 
          "events/basic", "events/cdata_ms", "events/comments",
          "events/element_end", "events/element_start",
          "events/entities", "events/pis", ]

for test ∈ tests
    include("$test.jl")
end


