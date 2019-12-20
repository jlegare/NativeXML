@testset "Events/Conditional Section" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    CSStart = E.ConditionalSectionStart
    CSEnd   = E.ConditionalSectionEnd

    DC = E.DataContent
    ME = E.MarkupError
    PE = E.EntityReferenceParameter

    @testset "Events/Conditional Section (Positive ... trivial content)" begin
        @test evaluate("<![INCLUDE[]]>") == [ CSStart("INCLUDE", L.Location("a buffer", -1)),
                                              CSEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![INCLUDE []]>") == [ CSStart("INCLUDE", L.Location("a buffer", -1)),
                                               CSEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![ INCLUDE[]]>") == [ CSStart("INCLUDE", L.Location("a buffer", -1)),
                                               CSEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![ INCLUDE []]>") == [ CSStart("INCLUDE", L.Location("a buffer", -1)),
                                                CSEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![\nINCLUDE\t[]]>") == [ CSStart("INCLUDE", L.Location("a buffer", -1)),
                                                  CSEnd(L.Location("a buffer", -1)) ]

        @test evaluate("<![IGNORE[]]>") == [ CSStart("IGNORE", L.Location("a buffer", -1)),
                                             CSEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![IGNORE []]>") == [ CSStart("IGNORE", L.Location("a buffer", -1)),
                                              CSEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![ IGNORE[]]>") == [ CSStart("IGNORE", L.Location("a buffer", -1)),
                                              CSEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![ IGNORE []]>") == [ CSStart("IGNORE", L.Location("a buffer", -1)),
                                               CSEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![\nIGNORE\t[]]>") == [ CSStart("IGNORE", L.Location("a buffer", -1)),
                                                 CSEnd(L.Location("a buffer", -1)) ]

        @test evaluate("<![%e;[]]>") == [ CSStart(PE("e", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                                          CSEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![%e; []]>") == [ CSStart(PE("e", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                                           CSEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![ %e;[]]>") == [ CSStart(PE("e", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                                           CSEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![ %e; []]>") == [ CSStart(PE("e", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                                            CSEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<![\n%e;\t[]]>") == [ CSStart(PE("e", L.Location("a buffer", -1)), L.Location("a buffer", -1)),
                                              CSEnd(L.Location("a buffer", -1)) ]
    end

    @testset "Events/Conditional Section (Negative ... mixed-case keywords)" begin
        @test evaluate("<![include[") == [ ME("ERROR: The keyword 'include' must be uppercased.", [ ], L.Location("a buffer", -1)),
                                           CSStart(true, "include", L.Location("a buffer", -1)) ]
        @test evaluate("<![incLUDE[") == [ ME("ERROR: The keyword 'incLUDE' must be uppercased.", [ ], L.Location("a buffer", -1)),
                                           CSStart(true, "incLUDE", L.Location("a buffer", -1)) ]

        @test evaluate("<![ignore[") == [ ME("ERROR: The keyword 'ignore' must be uppercased.", [ ], L.Location("a buffer", -1)),
                                          CSStart(true, "ignore", L.Location("a buffer", -1)) ]
        @test evaluate("<![ignORE[") == [ ME("ERROR: The keyword 'ignORE' must be uppercased.", [ ], L.Location("a buffer", -1)),
                                          CSStart(true, "ignORE", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Conditional Section (Negative ... no DSO)" begin
        @test evaluate("<![INCLUDE") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                             [ ], L.Location("a buffer", -1)),
                                          CSStart(true, "INCLUDE", L.Location("a buffer", -1)) ]
        @test evaluate("<![IGNORE") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                            [ ], L.Location("a buffer", -1)),
                                         CSStart(true, "IGNORE", L.Location("a buffer", -1)) ]
        @test evaluate("<![%e;") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                         [ ], L.Location("a buffer", -1)),
                                      CSStart(true, PE("e", L.Location("a buffer", -1)), L.Location("a buffer", -1)) ]

        # Make sure that leading and trailing white space doesn't throw off the error-reporting.
        #
        @test evaluate("<![INCLUDE ") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                              [ ], L.Location("a buffer", -1)),
                                           CSStart(true, "INCLUDE", L.Location("a buffer", -1)) ]
        @test evaluate("<![IGNORE ") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                             [ ], L.Location("a buffer", -1)),
                                          CSStart(true, "IGNORE", L.Location("a buffer", -1)) ]
        @test evaluate("<![%e; ") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                          [ ], L.Location("a buffer", -1)),
                                       CSStart(true, PE("e", L.Location("a buffer", -1)), L.Location("a buffer", -1)) ]

        @test evaluate("<![ INCLUDE") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                              [ ], L.Location("a buffer", -1)),
                                           CSStart(true, "INCLUDE", L.Location("a buffer", -1)) ]
        @test evaluate("<![ IGNORE") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                             [ ], L.Location("a buffer", -1)),
                                          CSStart(true, "IGNORE", L.Location("a buffer", -1)) ]
        @test evaluate("<![ %e;") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                          [ ], L.Location("a buffer", -1)),
                                       CSStart(true, PE("e", L.Location("a buffer", -1)), L.Location("a buffer", -1)) ]

        @test evaluate("<![ INCLUDE ") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                               [ ], L.Location("a buffer", -1)),
                                            CSStart(true, "INCLUDE", L.Location("a buffer", -1)) ]
        @test evaluate("<![ IGNORE ") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                              [ ], L.Location("a buffer", -1)),
                                           CSStart(true, "IGNORE", L.Location("a buffer", -1)) ]
        @test evaluate("<![ %e; ") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                           [ ], L.Location("a buffer", -1)),
                                        CSStart(true, PE("e", L.Location("a buffer", -1)), L.Location("a buffer", -1)) ]

        @test evaluate("<![\nINCLUDE\t") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                                 [ ], L.Location("a buffer", -1)),
                                              CSStart(true, "INCLUDE", L.Location("a buffer", -1)) ]
        @test evaluate("<![\nIGNORE\t") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                                [ ], L.Location("a buffer", -1)),
                                             CSStart(true, "IGNORE", L.Location("a buffer", -1)) ]
        @test evaluate("<![\n%e;\t") == [ ME("ERROR: Expecting '[' to open a conditional marked section.",
                                             [ ], L.Location("a buffer", -1)),
                                          CSStart(true, PE("e", L.Location("a buffer", -1)), L.Location("a buffer", -1)) ]
    end
end
