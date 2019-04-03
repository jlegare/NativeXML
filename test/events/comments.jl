@testset "Events/Comments" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Comments (Positive)" begin
        @test collect(E.events(L.State(IOBuffer("<!---->")))) == [ E.CommentStart("a buffer", -1),
                                                                   E.DataContent("", "a buffer", -1),
                                                                   E.CommentEnd("a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<!--x-->")))) == [ E.CommentStart("a buffer", -1),
                                                                    E.DataContent("x", "a buffer", -1),
                                                                    E.CommentEnd("a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<!--xxx-->")))) == [ E.CommentStart("a buffer", -1),
                                                                      E.DataContent("xxx", "a buffer", -1),
                                                                      E.CommentEnd("a buffer", -1) ]

        @test (collect(E.events(L.State(IOBuffer("<!--x--><!--y-->"))))
               == [ E.CommentStart("a buffer", -1), E.DataContent("x", "a buffer", -1), E.CommentEnd("a buffer", -1),
                    E.CommentStart("a buffer", -1), E.DataContent("y", "a buffer", -1), E.CommentEnd("a buffer", -1) ])

        @test collect(E.events(L.State(IOBuffer("<!-- Hello, World! -->")))) == [ E.CommentStart("a buffer", -1),
                                                                                  E.DataContent(" Hello, World! ", "a buffer", -1),
                                                                                  E.CommentEnd("a buffer", -1) ]

        @test collect(E.events(L.State(IOBuffer("<!--é-->")))) == [ E.CommentStart("a buffer", -1),
                                                                    E.DataContent("é", "a buffer", -1),
                                                                    E.CommentEnd("a buffer", -1) ]

        # This is from the XML specification, § 2.5.
        #
        @test (collect(E.events(L.State(IOBuffer("<!-- declarations for <head> & <body> -->"))))
               == [ E.CommentStart("a buffer", -1),
                    E.DataContent(" declarations for <head> & <body> ", "a buffer", -1),
                    E.CommentEnd("a buffer", -1) ])
    end

    @testset "Events/Comments (Negative ... no terminator)" begin
        @test (collect(E.events(L.State(IOBuffer("<!--")))) 
               == [ E.CommentStart("a buffer", -1),
                    E.DataContent("", "a buffer", -1),
                    E.MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], "a buffer", -1),
                    E.CommentEnd(true, "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!--x")))) 
               == [ E.CommentStart("a buffer", -1),
                    E.DataContent("x", "a buffer", -1),
                    E.MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], "a buffer", -1),
                    E.CommentEnd(true, "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!--é")))) 
               == [ E.CommentStart("a buffer", -1),
                    E.DataContent("é", "a buffer", -1),
                    E.MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], "a buffer", -1),
                    E.CommentEnd(true, "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!-- declarations for <head> & <body> ")))) 
               == [ E.CommentStart("a buffer", -1),
                    E.DataContent(" declarations for <head> & <body> ", "a buffer", -1),
                    E.MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], "a buffer", -1),
                    E.CommentEnd(true, "a buffer", -1) ])

        @test (collect(E.events(L.State(IOBuffer("<!--x-")))) 
               == [ E.CommentStart("a buffer", -1),
                    E.DataContent("x-", "a buffer", -1),
                    E.MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], "a buffer", -1),
                    E.CommentEnd(true, "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!--x--")))) 
               == [ E.CommentStart("a buffer", -1),
                    E.DataContent("x", "a buffer", -1),
                    E.MarkupError("ERROR: Expecting '-->' to end a comment.", [ ], "a buffer", -1),
                    E.CommentEnd(true, "a buffer", -1) ])
    end

    @testset "Events/Comments (Negative ... nested --)" begin
        @test (collect(E.events(L.State(IOBuffer("<!-- -- -->")))) 
               == [ E.CommentStart("a buffer", -1),
                    E.DataContent(" ", "a buffer", -1),
                    E.MarkupError("ERROR: '--' is not allowed inside a comment.", [ ], "a buffer", -1),
                    E.CommentEnd(true, "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!------>")))) 
               == [ E.CommentStart("a buffer", -1),
                    E.DataContent("", "a buffer", -1),
                    E.MarkupError("ERROR: '--' is not allowed inside a comment.", [ ], "a buffer", -1),
                    E.CommentEnd(true, "a buffer", -1) ])

        # This is from the XML specification, § 2.5.
        #
        @test (collect(E.events(L.State(IOBuffer("<!-- B+, B, or B--->")))) 
               == [ E.CommentStart("a buffer", -1),
                    E.DataContent(" B+, B, or B", "a buffer", -1),
                    E.MarkupError("ERROR: '--' is not allowed inside a comment.", [ ], "a buffer", -1),
                    E.CommentEnd(true, "a buffer", -1) ])
    end
end
