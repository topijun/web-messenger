# messenger_server

This is the starting point for your Serverpod server.

To run your server, you first need to start Postgres and Redis. It's easiest to do with Docker.

    docker compose up --build --detach

Then you can start the Serverpod server.

    dart bin/main.dart

Registration and password-reset emails use Gmail SMTP. Copy
`config/passwords.yaml.example` to gitignored `config/passwords.yaml` and set
`smtpPassword` to a local Gmail App Password. See `dev-notes/Setup.md`.
Never commit that password.

When you are finished, you can shut down Serverpod with `Ctrl-C`, then stop Postgres and Redis.

    docker compose stop
