@testset "Events/Entity Declarations" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Entity Declarations, Internal General (Positive)" begin
        # Basic tests ... empty entity value.
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY a \"\">"))))
               == [ E.EntityDeclarationInternalGeneral("a", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY abc \"\">"))))
               == [ E.EntityDeclarationInternalGeneral("abc", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY é \"\">"))))
               == [ E.EntityDeclarationInternalGeneral("é", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY aé \"\">"))))
               == [ E.EntityDeclarationInternalGeneral("aé", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY éb \"\">"))))
               == [ E.EntityDeclarationInternalGeneral("éb", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY aéb \"\">"))))
               == [ E.EntityDeclarationInternalGeneral("aéb", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY\na\n\"\">"))))
               == [ E.EntityDeclarationInternalGeneral("a", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY\na\t\"\">"))))
               == [ E.EntityDeclarationInternalGeneral("a", "", "a buffer", -1) ])

        # This is from the XML specification, § 4.2.1 ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY Pub-Status \"This is a pre-release of the\nspecification.\">"))))
               == [ E.EntityDeclarationInternalGeneral("Pub-Status", "This is a pre-release of the\nspecification.",
                                                       "a buffer", -1) ])

        # This is from the XML specification, § 4.4.5 ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY WhatHeSaid \"He said %YN;\" >"))))
               == [ E.EntityDeclarationInternalGeneral("WhatHeSaid", "He said %YN;", "a buffer", -1) ])
    end

    @testset "Events/Entity Declarations, Internal Parameter (Positive)" begin
        # Basic tests ... empty entity value.
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % a \"\">"))))
               == [ E.EntityDeclarationInternalParameter("a", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % abc \"\">"))))
               == [ E.EntityDeclarationInternalParameter("abc", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % é \"\">"))))
               == [ E.EntityDeclarationInternalParameter("é", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % aé \"\">"))))
               == [ E.EntityDeclarationInternalParameter("aé", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % éb \"\">"))))
               == [ E.EntityDeclarationInternalParameter("éb", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % aéb \"\">"))))
               == [ E.EntityDeclarationInternalParameter("aéb", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY\n%\na\n\"\">"))))
               == [ E.EntityDeclarationInternalParameter("a", "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY\n%\ta\t\"\">"))))
               == [ E.EntityDeclarationInternalParameter("a", "", "a buffer", -1) ])

        # This is from the XML specification, § 4.4.5 ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % YN \'\"Yes\"\' >"))))
               == [ E.EntityDeclarationInternalParameter("YN", "\"Yes\"", "a buffer", -1) ])
    end
end
