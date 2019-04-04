@testset "Events/Basic" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Basic/Empty String" begin
        @test collect(E.events(L.State(IOBuffer("")))) == [ ]
    end

    @testset "Events/Basic/White Space" begin
        @test collect(E.events(L.State(IOBuffer("\u20")))) == [ E.DataContent("\u20", true, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer(" "))))    == [ E.DataContent(" ", true, "a buffer", -1) ]

        @test collect(E.events(L.State(IOBuffer("\u09"))))    == [ E.DataContent("\u09", true, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("	")))) == [ E.DataContent("	", true, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("\t"))))      == [ E.DataContent("\t", true, "a buffer", -1) ]

        @test collect(E.events(L.State(IOBuffer("\u0a")))) == [ E.DataContent("\u0a", true, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("\u0d")))) == [ E.DataContent("\u0d", true, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("\n"))))   == [ E.DataContent("\n", true, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("\r"))))   == [ E.DataContent("\r", true, "a buffer", -1) ]

        @test collect(E.events(L.State(IOBuffer("	\n\r")))) == [ E.DataContent("	\n\r", true, "a buffer", -1) ]
    end

    @testset "Events/Basic/Data Content" begin
        @test collect(E.events(L.State(IOBuffer("a"))))   == [ E.DataContent("a", false, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("ab"))))  == [ E.DataContent("ab", false, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("abc")))) == [ E.DataContent("abc", false, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("é"))))   == [ E.DataContent("é", false, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("aé"))))  == [ E.DataContent("aé", false, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("éb"))))  == [ E.DataContent("éb", false, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("aéb")))) == [ E.DataContent("aéb", false, "a buffer", -1) ]
    end

    @testset "Events/Basic/Mixed White Space and Data Content" begin
        @test collect(E.events(L.State(IOBuffer("a "))))   == [ E.DataContent("a", false, "a buffer", -1),
                                                                E.DataContent(" ", true, "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer(" a"))))   == [ E.DataContent(" ", true, "a buffer", -1),
                                                                E.DataContent("a", false, "a buffer", -1) ]
        @test (collect(E.events(L.State(IOBuffer("Hello, World!")))) == [ E.DataContent("Hello", false, "a buffer", -1),
                                                                          E.DataContent(",", false, "a buffer", -1),
                                                                          E.DataContent(" ", true, "a buffer", -1),
                                                                          E.DataContent("World!", false, "a buffer", -1), ])
    end
end
