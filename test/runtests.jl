using NativeXML
using Test

using NativeXML.Lexical

tests = [ "lexical", ]

for test ∈ tests
    include("$test.jl")
end


