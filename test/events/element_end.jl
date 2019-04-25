@testset "Events/Element Ends" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Element Ends (Positive)" begin
        @test collect(E.events(L.State(IOBuffer("</a>"))))   == [ E.ElementEnd("a", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("</abc>")))) == [ E.ElementEnd("abc", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("</é>"))))   == [ E.ElementEnd("é", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("</aé>"))))  == [ E.ElementEnd("aé", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("</éa>"))))  == [ E.ElementEnd("éa", "a buffer", -1) ]

        # White space is allowed after the element name. Just try various combinations, and check that it is discarded.
        #
        @test collect(E.events(L.State(IOBuffer("</a >"))))       == [ E.ElementEnd("a", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("</a\u09>"))))    == [ E.ElementEnd("a", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("</a	\n>"))))  == [ E.ElementEnd("a", "a buffer", -1) ]

        @test collect(E.events(L.State(IOBuffer("</a></b>")))) == [ E.ElementEnd("a", "a buffer", -1), 
                                                                    E.ElementEnd("b", "a buffer", -1) ]
    end

    @testset "Events/Element Ends (Negative ... no terminator)" begin
        @test (collect(E.events(L.State(IOBuffer("</a")))) 
               == [ E.MarkupError("ERROR: Expecting '>' to end an element close tag.", [ ], "a buffer", -1), 
                    E.ElementEnd(true, "a", "a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("</abc")))) 
               == [ E.MarkupError("ERROR: Expecting '>' to end an element close tag.", [ ], "a buffer", -1), 
                    E.ElementEnd(true, "abc", "a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("</a ")))) 
               == [ E.MarkupError("ERROR: Expecting '>' to end an element close tag.", [ ], "a buffer", -1), 
                    E.ElementEnd(true, "a", "a buffer", -1) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = collect(E.events(L.State(IOBuffer("</a<?"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting '>' to end an element close tag.", [ ], "a buffer", -1))

        events = collect(E.events(L.State(IOBuffer("</a <?"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting '>' to end an element close tag.", [ ], "a buffer", -1))
    end

    @testset "Events/Element Ends (Negative ... no element name)" begin
        @test (collect(E.events(L.State(IOBuffer("</")))) 
               == [ E.MarkupError("ERROR: Expecting an element name.", 
                                  [ L.Token(L.etago, "</", "a buffer", -1) ], "a buffer", -1) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = collect(E.events(L.State(IOBuffer("</<?"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an element name.", 
                                              [ L.Token(L.etago, "</", "a buffer", -1) ], "a buffer", -1))

        events = collect(E.events(L.State(IOBuffer("</ "))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an element name.", 
                                              [ L.Token(L.etago, "</", "a buffer", -1) ], "a buffer", -1))
    end
end