@testset "Events/Data Content" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    @testset "Events/Data Content/Empty String" begin
        @test evaluate("") == [ ]
    end

    @testset "Events/Data Content/White Space" begin
        @test evaluate("\u20") == [ E.DataContent("\u20", true, L.Location("a buffer", -1)) ]
        @test evaluate(" ")    == [ E.DataContent(" ", true, L.Location("a buffer", -1)) ]

        @test evaluate("\u09")     == [ E.DataContent("\u09", true, L.Location("a buffer", -1)) ]
        @test evaluate("	") == [ E.DataContent("	", true, L.Location("a buffer", -1)) ]
        @test evaluate("\t")       == [ E.DataContent("\t", true, L.Location("a buffer", -1)) ]

        @test evaluate("\u0a") == [ E.DataContent("\u0a", true, L.Location("a buffer", -1)) ]
        @test evaluate("\u0d") == [ E.DataContent("\u0d", true, L.Location("a buffer", -1)) ]
        @test evaluate("\n")   == [ E.DataContent("\n", true, L.Location("a buffer", -1)) ]
        @test evaluate("\r")   == [ E.DataContent("\r", true, L.Location("a buffer", -1)) ]

        @test evaluate("	\n\r") == [ E.DataContent("	\n\r", true, L.Location("a buffer", -1)) ]
    end

    @testset "Events/Data Content/Data Content" begin
        @test evaluate("a")   == [ E.DataContent("a", false, L.Location("a buffer", -1)) ]
        @test evaluate("ab")  == [ E.DataContent("ab", false, L.Location("a buffer", -1)) ]
        @test evaluate("abc") == [ E.DataContent("abc", false, L.Location("a buffer", -1)) ]
        @test evaluate("é")   == [ E.DataContent("é", false, L.Location("a buffer", -1)) ]
        @test evaluate("aé")  == [ E.DataContent("aé", false, L.Location("a buffer", -1)) ]
        @test evaluate("éb")  == [ E.DataContent("éb", false, L.Location("a buffer", -1)) ]
        @test evaluate("aéb") == [ E.DataContent("aéb", false, L.Location("a buffer", -1)) ]
    end

    @testset "Events/Data Content/Mixed" begin
        @test evaluate("a ")   == [ E.DataContent("a", false, L.Location("a buffer", -1)),
                                    E.DataContent(" ", true, L.Location("a buffer", -1)) ]
        @test evaluate(" a")   == [ E.DataContent(" ", true, L.Location("a buffer", -1)),
                                    E.DataContent("a", false, L.Location("a buffer", -1)) ]
        @test (evaluate("Hello, World!")
               == [ E.DataContent("Hello", false, L.Location("a buffer", -1)),
                    E.DataContent(",", false, L.Location("a buffer", -1)),
                    E.DataContent(" ", true, L.Location("a buffer", -1)),
                    E.DataContent("World!", false, L.Location("a buffer", -1)), ])
    end
end
