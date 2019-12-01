@testset "Events/Element Ends" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    @testset "Events/Element Ends (Positive)" begin
        @test evaluate("</a>")   == [ E.ElementEnd("a", L.Location("a buffer", -1)) ]
        @test evaluate("</abc>") == [ E.ElementEnd("abc", L.Location("a buffer", -1)) ]
        @test evaluate("</é>")   == [ E.ElementEnd("é", L.Location("a buffer", -1)) ]
        @test evaluate("</aé>")  == [ E.ElementEnd("aé", L.Location("a buffer", -1)) ]
        @test evaluate("</éa>")  == [ E.ElementEnd("éa", L.Location("a buffer", -1)) ]

        # White space is allowed after the element name. Just try various combinations, and check that it is discarded.
        #
        @test evaluate("</a >")       == [ E.ElementEnd("a", L.Location("a buffer", -1)) ]
        @test evaluate("</a\u09>")    == [ E.ElementEnd("a", L.Location("a buffer", -1)) ]
        @test evaluate("</a	\n>") == [ E.ElementEnd("a", L.Location("a buffer", -1)) ]

        @test evaluate("</a></b>") == [ E.ElementEnd("a", L.Location("a buffer", -1)),
                                        E.ElementEnd("b", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Element Ends (Negative ... no terminator)" begin
        @test (evaluate("</a")
               == [ E.MarkupError("ERROR: Expecting '>' to end an element close tag.", [ ], L.Location("a buffer", -1)),
                    E.ElementEnd(true, "a", L.Location("a buffer", -1)) ])

        @test (evaluate("</abc")
               == [ E.MarkupError("ERROR: Expecting '>' to end an element close tag.", [ ], L.Location("a buffer", -1)),
                    E.ElementEnd(true, "abc", L.Location("a buffer", -1)) ])

        @test (evaluate("</a ")
               == [ E.MarkupError("ERROR: Expecting '>' to end an element close tag.", [ ], L.Location("a buffer", -1)),
                    E.ElementEnd(true, "a", L.Location("a buffer", -1)) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = evaluate("</a<?")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting '>' to end an element close tag.", [ ], L.Location("a buffer", -1)))

        events = evaluate("</a <?")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting '>' to end an element close tag.", [ ], L.Location("a buffer", -1)))
    end

    @testset "Events/Element Ends (Negative ... no element name)" begin
        @test (evaluate("</")
               == [ E.MarkupError("ERROR: Expecting an element name.",
                                  [ L.Token(L.etago, "</", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = evaluate("</<?")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an element name.",
                                              [ L.Token(L.etago, "</", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("</ ")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an element name.",
                                              [ L.Token(L.etago, "</", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end
end
