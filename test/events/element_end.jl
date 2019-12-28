@testset "Events/Element Ends" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    ElementEnd   = E.ElementEnd
    ElementStart = E.ElementStart

    DC = E.DataContent
    ME = E.MarkupError

    @testset "Events/Element Ends (Positive)" begin
        @test evaluate("</a>")   == [ ElementEnd("a", L.Location("a buffer", -1)) ]
        @test evaluate("</abc>") == [ ElementEnd("abc", L.Location("a buffer", -1)) ]
        @test evaluate("</é>")   == [ ElementEnd("é", L.Location("a buffer", -1)) ]
        @test evaluate("</aé>")  == [ ElementEnd("aé", L.Location("a buffer", -1)) ]
        @test evaluate("</éa>")  == [ ElementEnd("éa", L.Location("a buffer", -1)) ]

        # White space is allowed after the element name. Just try various combinations, and check that it is discarded.
        #
        @test evaluate("</a >")       == [ ElementEnd("a", L.Location("a buffer", -1)) ]
        @test evaluate("</a\u09>")    == [ ElementEnd("a", L.Location("a buffer", -1)) ]
        @test evaluate("</a	\n>") == [ ElementEnd("a", L.Location("a buffer", -1)) ]

        @test evaluate("</a></b>") == [ ElementEnd("a", L.Location("a buffer", -1)),
                                        ElementEnd("b", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Element Ends (Negative ... no terminator)" begin
        @test (evaluate("</a")
               == [ ME("ERROR: Expecting '>' to end an element close tag.", [ ], L.Location("a buffer", -1)),
                    ElementEnd(true, "a", L.Location("a buffer", -1)) ])

        @test (evaluate("</abc")
               == [ ME("ERROR: Expecting '>' to end an element close tag.", [ ], L.Location("a buffer", -1)),
                    ElementEnd(true, "abc", L.Location("a buffer", -1)) ])

        @test (evaluate("</a ")
               == [ ME("ERROR: Expecting '>' to end an element close tag.", [ ], L.Location("a buffer", -1)),
                    ElementEnd(true, "a", L.Location("a buffer", -1)) ])

        events = evaluate("</a<?")
        @test length(events) == 3
        @test (events == [ ME("ERROR: Expecting '>' to end an element close tag.", [ ], L.Location("a buffer", -1)),
                           ElementEnd(true, "a", L.Location("a buffer", -1)),
                           ME("ERROR: Expecting a PI target.", [ ], L.Location("a buffer", -1)) ])

        events = evaluate("</a <?")
        @test length(events) == 3
        @test (events == [ ME("ERROR: Expecting '>' to end an element close tag.", [ ], L.Location("a buffer", -1)),
                           ElementEnd(true, "a", L.Location("a buffer", -1)),
                           ME("ERROR: Expecting a PI target.", [ ], L.Location("a buffer", -1)) ])
    end

    @testset "Events/Element Ends (Negative ... no element name)" begin
        @test (evaluate("</") == [ ME("ERROR: Expecting an element name.", [ ], L.Location("a buffer", -1)) ])

        events = evaluate("</<?")
        @test length(events) == 2
        @test (events == [ ME("ERROR: Expecting an element name.", [ ], L.Location("a buffer", -1)),
                           ME("ERROR: Expecting a PI target.", [ ], L.Location("a buffer", -1)) ])

        events = evaluate("</ ")
        @test length(events) == 2
        @test (events == [ ME("ERROR: Expecting an element name.", [ ], L.Location("a buffer", -1)),
                           DC(" ", true, L.Location("a buffer", -1)) ])
    end
end
