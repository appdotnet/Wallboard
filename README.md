# Wallboard

Wallboard is a web browser for OS X designed to be used primarily with [information radiators](http://alistair.cockburn.us/Information+radiator). It has no UI; instead, upon startup, it fills every attached screen with a full-screen WebKit browser. Configuration is via command-line modification of the OS X user defaults store.

## Usage

Before launch, configure URLs to load like so:

```bash
    $ defaults write net.app.Wallboard url.0 http://www.google.com
```

URL keys are in the format url.&lt;number>, where &lt;number> is a zero-based index of attached screens.

Wallboard can be added to Login Items for a user with minimal permissions. Upon launch, Wallboard will load the URLs configured in the user defaults store.

Wallboard can be quit like a normal application &mdash; use &#8984;Q.

## HTTP API

Wallboard can also be configured via a HTTP API. Responses are JSON-encoded, and any POST bodies must be JSON-encoded as well. URL-encoded POST bodies are not allowed.

Get all screens

Get one screen

Set URL

The API may be disabled

API advertises bonjour service

## Development

Dev mode

## Feedback

Email us
