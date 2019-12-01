@testset "Lexical" begin
    L = Lexical

    @testset "Lexical/Empty String" begin
        @test collect(L.tokens(L.State(IOBuffer("")))) == [ ]
    end

    @testset "Lexical/Single Tokens (Single Character)" begin
        @test collect(L.tokens(L.State(IOBuffer("["))))  == [ L.Token(L.dso, "[", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("]"))))  == [ L.Token(L.dsc, "]", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("#"))))  == [ L.Token(L.rni, "#", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("\"")))) == [ L.Token(L.lit, "\"", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("'"))))  == [ L.Token(L.lita, "'", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("("))))  == [ L.Token(L.grpo, "(", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer(")"))))  == [ L.Token(L.grpc, ")", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("|"))))  == [ L.Token(L.or, "|", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer(","))))  == [ L.Token(L.seq, ",", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("?"))))  == [ L.Token(L.opt, "?", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("*"))))  == [ L.Token(L.rep, "*", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("+"))))  == [ L.Token(L.plus, "+", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("-"))))  == [ L.Token(L.minus, "-", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("&"))))  == [ L.Token(L.ero, "&", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("%"))))  == [ L.Token(L.pero, "%", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer(";"))))  == [ L.Token(L.refc, ";", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("<"))))  == [ L.Token(L.stago, "<", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer(">"))))  == [ L.Token(L.tagc, ">", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("/"))))  == [ L.Token(L.net, "/", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("="))))  == [ L.Token(L.vi, "=", L.Location("a buffer", -1)) ]
    end

    @testset "Lexical/Single Tokens (Two Character)" begin
        @test collect(L.tokens(L.State(IOBuffer("<!"))))  == [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("]]"))))  == [ L.Token(L.msc, "]]", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("--"))))  == [ L.Token(L.com, "--", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("&#"))))  == [ L.Token(L.cro, "&#", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("<?"))))  == [ L.Token(L.pio, "<?", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("?>"))))  == [ L.Token(L.pic, "?>", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("</"))))  == [ L.Token(L.etago, "</", L.Location("a buffer", -1)) ]
    end

    @testset "Lexical/Single Tokens (Basic Text)" begin
        @test collect(L.tokens(L.State(IOBuffer("a"))))    == [ L.Token(L.text, "a", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("ab"))))   == [ L.Token(L.text, "ab", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("abc"))))  == [ L.Token(L.text, "abc", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("∈"))))    == [ L.Token(L.text, "∈", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("a∈"))))   == [ L.Token(L.text, "a∈", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("∈b"))))   == [ L.Token(L.text, "∈b", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("a∈b"))))  == [ L.Token(L.text, "a∈b", L.Location("a buffer", -1)) ]
    end

    @testset "Lexical/Single Tokens (White Space)" begin
        @test collect(L.tokens(L.State(IOBuffer("\u20")))) == [ L.Token(L.ws, "\u20", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer(" ")))) == [ L.Token(L.ws, "\u20", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("\u09")))) == [ L.Token(L.ws, "\u09", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("	")))) == [ L.Token(L.ws, "\u09", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("\t")))) == [ L.Token(L.ws, "\u09", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("\u0a")))) == [ L.Token(L.ws, "\u0a", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("\u0d")))) == [ L.Token(L.ws, "\u0d", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("\n")))) == [ L.Token(L.ws, "\u0a", L.Location("a buffer", -1)) ]
        @test collect(L.tokens(L.State(IOBuffer("\r")))) == [ L.Token(L.ws, "\u0d", L.Location("a buffer", -1)) ]

        @test collect(L.tokens(L.State(IOBuffer(" 	\n\r")))) == [ L.Token(L.ws, " 	\n\r", L.Location("a buffer", -1)) ]
    end

    @testset "Lexical/Multiple Tokens (Realistic-ish Sequences" begin
        @test collect(L.tokens(L.State(IOBuffer("<a>")))) == [ L.Token(L.stago, "<", L.Location("a buffer", -1)),
                                                               L.Token(L.text, "a", L.Location("a buffer", -1)),
                                                               L.Token(L.tagc, ">", L.Location("a buffer", -1)), ]
        @test collect(L.tokens(L.State(IOBuffer("<π>")))) == [ L.Token(L.stago, "<", L.Location("a buffer", -1)),
                                                               L.Token(L.text, "π", L.Location("a buffer", -1)),
                                                               L.Token(L.tagc, ">", L.Location("a buffer", -1)), ]
        @test (collect(L.tokens(L.State(IOBuffer("<a a.a=\"Hello, World!\" a.b=\"Salut, Monde!\"/>"))))
               == [ L.Token(L.stago, "<", L.Location("a buffer", -1)),
                    L.Token(L.text, "a", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "a.a", L.Location("a buffer", -1)),
                    L.Token(L.vi, "=", L.Location("a buffer", -1)),
                    L.Token(L.lit, "\"", L.Location("a buffer", -1)),
                    L.Token(L.text, "Hello", L.Location("a buffer", -1)),
                    L.Token(L.seq, ",", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "World!", L.Location("a buffer", -1)),
                    L.Token(L.lit, "\"", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "a.b", L.Location("a buffer", -1)),
                    L.Token(L.vi, "=", L.Location("a buffer", -1)),
                    L.Token(L.lit, "\"", L.Location("a buffer", -1)),
                    L.Token(L.text, "Salut", L.Location("a buffer", -1)),
                    L.Token(L.seq, ",", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "Monde!", L.Location("a buffer", -1)),
                    L.Token(L.lit, "\"", L.Location("a buffer", -1)),
                    L.Token(L.net, "/", L.Location("a buffer", -1)),
                    L.Token(L.tagc, ">", L.Location("a buffer", -1)), ])
        @test (collect(L.tokens(L.State(IOBuffer("<a>Hello, World!</a>"))))
               == [ L.Token(L.stago, "<", L.Location("a buffer", -1)),
                    L.Token(L.text, "a", L.Location("a buffer", -1)),
                    L.Token(L.tagc, ">", L.Location("a buffer", -1)),
                    L.Token(L.text, "Hello", L.Location("a buffer", -1)),
                    L.Token(L.seq, ",", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "World!", L.Location("a buffer", -1)),
                    L.Token(L.etago, "</", L.Location("a buffer", -1)),
                    L.Token(L.text, "a", L.Location("a buffer", -1)),
                    L.Token(L.tagc, ">", L.Location("a buffer", -1)), ])
        @test (collect(L.tokens(L.State(IOBuffer("<!DOCTYPE root []>"))))
               == [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                    L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "root", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.dso, "[", L.Location("a buffer", -1)),
                    L.Token(L.dsc, "]", L.Location("a buffer", -1)),
                    L.Token(L.tagc, ">", L.Location("a buffer", -1)), ])
        @test (collect(L.tokens(L.State(IOBuffer("<!DOCTYPE root [<!ELEMENT root EMPTY>]><root/>"))))
               == [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                    L.Token(L.text, "DOCTYPE", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "root", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.dso, "[", L.Location("a buffer", -1)),
                    L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                    L.Token(L.text, "ELEMENT", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "root", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "EMPTY", L.Location("a buffer", -1)),
                    L.Token(L.tagc, ">", L.Location("a buffer", -1)),
                    L.Token(L.dsc, "]", L.Location("a buffer", -1)),
                    L.Token(L.tagc, ">", L.Location("a buffer", -1)),
                    L.Token(L.stago, "<", L.Location("a buffer", -1)),
                    L.Token(L.text, "root", L.Location("a buffer", -1)),
                    L.Token(L.net, "/", L.Location("a buffer", -1)),
                    L.Token(L.tagc, ">", L.Location("a buffer", -1)), ])
        @test (collect(L.tokens(L.State(IOBuffer("<!-- This is a comment, don't you know! -->"))))
               == [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                    L.Token(L.com, "--", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "This", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "is", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "a", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "comment", L.Location("a buffer", -1)),
                    L.Token(L.seq, ",", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "don", L.Location("a buffer", -1)),
                    L.Token(L.lita, "'", L.Location("a buffer", -1)),
                    L.Token(L.text, "t", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "you", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "know!", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.com, "--", L.Location("a buffer", -1)),
                    L.Token(L.tagc, ">", L.Location("a buffer", -1)), ])
        @test (collect(L.tokens(L.State(IOBuffer("<?PITarget Value?>"))))
               == [ L.Token(L.pio, "<?", L.Location("a buffer", -1)),
                    L.Token(L.text, "PITarget", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "Value", L.Location("a buffer", -1)),
                    L.Token(L.pic, "?>", L.Location("a buffer", -1)), ])
        @test (collect(L.tokens(L.State(IOBuffer("&#32;"))))
               == [ L.Token(L.cro, "&#", L.Location("a buffer", -1)),
                    L.Token(L.text, "32", L.Location("a buffer", -1)),
                    L.Token(L.refc, ";", L.Location("a buffer", -1)), ])
        @test (collect(L.tokens(L.State(IOBuffer("&#x20;"))))
               == [ L.Token(L.cro, "&#", L.Location("a buffer", -1)),
                    L.Token(L.text, "x20", L.Location("a buffer", -1)),
                    L.Token(L.refc, ";", L.Location("a buffer", -1)), ])
        @test (collect(L.tokens(L.State(IOBuffer("&eacute;"))))
               == [ L.Token(L.ero, "&", L.Location("a buffer", -1)),
                    L.Token(L.text, "eacute", L.Location("a buffer", -1)),
                    L.Token(L.refc, ";", L.Location("a buffer", -1)), ])
        @test (collect(L.tokens(L.State(IOBuffer("%ISOlat1;"))))
               == [ L.Token(L.pero, "%", L.Location("a buffer", -1)),
                    L.Token(L.text, "ISOlat1", L.Location("a buffer", -1)),
                    L.Token(L.refc, ";", L.Location("a buffer", -1)), ])
        @test (collect(L.tokens(L.State(IOBuffer("<![CDATA[Hello, World!]]>"))))
               == [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                    L.Token(L.dso, "[", L.Location("a buffer", -1)),
                    L.Token(L.text, "CDATA", L.Location("a buffer", -1)),
                    L.Token(L.dso, "[", L.Location("a buffer", -1)),
                    L.Token(L.text, "Hello", L.Location("a buffer", -1)),
                    L.Token(L.seq, ",", L.Location("a buffer", -1)),
                    L.Token(L.ws, " ", L.Location("a buffer", -1)),
                    L.Token(L.text, "World!", L.Location("a buffer", -1)),
                    L.Token(L.msc, "]]", L.Location("a buffer", -1)),
                    L.Token(L.tagc, ">", L.Location("a buffer", -1)), ])
    end
end
