@testset "Events/Document Type Declaration" begin
    E = Events
    L = Events.Lexical

    @testset "Events/Document Type Declaration (Positive)" begin
        # Basic tests ... no external/internal subset specification.
        #
        @test collect(E.events(L.State(IOBuffer("<!DOCTYPE a>")))) == [ E.DTDStart("a", nothing, nothing, "a buffer", -1),
                                                                        E.DTDEnd("a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<!DOCTYPE abc>")))) == [ E.DTDStart("abc", nothing, nothing, "a buffer", -1),
                                                                          E.DTDEnd("a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<!DOCTYPE é>")))) == [ E.DTDStart("é", nothing, nothing, "a buffer", -1),
                                                                        E.DTDEnd("a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<!DOCTYPE aé>")))) == [ E.DTDStart("aé", nothing, nothing, "a buffer", -1),
                                                                         E.DTDEnd("a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<!DOCTYPE éb>")))) == [ E.DTDStart("éb", nothing, nothing, "a buffer", -1),
                                                                         E.DTDEnd("a buffer", -1) ]
        @test collect(E.events(L.State(IOBuffer("<!DOCTYPE aéb>")))) == [ E.DTDStart("aéb", nothing, nothing, "a buffer", -1),
                                                                          E.DTDEnd("a buffer", -1) ]

        @test collect(E.events(L.State(IOBuffer("<!DOCTYPE\na\t>")))) == [ E.DTDStart("a", nothing, nothing, "a buffer", -1),
                                                                           E.DTDEnd("a buffer", -1) ]

        # Basic tests ... no internal subset specification. Assume the document type name is handled correctly.
        #
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a SYSTEM \"\">")))) 
               == [ E.DTDStart("a", nothing, "", "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a\nSYSTEM\t\"\"	>")))) 
               == [ E.DTDStart("a", nothing, "", "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a SYSTEM \"   \">")))) 
               == [ E.DTDStart("a", nothing, "   ", "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a PUBLIC \"\" \"\">")))) 
               == [ E.DTDStart("a", "", "", "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a\nPUBLIC\r\"\"\t\"\"	>")))) 
               == [ E.DTDStart("a", "", "", "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a PUBLIC \"   \" \"   \">")))) 
               == [ E.DTDStart("a", "   ", "   ", "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        
        # This is from the XML specification, § 2.8 ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting SYSTEM \"hello.dtd\">")))) 
               == [ E.DTDStart("greeting", nothing, "hello.dtd", "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        #
        # ... with a few simple variations ...
        #
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting SYSTEM 'hello.dtd'>")))) 
               == [ E.DTDStart("greeting", nothing, "hello.dtd", "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting SYSTEM '\"hello.dtd\"'>")))) 
               == [ E.DTDStart("greeting", nothing, "\"hello.dtd\"", "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting SYSTEM \"'hello.dtd'\">")))) 
               == [ E.DTDStart("greeting", nothing, "'hello.dtd'", "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        #
        # ... and a few variations that add a public identifier. (Yes, these public identifiers are bogus. That isn't
        # the point of these tests.)
        #
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting PUBLIC 'salut.dtd' 'hello.dtd'>")))) 
               == [ E.DTDStart("greeting", "salut.dtd", "hello.dtd", "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting PUBLIC '\"salut.dtd\"' '\"hello.dtd\"'>")))) 
               == [ E.DTDStart("greeting", "\"salut.dtd\"", "\"hello.dtd\"", "a buffer", -1), E.DTDEnd("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE greeting PUBLIC \"'salut.dtd'\" \"'hello.dtd'\">")))) 
               == [ E.DTDStart("greeting", "'salut.dtd'", "'hello.dtd'", "a buffer", -1), E.DTDEnd("a buffer", -1) ])

        # Basic tests ... no external subset specification. Assume the document type name is handled correctly.
        #
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a [")))) 
               == [ E.DTDStart("a", nothing, nothing, "a buffer", -1), E.DTDInternalStart("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a[")))) 
               == [ E.DTDStart("a", nothing, nothing, "a buffer", -1), E.DTDInternalStart("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a\n[")))) 
               == [ E.DTDStart("a", nothing, nothing, "a buffer", -1), E.DTDInternalStart("a buffer", -1) ])
        @test (collect(E.events(L.State(IOBuffer("<!DOCTYPE a	[")))) 
               == [ E.DTDStart("a", nothing, nothing, "a buffer", -1), E.DTDInternalStart("a buffer", -1) ])
    end
end
