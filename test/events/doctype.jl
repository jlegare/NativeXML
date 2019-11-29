@testset "Events/Document Type Declaration" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Document Type Declaration (Positive)" begin
        # Basic tests ... no external/internal subset specification.
        #
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a>")))) == [ E.DTDStart("a", nothing, "a buffer", -1), 
                                                                         E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE abc>")))) == [ E.DTDStart("abc", nothing, "a buffer", -1),
                                                                           E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE é>")))) == [ E.DTDStart("é", nothing, "a buffer", -1),
                                                                         E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE aé>")))) == [ E.DTDStart("aé", nothing, "a buffer", -1),
                                                                          E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE éb>")))) == [ E.DTDStart("éb", nothing, "a buffer", -1),
                                                                          E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE aéb>")))) == [ E.DTDStart("aéb", nothing, "a buffer", -1),
                                                                           E.DTDEnd("a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE\na\t>")))) == [ E.DTDStart("a", nothing, "a buffer", -1),
                                                                            E.DTDEnd("a buffer", -1) ])

        # Basic tests ... no internal subset specification. Assume the document type name is handled correctly.
        #
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a SYSTEM \"\">"))))
               == [ E.DTDStart("a", E.ExternalIdentifier(nothing, "", "a buffer", -1), "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a\nSYSTEM\t\"\"	>"))))
               == [ E.DTDStart("a", E.ExternalIdentifier(nothing, "", "a buffer", -1), "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a SYSTEM \"   \">"))))
               == [ E.DTDStart("a", E.ExternalIdentifier(nothing, "   ", "a buffer", -1), "a buffer", -1), 
                    E.DTDEnd("a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a PUBLIC \"\" \"\">"))))
               == [ E.DTDStart("a", E.ExternalIdentifier("", "", "a buffer", -1), "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a\nPUBLIC\r\"\"\t\"\"	>"))))
               == [ E.DTDStart("a", E.ExternalIdentifier("", "", "a buffer", -1), "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a PUBLIC \"   \" \"   \">"))))
               == [ E.DTDStart("a", E.ExternalIdentifier("   ", "   ", "a buffer", -1), "a buffer", -1), E.DTDEnd("a buffer", -1) ])

        # This is from the XML specification, § 2.8 ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting SYSTEM \"hello.dtd\">"))))
               == [ E.DTDStart("greeting", E.ExternalIdentifier(nothing, "hello.dtd", "a buffer", -1), "a buffer", -1), 
                    E.DTDEnd("a buffer", -1) ])
        #
        # ... with a few simple variations ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting SYSTEM 'hello.dtd'>"))))
               == [ E.DTDStart("greeting", E.ExternalIdentifier(nothing, "hello.dtd", "a buffer", -1), "a buffer", -1), 
                    E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting SYSTEM '\"hello.dtd\"'>"))))
               == [ E.DTDStart("greeting", E.ExternalIdentifier(nothing, "\"hello.dtd\"", "a buffer", -1), "a buffer", -1), 
                    E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting SYSTEM \"'hello.dtd'\">"))))
               == [ E.DTDStart("greeting", E.ExternalIdentifier(nothing, "'hello.dtd'", "a buffer", -1), "a buffer", -1), 
                    E.DTDEnd("a buffer", -1) ])
        #
        # ... and a few variations that add a public identifier. (Yes, these public identifiers are bogus. That isn't
        # the point of these tests.)
        #
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting PUBLIC 'salut.dtd' 'hello.dtd'>"))))
               == [ E.DTDStart("greeting", E.ExternalIdentifier("salut.dtd", "hello.dtd", "a buffer", -1), "a buffer", -1), 
                    E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting PUBLIC '\"salut.dtd\"' '\"hello.dtd\"'>"))))
               == [ E.DTDStart("greeting", E.ExternalIdentifier("\"salut.dtd\"", "\"hello.dtd\"", "a buffer", -1), "a buffer", -1), 
                    E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting PUBLIC \"'salut.dtd'\" \"'hello.dtd'\">"))))
               == [ E.DTDStart("greeting", E.ExternalIdentifier("'salut.dtd'", "'hello.dtd'", "a buffer", -1), "a buffer", -1), 
                    E.DTDEnd("a buffer", -1) ])

        # Basic tests ... no external subset specification. Assume the document type name is handled correctly.
        #
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a [")))) == [ E.DTDStart("a", nothing, "a buffer", -1), 
                                                                          E.DTDInternalStart("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a[")))) == [ E.DTDStart("a", nothing, "a buffer", -1), 
                                                                         E.DTDInternalStart("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a\n[")))) == [ E.DTDStart("a", nothing, "a buffer", -1), 
                                                                           E.DTDInternalStart("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a	[")))) == [ E.DTDStart("a", nothing, "a buffer", -1), 
                                                                            E.DTDInternalStart("a buffer", -1) ])
    end

    @testset "Events/Document Type Declaration (Negative ... invalid or absent document type name.)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE"))))
               == [ E.MarkupError("ERROR: Expecting a root element name.",
                                  [ L.Token(L.mdo, "<!", "a buffer", -1), L.Token(L.text, "DOCTYPE", "a buffer", -1) ],
                                  "a buffer", -1) ])
        events = collect(E.events(L.State(IOBuffer("<!DOCTYPE>"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting a root element name.",
                                              [ L.Token(L.mdo, "<!", "a buffer", -1),
                                                L.Token(L.text, "DOCTYPE", "a buffer", -1) ], "a buffer", -1))
        events = collect(E.events(L.State(IOBuffer("<!DOCTYPE >"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting a root element name.",
                                              [ L.Token(L.mdo, "<!", "a buffer", -1),
                                                L.Token(L.text, "DOCTYPE", "a buffer", -1) ], "a buffer", -1))
        events = collect(E.events(L.State(IOBuffer("<!DOCTYPE ["))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting a root element name.",
                                              [ L.Token(L.mdo, "<!", "a buffer", -1),
                                                L.Token(L.text, "DOCTYPE", "a buffer", -1) ], "a buffer", -1))
        events = collect(E.events(L.State(IOBuffer("<!DOCTYPE \"root\""))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting a root element name.",
                                              [ L.Token(L.mdo, "<!", "a buffer", -1),
                                                L.Token(L.text, "DOCTYPE", "a buffer", -1) ], "a buffer", -1))
        events = collect(E.events(L.State(IOBuffer("<!DOCTYPE 'root'"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting a root element name.",
                                              [ L.Token(L.mdo, "<!", "a buffer", -1),
                                                L.Token(L.text, "DOCTYPE", "a buffer", -1) ], "a buffer", -1))
        events = collect(E.events(L.State(IOBuffer("<!DOCTYPE <"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting a root element name.",
                                              [ L.Token(L.mdo, "<!", "a buffer", -1),
                                                L.Token(L.text, "DOCTYPE", "a buffer", -1) ], "a buffer", -1))
    end
end
