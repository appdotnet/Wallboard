# Wallboard

Wallboard is a web browser for OS X designed to be used primarily with [information radiators](http://alistair.cockburn.us/Information+radiator). It has no UI; instead, upon startup, it fills every attached screen with a full-screen WebKit browser. Configuration is via command-line modification of the OS X user defaults store.

## Usage

Before launch, configure URLs to load like so:

```bash
    $ defaults write net.app.Wallboard url.0 http://www.google.com
    $ defaults write net.app.Wallboard url.1 http://www.yahoo.com
```

URL keys are in the format url.&lt;number>, where &lt;number> is a zero-based index of attached screens. At the moment you may either quit the application or use the HTTP API to change the current page. Keyboard and mouse input should work, but have not been extensively tested.

Wallboard can be added to Login Items for a user with minimal permissions. Upon launch, Wallboard will load the URLs configured in the user defaults store.

Wallboard can be quit like a normal application &mdash; use &#8984;Q.

## HTTP API

Wallboard can also be configured via a HTTP API. Responses are JSON-encoded, and any POST bodies must be JSON-encoded as well. URL-encoded POST bodies are not allowed. At the moment, no mechanism for authentication is provided. Wallboard listens on port 9244 by default, but this can be changed:

```bash
    $ defaults write net.app.Wallboard httpport -int 9245
```

Wallboard advertises itself via Bonjour. The service name used is <code>_wallboard._tcp.</code>.

The API may be disabled altogether if desired:

```bash
    $ defaults write net.app.Wallboard disablehttp -bool YES
```

### GET /screens — Get all screens

```bash
    $ curl http://wallboard.local:9244/screens
    [
        {
            "saved_url" : "http:\/\/www.google.com",
            "current_url" : "http:\/\/www.google.com",
            "height" : 1080,
            "width" : 1920,
            "api_endpoint" : "\/screens\/0"
        },
        {
            "saved_url" : "http:\/\/www.yahoo.com",
            "current_url" : "http:\/\/www.yahoo.com",
            "height" : 1080,
            "width" : 1920,
            "api_endpoint" : "\/screens\/1"
        }
    ]
```

### GET /screens/:screen_id — Get one screen

```bash
    $ curl http://wallboard.local:9244/screens/0
    {
        "saved_url" : "http:\/\/www.google.com",
        "current_url" : "http:\/\/www.google.com",
        "height" : 1080,
        "width" : 1920,
        "api_endpoint" : "\/screens\/0"
    }
```

Attempts to access screens which do not exist will return a 404.

### POST /screens/:screen_id — Set URL

```bash
    $ curl -H 'Content-type: application/json' --data-ascii '{"url":"http://www.google.com"}' http://10.1.1.48:9244/screens/0
    {
        "saved_url" : null,
        "current_url" : "http:\/\/www.google.com\/",
        "height" : 1080,
        "width" : 1920,
        "api_endpoint" : "\/screens\/0"
    }
```

In addition, if the POSTed object includes <code>"save": true</code>, the user defaults object will be updated, and Wallboard will navigate to that URL when it is opened next.

## Development

If you're hacking on Wallboard (please do!), you can disable full-screen mode by setting the following preference:

```bash
    $ defaults write net.app.Wallboard devmode -bool YES
```

## Security concerns

Wallboard is designed for use on trusted networks. You can only navigate to http or https URLs via the API, but it may be possible to inject javascript into the browser instances.

## Feedback

Email me if you have any questions: [bryan@ber.gd](mailto:bryan@ber.gd). Or talk to me on [App.net](http://app.net): I'm
[@berg](https://alpha.app.net/berg). 
