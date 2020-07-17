-record(monstate,{
    queue,
    qc,
    wpid,
    free=true,
    wref,
    init=false
}).

-record(sstate,{
    init=false,
    mpid=null,
    mref=null
}).
