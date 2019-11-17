# Slim SSTI + Sinatra/Rack cookie forgery

## Version

Date        | Author                  | Contact               | Version | Comment
---         | ---                     | ---                   | ---     | ---
17/11/2019  | noraj (Alexandre ZANNI) | noraj#0833 on discord | 1.0     | Document creation

Information displayed for CTF players:

+ **Name of the challenge** / **Nom du challenge**: `Fat`
+ **Category** / **Catégorie**: `Web`
+ **Internet**: not needed
+ **Difficulty** / **Difficulté**: Medium / Moyen

### Description


```
noraj why did you made two websites again?

Demo server (vulnerable): http://x.x.x.x:42423
Flag server (not vulnerable): http://x.x.x.x:42424

Flag format: sigsegv{flag}

author: [noraj](https://pwn.by/noraj/)
```

### Hints

- Hint1: Slim
- Hint2: Sinatra

## Integration

This challenge require a Docker Engine and Docker Compose.

Builds, (re)creates, starts, and attaches to containers for a service:

```
$ docker-compose up --build
```

Add `-d` if you want to detach the container.

## Solving

### Author solution

1. Login to the demo server with the demo credentials `demo`/`demo`
1. See a cookie named `rack.session`, rack is a modular Ruby webserver interface
1. Decode the cookie (see `rack_cookie.rb`), there is a username and role
1. Role is *user* so maybe we need to set to at *admin* at some point
1. A HTTP header is saying `Server: thin` which is a tiny ruby http server
1. At http://192.168.1.84:42423/home there is a form, let's try to send a SSTI payload
1. Most famous ruby templates are ERB and Slim (title is *Fat*).
1. Try ERB: `<%= 7 * 7 %>` doesn't work.
1. Try Slim: `#{ 7 * 7 }` works.
1. So we have a Slim SSTI. But most when trying a RCE or LFI payload we have an error message:
    ```
    This is not the way, you're loosing your time.
    ```
1. A famous Jinja2 + Django/Flask payload is `{{config.items()}}` to be able to read the web server secrets that like the key to sign cookies.
1. Here it must be a Ruby web framework. And the most famous one which is not RoR (Ruby on Rails) is Sinatra (as Rack is not really a web framework but a middleware). Ref. [1][1], [2][2].
1. Anyway, any 404 page will tell it's a Sinatra web app.
1. The payload to read the rack secret key is `#{Sinatra::Application.settings.session_secret}`.
1. With the key we are now able to re-sign cookie after they have been modified. So let's change role from *user* to *admin*.
1. (Bonus) Smart enough player could be able to bypass the blacklist and read the source code. But the FS (file system) is read-only.
1. Then on home page we ca see a demo flag.
1. Assuming the secret key is the same on flag server, we can reproduce the vuln and get the real flag.

[1]:https://www.ruby-toolbox.com/categories/web_app_frameworks
[2]:https://naturaily.com/blog/8-frameworks-ruby-not-rails

## Flag

`sigsegv{n1ce_SSTI_sc3nario_r1ght?}`