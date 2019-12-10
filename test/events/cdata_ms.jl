@testset "Events/CDATA Marked Section" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    CDataStart = E.CDATAMarkedSectionStart
    CDataEnd   = E.CDATAMarkedSectionEnd

    DC = E.DataContent
    ME = E.MarkupError

    @testset "Events/CDATA Marked Section (Positive)" begin
        @test evaluate("<![CDATA[]]>") == [ CDataStart(L.Location("a buffer", -1)),
                                            DC("", L.Location("a buffer", -1)),
                                            CDataEnd(L.Location("a buffer", -1)) ]

        @test evaluate("<![CDATA[a]]>") == [ CDataStart(L.Location("a buffer", -1)),
                                             DC("a", L.Location("a buffer", -1)),
                                             CDataEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![CDATA[abc]]>") == [ CDataStart(L.Location("a buffer", -1)),
                                               DC("abc", L.Location("a buffer", -1)),
                                               CDataEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![CDATA[é]]>") == [ CDataStart(L.Location("a buffer", -1)),
                                             DC("é", L.Location("a buffer", -1)),
                                             CDataEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![CDATA[aé]]>") == [ CDataStart(L.Location("a buffer", -1)),
                                              DC("aé", L.Location("a buffer", -1)),
                                              CDataEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![CDATA[éb]]>") == [ CDataStart(L.Location("a buffer", -1)),
                                              DC("éb", L.Location("a buffer", -1)),
                                              CDataEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![CDATA[aéb]]>") == [ CDataStart(L.Location("a buffer", -1)),
                                               DC("aéb", L.Location("a buffer", -1)),
                                               CDataEnd(L.Location("a buffer", -1)) ]

        # This is from the XML specification, § 2.7.
        #
        @test (evaluate("<![CDATA[<greeting>Hello, world!</greeting>]]>")
               == [ CDataStart(L.Location("a buffer", -1)),
                    DC("<greeting>Hello, world!</greeting>", L.Location("a buffer", -1)),
                    CDataEnd(L.Location("a buffer", -1)) ])
    end

    @testset "Events/CDATA Marked Section (Negative ... no section type (CDATA))" begin
        @test (evaluate("<![")
               == [ ME("ERROR: Expecting 'CDATA' to open a CDATA marked section.",
                       [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                         L.Token(L.dso, "[", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        # White space is not allowed between the DSO and the CDATA token.
        #
        @test (evaluate("<![ CDATA")
               == [ ME("ERROR: Expecting 'CDATA' to open a CDATA marked section.",
                       [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                         L.Token(L.dso, "[", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                    DC(" ", true, L.Location("a buffer", -1)),
                    DC("CDATA", false, L.Location("a buffer", -1)) ])

        @test (evaluate("<![ ")
               == [ ME("ERROR: Expecting 'CDATA' to open a CDATA marked section.",
                       [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                         L.Token(L.dso, "[", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                    DC(" ", true, L.Location("a buffer", -1)) ])

        # Check that a random token is caught.
        #
        events = evaluate("<![<")
        @test length(events) >= 2
        @test (events[1:2] == [ ME("ERROR: Expecting 'CDATA' to open a CDATA marked section.",
                                   [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                     L.Token(L.dso, "[", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                                ME("ERROR: Expecting an element name.",
                                   [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
    end

    @testset "Events/CDATA Marked Section (Negative ... wrong section type (CDATA))" begin
        @test (evaluate("<![SDATA")
               == [ ME("ERROR: Expecting 'CDATA' to open a CDATA marked section.",
                       [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                         L.Token(L.dso, "[", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                    DC("SDATA", false, L.Location("a buffer", -1)) ])

        @test (evaluate("<![cdata")
               == [ ME("ERROR: Expecting 'CDATA' to open a CDATA marked section.",
                       [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                         L.Token(L.dso, "[", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                    DC("cdata", false, L.Location("a buffer", -1)) ])
    end

    @testset "Events/CDATA Marked Section (Negative ... no second DSO)" begin
        @test (evaluate("<![CDATA")
               == [ ME("ERROR: Expecting '[' to open a CDATA marked section.",
                       [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                         L.Token(L.dso, "[", L.Location("a buffer", -1)),
                         L.Token(L.text, "CDATA", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)), ])

        # White space is not allowed between the CDATA token and the second DSO.
        #
        @test (evaluate("<![CDATA [")
               == [ ME("ERROR: Expecting '[' to open a CDATA marked section.",
                       [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                         L.Token(L.dso, "[", L.Location("a buffer", -1)),
                         L.Token(L.text, "CDATA", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                    DC(" ", true, L.Location("a buffer", -1)),
                    DC("[", false, L.Location("a buffer", -1)), ])
    end

    @testset "Events/CDATA Marked Section (Negative ... no MSC)" begin
        @test (evaluate("<![CDATA[")
               == [ CDataStart(L.Location("a buffer", -1)),
                    DC("", L.Location("a buffer", -1)),
                    ME("ERROR: Expecting ']]>' to end a CDATA marked section.", [ ], L.Location("a buffer", -1)),
                    CDataEnd(true, L.Location("a buffer", -1)) ])

        @test (evaluate("<![CDATA[Hello, World!")
               == [ CDataStart(L.Location("a buffer", -1)),
                    DC("Hello, World!", L.Location("a buffer", -1)),
                    ME("ERROR: Expecting ']]>' to end a CDATA marked section.", [ ], L.Location("a buffer", -1)),
                    CDataEnd(true, L.Location("a buffer", -1)) ])
    end

    @testset "Events/CDATA Marked Section (Negative ... no TAGC)" begin
        @test (evaluate("<![CDATA[]]")
               == [ CDataStart(L.Location("a buffer", -1)),
                    DC("", L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '>' to end a CDATA marked section.", [ ], L.Location("a buffer", -1)),
                    CDataEnd(true, L.Location("a buffer", -1)) ])

        @test (evaluate("<![CDATA[Hello, World!]]")
               == [ CDataStart(L.Location("a buffer", -1)),
                    DC("Hello, World!", L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '>' to end a CDATA marked section.", [ ], L.Location("a buffer", -1)),
                    CDataEnd(true, L.Location("a buffer", -1)) ])

        # White space is not allowed between the MSC adn the TAGC.
        #
        @test (evaluate("<![CDATA[]] >")
               == [ CDataStart(L.Location("a buffer", -1)),
                    DC("", L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '>' to end a CDATA marked section.", [ ], L.Location("a buffer", -1)),
                    CDataEnd(true, L.Location("a buffer", -1)),
                    DC(" ", true, L.Location("a buffer", -1)),
                    DC(">", false, L.Location("a buffer", -1)) ])

        @test (evaluate("<![CDATA[Hello, World!]] >")
               == [ CDataStart(L.Location("a buffer", -1)),
                    DC("Hello, World!", L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '>' to end a CDATA marked section.", [ ], L.Location("a buffer", -1)),
                    CDataEnd(true, L.Location("a buffer", -1)),
                    DC(" ", true, L.Location("a buffer", -1)),
                    DC(">", false, L.Location("a buffer", -1)) ])
    end
end
