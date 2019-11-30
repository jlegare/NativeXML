using NativeXML
using Test

using NativeXML.Lexical
using NativeXML.Events

tests = [ "lexical",
          "events/basic", "events/cdata_ms", "events/comments", "events/doctype",
          "events/element_end", "events/element_start", "events/attributes",
          "events/entities", "events/entity_declaration", "events/pis", ]

for test ∈ tests
    include("$test.jl")
end


