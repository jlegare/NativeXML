@testset "Events/Attributes" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Attributes (Positive)" begin
        @test (collect(E.events(L.State(IOBuffer("<a b=\"c\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("b", [ E.DataContent("c", "a buffer", -1) ], "a buffer", -1) ],
                                   "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a abc=\"def\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("abc", [ E.DataContent("def", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a é=\"è\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("é", [ E.DataContent("è", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a aé=\"aè\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("aé", [ E.DataContent("aè", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a éb=\"èb\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("éb", [ E.DataContent("èb", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a aéb=\"aèb\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("aéb", [ E.DataContent("aèb", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("<a b='c'>"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("b", [ E.DataContent("c", "a buffer", -1) ], "a buffer", -1) ],
                                   "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a abc='def'>"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("abc", [ E.DataContent("def", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a é='è'>"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("é", [ E.DataContent("è", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a aé='aè'>"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("aé", [ E.DataContent("aè", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a éb='èb'>"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("éb", [ E.DataContent("èb", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a aéb='aèb'>"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("aéb", [ E.DataContent("aèb", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("<a b = \"c\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("b", [ E.DataContent("c", "a buffer", -1) ], "a buffer", -1) ],
                                   "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a abc = \"def\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("abc", [ E.DataContent("def", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a é = \"è\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("é", [ E.DataContent("è", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a aé = \"aè\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("aé", [ E.DataContent("aè", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a éb = \"èb\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("éb", [ E.DataContent("èb", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a aéb = \"aèb\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("aéb", [ E.DataContent("aèb", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("<a b=\"c\" d=\"e\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("b", [ E.DataContent("c", "a buffer", -1) ], "a buffer", -1),
                                          E.AttributeSpecification("d", [ E.DataContent("e", "a buffer", -1) ], "a buffer", -1) ],
                                   "a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("<a b=\"c\" d=\"e\" f=\"g\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("b", [ E.DataContent("c", "a buffer", -1) ], "a buffer", -1),
                                          E.AttributeSpecification("d", [ E.DataContent("e", "a buffer", -1) ], "a buffer", -1),
                                          E.AttributeSpecification("f", [ E.DataContent("g", "a buffer", -1) ], "a buffer", -1) ],
                                   "a buffer", -1) ])

        # Make sure any white space can be used as a separator.
        #
        @test (collect(E.events(L.State(IOBuffer("<a\tb=\"c\"\nd=\"e\"\rf=\"g\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("b", [ E.DataContent("c", "a buffer", -1) ], "a buffer", -1),
                                          E.AttributeSpecification("d", [ E.DataContent("e", "a buffer", -1) ], "a buffer", -1),
                                          E.AttributeSpecification("f", [ E.DataContent("g", "a buffer", -1) ], "a buffer", -1) ],
                                   "a buffer", -1) ])

        # Check that attribute values can contain allowed special characters.
        #
        @test (collect(E.events(L.State(IOBuffer("<a b=\" \">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("b", [ E.DataContent(" ", true, "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a b=\"&amp;\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("b", [ E.EntityReferenceGeneral("amp", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a b=\"&#20;\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("b", [ E.CharacterReference("20", "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])

        # Make sure that the "other" quotes can be used inside the attribute value.
        #
        @test (collect(E.events(L.State(IOBuffer("<a b=\"'Hello'\">"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("b", [ E.DataContent("'", false, "a buffer", -1),
                                                                          E.DataContent("Hello", false, "a buffer", -1),
                                                                          E.DataContent("'", false, "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<a b='\"Hello\"'>"))))
               == [ E.ElementStart("a", [ E.AttributeSpecification("b", [ E.DataContent("\"", false, "a buffer", -1),
                                                                          E.DataContent("Hello", false, "a buffer", -1),
                                                                          E.DataContent("\"", false, "a buffer", -1) ],
                                                                   "a buffer", -1) ], "a buffer", -1) ])
    end
end
