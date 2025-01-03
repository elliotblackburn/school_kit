# SchoolKit

SchoolKit is a collection of tools for working with UK Secondary School data. It is designed to be used by teachers, school leaders, and data analysts to help them understand and improve their schools.

## Features

* Notebooks for analysing and visualising school performance data
* A library of functions for working with school performance data, this is for more advanced users who want to build their own tools. Programming knowledge is required.

## Notebooks

At the moment, the best way to use SchoolKit is through the notebooks. These are interactive documents that you can run through livebook. The notebooks typically allow you to select input data, and then generate tables and charts based on that data.

To get started, you will need to install Livebook. You can do this by visiting [https://livebook.dev/](https://livebook.dev/), and following the instructions to "Install Livebook". Once you have Livebook installed and running, you can run the notebooks by clicking on the buttons below.

* GCSE Attainment and Progress [![Run in Livebook](https://livebook.dev/badge/v1/gray.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Felliotblackburn%2Fschool_kit%2Fblob%2Fmain%2Fnotebooks%2Fpupil-attainment-and-progress.livemd)

## Installation as a library

SchoolKit is not current available on hex.pm, but you can install it from GitHub by adding it to your list of dependencies in `mix.exs`. It will be published once it is a little more stable, but right now it is in the early stages of development.

```elixir
def deps do
  [
    {:school_kit, github: "elliotblackburn/school_kit"}
  ]
end
```
