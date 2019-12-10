@testset "Events/Entity References" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    @testset "Events/Entity References/Character References (Positive)" begin
        @test evaluate("&#10;") == [ E.CharacterReference("10", L.Location("a buffer", -1)) ]
        @test evaluate("&#xa;") == [ E.CharacterReference("xa", L.Location("a buffer", -1)) ]

        @test evaluate("&#10;&#xa;") == [ E.CharacterReference("10", L.Location("a buffer", -1)),
                                          E.CharacterReference("xa", L.Location("a buffer", -1)) ]
        @test evaluate("&#xa;&#10;") == [ E.CharacterReference("xa", L.Location("a buffer", -1)),
                                          E.CharacterReference("10", L.Location("a buffer", -1)) ]

        # This is a bogus character reference in terms of the XML specification, but legit at this layer of the parser.
        #
        @test evaluate("&#xxx;") == [ E.CharacterReference("xxx", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Entity References/Character References (Negative ... no character specification)" begin
        # Check that a missing character specification is caught.
        #
        @test (evaluate("&#;") == [ E.MarkupError("ERROR: Expecting a character value.",
                                                  [ L.Token(L.cro, "&#", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                    E.DataContent(";", false, L.Location("a buffer", -1)) ])

        # Check that EOI is caught.
        #
        @test (evaluate("&#") == [ E.MarkupError("ERROR: Expecting a character value.",
                                                 [ L.Token(L.cro, "&#", L.Location("a buffer", -1)) ],
                                                 L.Location("a buffer", -1)) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = evaluate("&#<")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a character value.",
                                          [ L.Token(L.cro, "&#", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end

    @testset "Events/Entity References/Character References (Negative ... no terminator)" begin
        # Check that EOI is caught.
        #
        @test (evaluate("&#10")
               == [ E.MarkupError("ERROR: Expecting ';' to end a character reference.",
                                  [ L.Token(L.cro, "&#", L.Location("a buffer", -1)),
                                    L.Token(L.text, "10", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = evaluate("&#10<")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting ';' to end a character reference.",
                                          [ L.Token(L.cro, "&#", L.Location("a buffer", -1)),
                                            L.Token(L.text, "10", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end

    @testset "Events/Entity References/General Entity References (Positive)" begin
        @test evaluate("&a;") == [ E.EntityReferenceGeneral("a", L.Location("a buffer", -1)) ]
        @test evaluate("&é;") == [ E.EntityReferenceGeneral("é", L.Location("a buffer", -1)) ]

        @test evaluate("&aé;") == [ E.EntityReferenceGeneral("aé", L.Location("a buffer", -1)) ]
        @test evaluate("&éa;") == [ E.EntityReferenceGeneral("éa", L.Location("a buffer", -1)) ]

        @test evaluate("&a;&é;") == [ E.EntityReferenceGeneral("a", L.Location("a buffer", -1)),
                                      E.EntityReferenceGeneral("é", L.Location("a buffer", -1)) ]

        @test evaluate("&é;&a;") == [ E.EntityReferenceGeneral("é", L.Location("a buffer", -1)),
                                      E.EntityReferenceGeneral("a", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Entity References/General Entity References (Negative ... no entity name)" begin
        # Check that a missing entity name is caught.
        #
        @test (evaluate("&;")
               == [ E.MarkupError("ERROR: Expecting an entity name.",
                                  [ L.Token(L.ero, "&", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                    E.DataContent(";", false, L.Location("a buffer", -1)) ])


        # Check that EOI is caught.
        #
        @test (evaluate("&")
               == [ E.MarkupError("ERROR: Expecting an entity name.",
                                  [ L.Token(L.ero, "&", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = evaluate("&<")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting an entity name.",
                                          [ L.Token(L.ero, "&", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end

    @testset "Events/Entity References/General Entity References (Negative ... no terminator)" begin
        # Check that EOI is caught.
        #
        @test (evaluate("&a")
               == [ E.MarkupError("ERROR: Expecting ';' to end an entity reference.",
                                  [ L.Token(L.ero, "&", L.Location("a buffer", -1)),
                                    L.Token(L.text, "a", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = evaluate("&a<")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting ';' to end an entity reference.",
                                          [ L.Token(L.ero, "&", L.Location("a buffer", -1)),
                                            L.Token(L.text, "a", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end

    @testset "Events/Entity References/Parameter Entity References (Positive)" begin
        @test evaluate("%a;") == [ E.EntityReferenceParameter("a", L.Location("a buffer", -1)) ]
        @test evaluate("%é;") == [ E.EntityReferenceParameter("é", L.Location("a buffer", -1)) ]

        @test evaluate("%aé;") == [ E.EntityReferenceParameter("aé", L.Location("a buffer", -1)) ]
        @test evaluate("%éa;") == [ E.EntityReferenceParameter("éa", L.Location("a buffer", -1)) ]

        @test evaluate("%a;%é;") == [ E.EntityReferenceParameter("a", L.Location("a buffer", -1)),
                                                                  E.EntityReferenceParameter("é", L.Location("a buffer", -1)) ]

        @test evaluate("%é;%a;") == [ E.EntityReferenceParameter("é", L.Location("a buffer", -1)),
                                                                  E.EntityReferenceParameter("a", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Entity References/Parameter Entity References (Negative ... no entity name)" begin
        # Check that a missing entity name is caught.
        #
        @test (evaluate("%;") == [ E.MarkupError("ERROR: Expecting a parameter entity name.",
                                                 [ L.Token(L.pero, "%", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                   E.DataContent(";", false, L.Location("a buffer", -1)) ])

        # Check that EOI is caught.
        #
        @test (evaluate("%") == [ E.MarkupError("ERROR: Expecting a parameter entity name.",
                                                [ L.Token(L.pero, "%", L.Location("a buffer", -1)) ],
                                                L.Location("a buffer", -1)) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = evaluate("%<")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a parameter entity name.",
                                          [ L.Token(L.pero, "%", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end

    @testset "Events/Entity References/Parameter Entity References (Negative ... no terminator)" begin
        # Check that EOI is caught.
        #
        @test (evaluate("%a") == [ E.MarkupError("ERROR: Expecting ';' to end a parameter entity reference.",
                                                 [ L.Token(L.pero, "%", L.Location("a buffer", -1)),
                                                   L.Token(L.text, "a", L.Location("a buffer", -1)) ],
                                                 L.Location("a buffer", -1)) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = evaluate("%a<")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting ';' to end a parameter entity reference.",
                                          [ L.Token(L.pero, "%", L.Location("a buffer", -1)),
                                            L.Token(L.text, "a", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end
end
