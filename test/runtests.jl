using NativeXML
using Test

using NativeXML.Lexical
using NativeXML.Events

tests = [ "lexical",
          "events/attributes", "events/cdata_ms", "events/comments", "events/conditional_section",
          "events/data_content", "events/doctype", "events/element_end", "events/element_start", "events/element_declarations",
          "events/entity_declarations", "events/entity_references",
          "events/markup_declarations", "events/miscellaneous", "events/notation_declarations", "events/pis", ]

for test ∈ tests
    include("$test.jl")
end


