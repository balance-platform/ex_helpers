defmodule ExHelpers.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_helpers,
      version: "0.2.0",
      elixir: ">= 1.3.0",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
#      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.18.0", only: :dev, runtime: false},
      {:timex, ">= 3.0.0"},
      {:memoize, "~> 1.3"},
    ]
  end
end
