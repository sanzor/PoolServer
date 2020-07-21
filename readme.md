# Supervised Pool Server
Pool Server with and without using Erlang's `supervisor` and `gen_server` behaviours

**Without generic behaviour implementation**

In the `app_1` there are 4 modules:
- `sv` acting as a dispatcher for messages from potential clients
- `monitor` acting as supervisor (for the `worker`) and also as a `gen_server` that can be queried by `sv` regarding the state of its `worker`.
  This module forwards received messages to the `worker` if its `free` or places them in  a `queue` for later dequeuing (when worker is ready)
-  `worker` the processing unit for the requests
- `common` module that will contain reuseable logic

