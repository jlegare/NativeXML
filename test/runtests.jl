using NativeXML
using Test

tests = [ "lexical", ]

for test ∈ tests
    include("$test.jl")
end


