@testset "Events/Element Starts" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    E = Events
    L = Events.Lexical

    ElementEnd   = E.ElementEnd
    ElementStart = E.ElementStart

    DC = E.DataContent
    ME = E.MarkupError

    @testset "Events/Element Starts (Positive)" begin
        @test evaluate("<a>")   == [ ElementStart("a", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<abc>") == [ ElementStart("abc", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<é>")   == [ ElementStart("é", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<aé>")  == [ ElementStart("aé", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<éb>")  == [ ElementStart("éb", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<aéb>") == [ ElementStart("aéb", [ ], L.Location("a buffer", -1)) ]

        # White space is allowed after the element name. Just try various combinations, and check that it is discarded.
        #
        @test evaluate("<a >")        == [ ElementStart("a", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<a\u09>")     == [ ElementStart("a", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<a	\n>") == [ ElementStart("a", [ ], L.Location("a buffer", -1)) ]

        @test evaluate("<a><b>") == [ ElementStart("a", [ ], L.Location("a buffer", -1)),
                                      ElementStart("b", [ ], L.Location("a buffer", -1)) ]
    end

    @testset "Events/Empty Elements (Positive)" begin
        @test evaluate("<a/>")   == [ ElementStart(true, "a", [ ], L.Location("a buffer", -1)),
                                      ElementEnd("a", L.Location("a buffer", -1)) ]
        @test evaluate("<abc/>") == [ ElementStart(true, "abc", [ ], L.Location("a buffer", -1)),
                                      ElementEnd("abc", L.Location("a buffer", -1)) ]
        @test evaluate("<é/>")   == [ ElementStart(true, "é", [ ], L.Location("a buffer", -1)),
                                      ElementEnd("é", L.Location("a buffer", -1)) ]
        @test evaluate("<aé/>")  == [ ElementStart(true, "aé", [ ], L.Location("a buffer", -1)),
                                      ElementEnd("aé", L.Location("a buffer", -1)) ]
        @test evaluate("<éb/>")  == [ ElementStart(true, "éb", [ ], L.Location("a buffer", -1)),
                                      ElementEnd("éb", L.Location("a buffer", -1)) ]
        @test evaluate("<aéb/>") == [ ElementStart(true, "aéb", [ ], L.Location("a buffer", -1)),
                                      ElementEnd("aéb", L.Location("a buffer", -1)) ]

        # White space is allowed after the element name. Just try various combinations, and check that it is discarded.
        #
        @test evaluate("<a />")        == [ ElementStart(true, "a", [ ], L.Location("a buffer", -1)),
                                            ElementEnd("a", L.Location("a buffer", -1)) ]
        @test evaluate("<a\u09/>")     == [ ElementStart(true, "a", [ ], L.Location("a buffer", -1)),
                                            ElementEnd("a", L.Location("a buffer", -1)) ]
        @test evaluate("<a	\n/>") == [ ElementStart(true, "a", [ ], L.Location("a buffer", -1)),
                                            ElementEnd("a", L.Location("a buffer", -1)) ]

        @test evaluate("<a/><b/>") == [ ElementStart(true, "a", [ ], L.Location("a buffer", -1)),
                                        ElementEnd("a", L.Location("a buffer", -1)),
                                        ElementStart(true, "b", [ ], L.Location("a buffer", -1)),
                                        ElementEnd("b", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Element Starts (Negative ... no terminator)" begin
        @test (evaluate("<a")
               == [ ElementStart(true, false, "a", [ ], L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '>' to end an element open tag.", [ ], L.Location("a buffer", -1)) ])

        @test (evaluate("<abc")
               == [ ElementStart(true, false, "abc", [ ], L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '>' to end an element open tag.", [ ], L.Location("a buffer", -1)) ])

        @test (evaluate("<a ")
               == [ ElementStart(true, false, "a", [ ], L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '>' to end an element open tag.", [ ], L.Location("a buffer", -1)) ])

        events = evaluate("<a<?")
        @test length(events) >= 3
        @test events[1:3] == [ ElementStart(true, false, "a", [ ], L.Location("a buffer", -1)),
                               ME("ERROR: Expecting '>' to end an element open tag.", [ ], L.Location("a buffer", -1)),
                               ME("ERROR: Expecting a PI target.", [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ],
                                  L.Location("a buffer", -1)) ]

        events = evaluate("<a <?")
        @test length(events) >= 3
        @test events[1:3] == [ ElementStart(true, false, "a", [ ], L.Location("a buffer", -1)),
                               ME("ERROR: Expecting '>' to end an element open tag.", [ ], L.Location("a buffer", -1)),
                               ME("ERROR: Expecting a PI target.", [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ],
                                  L.Location("a buffer", -1)) ]
    end

    @testset "Events/Empty Elements (Negative ... no terminator)" begin
        @test (evaluate("<a/")
               == [ ElementStart(true, true, "a", [ ], L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '>' to end an element open tag.", [ ], L.Location("a buffer", -1)),
                    ElementEnd(true, "a", L.Location("a buffer", -1)) ])

        @test (evaluate("<abc/")
               == [ ElementStart(true, true, "abc", [ ], L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '>' to end an element open tag.", [ ], L.Location("a buffer", -1)),
                    ElementEnd(true, "abc", L.Location("a buffer", -1)) ])

        @test (evaluate("<a /")
               == [ ElementStart(true, true, "a", [ ], L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '>' to end an element open tag.", [ ], L.Location("a buffer", -1)),
                    ElementEnd(true, "a", L.Location("a buffer", -1)) ])

        events = evaluate("<a/<?")
        @test length(events) >= 4
        @test events[1:4] == [ ElementStart(true, false, "a", [ ], L.Location("a buffer", -1)),
                               ME("ERROR: Expecting '>' to end an element open tag.", [ ], L.Location("a buffer", -1)),
                               ElementEnd(true, "a", L.Location("a buffer", -1)),
                               ME("ERROR: Expecting a PI target.", [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ],
                                  L.Location("a buffer", -1)) ]

        events = evaluate("<a /<?")
        @test length(events) >= 4
        @test events[1:4] == [ ElementStart(true, false, "a", [ ], L.Location("a buffer", -1)),
                               ME("ERROR: Expecting '>' to end an element open tag.", [ ], L.Location("a buffer", -1)),
                               ElementEnd(true, "a", L.Location("a buffer", -1)),
                               ME("ERROR: Expecting a PI target.", [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ],
                                  L.Location("a buffer", -1)) ]
    end

    @testset "Events/Element Starts (Negative ... no element name)" begin
        @test (evaluate("<")
               == [ ME("ERROR: Expecting an element name.", [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        events = evaluate("<<?")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting an element name.",
                                   [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting a PI target.", [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ],
                                  L.Location("a buffer", -1)) ])

        events = evaluate("< ")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting an element name.",
                                   [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                DC(" ", true, L.Location("a buffer", -1)) ])
    end
end
