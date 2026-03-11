# Contribution Guidelines
**tl;dr**: The main requirements to getting your code pulled are:
- making it easy to debug
- making it easy for others to read
- making it easy for others to use
- not forcing anyone to change their workflows unnecessarily
- not breaking the repository state

Fixing minor bugs is secondary - this can be done in further pull requests.

## Making it easy to debug

> [!IMPORTANT]
> ![Godot debugging tools](img/contribution_guidelines/debugging-utilities.png)
> 
> Godot has an extensive suite of debugging tools. If any of them can't be used as a 
> result of your pull request (e.g. - can't use the override camera or can't modify
> the remote scene tree) this is considered a major bug

Ask yourself:
- Can we modify your node's state in the remote viewer?
- Can we quickly modify its main parameters to test them?
- Is the main code path easy to follow?
- Is it easy to reason what is happening inside your code for others?

If not, then it's probably not easy to debug.
