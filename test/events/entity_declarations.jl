@testset "Events/Entity Declarations" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    @testset "Events/Entity Declarations, Internal General (Positive)" begin
        # Basic tests ... empty entity value.
        #
        @test evaluate("<!ENTITY a \"\">")   == [ E.EntityDeclarationInternalGeneral("a", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY abc \"\">") == [ E.EntityDeclarationInternalGeneral("abc", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY é \"\">")   == [ E.EntityDeclarationInternalGeneral("é", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY aé \"\">")  == [ E.EntityDeclarationInternalGeneral("aé", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY éb \"\">")  == [ E.EntityDeclarationInternalGeneral("éb", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY aéb \"\">") == [ E.EntityDeclarationInternalGeneral("aéb", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY\na\n\"\">") == [ E.EntityDeclarationInternalGeneral("a", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY\na\t\"\">") == [ E.EntityDeclarationInternalGeneral("a", "", L.Location("a buffer", -1)) ]

        # This is from the XML specification, § 4.2.1 ...
        #
        @test (evaluate("<!ENTITY Pub-Status \"This is a pre-release of the\nspecification.\">")
               == [ E.EntityDeclarationInternalGeneral("Pub-Status", "This is a pre-release of the\nspecification.",
                                                       L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 4.4.5 ...
        #
        @test (evaluate("<!ENTITY WhatHeSaid \"He said %YN;\" >")
               == [ E.EntityDeclarationInternalGeneral("WhatHeSaid", "He said %YN;", L.Location("a buffer", -1)) ])
    end

    @testset "Events/Entity Declarations, Internal Parameter (Positive)" begin
        # Basic tests ... empty entity value.
        #
        @test evaluate("<!ENTITY % a \"\">")    == [ E.EntityDeclarationInternalParameter("a", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % abc \"\">")  == [ E.EntityDeclarationInternalParameter("abc", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % é \"\">")    == [ E.EntityDeclarationInternalParameter("é", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % aé \"\">")   == [ E.EntityDeclarationInternalParameter("aé", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % éb \"\">")   == [ E.EntityDeclarationInternalParameter("éb", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % aéb \"\">")  == [ E.EntityDeclarationInternalParameter("aéb", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY\n%\na\n\"\">") == [ E.EntityDeclarationInternalParameter("a", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY\n%\ta\t\"\">") == [ E.EntityDeclarationInternalParameter("a", "", L.Location("a buffer", -1)) ]

        # This is from the XML specification, § 4.4.5 ...
        #
        @test (evaluate("<!ENTITY % YN \'\"Yes\"\' >")
               == [ E.EntityDeclarationInternalParameter("YN", "\"Yes\"", L.Location("a buffer", -1)) ])
    end
end
