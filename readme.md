## nix

This all probably only works on linux:

#### 1. Enter the environment

```bash
$ nix-shell
[...lots of console spam the first time]
[nix-shell:]$
```

#### 2. If you don't have an avd set up, make one

```bash
[nix-shell:]$ android create avd -t android-23 -b x86 -d "Nexus 5" -n nexus
```

That command seeme to create slightly screwy avds. I ran `$ android avd` and then hit `edit` and `save` without any changes on mine, which seems to fix it :/

#### 3. Start the JS server and emulator

Both commands block: either background then (add `&` at the end) to run in the same terminal, or open a terminal for each

```bash
[nix-shell:]$ npm start
[nix-shell:]$ emulator -avd nexus
```


#### 4. Run it!

```bash
[nix-shell:]$ run-android
```

Note that this `run-android` is provided by [`shell.nix`](./shell.nix), and wraps the call to `react-native-cli`'s `react-native run-android` command in the FHS environment so that the build works.
