-record(state,#{
    wmap,
    queue,
    qc
    }).

-record(worker,#{
    free,
    Ref,
    Pid
    }).