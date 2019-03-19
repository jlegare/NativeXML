module Lexical

@enum TokenType begin
    mdo     # markup delimiter open ... <!
    mdc     # markup delimiter close ... >
    dso     # declaration subset open ... [
    dsc     # declaratino subset close ... ]
    msc     # marked section close ... ]]
    com     # comment ... --
    rni     # reserved name indicator ... #
    lit     # literal ... "
    lita    # alternative literal ... '
    grpo    # group open ... (
    grpc    # group close ... )
    and     # and connector ... &
    or      # or connector ... |
    seq     # sequence connector ... ,
    opt     # optional occurrence indicator ... ?
    rep     # zero-or-more occurrence indicator ... *
    plus    # one-or-more occurrence indicator ... +
    minus   # exclusion/omission flag ... -
    cro     # character reference open ... &#
    ero     # entity reference open ... &
    pero    # parameter entity reference open ... %
    refc    # reference close ... ;
    pio     # processing instruction open ... <?
    pic     # processing instruction close ... >
    stago   # start tag open ... <
    etago   # end tag open ... </
    tagc    # tag close ... >
    net     # null end tag ... /
    vi      # value indicator ... =
end

struct Token
   token_type  ::TokenType
   value       ::String
   file_name   ::String
   line_number ::UInt64
end

end
