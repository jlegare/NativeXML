@testset "Events/Document Type Declaration" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    ExternalID = E.ExternalIdentifier

    DTDStart = E.DTDStart
    DTDEnd   = E.DTDEnd

    DTDInternalStart = E.DTDInternalStart

    DC = E.DataContent
    ME = E.MarkupError

    @testset "Events/Document Type Declaration (Positive)" begin
        # Basic tests ... no external/internal subset specification.
        #
        @test (evaluate("<!DOCTYPE a>") == [ DTDStart("a", nothing, L.Location("a buffer", -1)),
                                             DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE abc>") == [ DTDStart("abc", nothing, L.Location("a buffer", -1)),
                                               DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE é>") == [ DTDStart("é", nothing, L.Location("a buffer", -1)),
                                             DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE aé>") == [ DTDStart("aé", nothing, L.Location("a buffer", -1)),
                                              DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE éb>") == [ DTDStart("éb", nothing, L.Location("a buffer", -1)),
                                              DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE aéb>") == [ DTDStart("aéb", nothing, L.Location("a buffer", -1)),
                                               DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE\na\t>") == [ DTDStart("a", nothing, L.Location("a buffer", -1)),
                                                DTDEnd(L.Location("a buffer", -1)) ])

        # Basic tests ... no internal subset specification. Assume the document type name is handled correctly.
        #
        @test (evaluate("<!DOCTYPE a SYSTEM \"\">")
               == [ DTDStart("a", ExternalID(nothing, "", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE a\nSYSTEM\t\"\"	>")
               == [ DTDStart("a", ExternalID(nothing, "", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE a SYSTEM \"   \">")
               == [ DTDStart("a", ExternalID(nothing, "   ", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE a PUBLIC \"\" \"\">")
               == [ DTDStart("a", ExternalID("", "", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE a\nPUBLIC\r\"\"\t\"\"	>")
               == [ DTDStart("a", ExternalID("", "", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE a PUBLIC \"   \" \"   \">")
               == [ DTDStart("a", ExternalID("   ", "   ", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 2.8 ...
        #
        @test (evaluate("<!DOCTYPE greeting SYSTEM \"hello.dtd\">")
               == [ DTDStart("greeting", ExternalID(nothing, "hello.dtd", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])
        #
        # ... with a few simple variations ...
        #
        @test (evaluate("<!DOCTYPE greeting SYSTEM 'hello.dtd'>")
               == [ DTDStart("greeting", ExternalID(nothing, "hello.dtd", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE greeting SYSTEM '\"hello.dtd\"'>")
               == [ DTDStart("greeting", ExternalID(nothing, "\"hello.dtd\"", L.Location("a buffer", -1)),
                             L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE greeting SYSTEM \"'hello.dtd'\">")
               == [ DTDStart("greeting", ExternalID(nothing, "'hello.dtd'", L.Location("a buffer", -1)),
                             L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])
        #
        # ... and a few variations that add a public identifier. (Yes, these public identifiers are bogus. That isn't
        # the point of these tests.)
        #
        @test (evaluate("<!DOCTYPE greeting PUBLIC 'salut.dtd' 'hello.dtd'>")
               == [ DTDStart("greeting", ExternalID("salut.dtd", "hello.dtd", L.Location("a buffer", -1)),
                             L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE greeting PUBLIC '\"salut.dtd\"' '\"hello.dtd\"'>")
               == [ DTDStart("greeting", ExternalID("\"salut.dtd\"", "\"hello.dtd\"", L.Location("a buffer", -1)),
                             L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE greeting PUBLIC \"'salut.dtd'\" \"'hello.dtd'\">")
               == [ DTDStart("greeting", ExternalID("'salut.dtd'", "'hello.dtd'", L.Location("a buffer", -1)),
                             L.Location("a buffer", -1)),
                    DTDEnd(L.Location("a buffer", -1)) ])

        # Basic tests ... no external subset specification. Assume the document type name is handled correctly.
        #
        @test (evaluate("<!DOCTYPE a [") == [ DTDStart("a", nothing, L.Location("a buffer", -1)),
                                              DTDInternalStart(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE a[") == [ DTDStart("a", nothing, L.Location("a buffer", -1)),
                                             DTDInternalStart(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE a\n[") == [ DTDStart("a", nothing, L.Location("a buffer", -1)),
                                               DTDInternalStart(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE a	[") == [ DTDStart("a", nothing, L.Location("a buffer", -1)),
                                                 DTDInternalStart(L.Location("a buffer", -1)) ])
    end

    @testset "Events/Document Type Declaration (Negative ... invalid or absent document type name.)" begin
        @test (evaluate("<!DOCTYPE")
               == [ ME("ERROR: Expecting a root element name.",
                       [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                         L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        events = evaluate("<!DOCTYPE>")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting a root element name.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                DC(">", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!DOCTYPE >")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting a root element name.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                DC(">", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!DOCTYPE [")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting a root element name.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                DC("[", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!DOCTYPE \"root\"")
        @test length(events) >= 4
        @test (events[1:4] == [ ME("ERROR: Expecting a root element name.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                DC("\"", false, L.Location("a buffer", -1)),
                                DC("root", false, L.Location("a buffer", -1)),
                                DC("\"", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!DOCTYPE 'root'")
        @test length(events) >= 4
        @test (events[1:4] == [ ME("ERROR: Expecting a root element name.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                DC("\'", false, L.Location("a buffer", -1)),
                                DC("root", false, L.Location("a buffer", -1)),
                                DC("\'", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!DOCTYPE <")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting a root element name.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting an element name.",
                                   [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
    end

    @testset "Events/Document Type Declaration (Negative ... missing TAGC.)" begin
        events = evaluate("<!DOCTYPE root")
        @test length(events) == 1
        @test (events[1] == ME("ERROR: Expecting '>' to end a document type declaration.",
                               [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                 L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)),
                                 L.Token(L.text, "root", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE root SYSTEM \"'hello.dtd'\"")
        @test length(events) == 1
        @test (events[1] == ME("ERROR: Expecting '>' to end a document type declaration.",
                               [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                 L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)),
                                 L.Token(L.text, "root", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE root PUBLIC \"'salut.dtd'\" \"'hello.dtd'\"")
        @test length(events) == 1
        @test (events[1] == ME("ERROR: Expecting '>' to end a document type declaration.",
                               [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                 L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)),
                                 L.Token(L.text, "root", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end

    @testset "Events/Document Type Declaration (Negative ... missing string following PUBLIC or SYSTEM.)" begin
        events = evaluate("<!DOCTYPE a PUBLIC")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a document type declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)),
                                     L.Token(L.text, "a", L.Location("a buffer", -1)) ],
                                   L.Location("a buffer", -1)) ])

        # Make sure the trailing white space doesn't throw things off.
        #
        events = evaluate("<!DOCTYPE a PUBLIC ")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a document type declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)),
                                     L.Token(L.text, "a", L.Location("a buffer", -1)) ],
                                   L.Location("a buffer", -1)) ])

        events = evaluate("<!DOCTYPE a PUBLIC>")
        @test length(events) >= 3
        @test (events[1:3] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                DTDStart("a", nothing, L.Location("a buffer", -1)),
                                DTDEnd(L.Location("a buffer", -1)) ])

        events = evaluate("<!DOCTYPE a PUBLIC[")
        @test length(events) >= 3
        @test (events[1:3] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                DTDStart("a", nothing, L.Location("a buffer", -1)),
                                DTDInternalStart(L.Location("a buffer", -1)) ])

        events = evaluate("<!DOCTYPE a SYSTEM")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a document type declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)),
                                     L.Token(L.text, "a", L.Location("a buffer", -1)) ],
                                   L.Location("a buffer", -1)) ])

        # Make sure the trailing white space doesn't throw things off.
        #
        events = evaluate("<!DOCTYPE a SYSTEM ")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a document type declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)),
                                     L.Token(L.text, "a", L.Location("a buffer", -1)) ],
                                   L.Location("a buffer", -1)) ])

        events = evaluate("<!DOCTYPE a SYSTEM>")
        @test length(events) >= 3
        @test (events[1:3] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                DTDStart("a", nothing, L.Location("a buffer", -1)),
                                DTDEnd(L.Location("a buffer", -1)) ])

        events = evaluate("<!DOCTYPE a SYSTEM[")
        @test length(events) >= 3
        @test (events[1:3] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                DTDStart("a", nothing, L.Location("a buffer", -1)),
                                DTDInternalStart(L.Location("a buffer", -1)) ])
    end

    @testset "Events/Document Type Declaration (Negative ... missing white space between public and system identifier.)" begin
        events = evaluate("<!DOCTYPE root PUBLIC \"'salut.dtd'\"\"'hello.dtd'\">")
        @test length(events) >= 3
        @test (events[1:3] == [ ME("ERROR: Expecting white space following a public identifier.",
                                   [ ], L.Location("a buffer", -1)),
                                DTDStart("root", ExternalID("'salut.dtd'", "'hello.dtd'", L.Location("a buffer", -1)),
                                         L.Location("a buffer", -1)),
                                DTDEnd(L.Location("a buffer", -1)) ])
    end

    @testset "Events/Document Type Declaration (Negative ... missing system identifier following public identifier.)" begin
        events = evaluate("<!DOCTYPE root PUBLIC \"'salut.dtd'\" >")
        @test length(events) >= 4
        @test (events[1:4] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting a system identifier following a public identifier.",
                                   [ ], L.Location("a buffer", -1)),
                                DTDStart("root", ExternalID("'salut.dtd'", nothing, L.Location("a buffer", -1)),
                                         L.Location("a buffer", -1)),
                                DTDEnd(L.Location("a buffer", -1)) ])
    end
end
