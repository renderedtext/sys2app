# Sys2app - System Environment to Application Environment

Sys2app is a library application designed to be the first dependency started in your Elixir application. It sets up the application environment based on the system environment or other sources, effectively enabling run-time configuration.

## Features

- **Run-time Configuration**: Sets up the application environment dynamically at runtime.
- **Callback Execution**: Executes a designated callback to configure the environment before other dependencies are started.
- **Supervisor Integration**: Integrates with the Elixir supervisor to ensure the callback is executed in the correct context.

## Usage

Configure the callback in your config.exs or environment-specific configuration files:

```elixir
config :sys2app,
  callback: {YourModule, :your_callback_function, []}
```

## License

This software is licensed under [the Apache 2.0 license](LICENSE).