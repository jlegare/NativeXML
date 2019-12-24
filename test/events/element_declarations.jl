@testset "Events/Element Declarations" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    ED = Events.ElementDeclaration

    CMAny   = Events.ContentModels.AnyModel
    CMEmpty = Events.ContentModels.EmptyModel
    CMMixed = Events.ContentModels.MixedModel

    CMElement = Events.ContentModels.ElementModel

    Choice   = Events.ContentModels.ChoiceGroup
    Sequence = Events.ContentModels.SequenceGroup

    OneOrMore  = Events.ContentModels.OneOrMore
    Optional   = Events.ContentModels.Optional
    ZeroOrMore = Events.ContentModels.ZeroOrMore

    DC = E.DataContent
    ME = E.MarkupError

    @testset "Events/Element Declarations (Positive)" begin
        # Verify that the element name is handled properly ... just use ANY for the content model.
        #
        @test evaluate("<!ELEMENT a ANY>")   == [ ED(false, "a", CMAny(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT abc ANY>") == [ ED(false, "abc", CMAny(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT é ANY>")   == [ ED(false, "é", CMAny(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT aé ANY>")  == [ ED(false, "aé", CMAny(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT éb ANY>")  == [ ED(false, "éb", CMAny(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT aéb ANY>") == [ ED(false, "aéb", CMAny(), L.Location("a buffer", -1)) ]

        # White space is required following the element name. Just try various combinations, and check that it is
        # discarded.
        #
        @test evaluate("<!ELEMENT a\tANY>")    == [ ED(false, "a", CMAny(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a	ANY>") == [ ED(false, "a", CMAny(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a\n\nANY>")  == [ ED(false, "a", CMAny(), L.Location("a buffer", -1)) ]

        # Verify that the ANY content model is handled properly. This is mostly a matter of verifying that trailing
        # white space is discarded.
        #
        @test evaluate("<!ELEMENT a ANY >")        == [ ED(false, "a", CMAny(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a ANY        >") == [ ED(false, "a", CMAny(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a ANY\t>")       == [ ED(false, "a", CMAny(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a ANY\n>")       == [ ED(false, "a", CMAny(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a ANY\n\t>")     == [ ED(false, "a", CMAny(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a ANY\u09>")     == [ ED(false, "a", CMAny(), L.Location("a buffer", -1)) ]

        # Verify that the EMPTY content model is handled properly. This is mostly a matter of verifying that trailing
        # white space is discarded.
        #
        @test evaluate("<!ELEMENT a EMPTY >")        == [ ED(false, "a", CMEmpty(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a EMPTY        >") == [ ED(false, "a", CMEmpty(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a EMPTY\t>")       == [ ED(false, "a", CMEmpty(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a EMPTY\n>")       == [ ED(false, "a", CMEmpty(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a EMPTY\n\t>")     == [ ED(false, "a", CMEmpty(), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a EMPTY\u09>")     == [ ED(false, "a", CMEmpty(), L.Location("a buffer", -1)) ]

        # Verify that a mixed content model is handled properly. Assuming minimal white space for now.
        #
        @test evaluate("<!ELEMENT a (#PCDATA)>")  == [ ED(false, "a", CMMixed([ ]), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (#PCDATA)*>") == [ ED(false, "a", CMMixed([ ]), L.Location("a buffer", -1)) ]

        @test (evaluate("<!ELEMENT a (#PCDATA|b)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|b|c)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|b|c|d)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b"), CMElement("c"), CMElement("d") ]), L.Location("a buffer", -1)) ])

        # Still working with a mixed content model, verify that the child elements are handled properly.
        #
        @test (evaluate("<!ELEMENT a (#PCDATA|bcd)*>")
               == [ ED(false, "a", CMMixed([ CMElement("bcd") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|é)*>")
               == [ ED(false, "a", CMMixed([ CMElement("é") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|bé)*>")
               == [ ED(false, "a", CMMixed([ CMElement("bé") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|éc)*>")
               == [ ED(false, "a", CMMixed([ CMElement("éc") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|béc)*>")
               == [ ED(false, "a", CMMixed([ CMElement("béc") ]), L.Location("a buffer", -1)) ])

        @test (evaluate("<!ELEMENT a (#PCDATA|b|cde)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b"), CMElement("cde") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|b|é)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b"), CMElement("é") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|b|cé)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b"), CMElement("cé") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|b|éc)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b"), CMElement("éc") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|b|céd)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b"), CMElement("céd") ]), L.Location("a buffer", -1)) ])

        # Finally, verify that the various combinations of spurious white space in a mixed content model are handled
        # properly.
        #
        @test (evaluate("<!ELEMENT a  (#PCDATA| b)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a\n(#PCDATA| b)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a\t(#PCDATA| b)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b") ]), L.Location("a buffer", -1)) ])

        @test (evaluate("<!ELEMENT a (#PCDATA| b)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA |b)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA | b)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA| b )*>")
               == [ ED(false, "a", CMMixed([ CMElement("b") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA\t|\nb\t)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b") ]), L.Location("a buffer", -1)) ])

        @test (evaluate("<!ELEMENT a (#PCDATA|b| c)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|b|c )*>")
               == [ ED(false, "a", CMMixed([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|b| c )*>")
               == [ ED(false, "a", CMMixed([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (#PCDATA|b\t|\tc\n)*>")
               == [ ED(false, "a", CMMixed([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])

        @test (evaluate("<!ELEMENT a (#PCDATA|b\t|\tc\n)*\n>")
               == [ ED(false, "a", CMMixed([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])

        # Verify that a single-child element content model is handled properly. Assuming minimal white space for now.
        #
        @test evaluate("<!ELEMENT a (b)>")  == [ ED(false, "a", CMElement("b"), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b)+>") == [ ED(false, "a", OneOrMore(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b)?>") == [ ED(false, "a", Optional(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b)*>") == [ ED(false, "a", ZeroOrMore(CMElement("b")), L.Location("a buffer", -1)) ]

        # Fiddle with the white space.
        #
        @test evaluate("<!ELEMENT a  (b)>") == [ ED(false, "a", CMElement("b"), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a\n(b)>") == [ ED(false, "a", CMElement("b"), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a\t(b)>") == [ ED(false, "a", CMElement("b"), L.Location("a buffer", -1)) ]

        @test evaluate("<!ELEMENT a ( b)>")      == [ ED(false, "a", CMElement("b"), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b )>")      == [ ED(false, "a", CMElement("b"), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b) >")      == [ ED(false, "a", CMElement("b"), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (\nb\t)\n>") == [ ED(false, "a", CMElement("b"), L.Location("a buffer", -1)) ]

        @test evaluate("<!ELEMENT a (b)+>")       == [ ED(false, "a", OneOrMore(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a ( b)+>")      == [ ED(false, "a", OneOrMore(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b )+>")      == [ ED(false, "a", OneOrMore(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b)+ >")      == [ ED(false, "a", OneOrMore(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (\nb\t)\n+>") == [ ED(false, "a", OneOrMore(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b)\n+\t>")   == [ ED(false, "a", OneOrMore(CMElement("b")), L.Location("a buffer", -1)) ]

        @test evaluate("<!ELEMENT a (b)?>")       == [ ED(false, "a", Optional(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a ( b)?>")      == [ ED(false, "a", Optional(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b )?>")      == [ ED(false, "a", Optional(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b)? >")      == [ ED(false, "a", Optional(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (\nb\t)\n?>") == [ ED(false, "a", Optional(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b)\n?\t>")   == [ ED(false, "a", Optional(CMElement("b")), L.Location("a buffer", -1)) ]

        @test evaluate("<!ELEMENT a (b)*>")       == [ ED(false, "a", ZeroOrMore(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a ( b)*>")      == [ ED(false, "a", ZeroOrMore(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b )*>")      == [ ED(false, "a", ZeroOrMore(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b)* >")      == [ ED(false, "a", ZeroOrMore(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (\nb\t)\n*>") == [ ED(false, "a", ZeroOrMore(CMElement("b")), L.Location("a buffer", -1)) ]
        @test evaluate("<!ELEMENT a (b)*\t>")     == [ ED(false, "a", ZeroOrMore(CMElement("b")), L.Location("a buffer", -1)) ]

        # Verify that a choice-group content model is handled properly. Assuming minimal white space and no occurrence
        # indicator for now.
        #
        @test (evaluate("<!ELEMENT a (b|c)>")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (b|c|d)>")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c"), CMElement("d") ]), L.Location("a buffer", -1)) ])

        # Fiddle with the white space.
        #
        @test (evaluate("<!ELEMENT a  (b|c)>")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a\n(b|c)>")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a \t(b|c)>")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])

        @test (evaluate("<!ELEMENT a ( b|c)>")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (b |c)>")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a ( b |c)>")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])

        @test (evaluate("<!ELEMENT a (b| c)>")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (b|c )>")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (b| c )>")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])

        @test (evaluate("<!ELEMENT a ( b | c )>")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a ( b | c ) >")
               == [ ED(false, "a", Choice([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])

        # Throw in an occurrence indicator.
        #
        @test (evaluate("<!ELEMENT a (b|c)+>")
               == [ ED(false, "a", OneOrMore(Choice([ CMElement("b"), CMElement("c") ])), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (b|c)?>")
               == [ ED(false, "a", Optional(Choice([ CMElement("b"), CMElement("c") ])), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (b|c)*>")
               == [ ED(false, "a", ZeroOrMore(Choice([ CMElement("b"), CMElement("c") ])), L.Location("a buffer", -1)) ])

        # Verify that a sequence-group content model is handled properly. Assuming minimal white space and no occurrence
        # indicator for now.
        #
        @test (evaluate("<!ELEMENT a (b,c)>")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (b,c,d)>")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c"), CMElement("d") ]), L.Location("a buffer", -1)) ])

        # Fiddle with the white space.
        #
        @test (evaluate("<!ELEMENT a  (b,c)>")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a\n(b,c)>")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a \t(b,c)>")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])

        @test (evaluate("<!ELEMENT a ( b,c)>")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (b ,c)>")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a ( b ,c)>")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])

        @test (evaluate("<!ELEMENT a (b, c)>")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (b,c )>")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (b, c )>")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])

        @test (evaluate("<!ELEMENT a ( b , c )>")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a ( b , c ) >")
               == [ ED(false, "a", Sequence([ CMElement("b"), CMElement("c") ]), L.Location("a buffer", -1)) ])

        # Throw in an occurrence indicator.
        #
        @test (evaluate("<!ELEMENT a (b,c)+>")
               == [ ED(false, "a", OneOrMore(Sequence([ CMElement("b"), CMElement("c") ])), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (b,c)?>")
               == [ ED(false, "a", Optional(Sequence([ CMElement("b"), CMElement("c") ])), L.Location("a buffer", -1)) ])
        @test (evaluate("<!ELEMENT a (b,c)*>")
               == [ ED(false, "a", ZeroOrMore(Sequence([ CMElement("b"), CMElement("c") ])), L.Location("a buffer", -1)) ])
    end
end
