@testset "Events/Data Content" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Data Content/Empty String" begin
        @test collect(E.events(L.State(IOBuffer("")))) == [ ]
    end

    @testset "Events/Data Content/White Space" begin
        @test collect(E.events(L.State(IOBuffer("\u20")))) == [ E.DataContent("\u20", true, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer(" "))))    == [ E.DataContent(" ", true, L.Location("a buffer", -1)) ]

        @test collect(E.events(L.State(IOBuffer("\u09"))))    == [ E.DataContent("\u09", true, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("	")))) == [ E.DataContent("	", true, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("\t"))))      == [ E.DataContent("\t", true, L.Location("a buffer", -1)) ]

        @test collect(E.events(L.State(IOBuffer("\u0a")))) == [ E.DataContent("\u0a", true, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("\u0d")))) == [ E.DataContent("\u0d", true, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("\n"))))   == [ E.DataContent("\n", true, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("\r"))))   == [ E.DataContent("\r", true, L.Location("a buffer", -1)) ]

        @test collect(E.events(L.State(IOBuffer("	\n\r")))) == [ E.DataContent("	\n\r", true, L.Location("a buffer", -1)) ]
    end

    @testset "Events/Data Content/Data Content" begin
        @test collect(E.events(L.State(IOBuffer("a"))))   == [ E.DataContent("a", false, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("ab"))))  == [ E.DataContent("ab", false, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("abc")))) == [ E.DataContent("abc", false, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("é"))))   == [ E.DataContent("é", false, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("aé"))))  == [ E.DataContent("aé", false, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("éb"))))  == [ E.DataContent("éb", false, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("aéb")))) == [ E.DataContent("aéb", false, L.Location("a buffer", -1)) ]
    end

    @testset "Events/Data Content/Mixed" begin
        @test collect(E.events(L.State(IOBuffer("a "))))   == [ E.DataContent("a", false, L.Location("a buffer", -1)),
                                                                E.DataContent(" ", true, L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer(" a"))))   == [ E.DataContent(" ", true, L.Location("a buffer", -1)),
                                                                E.DataContent("a", false, L.Location("a buffer", -1)) ]
        @test (collect(E.events(L.State(IOBuffer("Hello, World!"))))
               == [ E.DataContent("Hello", false, L.Location("a buffer", -1)),
                    E.DataContent(",", false, L.Location("a buffer", -1)),
                    E.DataContent(" ", true, L.Location("a buffer", -1)),
                    E.DataContent("World!", false, L.Location("a buffer", -1)), ])
    end
end
