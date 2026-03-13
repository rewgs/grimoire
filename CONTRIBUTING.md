## architecture

This library follows a very simple architecture:

Each type is defined as a class in each subdirectory of [`grim`](./grim).

[Testing](./tests/) is critical -- otherwise, it's very difficult to actually write a library when your only runtime is a DAW, and what you're doing is potentially highly dependent on the myriad details local to your DAW project. Whenever it makes sense, a function returns both its value and an error message, as this highly improves testing ergnomics.

## performance

Being a library, we must expect that it will be used to its fullest extent possible. Therefore, in order to avoid using unnecessary resources, each type should perform as little initialization as possible, opting instead to private declare `nil` variables and then retrieve them in a Python `@property`-ish fashion.

## style

You can probably tell that this was written by someone that likes Go.

This codebase prefers privtate `camelCase` and ``
