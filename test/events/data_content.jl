@testset "Events/Data Content" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    DC = E.DataContent

    @testset "Events/Data Content/Empty String" begin
        @test evaluate("") == [ ]
    end

    @testset "Events/Data Content/White Space" begin
        @test evaluate("\u20") == [ DC("\u20", true, L.Location("a buffer", -1)) ]
        @test evaluate(" ")    == [ DC(" ", true, L.Location("a buffer", -1)) ]

        @test evaluate("\u09")     == [ DC("\u09", true, L.Location("a buffer", -1)) ]
        @test evaluate("	") == [ DC("	", true, L.Location("a buffer", -1)) ]
        @test evaluate("\t")       == [ DC("\t", true, L.Location("a buffer", -1)) ]

        @test evaluate("\u0a") == [ DC("\u0a", true, L.Location("a buffer", -1)) ]
        @test evaluate("\u0d") == [ DC("\u0d", true, L.Location("a buffer", -1)) ]
        @test evaluate("\n")   == [ DC("\n", true, L.Location("a buffer", -1)) ]
        @test evaluate("\r")   == [ DC("\r", true, L.Location("a buffer", -1)) ]

        @test evaluate("	\n\r") == [ DC("	\n\r", true, L.Location("a buffer", -1)) ]
    end

    @testset "Events/Data Content/Data Content" begin
        @test evaluate("a")   == [ DC("a", false, L.Location("a buffer", -1)) ]
        @test evaluate("ab")  == [ DC("ab", false, L.Location("a buffer", -1)) ]
        @test evaluate("abc") == [ DC("abc", false, L.Location("a buffer", -1)) ]
        @test evaluate("é")   == [ DC("é", false, L.Location("a buffer", -1)) ]
        @test evaluate("aé")  == [ DC("aé", false, L.Location("a buffer", -1)) ]
        @test evaluate("éb")  == [ DC("éb", false, L.Location("a buffer", -1)) ]
        @test evaluate("aéb") == [ DC("aéb", false, L.Location("a buffer", -1)) ]
    end

    @testset "Events/Data Content/Mixed" begin
        @test evaluate("a ")   == [ DC("a", false, L.Location("a buffer", -1)),
                                    DC(" ", true, L.Location("a buffer", -1)) ]
        @test evaluate(" a")   == [ DC(" ", true, L.Location("a buffer", -1)),
                                    DC("a", false, L.Location("a buffer", -1)) ]
        @test (evaluate("Hello, World!")
               == [ DC("Hello", false, L.Location("a buffer", -1)),
                    DC(",", false, L.Location("a buffer", -1)),
                    DC(" ", true, L.Location("a buffer", -1)),
                    DC("World!", false, L.Location("a buffer", -1)), ])
    end
end
