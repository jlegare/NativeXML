@testset "Events/Entity Declarations" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Entity Declarations, Internal General (Positive)" begin
        # Basic tests ... empty entity value.
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY a \"\">"))))
               == [ E.EntityDeclarationInternalGeneral("a", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY abc \"\">"))))
               == [ E.EntityDeclarationInternalGeneral("abc", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY é \"\">"))))
               == [ E.EntityDeclarationInternalGeneral("é", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY aé \"\">"))))
               == [ E.EntityDeclarationInternalGeneral("aé", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY éb \"\">"))))
               == [ E.EntityDeclarationInternalGeneral("éb", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY aéb \"\">"))))
               == [ E.EntityDeclarationInternalGeneral("aéb", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY\na\n\"\">"))))
               == [ E.EntityDeclarationInternalGeneral("a", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY\na\t\"\">"))))
               == [ E.EntityDeclarationInternalGeneral("a", "", L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 4.2.1 ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY Pub-Status \"This is a pre-release of the\nspecification.\">"))))
               == [ E.EntityDeclarationInternalGeneral("Pub-Status", "This is a pre-release of the\nspecification.",
                                                       L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 4.4.5 ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY WhatHeSaid \"He said %YN;\" >"))))
               == [ E.EntityDeclarationInternalGeneral("WhatHeSaid", "He said %YN;", L.Location("a buffer", -1)) ])
    end

    @testset "Events/Entity Declarations, Internal Parameter (Positive)" begin
        # Basic tests ... empty entity value.
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % a \"\">"))))
               == [ E.EntityDeclarationInternalParameter("a", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % abc \"\">"))))
               == [ E.EntityDeclarationInternalParameter("abc", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % é \"\">"))))
               == [ E.EntityDeclarationInternalParameter("é", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % aé \"\">"))))
               == [ E.EntityDeclarationInternalParameter("aé", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % éb \"\">"))))
               == [ E.EntityDeclarationInternalParameter("éb", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % aéb \"\">"))))
               == [ E.EntityDeclarationInternalParameter("aéb", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY\n%\na\n\"\">"))))
               == [ E.EntityDeclarationInternalParameter("a", "", L.Location("a buffer", -1)) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY\n%\ta\t\"\">"))))
               == [ E.EntityDeclarationInternalParameter("a", "", L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 4.4.5 ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % YN \'\"Yes\"\' >"))))
               == [ E.EntityDeclarationInternalParameter("YN", "\"Yes\"", L.Location("a buffer", -1)) ])
    end
end
