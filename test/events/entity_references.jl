@testset "Events/Entity References" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    CharRef = E.CharacterReference
    GenRef  = E.EntityReferenceGeneral
    ParRef  = E.EntityReferenceParameter

    DC = E.DataContent
    ME = E.MarkupError

    @testset "Events/Entity References/Character References (Positive)" begin
        @test evaluate("&#10;") == [ CharRef("10", L.Location("a buffer", -1)) ]
        @test evaluate("&#xa;") == [ CharRef("xa", L.Location("a buffer", -1)) ]

        @test evaluate("&#10;&#xa;") == [ CharRef("10", L.Location("a buffer", -1)),
                                          CharRef("xa", L.Location("a buffer", -1)) ]
        @test evaluate("&#xa;&#10;") == [ CharRef("xa", L.Location("a buffer", -1)),
                                          CharRef("10", L.Location("a buffer", -1)) ]

        # This is a bogus character reference in terms of the XML specification, but legit at this layer of the parser.
        #
        @test evaluate("&#xxx;") == [ CharRef("xxx", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Entity References/Character References (Negative ... no character specification)" begin
        # Check that a missing character specification is caught.
        #
        @test (evaluate("&#;") == [ ME("ERROR: Expecting a character value.", L.Location("a buffer", -1)),
                                    DC("&#", false, L.Location("a buffer", -1)),
                                    DC(";", false, L.Location("a buffer", -1)) ])

        # Check that EOI is caught.
        #
        @test (evaluate("&#") == [ ME("ERROR: Expecting a character value.", L.Location("a buffer", -1)),
                                   DC("&#", false, L.Location("a buffer", -1)) ])

        # Check that a random token is caught.
        #
        events = evaluate("&#<")
        @test length(events) == 3
        @test (events == [ ME("ERROR: Expecting a character value.", L.Location("a buffer", -1)),
                           DC("&#", false, L.Location("a buffer", -1)),
                           ME("ERROR: Expecting an element name.", L.Location("a buffer", -1)) ])
    end

    @testset "Events/Entity References/Character References (Negative ... no terminator)" begin
        # Check that EOI is caught.
        #
        @test (evaluate("&#10")
               == [ ME("ERROR: Expecting ';' to end a character reference.", L.Location("a buffer", -1)),
                    DC("&#10", false, L.Location("a buffer", -1)) ])

        # Check that a random token is caught.
        #
        events = evaluate("&#10<")
        @test length(events) == 3
        @test (events == [ ME("ERROR: Expecting ';' to end a character reference.", L.Location("a buffer", -1)),
                           DC("&#10", false, L.Location("a buffer", -1)),
                           ME("ERROR: Expecting an element name.", L.Location("a buffer", -1)) ])
    end

    @testset "Events/Entity References/General Entity References (Positive)" begin
        @test evaluate("&a;") == [ GenRef("a", L.Location("a buffer", -1)) ]
        @test evaluate("&é;") == [ GenRef("é", L.Location("a buffer", -1)) ]

        @test evaluate("&aé;") == [ GenRef("aé", L.Location("a buffer", -1)) ]
        @test evaluate("&éa;") == [ GenRef("éa", L.Location("a buffer", -1)) ]

        @test evaluate("&a;&é;") == [ GenRef("a", L.Location("a buffer", -1)),
                                      GenRef("é", L.Location("a buffer", -1)) ]

        @test evaluate("&é;&a;") == [ GenRef("é", L.Location("a buffer", -1)),
                                      GenRef("a", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Entity References/General Entity References (Negative ... no entity name)" begin
        # Check that a missing entity name is caught.
        #
        @test (evaluate("&;")
               == [ ME("ERROR: Expecting an entity name.", L.Location("a buffer", -1)),
                    DC("&", false, L.Location("a buffer", -1)),
                    DC(";", false, L.Location("a buffer", -1)) ])


        # Check that EOI is caught.
        #
        @test (evaluate("&")
               == [ ME("ERROR: Expecting an entity name.", L.Location("a buffer", -1)),
                    DC("&", false, L.Location("a buffer", -1)) ])

        # Check that a random token is caught.
        #
        events = evaluate("&<")
        @test length(events) == 3
        @test (events == [ ME("ERROR: Expecting an entity name.", L.Location("a buffer", -1)),
                           DC("&", false, L.Location("a buffer", -1)),
                           ME("ERROR: Expecting an element name.", L.Location("a buffer", -1)) ])
    end

    @testset "Events/Entity References/General Entity References (Negative ... no terminator)" begin
        # Check that EOI is caught.
        #
        @test (evaluate("&a")
               == [ ME("ERROR: Expecting ';' to end an entity reference.", L.Location("a buffer", -1)),
                    GenRef("a", L.Location("a buffer", -1)) ])

        # Check that a random token is caught.
        #
        events = evaluate("&a<")
        @test length(events) == 3
        @test (events == [ ME("ERROR: Expecting ';' to end an entity reference.", L.Location("a buffer", -1)),
                           GenRef("a", L.Location("a buffer", -1)),
                           ME("ERROR: Expecting an element name.", L.Location("a buffer", -1)) ])
    end

    @testset "Events/Entity References/Parameter Entity References (Positive)" begin
        @test evaluate("%a;") == [ ParRef("a", L.Location("a buffer", -1)) ]
        @test evaluate("%é;") == [ ParRef("é", L.Location("a buffer", -1)) ]

        @test evaluate("%aé;") == [ ParRef("aé", L.Location("a buffer", -1)) ]
        @test evaluate("%éa;") == [ ParRef("éa", L.Location("a buffer", -1)) ]

        @test evaluate("%a;%é;") == [ ParRef("a", L.Location("a buffer", -1)),
                                      ParRef("é", L.Location("a buffer", -1)) ]

        @test evaluate("%é;%a;") == [ ParRef("é", L.Location("a buffer", -1)),
                                      ParRef("a", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Entity References/Parameter Entity References (Negative ... no entity name)" begin
        # Check that a missing entity name is caught.
        #
        @test (evaluate("%;") == [ ME("ERROR: Expecting a parameter entity name.", L.Location("a buffer", -1)),
                                   DC("%", false, L.Location("a buffer", -1)),
                                   DC(";", false, L.Location("a buffer", -1)) ])

        # Check that EOI is caught.
        #
        @test (evaluate("%") == [ ME("ERROR: Expecting a parameter entity name.", L.Location("a buffer", -1)),
                                  DC("%", false, L.Location("a buffer", -1)) ])

        # Check that a random token is caught.
        #
        events = evaluate("%<")
        @test length(events) == 3
        @test (events == [ ME("ERROR: Expecting a parameter entity name.", L.Location("a buffer", -1)),
                           DC("%", false, L.Location("a buffer", -1)),
                           ME("ERROR: Expecting an element name.", L.Location("a buffer", -1)) ])
    end

    @testset "Events/Entity References/Parameter Entity References (Negative ... no terminator)" begin
        # Check that EOI is caught.
        #
        @test (evaluate("%a") == [ ME("ERROR: Expecting ';' to end a parameter entity reference.", L.Location("a buffer", -1)),
                                   ParRef("a", L.Location("a buffer", -1)) ])

        # Check that a random token is caught.
        #
        events = evaluate("%a<")
        @test length(events) == 3
        @test (events == [ ME("ERROR: Expecting ';' to end a parameter entity reference.", L.Location("a buffer", -1)),
                           ParRef("a", L.Location("a buffer", -1)),
                           ME("ERROR: Expecting an element name.", L.Location("a buffer", -1)) ])
    end
end
