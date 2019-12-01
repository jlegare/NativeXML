@testset "Events/CDATA Marked Section" begin
    E = Events
    L = Events.Lexical

    @testset "Events/CDATA Marked Section (Positive)" begin
        @test collect(E.events(L.State(IOBuffer("<![CDATA[]]>")))) == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                                                                        E.DataContent("", L.Location("a buffer", -1)),
                                                                        E.CDATAMarkedSectionEnd(L.Location("a buffer", -1)) ]

        @test collect(E.events(L.State(IOBuffer("<![CDATA[a]]>")))) == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                                                                         E.DataContent("a", L.Location("a buffer", -1)),
                                                                         E.CDATAMarkedSectionEnd(L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("<![CDATA[abc]]>")))) == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                                                                           E.DataContent("abc", L.Location("a buffer", -1)),
                                                                           E.CDATAMarkedSectionEnd(L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("<![CDATA[é]]>")))) == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                                                                         E.DataContent("é", L.Location("a buffer", -1)),
                                                                         E.CDATAMarkedSectionEnd(L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("<![CDATA[aé]]>")))) == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                                                                          E.DataContent("aé", L.Location("a buffer", -1)),
                                                                          E.CDATAMarkedSectionEnd(L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("<![CDATA[éb]]>")))) == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                                                                          E.DataContent("éb", L.Location("a buffer", -1)),
                                                                          E.CDATAMarkedSectionEnd(L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("<![CDATA[aéb]]>")))) == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                                                                           E.DataContent("aéb", L.Location("a buffer", -1)),
                                                                           E.CDATAMarkedSectionEnd(L.Location("a buffer", -1)) ]

        # This is from the XML specification, § 2.7.
        #
        @test (collect(E.events(L.State(IOBuffer("<![CDATA[<greeting>Hello, world!</greeting>]]>"))))
               == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                    E.DataContent("<greeting>Hello, world!</greeting>", L.Location("a buffer", -1)),
                    E.CDATAMarkedSectionEnd(L.Location("a buffer", -1)) ])
    end

    @testset "Events/CDATA Marked Section (Negative ... no section type (CDATA))" begin
        @test (collect(E.events(L.State(IOBuffer("<!["))))
               == [ E.MarkupError("ERROR: Expecting 'CDATA' to open a CDATA marked section.",
                                  [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                    L.Token(L.dso, "[", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        # White space is not allowed between the DSO and the CDATA token.
        #
        @test (collect(E.events(L.State(IOBuffer("<![ CDATA"))))
               == [ E.MarkupError("ERROR: Expecting 'CDATA' to open a CDATA marked section.",
                                  [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                    L.Token(L.dso, "[", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                    E.DataContent(" ", true, L.Location("a buffer", -1)),
                    E.DataContent("CDATA", false, L.Location("a buffer", -1)) ])

        @test (collect(E.events(L.State(IOBuffer("<![ "))))
               == [ E.MarkupError("ERROR: Expecting 'CDATA' to open a CDATA marked section.",
                                  [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                    L.Token(L.dso, "[", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                    E.DataContent(" ", true, L.Location("a buffer", -1)) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = collect(E.events(L.State(IOBuffer("<![<"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting 'CDATA' to open a CDATA marked section.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.dso, "[", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end

    @testset "Events/CDATA Marked Section (Negative ... wrong section type (CDATA))" begin
        @test (collect(E.events(L.State(IOBuffer("<![SDATA"))))
               == [ E.MarkupError("ERROR: Expecting 'CDATA' to open a CDATA marked section.",
                                  [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                    L.Token(L.dso, "[", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                    E.DataContent("SDATA", false, L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<![cdata"))))
               == [ E.MarkupError("ERROR: Expecting 'CDATA' to open a CDATA marked section.",
                                  [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                    L.Token(L.dso, "[", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                    E.DataContent("cdata", false, L.Location("a buffer", -1)) ])
    end

    @testset "Events/CDATA Marked Section (Negative ... no second DSO)" begin
        @test (collect(E.events(L.State(IOBuffer("<![CDATA"))))
               == [ E.MarkupError("ERROR: Expecting '[' to open a CDATA marked section.",
                                  [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                    L.Token(L.dso, "[", L.Location("a buffer", -1)),
                                    L.Token(L.text, "CDATA", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)), ])

        # White space is not allowed between the CDATA token and the second DSO.
        #
        @test (collect(E.events(L.State(IOBuffer("<![CDATA ["))))
               == [ E.MarkupError("ERROR: Expecting '[' to open a CDATA marked section.",
                                  [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                    L.Token(L.dso, "[", L.Location("a buffer", -1)),
                                    L.Token(L.text, "CDATA", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                    E.DataContent(" ", true, L.Location("a buffer", -1)),
                    E.DataContent("[", false, L.Location("a buffer", -1)), ])
    end

    @testset "Events/CDATA Marked Section (Negative ... no MSC)" begin
        @test (collect(E.events(L.State(IOBuffer("<![CDATA["))))
               == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                    E.DataContent("", L.Location("a buffer", -1)),
                    E.MarkupError("ERROR: Expecting ']]>' to end a CDATA marked section.", [ ], L.Location("a buffer", -1)),
                    E.CDATAMarkedSectionEnd(true, L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<![CDATA[Hello, World!"))))
               == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                    E.DataContent("Hello, World!", L.Location("a buffer", -1)),
                    E.MarkupError("ERROR: Expecting ']]>' to end a CDATA marked section.", [ ], L.Location("a buffer", -1)),
                    E.CDATAMarkedSectionEnd(true, L.Location("a buffer", -1)) ])
    end

    @testset "Events/CDATA Marked Section (Negative ... no TAGC)" begin
        @test (collect(E.events(L.State(IOBuffer("<![CDATA[]]"))))
               == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                    E.DataContent("", L.Location("a buffer", -1)),
                    E.MarkupError("ERROR: Expecting '>' to end a CDATA marked section.", [ ], L.Location("a buffer", -1)),
                    E.CDATAMarkedSectionEnd(true, L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<![CDATA[Hello, World!]]"))))
               == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                    E.DataContent("Hello, World!", L.Location("a buffer", -1)),
                    E.MarkupError("ERROR: Expecting '>' to end a CDATA marked section.", [ ], L.Location("a buffer", -1)),
                    E.CDATAMarkedSectionEnd(true, L.Location("a buffer", -1)) ])

        # White space is not allowed between the MSC adn the TAGC.
        #
        @test (collect(E.events(L.State(IOBuffer("<![CDATA[]] >"))))
               == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                    E.DataContent("", L.Location("a buffer", -1)),
                    E.MarkupError("ERROR: Expecting '>' to end a CDATA marked section.", [ ], L.Location("a buffer", -1)),
                    E.CDATAMarkedSectionEnd(true, L.Location("a buffer", -1)),
                    E.DataContent(" ", true, L.Location("a buffer", -1)),
                    E.DataContent(">", false, L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<![CDATA[Hello, World!]] >"))))
               == [ E.CDATAMarkedSectionStart(L.Location("a buffer", -1)),
                    E.DataContent("Hello, World!", L.Location("a buffer", -1)),
                    E.MarkupError("ERROR: Expecting '>' to end a CDATA marked section.", [ ], L.Location("a buffer", -1)),
                    E.CDATAMarkedSectionEnd(true, L.Location("a buffer", -1)),
                    E.DataContent(" ", true, L.Location("a buffer", -1)),
                    E.DataContent(">", false, L.Location("a buffer", -1)) ])
    end
end
