@testset "Events/Attributes" begin
    E = Events
    L = Events.Lexical

    AS = E.AttributeSpecification
    ES = E.ElementStart
    DC = E.DataContent
    ME = E.MarkupError

    @testset "Events/Attributes (Positive)" begin
        @test (collect(E.events(L.State(IOBuffer("<a b=\"c\">"))))
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a abc=\"def\">"))))
               == [ ES("a", [ AS("abc", [ DC("def", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a é=\"è\">"))))
               == [ ES("a", [ AS("é", [ DC("è", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a aé=\"aè\">"))))
               == [ ES("a", [ AS("aé", [ DC("aè", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a éb=\"èb\">"))))
               == [ ES("a", [ AS("éb", [ DC("èb", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a aéb=\"aèb\">"))))
               == [ ES("a", [ AS("aéb", [ DC("aèb", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        @test (collect(E.events(L.State(IOBuffer("<a b='c'>"))))
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a abc='def'>"))))
               == [ ES("a", [ AS("abc", [ DC("def", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a é='è'>"))))
               == [ ES("a", [ AS("é", [ DC("è", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a aé='aè'>"))))
               == [ ES("a", [ AS("aé", [ DC("aè", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a éb='èb'>"))))
               == [ ES("a", [ AS("éb", [ DC("èb", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a aéb='aèb'>"))))
               == [ ES("a", [ AS("aéb", [ DC("aèb", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        @test (collect(E.events(L.State(IOBuffer("<a b = \"c\">"))))
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a abc = \"def\">"))))
               == [ ES("a", [ AS("abc", [ DC("def", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a é = \"è\">"))))
               == [ ES("a", [ AS("é", [ DC("è", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a aé = \"aè\">"))))
               == [ ES("a", [ AS("aé", [ DC("aè", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a éb = \"èb\">"))))
               == [ ES("a", [ AS("éb", [ DC("èb", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a aéb = \"aèb\">"))))
               == [ ES("a", [ AS("aéb", [ DC("aèb", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        @test (collect(E.events(L.State(IOBuffer("<a b=\"c\" d=\"e\">"))))
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                              AS("d", [ DC("e", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        @test (collect(E.events(L.State(IOBuffer("<a b=\"c\" d=\"e\" f=\"g\">"))))
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                              AS("d", [ DC("e", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                              AS("f", [ DC("g", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        # Make sure any white space can be used as a separator.
        #
        @test (collect(E.events(L.State(IOBuffer("<a\tb=\"c\"\nd=\"e\"\rf=\"g\">"))))
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                              AS("d", [ DC("e", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                              AS("f", [ DC("g", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        # Make sure trailing white space is consumed.
        #
        @test (collect(E.events(L.State(IOBuffer("<a b=\"c\" >"))))
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a b=\"c\"\n>"))))
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a b=\"c\"      >"))))
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        # Check that attribute values can contain allowed special characters. Well, try a few representative cases.
        #
        @test (collect(E.events(L.State(IOBuffer("<a b=\" \">"))))
               == [ ES("a", [ AS("b", [ DC(" ", true, L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a b=\"&amp;\">"))))
               == [ ES("a", [ AS("b", [ E.EntityReferenceGeneral("amp", L.Location("a buffer", -1)) ],
                                 L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a b=\"&#20;\">"))))
               == [ ES("a", [ AS("b", [ E.CharacterReference("20", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        # Make sure that the "other" quotes can be used inside the attribute value.
        #
        @test (collect(E.events(L.State(IOBuffer("<a b=\"'Hello'\">"))))
               == [ ES("a", [ AS("b", [ DC("'", false, L.Location("a buffer", -1)),
                                        DC("Hello", false, L.Location("a buffer", -1)),
                                        DC("'", false, L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a b='\"Hello\"'>"))))
               == [ ES("a", [ AS("b", [ DC("\"", false, L.Location("a buffer", -1)),
                                        DC("Hello", false, L.Location("a buffer", -1)),
                                        DC("\"", false, L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
    end

    @testset "Events/Attributes (Negative ... no VI)" begin
        # Be careful here ... the attributes parser bails as soon as it sees the VI is missing, and then another parser
        # can kick in. So only check the FIRST events.
        #
        @test (collect(E.events(L.State(IOBuffer("<a b"))))
               == [ ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting '=' after an attribute name.",
                                                        [ ], L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '>' to end an element open tag.", [ ], L.Location("a buffer", -1)) ])

        events = collect(E.events(L.State(IOBuffer("<a b \"c\">"))))
        @test length(events) > 1
        @test first(events) == ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting '=' after an attribute name.",
                                                                   [ ], L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1))

        events = collect(E.events(L.State(IOBuffer("<a b=\"c\" d\"e\">"))))
        @test length(events) > 1
        @test first(events) == ES(true, false, "a", [ AS("b", [ DC("c", false, L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)),
                                                      AS("d", [ ME("ERROR: Expecting '=' after an attribute name.",
                                                                   [ ], L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1))
    end

    @testset "Events/Attributes (Negative ... no quoted value)" begin
        # Be careful here ... the attributes parser bails as soon as it sees the VI is missing, and then another parser
        # can kick in. So only check the FIRST events.
        #
        events = collect(E.events(L.State(IOBuffer("<a b="))))
        @test length(events) > 1
        @test first(events) == ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting a quoted attribute value after '='.",
                                                                   [ ], L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1))
        events = collect(E.events(L.State(IOBuffer("<a b = "))))
        @test length(events) > 1
        @test first(events) == ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting a quoted attribute value after '='.",
                                                                   [ ], L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1))
        events = collect(E.events(L.State(IOBuffer("<a b=c"))))
        @test length(events) > 1
        @test first(events) == ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting a quoted attribute value after '='.",
                                                                   [ ], L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1))
        events = collect(E.events(L.State(IOBuffer("<a b= c"))))
        @test length(events) > 1
        @test first(events) == ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting a quoted attribute value after '='.",
                                                                   [ ], L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1))
    end

    @testset "Events/Attributes (Negative ... incomplete quoted value)" begin
        # Be careful here ... the attributes parser bails as soon as it sees the VI is missing, and then another parser
        # can kick in. So only check the FIRST events.
        #
        events = collect(E.events(L.State(IOBuffer("<a b=\""))))
        @test length(events) > 1
        @test first(events) == ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting the remainder of an attribute value.",
                                                                   [ ], L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1))
        events = collect(E.events(L.State(IOBuffer("<a b=\"c"))))
        @test length(events) > 1
        @test first(events) == ES(true, false, "a", [ AS("b", [ DC("c", false, L.Location("a buffer", -1)),
                                                                ME("ERROR: Expecting the remainder of an attribute value.",
                                                                   [ ], L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1))
    end

    @testset "Events/Attributes (Negative ... unescaped special characters)" begin
        @test (collect(E.events(L.State(IOBuffer("<a b=\"<\">"))))
               == [ ES(false, false, "a", [ AS("b", [ ME("ERROR: A '<' must be escaped inside an attribute value.",
                                                         [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a b=\"<<<\">"))))
               == [ ES(false, false, "a", [ AS("b", [ ME("ERROR: A '<' must be escaped inside an attribute value.",
                                                         [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)),
                                                      ME("ERROR: A '<' must be escaped inside an attribute value.",
                                                         [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)),
                                                      ME("ERROR: A '<' must be escaped inside an attribute value.",
                                                         [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                    L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a b=\"Hello, <World!\">"))))
               == [ ES(false, false, "a", [ AS("b", [ DC("Hello", false, L.Location("a buffer", -1)),
                                                      DC(",", false, L.Location("a buffer", -1)),
                                                      DC(" ", true, L.Location("a buffer", -1)),
                                                      ME("ERROR: A '<' must be escaped inside an attribute value.",
                                                         [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)),
                                                      DC("World!", false, L.Location("a buffer", -1)) ],
                                            L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        @test (collect(E.events(L.State(IOBuffer("<a b=\"&\">"))))
               == [ ES(false, false, "a", [ AS("b", [ ME("ERROR: A '&' must be escaped inside an attribute value.",
                                                         [ L.Token(L.ero, "&", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a b=\"&&&\">"))))
               == [ ES(false, false, "a", [ AS("b", [ ME("ERROR: A '&' must be escaped inside an attribute value.",
                                                         [ L.Token(L.ero, "&", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)),
                                                      ME("ERROR: A '&' must be escaped inside an attribute value.",
                                                         [ L.Token(L.ero, "&", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)),
                                                      ME("ERROR: A '&' must be escaped inside an attribute value.",
                                                         [ L.Token(L.ero, "&", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                    L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<a b=\"Jack & Jill\">"))))
               == [ ES(false, false, "a", [ AS("b", [ DC("Jack", false, L.Location("a buffer", -1)),
                                                      DC(" ", true, L.Location("a buffer", -1)),
                                                      ME("ERROR: A '&' must be escaped inside an attribute value.",
                                                         [ L.Token(L.ero, "&", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)),
                                                      DC(" ", true, L.Location("a buffer", -1)),
                                                      DC("Jill", false, L.Location("a buffer", -1)) ],
                                            L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
    end
end
