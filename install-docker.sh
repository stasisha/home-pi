#!/bin/bash

bash -c "$(curl -fsSL https://get.docker.com)"
sudo usermod -aG docker $USER
