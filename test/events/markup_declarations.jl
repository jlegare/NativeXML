@testset "Events/Markup Declarations" begin
    # These test sets are a grab bag of negative tests that really fit anywhere else.
    #
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    DC = E.DataContent
    ME = E.MarkupError

    @testset "Events/Markup Declarations (Negative ... invalid token after <!)" begin
        events = evaluate("<!")
        @test (events == [ ME("ERROR: Expecting the start of a markup declaration.", L.Location("a buffer", -1)) ])

        events = evaluate("<! ")
        @test length(events) == 2
        @test (events == [ ME("ERROR: Expecting the start of a markup declaration.", L.Location("a buffer", -1)),
                           DC(" ", true, L.Location("a buffer", -1)) ])

        # Check that some random token is caught.
        #
        events = evaluate("<!bob")
        @test length(events) == 2
        @test (events == [ ME("ERROR: Expecting the start of a markup declaration.", L.Location("a buffer", -1)),
                           DC("bob", false, L.Location("a buffer", -1)) ])

        # Look for the lowercased-versions of the correct keywords. These are valid in SGML, but invalid in XML.
        #
        events = evaluate("<!doctype")
        @test length(events) == 2
        @test (events == [ ME("ERROR: The keyword 'doctype' must be uppercased.", L.Location("a buffer", -1)),
                           ME("ERROR: Expecting a root element name.", L.Location("a buffer", -1)) ])

        events = evaluate("<!entity")
        @test length(events) == 3
        @test (events == [ ME("ERROR: The keyword 'entity' must be uppercased.", L.Location("a buffer", -1)),
                           ME("ERROR: White space is required following the 'ENTITY' keyword.", L.Location("a buffer", -1)),
                           ME("ERROR: Expecting an entity name.", L.Location("a buffer", -1)) ])

        events = evaluate("<!notation")
        @test length(events) == 2
        @test (events == [ ME("ERROR: The keyword 'notation' must be uppercased.", L.Location("a buffer", -1)),
                           ME("ERROR: Expecting a notation name.", L.Location("a buffer", -1)) ])

        # Look for the remaining SGML keywords.
        #
        events = evaluate("<!sgml")
        @test length(events) == 2
        @test (events == [ ME("ERROR: The keyword 'SGML' is not available in XML.", L.Location("a buffer", -1)),
                           DC("sgml", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!shortref")
        @test length(events) == 2
        @test (events == [ ME("ERROR: The keyword 'SHORTREF' is not available in XML.", L.Location("a buffer", -1)),
                           DC("shortref", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!usemap")
        @test length(events) == 2
        @test (events == [ ME("ERROR: The keyword 'USEMAP' is not available in XML.", L.Location("a buffer", -1)),
                           DC("usemap", false, L.Location("a buffer", -1)) ])
    end
end
