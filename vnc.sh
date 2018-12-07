#!/bin/bash

# Remove VNC lock (if process already killed)
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1
# Run VNC server with tail in the foreground
vncserver :1 -geometry 1346x740 && tail -F ~/.vnc/*.log
