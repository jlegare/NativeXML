@testset "Lexical" begin
    M = Lexical

    @testset "Lexical/Empty String" begin
        @test collect(M.tokens(M.State(IOBuffer("")))) == [ ]
    end

    @testset "Lexical/Single Tokens (Single Character)" begin
        @test collect(M.tokens(M.State(IOBuffer("["))))  == [ M.Token(M.dso, "[",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("]"))))  == [ M.Token(M.dsc, "]",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("#"))))  == [ M.Token(M.rni, "#",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("\"")))) == [ M.Token(M.lit, "\"",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("'"))))  == [ M.Token(M.lita, "'",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("("))))  == [ M.Token(M.grpo, "(",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer(")"))))  == [ M.Token(M.grpc, ")",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("|"))))  == [ M.Token(M.or, "|",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer(","))))  == [ M.Token(M.seq, ",",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("?"))))  == [ M.Token(M.opt, "?",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("*"))))  == [ M.Token(M.rep, "*",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("+"))))  == [ M.Token(M.plus, "+",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("-"))))  == [ M.Token(M.minus, "-",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("&"))))  == [ M.Token(M.ero, "&",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("%"))))  == [ M.Token(M.pero, "%",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer(";"))))  == [ M.Token(M.refc, ";",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("<"))))  == [ M.Token(M.stago, "<",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer(">"))))  == [ M.Token(M.tagc, ">",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("/"))))  == [ M.Token(M.net, "/",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("="))))  == [ M.Token(M.vi, "=",  "a buffer", -1) ]
    end

    @testset "Lexical/Single Tokens (Two Character)" begin
        @test collect(M.tokens(M.State(IOBuffer("<!"))))  == [ M.Token(M.mdo, "<!",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("]]"))))  == [ M.Token(M.msc, "]]",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("--"))))  == [ M.Token(M.com, "--",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("&#"))))  == [ M.Token(M.cro, "&#",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("<?"))))  == [ M.Token(M.pio, "<?",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("?>"))))  == [ M.Token(M.pic, "?>",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("</"))))  == [ M.Token(M.etago, "</",  "a buffer", -1) ]
    end

    @testset "Lexical/Single Tokens (Basic Text)" begin
        @test collect(M.tokens(M.State(IOBuffer("a"))))    == [ M.Token(M.text, "a",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("ab"))))   == [ M.Token(M.text, "ab",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("abc"))))  == [ M.Token(M.text, "abc",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("∈"))))    == [ M.Token(M.text, "∈",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("a∈"))))   == [ M.Token(M.text, "a∈",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("∈b"))))   == [ M.Token(M.text, "∈b",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("a∈b"))))  == [ M.Token(M.text, "a∈b",  "a buffer", -1) ]
    end

    @testset "Lexical/Single Tokens (White Space)" begin
        @test collect(M.tokens(M.State(IOBuffer("\u20")))) == [ M.Token(M.ws, "\u20",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer(" ")))) == [ M.Token(M.ws, "\u20",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("\u09")))) == [ M.Token(M.ws, "\u09",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("	")))) == [ M.Token(M.ws, "\u09",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("\t")))) == [ M.Token(M.ws, "\u09",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("\u0a")))) == [ M.Token(M.ws, "\u0a",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("\u0d")))) == [ M.Token(M.ws, "\u0d",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("\n")))) == [ M.Token(M.ws, "\u0a",  "a buffer", -1) ]
        @test collect(M.tokens(M.State(IOBuffer("\r")))) == [ M.Token(M.ws, "\u0d",  "a buffer", -1) ]

        @test collect(M.tokens(M.State(IOBuffer(" 	\n\r")))) == [ M.Token(M.ws, " 	\n\r",  "a buffer", -1) ]
    end

    @testset "Lexical/Multiple Tokens (Realistic-ish Sequences" begin
        @test collect(M.tokens(M.State(IOBuffer("<a>")))) == [ M.Token(M.stago, "<",  "a buffer", -1),
                                                               M.Token(M.text, "a",  "a buffer", -1),
                                                               M.Token(M.tagc, ">",  "a buffer", -1), ]
        @test collect(M.tokens(M.State(IOBuffer("<π>")))) == [ M.Token(M.stago, "<",  "a buffer", -1),
                                                               M.Token(M.text, "π",  "a buffer", -1),
                                                               M.Token(M.tagc, ">",  "a buffer", -1), ]
        @test (collect(M.tokens(M.State(IOBuffer("<a a.a=\"Hello, World!\" a.b=\"Salut, Monde!\"/>")))) 
               == [ M.Token(M.stago, "<",  "a buffer", -1),
                    M.Token(M.text, "a",  "a buffer", -1),
                    M.Token(M.ws, " ",  "a buffer", -1),
                    M.Token(M.text, "a.a",  "a buffer", -1),
                    M.Token(M.vi, "=",  "a buffer", -1),
                    M.Token(M.lit, "\"",  "a buffer", -1),
                    M.Token(M.text, "Hello",  "a buffer", -1),
                    M.Token(M.seq, ",",  "a buffer", -1),
                    M.Token(M.ws, " ",  "a buffer", -1),
                    M.Token(M.text, "World!",  "a buffer", -1),
                    M.Token(M.lit, "\"",  "a buffer", -1),
                    M.Token(M.ws, " ",  "a buffer", -1),
                    M.Token(M.text, "a.b",  "a buffer", -1),
                    M.Token(M.vi, "=",  "a buffer", -1),
                    M.Token(M.lit, "\"",  "a buffer", -1),
                    M.Token(M.text, "Salut",  "a buffer", -1),
                    M.Token(M.seq, ",",  "a buffer", -1),
                    M.Token(M.ws, " ",  "a buffer", -1),
                    M.Token(M.text, "Monde!",  "a buffer", -1),
                    M.Token(M.lit, "\"",  "a buffer", -1),
                    M.Token(M.net, "/",  "a buffer", -1),
                    M.Token(M.tagc, ">",  "a buffer", -1), ])
    end
end
