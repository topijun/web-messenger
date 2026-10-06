
**Serverpod is a backend framework for Dart.** It provides the infrastructure for building a server that handles things such as API endpoints, authentication, database access, and realtime communication.

### How does the Serverpod server relate to the project code?

In this project, the backend lives in `messenger_server/`. It is a separate Dart application that runs alongside the Flutter app.

The basic flow is:

```
Flutter app
    ↓
Serverpod client
    ↓
Serverpod server
    ↓
PostgreSQL database
```

The Flutter app does not access the database directly. It calls the Serverpod server through its endpoints.

### How are Serverpod functions generated?

Serverpod uses **code generation** based on the definitions in the server project.

For example, a Serverpod endpoint is written on the server:

```
class MessageEndpoint extends Endpoint {
  Future<MessageView> send(...) async {
    // ...
  }
}
```

Serverpod's generator reads the endpoint and protocol definitions and generates the corresponding **client-side API code** in `messenger_client`.

So the developer mainly writes the server-side definition once:

```
messenger_server/
    endpoints + protocol definitions
              ↓
        Serverpod generator
              ↓
messenger_client/
    generated client API
```

The Flutter application can then call the generated API with Dart methods instead of manually constructing HTTP requests.

**In short:** Serverpod is the layer that connects the Flutter application to the backend logic and database, while its code generator keeps the client API synchronized with the server's endpoint and data definitions.