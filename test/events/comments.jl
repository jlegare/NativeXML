@testset "Events/Comments" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    @testset "Events/Comments (Positive)" begin
        @test evaluate("<!---->") == [ E.CommentStart(L.Location("a buffer", -1)),
                                       E.DataContent("", L.Location("a buffer", -1)),
                                       E.CommentEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<!--x-->") == [ E.CommentStart(L.Location("a buffer", -1)),
                                        E.DataContent("x", L.Location("a buffer", -1)),
                                        E.CommentEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<!--xxx-->") == [ E.CommentStart(L.Location("a buffer", -1)),
                                          E.DataContent("xxx", L.Location("a buffer", -1)),
                                          E.CommentEnd(L.Location("a buffer", -1)) ]

        @test (evaluate("<!--x--><!--y-->") == [ E.CommentStart(L.Location("a buffer", -1)),
                                                 E.DataContent("x", L.Location("a buffer", -1)),
                                                 E.CommentEnd(L.Location("a buffer", -1)),
                                                 E.CommentStart(L.Location("a buffer", -1)),
                                                 E.DataContent("y", L.Location("a buffer", -1)),
                                                 E.CommentEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!-- Hello, World! -->") == [ E.CommentStart(L.Location("a buffer", -1)),
                                                       E.DataContent(" Hello, World! ", L.Location("a buffer", -1)),
                                                       E.CommentEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!--é-->") == [ E.CommentStart(L.Location("a buffer", -1)),
                                         E.DataContent("é", L.Location("a buffer", -1)),
                                         E.CommentEnd(L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 2.5.
        #
        @test (evaluate("<!-- declarations for <head> & <body> -->")
               == [ E.CommentStart(L.Location("a buffer", -1)),
                    E.DataContent(" declarations for <head> & <body> ", L.Location("a buffer", -1)),
                    E.CommentEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!-- &e; -->") == [ E.CommentStart(L.Location("a buffer", -1)),
                                             E.DataContent(" &e; ", L.Location("a buffer", -1)),
                                             E.CommentEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!-- <?target value?> -->") == [ E.CommentStart(L.Location("a buffer", -1)),
                                                          E.DataContent(" <?target value?> ", L.Location("a buffer", -1)),
                                                          E.CommentEnd(L.Location("a buffer", -1)) ])
    end

    @testset "Events/Comments (Negative ... no terminator)" begin
        @test (evaluate("<!--") == [ E.CommentStart(L.Location("a buffer", -1)),
                                     E.DataContent("", L.Location("a buffer", -1)),
                                     E.MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], L.Location("a buffer", -1)),
                                     E.CommentEnd(true, L.Location("a buffer", -1)) ])
        @test (evaluate("<!--x") == [ E.CommentStart(L.Location("a buffer", -1)),
                                      E.DataContent("x", L.Location("a buffer", -1)),
                                      E.MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], L.Location("a buffer", -1)),
                                      E.CommentEnd(true, L.Location("a buffer", -1)) ])
        @test (evaluate("<!--é") == [ E.CommentStart(L.Location("a buffer", -1)),
                                      E.DataContent("é", L.Location("a buffer", -1)),
                                      E.MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], L.Location("a buffer", -1)),
                                      E.CommentEnd(true, L.Location("a buffer", -1)) ])
        @test (evaluate("<!-- declarations for <head> & <body> ")
               == [ E.CommentStart(L.Location("a buffer", -1)),
                    E.DataContent(" declarations for <head> & <body> ", L.Location("a buffer", -1)),
                    E.MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], L.Location("a buffer", -1)),
                    E.CommentEnd(true, L.Location("a buffer", -1)) ])

        @test (evaluate("<!--x-") == [ E.CommentStart(L.Location("a buffer", -1)),
                                       E.DataContent("x-", L.Location("a buffer", -1)),
                                       E.MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], L.Location("a buffer", -1)),
                                       E.CommentEnd(true, L.Location("a buffer", -1)) ])
        @test (evaluate("<!--x--") == [ E.CommentStart(L.Location("a buffer", -1)),
                                        E.DataContent("x", L.Location("a buffer", -1)),
                                        E.MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], L.Location("a buffer", -1)),
                                        E.CommentEnd(true, L.Location("a buffer", -1)) ])
    end

    @testset "Events/Comments (Negative ... nested --)" begin
        @test (evaluate("<!-- -- -->")
               == [ E.CommentStart(L.Location("a buffer", -1)),
                    E.DataContent(" ", L.Location("a buffer", -1)),
                    E.MarkupError("ERROR: '--' is not allowed inside a comment.", [ ], L.Location("a buffer", -1)),
                    E.CommentEnd(true, L.Location("a buffer", -1)),
                    E.DataContent(" ", true, L.Location("a buffer", -1)),
                    E.DataContent("--", false, L.Location("a buffer", -1)),
                    E.DataContent(">", false, L.Location("a buffer", -1)) ])
        @test (evaluate("<!------>")
               == [ E.CommentStart(L.Location("a buffer", -1)),
                    E.DataContent("", L.Location("a buffer", -1)),
                    E.MarkupError("ERROR: '--' is not allowed inside a comment.", [ ], L.Location("a buffer", -1)),
                    E.CommentEnd(true, L.Location("a buffer", -1)),
                    E.DataContent("--", false, L.Location("a buffer", -1)),
                    E.DataContent(">", false, L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 2.5.
        #
        @test (evaluate("<!-- B+, B, or B--->")
               == [ E.CommentStart(L.Location("a buffer", -1)),
                    E.DataContent(" B+, B, or B", L.Location("a buffer", -1)),
                    E.MarkupError("ERROR: '--' is not allowed inside a comment.", [ ], L.Location("a buffer", -1)),
                    E.CommentEnd(true, L.Location("a buffer", -1)),
                    E.DataContent("-", false, L.Location("a buffer", -1)),
                    E.DataContent(">", false, L.Location("a buffer", -1)) ])
    end
end
