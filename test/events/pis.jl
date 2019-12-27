@testset "Events/Processing Instructions" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    DC = E.DataContent
    ME = E.MarkupError
    PI = E.ProcessingInstruction

    @testset "Events/Processing Instructions (Positive)" begin
        @test evaluate("<?x?>")   == [ PI("x", "", L.Location("a buffer", -1)) ]
        @test evaluate("<?xxx?>") == [ PI("xxx", "", L.Location("a buffer", -1)) ]

        @test evaluate("<?x?><?y?>") == [ PI("x", "", L.Location("a buffer", -1)),
                                          PI("y", "", L.Location("a buffer", -1)) ]

        @test evaluate("<?é?>") == [ PI("é", "", L.Location("a buffer", -1)) ]

        # The specification allows for trailing white space after the PI target, but it's considered pure syntax by the
        # parser, so make sure it doesn't appear in the generated event. Try various types and numbers of white space.
        #
        @test evaluate("<?target ?>") == [ PI("target", "", L.Location("a buffer", -1)) ]
        @test evaluate("<?target   ?>") == [ PI("target", "", L.Location("a buffer", -1)) ]
        @test evaluate("<?target \n ?>") == [ PI("target", "", L.Location("a buffer", -1)) ]

        # The specification excludes all case variants of "xml" for the PI target, but the parser doesn't care. So
        # ensure they get captured at this level.
        #
        events = evaluate("<?XML?>")
        @test events == [ ME("ERROR: A PI target cannot be any case variant of 'XML'.",
                             [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                          PI("XML", "", L.Location("a buffer", -1)) ]

        events = evaluate("<?xml?>")
        @test events == [ ME("ERROR: A PI target cannot be any case variant of 'XML'.",
                             [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                          PI("xml", "", L.Location("a buffer", -1)) ]

        events = evaluate("<?xmL?>")
        @test events == [ ME("ERROR: A PI target cannot be any case variant of 'XML'.",
                             [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)),
                          PI("xmL", "", L.Location("a buffer", -1)) ]

        @test evaluate("<?target value?>") == [ PI("target", "value", L.Location("a buffer", -1)) ]
        @test (evaluate("<?target value value value?>") == [ PI("target", "value value value", L.Location("a buffer", -1)) ])
        @test (evaluate("<?target value\nvalue\nvalue?>") == [ PI("target", "value\nvalue\nvalue", L.Location("a buffer", -1)) ])

        @test evaluate("<?target ééé?>") == [ PI("target", "ééé", L.Location("a buffer", -1)) ]

        # The PI value is anything following the first white space, including any white space trailing at the end of the
        # PI. Make sure that any trailing white space is captured.
        #
        @test evaluate("<?target value ?>") == [ PI("target", "value ", L.Location("a buffer", -1)) ]

        # A '?' can appear in a PI value.
        #
        @test evaluate("<?Are you there? Hello, World!?>") == [ PI("Are", "you there? Hello, World!", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Processing Instructions (Negative ... no target)" begin
        # Check that a missing PI target is caught.
        #
        events = evaluate("<??>")
        @test (events == [ ME("ERROR: Expecting a PI target.", [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ],
                              L.Location("a buffer", -1)),
                           DC("?", false, L.Location("a buffer", -1)),
                           DC(">", false, L.Location("a buffer", -1)) ])

        # Check that EOI is caught.
        #
        events = evaluate("<?")
        @test (events == [ ME("ERROR: Expecting a PI target.", [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ],
                              L.Location("a buffer", -1)) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = evaluate("<?<")
        @test (events == [ ME("ERROR: Expecting a PI target.", [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ],
                              L.Location("a buffer", -1)),
                           ME("ERROR: Expecting an element name.",
                              [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
    end

    @testset "Events/Processing Instructions (Negative ... no terminator)" begin
        # Check that EOI is caught.
        #
        events = evaluate("<?target")
        @test (events == [ ME("ERROR: Expecting '?>' to end a processing instruction.",
                              [ L.Token(L.pio, "<?", L.Location("a buffer", -1)),
                                L.Token(L.text, "target", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        events = evaluate("<?target value")
        @test (events == [ ME("ERROR: Expecting '?>' to end a processing instruction.",
                             [ L.Token(L.pio, "<?", L.Location("a buffer", -1)),
                               L.Token(L.text, "target", L.Location("a buffer", -1)),
                               L.Token(L.text, "value", L.Location("a buffer", -1)) ],
                             L.Location("a buffer", -1)) ])

        events = evaluate("<?target value ")
        @test (events == [ ME("ERROR: Expecting '?>' to end a processing instruction.",
                             [ L.Token(L.pio, "<?", L.Location("a buffer", -1)),
                               L.Token(L.text, "target", L.Location("a buffer", -1)),
                               L.Token(L.text, "value", L.Location("a buffer", -1)),
                               L.Token(L.ws, " ", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        # Check that a random token is caught. Note the random token goes into the PI value.
        #
        events = evaluate("<?target<")
        @test (events == [ ME("ERROR: Expecting '?>' to end a processing instruction.",
                              [ L.Token(L.pio, "<?", L.Location("a buffer", -1)),
                                L.Token(L.text, "target", L.Location("a buffer", -1)),
                                L.Token(L.stago, "<", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
    end
end
