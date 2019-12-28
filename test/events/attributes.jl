@testset "Events/Attributes" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    AS = E.AttributeSpecification
    ES = E.ElementStart
    DC = E.DataContent
    ME = E.MarkupError

    @testset "Events/Attributes (Positive)" begin
        @test (evaluate("<a b=\"c\">") == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a abc=\"def\">") == [ ES("a", [ AS("abc", [ DC("def", L.Location("a buffer", -1)) ],
                                                             L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a é=\"è\">") == [ ES("a", [ AS("é", [ DC("è", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a aé=\"aè\">") == [ ES("a", [ AS("aé", [ DC("aè", L.Location("a buffer", -1)) ],
                                                           L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a éb=\"èb\">") == [ ES("a", [ AS("éb", [ DC("èb", L.Location("a buffer", -1)) ],
                                                           L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a aéb=\"aèb\">") == [ ES("a", [ AS("aéb", [ DC("aèb", L.Location("a buffer", -1)) ],
                                                             L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        @test (evaluate("<a b='c'>") == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                                             L.Location("a buffer", -1)) ])
        @test (evaluate("<a abc='def'>") == [ ES("a", [ AS("abc", [ DC("def", L.Location("a buffer", -1)) ],
                                                           L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a é='è'>") == [ ES("a", [ AS("é", [ DC("è", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                                             L.Location("a buffer", -1)) ])
        @test (evaluate("<a aé='aè'>") == [ ES("a", [ AS("aé", [ DC("aè", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a éb='èb'>") == [ ES("a", [ AS("éb", [ DC("èb", L.Location("a buffer", -1)) ],
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a aéb='aèb'>") == [ ES("a", [ AS("aéb", [ DC("aèb", L.Location("a buffer", -1)) ],
                                                           L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        @test (evaluate("<a b = \"c\">") == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ],
                                                           L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a abc = \"def\">") == [ ES("a", [ AS("abc", [ DC("def", L.Location("a buffer", -1)) ],
                                                               L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a é = \"è\">") == [ ES("a", [ AS("é", [ DC("è", L.Location("a buffer", -1)) ],
                                                           L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a aé = \"aè\">") == [ ES("a", [ AS("aé", [ DC("aè", L.Location("a buffer", -1)) ],
                                                             L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a éb = \"èb\">") == [ ES("a", [ AS("éb", [ DC("èb", L.Location("a buffer", -1)) ],
                                                             L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a aéb = \"aèb\">") == [ ES("a", [ AS("aéb", [ DC("aèb", L.Location("a buffer", -1)) ],
                                                               L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        @test (evaluate("<a b=\"c\" d=\"e\">")
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                              AS("d", [ DC("e", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        @test (evaluate("<a b=\"c\" d=\"e\" f=\"g\">")
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                              AS("d", [ DC("e", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                              AS("f", [ DC("g", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        # Make sure any white space can be used as a separator.
        #
        @test (evaluate("<a\tb=\"c\"\nd=\"e\"\rf=\"g\">")
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                              AS("d", [ DC("e", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                              AS("f", [ DC("g", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        # Make sure trailing white space is consumed.
        #
        @test (evaluate("<a b=\"c\" >")
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (evaluate("<a b=\"c\"\n>")
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (evaluate("<a b=\"c\"      >")
               == [ ES("a", [ AS("b", [ DC("c", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        # Check that attribute values can contain allowed special characters. Well, try a few representative cases.
        #
        @test (evaluate("<a b=\" \">")
               == [ ES("a", [ AS("b", [ DC(" ", true, L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (evaluate("<a b=\"&amp;\">")
               == [ ES("a", [ AS("b", [ E.EntityReferenceGeneral("amp", L.Location("a buffer", -1)) ],
                                 L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (evaluate("<a b=\"&#20;\">")
               == [ ES("a", [ AS("b", [ E.CharacterReference("20", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        # Make sure that the "other" quotes can be used inside the attribute value.
        #
        @test (evaluate("<a b=\"'Hello'\">")
               == [ ES("a", [ AS("b", [ DC("'", false, L.Location("a buffer", -1)),
                                        DC("Hello", false, L.Location("a buffer", -1)),
                                        DC("'", false, L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
        @test (evaluate("<a b='\"Hello\"'>")
               == [ ES("a", [ AS("b", [ DC("\"", false, L.Location("a buffer", -1)),
                                        DC("Hello", false, L.Location("a buffer", -1)),
                                        DC("\"", false, L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])
    end

    @testset "Events/Attributes (Negative ... no VI)" begin
        @test (evaluate("<a b")
               == [ ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting '=' after an attribute name.",
                                                        L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '>' to end an element open tag.", L.Location("a buffer", -1)) ])

        events = evaluate("<a b \"c\">")
        @test length(events) == 6
        @test events == [ ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting '=' after an attribute name.",
                                                              L.Location("a buffer", -1)) ],
                                               L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),

                          ME("ERROR: Expecting '>' to end an element open tag.", L.Location("a buffer", -1)),
                          DC("\"", false, L.Location("a buffer", -1)),
                          DC("c", false, L.Location("a buffer", -1)),
                          DC("\"", false, L.Location("a buffer", -1)),
                          DC(">", false, L.Location("a buffer", -1)) ]

        events = evaluate("<a b=\"c\" d\"e\">")
        @test length(events) == 6
        @test events == [ ES(true, false, "a", [ AS("b", [ DC("c", false, L.Location("a buffer", -1)) ],
                                                    L.Location("a buffer", -1)),
                                                 AS("d", [ ME("ERROR: Expecting '=' after an attribute name.",
                                                              L.Location("a buffer", -1)) ],
                                                    L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                          ME("ERROR: Expecting '>' to end an element open tag.", L.Location("a buffer", -1)),
                          DC("\"", false, L.Location("a buffer", -1)),
                          DC("e", false, L.Location("a buffer", -1)),
                          DC("\"", false, L.Location("a buffer", -1)),
                          DC(">", false, L.Location("a buffer", -1)) ]

    end

    @testset "Events/Attributes (Negative ... no quoted value)" begin
        events = evaluate("<a b=")
        @test length(events) == 2
        @test events == [ ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting a quoted attribute value after '='.",
                                                              L.Location("a buffer", -1)) ],
                                                L.Location("a buffer", -1)) ], L.Location("a buffer", -1))
                          ME("ERROR: Expecting '>' to end an element open tag.", L.Location("a buffer", -1)) ]

        events = evaluate("<a b = ")
        @test length(events) == 2
        @test events == [ ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting a quoted attribute value after '='.",
                                                              L.Location("a buffer", -1)) ],
                                                L.Location("a buffer", -1)) ], L.Location("a buffer", -1))
                          ME("ERROR: Expecting '>' to end an element open tag.", L.Location("a buffer", -1)) ]

        events = evaluate("<a b=c")
        @test length(events) == 3
        @test events == [ ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting a quoted attribute value after '='.",
                                                              L.Location("a buffer", -1)) ],
                                                L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                          ME("ERROR: Expecting '>' to end an element open tag.", L.Location("a buffer", -1)),
                          DC("c", false, L.Location("a buffer", -1)) ]

        events = evaluate("<a b= c")
        @test length(events) == 3
        @test events == [ ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting a quoted attribute value after '='.",
                                                              L.Location("a buffer", -1)) ],
                                                L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                          ME("ERROR: Expecting '>' to end an element open tag.", L.Location("a buffer", -1)),
                          DC("c", false, L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attributes (Negative ... incomplete quoted value)" begin
        events = evaluate("<a b=\"")
        @test length(events) == 2
        @test events == [ ES(true, false, "a", [ AS("b", [ ME("ERROR: Expecting the remainder of an attribute value.",
                                                              L.Location("a buffer", -1)) ],
                                                L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                          ME("ERROR: Expecting '>' to end an element open tag.", L.Location("a buffer", -1)) ]

        events = evaluate("<a b=\"c")
        @test length(events) == 2
        @test events == [ ES(true, false, "a", [ AS("b", [ DC("c", false, L.Location("a buffer", -1)),
                                                           ME("ERROR: Expecting the remainder of an attribute value.",
                                                              L.Location("a buffer", -1)) ],
                                                L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                          ME("ERROR: Expecting '>' to end an element open tag.", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attributes (Negative ... unescaped special characters)" begin
        @test (evaluate("<a b=\"<\">")
               == [ ES(false, false, "a", [ AS("b", [ ME("ERROR: A '<' must be escaped inside an attribute value.",
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        @test (evaluate("<a b=\"<<<\">")
               == [ ES(false, false, "a", [ AS("b", [ ME("ERROR: A '<' must be escaped inside an attribute value.",
                                                         L.Location("a buffer", -1)),
                                                      ME("ERROR: A '<' must be escaped inside an attribute value.",
                                                         L.Location("a buffer", -1)),
                                                      ME("ERROR: A '<' must be escaped inside an attribute value.",
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                    L.Location("a buffer", -1)) ])

        @test (evaluate("<a b=\"Hello, <World!\">")
               == [ ES(false, false, "a", [ AS("b", [ DC("Hello", false, L.Location("a buffer", -1)),
                                                      DC(",", false, L.Location("a buffer", -1)),
                                                      DC(" ", true, L.Location("a buffer", -1)),
                                                      ME("ERROR: A '<' must be escaped inside an attribute value.",
                                                         L.Location("a buffer", -1)),
                                                      DC("World!", false, L.Location("a buffer", -1)) ],
                                            L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        @test (evaluate("<a b=\"&\">")
               == [ ES(false, false, "a", [ AS("b", [ ME("ERROR: A '&' must be escaped inside an attribute value.",
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                       L.Location("a buffer", -1)) ])

        @test (evaluate("<a b=\"&&&\">")
               == [ ES(false, false, "a", [ AS("b", [ ME("ERROR: A '&' must be escaped inside an attribute value.",
                                                         L.Location("a buffer", -1)),
                                                      ME("ERROR: A '&' must be escaped inside an attribute value.",
                                                         L.Location("a buffer", -1)),
                                                      ME("ERROR: A '&' must be escaped inside an attribute value.",
                                                         L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ],
                    L.Location("a buffer", -1)) ])

        @test (evaluate("<a b=\"Jack & Jill\">")
               == [ ES(false, false, "a", [ AS("b", [ DC("Jack", false, L.Location("a buffer", -1)),
                                                      DC(" ", true, L.Location("a buffer", -1)),
                                                      ME("ERROR: A '&' must be escaped inside an attribute value.",
                                                         L.Location("a buffer", -1)),
                                                      DC(" ", true, L.Location("a buffer", -1)),
                                                      DC("Jill", false, L.Location("a buffer", -1)) ],
                                            L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
    end
end
