@testset "Events/Entity Declarations" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    InternalGeneral   = E.EntityDeclarationInternalGeneral
    InternalParameter = E.EntityDeclarationInternalParameter

    @testset "Events/Entity Declarations, Internal General (Positive)" begin
        # Basic tests ... empty entity value.
        #
        @test evaluate("<!ENTITY a \"\">")   == [ InternalGeneral("a", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY abc \"\">") == [ InternalGeneral("abc", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY é \"\">")   == [ InternalGeneral("é", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY aé \"\">")  == [ InternalGeneral("aé", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY éb \"\">")  == [ InternalGeneral("éb", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY aéb \"\">") == [ InternalGeneral("aéb", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY\na\n\"\">") == [ InternalGeneral("a", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY\na\t\"\">") == [ InternalGeneral("a", "", L.Location("a buffer", -1)) ]

        # This is from the XML specification, § 4.2.1 ...
        #
        @test (evaluate("<!ENTITY Pub-Status \"This is a pre-release of the\nspecification.\">")
               == [ InternalGeneral("Pub-Status", "This is a pre-release of the\nspecification.", L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 4.4.5 ...
        #
        @test (evaluate("<!ENTITY WhatHeSaid \"He said %YN;\" >")
               == [ InternalGeneral("WhatHeSaid", "He said %YN;", L.Location("a buffer", -1)) ])
    end

    @testset "Events/Entity Declarations, Internal General (Negative ... invalid or absent entity name.)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        @test (evaluate("<!ENTITY")
               == [ E.MarkupError("ERROR: Expecting an entity name.",
                                  [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                    L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])


        events = evaluate("<!ENTITY>")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        events = evaluate("<!ENTITY >")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        # This one is a little weird: we're picking up "PUBLIC" as the entity name. I'll have to figure out later if
        # that's allowed or not, but there doesn't appear to be anything in the specification that forbids it.
        #
        events = evaluate("<!ENTITY PUBLIC")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!ENTITY \"\"")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        events = evaluate("<!ENTITY ''")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        events = evaluate("<!ENTITY <")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))
    end

    @testset "Events/Entity Declarations, Internal Parameter (Positive)" begin
        # Basic tests ... empty entity value.
        #
        @test evaluate("<!ENTITY % a \"\">")    == [ InternalParameter("a", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % abc \"\">")  == [ InternalParameter("abc", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % é \"\">")    == [ InternalParameter("é", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % aé \"\">")   == [ InternalParameter("aé", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % éb \"\">")   == [ InternalParameter("éb", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % aéb \"\">")  == [ InternalParameter("aéb", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY\n%\na\n\"\">") == [ InternalParameter("a", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY\n%\ta\t\"\">") == [ InternalParameter("a", "", L.Location("a buffer", -1)) ]

        # This is from the XML specification, § 4.4.5 ...
        #
        @test evaluate("<!ENTITY % YN \'\"Yes\"\' >") == [ InternalParameter("YN", "\"Yes\"", L.Location("a buffer", -1)) ]
    end
end
