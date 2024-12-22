defmodule SchoolKit.MixProject do
  use Mix.Project

  def project do
    [
      app: :school_kit,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:csv, "~> 3.2"},
      {:jason, "~> 1.4"},
      {:mox, "~> 1.2", only: :test}
    ]
  end
end
