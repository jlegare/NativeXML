@testset "Events/Entity Declarations" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Entity Declarations, Internal General (Positive)" begin
        # Basic tests ... empty entity value.
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY a \"\">")))) 
               == [ E.EntityDeclarationInternal("a", false, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY abc \"\">")))) 
               == [ E.EntityDeclarationInternal("abc", false, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY é \"\">")))) 
               == [ E.EntityDeclarationInternal("é", false, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY aé \"\">")))) 
               == [ E.EntityDeclarationInternal("aé", false, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY éb \"\">")))) 
               == [ E.EntityDeclarationInternal("éb", false, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY aéb \"\">")))) 
               == [ E.EntityDeclarationInternal("aéb", false, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY\na\n\"\">")))) 
               == [ E.EntityDeclarationInternal("a", false, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY\na\t\"\">")))) 
               == [ E.EntityDeclarationInternal("a", false, "", "a buffer", -1) ])

        # This is from the XML specification, § 4.2.1 ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY Pub-Status \"This is a pre-release of the\nspecification.\">")))) 
               == [ E.EntityDeclarationInternal("Pub-Status", false, "This is a pre-release of the\nspecification.", 
                                                "a buffer", -1) ])

        # This is from the XML specification, § 4.4.5 ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY WhatHeSaid \"He said %YN;\" >"))))
               == [ E.EntityDeclarationInternal("WhatHeSaid", false, "He said %YN;", "a buffer", -1) ])
    end

    @testset "Events/Entity Declarations, Internal Parameter (Positive)" begin
        # Basic tests ... empty entity value.
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % a \"\">")))) 
               == [ E.EntityDeclarationInternal("a", true, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % abc \"\">")))) 
               == [ E.EntityDeclarationInternal("abc", true, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % é \"\">")))) 
               == [ E.EntityDeclarationInternal("é", true, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % aé \"\">")))) 
               == [ E.EntityDeclarationInternal("aé", true, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % éb \"\">")))) 
               == [ E.EntityDeclarationInternal("éb", true, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % aéb \"\">")))) 
               == [ E.EntityDeclarationInternal("aéb", true, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY\n%\na\n\"\">")))) 
               == [ E.EntityDeclarationInternal("a", true, "", "a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY\n%\ta\t\"\">")))) 
               == [ E.EntityDeclarationInternal("a", true, "", "a buffer", -1) ])

        # This is from the XML specification, § 4.4.5 ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!ENTITY % YN \'\"Yes\"\' >"))))
               == [ E.EntityDeclarationInternal("YN", true, "\"Yes\"", "a buffer", -1) ])
    end
end
