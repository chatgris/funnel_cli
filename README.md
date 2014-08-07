[![Build Status](https://travis-ci.org/chatgris/funnel_cli.png?branch=master)](https://travis-ci.org/chatgris/funnel_cli)
# FunnelCli

FunnelCli is a command line tool build to ease the development of the [Funnel
Streaming API](https://github.com/AF83/funnel).

Elixir `v0.15` is required.


## Command


``` shell
Usage:

  * funnel_cli register http://funnel.dev
  * funnel_cli index index_name index_configuration_in_json
  * funnel_cli query index_name query_configuration_in_json
  * funnel_cli queries index_name
  * funnel_cli push index_name document_in_json

Option:

  * `-name`: Select a configuration name. Aliased as `-n`
```
