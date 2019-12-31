@testset "Events/Miscellaneous" begin
    # These test sets are a grab bag of tests that don't fit anywhere else.
    #
    tokenize(s) = L.tokens(L.State(IOBuffer(s)))

    E = Events
    L = Events.Lexical

    name_start_chars = [ Char(':'), Char('A'):Char('Z'), Char('a'):Char('z'),
                         0xc0:0xd6, 0xd8:0xf6, 0xf8:0x2ff, 0x370:0x37d, 0x37f:0x1fff,
                         0x200c:0x200d, 0x2070:0x218f, 0x2c00:0x2fef, 0x3001:0xd7ff,
                         0xf900:0xfdcf, 0xfdf0:0xfffd, 0x10000:0xeffff ]

    # This is only the "other" characters that are in NameChar ... to get a full set, we will need to include
    # NameStartChar.
    #
    name_chars = [ Char('-'), Char('.'), Char('0'):Char('9'), 0xb7, 0x300:0x36f, 0x203f:0x2040 ]

    # These are some characters that are not part of either of the two above sets.
    #
    other_chars = [ 0xb8:0xbf, 0xd7, 0xf7, 0x37e, 0x200e:0x203e ]

    function select_characters(character_range)
        if length(character_range) == 1
            return [ String([ Char(character_range) ]) ]

        else
            result = [ String([ Char(character_range.start) ]), String([ Char(character_range.stop) ]) ]

            if length(character_range) > 2
                other_character = rand(character_range[2:length(character_range) - 1])

                push!(result, String([ Char(other_character) ]))
            end

            return result
        end
    end


    function build_values(character_range)
        return select_characters(character_range)
    end

    function build_values(first_character_range, second_character_range)
        first_set  = select_characters(first_character_range)
        second_set = select_characters(second_character_range)

        return vec([ f * s for f ∈ first_set, s ∈ second_set ])
    end

    function build_values(first_character_range, second_character_range, third_character_range)
        first_set  = select_characters(first_character_range)
        second_set = select_characters(second_character_range)
        third_set  = select_characters(third_character_range)

        return vec([ f * s * t for f ∈ first_set, s ∈ second_set, t ∈ third_set ])
    end

    @testset "Events/Miscellaneous, is_name() (Positive)" begin
        # First some trivial cases ... basically trigger each branch. If it's a range, trigger it at each extreme and
        # somewhere in the middle (selected randomly)
        #
        for name_start_char ∈ name_start_chars
            for name ∈ build_values(name_start_char)
                tokens = tokenize(name)
                @test E.is_name(tokens)
                @test length(collect(tokens)) == 1
            end
        end

        # Now some two-character cases, where both characters come from NameStartChar.
        #
        for name_start_char ∈ name_start_chars
            for name_char ∈ name_start_chars
                for name ∈ build_values(name_start_char, name_char)
                    tokens = tokenize(name)
                    @test E.is_name(tokens)
                    @test length(collect(tokens)) == 1
                end
            end
        end

        # And now some two character-cases, where the second character comes from NameChar.
        #
        for name_start_char ∈ name_start_chars
            for name_char ∈ name_chars
                for name ∈ build_values(name_start_char, name_char)
                    tokens = tokenize(name)
                    @test E.is_name(tokens)
                    @test length(collect(tokens)) == 1
                end
            end
        end

        # Finally, some three character-cases. Trying combinations like we did earlier could take way too much time. So
        # we'll randomly construct one and test it.
        #
        all_name_chars = vcat(name_start_chars, name_chars)

        name_start_char  = rand(name_start_chars)
        second_name_char = rand(all_name_chars)
        third_name_char  = rand(all_name_chars)

        name = rand(build_values(name_start_char, second_name_char, third_name_char))

        tokens = tokenize(name)
        @test E.is_name(tokens)
        @test length(collect(tokens)) == 1
    end

    @testset "Events/Miscellaneous, is_nmtoken() (Positive)" begin
        # First some trivial cases ... basically trigger each branch. If it's a range, trigger it at each extreme and
        # somewhere in the middle (selected randomly)
        #
        for name_char ∈ name_chars
            for nmtoken ∈ build_values(name_char)
                tokens = tokenize(nmtoken)
                @test E.is_nmtoken(tokens)
                @test length(collect(tokens)) == 1
            end
        end

        # Now some two-character cases.
        #
        for first_name_char ∈ name_chars
            for second_name_char ∈ name_chars
                for nmtoken ∈ build_values(first_name_char, second_name_char)
                    tokens = tokenize(nmtoken)
                    @test E.is_nmtoken(tokens)
                    @test length(collect(tokens)) == 1
                end
            end
        end

        # Finally, some three character-cases. Trying combinations like we did earlier could take way too much time. So
        # we'll randomly construct one and test it.
        #
        all_name_chars = vcat(name_start_chars, name_chars)

        first_name_char  = rand(all_name_chars)
        second_name_char = rand(all_name_chars)
        third_name_char  = rand(all_name_chars)

        nmtoken = rand(build_values(first_name_char, second_name_char, third_name_char))

        tokens = tokenize(nmtoken)
        @test E.is_nmtoken(tokens)
        @test length(collect(tokens)) == 1
    end

    @testset "Events/Miscellaneous, is_name() (Negative)" begin
        # Negative tests for single-character names are easy enough ... just choose a character from NameChar.
        #
        for name_start_char ∈ name_chars
            for name ∈ build_values(name_start_char)
                tokens = tokenize(name)
                @test !E.is_name(tokens)
            end
        end

        # For two character-cases, uses a "safe" character for the first position, and pull the second character from
        # other_chars, defined above.
        #
        for first_char ∈ [ 'a' ]
            for second_char ∈ other_chars
                for name ∈ build_values(first_char, second_char)
                    tokens = tokenize(name)
                    @test !E.is_name(tokens)
                    @test length(collect(tokens)) == 1
                end
            end
        end

        # Finally, make sure that is_name() doesn't try accepting tokens that aren't of type text to begin with.
        #
        for input ∈ [ "+", "<", "<!", " ", "<?", "?>", ">", "" ]
            tokens = tokenize(input)
            @test !E.is_name(tokens)
        end
    end

    @testset "Events/Miscellaneous, is_nmtoken() (Negative)" begin
        # Negative tests for single-character nmtokens are easy enough ... just choose a character from other_chars,
        # defined above.
        #
        for name_char ∈ other_chars
            for nmtoken ∈ build_values(name_char)
                tokens = tokenize(nmtoken)
                @test !E.is_nmtoken(tokens)
            end
        end

        # For two character-cases, uses a "safe" character for the first position, and pull the second character from
        # other_chars, defined above.
        #
        for first_char ∈ [ 'a' ]
            for second_char ∈ other_chars
                for nmtoken ∈ build_values(first_char, second_char)
                    tokens = tokenize(nmtoken)
                    @test !E.is_nmtoken(tokens)
                    @test length(collect(tokens)) == 1
                end
            end
        end

        # Finally, make sure that is_name() doesn't try accepting tokens that aren't of type text to begin with.
        #
        for input ∈ [ "+", "<", "<!", " ", "<?", "?>", ">", "" ]
            tokens = tokenize(input)
            @test !E.is_nmtoken(tokens)
        end
    end
end
