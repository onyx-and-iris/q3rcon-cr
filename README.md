# q3rcon-cr

A Quake3 RCON implementation

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     q3rcon:
       github: onyx-and-iris/q3rcon-cr
   ```

2. Run `shards install`

## Usage

```crystal
require "q3rcon"

# Connect to the server
client = Q3Rcon::Client.new(
  "127.0.0.1",
  28960,
  ENV["Q3RCON_PASSWORD"]? || "changeme"
)

# Send an RCON command
response = client.exec("status")

puts response
```

## Included CLI

### Flags

```console
Usage: q3rcon [options] <command>
    -h HOST, --host HOST             Server host
    -p PORT, --port PORT             Server port
    -w PASS, --password PASS         RCON password
    -i, --interactive                Interactive mode
        --help                       Show help
```

### Environment Variables

example .envrc:
```bash
#!/usr/bin/env bash

export Q3RCON_HOST="127.0.0.1"
export Q3RCON_PORT="28960"
export Q3RCON_PASSWORD="changeme"
```