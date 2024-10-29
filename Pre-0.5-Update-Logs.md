V0.1
Implemented a simple module loader.

V0.2
Moved some of the code in the main script into modular code for readability.
Added SubTicks.
Temporarily removed my ModuleLoader as it broke intellisense.
Added the serializer.

V0.4
Implemented the AtomMain.GetService() function,
Implemented the AtomMain.CreateRemoteEvent() function,
Implemented the AtomMain.CreateUnreliableEvent() function,
Implented the Atom.GetSignal() function,

V0.5
Moved the serializer to a seperate script for modularity and added a copy of it's requirements to it.
Fixed the cylical dependency bug in the Module Loader.