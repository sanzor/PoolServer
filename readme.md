# Supervised Pool Server
Pool Server using Erlang's `supervisor` and `gen_server` behaviours
In the (without_supervisor folder) Pool Server without Erlang behaviours
## Architecture

### **App Supervisor**
Manages the Pool Supervisor and the Pool Server
### **Pool Supervisor** : 
Manages workers that process client messages

### **Pool Server** : 
Handles client requests , querries client tasks to workers