# blst Verification

This repository contains specifications and correctness proofs for the [blst](https://github.com/supranational/blst) BLS12-381 signature library.

# Building and running
The easiest way to build the library and run the proofs is to use [Docker](https://www.docker.com/).

1. Install [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/).
2. Clone the submodules: `git submodule update --init`
3. Build a Docker image containing all of the dependencies: `docker-compose build`
4. Run the proofs inside the Docker container: `docker-compose run blst`

Running `docker-compose run --entrypoint bash blst` will enter an interactive shell within the container, which is often useful for debugging.
