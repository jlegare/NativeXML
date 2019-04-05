@testset "Events/Element Starts" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Element Starts (Positive)" begin
        @test collect(E.events(L.State(IOBuffer("<a>"))))   == [ E.ElementStart("a", [ ], "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<abc>")))) == [ E.ElementStart("abc", [ ], "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<é>"))))   == [ E.ElementStart("é", [ ], "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<aé>"))))  == [ E.ElementStart("aé", [ ], "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<éb>"))))  == [ E.ElementStart("éb", [ ], "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<aéb>")))) == [ E.ElementStart("aéb", [ ], "a buffer", -1) ]

        # White space is allowed after the element name. Just try various combinations, and check that it is discarded.
        #
        @test collect(E.events(L.State(IOBuffer("<a >"))))       == [ E.ElementStart("a", [ ], "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<a\u09>"))))    == [ E.ElementStart("a", [ ], "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<a	\n>")))) == [ E.ElementStart("a", [ ], "a buffer", -1) ]

        @test collect(E.events(L.State(IOBuffer("<a><b>")))) == [ E.ElementStart("a", [ ], "a buffer", -1),
                                                                  E.ElementStart("b", [ ], "a buffer", -1) ]
    end

    @testset "Events/Empty Elements (Positive)" begin
        @test collect(E.events(L.State(IOBuffer("<a/>"))))   == [ E.ElementStart(true, "a", [ ], "a buffer", -1),
                                                                  E.ElementEnd("a", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<abc/>")))) == [ E.ElementStart(true, "abc", [ ], "a buffer", -1),
                                                                  E.ElementEnd("abc", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<é/>"))))   == [ E.ElementStart(true, "é", [ ], "a buffer", -1),
                                                                  E.ElementEnd("é", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<aé/>"))))  == [ E.ElementStart(true, "aé", [ ], "a buffer", -1),
                                                                  E.ElementEnd("aé", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<éb/>"))))  == [ E.ElementStart(true, "éb", [ ], "a buffer", -1),
                                                                  E.ElementEnd("éb", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<aéb/>")))) == [ E.ElementStart(true, "aéb", [ ], "a buffer", -1),
                                                                  E.ElementEnd("aéb", "a buffer", -1) ]

        # White space is allowed after the element name. Just try various combinations, and check that it is discarded.
        #
        @test collect(E.events(L.State(IOBuffer("<a />"))))       == [ E.ElementStart(true, "a", [ ], "a buffer", -1),
                                                                       E.ElementEnd("a", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<a\u09/>"))))    == [ E.ElementStart(true, "a", [ ], "a buffer", -1),
                                                                       E.ElementEnd("a", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<a	\n/>")))) == [ E.ElementStart(true, "a", [ ], "a buffer", -1),
                                                                       E.ElementEnd("a", "a buffer", -1) ]

        @test collect(E.events(L.State(IOBuffer("<a/><b/>")))) == [ E.ElementStart(true, "a", [ ], "a buffer", -1),
                                                                    E.ElementEnd("a", "a buffer", -1),
                                                                    E.ElementStart(true, "b", [ ], "a buffer", -1),
                                                                    E.ElementEnd("b", "a buffer", -1) ]
    end

    @testset "Events/Element Starts (Negative ... no terminator)" begin
        @test (collect(E.events(L.State(IOBuffer("<a"))))
               == [ E.ElementStart(true, false, "a", [ ], "a buffer", -1),
                    E.MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], "a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("<abc"))))
               == [ E.ElementStart(true, false, "abc", [ ], "a buffer", -1),
                    E.MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], "a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("<a "))))
               == [ E.ElementStart(true, false, "a", [ ], "a buffer", -1),
                    E.MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], "a buffer", -1) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST TWO
        # events. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = collect(E.events(L.State(IOBuffer("<a<?"))))
        @test length(events) > 2
        @test events[1:2] == [ E.ElementStart(true, false, "a", [ ], "a buffer", -1),
                               E.MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], "a buffer", -1) ]

        events = collect(E.events(L.State(IOBuffer("<a <?"))))
        @test length(events) > 2
        @test events[1:2] == [ E.ElementStart(true, false, "a", [ ], "a buffer", -1),
                               E.MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], "a buffer", -1) ]
    end

    @testset "Events/Empty Elements (Negative ... no terminator)" begin
        @test (collect(E.events(L.State(IOBuffer("<a/"))))
               == [ E.ElementStart(true, true, "a", [ ], "a buffer", -1),
                    E.MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], "a buffer", -1),
                    E.ElementEnd(true, "a", "a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("<abc/"))))
               == [ E.ElementStart(true, true, "abc", [ ], "a buffer", -1),
                    E.MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], "a buffer", -1),
                    E.ElementEnd(true, "abc", "a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("<a /"))))
               == [ E.ElementStart(true, true, "a", [ ], "a buffer", -1),
                    E.MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], "a buffer", -1),
                    E.ElementEnd(true, "a", "a buffer", -1) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST THREE
        # events. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = collect(E.events(L.State(IOBuffer("<a/<?"))))
        @test length(events) > 3
        @test events[1:3] == [ E.ElementStart(true, true, "a", [ ], "a buffer", -1),
                               E.MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], "a buffer", -1),
                               E.ElementEnd(true, "a", "a buffer", -1) ]

        events = collect(E.events(L.State(IOBuffer("<a /<?"))))
        @test length(events) > 3
        @test events[1:3] == [ E.ElementStart(true, true, "a", [ ], "a buffer", -1),
                               E.MarkupError("ERROR: Expecting '>' to end an element open tag.", [ ], "a buffer", -1),
                               E.ElementEnd(true, "a", "a buffer", -1) ]
    end

    @testset "Events/Element Starts (Negative ... no element name)" begin
        @test (collect(E.events(L.State(IOBuffer("<"))))
               == [ E.MarkupError("ERROR: Expecting an element name.", [ L.Token(L.stago, "<", "a buffer", -1) ], "a buffer", -1) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = collect(E.events(L.State(IOBuffer("<<?"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an element name.",
                                              [ L.Token(L.stago, "<", "a buffer", -1) ], "a buffer", -1))

        events = collect(E.events(L.State(IOBuffer("< "))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an element name.",
                                              [ L.Token(L.stago, "<", "a buffer", -1) ], "a buffer", -1))
    end
end
