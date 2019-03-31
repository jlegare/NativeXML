@testset "Events/Basic" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Basic/Empty String" begin
        @test collect(E.events(L.State(IOBuffer("")))) == [ ]
    end
end
