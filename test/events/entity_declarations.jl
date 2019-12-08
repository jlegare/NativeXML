@testset "Events/Entity Declarations" begin
    evaluate(s) = collect(E.events(L.State(IOBuffer(s))))

    E = Events
    L = Events.Lexical

    function ExternalGeneralData(name, public_id, system_id, notation, location)
        return E.EntityDeclarationExternalGeneralData(name, E.ExternalIdentifier(public_id, system_id, location), 
                                                      notation, location)
    end

    function ExternalGeneralText(name, public_id, system_id, location)
        return E.EntityDeclarationExternalGeneralText(name, E.ExternalIdentifier(public_id, system_id, location), location)
    end

    function ExternalParameter(name, public_id, system_id, location)
        return E.EntityDeclarationExternalParameter(name, E.ExternalIdentifier(public_id, system_id, location), location)
    end

    InternalGeneral   = E.EntityDeclarationInternalGeneral
    InternalParameter = E.EntityDeclarationInternalParameter

    @testset "Events/Entity Declarations, Internal General (Positive)" begin
        # Basic tests ... empty entity value.
        #
        @test evaluate("<!ENTITY a \"\">")   == [ InternalGeneral("a", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY abc \"\">") == [ InternalGeneral("abc", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY é \"\">")   == [ InternalGeneral("é", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY aé \"\">")  == [ InternalGeneral("aé", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY éb \"\">")  == [ InternalGeneral("éb", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY aéb \"\">") == [ InternalGeneral("aéb", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY\na\n\"\">") == [ InternalGeneral("a", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY\na\t\"\">") == [ InternalGeneral("a", "", L.Location("a buffer", -1)) ]

        # Basic tests ... non-empty entity value.
        #
        @test evaluate("<!ENTITY e \"a\">")       == [ InternalGeneral("e", "a", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY e \"abc\">")     == [ InternalGeneral("e", "abc", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY e \"é\">")       == [ InternalGeneral("e", "é", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY e \"aé\">")      == [ InternalGeneral("e", "aé", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY e \"éb\">")      == [ InternalGeneral("e", "éb", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY e \"aéb\">")     == [ InternalGeneral("e", "aéb", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY e \"\na\n\">")   == [ InternalGeneral("e", "\na\n", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY e \"\na\t\">")   == [ InternalGeneral("e", "\na\t", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY e \"&other;\">") == [ InternalGeneral("e", "&other;", L.Location("a buffer", -1)) ]

        # This is from the XML specification, § 4.2.1 ...
        #
        @test (evaluate("<!ENTITY Pub-Status \"This is a pre-release of the\nspecification.\">")
               == [ InternalGeneral("Pub-Status", "This is a pre-release of the\nspecification.", L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 4.4.5 ...
        #
        @test (evaluate("<!ENTITY WhatHeSaid \"He said %YN;\" >")
               == [ InternalGeneral("WhatHeSaid", "He said %YN;", L.Location("a buffer", -1)) ])
    end

    @testset "Events/Entity Declarations, Internal General (Negative ... invalid or absent entity name.)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        @test (evaluate("<!ENTITY")
               == [ E.MarkupError("ERROR: Expecting an entity name.",
                                  [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                    L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])


        events = evaluate("<!ENTITY>")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        events = evaluate("<!ENTITY >")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        # This one is a little weird: we're picking up "PUBLIC" as the entity name. I'll have to figure out later if
        # that's allowed or not, but there doesn't appear to be anything in the specification that forbids it.
        #
        events = evaluate("<!ENTITY PUBLIC")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!ENTITY \"\"")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        events = evaluate("<!ENTITY ''")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        events = evaluate("<!ENTITY <")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))
    end

    @testset "Events/Entity Declarations, Internal Parameter (Positive)" begin
        # Basic tests ... empty entity value.
        #
        @test evaluate("<!ENTITY % a \"\">")    == [ InternalParameter("a", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % abc \"\">")  == [ InternalParameter("abc", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % é \"\">")    == [ InternalParameter("é", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % aé \"\">")   == [ InternalParameter("aé", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % éb \"\">")   == [ InternalParameter("éb", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % aéb \"\">")  == [ InternalParameter("aéb", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY\n%\na\n\"\">") == [ InternalParameter("a", "", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY\n%\ta\t\"\">") == [ InternalParameter("a", "", L.Location("a buffer", -1)) ]

        # Basic tests ... non-empty entity value.
        #
        @test evaluate("<!ENTITY % e \"a\">")       == [ InternalParameter("e", "a", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % e \"abc\">")     == [ InternalParameter("e", "abc", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % e \"é\">")       == [ InternalParameter("e", "é", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % e \"aé\">")      == [ InternalParameter("e", "aé", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % e \"éb\">")      == [ InternalParameter("e", "éb", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % e \"aéb\">")     == [ InternalParameter("e", "aéb", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % e \"\na\n\">")   == [ InternalParameter("e", "\na\n", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % e \"\na\t\">")   == [ InternalParameter("e", "\na\t", L.Location("a buffer", -1)) ]
        @test evaluate("<!ENTITY % e \"&other;\">") == [ InternalParameter("e", "&other;", L.Location("a buffer", -1)) ]

        # This is from the XML specification, § 4.4.5 ...
        #
        @test evaluate("<!ENTITY % YN \'\"Yes\"\' >") == [ InternalParameter("YN", "\"Yes\"", L.Location("a buffer", -1)) ]
    end

    @testset "Events/Entity Declarations, Internal Parameter (Negative ... invalid or absent entity name.)" begin
        # Be careful with some of these tests ... the parser keeps going, so we only check the FIRST event. (Otherwise
        # we're testing the results of some other part of the parser.)
        #
        @test (evaluate("<!ENTITY %")
               == [ E.MarkupError("ERROR: Expecting an entity name.",
                                  [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                    L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ], L.Location("a buffer", -1)) ])


        events = evaluate("<!ENTITY %>")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        events = evaluate("<!ENTITY % >")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        # This one is a little weird: we're picking up "PUBLIC" as the entity name. I'll have to figure out later if
        # that's allowed or not, but there doesn't appear to be anything in the specification that forbids it.
        #
        events = evaluate("<!ENTITY % PUBLIC")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting a quoted string.", [ ], L.Location("a buffer", -1)))

        events = evaluate("<!ENTITY % \"\"")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        events = evaluate("<!ENTITY % ''")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))

        events = evaluate("<!ENTITY % <")
        @test length(events) > 1
        @test (first(events) == E.MarkupError("ERROR: Expecting an entity name.",
                                              [ L.Token(L.mdo, "<!", L.Location("a buffer", -1)),
                                                L.Token(L.text, "ENTITY", L.Location("a buffer", -1)) ],
                                              L.Location("a buffer", -1)))
    end

    @testset "Events/Entity Declarations, External General (Positive)" begin
        # Basic tests ... fixed public/system identifier.
        #
        @test (evaluate("<!ENTITY a PUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalGeneralText("a", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY abc PUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalGeneralText("abc", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY é PUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalGeneralText("é", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY aé PUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalGeneralText("aé", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY éb PUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalGeneralText("éb", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY aéb PUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalGeneralText("aéb", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY\na\nPUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalGeneralText("a", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY\na\tPUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalGeneralText("a", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        # Basic tests ... fixed entity name ...
        #
        @test (evaluate("<!ENTITY a SYSTEM \"\">") == [ ExternalGeneralText("a", nothing, "", L.Location("a buffer", -1)) ])
        @test (evaluate("<!ENTITY a\nSYSTEM\t\"\"	>")
               == [ ExternalGeneralText("a", nothing, "", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY a SYSTEM \"   \">") == [ ExternalGeneralText("a", nothing, "   ", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY a PUBLIC \"\" \"\">") == [ ExternalGeneralText("a", "", "", L.Location("a buffer", -1)) ])
        @test (evaluate("<!ENTITY a\nPUBLIC\r\"\"\t\"\"	>") == [ ExternalGeneralText("a", "", "", L.Location("a buffer", -1)) ])
        @test (evaluate("<!ENTITY a PUBLIC \"   \" \"   \">")
               == [ ExternalGeneralText("a", "   ", "   ", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY a SYSTEM \"hello.dtd\">")
               == [ ExternalGeneralText("a", nothing, "hello.dtd", L.Location("a buffer", -1)) ])

        # ... fixed entity name with system identifier ...
        #
        @test (evaluate("<!ENTITY a SYSTEM \"hello.dtd\">")
               == [ ExternalGeneralText("a", nothing, "hello.dtd", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY a SYSTEM 'hello.dtd'>")
               == [ ExternalGeneralText("a", nothing, "hello.dtd", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY a SYSTEM '\"hello.dtd\"'>")
               == [ ExternalGeneralText("a", nothing, "\"hello.dtd\"", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY a SYSTEM \"'hello.dtd'\">")
               == [ ExternalGeneralText("a", nothing, "'hello.dtd'", L.Location("a buffer", -1)) ])

        # ... fixed entity name with public/system identifier ...
        #
        @test (evaluate("<!ENTITY a PUBLIC \"salut.dtd\" \"hello.dtd\">")
               == [ ExternalGeneralText("a", "salut.dtd", "hello.dtd", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY a PUBLIC 'salut.dtd' 'hello.dtd'>")
               == [ ExternalGeneralText("a", "salut.dtd", "hello.dtd", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY a PUBLIC '\"salut.dtd\"' '\"hello.dtd\"'>")
               == [ ExternalGeneralText("a", "\"salut.dtd\"", "\"hello.dtd\"", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY a PUBLIC \"'salut.dtd'\" \"'hello.dtd'\">")
               == [ ExternalGeneralText("a", "'salut.dtd'", "'hello.dtd'", L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 4.2.2 ...
        #
        @test (evaluate("<!ENTITY open-hatch"
                        * " PUBLIC \"-//Textuality//TEXT Standard open-hatch boilerplate//EN\""
                        * " \"http://www.textuality.com/boilerplate/OpenHatch.xml\">")
               == [ ExternalGeneralText("open-hatch", "-//Textuality//TEXT Standard open-hatch boilerplate//EN",
                                        "http://www.textuality.com/boilerplate/OpenHatch.xml", L.Location("a buffer", -1)) ])
    end

    @testset "Events/Entity Declarations, External Parameter (Positive)" begin
        # Basic tests ... fixed public/system identifier.
        #
        @test (evaluate("<!ENTITY % a PUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalParameter("a", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % abc PUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalParameter("abc", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % é PUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalParameter("é", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % aé PUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalParameter("aé", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % éb PUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalParameter("éb", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % aéb PUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalParameter("aéb", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY %\na\nPUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalParameter("a", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY %\na\tPUBLIC \"hello.ent\" \"salut.ent\">")
               == [ ExternalParameter("a", "hello.ent", "salut.ent", L.Location("a buffer", -1)) ])

        # Basic tests ... fixed entity name ...
        #
        @test (evaluate("<!ENTITY % a SYSTEM \"\">") == [ ExternalParameter("a", nothing, "", L.Location("a buffer", -1)) ])
        @test (evaluate("<!ENTITY % a\nSYSTEM\t\"\"	>") == [ ExternalParameter("a", nothing, "", L.Location("a buffer", -1)) ])
        @test (evaluate("<!ENTITY % a SYSTEM \"   \">") == [ ExternalParameter("a", nothing, "   ", L.Location("a buffer", -1)) ])
        @test (evaluate("<!ENTITY % a PUBLIC \"\" \"\">") == [ ExternalParameter("a", "", "", L.Location("a buffer", -1)) ])
        @test (evaluate("<!ENTITY % a\nPUBLIC\r\"\"\t\"\"	>")
               == [ ExternalParameter("a", "", "", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % a PUBLIC \"   \" \"   \">")
               == [ ExternalParameter("a", "   ", "   ", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % a SYSTEM \"hello.dtd\">")
               == [ ExternalParameter("a", nothing, "hello.dtd", L.Location("a buffer", -1)) ])

        # ... fixed entity name with system identifier ...
        #
        @test (evaluate("<!ENTITY % a SYSTEM \"hello.dtd\">")
               == [ ExternalParameter("a", nothing, "hello.dtd", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % a SYSTEM 'hello.dtd'>")
               == [ ExternalParameter("a", nothing, "hello.dtd", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % a SYSTEM '\"hello.dtd\"'>")
               == [ ExternalParameter("a", nothing, "\"hello.dtd\"", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % a SYSTEM \"'hello.dtd'\">")
               == [ ExternalParameter("a", nothing, "'hello.dtd'", L.Location("a buffer", -1)) ])

        # ... fixed entity name with public/system identifier ...
        #
        @test (evaluate("<!ENTITY % a PUBLIC \"salut.dtd\" \"hello.dtd\">")
               == [ ExternalParameter("a", "salut.dtd", "hello.dtd", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % a PUBLIC 'salut.dtd' 'hello.dtd'>")
               == [ ExternalParameter("a", "salut.dtd", "hello.dtd", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % a PUBLIC '\"salut.dtd\"' '\"hello.dtd\"'>")
               == [ ExternalParameter("a", "\"salut.dtd\"", "\"hello.dtd\"", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY % a PUBLIC \"'salut.dtd'\" \"'hello.dtd'\">")
               == [ ExternalParameter("a", "'salut.dtd'", "'hello.dtd'", L.Location("a buffer", -1)) ])

        # This is from the XML specification, § 4.1 ...
        #
        @test (evaluate("<!ENTITY % ISOLat2 SYSTEM \"http://www.xml.com/iso/isolat2-xml.entities\" >")
               == [ ExternalParameter("ISOLat2", nothing, "http://www.xml.com/iso/isolat2-xml.entities",
                                      L.Location("a buffer", -1)) ])
    end

    @testset "Events/Entity Declarations, External Data (Positive)" begin
        # Basic tests ... fixed entity name, fixed public/system identifier, with notation specification.
        #
        @test (evaluate("<!ENTITY e PUBLIC \"hello.ent\" \"salut.ent\" NDATA a>")
               == [ ExternalGeneralData("e", "hello.ent", "salut.ent", "a", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY e PUBLIC \"hello.ent\" \"salut.ent\" NDATA abc>")
               == [ ExternalGeneralData("e", "hello.ent", "salut.ent", "abc", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY e PUBLIC \"hello.ent\" \"salut.ent\" NDATA é>")
               == [ ExternalGeneralData("e", "hello.ent", "salut.ent", "é", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY e PUBLIC \"hello.ent\" \"salut.ent\" NDATA aé>")
               == [ ExternalGeneralData("e", "hello.ent", "salut.ent", "aé", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY e PUBLIC \"hello.ent\" \"salut.ent\" NDATA éb>")
               == [ ExternalGeneralData("e", "hello.ent", "salut.ent", "éb", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY e PUBLIC \"hello.ent\" \"salut.ent\" NDATA aéb>")
               == [ ExternalGeneralData("e", "hello.ent", "salut.ent", "aéb", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY e PUBLIC \"hello.ent\" \"salut.ent\" NDATA\na\n>")
               == [ ExternalGeneralData("e", "hello.ent", "salut.ent", "a", L.Location("a buffer", -1)) ])

        @test (evaluate("<!ENTITY e PUBLIC \"hello.ent\" \"salut.ent\" NDATA\na\t>")
               == [ ExternalGeneralData("e", "hello.ent", "salut.ent", "a", L.Location("a buffer", -1)) ])
    end
end
