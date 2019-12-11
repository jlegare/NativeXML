@testset "Events/Markup Declarations" begin
    # These test sets are a grab bag of negative tests that really fit anywhere else.
    #
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    DC = E.DataContent
    ME = E.MarkupError

    @testset "Events/Markup Declarations (Negative ... placeholders until parsers get written)" begin
        events = evaluate("<!ATTLIST")
        @test length(events) == 2
        @test (events == [ ME("ERROR: Expecting the start of a markup declaration.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                           DC("ATTLIST", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!ELEMENT")
        @test length(events) == 2
        @test (events == [ ME("ERROR: Expecting the start of a markup declaration.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                           DC("ELEMENT", false, L.Location("a buffer", -1)) ])
    end

    @testset "Events/Markup Declarations (Negative ... invalid token after <!)" begin
        events = evaluate("<!")
        @test (events == [ ME("ERROR: Expecting the start of a markup declaration.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        events = evaluate("<! ")
        @test length(events) == 2
        @test (events == [ ME("ERROR: Expecting the start of a markup declaration.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                           DC(" ", true, L.Location("a buffer", -1)) ])

        # Check that some random token is caught.
        #
        events = evaluate("<!bob")
        @test length(events) == 2
        @test (events == [ ME("ERROR: Expecting the start of a markup declaration.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                           DC("bob", false, L.Location("a buffer", -1)) ])

        # Look for the lowercased-versions of the correct keywords. These are valid in SGML, but invalid in XML.
        #
        events = evaluate("<!attlist")
        @test length(events) == 3
        @test (events == [ ME("ERROR: The keyword 'attlist' must be uppercased.", [ ], L.Location("a buffer", -1)),
                           ME("ERROR: Expecting the start of a markup declaration.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                           DC("attlist", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!doctype")
        @test length(events) == 3
        @test (events == [ ME("ERROR: The keyword 'doctype' must be uppercased.", [ ], L.Location("a buffer", -1)),
                           ME("ERROR: Expecting a root element name.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                L.Token(L.text, "doctype", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                           ME("ERROR: Expecting the start of a markup declaration.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        events = evaluate("<!element")
        @test length(events) == 3
        @test (events == [ ME("ERROR: The keyword 'element' must be uppercased.", [ ], L.Location("a buffer", -1)),
                           ME("ERROR: Expecting the start of a markup declaration.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                           DC("element", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!entity")
        @test length(events) == 3
        @test (events == [ ME("ERROR: The keyword 'entity' must be uppercased.", [ ], L.Location("a buffer", -1)),
                           ME("ERROR: Expecting an entity name.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                L.Token(L.text, "entity", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                           ME("ERROR: Expecting the start of a markup declaration.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        events = evaluate("<!notation")
        @test length(events) == 3
        @test (events == [ ME("ERROR: The keyword 'notation' must be uppercased.", [ ], L.Location("a buffer", -1)),
                           ME("ERROR: Expecting the start of a markup declaration.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                           DC("notation", false, L.Location("a buffer", -1)) ])

        # Look for the remaining SGML keywords.
        #
        events = evaluate("<!shortref")
        @test length(events) == 3
        @test (events == [ ME("ERROR: The keyword 'shortref' is not available in XML.", [ ], L.Location("a buffer", -1)),
                           ME("ERROR: Expecting the start of a markup declaration.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                           DC("shortref", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!usemap")
        @test length(events) == 3
        @test (events == [ ME("ERROR: The keyword 'usemap' is not available in XML.", [ ], L.Location("a buffer", -1)),
                           ME("ERROR: Expecting the start of a markup declaration.",
                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                           DC("usemap", false, L.Location("a buffer", -1)) ])
    end
end
