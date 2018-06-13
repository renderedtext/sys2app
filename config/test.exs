use Mix.Config

config(:sys2app,
  :callback, &Sys2app.TestCallback.test_callback/0)
