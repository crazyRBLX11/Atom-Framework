# Atom Framework
An easy to implement Roblox framework.

## Introduction
The Atom Framework is an open-source framework used for crazyattaker1's games on Roblox.
The Atom Framework is easy to work with and encourages modular coding.
Documentation can be found in the documentation/ folder.

## Features
Atom was designed to do all the heavy work for multi module codebases. Some of the features Atom contains to assist you as a developer are:
* Services, Controllers and Components - Seperate server and client code by using specialized containers for each type and a special type for shared code called Components.
* Libraries - Packages from the Atom registry to include extra functionality that you can implement in your own modules.
* Out-of-the-box Networking - A custom developed network solution that doesn't rely on Roblox remotes.
* Automatic error handling - Allow Atom to automatically deal with errors or tell it what to do when an error occurs.
* Automatic Garbage Collection - Atom uses the Janitor module to clean up instances when they're no longer needed.

## Building Atom's source code
Do <b>NOT</b> build from this repository, due to limitations with putting scripts under ModuleScripts I've had to structure the repository entirely different than how Atom thinks it's structured. If you build this repository and try to use it nothing will work. If you know how I could fix this please put a pull request or an issue ticket and I'll contact you via it. If you'd like to use Atom, please use a pre-built .rbxm under releases.