# echo - Ruby

Echo code challenge based on [these requirements](echo.md)

## Techincal information

This application was built using Ruby Sinatra and the endpoints use [JSON:API v1.0](https://jsonapi.org/) as a format.

## Run locally

Note: this assumes you have ruby 3.2 and bundler installed.

1. clone the repo
2. inside the repo directory run `bundle install`
3. run tests `rubocop && rspec`
4. run `ruby app/server.rb`

Use cURL or Postman to send http requests to the server at `http://127.0.0.1:4567`
Server works using the exact API documentation specificed in the [requirements](echo.md#examples)

## Quick cURL commands to test the server

View endpoints:

```bash
curl -L -X GET 'http://127.0.0.1:4567/endpoints' 
```

Submit an endpoint:

```bash
curl -L -X POST 'http://127.0.0.1:4567/endpoints' \
-H 'Content-Type: application/vnd.api+json' \
-d '{
    "data": {
        "type": "endpoints",
        "attributes": {
            "verb": "GET",
            "path": "/revert_entropy",
            "response": {
              "code": 200,
              "headers": {},
              "body": "\"{ \"message\": \"INSUFFICIENT DATA FOR MEANINGFUL ANSWER\" }\""
            }
        }
    }
}'
```

Now you can run View endpoints again to check the enpoint is there.

Use the endpoint:

```bash
curl -L -X GET 'http://127.0.0.1:4567/revert_entropy' 
```
