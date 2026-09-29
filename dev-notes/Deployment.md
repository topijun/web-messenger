
The web app will be deployed on Github Pages. 

The deployed web app is found here:
```
https://topijun.github.io/web-messenger/
```


The deployment will look like this:

```
GitHub Pages
https://<github-user>.github.io/<repo>/
        │
        │ HTTPS
        ▼
Flutter Web
        │
        │ HTTPS
        ▼
https://<ngrok-host>/
        │
        ▼
ngrok → localhost:8080
        │
        ▼
Serverpod development
        │
        ▼
PostgreSQL Dockerissa :8090

```
