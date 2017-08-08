nginxflip
---------
This script switches between two groups of NGINX upstreams for graceful deploys.

Usage
-----
1. Include two upstreams in your NGINX config file, "upstreamA" and "upstreamB".
2. Use one of the upstreams (whichever) in your `proxy_pass` commands.
3. Start processes for both upstreams at boot. We use supervisor for this.
4. Set some environment variables:
    * `NGINX_CONFIG`: path to your nginx config file
    * `UPSTREAM_BASE`: prefix of your upstream name
    * `RESTART_CMD_A`: bash command to restart group A workers
    * `RESTART_CMD_B`: bash command to restart group B workers
    * `VERIFY_CMD_A`: optional bash command to verify that group A workers are up
    * `VERIFY_CMD_B`: optional bash command to verify that group B workers are up
5. Call the nginx flipping script: `./flip.sh`

Example
-------
See `examples/nginx-site.conf` and `examples/supervisor-worker.conf`.

Example invocation script:
```
#!/bin/sh
export NGINX_CONFIG='/etc/nginx/sites-enabled/nginx-site.conf'
export UPSTREAM_BASE='upstream'
export RESTART_CMD_A='supervisorctl restart backend:00 backend:01'
export RESTART_CMD_B='supervisorctl restart backend:02 backend:03'
export VERIFY_CMD_A='curl -s http://localhost:7000/internal/health'
export VERIFY_CMD_B='curl -s http://localhost:7002/internal/health'
./flip.sh
```
