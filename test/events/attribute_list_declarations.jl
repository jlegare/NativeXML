@testset "Events/Attribute List Declarations" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    DC = Events.DataContent
    ME = Events.MarkupError

    ADs = Events.AttributeDeclarations
    AD  = Events.AttributeDeclaration

    CData    = Events.StringType
    Entity   = Events.EntityType
    Entities = Events.EntitiesType
    IDRef    = Events.IDRefType
    IDRefs   = Events.IDRefsType
    ID       = Events.IDType
    NmToken  = Events.NameTokenType
    NmTokens = Events.NameTokensType

    Enumerated = Events.EnumeratedType
    Notations  = Events.EnumeratedNotationType

    DefaultValue = Events.DefaultValue
    Implied      = Events.Implied
    Required     = Events.Required

    @testset "Events/Attribute List Declarations (Positive ... empty attribute list)" begin
        # Verify that the element name is handled properly.
        #
        @test evaluate("<!ATTLIST e>")   == [ ADs(false, "e", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<!ATTLIST efg>") == [ ADs(false, "efg", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<!ATTLIST é>")   == [ ADs(false, "é", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<!ATTLIST eé>")  == [ ADs(false, "eé", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<!ATTLIST éf>")  == [ ADs(false, "éf", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<!ATTLIST eéf>") == [ ADs(false, "eéf", [ ], L.Location("a buffer", -1)) ]

        # Make sure that if there are no attribute declarations, the white space following the element name is properly
        # discarded.
        #
        @test evaluate("<!ATTLIST e >")       == [ ADs(false, "e", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<!ATTLIST e\n>")      == [ ADs(false, "e", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<!ATTLIST e\t>")      == [ ADs(false, "e", [ ], L.Location("a buffer", -1)) ]
        @test evaluate("<!ATTLIST e\t\n >")   == [ ADs(false, "e", [ ], L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations, CDATA (Positive)" begin
        # Verify that the element name is handled properly. Just use a CDATA/#REQUIRED model.
        #
        events = evaluate("<!ATTLIST e a CDATA #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", CData(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e abc CDATA #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "abc", CData(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e é CDATA #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "é", CData(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e aé CDATA #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "aé", CData(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e éb CDATA #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "éb", CData(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e aéb CDATA #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "aéb", CData(), Required()) ], L.Location("a buffer", -1)) ]

        # Verify that the CDATA model is handled properly. Use #REQUIRED for now. This is mostly a matter of verifying
        # that surrounding white space is discarded.
        #
        events = evaluate("<!ATTLIST e a CDATA #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", CData(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\nCDATA\n#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", CData(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\tCDATA\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", CData(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\n\tCDATA\n\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", CData(), Required()) ], L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations, ENTITY (Positive)" begin
        # Verify that the ENTITY model is handled properly. Use #REQUIRED for now. This is mostly a matter of verifying
        # that surrounding white space is discarded.
        #
        events = evaluate("<!ATTLIST e a ENTITY #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Entity(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\nENTITY\n#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Entity(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\tENTITY\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Entity(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\n\tENTITY\n\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Entity(), Required()) ], L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations, ENTITIES (Positive)" begin
        # Verify that the ENTITIES model is handled properly. Use #REQUIRED for now. This is mostly a matter of
        # verifying that surrounding white space is discarded.
        #
        events = evaluate("<!ATTLIST e a ENTITIES #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Entities(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\nENTITIES\n#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Entities(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\tENTITIES\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Entities(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\n\tENTITIES\n\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Entities(), Required()) ], L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations, IDREF (Positive)" begin
        # Verify that the IDREF model is handled properly. Use #REQUIRED for now. This is mostly a matter of verifying
        # that surrounding white space is discarded.
        #
        events = evaluate("<!ATTLIST e a IDREF #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", IDRef(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\nIDREF\n#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", IDRef(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\tIDREF\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", IDRef(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\n\tIDREF\n\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", IDRef(), Required()) ], L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations, IDREFS (Positive)" begin
        # Verify that the IDREFS model is handled properly. Use #REQUIRED for now. This is mostly a matter of verifying
        # that surrounding white space is discarded.
        #
        events = evaluate("<!ATTLIST e a IDREFS #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", IDRefs(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\nIDREFS\n#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", IDRefs(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\tIDREFS\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", IDRefs(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\n\tIDREFS\n\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", IDRefs(), Required()) ], L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations, ID (Positive)" begin
        # Verify that the ID model is handled properly. Use #REQUIRED for now. This is mostly a matter of verifying
        # that surrounding white space is discarded.
        #
        events = evaluate("<!ATTLIST e a ID #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", ID(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\nID\n#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", ID(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\tID\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", ID(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\n\tID\n\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", ID(), Required()) ], L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations, NMTOKEN (Positive)" begin
        # Verify that the NMTOKEN model is handled properly. Use #REQUIRED for now. This is mostly a matter of verifying
        # that surrounding white space is discarded.
        #
        events = evaluate("<!ATTLIST e a NMTOKEN #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", NmToken(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\nNMTOKEN\n#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", NmToken(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\tNMTOKEN\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", NmToken(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\n\tNMTOKEN\n\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", NmToken(), Required()) ], L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations, NMTOKENS (Positive)" begin
        # Verify that the NMTOKENS model is handled properly. Use #REQUIRED for now. This is mostly a matter of verifying
        # that surrounding white space is discarded.
        #
        events = evaluate("<!ATTLIST e a NMTOKENS #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", NmTokens(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\nNMTOKENS\n#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", NmTokens(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\tNMTOKENS\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", NmTokens(), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a\n\tNMTOKENS\n\t#REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", NmTokens(), Required()) ], L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations, enumerated type (Positive)" begin
        # Verify that the enumerated type is handled properly. Use #REQUIRED for now. First check that basic grouping is
        # handled.
        #
        events = evaluate("<!ATTLIST e a (b) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Enumerated([ "b" ]), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a (b|c) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Enumerated([ "b", "c" ]), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a (b|c|d) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Enumerated([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        # Verify that white space in the enumeration is handled properly.
        #
        events = evaluate("<!ATTLIST e a ( b |c|d) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Enumerated([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a (b |c|d) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Enumerated([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a ( b|c|d) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Enumerated([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a (b|c |d) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Enumerated([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a (b| c|d) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Enumerated([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a (\n\nb|\t\nc\n\t|\t\td\t\t) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Enumerated([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        # Verify that various NMTOKENs in the enumeration are handled properly.
        #
        events = evaluate("<!ATTLIST e a (0|1|2|33|444|5555) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Enumerated([ "0", "1", "2", "33", "444", "5555" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a (:a|\uc0|\ud8|\uf8) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Enumerated([ ":a", "\uc0", "\ud8", "\uf8" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a (-|--|.|\ub7|\u0300) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Enumerated([ "-", "--", ".", "\ub7", "\u0300" ]), Required()) ],
                              L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations, enumerated NOTATIONs type (Positive)" begin
        # Verify that the enumerated NOTATIONs type is handled properly. Use #REQUIRED for now. First check that basic
        # grouping is handled.
        #
        events = evaluate("<!ATTLIST e a NOTATION (b) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Notations([ "b" ]), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION (b|c) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Notations([ "b", "c" ]), Required()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION (b|c|d) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Notations([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        # Verify that white space in the enumeration is handled properly.
        #
        events = evaluate("<!ATTLIST e a NOTATION ( b |c|d) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Notations([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION (b |c|d) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Notations([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION ( b|c|d) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Notations([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION (b|c |d) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Notations([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION (b| c|d) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Notations([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION (\n\nb|\t\nc\n\t|\t\td\t\t) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Notations([ "b", "c", "d" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        # Verify that various NMTOKENs in the enumeration are handled properly.
        #
        events = evaluate("<!ATTLIST e a NOTATION (a0|b1|c2|d33|e444|f5555) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Notations([ "a0", "b1", "c2", "d33", "e444", "f5555" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION (a:a|b\uc0|c\ud8|d\uf8) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Notations([ "a:a", "b\uc0", "c\ud8", "d\uf8" ]), Required()) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION (a-|b--|c.|d\ub7|e\u0300) #REQUIRED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", Notations([ "a-", "b--", "c.", "d\ub7", "e\u0300" ]), Required()) ],
                              L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations, #REQUIRED (Positive)" begin
        # #REQUIRED has been tested enough earlier. This is just to indicate that I haven't forgotten it.
        #
    end

    @testset "Events/Attribute List Declarations, #IMPLIED (Positive)" begin
        # Verify that #IMPLIED is handled properly. This is mostly a matter of verifying that the surrounding white
        # space is discarded.
        #
        events = evaluate("<!ATTLIST e a CDATA #IMPLIED>")
        @test events == [ ADs(false, "e", [ AD(false, "a", CData(), Implied()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a CDATA\n#IMPLIED\n>")
        @test events == [ ADs(false, "e", [ AD(false, "a", CData(), Implied()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a CDATA\t#IMPLIED\t>")
        @test events == [ ADs(false, "e", [ AD(false, "a", CData(), Implied()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a CDATA\t\n#IMPLIED\n\t>")
        @test events == [ ADs(false, "e", [ AD(false, "a", CData(), Implied()) ], L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations, default value (Positive)" begin
        # Verify that a default attribute value is handled properly.
        #
        events = evaluate("<!ATTLIST e a CDATA \"\">")
        @test events == [ ADs(false, "e", [ AD(false, "a", CData(), DefaultValue(false, [ ])) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a CDATA \" \">")
        @test events == [ ADs(false, "e",
                              [ AD(false, "a", CData(),
                                   DefaultValue(false, [ DC(" ", true, L.Location("a buffer", -1))])) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a CDATA \"Hello, World!\">")
        @test events == [ ADs(false, "e",
                              [ AD(false, "a", CData(),
                                   DefaultValue(false, [ DC("Hello", false, L.Location("a buffer", -1)),
                                                         DC(",", false, L.Location("a buffer", -1)),
                                                         DC(" ", true, L.Location("a buffer", -1)),
                                                         DC("World!", false, L.Location("a buffer", -1))])) ],
                              L.Location("a buffer", -1)) ]

        # Verify that surrounding white space is discarded.
        #
        events = evaluate("<!ATTLIST e a CDATA \"value\">")
        @test events == [ ADs(false, "e",
                              [ AD(false, "a", CData(),
                                   DefaultValue(false, [ DC("value", false, L.Location("a buffer", -1))])) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a CDATA\n\"value\"\n>")
        @test events == [ ADs(false, "e",
                              [ AD(false, "a", CData(),
                                   DefaultValue(false, [ DC("value", false, L.Location("a buffer", -1))])) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a CDATA\t\"value\"\t>")
        @test events == [ ADs(false, "e",
                              [ AD(false, "a", CData(),
                                   DefaultValue(false, [ DC("value", false, L.Location("a buffer", -1))])) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a CDATA\n\t\"value\"\t\n>")
        @test events == [ ADs(false, "e",
                              [ AD(false, "a", CData(),
                                   DefaultValue(false, [ DC("value", false, L.Location("a buffer", -1))])) ],
                              L.Location("a buffer", -1)) ]

        # Verify that #FIXED is handled properly. This is mostly a matter of checking that surrounding white space is
        # discarded.
        #
        events = evaluate("<!ATTLIST e a CDATA #FIXED \"value\">")
        @test events == [ ADs(false, "e",
                              [ AD(false, "a", CData(),
                                   DefaultValue(true, [ DC("value", false, L.Location("a buffer", -1))])) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a CDATA\n#FIXED\n\"value\">")
        @test events == [ ADs(false, "e",
                              [ AD(false, "a", CData(),
                                   DefaultValue(true, [ DC("value", false, L.Location("a buffer", -1))])) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a CDATA\t#FIXED\t\"value\">")
        @test events == [ ADs(false, "e",
                              [ AD(false, "a", CData(),
                                   DefaultValue(true, [ DC("value", false, L.Location("a buffer", -1))])) ],
                              L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a CDATA\n\t#FIXED\t\n\"value\">")
        @test events == [ ADs(false, "e",
                              [ AD(false, "a", CData(),
                                   DefaultValue(true, [ DC("value", false, L.Location("a buffer", -1))])) ],
                              L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations (Negative ... missing element name)" begin
        events = evaluate("<!ATTLIST")
        @test events == [ ME("ERROR: White space is required following the 'ATTLIST' keyword.", L.Location("a buffer", -1)),
                          ME("ERROR: Expecting an element name.", L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST ")
        @test events == [ ME("ERROR: Expecting an element name.", L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST >")
        @test events == [ ME("ERROR: Expecting an element name.", L.Location("a buffer", -1)),
                          DC(">", false, L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations (Negative ... missing TAGC)" begin
        events = evaluate("<!ATTLIST e")
        @test events == [ ME("ERROR: Expecting '>' to end an attribute list declaration.", L.Location("a buffer", -1)),
                          ADs(true, "e", [ ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e ")
        @test events == [ ME("ERROR: Expecting '>' to end an attribute list declaration.", L.Location("a buffer", -1)),
                          ADs(true, "e", [ ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a CDATA #IMPLIED")
        @test events == [ ME("ERROR: Expecting '>' to end an attribute list declaration.", L.Location("a buffer", -1)),
                          ADs(true, "e", [ AD(false, "a", CData(), Implied()) ], L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations (Negative ... missing attribute name)" begin
        # This is tricky, because in the absence of an attribute name, any of the attribute types will be interpreted as
        # the attribute name, and the error will occur later. So we'll use an enumerated attribute type, which starts
        # with '('.
        #
        events = evaluate("<!ATTLIST e (a) #IMPLIED>")
        @test events == [ ME("ERROR: Expecting '>' to end an attribute list declaration.", L.Location("a buffer", -1)),
                          ADs(true, "e", [ ], L.Location("a buffer", -1)),
                          DC("(", false, L.Location("a buffer", -1)),
                          DC("a", false, L.Location("a buffer", -1)),
                          DC(")", false, L.Location("a buffer", -1)),
                          DC(" ", true, L.Location("a buffer", -1)),
                          DC("#IMPLIED", false, L.Location("a buffer", -1)),
                          DC(">", false, L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e(a) #IMPLIED>")
        @test events == [ ME("ERROR: Expecting '>' to end an attribute list declaration.", L.Location("a buffer", -1)),
                          ADs(true, "e", [ ], L.Location("a buffer", -1)),
                          DC("(", false, L.Location("a buffer", -1)),
                          DC("a", false, L.Location("a buffer", -1)),
                          DC(")", false, L.Location("a buffer", -1)),
                          DC(" ", true, L.Location("a buffer", -1)),
                          DC("#IMPLIED", false, L.Location("a buffer", -1)),
                          DC(">", false, L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations (Negative ... missing/invalid attribute type)" begin
        events = evaluate("<!ATTLIST e a #IMPLIED>")
        @test events == [ ME("ERROR: Expecting an attribute type.", L.Location("a buffer", -1)),
                          ADs(false, "e", [ AD(false, "a", Main.Events.StringType(), Implied()) ], L.Location("a buffer", -1)) ]

        # The attribute type is misspelled here. I purposefully chose something other than CDATA, to nail down the
        # recovery for the attribute type ... i.e., the fallback to CDATA.
        #
        events = evaluate("<!ATTLIST e a ENTITIE #IMPLIED>")
        @test events == [ ME("ERROR: Expecting an attribute type.", L.Location("a buffer", -1)),
                          ME("ERROR: Expecting a quoted attribute value.", L.Location("a buffer", -1)),
                          ME("ERROR: Expecting '>' to end an attribute list declaration.", L.Location("a buffer", -1)),
                          ADs(true, "e", [ AD(true, "a", CData(), DefaultValue(false, [ ])) ], L.Location("a buffer", -1)),
                          DC("ENTITIE", false, L.Location("a buffer", -1)),
                          DC(" ", true, L.Location("a buffer", -1)),
                          DC("#IMPLIED", false, L.Location("a buffer", -1)),
                          DC(">", false, L.Location("a buffer", -1)) ]
    end

    @testset "Events/Attribute List Declarations (Negative ... NOTATION missing TAGO for group)" begin
        events = evaluate("<!ATTLIST e a NOTATION a | b) #IMPLIED>")
        @test events == [  ME("ERROR: Expecting '(' to open an enumerated notation attribute value.", L.Location("a buffer", -1)),
                           ADs(false, "e", [ AD(false, "a", Notations([ "a", "b" ]), Implied()) ], L.Location("a buffer", -1)) ]

    end

    @testset "Events/Attribute List Declarations (Negative ... NOTATION missing white space)" begin
        events = evaluate("<!ATTLIST e a NOTATION(a | b) #IMPLIED>")
        @test events == [  ME("ERROR: White space is required following the 'NOTATION' keyword.", L.Location("a buffer", -1)),
                           ADs(false, "e", [ AD(false, "a", Notations([ "a", "b" ]), Implied()) ], L.Location("a buffer", -1)) ]

    end

    @testset "Events/Attribute List Declarations (Negative ... NOTATION missing TAGC for group)" begin
        events = evaluate("<!ATTLIST e a NOTATION (a | b #IMPLIED>")
        @test events == [  ME("ERROR: Expecting '|' or ')'.", L.Location("a buffer", -1)),
                           ADs(true, "e", [ AD(true, "a", Notations([ "a", "b" ]), Implied()) ], L.Location("a buffer", -1)) ]

    end

    @testset "Events/Attribute List Declarations (Negative ... missing TAGC for group)" begin
        events = evaluate("<!ATTLIST e a (a | b #IMPLIED>")
        @test events == [  ME("ERROR: Expecting '|' or ')'.", L.Location("a buffer", -1)),
                           ADs(true, "e", [ AD(true, "a", Enumerated([ "a", "b" ]), Implied()) ], L.Location("a buffer", -1)) ]

    end

    @testset "Events/Attribute List Declarations (Negative ... invalid group)" begin
        events = evaluate("<!ATTLIST e a (| b) #IMPLIED>")
        @test events == [  ME("ERROR: Expecting a NMTOKEN for an enumerated attribute value.", L.Location("a buffer", -1)),
                           ADs(true, "e", [ AD(true, "a", Enumerated([ "b" ]), Implied()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION (| b) #IMPLIED>")
        @test events == [  ME("ERROR: Expecting a name for an enumerated attribute value.", L.Location("a buffer", -1)),
                           ADs(true, "e", [ AD(true, "a", Notations([ "b" ]), Implied()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a (< | b) #IMPLIED>")
        @test events == [  ME("ERROR: Expecting a NMTOKEN for an enumerated attribute value.", L.Location("a buffer", -1)),
                           ADs(true, "e", [ AD(true, "a", Enumerated([ "b" ]), Implied()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION (< | b) #IMPLIED>")
        @test events == [  ME("ERROR: Expecting a name for an enumerated attribute value.", L.Location("a buffer", -1)),
                           ADs(true, "e", [ AD(true, "a", Notations([ "b" ]), Implied()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a (a b) #IMPLIED>")
        @test events == [  ME("ERROR: Expecting '|' between items in an enumerated attribute value.", L.Location("a buffer", -1)),
                           ADs(true, "e", [ AD(true, "a", Enumerated([ "a", "b" ]), Implied()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION (a b) #IMPLIED>")
        @test events == [  ME("ERROR: Expecting '|' between items in an enumerated attribute value.", L.Location("a buffer", -1)),
                           ADs(true, "e", [ AD(true, "a", Notations([ "a", "b" ]), Implied()) ], L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a (a | b] #IMPLIED>")
        @test events == [ ME("ERROR: Expecting '|' or ')'.", L.Location("a buffer", -1)),
                          ME("ERROR: Expecting a quoted attribute value.", L.Location("a buffer", -1)),
                          ME("ERROR: Expecting '>' to end an attribute list declaration.", L.Location("a buffer", -1)),
                          ADs(true, "e", [ AD(true, "a", Enumerated([ "a", "b" ]), DefaultValue(false, [ ])) ],
                              L.Location("a buffer", -1)),
                          DC("]", false, L.Location("a buffer", -1)),
                          DC(" ", true, L.Location("a buffer", -1)),
                          DC("#IMPLIED", false, L.Location("a buffer", -1)),
                          DC(">", false, L.Location("a buffer", -1)) ]

        events = evaluate("<!ATTLIST e a NOTATION (a | b] #IMPLIED>")
        @test events == [ ME("ERROR: Expecting '|' or ')'.", L.Location("a buffer", -1)),
                          ME("ERROR: Expecting a quoted attribute value.", L.Location("a buffer", -1)),
                          ME("ERROR: Expecting '>' to end an attribute list declaration.", L.Location("a buffer", -1)),
                          ADs(true, "e", [ AD(true, "a", Notations([ "a", "b" ]), DefaultValue(false, [ ])) ],
                              L.Location("a buffer", -1)),
                          DC("]", false, L.Location("a buffer", -1)),
                          DC(" ", true, L.Location("a buffer", -1)),
                          DC("#IMPLIED", false, L.Location("a buffer", -1)),
                          DC(">", false, L.Location("a buffer", -1)) ]
    end
end
