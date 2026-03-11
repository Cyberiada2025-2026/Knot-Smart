# Architecture Guidelines
The Contribution Guidelines document described *what* we want to achieve. This document describes *how* to do it.

## Godot Fundamentals
Before discussing the main architectural decisions we need to provide more context. If you're already proficient in Godot programming feel free to skip this section.

### Scenes
The main abstraction that the Godot engine provides is the **scene tree** composed of **nodes**. The "scene" is a misnomer - the main purpose of that structure is to serialize common nodes and their children to the disk for reuse later. These scenes can be then be **composed** with each other.

> [!NOTE]
> Godot is centered around separating common node structures into **reusable components** in the form of scenes and scripted nodes. This is all powered by **composition**.

### GDScript
GDScript, on the other hand, is a language designed primarily for rapid prototyping. It's meant to get out of your way as much as possible, even when what you're trying to do is a quick and unmaintainable hack. While this is good for small solo prototypes it's unacceptable for long-term team projects.

> [!NOTE]
> While the engine itself is opinionated, the language itself is not - it's our job as the end user to set correct boundaries on what is and isn't allowed.

### The case for GDScript
While we could use C# in our project the Godot Engine itself was built around GDScript. This is evident both in the documentation and the sheer amound of tutorials for GDScript.

The C# support is still immature - a lot of functions don't have fully idiomatic bindings, use inconsistent naming conventions, and most importantly - **Godot 4 projects doesn't support exporting C#-based projects to the web**. Since web export is a hard requirement for this project, it makes C# a completely non-viable option for us.

## Component-based design

> [!TIP]
> Here's a good introductory video to component-based design. Click on the thumbnail to go to YouTube.
> 
> [![An introduction to component-based design](https://img.youtube.com/vi/74y6zWZfQKk/0.jpg)](https://www.youtube.com/watch?v=74y6zWZfQKk)

Given the previous information, we need a way to enforce component-based design across the entire project. We do this by **banning inheritance**.

> [!IMPORTANT]
> Using inheritance is strictly forbidden.

While inheritance may be useful in a lot of contexts, we don't actually need it in our case.

### But I want polymorphism!
GDScript is a dynamic language, and as such - every method call is already dispatched dynamically thanks to duck typing.

### But I want to reuse variables!
Godot explicitly favors composition. Use nodes instead.

### But I want more-detailed type information!
This is an actual valid use-case since duck typing erases types. However - enabling inheritance just for this sets a precedence. While this use-case is acknowledged, enabling it encourages people to give up and just use inheritance for everything else instead. While this will help with 5% of the actually relevant use-cases, it will inevitably degrade the quality of everything else.

> [!IMPORTANT]
> Banning inheritance forces us to rethink our problems. That is - instead of thinking in terms of class hierarchies we have to ask ourselves how to decompose these problems into different nodes.
