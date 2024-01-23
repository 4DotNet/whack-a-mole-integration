# Whack-A-Mole Game

[![Users Service](https://github.com/4DotNet/whack-a-mole-users/actions/workflows/build-container.yml/badge.svg)](https://github.com/4DotNet/whack-a-mole-users/actions/workflows/build-container.yml)
[![Games Service](https://github.com/4DotNet/whack-a-mole-games/actions/workflows/build-container.yml/badge.svg)](https://github.com/4DotNet/whack-a-mole-games/actions/workflows/build-container.yml)
[![Scores Service](https://github.com/4DotNet/whack-a-mole-scores/actions/workflows/build-container.yml/badge.svg)](https://github.com/4DotNet/whack-a-mole-scores/actions/workflows/build-container.yml)
[![Realtime Service](https://github.com/4DotNet/whack-a-mole-realtime-service/actions/workflows/build-container.yml/badge.svg)](https://github.com/4DotNet/whack-a-mole-realtime-service/actions/workflows/build-container.yml)

This is the Whack-A-Mole game, a completely over-engineered game to demonstrate microservices, containers, Azure Container Apps, and real-time communication. This project is managed at GitHub [GitHub Project Page](https://github.com/users/nikneem/projects/3), which is a private project that you need to have granted access for.

## Project structure

There are a couple of repo's involved for this project. This repo, the integration repo, deploys the central cloud environment that all other repo's take advantage of. In essense, it deploys a distributed cache, Container Apps Environment, Logging and intrumentation with Log Analytics & Application Insights, Web PubSub for real-time communication.

### Proxy service

The proxy service is going to be a low weight simple reverse proxy (YARP) to accept external traffic and redirect that to the appropriate service. The repository [can be found here](https://github.com/4DotNet/whack-a-mole-proxy)

### Users service

One service is responsible for creating and resolving users. There is not complicated identity management involved. Once a user registers, he will be assigned a GUID that is stored in the localstore of the browser. This GUID is now used to identify individuals. Once people get to know other people's GUID's they can impersonate other, we take that risk for now as it is only a game. The [Users Service Repository](https://github.com/nikneem/whack-a-mole-games-api) contains all the API Code.

### Game service

One service is responsible for creating games and allowing users to join a game (they become a player in this domain). There can be one game at a time in the new state. In this state, the game allows new players to join (up to x players at a time). The game then advances to active, started, and finished. When a game advances in state, we can create a new game allowing new players to already join the new game, while the previous game is still being played. There is also a cancelled state, allowing us to cancel the game at all times. Reading game information is allowed for everyone (anonymous access), while controlling game state and creating a new game can only be done by 4Dotnet workers (they must log in with their 4Dotnet account). [Repo is here](https://github.com/4DotNet/whack-a-mole-games)

### Vouchers service

The game can be configured to demand voucher codes upon joining a game. This vouchers service verifies wether a voucher is valid (or not), and invalidates vouchers after usage. [Repo is here](https://github.com/4DotNet/whack-a-mole-vouchers)

### Scores service

The scores service receives all the scores done by players. The scores services will be hammered upon when a game has started because each and every time a player whacks a mole, the response time in milliseconds is passed to the server as a request. With a [repo here](https://github.com/4DotNet/whack-a-mole-scores)

### Central dashboard

A central dashboard allows us to show the current game statistics, with a leader board and real-time incoming scores on the left-hand side. On the right-hand side, the dashboard shows the ability to join the new game scheduled for the next round.
