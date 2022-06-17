#!/bin/bash
sudo dnf update -y && sudo dnf install docker -y
sudo usermode -aG docker $(whoami)
docker run -d -p 8080:80 nginx