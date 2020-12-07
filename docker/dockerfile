FROM elixir:alpine

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force

RUN apk update
RUN apk add the_silver_searcher entr
