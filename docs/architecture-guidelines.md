# Architecture Guidelines
The Contribution Guidelines document described *what* we want to achieve. This document describes *how* to do it.

## Godot Fundamentals
Before discussing the main architectural decisions we need to provide more context. The main abstraction that the Godot engine provides is the **scene tree** composed of **nodes**.

### Scenes
The "scene" is a misnomer - the main purpose of that structure is to serialize common nodes and their children to the disk for reuse later. These scenes can be then be **composed** with each other.

> [!NOTE]
> Godot is centered around separating common node structures into **reusable components** in the form of scenes and scripted nodes. This is all powered by **composition**.

### GDScript
GDScript, on the other hand, is a language designed primarily for rapid prototyping. It's meant to get out of your way as much as possible, even when what you're trying to do is a quick and unmaintainable hack. While this is good for small solo prototypes it's unacceptable for long-term team projects.

> [!NOTE]
> While the engine itself is opinionated, the language itself is not - it's our job as the end user to set correct boundaries on what is and isn't allowed.

### The case for GDScript
While we could use C# in our project the Godot Engine itself was built around GDScript. This is evident both in the documentation and the sheer amound of tutorials for GDScript.

The C# support is still immature - a lot of functions don't have fully idiomatic bindings, use inconsistent naming conventions, and most importantly - **Godot 4 projects doesn't support exporting C#-based projects to the web**. Since web export is a hard requirement for this project, it makes C# completely non-viable for us.
