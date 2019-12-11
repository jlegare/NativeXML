@testset "Events/Notation Declarations" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    DC = E.DataContent
    ME = E.MarkupError

    function NotationDeclaration(name, public_id, system_id, location)
        return E.NotationDeclaration(name, E.ExternalIdentifier(public_id, system_id, location), location)
    end

    function NotationDeclaration(name, location)
        return E.NotationDeclaration(name, nothing, location)
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

    @testset "Events/Notation Declarations (Negative ... invalid or absent notation name.)" begin
        @test (evaluate("<!NOTATION")
               == [ ME("ERROR: Expecting a notation name.",
                       [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                         L.Token(L.text, "NOTATION", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION>")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting a notation name.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                DC(">", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION >")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting a notation name.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                DC(">", false, L.Location("a buffer", -1)) ])

        # This one is a little weird: we're picking up "PUBLIC" as the notation name. I'll have to figure out later if
        # that's allowed or not, but there doesn't appear to be anything in the specification that forbids it.
        #
        events = evaluate("<!NOTATION PUBLIC")
        @test length(events) >= 3
        @test (events[1:3] == [ ME("ERROR: A notation declaration must specify an external identifier.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "PUBLIC", L.Location("a buffer", -1)) ],
                                   L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a notation declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "PUBLIC", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("PUBLIC", L.Location("a buffer", -1)) ])

        # This one is a little weird: we're picking up "SYSTEM" as the notation name. I'll have to figure out later if
        # that's allowed or not, but there doesn't appear to be anything in the specification that forbids it.
        #
        events = evaluate("<!NOTATION SYSTEM")
        @test length(events) >= 3
        @test (events[1:3] == [ ME("ERROR: A notation declaration must specify an external identifier.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "SYSTEM", L.Location("a buffer", -1)) ],
                                   L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a notation declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "SYSTEM", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("SYSTEM", L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION \"\"")
        @test length(events) >= 3
        @test (events[1:3] == [ ME("ERROR: Expecting a notation name.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                DC("\"", false, L.Location("a buffer", -1)),
                                DC("\"", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION ''")
        @test length(events) >= 3
        @test (events[1:3] == [ ME("ERROR: Expecting a notation name.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                DC("'", false, L.Location("a buffer", -1)),
                                DC("'", false, L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION <")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting a notation name.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting an element name.",
                                   [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
    end

    @testset "Events/Notation Declarations (Negative ... missing/invalid notation value.)" begin
        events = evaluate("<!NOTATION n>")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: A notation declaration must specify an external identifier.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION n >")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: A notation declaration must specify an external identifier.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION n\n>")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: A notation declaration must specify an external identifier.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION n PUBLIC")
        @test length(events) >= 4
        @test (events[1:4] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                ME("ERROR: A notation declaration must specify an external identifier.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a notation declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION n PUBLIC ")
        @test length(events) >= 4
        @test (events[1:4] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                ME("ERROR: A notation declaration must specify an external identifier.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a notation declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION n PUBLIC <")
        @test length(events) >= 5
        @test (events[1:5] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                ME("ERROR: A notation declaration must specify an external identifier.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a notation declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", L.Location("a buffer", -1)),
                                ME("ERROR: Expecting an element name.",
                                   [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION n SYSTEM")
        @test length(events) >= 4
        @test (events[1:4] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                ME("ERROR: A notation declaration must specify an external identifier.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a notation declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION n SYSTEM ")
        @test length(events) >= 4
        @test (events[1:4] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                ME("ERROR: A notation declaration must specify an external identifier.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a notation declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION n SYSTEM <")
        @test length(events) >= 5
        @test (events[1:5] == [ ME("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)),
                                ME("ERROR: A notation declaration must specify an external identifier.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a notation declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", L.Location("a buffer", -1)),
                                ME("ERROR: Expecting an element name.",
                                   [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
    end

    @testset "Events/Notation Declarations (Negative ... missing TAGC.)" begin
        events = evaluate("<!NOTATION n PUBLIC \"salut.not\" \"hello.not\"")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting '>' to end a notation declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", "salut.not", "hello.not", L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION n PUBLIC \"salut.not\" \"hello.not\" ")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting '>' to end a notation declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", "salut.not", "hello.not", L.Location("a buffer", -1)) ])

        events = evaluate("<!NOTATION n PUBLIC \"salut.not\" \"hello.not\" <")
        @test length(events) >= 3
        @test (events[1:3] == [ ME("ERROR: Expecting '>' to end a notation declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", "salut.not", "hello.not", L.Location("a buffer", -1)),
                                ME("ERROR: Expecting an element name.",
                                   [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
    end

    @testset "Events/Notation Declarations (Negative ... missing white space between public and system identifier.)" begin
        events = evaluate("<!NOTATION n PUBLIC \"salut.not\"\"hello.not\"")
        @test length(events) >= 3
        @test (events[1:3] == [ ME("ERROR: Expecting white space following a public identifier.",
                                   [ ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting '>' to end a notation declaration.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.text, "NOTATION", L.Location("a buffer", -1)),
                                     L.Token(L.text, "n", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                NotationDeclaration("n", "salut.not", "hello.not", L.Location("a buffer", -1)) ])
    end
end
