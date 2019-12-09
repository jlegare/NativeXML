@testset "Events/Markup Declarations" begin
    # These test sets are a grab bag of negative tests that really fit anywhere else.
    #
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    @testset "Events/Markup Declarations (Negative ... placeholders until parsers get written)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        events = evaluate("<!ATTLIST")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting the start of a markup declaration.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!ELEMENT")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting the start of a markup declaration.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end

    @testset "Events/Markup Declarations (Negative ... invalid token after <!)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        events = evaluate("<!")
        @test length(events) == 1
        @test (first(events) == E.MarkupError("ERROR: Expecting the start of a markup declaration.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<! ")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting the start of a markup declaration.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        # Check that some random token is caught.
        #
        events = evaluate("<!bob")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting the start of a markup declaration.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        # Look for the lowercased-versions of the correct keywords. These are valid in SGML, but invalid in XML.
        #
        events = evaluate("<!attlist")
        @test length(events) > 2
        @test (events[1] == E.MarkupError("ERROR: The keyword 'attlist' must be uppercased.", [ ], L.Location("a buffer", -1)))
        @test (events[2]== E.MarkupError("ERROR: Expecting the start of a markup declaration.",
                                         [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!doctype")
        @test length(events) > 2
        @test (events[1] == E.MarkupError("ERROR: The keyword 'doctype' must be uppercased.", [ ], L.Location("a buffer", -1)))
        @test (events[2] == E.MarkupError("ERROR: Expecting a root element name.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "doctype", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!element")
        @test length(events) > 2
        @test (events[1] == E.MarkupError("ERROR: The keyword 'element' must be uppercased.", [ ], L.Location("a buffer", -1)))
        @test (events[2]== E.MarkupError("ERROR: Expecting the start of a markup declaration.",
                                         [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!entity")
        @test length(events) > 2
        @test (events[1] == E.MarkupError("ERROR: The keyword 'entity' must be uppercased.", [ ], L.Location("a buffer", -1)))
        @test (events[2] == E.MarkupError("ERROR: Expecting an entity name.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "entity", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!notation")
        @test length(events) > 2
        @test (events[1] == E.MarkupError("ERROR: The keyword 'notation' must be uppercased.", [ ], L.Location("a buffer", -1)))
        @test (events[2]== E.MarkupError("ERROR: Expecting the start of a markup declaration.",
                                         [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        # Look for the remaining SGML keywords.
        #
        events = evaluate("<!shortref")
        @test length(events) > 2
        @test (events[1] == E.MarkupError("ERROR: The keyword 'shortref' is not available in XML.", [ ], L.Location("a buffer", -1)))
        @test (events[2] == E.MarkupError("ERROR: Expecting the start of a markup declaration.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!usemap")
        @test length(events) > 2
        @test (events[1] == E.MarkupError("ERROR: The keyword 'usemap' is not available in XML.", [ ], L.Location("a buffer", -1)))
        @test (events[2] == E.MarkupError("ERROR: Expecting the start of a markup declaration.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end
end
