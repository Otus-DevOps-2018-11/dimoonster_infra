#!/bin/sh

mv /tmp/reddit.service /etc/systemd/system/reddit.service

/bin/systemctl daemon-reload
/bin/systemctl enable reddit.service
