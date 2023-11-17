#!/bin/bash
sleep 10
sudo apt update
sleep 10
sudo apt install mongodb -y
sudo systemctl start mongodb
sudo systemctl enable mongodb
