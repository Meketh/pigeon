FROM elixir:alpine

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force

# RUN apt-get update
# RUN apt-get install silversearcher-ag entr
RUN apk update
RUN apk add the_silver_searcher entr
