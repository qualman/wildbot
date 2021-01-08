# Wildbot

Wildbot is a simple chatbot-like interface, offering an effortless, reliable way to manage incidents.

## Basics

Wildbot allows users to quickly take notes or record status updates during an incident. Data is stored redundantly in a persistent redis database, and incidents will resume across restarts or other interruptions.

Once an active incident ends, data is stored in an archive in redis, and can be easily exported to JSON for further recording or sharing.

Wildbot's focus is demonstrating a simple and stable interface for the important and actively-evolving nature of managing incidents.

## Usage

### Prerequisites

Wildbot runs on pure Ruby (built for 2.7.2), and is backed by Redis. You simply need Ruby and Redis to run the app!

It speaks to the default Redis port locally. You can use your own local redis server, or a pre-configured copy is provided using docker-compose, which is available with Docker and [Docker Desktop](https://www.docker.com/products/docker-desktop).

Environment variables are managed by the `dotenv` gem. You simply need to make the requisite `.env` file from the template provided.

```
cd wildbot
cp .env.template .env
```

### Starting Up

Start up your local redis, or navigate to the root directory and use `docker-compose build && docker-compose up` to start redis. Then, start the app:

```
cd wildbot
gem install bundler
bundle install
ruby app/wildbot.rb
```

## Testing

The goal of Wildbot is to be written in such a way that the user is not left with many options to get into a bad state. However, a (very) limited testing suite is available. More will be added in the future.
