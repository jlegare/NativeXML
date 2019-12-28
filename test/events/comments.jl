@testset "Events/Comments" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    CommentStart = E.CommentStart
    CommentEnd   = E.CommentEnd

    DC = E.DataContent
    ME = E.MarkupError

    @testset "Events/Comments (Positive)" begin
        @test evaluate("<!---->") == [ CommentStart(L.Location("a buffer", -1)),
                                       DC("", L.Location("a buffer", -1)),
                                       CommentEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<!--x-->") == [ CommentStart(L.Location("a buffer", -1)),
                                        DC("x", L.Location("a buffer", -1)),
                                        CommentEnd(L.Location("a buffer", -1)) ]
        @test evaluate("<!--xxx-->") == [ CommentStart(L.Location("a buffer", -1)),
                                          DC("xxx", L.Location("a buffer", -1)),
                                          CommentEnd(L.Location("a buffer", -1)) ]

        @test (evaluate("<!--x--><!--y-->") == [ CommentStart(L.Location("a buffer", -1)),
                                                 DC("x", L.Location("a buffer", -1)),
                                                 CommentEnd(L.Location("a buffer", -1)),
                                                 CommentStart(L.Location("a buffer", -1)),
                                                 DC("y", L.Location("a buffer", -1)),
                                                 CommentEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!-- Hello, World! -->") == [ CommentStart(L.Location("a buffer", -1)),
                                                       DC(" Hello, World! ", L.Location("a buffer", -1)),
                                                       CommentEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!--é-->") == [ CommentStart(L.Location("a buffer", -1)),
                                         DC("é", L.Location("a buffer", -1)),
                                         CommentEnd(L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 2.5.
        #
        @test (evaluate("<!-- declarations for <head> & <body> -->")
               == [ CommentStart(L.Location("a buffer", -1)),
                    DC(" declarations for <head> & <body> ", L.Location("a buffer", -1)),
                    CommentEnd(L.Location("a buffer", -1)) ])

        @test (evaluate("<!-- &e; -->") == [ CommentStart(L.Location("a buffer", -1)),
                                             DC(" &e; ", L.Location("a buffer", -1)),
                                             CommentEnd(L.Location("a buffer", -1)) ])
        @test (evaluate("<!-- <?target value?> -->") == [ CommentStart(L.Location("a buffer", -1)),
                                                          DC(" <?target value?> ", L.Location("a buffer", -1)),
                                                          CommentEnd(L.Location("a buffer", -1)) ])
    end

    @testset "Events/Comments (Negative ... no terminator)" begin
        @test (evaluate("<!--") == [ CommentStart(L.Location("a buffer", -1)),
                                     DC("", L.Location("a buffer", -1)),
                                     ME("ERROR: Expecting '-->' to end a comment.", L.Location("a buffer", -1)),
                                     CommentEnd(true, L.Location("a buffer", -1)) ])
        @test (evaluate("<!--x") == [ CommentStart(L.Location("a buffer", -1)),
                                      DC("x", L.Location("a buffer", -1)),
                                      ME("ERROR: Expecting '-->' to end a comment.", L.Location("a buffer", -1)),
                                      CommentEnd(true, L.Location("a buffer", -1)) ])
        @test (evaluate("<!--é") == [ CommentStart(L.Location("a buffer", -1)),
                                      DC("é", L.Location("a buffer", -1)),
                                      ME("ERROR: Expecting '-->' to end a comment.", L.Location("a buffer", -1)),
                                      CommentEnd(true, L.Location("a buffer", -1)) ])
        @test (evaluate("<!-- declarations for <head> & <body> ")
               == [ CommentStart(L.Location("a buffer", -1)),
                    DC(" declarations for <head> & <body> ", L.Location("a buffer", -1)),
                    ME("ERROR: Expecting '-->' to end a comment.", L.Location("a buffer", -1)),
                    CommentEnd(true, L.Location("a buffer", -1)) ])

        @test (evaluate("<!--x-") == [ CommentStart(L.Location("a buffer", -1)),
                                       DC("x-", L.Location("a buffer", -1)),
                                       ME("ERROR: Expecting '-->' to end a comment.", L.Location("a buffer", -1)),
                                       CommentEnd(true, L.Location("a buffer", -1)) ])
        @test (evaluate("<!--x--") == [ CommentStart(L.Location("a buffer", -1)),
                                        DC("x--", L.Location("a buffer", -1)),
                                        ME("ERROR: Expecting '-->' to end a comment.", L.Location("a buffer", -1)),
                                        CommentEnd(true, L.Location("a buffer", -1)) ])
    end

    @testset "Events/Comments (Negative ... nested --)" begin
        @test (evaluate("<!-- -- -->")
               == [ CommentStart(L.Location("a buffer", -1)),
                    DC(" ", L.Location("a buffer", -1)),
                    ME("ERROR: '--' is not allowed inside a comment.", L.Location("a buffer", -1)),
                    CommentEnd(true, L.Location("a buffer", -1)),
                    DC(" ", true, L.Location("a buffer", -1)),
                    DC("--", false, L.Location("a buffer", -1)),
                    DC(">", false, L.Location("a buffer", -1)) ])
        @test (evaluate("<!------>")
               == [ CommentStart(L.Location("a buffer", -1)),
                    DC("", L.Location("a buffer", -1)),
                    ME("ERROR: '--' is not allowed inside a comment.", L.Location("a buffer", -1)),
                    CommentEnd(true, L.Location("a buffer", -1)),
                    DC("--", false, L.Location("a buffer", -1)),
                    DC(">", false, L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 2.5.
        #
        @test (evaluate("<!-- B+, B, or B--->")
               == [ CommentStart(L.Location("a buffer", -1)),
                    DC(" B+, B, or B", L.Location("a buffer", -1)),
                    ME("ERROR: '--' is not allowed inside a comment.", L.Location("a buffer", -1)),
                    CommentEnd(true, L.Location("a buffer", -1)),
                    DC("-", false, L.Location("a buffer", -1)),
                    DC(">", false, L.Location("a buffer", -1)) ])
    end
end
