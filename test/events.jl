@testset "Events" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Empty String" begin
        @test collect(E.events(L.State(IOBuffer("")))) == [ ]
    end

    @testset "Events/Character References (Positive)" begin
        @test collect(E.events(L.State(IOBuffer("&#10;")))) == [ E.CharacterReference("10", "a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("&#xa;")))) == [ E.CharacterReference("xa", "a buffer", -1) ]
        # This is a bogus character reference in terms of the XML specification, but legit at this layer of the parser. 
        #
        @test collect(E.events(L.State(IOBuffer("&#xxx;")))) == [ E.CharacterReference("xxx", "a buffer", -1) ]
    end
end
