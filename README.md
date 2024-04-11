# echo - Ruby

Echo code challenge based on [these requirements](echo.md)

## Techincal information

This application was build using Ruby Sinatra and the endpoints use [JSON:API v1.0](https://jsonapi.org/) as a format.

## Run locally

1. clone the repo
2. inside the repo directory run `bundle install`
3. run tests `rubocop && rspec`
4. run `ruby app/server.rb`

Use cURL or Postman to send http requests to the server at `http://127.0.0.1:4567`
Server works using the exact API documentation specificed in the [requirements](echo.md#examples)
