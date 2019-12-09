@testset "Events/Notation Declarations" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    function NotationDeclaration(name, public_id, system_id, location)
        return E.NotationDeclaration(name, E.ExternalIdentifier(public_id, system_id, location), location)
    end

    @testset "Events/Notation Declarations (Positive)" begin
        # Basic tests ... fixed public/system identifier.
        #
        @test (evaluate("<!NOTATION a PUBLIC \"hello.not\" \"salut.not\">")
               == [ NotationDeclaration("a", "hello.not", "salut.not", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION abc PUBLIC \"hello.not\" \"salut.not\">")
               == [ NotationDeclaration("abc", "hello.not", "salut.not", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION é PUBLIC \"hello.not\" \"salut.not\">")
               == [ NotationDeclaration("é", "hello.not", "salut.not", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION aé PUBLIC \"hello.not\" \"salut.not\">")
               == [ NotationDeclaration("aé", "hello.not", "salut.not", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION éb PUBLIC \"hello.not\" \"salut.not\">")
               == [ NotationDeclaration("éb", "hello.not", "salut.not", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION aéb PUBLIC \"hello.not\" \"salut.not\">")
               == [ NotationDeclaration("aéb", "hello.not", "salut.not", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION\na\nPUBLIC \"hello.not\" \"salut.not\">")
               == [ NotationDeclaration("a", "hello.not", "salut.not", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION\na\tPUBLIC \"hello.not\" \"salut.not\">")
               == [ NotationDeclaration("a", "hello.not", "salut.not", L.Location("a buffer", -1)) ])

        # Basic tests ... fixed notation name ...
        #
        @test (evaluate("<!NOTATION a SYSTEM \"\">") == [ NotationDeclaration("a", nothing, "", L.Location("a buffer", -1)) ])
        @test (evaluate("<!NOTATION a\nSYSTEM\t\"\"	>")
               == [ NotationDeclaration("a", nothing, "", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a SYSTEM \"   \">") == [ NotationDeclaration("a", nothing, "   ", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a PUBLIC \"\" \"\">") == [ NotationDeclaration("a", "", "", L.Location("a buffer", -1)) ])
        @test (evaluate("<!NOTATION a\nPUBLIC\r\"\"\t\"\"	>") 
               == [ NotationDeclaration("a", "", "", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a PUBLIC \"   \" \"   \">")
               == [ NotationDeclaration("a", "   ", "   ", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a SYSTEM \"hello.not\">")
               == [ NotationDeclaration("a", nothing, "hello.not", L.Location("a buffer", -1)) ])

        # ... fixed notation name with system identifier ...
        #
        @test (evaluate("<!NOTATION a SYSTEM \"hello.not\">")
               == [ NotationDeclaration("a", nothing, "hello.not", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a SYSTEM 'hello.not'>")
               == [ NotationDeclaration("a", nothing, "hello.not", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a SYSTEM '\"hello.not\"'>")
               == [ NotationDeclaration("a", nothing, "\"hello.not\"", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a SYSTEM \"'hello.not'\">")
               == [ NotationDeclaration("a", nothing, "'hello.not'", L.Location("a buffer", -1)) ])

        # ... fixed notation name with public/system identifier ...
        #
        @test (evaluate("<!NOTATION a PUBLIC \"salut.not\" \"hello.not\">")
               == [ NotationDeclaration("a", "salut.not", "hello.not", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a PUBLIC 'salut.not' 'hello.not'>")
               == [ NotationDeclaration("a", "salut.not", "hello.not", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a PUBLIC '\"salut.not\"' '\"hello.not\"'>")
               == [ NotationDeclaration("a", "\"salut.not\"", "\"hello.not\"", L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a PUBLIC \"'salut.not'\" \"'hello.not'\">")
               == [ NotationDeclaration("a", "'salut.not'", "'hello.not'", L.Location("a buffer", -1)) ])

        # ... fixed notation name with public identifier ...
        #
        @test (evaluate("<!NOTATION a PUBLIC \"salut.not\">")
               == [ NotationDeclaration("a", "salut.not", nothing, L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a PUBLIC 'salut.not'>")
               == [ NotationDeclaration("a", "salut.not", nothing, L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a PUBLIC '\"salut.not\"'>")
               == [ NotationDeclaration("a", "\"salut.not\"", nothing, L.Location("a buffer", -1)) ])

        @test (evaluate("<!NOTATION a PUBLIC \"'salut.not'\">")
               == [ NotationDeclaration("a", "'salut.not'", nothing, L.Location("a buffer", -1)) ])
    end

    @testset "Events/Notation Declarations (Negative ... missing/invalid notation value.)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        events = evaluate("<!NOTATION n>")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: A notation declaration must specify an external identifier.", 
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                            L.Token(L.text, "n", L.Location("a buffer", -1)) ], 
                                          L.Location("a buffer", -1)))

        events = evaluate("<!NOTATION n >")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: A notation declaration must specify an external identifier.", 
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                            L.Token(L.text, "n", L.Location("a buffer", -1)) ], 
                                          L.Location("a buffer", -1)))

        events = evaluate("<!NOTATION n\n>")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: A notation declaration must specify an external identifier.", 
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                            L.Token(L.text, "n", L.Location("a buffer", -1)) ], 
                                          L.Location("a buffer", -1)))

        events = evaluate("<!NOTATION n PUBLIC")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!NOTATION n PUBLIC ")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!NOTATION n PUBLIC <")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!NOTATION n SYSTEM")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!NOTATION n SYSTEM ")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!NOTATION n SYSTEM <")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))
    end

    @testset "Events/Notation Declarations (Negative ... missing TAGC.)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        events = evaluate("<!NOTATION n PUBLIC \"salut.not\" \"hello.not\"")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting '>' to end a notation declaration.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                            L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!NOTATION n PUBLIC \"salut.not\" \"hello.not\" ")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting '>' to end a notation declaration.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                            L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))

        events = evaluate("<!NOTATION n PUBLIC \"salut.not\" \"hello.not\" <")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting '>' to end a notation declaration.",
                                          [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                            L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                            L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end

    @testset "Events/Notation Declarations (Negative ... missing white space between public and system identifier.)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        events = evaluate("<!NOTATION n PUBLIC \"salut.not\"\"hello.not\"")
        @test length(events) > 1
        @test (events[1] == E.MarkupError("ERROR: Expecting white space following a public identifier.",
                                          [ ], L.Location("a buffer", -1)))
    end
end
