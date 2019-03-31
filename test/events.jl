@testset "Events" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Empty String" begin
        @test collect(E.events(L.State(IOBuffer("")))) == [ ]
    end

    @testset "Events/Character References (Positive)" begin
        @test collect(E.events(L.State(IOBuffer("&#10;")))) == [ E.CharacterReference("10", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("&#xa;")))) == [ E.CharacterReference("xa", "a buffer", -1) ]

        @test collect(E.events(L.State(IOBuffer("&#10;&#xa;")))) == [ E.CharacterReference("10", "a buffer", -1),
                                                                      E.CharacterReference("xa", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("&#xa;&#10;")))) == [ E.CharacterReference("xa", "a buffer", -1),
                                                                      E.CharacterReference("10", "a buffer", -1) ]

        # This is a bogus character reference in terms of the XML specification, but legit at this layer of the parser.
        #
        @test collect(E.events(L.State(IOBuffer("&#xxx;")))) == [ E.CharacterReference("xxx", "a buffer", -1) ]
    end

    @testset "Events/Character References (Negative ... no character specification)" begin
        # Check that a missing character specification is caught.
        #
        @test (collect(E.events(L.State(IOBuffer("&#;"))))
               == [ E.MarkupError("ERROR: Expecting a character value.",
                                  [ L.Token(L.cro, "&#", "a buffer", -1) ], "a buffer", -1) ])

        # Check that EOI is caught.
        #
        @test (collect(E.events(L.State(IOBuffer("&#"))))
               == [ E.MarkupError("ERROR: Expecting a character value.",
                                  [ L.Token(L.cro, "&#", "a buffer", -1) ], "a buffer", -1) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = collect(E.events(L.State(IOBuffer("&#<"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting a character value.",
                                              [ L.Token(L.cro, "&#", "a buffer", -1) ], "a buffer", -1))
    end

    @testset "Events/Character References (Negative ... no terminator)" begin
        # Check that EOI is caught.
        #
        @test (collect(E.events(L.State(IOBuffer("&#10"))))
               == [ E.MarkupError("ERROR: Expecting ';' to end a character reference.",
                                  [ L.Token(L.cro, "&#", "a buffer", -1),
                                    L.Token(L.text, "10", "a buffer", -1) ], "a buffer", -1) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = collect(E.events(L.State(IOBuffer("&#10<"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting ';' to end a character reference.",
                                              [ L.Token(L.cro, "&#", "a buffer", -1),
                                                L.Token(L.text, "10", "a buffer", -1) ], "a buffer", -1))
    end

    @testset "Events/General Entity References (Positive)" begin
        @test collect(E.events(L.State(IOBuffer("&a;")))) == [ E.EntityReferenceGeneral("a", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("&é;")))) == [ E.EntityReferenceGeneral("é", "a buffer", -1) ]

        @test collect(E.events(L.State(IOBuffer("&aé;")))) == [ E.EntityReferenceGeneral("aé", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("&éa;")))) == [ E.EntityReferenceGeneral("éa", "a buffer", -1) ]

        @test collect(E.events(L.State(IOBuffer("&a;&é;")))) == [ E.EntityReferenceGeneral("a", "a buffer", -1), 
                                                                  E.EntityReferenceGeneral("é", "a buffer", -1) ]

        @test collect(E.events(L.State(IOBuffer("&é;&a;")))) == [ E.EntityReferenceGeneral("é", "a buffer", -1), 
                                                                  E.EntityReferenceGeneral("a", "a buffer", -1) ]
    end
end
