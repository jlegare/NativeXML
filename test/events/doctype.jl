@testset "Events/Document Type Declaration" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    @testset "Events/Document Type Declaration (Positive)" begin
        # Basic tests ... no external/internal subset specification.
        #
        @test (evaluate("<!DOCTYPE a>") == [ E.DTDStart("a", nothing, L.Location("a buffer", -1)),
                                             E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE abc>") == [ E.DTDStart("abc", nothing, L.Location("a buffer", -1)),
                                               E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE é>") == [ E.DTDStart("é", nothing, L.Location("a buffer", -1)),
                                             E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE aé>") == [ E.DTDStart("aé", nothing, L.Location("a buffer", -1)),
                                              E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE éb>") == [ E.DTDStart("éb", nothing, L.Location("a buffer", -1)),
                                              E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE aéb>") == [ E.DTDStart("aéb", nothing, L.Location("a buffer", -1)),
                                               E.DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE\na\t>") == [ E.DTDStart("a", nothing, L.Location("a buffer", -1)),
                                                E.DTDEnd(L.Location("a buffer", -1)) ])

        # Basic tests ... no internal subset specification. Assume the document type name is handled correctly.
        #
        @test (evaluate("<!DOCTYPE a SYSTEM \"\">")
               == [ E.DTDStart("a", E.ExternalIdentifier(nothing, "", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE a\nSYSTEM\t\"\"	>")
               == [ E.DTDStart("a", E.ExternalIdentifier(nothing, "", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE a SYSTEM \"   \">")
               == [ E.DTDStart("a", E.ExternalIdentifier(nothing, "   ", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!DOCTYPE a PUBLIC \"\" \"\">")
               == [ E.DTDStart("a", E.ExternalIdentifier("", "", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE a\nPUBLIC\r\"\"\t\"\"	>")
               == [ E.DTDStart("a", E.ExternalIdentifier("", "", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE a PUBLIC \"   \" \"   \">")
               == [ E.DTDStart("a", E.ExternalIdentifier("   ", "   ", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 2.8 ...
        #
        @test (evaluate("<!DOCTYPE greeting SYSTEM \"hello.dtd\">")
               == [ E.DTDStart("greeting", E.ExternalIdentifier(nothing, "hello.dtd", L.Location("a buffer", -1)),
                               L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])
        #
        # ... with a few simple variations ...
        #
        @test (evaluate("<!DOCTYPE greeting SYSTEM 'hello.dtd'>")
               == [ E.DTDStart("greeting", E.ExternalIdentifier(nothing, "hello.dtd", L.Location("a buffer", -1)),
                               L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE greeting SYSTEM '\"hello.dtd\"'>")
               == [ E.DTDStart("greeting", E.ExternalIdentifier(nothing, "\"hello.dtd\"", L.Location("a buffer", -1)),
                               L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE greeting SYSTEM \"'hello.dtd'\">")
               == [ E.DTDStart("greeting", E.ExternalIdentifier(nothing, "'hello.dtd'", L.Location("a buffer", -1)),
                               L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])
        #
        # ... and a few variations that add a public identifier. (Yes, these public identifiers are bogus. That isn't
        # the point of these tests.)
        #
        @test (evaluate("<!DOCTYPE greeting PUBLIC 'salut.dtd' 'hello.dtd'>")
               == [ E.DTDStart("greeting", E.ExternalIdentifier("salut.dtd", "hello.dtd", L.Location("a buffer", -1)),
                               L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE greeting PUBLIC '\"salut.dtd\"' '\"hello.dtd\"'>")
               == [ E.DTDStart("greeting", E.ExternalIdentifier("\"salut.dtd\"", "\"hello.dtd\"", L.Location("a buffer", -1)),
                               L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE greeting PUBLIC \"'salut.dtd'\" \"'hello.dtd'\">")
               == [ E.DTDStart("greeting", E.ExternalIdentifier("'salut.dtd'", "'hello.dtd'", L.Location("a buffer", -1)),
                               L.Location("a buffer", -1)),
                    E.DTDEnd(L.Location("a buffer", -1)) ])

        # Basic tests ... no external subset specification. Assume the document type name is handled correctly.
        #
        @test (evaluate("<!DOCTYPE a [") == [ E.DTDStart("a", nothing, L.Location("a buffer", -1)),
                                              E.DTDInternalStart(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE a[") == [ E.DTDStart("a", nothing, L.Location("a buffer", -1)),
                                             E.DTDInternalStart(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE a\n[") == [ E.DTDStart("a", nothing, L.Location("a buffer", -1)),
                                               E.DTDInternalStart(L.Location("a buffer", -1)) ])
        @test (evaluate("<!DOCTYPE a	[") == [ E.DTDStart("a", nothing, L.Location("a buffer", -1)),
                                                 E.DTDInternalStart(L.Location("a buffer", -1)) ])
    end

    @testset "Events/Document Type Declaration (Negative ... invalid or absent document type name.)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        @test (evaluate("<!DOCTYPE")
               == [ E.MarkupError("ERROR: Expecting a root element name.",
                                  [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                    L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        events = evaluate("<!DOCTYPE>")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a root element name.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE >")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a root element name.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE [")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a root element name.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE \"root\"")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a root element name.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE 'root'")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a root element name.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE <")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a root element name.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

    end

    @testset "Events/Document Type Declaration (Negative ... missing TAGC.)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        events = evaluate("<!DOCTYPE root")
        @test length(events) == 1
        @test (events[1] == E.MarkupError("ERROR: Expecting '>' to end a document type declaration.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)),
                                            L.Token(L.text, "root", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE root SYSTEM \"'hello.dtd'\"")
        @test length(events) == 1
        @test (events[1] == E.MarkupError("ERROR: Expecting '>' to end a document type declaration.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)),
                                            L.Token(L.text, "root", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE root PUBLIC \"'salut.dtd'\" \"'hello.dtd'\"")
        @test length(events) == 1
        @test (events[1] == E.MarkupError("ERROR: Expecting '>' to end a document type declaration.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)),
                                            L.Token(L.text, "root", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end

    @testset "Events/Document Type Declaration (Negative ... missing string following PUBLIC or SYSTEM.)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        events = evaluate("<!DOCTYPE a PUBLIC")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        # Make sure the trailing white space doesn't throw things off.
        #
        events = evaluate("<!DOCTYPE a PUBLIC ")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE a PUBLIC>")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE a PUBLIC[")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE a SYSTEM")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        # Make sure the trailing white space doesn't throw things off.
        #
        events = evaluate("<!DOCTYPE a SYSTEM ")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE a SYSTEM>")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!DOCTYPE a SYSTEM[")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))
    end

    @testset "Events/Document Type Declaration (Negative ... missing white space between public and system identifier.)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        events = evaluate("<!DOCTYPE root PUBLIC \"'salut.dtd'\"\"'hello.dtd'\">")
        @test length(events) == 3
        @test (events[1] == E.MarkupError("ERROR: Expecting white space following a public identifier.",
                                          [ ], L.Location("a buffer", -1)))
        @test (events[2] == E.DTDStart("root", E.ExternalIdentifier("'salut.dtd'", "'hello.dtd'", L.Location("a buffer", -1)),
                                       L.Location("a buffer", -1)))
        @test (events[3] == E.DTDEnd(L.Location("a buffer", -1)))
    end

    @testset "Events/Document Type Declaration (Negative ... missing system identifier following public identifier.)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the fist two
        # events. (Otherwise we're testing the results of some other part of the parser.) Note that we need to check two
        # events, because two markup errors are emitted in this situation, and we actually care about the second.
        #
        events = evaluate("<!DOCTYPE root PUBLIC \"'salut.dtd'\" >")
        @test length(events) > 2
        @test events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1))
        @test events[2] == E.MarkupError("ERROR: Expecting a system identifier following a public identifier.",
                                         [ ], L.Location("a buffer", -1))
    end
end
