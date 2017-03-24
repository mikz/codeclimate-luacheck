# Code Climate luacheck Engine [![Build Status](https://travis-ci.org/mikz/codeclimate-luacheck.svg?branch=master)](https://travis-ci.org/mikz/codeclimate-luacheck)

CodeClimate Engine that runs [luacheck](https://github.com/mpeterv/luacheck/) on Lua files.
Uses [linguist](https://github.com/github/linguist) to detect Lua files.

## Engine

To enable the luacheck engine add the following to your `.codeclimate.yml` file:

```yml
engines:
  luacheck:
    enabled: true
ratings:
  paths:
    - "**.lua"
```

## Configuration

Luacheck engine supports plenty of configuration options.

### Checks

You can control which checks to enable/disable via [patterns](http://luacheck.readthedocs.io/en/stable/cli.html#patterns):

```yaml
engines:
  luacheck:
    enabled: true
    checks:
      LC631: # disable check 631
        enabled: false
      LC4.2: # disable shadowing declarations of arguments or redefining them
        enabled: false
```

### Config

You can control global configuration options of luacheck:

```yaml
engines:
  luacheck:
    enabled: true
    config:
      allow_defined: # you can use both enabled: true/false and just true/false
        enabled: true
      allow_defined_top: false
      module: false
      compat: true
      std: # which standard library to use, all are concatenated with +
        - min
        - busted
      globals:
        - val
      read_globals:
        - read
      new_globals:
        - new
      new_read_globals:
        - new
      not_globals:
        - new
      ignore:
        - new
      enable:
        - new
      only: # only run global-related warnings
        - 1
```

## Testing

```shell
make build test integration
```

