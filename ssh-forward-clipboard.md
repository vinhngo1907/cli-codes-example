## Exposing your clipboard over SSH

I frequently administer remote servers over SSH, and need to copy data to my clipboard.
If the text I want to copy all fits on one screen, then I simply select it with my mouse and press CMD-C, which asks relies on m y terminal emulator (xterm2) to throw it to the clipboard. 

This isn't practical for larger texts, like when I want to copy the whole contents of a file.

If I had been editing `large-file.txt` locally, I could easily copy its contents by using the `pbcopy` command:

```
cat large-file.txt | pbcopy
```

In this writeup, I show how we can expose the `pbcopy` command as a network daemon that listens on port `5556`, and is easily accessible from any machine you SSH into.

## Daemonizing pbcopy

The quickest way to "networkify" pbcopy is to run the following snippet in a dedicated terminal tab:

```bash
while (true); do nc -l 5556 | pbcopy; done
```

We just asked bash to launch netcat (`nc`), repeatedly wait for incoming connections on localhost:5556, and pipe any data received into pbcopy.

Now locally, the following two are equivalent:

```
echo "This text gets sent to clipboard" | pbcopy
echo "This text gets sent to clipboard" | nc localhost 5556
```

## Exposing our daemon to machines we SSH to

For security reasons, our "pbcopy daemon" only allows connections from localhost. But the goal is to allow you to pipe text to your local clipboard from a server you've SSHd into. This is done via SSH's reverse tunnel forwarding feature:

```
# SSH in to remote-server as usual, except -R asks that 
# remote's port 5556 is forwarded to your laptop's localhost:5556
ssh user@remote-server.com -R 5556:localhost:5556
```

If you'd prefer to enable reverse tunneling of port 5556 all your future outgoing SSH connections, the following adds the appropriate line to `~/.ssh/config`:

```
echo "RemoteForward 5556 localhost:5556" >> ~/.ssh/config
```

Having established the SSH reverse tunnel, you can now do the following from the remote server:

```
cat large-file.txt | nc -q0 localhost 5556
# -q0 is required for GNU's version of netcat to exit on eof; the osx version does it by default
```

If the remote server is missing `nc`, either run `sudo apt-get install netcat -y` or use telnet instead:

```
cat large-file.txt | telnet localhost 5556
```

Enjoy your newly-supercharged clipboard!

## Getting Fancier

If your laptop is running linux, replacing `pbcopy` with `xcopy` should work:

```bash
while (true); do nc -l 5556 | xcopy; done
```

For a more verbose version of our "pbcopy daemon" that prints what's being sent to the clipboard, try this:

```bash
while (true); do echo "Waiting..." ;  nc -l 5556 | pbcopy; echo "Copied: "; pbpaste | sed 's/^/  /'; done
```

To automatically start the "pbcopy daemon" on boot, you should use launchd. See http://seancoates.com/blogs/remote-pbcopy (if down, use [Google's cached version](http://webcache.googleusercontent.com/search?q=cache:http://seancoates.com/blogs/remote-pbcopy))

To expose `pbpaste` as well as `pbcopy`, see https://gist.github.com/vinhngo1907