@testset "Lexical" begin
    L = Lexical

    @testset "Lexical/Empty String" begin
        @test collect(L.tokens(L.State(IOBuffer("")))) == [ ]
    end

    @testset "Lexical/Single Tokens (Single Character)" begin
        @test collect(L.tokens(L.State(IOBuffer("["))))  == [ L.Token(L.dso, "[",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("]"))))  == [ L.Token(L.dsc, "]",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("#"))))  == [ L.Token(L.rni, "#",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("\"")))) == [ L.Token(L.lit, "\"",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("'"))))  == [ L.Token(L.lita, "'",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("("))))  == [ L.Token(L.grpo, "(",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer(")"))))  == [ L.Token(L.grpc, ")",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("|"))))  == [ L.Token(L.or, "|",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer(","))))  == [ L.Token(L.seq, ",",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("?"))))  == [ L.Token(L.opt, "?",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("*"))))  == [ L.Token(L.rep, "*",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("+"))))  == [ L.Token(L.plus, "+",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("-"))))  == [ L.Token(L.minus, "-",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("&"))))  == [ L.Token(L.ero, "&",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("%"))))  == [ L.Token(L.pero, "%",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer(";"))))  == [ L.Token(L.refc, ";",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("<"))))  == [ L.Token(L.stago, "<",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer(">"))))  == [ L.Token(L.tagc, ">",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("/"))))  == [ L.Token(L.net, "/",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("="))))  == [ L.Token(L.vi, "=",  "a buffer", -1) ]
    end

    @testset "Lexical/Single Tokens (Two Character)" begin
        @test collect(L.tokens(L.State(IOBuffer("<!"))))  == [ L.Token(L.mdo, "<!",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("]]"))))  == [ L.Token(L.msc, "]]",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("--"))))  == [ L.Token(L.com, "--",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("&#"))))  == [ L.Token(L.cro, "&#",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("<?"))))  == [ L.Token(L.pio, "<?",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("?>"))))  == [ L.Token(L.pic, "?>",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("</"))))  == [ L.Token(L.etago, "</",  "a buffer", -1) ]
    end

    @testset "Lexical/Single Tokens (Basic Text)" begin
        @test collect(L.tokens(L.State(IOBuffer("a"))))    == [ L.Token(L.text, "a",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("ab"))))   == [ L.Token(L.text, "ab",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("abc"))))  == [ L.Token(L.text, "abc",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("∈"))))    == [ L.Token(L.text, "∈",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("a∈"))))   == [ L.Token(L.text, "a∈",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("∈b"))))   == [ L.Token(L.text, "∈b",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("a∈b"))))  == [ L.Token(L.text, "a∈b",  "a buffer", -1) ]
    end

    @testset "Lexical/Single Tokens (White Space)" begin
        @test collect(L.tokens(L.State(IOBuffer("\u20")))) == [ L.Token(L.ws, "\u20",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer(" ")))) == [ L.Token(L.ws, "\u20",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("\u09")))) == [ L.Token(L.ws, "\u09",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("	")))) == [ L.Token(L.ws, "\u09",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("\t")))) == [ L.Token(L.ws, "\u09",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("\u0a")))) == [ L.Token(L.ws, "\u0a",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("\u0d")))) == [ L.Token(L.ws, "\u0d",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("\n")))) == [ L.Token(L.ws, "\u0a",  "a buffer", -1) ]
        @test collect(L.tokens(L.State(IOBuffer("\r")))) == [ L.Token(L.ws, "\u0d",  "a buffer", -1) ]

        @test collect(L.tokens(L.State(IOBuffer(" 	\n\r")))) == [ L.Token(L.ws, " 	\n\r",  "a buffer", -1) ]
    end

    @testset "Lexical/Multiple Tokens (Realistic-ish Sequences" begin
        @test collect(L.tokens(L.State(IOBuffer("<a>")))) == [ L.Token(L.stago, "<",  "a buffer", -1),
                                                               L.Token(L.text, "a",  "a buffer", -1),
                                                               L.Token(L.tagc, ">",  "a buffer", -1), ]
        @test collect(L.tokens(L.State(IOBuffer("<π>")))) == [ L.Token(L.stago, "<",  "a buffer", -1),
                                                               L.Token(L.text, "π",  "a buffer", -1),
                                                               L.Token(L.tagc, ">",  "a buffer", -1), ]
        @test (collect(L.tokens(L.State(IOBuffer("<a a.a=\"Hello, World!\" a.b=\"Salut, Monde!\"/>"))))
               == [ L.Token(L.stago, "<",  "a buffer", -1),
                    L.Token(L.text, "a",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "a.a",  "a buffer", -1),
                    L.Token(L.vi, "=",  "a buffer", -1),
                    L.Token(L.lit, "\"",  "a buffer", -1),
                    L.Token(L.text, "Hello",  "a buffer", -1),
                    L.Token(L.seq, ",",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "World!",  "a buffer", -1),
                    L.Token(L.lit, "\"",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "a.b",  "a buffer", -1),
                    L.Token(L.vi, "=",  "a buffer", -1),
                    L.Token(L.lit, "\"",  "a buffer", -1),
                    L.Token(L.text, "Salut",  "a buffer", -1),
                    L.Token(L.seq, ",",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "Monde!",  "a buffer", -1),
                    L.Token(L.lit, "\"",  "a buffer", -1),
                    L.Token(L.net, "/",  "a buffer", -1),
                    L.Token(L.tagc, ">",  "a buffer", -1), ])
        @test (collect(L.tokens(L.State(IOBuffer("<a>Hello, World!</a>"))))
               == [ L.Token(L.stago, "<",  "a buffer", -1),
                    L.Token(L.text, "a",  "a buffer", -1),
                    L.Token(L.tagc, ">",  "a buffer", -1),
                    L.Token(L.text, "Hello",  "a buffer", -1),
                    L.Token(L.seq, ",",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "World!",  "a buffer", -1),
                    L.Token(L.etago, "</",  "a buffer", -1),
                    L.Token(L.text, "a",  "a buffer", -1),
                    L.Token(L.tagc, ">",  "a buffer", -1), ])
        @test (collect(L.tokens(L.State(IOBuffer("<!DOCTYPE root []>"))))
               == [ L.Token(L.mdo, "<!",  "a buffer", -1),
                    L.Token(L.text, "DOCTYPE",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "root",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.dso, "[",  "a buffer", -1),
                    L.Token(L.dsc, "]",  "a buffer", -1),
                    L.Token(L.tagc, ">",  "a buffer", -1), ])
        @test (collect(L.tokens(L.State(IOBuffer("<!DOCTYPE root [<!ELEMENT root EMPTY>]><root/>"))))
               == [ L.Token(L.mdo, "<!",  "a buffer", -1),
                    L.Token(L.text, "DOCTYPE",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "root",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.dso, "[",  "a buffer", -1),
                    L.Token(L.mdo, "<!",  "a buffer", -1),
                    L.Token(L.text, "ELEMENT",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "root",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "EMPTY",  "a buffer", -1),
                    L.Token(L.tagc, ">",  "a buffer", -1),
                    L.Token(L.dsc, "]",  "a buffer", -1),
                    L.Token(L.tagc, ">",  "a buffer", -1),
                    L.Token(L.stago, "<",  "a buffer", -1),
                    L.Token(L.text, "root",  "a buffer", -1),
                    L.Token(L.net, "/",  "a buffer", -1),
                    L.Token(L.tagc, ">",  "a buffer", -1), ])
        @test (collect(L.tokens(L.State(IOBuffer("<!-- This is a comment, don't you know! -->"))))
               == [ L.Token(L.mdo, "<!",  "a buffer", -1),
                    L.Token(L.com, "--",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "This",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "is",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "a",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "comment",  "a buffer", -1),
                    L.Token(L.seq, ",",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "don",  "a buffer", -1),
                    L.Token(L.lita, "'",  "a buffer", -1),
                    L.Token(L.text, "t",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "you",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "know!",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.com, "--",  "a buffer", -1),
                    L.Token(L.tagc, ">",  "a buffer", -1), ])
        @test (collect(L.tokens(L.State(IOBuffer("<?PITarget Value?>"))))
               == [ L.Token(L.pio, "<?",  "a buffer", -1),
                    L.Token(L.text, "PITarget",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "Value",  "a buffer", -1),
                    L.Token(L.pic, "?>",  "a buffer", -1), ])
        @test (collect(L.tokens(L.State(IOBuffer("&#32;"))))
               == [ L.Token(L.cro, "&#",  "a buffer", -1),
                    L.Token(L.text, "32",  "a buffer", -1),
                    L.Token(L.refc, ";",  "a buffer", -1), ])
        @test (collect(L.tokens(L.State(IOBuffer("&#x20;"))))
               == [ L.Token(L.cro, "&#",  "a buffer", -1),
                    L.Token(L.text, "x20",  "a buffer", -1),
                    L.Token(L.refc, ";",  "a buffer", -1), ])
        @test (collect(L.tokens(L.State(IOBuffer("&eacute;"))))
               == [ L.Token(L.ero, "&",  "a buffer", -1),
                    L.Token(L.text, "eacute",  "a buffer", -1),
                    L.Token(L.refc, ";",  "a buffer", -1), ])
        @test (collect(L.tokens(L.State(IOBuffer("%ISOlat1;"))))
               == [ L.Token(L.pero, "%",  "a buffer", -1),
                    L.Token(L.text, "ISOlat1",  "a buffer", -1),
                    L.Token(L.refc, ";",  "a buffer", -1), ])
        @test (collect(L.tokens(L.State(IOBuffer("<![CDATA[Hello, World!]]>"))))
               == [ L.Token(L.mdo, "<!",  "a buffer", -1),
                    L.Token(L.dso, "[",  "a buffer", -1),
                    L.Token(L.text, "CDATA",  "a buffer", -1),
                    L.Token(L.dso, "[",  "a buffer", -1),
                    L.Token(L.text, "Hello",  "a buffer", -1),
                    L.Token(L.seq, ",",  "a buffer", -1),
                    L.Token(L.ws, " ",  "a buffer", -1),
                    L.Token(L.text, "World!",  "a buffer", -1),
                    L.Token(L.msc, "]]",  "a buffer", -1),
                    L.Token(L.tagc, ">",  "a buffer", -1), ])
    end
end
