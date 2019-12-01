@testset "Events/Processing Instructions" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Processing Instructions (Positive)" begin
        @test collect(E.events(L.State(IOBuffer("<?x?>"))))   == [ E.ProcessingInstruction("x", "", L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("<?xxx?>")))) == [ E.ProcessingInstruction("xxx", "", L.Location("a buffer", -1)) ]

        @test collect(E.events(L.State(IOBuffer("<?x?><?y?>")))) == [ E.ProcessingInstruction("x", "", L.Location("a buffer", -1)),
                                                                      E.ProcessingInstruction("y", "", L.Location("a buffer", -1)) ]

        @test collect(E.events(L.State(IOBuffer("<?é?>")))) == [ E.ProcessingInstruction("é", "", L.Location("a buffer", -1)) ]

        # The specification allows for trailing white space after the PI target, but it's considered pure syntax by the
        # parser, so make sure it doesn't appear in the generated event. Try various types and numbers of white space.
        #
        @test (collect(E.events(L.State(IOBuffer("<?target ?>"))))
               == [ E.ProcessingInstruction("target", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<?target   ?>"))))
               == [ E.ProcessingInstruction("target", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<?target \n ?>"))))
               == [ E.ProcessingInstruction("target", "", L.Location("a buffer", -1)) ])

        # The specification excludes all case variants of "xml" for the PI target, but the parser doesn't care. So
        # ensure they get captured at this level.
        #
        @test collect(E.events(L.State(IOBuffer("<?XML?>")))) == [ E.ProcessingInstruction("XML", "", L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("<?xml?>")))) == [ E.ProcessingInstruction("xml", "", L.Location("a buffer", -1)) ]
        @test collect(E.events(L.State(IOBuffer("<?xmL?>")))) == [ E.ProcessingInstruction("xmL", "", L.Location("a buffer", -1)) ]

        @test (collect(E.events(L.State(IOBuffer("<?target value?>"))))
               == [ E.ProcessingInstruction("target", "value", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<?target value value value?>"))))
               == [ E.ProcessingInstruction("target", "value value value", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<?target value\nvalue\nvalue?>"))))
               == [ E.ProcessingInstruction("target", "value\nvalue\nvalue", L.Location("a buffer", -1)) ])

        @test (collect(E.events(L.State(IOBuffer("<?target ééé?>"))))
               == [ E.ProcessingInstruction("target", "ééé", L.Location("a buffer", -1)) ])

        # The PI value is anything following the first white space, including any white space trailing at the end of the
        # PI. Make sure that any trailing white space is captured.
        #
        @test (collect(E.events(L.State(IOBuffer("<?target value ?>"))))
               == [ E.ProcessingInstruction("target", "value ", L.Location("a buffer", -1)) ])
    end

    @testset "Events/Processing Instructions (Negative ... no target)" begin
        # Check that a missing PI target is caught.
        #
        @test (collect(E.events(L.State(IOBuffer("<??>"))))
               == [ E.MarkupError("ERROR: Expecting a PI target.", [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ],
                                  L.Location("a buffer", -1)),
                    E.DataContent("?>", false, L.Location("a buffer", -1)) ])

        # Check that EOI is caught.
        #
        @test (collect(E.events(L.State(IOBuffer("<?"))))
               == [ E.MarkupError("ERROR: Expecting a PI target.", [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ],
                                  L.Location("a buffer", -1)) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = collect(E.events(L.State(IOBuffer("<?<"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting a PI target.",
                                              [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)))
    end

    @testset "Events/Processing Instructions (Negative ... no terminator)" begin
        # Check that EOI is caught.
        #
        @test (collect(E.events(L.State(IOBuffer("<?target"))))
               == [ E.MarkupError("ERROR: Expecting '?>' to end a processing instruction.",
                                  [ L.Token(L.pio, "<?", L.Location("a buffer", -1)),
                                    L.Token(L.text, "target", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<?target value"))))
               == [ E.MarkupError("ERROR: Expecting '?>' to end a processing instruction.",
                                  [ L.Token(L.pio, "<?", L.Location("a buffer", -1)),
                                    L.Token(L.text, "target", L.Location("a buffer", -1)),
                                    L.Token(L.text, "value", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<?target value "))))
               == [ E.MarkupError("ERROR: Expecting '?>' to end a processing instruction.",
                                  [ L.Token(L.pio, "<?", L.Location("a buffer", -1)),
                                    L.Token(L.text, "target", L.Location("a buffer", -1)),
                                    L.Token(L.text, "value", L.Location("a buffer", -1)),
                                    L.Token(L.ws, " ", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])

        # Check that a random token is caught. But careful ... the parser keeps going, so we only check the FIRST
        # event. (Otherwise we're testing the results of some other part of the parser.)
        #
        events = collect(E.events(L.State(IOBuffer("<?target<"))))
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting '?>' to end a processing instruction.",
                                              [ L.Token(L.pio, "<?", L.Location("a buffer", -1)),
                                                L.Token(L.text, "target", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        # We can't write an equivalent test with a PI value, because anything that appears after the first white space
        # (except '?>') belongs in the PI value.
    end
end
