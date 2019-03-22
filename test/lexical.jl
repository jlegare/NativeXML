@testset "Lexical" begin
    @testset "Lexical/Empty String" begin
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("")))) == [ ]
    end

    @testset "Lexical/Single Tokens (Single Character)" begin
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("["))))  == [ Lexical.Token(Lexical.dso, "[",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("]"))))  == [ Lexical.Token(Lexical.dsc, "]",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("#"))))  == [ Lexical.Token(Lexical.rni, "#",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("\"")))) == [ Lexical.Token(Lexical.lit, "\"",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("'"))))  == [ Lexical.Token(Lexical.lita, "'",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("("))))  == [ Lexical.Token(Lexical.grpo, "(",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer(")"))))  == [ Lexical.Token(Lexical.grpc, ")",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("|"))))  == [ Lexical.Token(Lexical.or, "|",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer(","))))  == [ Lexical.Token(Lexical.seq, ",",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("?"))))  == [ Lexical.Token(Lexical.opt, "?",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("*"))))  == [ Lexical.Token(Lexical.rep, "*",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("+"))))  == [ Lexical.Token(Lexical.plus, "+",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("-"))))  == [ Lexical.Token(Lexical.minus, "-",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("&"))))  == [ Lexical.Token(Lexical.ero, "&",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("%"))))  == [ Lexical.Token(Lexical.pero, "%",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer(";"))))  == [ Lexical.Token(Lexical.refc, ";",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("<"))))  == [ Lexical.Token(Lexical.stago, "<",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer(">"))))  == [ Lexical.Token(Lexical.tagc, ">",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("/"))))  == [ Lexical.Token(Lexical.net, "/",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("="))))  == [ Lexical.Token(Lexical.vi, "=",  "a buffer", -1) ]
    end

    @testset "Lexical/Single Tokens (Two Character)" begin
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("<!"))))  == [ Lexical.Token(Lexical.mdo, "<!",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("]]"))))  == [ Lexical.Token(Lexical.msc, "]]",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("--"))))  == [ Lexical.Token(Lexical.com, "--",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("&#"))))  == [ Lexical.Token(Lexical.cro, "&#",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("<?"))))  == [ Lexical.Token(Lexical.pio, "<?",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("?>"))))  == [ Lexical.Token(Lexical.pic, "?>",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("</"))))  == [ Lexical.Token(Lexical.etago, "</",  "a buffer", -1) ]
    end

    @testset "Lexical/Single Tokens (Basic Text)" begin
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("a"))))    == [ Lexical.Token(Lexical.text, "a",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("ab"))))   == [ Lexical.Token(Lexical.text, "ab",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("abc"))))  == [ Lexical.Token(Lexical.text, "abc",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("∈"))))    == [ Lexical.Token(Lexical.text, "∈",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("a∈"))))   == [ Lexical.Token(Lexical.text, "a∈",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("∈b"))))   == [ Lexical.Token(Lexical.text, "∈b",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("a∈b"))))  == [ Lexical.Token(Lexical.text, "a∈b",  "a buffer", -1) ]
    end

    @testset "Lexical/Single Tokens (White Space)" begin
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("\u20")))) == [ Lexical.Token(Lexical.ws, "\u20",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer(" ")))) == [ Lexical.Token(Lexical.ws, "\u20",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("\u09")))) == [ Lexical.Token(Lexical.ws, "\u09",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("	")))) == [ Lexical.Token(Lexical.ws, "\u09",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("\t")))) == [ Lexical.Token(Lexical.ws, "\u09",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("\u0a")))) == [ Lexical.Token(Lexical.ws, "\u0a",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("\u0d")))) == [ Lexical.Token(Lexical.ws, "\u0d",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("\n")))) == [ Lexical.Token(Lexical.ws, "\u0a",  "a buffer", -1) ]
        @test collect(Lexical.tokens(Lexical.State(IOBuffer("\r")))) == [ Lexical.Token(Lexical.ws, "\u0d",  "a buffer", -1) ]

        @test collect(Lexical.tokens(Lexical.State(IOBuffer(" 	\n\r")))) == [ Lexical.Token(Lexical.ws, 
                                                                                             " 	\n\r",  "a buffer", -1) ]
    end
end
